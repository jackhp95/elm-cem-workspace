module Generate.Phantom.Emit.FamilyPackage exposing (files)

{-| Port of bin/gen-family-package.js (G3, 2026-08-19 generator-consolidation
research). Emits `<lib>.<namespace>.<Family>` flat family modules that
re-export each member element's flat `<lib>.Component.*` surface,
additively.

DESIGN DEVIATION from the plan's own Task 7 design note, documented here
because it matters: the plan's note called for extending
`Generate.Phantom.Emit.Component` with a shared `compSurface` function so
this module never independently re-derives (and risks drifting from) the
per-component exposing/type/annotation surface `compModule` already builds.
That would require restructuring ~15 different construction paths inside
`compModule` (the `component` ctor's two arities, enum setters, attr
re-exports, event re-exports, slot setters, the default-child setter) into a
second, parallel "surface" builder — a large refactor with its own
correctness risk.

Instead, this module calls `Generate.Phantom.Emit.Component.compModule`
itself (the SAME function, same `Brand`/`Comp` inputs, called a second time
for the same component within the same generation run — deterministic, byte
-for-byte identical both times) and parses the resulting `Elm.File.contents`
STRING IN MEMORY with an Elm port of `gen-family-package.js`'s own
`parseModuleSurface` regex parser. This still satisfies every HARD
constraint from the research doc (no filesystem read — the string never
touches disk; Elm/elm-codegen only; no new JS logic) and cannot drift from
the actual emitted surface, because it IS the actual emitted surface: there is
no way for the parsed surface to disagree with what `compModule` wrote, since
they are the same string. It trades the plan's preferred "structured avoids
regex" elegance for a much smaller, lower-risk diff — the byte-equality
golden test is this port's real acceptance bar, and this path reaches it
without touching `Component.elm` at all.

Also DELIBERATELY DROPPED, matching the icon module's port
(`Generate.Phantom.Emit.IconModule`) and Task 7's own design note that
"only if absent" semantics don't survive the move to a single-pass, no-
filesystem-access generator: `README.md`/`LICENSE` generation
(`gen-family-package.js:450-500`). `elm.json` — the one package-tree file
this module's golden test governs — is still emitted.

Also DROPPED: `_families.componentsFrom` (an override letting the JS
generator read a member's flat surface from some OTHER pre-built src/ tree
instead of the one just generated). Since this port reads the surface from
the SAME generation run's in-memory `Brand`/`Comp` model rather than any
filesystem path, there is no equivalent "read from elsewhere" to support.
`brands/m3e`'s real `_families` config does not set `componentsFrom`, so
this is a no-op for the shipped brand; documented as a narrowing for anyone
who might have relied on it.

@docs files

-}

import Dict exposing (Dict)
import Elm
import Generate.Phantom.Emit.Component as Component
import Generate.Phantom.Model exposing (Brand, Comp)
import Generate.Types exposing (FamiliesConfig, FamilyPackageConfig, FamilySpec)
import Regex
import Set exposing (Set)



-- ── small naming helpers (gen-family-package.js:84-89) ────────────────────


lowerFirst : String -> String
lowerFirst s =
    case String.uncons s of
        Nothing ->
            s

        Just ( c, tail ) ->
            String.cons (Char.toLower c) tail


upperFirst : String -> String
upperFirst s =
    case String.uncons s of
        Nothing ->
            s

        Just ( c, tail ) ->
            String.cons (Char.toUpper c) tail


isUpperFirst : String -> Bool
isUpperFirst s =
    case String.uncons s of
        Nothing ->
            False

        Just ( c, _ ) ->
            Char.isUpper c


isLowerFirst : String -> Bool
isLowerFirst s =
    case String.uncons s of
        Nothing ->
            False

        Just ( c, _ ) ->
            Char.isLower c



-- ── parse the public surface of an in-memory-rendered component module ────
-- Port of gen-family-package.js:101-153's `parseModuleSurface`. `filePath` in
-- the JS version was only used for error messages; here the caller's
-- `origModuleName` plays that role.


type alias Surface =
    { moduleName : String
    , exposing_ : List String
    , types : Dict String String
    , valueAnnotations : Dict String String
    }


moduleHeaderRegex : Regex.Regex
moduleHeaderRegex =
    Regex.fromStringWith { caseInsensitive = False, multiline = True }
        "^module\\s+([\\w.]+)\\s+exposing\\s*\\(([\\s\\S]*?)\\)"
        |> Maybe.withDefault Regex.never


typeAliasRegex : Regex.Regex
typeAliasRegex =
    Regex.fromStringWith { caseInsensitive = False, multiline = True }
        "^type alias\\s+([A-Z]\\w*)((?:\\s+\\w+)*)\\s*="
        |> Maybe.withDefault Regex.never


opaqueTypeRegex : Regex.Regex
opaqueTypeRegex =
    -- Port of gen-family-package.js:123-133. The JS defensively excludes
    -- matches that are actually `type alias ...` via a `startsWith` check,
    -- but `^type\s+([A-Z]\w*)` can never match a `type alias` line in the
    -- first place — the character right after "type " in "type alias X" is
    -- the lowercase `a` of "alias", which `[A-Z]` rejects — so that guard is
    -- unreachable and is not ported.
    Regex.fromStringWith { caseInsensitive = False, multiline = True }
        "^type\\s+([A-Z]\\w*)"
        |> Maybe.withDefault Regex.never


multilineAnnotationRegex : Regex.Regex
multilineAnnotationRegex =
    Regex.fromStringWith { caseInsensitive = False, multiline = True }
        "^([a-z]\\w*)\\s*:\\n([\\s\\S]*?)\\n\\1(?:\\s|=)"
        |> Maybe.withDefault Regex.never


singleLineAnnotationRegex : Regex.Regex
singleLineAnnotationRegex =
    Regex.fromStringWith { caseInsensitive = False, multiline = True }
        "^([a-z]\\w*)\\s*:\\s+([^\\n]+)\\n\\1(?:\\s|=)"
        |> Maybe.withDefault Regex.never


trailingWhitespaceRegex : Regex.Regex
trailingWhitespaceRegex =
    Regex.fromString "\\s+$" |> Maybe.withDefault Regex.never


rstrip : String -> String
rstrip s =
    Regex.replace trailingWhitespaceRegex (\_ -> "") s


submatchAt : Int -> Regex.Match -> Maybe String
submatchAt i m =
    m.submatches |> List.drop i |> List.head |> Maybe.andThen identity


stripVariantSuffix : String -> String
stripVariantSuffix s =
    if String.endsWith "(..)" s then
        String.dropRight 4 s |> String.trimRight

    else
        s


parseModuleSurface : String -> String -> Result String Surface
parseModuleSurface src origModuleName =
    case List.head (Regex.find moduleHeaderRegex src) of
        Nothing ->
            Err ("gen-family-package: cannot parse module header in " ++ origModuleName)

        Just m ->
            let
                moduleName =
                    Maybe.withDefault "" (submatchAt 0 m)

                exposingRaw =
                    Maybe.withDefault "" (submatchAt 1 m)

                exposingNames =
                    exposingRaw
                        |> String.split ","
                        |> List.map (String.trim >> stripVariantSuffix >> String.trim)
                        |> List.filter (\s -> not (String.isEmpty s))

                types =
                    Regex.find typeAliasRegex src
                        |> List.foldl
                            (\mm acc ->
                                case submatchAt 0 mm of
                                    Just name ->
                                        Dict.insert name (String.trim (Maybe.withDefault "" (submatchAt 1 mm))) acc

                                    Nothing ->
                                        acc
                            )
                            Dict.empty

                opaqueOffenders =
                    Regex.find opaqueTypeRegex src
            in
            if not (List.isEmpty opaqueOffenders) then
                Err
                    (moduleName
                        ++ " exposes/declares an opaque `type` — transparent re-aliasing is not possible. The family package assumes every exposed type is a `type alias`; fix the codegen or exclude this component."
                    )

            else
                let
                    multiAnns =
                        Regex.find multilineAnnotationRegex src
                            |> List.foldl
                                (\mm acc ->
                                    case ( submatchAt 0 mm, submatchAt 1 mm ) of
                                        ( Just name, Just body ) ->
                                            Dict.insert name (rstrip body) acc

                                        _ ->
                                            acc
                                )
                                Dict.empty

                    valueAnnotations =
                        Regex.find singleLineAnnotationRegex src
                            |> List.foldl
                                (\mm acc ->
                                    case ( submatchAt 0 mm, submatchAt 1 mm ) of
                                        ( Just name, Just body ) ->
                                            if Dict.member name acc then
                                                acc

                                            else
                                                Dict.insert name ("    " ++ String.trim body) acc

                                        _ ->
                                            acc
                                )
                                multiAnns
                in
                Ok { moduleName = moduleName, exposing_ = exposingNames, types = types, valueAnnotations = valueAnnotations }



-- ── rewrite a member's annotation to reference prefixed local type names ──
-- Port of gen-family-package.js:164-176.


prefixTypeRefs : String -> Set String -> String -> String
prefixTypeRefs annotationText exposedTypeNames elementPascal =
    let
        namesLongestFirst =
            exposedTypeNames
                |> Set.toList
                |> List.sortBy (\s -> -(String.length s))
    in
    List.foldl
        (\t acc ->
            case Regex.fromString ("(^|[^.\\w])" ++ t ++ "\\b") of
                Nothing ->
                    acc

                Just re ->
                    Regex.replace re
                        (\match ->
                            let
                                pre =
                                    submatchAt 0 match |> Maybe.withDefault ""
                            in
                            pre ++ elementPascal ++ t
                        )
                        acc
        )
        annotationText
        namesLongestFirst



-- ── emit one FLAT family module ────────────────────────────────────────────
-- Port of gen-family-package.js:178-317's `generateFamilyModule`.


type alias Member =
    { component : String
    , elementPascal : String
    , elementCamel : String
    , alias_ : String
    , origModuleName : String
    , surface : Surface
    }


type EmittedKind
    = KType
    | KCtor
    | KValue


type alias Emitted =
    { kind : EmittedKind
    , emittedName : String
    , member : Member
    , srcName : String
    }


externalImports : List ( String, List String )
externalImports =
    -- Verbatim port of gen-family-package.js:242-251, INCLUDING its literal
    -- "M3e.Kind" — the JS source hardcodes the M3e brand name here rather
    -- than parameterizing on `lib` (this is the JS generator's own
    -- pre-existing behavior, not something this port introduces; preserved
    -- byte-for-byte per the plan's "port line-for-line, do not improve" rule).
    [ ( "import HtmlIr.Attribute exposing (Attr)", [ "Attr" ] )
    , ( "import HtmlIr.Element exposing (Element)", [ "Element" ] )
    , ( "import HtmlIr.Value exposing (Value)", [ "Value" ] )
    , ( "import HtmlIr.Kind exposing (Shared, Supported)", [ "Shared", "Supported" ] )
    , ( "import M3e.Kind exposing (Available, Brand, Ctx, Used)", [ "Available", "Brand", "Ctx", "Used" ] )
    , ( "import M3e.Action as Ac", [ "Ac.Action" ] )
    , ( "import Json.Encode", [ "Json.Encode" ] )
    , ( "import Json.Decode", [ "Json.Decode" ] )
    ]


tokenMatches : String -> String -> Bool
tokenMatches token annBlob =
    let
        pattern =
            if String.contains "." token then
                String.replace "." "\\." token ++ "\\b"

            else
                "\\b" ++ token ++ "\\b"
    in
    case Regex.fromString pattern of
        Nothing ->
            False

        Just re ->
            Regex.contains re annBlob


buildDecl : Emitted -> Result String String
buildDecl item =
    let
        member =
            item.member

        exposedTypeNames =
            member.surface.exposing_ |> List.filter isUpperFirst |> Set.fromList
    in
    case item.kind of
        KType ->
            case Dict.get item.srcName member.surface.types of
                Nothing ->
                    Err
                        (member.origModuleName
                            ++ " exposes type `"
                            ++ item.srcName
                            ++ "` but no `type alias "
                            ++ item.srcName
                            ++ "` declaration was found to read its parameters."
                        )

                Just params ->
                    let
                        lhs =
                            if String.isEmpty params then
                                item.emittedName

                            else
                                item.emittedName ++ " " ++ params

                        rhs =
                            if String.isEmpty params then
                                member.alias_ ++ "." ++ item.srcName

                            else
                                member.alias_ ++ "." ++ item.srcName ++ " " ++ params
                    in
                    Ok
                        ([ "{-| See [`" ++ member.origModuleName ++ "." ++ item.srcName ++ "`](" ++ member.origModuleName ++ "#" ++ item.srcName ++ "). -}"
                         , "type alias " ++ lhs ++ " ="
                         , "    " ++ rhs
                         ]
                            |> String.join "\n"
                        )

        _ ->
            case Dict.get item.srcName member.surface.valueAnnotations of
                Nothing ->
                    Err
                        (member.origModuleName
                            ++ " exposes value `"
                            ++ item.srcName
                            ++ "` but no type annotation was found for it. `elm make --docs` requires an annotation on every exposed value."
                        )

                Just rawAnn ->
                    let
                        ann =
                            prefixTypeRefs rawAnn exposedTypeNames member.elementPascal

                        doc =
                            if item.kind == KCtor then
                                "{-| The `" ++ member.elementCamel ++ "` element of this family — delegates to [`" ++ member.origModuleName ++ ".component`](" ++ member.origModuleName ++ "#component). -}"

                            else
                                "{-| See [`" ++ member.origModuleName ++ "." ++ item.srcName ++ "`](" ++ member.origModuleName ++ "#" ++ item.srcName ++ "). -}"
                    in
                    Ok
                        ([ doc
                         , item.emittedName ++ " :"
                         , ann
                         , item.emittedName ++ " ="
                         , "    " ++ member.alias_ ++ "." ++ item.srcName
                         ]
                            |> String.join "\n"
                        )


generateFamilyModule : String -> List Member -> String -> Result String String
generateFamilyModule familyModuleName members familyBlurb =
    let
        emitted =
            members
                |> List.concatMap
                    (\member ->
                        member.surface.exposing_
                            |> List.map
                                (\name ->
                                    if isUpperFirst name then
                                        { kind = KType, emittedName = member.elementPascal ++ name, member = member, srcName = name }

                                    else if name == "component" then
                                        { kind = KCtor, emittedName = member.elementCamel, member = member, srcName = name }

                                    else
                                        { kind = KValue, emittedName = member.elementCamel ++ upperFirst name, member = member, srcName = name }
                                )
                    )

        typeNames =
            emitted |> List.filter (\e -> e.kind == KType) |> List.map .emittedName

        valueNames =
            emitted |> List.filter (\e -> e.kind /= KType) |> List.map .emittedName

        exposingAll =
            typeNames ++ valueNames

        exposingList =
            String.join "\n    , " exposingAll

        moduleLine =
            "module " ++ familyModuleName ++ " exposing\n    ( " ++ exposingList ++ "\n    )"

        memberList =
            members
                |> List.map (\mem -> "[`" ++ mem.origModuleName ++ "`](" ++ mem.origModuleName ++ ") as `" ++ mem.elementCamel ++ "`")
                |> String.join ", "

        docLines =
            [ "{-| " ++ familyBlurb
            , ""
            , "This is the **flat family module** for this family: one module carrying every"
            , "member element as an element-named constructor (delegating to that component's"
            , "`component` ctor), with element-prefixed type aliases and element-prefixed"
            , "typed helpers so members never collide. It re-exports:"
            , ""
            , memberList ++ "."
            , ""
            , "Prefer whichever import reads best — the flat `M3e.Component.*` modules and"
            , "this family module are the same elements, same types."
            , ""
            , "@docs " ++ String.join ", " exposingAll
            , "-}"
            ]
                |> String.join "\n"

        annBlob =
            members
                |> List.map
                    (\mem ->
                        mem.surface.exposing_
                            |> List.filter isLowerFirst
                            |> List.map (\n -> Dict.get n mem.surface.valueAnnotations |> Maybe.withDefault "")
                            |> String.join "\n"
                    )
                |> String.join "\n"

        importLines =
            (members |> List.map (\mem -> "import " ++ mem.origModuleName ++ " as " ++ mem.alias_))
                ++ (externalImports
                        |> List.filter (\( _, tokens ) -> List.any (\t -> tokenMatches t annBlob) tokens)
                        |> List.map Tuple.first
                   )

        imports =
            String.join "\n" importLines

        declsResult =
            emitted
                |> List.foldr
                    (\item acc -> acc |> Result.andThen (\ds -> buildDecl item |> Result.map (\d -> d :: ds)))
                    (Ok [])
    in
    declsResult
        |> Result.map
            (\decls ->
                String.join "\n\n\n" ([ moduleLine, docLines, imports ] ++ decls) ++ "\n"
            )



-- ── plan every FLAT family module the package emits ────────────────────────
-- Port of gen-family-package.js:319-407's `planModules`.


type alias PlannedMember =
    { component : String
    , elementPascal : String
    , elementCamel : String
    , alias_ : String
    }


type alias FamilyPlan =
    { familyModuleName : String
    , family : String
    , blurb : String
    , members : List PlannedMember
    }


type alias PlanState =
    { emittedNames : Set String
    , usedComponents : Set String
    , plans : List FamilyPlan
    }


uniqueAlias : Set String -> String -> String
uniqueAlias existing candidate =
    if Set.member candidate existing then
        uniqueAlias existing (candidate ++ "_")

    else
        candidate


planOneFamily : String -> String -> FamilySpec -> PlanState -> Result String PlanState
planOneFamily familyPrefix family spec state =
    let
        familyModuleName =
            familyPrefix ++ "." ++ family
    in
    if Set.member familyModuleName state.emittedNames then
        Err ("gen-family-package: duplicate emitted module name " ++ familyModuleName ++ ".")

    else
        let
            candidates =
                (case spec.root of
                    Just root ->
                        [ ( root, family ) ]

                    Nothing ->
                        []
                )
                    ++ (spec.members |> List.map (\m -> ( m.component, m.path )))

            pushOne ( component, elementPascal ) acc =
                acc
                    |> Result.andThen
                        (\st ->
                            if Set.member component st.used then
                                Err
                                    ("gen-family-package: component "
                                        ++ component
                                        ++ " is assigned to more than one family/member — a component may belong to at most one family."
                                    )

                            else if Set.member elementPascal st.labels then
                                Err
                                    ("gen-family-package: family \""
                                        ++ family
                                        ++ "\" has two members with element label \""
                                        ++ elementPascal
                                        ++ "\" — element labels must be unique within a flat family module (they name the constructor and prefix the types/helpers)."
                                    )

                            else
                                let
                                    alias_ =
                                        uniqueAlias st.aliasesInFam (elementPascal ++ "_")
                                in
                                Ok
                                    { used = Set.insert component st.used
                                    , labels = Set.insert elementPascal st.labels
                                    , aliasesInFam = Set.insert alias_ st.aliasesInFam
                                    , membersAcc =
                                        { component = component
                                        , elementPascal = elementPascal
                                        , elementCamel = lowerFirst elementPascal
                                        , alias_ = alias_
                                        }
                                            :: st.membersAcc
                                    }
                        )
        in
        candidates
            |> List.foldl pushOne (Ok { used = state.usedComponents, labels = Set.empty, aliasesInFam = Set.empty, membersAcc = [] })
            |> Result.andThen
                (\st ->
                    let
                        usedComponents =
                            st.used

                        plannedMembers =
                            List.reverse st.membersAcc
                    in
                    if List.isEmpty plannedMembers then
                        Err ("gen-family-package: family \"" ++ family ++ "\" has no root and no members — nothing to emit.")

                    else
                        Ok
                            { emittedNames = Set.insert familyModuleName state.emittedNames
                            , usedComponents = usedComponents
                            , plans =
                                { familyModuleName = familyModuleName
                                , family = family
                                , blurb = "The **" ++ family ++ "** family — flat module re-exporting its member elements."
                                , members = plannedMembers
                                }
                                    :: state.plans
                            }
                )


planFamilies : String -> String -> FamiliesConfig -> Result String (List FamilyPlan)
planFamilies lib ns cfg =
    if List.isEmpty cfg.families then
        Err "gen-family-package: _families.families is empty — nothing to emit."

    else
        let
            familyPrefix =
                lib ++ "." ++ ns
        in
        cfg.families
            |> List.foldl
                (\( family, spec ) acc -> acc |> Result.andThen (planOneFamily familyPrefix family spec))
                (Ok { emittedNames = Set.empty, usedComponents = Set.empty, plans = [] })
            |> Result.map (\state -> List.reverse state.plans)



-- ── resolve each planned member against Brand.comps + render its module ───


resolveMember : String -> Brand -> PlannedMember -> Result String Member
resolveMember lib brand pm =
    let
        origModuleName =
            lib ++ ".Component." ++ pm.component
    in
    case brand.comps |> List.filter (\c -> c.name == pm.component) |> List.head of
        Nothing ->
            Err
                ("gen-family-package: source component module not found: "
                    ++ origModuleName
                    ++ " (for family member "
                    ++ pm.elementPascal
                    ++ "). Check the _families config component names."
                )

        Just comp ->
            let
                rendered =
                    Component.compModule brand comp
            in
            parseModuleSurface rendered.contents origModuleName
                |> Result.map
                    (\surface ->
                        { component = pm.component
                        , elementPascal = pm.elementPascal
                        , elementCamel = pm.elementCamel
                        , alias_ = pm.alias_
                        , origModuleName = origModuleName
                        , surface = surface
                        }
                    )


{-| The family module tree lives ONLY inside the standalone package (there is
no flat copy at `--output`, unlike the icon module's main-file + package-copy
duality) — so its path always carries the `"../<pkg.dir>/src/"` prefix
(research §3/§5 Risk 2), matching gen-family-package.js:410-431's
`writePackageTree`, which writes exclusively to `<pkgDir>/src/<relPath>`.
-}
renderOneFamily : String -> String -> Brand -> FamilyPlan -> Result String { moduleName : String, elmFile : Elm.File }
renderOneFamily pkgDir lib brand plan =
    plan.members
        |> List.foldr
            (\pm acc -> acc |> Result.andThen (\ms -> resolveMember lib brand pm |> Result.map (\m -> m :: ms)))
            (Ok [])
        |> Result.andThen
            (\members ->
                generateFamilyModule plan.familyModuleName members plan.blurb
                    |> Result.map
                        (\src ->
                            { moduleName = plan.familyModuleName
                            , elmFile =
                                { path = "../" ++ pkgDir ++ "/src/" ++ String.join "/" (String.split "." plan.familyModuleName) ++ ".elm"
                                , contents = src
                                , warnings = []
                                }
                            }
                        )
            )


{-| Build the standalone package's `elm.json`, at the same `"../<pkg.dir>/..."`
nested path convention as `Generate.Phantom.Emit.IconModule` (research §3/§5
Risk 2) — one level above `--output`.
-}
familyElmJsonFile : FamilyPackageConfig -> List String -> Elm.File
familyElmJsonFile pkg exposedModules =
    let
        depsJson =
            pkg.deps
                |> List.map (\( k, v ) -> "        \"" ++ k ++ "\": \"" ++ v ++ "\"")
                |> String.join ",\n"

        exposedJson =
            exposedModules
                |> List.map (\m -> "        \"" ++ m ++ "\"")
                |> String.join ",\n"

        contents =
            "{\n"
                ++ "    \"type\": \"package\",\n"
                ++ "    \"name\": \""
                ++ pkg.name
                ++ "\",\n"
                ++ "    \"summary\": \""
                ++ pkg.summary
                ++ "\",\n"
                ++ "    \"license\": \"BSD-3-Clause\",\n"
                ++ "    \"version\": \""
                ++ pkg.version
                ++ "\",\n"
                ++ "    \"exposed-modules\": [\n"
                ++ exposedJson
                ++ "\n    ],\n"
                ++ "    \"elm-version\": \"0.19.0 <= v < 0.20.0\",\n"
                ++ "    \"dependencies\": {\n"
                ++ depsJson
                ++ "\n    },\n"
                ++ "    \"test-dependencies\": {}\n"
                ++ "}\n"
    in
    { path = "../" ++ pkg.dir ++ "/elm.json", contents = contents, warnings = [] }


{-| Emit every `<lib>.<namespace>.<Family>` flat family module plus the
standalone package's `elm.json`. `Nothing` config is a silent no-op,
mirroring gen-family-package.js's own opt-in behavior when `_families` is
absent.
-}
files : Brand -> Maybe FamiliesConfig -> Result String (List Elm.File)
files brand maybeConfig =
    case maybeConfig of
        Nothing ->
            Ok []

        Just cfg ->
            planFamilies cfg.lib cfg.namespace cfg
                |> Result.andThen
                    (\plans ->
                        plans
                            |> List.foldr
                                (\plan acc -> acc |> Result.andThen (\fs -> renderOneFamily cfg.package.dir cfg.lib brand plan |> Result.map (\f -> f :: fs)))
                                (Ok [])
                    )
                |> Result.map
                    (\rendered ->
                        let
                            exposedModules =
                                rendered |> List.map .moduleName |> List.sort

                            srcFiles =
                                rendered |> List.map .elmFile
                        in
                        srcFiles ++ [ familyElmJsonFile cfg.package exposedModules ]
                    )
