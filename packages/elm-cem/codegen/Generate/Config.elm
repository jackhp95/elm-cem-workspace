module Generate.Config exposing (decodeConfigResult, extractComponents, extractLibraryInfo)

import Cem
import Dict
import Generate.Normalize exposing (dropNamelessMembers, mergeComponentsByTagName, normalizeAttrTypes)
import Generate.Types exposing (ActionConfig, ActionWrapper, Config, ConfigResult, EventDecoder(..), EventScalar(..), LibraryInfo, SlotKinds(..))
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



{-| Decode the optional `_config` field; default empty. Per component, all optional:
`slots` (accepted child kinds/multi/required), `required` (field → kind), `group`
(variant grouping), `examples` (generic usage examples → doc-comment blocks), and
`docMeta` (opaque key/value doc metadata). `examples`/`docMeta` default to `[]`, so
the feature is opt-in and manifest-agnostic.
-}
decodeConfigResult : Json.Decode.Value -> Result String ConfigResult
decodeConfigResult flags =
    let
        baseSlotsKey =
            "_baseSlots"

        seamsKey =
            "_seams"

        nativeKey =
            "_native"

        htmlNamespaceKey =
            "_htmlNamespace"

        rawNamespaceKey =
            "_rawNamespace"

        excludeKey =
            "_exclude"

        runtimeKey =
            "_runtime"

        actionsKey =
            "_actions"

        nativeAttrTableKey =
            "_nativeAttrTable"

        categoriesKey =
            "_categories"

        opt name dec default =
            Json.Decode.oneOf [ Json.Decode.field name dec, Json.Decode.succeed default ]

        -- Like `opt`, but a PRESENT-but-invalid field fails LOUD rather than
        -- silently collapsing to the default. (`opt`'s `oneOf` catches every
        -- failure, including a genuine decode error, which would let a bad
        -- `slots` block vanish into `[]`.) Only an ABSENT field takes the default.
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

        -- Strict 4-state `kinds` (§2.9-B):
        --   • the string "arbitrary"                 ⇒ spec-open content (`Arbitrary`)
        --   • a NON-EMPTY list of kind strings       ⇒ typed closed kinds (`Kinds`)
        --   • { "category": "<Name>", "extras": … }  ⇒ a content-category slot
        --     (`Category`) — the child row is `<Lib>.Category.<Name>` extended with
        --     the optional dual-mode `extras` (default `[]`). `<Name>` must be one of
        --     the modeled categories (Phrasing/Flow/Heading/Metadata); an unknown one
        --     fails LOUD so a typo can't reference a non-existent alias.
        -- Anything else (missing field, empty list, any other string/object) is a
        -- BUILD ERROR. "kind undetermined" is not representable, so it can never
        -- masquerade as a spec claim.
        knownCategories =
            [ "Phrasing", "Flow", "Heading", "Metadata" ]

        categoryKindsDecoder =
            Json.Decode.map3 (\name extras nested -> { name = name, extras = extras, nested = nested })
                (Json.Decode.field "category" Json.Decode.string)
                (opt "extras" (Json.Decode.list Json.Decode.string) [])
                (Json.Decode.maybe (Json.Decode.field "unionCategory" Json.Decode.string))
                |> Json.Decode.andThen
                    (\c ->
                        let
                            unknown =
                                List.filter (\n -> not (List.member n knownCategories))
                                    (c.name :: (c.nested |> Maybe.map List.singleton |> Maybe.withDefault []))
                        in
                        case unknown of
                            [] ->
                                Json.Decode.succeed (Category c)

                            bad :: _ ->
                                Json.Decode.fail
                                    ("slot `kinds.category`/`unionCategory` must be one of "
                                        ++ String.join "/" knownCategories
                                        ++ ", got: \""
                                        ++ bad
                                        ++ "\""
                                    )
                    )

        kindsDecoder =
            Json.Decode.oneOf
                [ Json.Decode.string
                    |> Json.Decode.andThen
                        (\s ->
                            if s == "arbitrary" then
                                Json.Decode.succeed Arbitrary

                            else
                                Json.Decode.fail
                                    ("slot `kinds` string must be \"arbitrary\", got: \"" ++ s ++ "\"")
                        )
                , Json.Decode.list Json.Decode.string
                    |> Json.Decode.andThen
                        (\ks ->
                            case ks of
                                [] ->
                                    Json.Decode.fail
                                        "slot `kinds` list is empty — use a non-empty list of kinds or the string \"arbitrary\""

                                _ ->
                                    Json.Decode.succeed (Kinds ks)
                        )
                , categoryKindsDecoder
                ]

        slotsDecoder =
            Json.Decode.keyValuePairs
                (Json.Decode.map3 (\k m r -> { kinds = k, multi = m, required = r })
                    (Json.Decode.field "kinds" kindsDecoder)
                    (opt "multi" Json.Decode.bool False)
                    (opt "required" Json.Decode.bool False)
                )
                |> Json.Decode.map
                    (List.map
                        (\( name, s ) ->
                            { name = name, kinds = s.kinds, multi = s.multi, required = s.required }
                        )
                    )

        exampleDecoder =
            Json.Decode.map4 (\t c s cr -> { title = t, code = c, section = s, codeRecord = cr })
                (opt "title" Json.Decode.string "")
                (opt "code" Json.Decode.string "")
                (Json.Decode.maybe (Json.Decode.field "section" Json.Decode.string))
                (Json.Decode.maybe (Json.Decode.field "codeRecord" Json.Decode.string))

        stringPairDecoder =
            Json.Decode.map2 Tuple.pair
                (Json.Decode.index 0 Json.Decode.string)
                (Json.Decode.index 1 Json.Decode.string)

        -- A per-attribute type override (R12). Three JSON shapes, disjoint by type
        -- so `oneOf` is unambiguous:
        --   "int"/"float"/"bool"/"string"  → force a scalar setter
        --   ["a","b"]                       → force an enum (token == emitted value)
        --   {"tok":"value", …}              → force an enum (token → emitted value)
        -- A present-but-unknown scalar string fails LOUD (a typo must not silently
        -- degrade to String), and so does an EMPTY token list / map: an enum that
        -- admits nothing is a typo, not a request. It used to be harmless only by
        -- accident — `AEnumMap []` matched nothing in the phantom emitters and fell
        -- through to a plain `String` setter, i.e. it was swallowed by the very bug
        -- that made every enum override a no-op. Now that an all-identity override
        -- IS an `AEnum`, an empty one would mint `type alias X = {}` and a
        -- `Value {}` setter no token can satisfy: dead code, emitted in silence.
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

        -- The for/id auto-wiring descriptor. PRESENT-but-invalid
        -- fails LOUD (a typo in `control`/`label` must not silently drop the
        -- wiring); ABSENT ⇒ Nothing (no wiring — the manifest-agnostic default).
        idWiringDecoder =
            optStrict "idWiring"
                (Json.Decode.map2 (\c l -> Just { control = c, label = l })
                    (Json.Decode.field "control" Json.Decode.string)
                    (Json.Decode.field "label" Json.Decode.string)
                )
                Nothing

        -- The R9 event-payload descriptor: per DOM event name, the typed payload
        -- to bake into that event's setter. The JSON path is given by exactly one
        -- of `path` (explicit list), `detail` (shorthand for `["detail", X]`), or
        -- `target` (shorthand for `["target", X]`); `type` picks the leaf decoder.
        -- `type: "none"` (or no path at all) is the no-payload case. An unknown
        -- `type` fails LOUD so a typo can't silently degrade to `succeed`.
        eventScalarOf s =
            case s of
                "int" ->
                    Just EInt

                "float" ->
                    Just EFloat

                "bool" ->
                    Just EBool

                "string" ->
                    Just EString

                _ ->
                    Nothing

        eventPathDecoder =
            Json.Decode.oneOf
                [ Json.Decode.field "path" (Json.Decode.list Json.Decode.string)
                , Json.Decode.field "detail" Json.Decode.string
                    |> Json.Decode.map (\f -> [ "detail", f ])
                , Json.Decode.field "target" Json.Decode.string
                    |> Json.Decode.map (\f -> [ "target", f ])
                , Json.Decode.succeed []
                ]

        eventDecoderDescriptor =
            Json.Decode.map2 Tuple.pair
                eventPathDecoder
                (opt "type" Json.Decode.string "none")
                |> Json.Decode.andThen
                    (\( path, ty ) ->
                        case ty of
                            "none" ->
                                Json.Decode.succeed EventNone

                            "date" ->
                                if List.isEmpty path then
                                    Json.Decode.fail "event `type: \"date\"` needs a `path`/`detail`/`target` source"

                                else
                                    Json.Decode.succeed (EventDate path)

                            _ ->
                                case eventScalarOf ty of
                                    Just scalar ->
                                        if List.isEmpty path then
                                            Json.Decode.fail ("event `type: \"" ++ ty ++ "\"` needs a `path`/`detail`/`target` source")

                                        else
                                            Json.Decode.succeed (EventAt path scalar)

                                    Nothing ->
                                        Json.Decode.fail ("event `type` must be one of int|float|bool|string|date|none, got: \"" ++ ty ++ "\"")
                    )

        -- A SYNTHETIC (non-CEM) attribute (issue #38): a settable attr injected
        -- onto this component with a real phantom capability, keyed by its Elm-facing
        -- setter name. `htmlName` is the HTML attribute actually stamped; `type`
        -- reuses the `attrTypes` override vocabulary (scalar string or enum
        -- list/map). Absent `type` ⇒ a presence boolean (the `m3e-toc-ignore` case).
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

        componentDecoder =
            Json.Decode.map8
                (\slots extra grp examples docMeta requiredAttrs actionMap rest ->
                    { slots = slots
                    , extra = extra
                    , group = grp
                    , examples = examples
                    , docMeta = docMeta
                    , requiredAttrs = requiredAttrs
                    , actionMap = actionMap
                    , attrTypes = rest.attrTypes
                    , idWiring = rest.idWiring
                    , events = rest.events
                    , staticAttrs = rest.staticAttrs
                    , attrForm = rest.attrForm
                    , syntheticAttrs = rest.syntheticAttrs
                    }
                )
                (optStrict "slots" slotsDecoder [])
                (opt "required" (Json.Decode.keyValuePairs Json.Decode.string) [])
                (opt "group" (Json.Decode.keyValuePairs Json.Decode.string) [])
                (opt "examples" (Json.Decode.list exampleDecoder) [])
                (opt "docMeta" (Json.Decode.keyValuePairs Json.Decode.string) [])
                (opt "requiredAttrs" (Json.Decode.list Json.Decode.string) [])
                (opt "actionMap" (Json.Decode.list stringPairDecoder) [])
                (Json.Decode.map6
                    (\attrTypes idWiring events staticAttrs attrForm syntheticAttrs ->
                        { attrTypes = attrTypes
                        , idWiring = idWiring
                        , events = events
                        , staticAttrs = staticAttrs
                        , attrForm = attrForm
                        , syntheticAttrs = syntheticAttrs
                        }
                    )
                    (optStrict "attrTypes" (Json.Decode.keyValuePairs attrOverrideDecoder) [])
                    idWiringDecoder
                    (optStrict "events" (Json.Decode.keyValuePairs eventDecoderDescriptor) [])
                    (optStrict "staticAttrs" (Json.Decode.keyValuePairs Json.Decode.string) [])
                    (opt "attrForm" (Json.Decode.keyValuePairs Json.Decode.string) [])
                    (optStrict "syntheticAttrs" syntheticAttrsDecoder [])
                )

        -- A native emit tag: a non-empty HTML tag name. An empty
        -- entry fails LOUD rather than emitting a nameless constructor.
        nativeTagDecoder =
            Json.Decode.string
                |> Json.Decode.andThen
                    (\s ->
                        if String.trim s == "" then
                            Json.Decode.fail "native `emit` tag must be a non-empty string"

                        else
                            Json.Decode.succeed s
                    )

        -- The config-sourced doc-comment prose (element-tag → summary,
        -- attribute-name → summary). Absent ⇒ empty maps ⇒ the generic fallback
        -- applies to every member. `summaries.elements` / `summaries.attributes`
        -- are plain `{ key: string }` objects (the consumer library populates them
        -- verbatim from MDN or another doc source via a manual refresh script).
        summariesDecoder =
            Json.Decode.map2 Tuple.pair
                (opt "elements" (Json.Decode.keyValuePairs Json.Decode.string) [])
                (opt "attributes" (Json.Decode.keyValuePairs Json.Decode.string) [])

        nativeDecoder =
            Json.Decode.map3
                (\emit semantics ( elementSummaries, attrSummaries ) ->
                    { emit = emit
                    , semantics = List.sortBy Tuple.first semantics
                    , elementSummaries = elementSummaries
                    , attrSummaries = attrSummaries
                    }
                )
                (optStrict "emit" (Json.Decode.list nativeTagDecoder) [])
                (opt "semantics" (Json.Decode.keyValuePairs Json.Decode.string) [])
                (opt "summaries" summariesDecoder ( [], [] ))

        -- The `_actions` block: the library-specific Action roster.
        -- Each wrapper names a concrete trigger component (`comp`) that MUST
        -- exist in the manifest for its behaviour to be emitted.
        -- `bottomSheetComp`/`dialogActionComp` name the special-case trigger
        -- components (each has a non-standard ctor shape). Absent ⇒ `Nothing`
        -- (no Action module emitted for this library).
        actionWrapperDecoder : Json.Decode.Decoder ActionWrapper
        actionWrapperDecoder =
            Json.Decode.map5 ActionWrapper
                (Json.Decode.field "ctor" Json.Decode.string)
                (Json.Decode.field "cap" Json.Decode.string)
                (Json.Decode.field "variant" Json.Decode.string)
                (Json.Decode.field "comp" Json.Decode.string)
                (Json.Decode.field "doc" Json.Decode.string)

        actionsDecoder : Json.Decode.Decoder ActionConfig
        actionsDecoder =
            Json.Decode.map4
                (\forWs nullaryWs bsc dac ->
                    Just
                        { forWrappers = forWs
                        , nullaryWrappers = nullaryWs
                        , bottomSheetComp = bsc
                        , dialogActionComp = dac
                        }
                )
                (opt "forWrappers" (Json.Decode.list actionWrapperDecoder) [])
                (opt "nullaryWrappers" (Json.Decode.list actionWrapperDecoder) [])
                (Json.Decode.maybe (Json.Decode.field "bottomSheetComp" Json.Decode.string))
                (Json.Decode.maybe (Json.Decode.field "dialogActionComp" Json.Decode.string))

        -- The HTML-natural attr→element constraint table, injected from
        -- `data/native-attrs.json` by `bin/elm-cem.js`. Each entry names
        -- an Elm setter (e.g. `"href"`), its value type (`"String"`/`"Bool"`/
        -- `"Int"`), and the HTML tags it is valid on.
        -- Absent ⇒ [] (no attr setters — the CLI always supplies the bundled
        -- default unless overridden, so this is only missing in test harnesses
        -- that build ConfigResult without the CLI injection).
        nativeAttrEntryDecoder : Json.Decode.Decoder { elmName : String, valueType : String, tags : List String }
        nativeAttrEntryDecoder =
            Json.Decode.map3
                (\e v t -> { elmName = e, valueType = v, tags = t })
                (Json.Decode.field "elmName" Json.Decode.string)
                (Json.Decode.field "valueType" Json.Decode.string)
                (Json.Decode.field "tags" (Json.Decode.list Json.Decode.string))

        nativeAttrTableDecoder : Json.Decode.Decoder (List { elmName : String, valueType : String, tags : List String })
        nativeAttrTableDecoder =
            Json.Decode.list nativeAttrEntryDecoder

    in
    -- Absent `_config` ⇒ empty config (the manifest-agnostic path). A PRESENT
    -- but malformed `_config` must fail LOUD rather than silently collapse to
    -- empty — that silent collapse is exactly how a bad kinds spec would slip by.
    case
        Json.Decode.decodeValue
            (Json.Decode.maybe (Json.Decode.field "_config" Json.Decode.value))
            flags
    of
        Ok Nothing ->
            Ok { components = Dict.empty, native = { emit = [], semantics = [], elementSummaries = [], attrSummaries = [] }, htmlNamespace = "Html", rawNamespace = "Raw", exclude = [], actions = Nothing, nativeAttrTable = [] }

        Ok (Just configValue) ->
            let
                compsResult =
                    Json.Decode.decodeValue (Json.Decode.dict componentDecoder) configValue
                        |> Result.mapError Json.Decode.errorToString

                nativeResult =
                    Json.Decode.decodeValue
                        (optStrict nativeKey nativeDecoder { emit = [], semantics = [], elementSummaries = [], attrSummaries = [] })
                        configValue
                        |> Result.mapError Json.Decode.errorToString

                nsResult =
                    Json.Decode.decodeValue
                        (Json.Decode.map3 (\h r e -> ( h, r, e ))
                            (opt htmlNamespaceKey Json.Decode.string "Html")
                            (opt rawNamespaceKey Json.Decode.string "Raw")
                            -- Strict: a PRESENT-but-malformed `_exclude` fails LOUD
                            -- rather than silently collapsing to `[]`. That silent
                            -- collapse is exactly how the CLI's array→object merge bug
                            -- left `_exclude` inert (leaked base classes kept emitting).
                            (optStrict excludeKey (Json.Decode.list Json.Decode.string) [])
                        )
                        configValue
                        |> Result.mapError Json.Decode.errorToString

                -- `_actions` block: absent ⇒ Nothing (no Action module).
                -- Present-but-malformed fails LOUD.
                actionsResult =
                    Json.Decode.decodeValue
                        (optStrict actionsKey actionsDecoder Nothing)
                        configValue
                        |> Result.mapError Json.Decode.errorToString

                -- `_nativeAttrTable`: the HTML-natural attr→element table,
                -- injected from the bundled data file by bin/elm-cem.js.
                -- Absent ⇒ [] (safe default; CLI always injects the table).
                nativeAttrTableResult =
                    Json.Decode.decodeValue
                        (optStrict nativeAttrTableKey nativeAttrTableDecoder [])
                        configValue
                        |> Result.mapError Json.Decode.errorToString
            in
            Result.map3
                (\comps native ( htmlNs, rawNs, excl ) ->
                    { comps = comps, native = native, htmlNs = htmlNs, rawNs = rawNs, excl = excl }
                )
                compsResult
                nativeResult
                nsResult
                |> Result.andThen
                    (\r ->
                        Result.map2
                            (\actions nativeAttrTable ->
                                -- Scrub the `_`-prefixed meta-keys out of the raw
                                -- component dict so they are never treated as
                                -- component entries. The keys are load-bearing here
                                -- even though several of their decoded values are no
                                -- longer projected into `ConfigResult` (phantom path
                                -- reads only `components` + `exclude`).
                                { components =
                                    Dict.remove categoriesKey
                                        (Dict.remove nativeAttrTableKey
                                            (Dict.remove actionsKey
                                                (Dict.remove runtimeKey
                                                    (Dict.remove excludeKey
                                                        (Dict.remove rawNamespaceKey
                                                            (Dict.remove htmlNamespaceKey
                                                                (Dict.remove nativeKey (Dict.remove seamsKey (Dict.remove baseSlotsKey r.comps)))
                                                            )
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                , native = r.native
                                , htmlNamespace = r.htmlNs
                                , rawNamespace = r.rawNs
                                , exclude = r.excl
                                , actions = actions
                                , nativeAttrTable = nativeAttrTable
                                }
                            )
                            actionsResult
                            nativeAttrTableResult
                    )

        Err e ->
            Err (Json.Decode.errorToString e)


{-| Extract library information from a manifest
-}
extractLibraryInfo : Cem.Manifest -> LibraryInfo
extractLibraryInfo manifest =
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
            extractComponents [] manifest
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

    -- Namespace defaults; `generateFromManifest` overrides these from the
    -- decoded top-level `_htmlNamespace` / `_rawNamespace` config keys.
    , htmlNamespace = "Html"
    , rawNamespace = "Raw"

    -- Default: owns runtime (same as moduleName). Overridden in
    -- `generateFromManifest` when ownsRuntime = False → "Markup".
    , runtimeBase = moduleName

    -- Populated in `generateFromManifest` from the FINAL component set (needs all
    -- components to know which attrs are universal); manifest-only start is empty.
    , universalGlobalNames = []
    }
