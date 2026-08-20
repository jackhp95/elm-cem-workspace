module Generate.Config exposing (decodeConfigResult, extractComponents, extractLibraryInfo)

import Cem
import Dict
import Generate.Normalize exposing (dropNamelessMembers, mergeComponentsByTagName, normalizeAttrTypes)
import Generate.Types exposing (Config, ConfigResult, FamiliesConfig, FamilySpec, IconModuleConfig, IconPackageConfig, LibraryInfo, SyntheticAttr)
import Json.Decode
import Naming


extractComponents : List String -> Cem.Manifest -> List Cem.Declaration
extractComponents exclude manifest =
    manifest.modules
        |> List.concatMap .declarations
        |> List.filter (\decl -> decl.customElement == Just True)
        |> List.filter (\decl -> not (List.member decl.name exclude))
        |> mergeComponentsByTagName
        |> List.map dropNamelessMembers
        |> normalizeAttrTypes



{-| Decode the optional `_config` field; default empty.

This decoder is deliberately narrow: it decodes ONLY the two pieces of
`_config` that `Generate.elm` actually reuses downstream — per-component
`attrTypes`/`syntheticAttrs` (fed into `applyTypeOverrides` /
`applySyntheticAttrs`) and the top-level `_exclude` list (custom-element
curation). Most other `_config` keys — `slots`, `idWiring`, `group`,
`examples`, `docMeta`, `requiredAttrs`, `actionMap`, `events`, `staticAttrs`,
`attrForm`, `_native`, `_actions`, `_nativeAttrTable` — are resolved directly
from the raw flags by `Generate.Phantom.Model`, which is the ONLY decoder
whose output the phantom pipeline reads for those keys. A few more —
`_htmlNamespace`, `_rawNamespace`, `_baseSlots`, `_seams`, `_runtime`,
`_categories` — are not read by ANY live decoder at all; nothing in the
codebase or any shipped config JSON references them.

This decoder used to re-decode that entire surface a second time, but nothing
downstream ever read the second copy (dead code — see
docs/reviews/2026-08-17-thermonuclear-workspace-review.md Theme 5 / finding 5).
Worse, its `_actions` sub-decoder required `doc` on every wrapper while
`Generate.Phantom.Model`'s live decoder defaults it — because the dead
decoder was fail-loud, a manifest omitting `doc` on any `_actions` wrapper
aborted the WHOLE build even though the decoder whose output is actually used
would have accepted it. Deleting the dead surface kills that divergence bug
as a side effect.

Any `_`-prefixed key in `_config` (whatever the CLI or a manifest author
puts there for `Generate.Phantom.Model` to read) is scrubbed out of the
decoded component dict generically, rather than by an enumerated list of
meta-key names — a real component's module name is never `_`-prefixed, so
this can't drop a legitimate component.
-}
decodeConfigResult : Json.Decode.Value -> Result String ConfigResult
decodeConfigResult flags =
    let
        excludeKey =
            "_exclude"

        opt name dec default =
            Json.Decode.oneOf [ Json.Decode.field name dec, Json.Decode.succeed default ]

        -- Like `opt`, but a PRESENT-but-invalid field fails LOUD rather than
        -- silently collapsing to the default. (`opt`'s `oneOf` catches every
        -- failure, including a genuine decode error, which would let a bad
        -- field vanish into its default.) Only an ABSENT field takes the default.
        optStrict name dec default =
            Json.Decode.maybe (Json.Decode.field name Json.Decode.value)
                |> Json.Decode.andThen
                    (\mv ->
                        case mv of
                            Nothing ->
                                Json.Decode.succeed default

                            Just _ ->
                                Json.Decode.field name dec
                    )

        -- A per-attribute type override (R12). Three JSON shapes, disjoint by type
        -- so `oneOf` is unambiguous:
        --   "int"/"float"/"bool"/"string"  → force a scalar setter
        --   ["a","b"]                       → force an enum (token == emitted value)
        --   {"tok":"value", …}              → force an enum (token → emitted value)
        -- A present-but-unknown scalar string fails LOUD (a typo must not silently
        -- degrade to String), and so does an EMPTY token list / map: an enum that
        -- admits nothing is a typo, not a request.
        emptyEnumFail =
            Json.Decode.fail
                ("attrTypes enum override must list at least one value;"
                    ++ " an empty list/map admits nothing and cannot be a real constraint."
                )

        enumOverride pairs =
            if List.isEmpty pairs then
                emptyEnumFail

            else
                Json.Decode.succeed (Cem.OverrideEnum pairs)

        attrOverrideDecoder =
            Json.Decode.oneOf
                [ Json.Decode.string
                    |> Json.Decode.andThen
                        (\s ->
                            if List.member s [ "int", "float", "bool", "string" ] then
                                Json.Decode.succeed (Cem.OverrideScalar s)

                            else
                                Json.Decode.fail
                                    ("attrTypes scalar override must be one of int|float|bool|string, got: \"" ++ s ++ "\"")
                        )
                , Json.Decode.list Json.Decode.string
                    |> Json.Decode.andThen (\xs -> enumOverride (List.map (\x -> ( x, x )) xs))
                , Json.Decode.keyValuePairs Json.Decode.string
                    |> Json.Decode.andThen enumOverride
                ]

        -- A SYNTHETIC (non-CEM) attribute (issue #38): a settable attr injected
        -- onto this component with a real phantom capability, keyed by its Elm-facing
        -- setter name. `htmlName` is the HTML attribute actually stamped; `type`
        -- reuses the `attrTypes` override vocabulary (scalar string or enum
        -- list/map). Absent `type` ⇒ a presence boolean (the `m3e-toc-ignore` case).
        syntheticAttrsDecoder : Json.Decode.Decoder (List SyntheticAttr)
        syntheticAttrsDecoder =
            Json.Decode.keyValuePairs
                (Json.Decode.map3
                    (\htmlName ty desc -> { htmlName = htmlName, type_ = ty, description = desc })
                    (Json.Decode.field "htmlName" Json.Decode.string)
                    (opt "type" attrOverrideDecoder (Cem.OverrideScalar "bool"))
                    (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
                )
                |> Json.Decode.map
                    (List.map
                        (\( elmName, s ) ->
                            { elmName = elmName, htmlName = s.htmlName, type_ = s.type_, description = s.description }
                        )
                    )

        componentDecoder : Json.Decode.Decoder { attrTypes : List ( String, Cem.AttrTypeOverride ), syntheticAttrs : List SyntheticAttr }
        componentDecoder =
            Json.Decode.map2
                (\attrTypes syntheticAttrs -> { attrTypes = attrTypes, syntheticAttrs = syntheticAttrs })
                (optStrict "attrTypes" (Json.Decode.keyValuePairs attrOverrideDecoder) [])
                (optStrict "syntheticAttrs" syntheticAttrsDecoder [])

        -- G1: `_iconModule`/`_families` decoders (Generate.Types.IconModuleConfig /
        -- FamiliesConfig). Mirror the field lists `bin/gen-icon-module.js:429-449`
        -- and `bin/gen-family-package.js:504-518` read today.
        depPairsDecoder : Json.Decode.Decoder (List ( String, String ))
        depPairsDecoder =
            Json.Decode.keyValuePairs Json.Decode.string

        iconPackageDecoder : Json.Decode.Decoder IconPackageConfig
        iconPackageDecoder =
            Json.Decode.map5
                (\dir nm summary version deps -> { dir = dir, name = nm, summary = summary, version = version, deps = deps })
                (Json.Decode.field "dir" Json.Decode.string)
                (Json.Decode.field "name" Json.Decode.string)
                (Json.Decode.field "summary" Json.Decode.string)
                (Json.Decode.field "version" Json.Decode.string)
                (opt "deps" depPairsDecoder [])

        iconModuleDecoder : Json.Decode.Decoder IconModuleConfig
        iconModuleDecoder =
            Json.Decode.map8
                (\lib iconComp catalogFrom shape maybeTag maybeIconFamily attribution pkg ->
                    { lib = lib
                    , iconComp = iconComp
                    , catalogFrom = catalogFrom
                    , shape = shape
                    , maybeTag = maybeTag
                    , maybeIconFamily = maybeIconFamily
                    , attribution = attribution
                    , package = pkg
                    }
                )
                (Json.Decode.field "lib" Json.Decode.string)
                (Json.Decode.field "iconComp" Json.Decode.string)
                (Json.Decode.field "catalogFrom" Json.Decode.string)
                (opt "shape" Json.Decode.string "names")
                (Json.Decode.maybe (Json.Decode.field "tag" Json.Decode.string))
                (Json.Decode.maybe (Json.Decode.field "iconFamily" Json.Decode.string))
                (Json.Decode.maybe (Json.Decode.field "attribution" Json.Decode.string))
                (Json.Decode.maybe (Json.Decode.field "package" iconPackageDecoder))
                |> Json.Decode.andThen
                    (\partial ->
                        -- finding 2.1 (2026-08-17 thermonuclear review): a brand
                        -- opting into `_iconModule` without supplying its own
                        -- tag/iconFamily used to silently get M3E's "m3e-icon"/
                        -- "Material Symbols" baked in. Fail loud instead, with a
                        -- message naming the exact config keys (matching
                        -- gen-icon-module.js's own error text) — a generic
                        -- "missing field" decode error wouldn't name
                        -- `_iconModule.tag` specifically.
                        case ( partial.maybeTag, partial.maybeIconFamily ) of
                            ( Just tag, Just iconFamily ) ->
                                Json.Decode.succeed
                                    { lib = partial.lib
                                    , iconComp = partial.iconComp
                                    , catalogFrom = partial.catalogFrom
                                    , shape = partial.shape
                                    , tag = tag
                                    , iconFamily = iconFamily
                                    , attribution = partial.attribution
                                    , package = partial.package
                                    , names = Nothing
                                    }

                            _ ->
                                Json.Decode.fail
                                    "_iconModule.tag and _iconModule.iconFamily are both required (without them the generator has no brand-neutral way to name the emitted element or the icon set in doc prose)."
                    )
                |> Json.Decode.andThen
                    (\im ->
                        Json.Decode.maybe (Json.Decode.field "names" (Json.Decode.list Json.Decode.string))
                            |> Json.Decode.map (\names -> { im | names = names })
                    )

        familyMemberDecoder =
            Json.Decode.map2 (\c p -> { component = c, path = p })
                (Json.Decode.field "component" Json.Decode.string)
                (Json.Decode.field "path" Json.Decode.string)

        familySpecDecoder : Json.Decode.Decoder FamilySpec
        familySpecDecoder =
            Json.Decode.map2 (\root members -> { root = root, members = members })
                (Json.Decode.maybe (Json.Decode.field "root" Json.Decode.string))
                (opt "members" (Json.Decode.list familyMemberDecoder) [])

        familiesDecoder : Json.Decode.Decoder FamiliesConfig
        familiesDecoder =
            Json.Decode.map5
                (\lib ns componentsFrom pkg fams -> { lib = lib, namespace = ns, componentsFrom = componentsFrom, package = pkg, families = fams })
                (Json.Decode.field "lib" Json.Decode.string)
                (Json.Decode.field "namespace" Json.Decode.string)
                (Json.Decode.maybe (Json.Decode.field "componentsFrom" Json.Decode.string))
                (Json.Decode.field "package" iconPackageDecoder)
                (Json.Decode.field "families" (Json.Decode.keyValuePairs familySpecDecoder))
    in
    -- Absent `_config` ⇒ empty config (the manifest-agnostic path). A PRESENT
    -- but malformed `_config` must fail LOUD rather than silently collapse to
    -- empty — that silent collapse is exactly how a bad decode would slip by.
    case
        Json.Decode.decodeValue
            (Json.Decode.maybe (Json.Decode.field "_config" Json.Decode.value))
            flags
    of
        Ok Nothing ->
            Ok { components = Dict.empty, exclude = [], iconModule = Nothing, families = Nothing }

        Ok (Just configValue) ->
            let
                compsResult =
                    Json.Decode.decodeValue (Json.Decode.dict componentDecoder) configValue
                        |> Result.mapError Json.Decode.errorToString
                        |> Result.map (Dict.filter (\k _ -> not (String.startsWith "_" k)))

                exclResult =
                    Json.Decode.decodeValue
                        -- Strict: a PRESENT-but-malformed `_exclude` fails LOUD
                        -- rather than silently collapsing to `[]`. That silent
                        -- collapse is exactly how the CLI's array→object merge bug
                        -- left `_exclude` inert (leaked base classes kept emitting).
                        (optStrict excludeKey (Json.Decode.list Json.Decode.string) [])
                        configValue
                        |> Result.mapError Json.Decode.errorToString

                -- Presence-aware, like `optStrict`: an ABSENT `_iconModule`/
                -- `_families` key decodes to `Nothing` (both are opt-in), but a
                -- PRESENT-but-malformed one (e.g. missing the required `tag`/
                -- `iconFamily` fields) must fail LOUD, not silently collapse to
                -- `Nothing` — that silent collapse is exactly the finding 2.1
                -- bug class (a brand without its own tag/iconFamily quietly
                -- getting no icon module at all instead of a loud error).
                -- `Json.Decode.maybe` on the WHOLE field+decoder pair (the
                -- naive form) cannot distinguish "absent" from "present but
                -- fails to decode" — both collapse to `Nothing` — so presence
                -- is checked separately first.
                presenceAwareMaybe fieldName dec =
                    Json.Decode.maybe (Json.Decode.field fieldName Json.Decode.value)
                        |> Json.Decode.andThen
                            (\present ->
                                case present of
                                    Nothing ->
                                        Json.Decode.succeed Nothing

                                    Just _ ->
                                        Json.Decode.field fieldName dec |> Json.Decode.map Just
                            )

                iconModuleResult =
                    Json.Decode.decodeValue (presenceAwareMaybe "_iconModule" iconModuleDecoder) configValue
                        |> Result.mapError Json.Decode.errorToString

                familiesResult =
                    Json.Decode.decodeValue (presenceAwareMaybe "_families" familiesDecoder) configValue
                        |> Result.mapError Json.Decode.errorToString
            in
            Result.map4
                (\comps excl im fams -> { components = comps, exclude = excl, iconModule = im, families = fams })
                compsResult
                exclResult
                iconModuleResult
                familiesResult

        Err e ->
            Err (Json.Decode.errorToString e)


{-| Extract library information from a manifest. Takes the manifest's
already-extracted declaration list (via `extractComponents`) rather than
re-running that pipeline itself — `Generate.elm` used to call
`extractComponents` twice per generation (once here with `exclude = []`
purely to sniff the tag prefix, once for real with the config's `_exclude`
list); this reuses the one real extraction instead (finding 11, Theme 5 of
the 2026-08-17 thermonuclear review). Sniffing the prefix from the
exclude-FILTERED list rather than the unfiltered one is a no-op for every
real library (every component shares one tag prefix, so which declaration
happens to be first almost never matters) and is the more honest answer
when it does.
-}
extractLibraryInfo : Cem.Manifest -> List Cem.Declaration -> LibraryInfo
extractLibraryInfo manifest declarations =
    let
        -- Try to get package name from manifest
        packageName =
            case manifest.package of
                Just pkg ->
                    pkg.name

                Nothing ->
                    ""

        -- Detect component prefix from tagNames first
        componentPrefix =
            declarations
                |> List.filterMap .tagName
                |> List.head
                |> Maybe.map
                    (\tagName ->
                        -- Extract prefix up to first dash
                        case String.split "-" tagName |> List.head of
                            Just prefix ->
                                prefix ++ "-"

                            Nothing ->
                                ""
                    )
                |> Maybe.withDefault ""

        -- Use component prefix as module name (removing the dash and capitalizing)
        moduleName =
            if componentPrefix == "" then
                "Components"

            else
                componentPrefix
                    |> String.dropRight 1
                    -- Remove trailing dash
                    |> Naming.capitalize

        -- Event prefix is usually the same as component prefix
        eventPrefix =
            componentPrefix
    in
    { moduleName = moduleName
    , libraryName = packageName
    , componentPrefix = componentPrefix
    , eventPrefix = eventPrefix
    }
