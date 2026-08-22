module Generate.Phantom.Emit.FamilyPackage exposing (degenerateFacadeModule, familyElmJsonFile, familyLicenseFile, familyReadmeFile, files)

{-| Port of bin/gen-family-package.js (G3, 2026-08-19 generator-consolidation
research). Emits `<lib>.<namespace>.<Family>` flat family modules that
re-export each member element's flat `<lib>.Element.*` surface,
additively.

Per the plan's own Task 7 design note: this module never independently
re-derives (and so can never drift from) the per-component
exposing/type/annotation surface `compModule` already builds — it consumes
`Generate.Phantom.Emit.Component.compSurface`, which is computed by the SAME
shared `componentCore` function `compModule` renders from (see
`Component.elm`'s doc comments). There is no regex, no re-parsing of
rendered `.elm` text anywhere in this path — the surface is read directly
off `Brand.comps`/`Comp` records via `compSurface`, exactly as the plan
asked for, replacing gen-family-package.js's fragile
`parseModuleSurface` (which had to re-derive this by reading the rendered
`.elm` file back off disk) with data captured at construction time instead.

`README.md`/`LICENSE` generation (`gen-family-package.js:450-500`) IS
emitted (`familyReadmeFile`/`familyLicenseFile`) — matching the icon
module's port. The only narrowing, per Task 7's own design note, is dropping
README's "only if destination absent" check (Elm has no filesystem access to
probe that, and elm-codegen's writer overwrites unconditionally every run
regardless, so this is a no-op for byte-equality); LICENSE keeps its
conditional shape via `Maybe Elm.File`, sourced from `licenseText` injected
into flags by `bin/elm-cem.js`'s `injectPackageLicense`.

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
import Generate.Phantom.Emit.Component as Component exposing (ComponentSurface)
import Generate.Phantom.Emit.Shared exposing (homeOf)
import Generate.Phantom.Model exposing (Brand, Comp)
import Generate.Types exposing (FamiliesConfig, FamilyPackageConfig, FamilySpec)
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



-- ── small char-boundary helpers (regex-free word-boundary matching) ───────
-- `Generate.Phantom.Emit.Component.compSurface` supplies exposing/type/
-- annotation data directly (no filesystem, no rendered-text re-parse); the
-- ONLY text-processing left in this module is `prefixTypeRefs`'s rewrite of
-- a copied annotation's type references and `tokenMatches`'s "does this
-- external token appear" test, both ported from gen-family-package.js's own
-- word-boundary regexes (`(^|[^.\w])name\b`, `\bT\b` / `T\.U\b`) using plain
-- `String` splitting instead of `elm/regex` — this module has no dependency
-- on that package.


isWordChar : Char -> Bool
isWordChar c =
    Char.isAlphaNum c || c == '_'


lastChar : String -> Maybe Char
lastChar s =
    s |> String.reverse |> String.uncons |> Maybe.map Tuple.first


firstChar : String -> Maybe Char
firstChar s =
    s |> String.uncons |> Maybe.map Tuple.first



-- ── rewrite a member's annotation to reference prefixed local type names ──
-- Port of gen-family-package.js:164-176's `prefixTypeRefs` (regex
-- `(^|[^.\w])name\b`, global): every whole-word occurrence of one of the
-- member's OWN exposed types becomes the element-prefixed local alias,
-- EXCLUDING occurrences immediately preceded by a `.` (a qualified
-- reference) or another word character (a longer identifier this name is a
-- substring of).


prefixTypeRefs : String -> Set String -> String -> String
prefixTypeRefs annotationText exposedTypeNames elementPascal =
    let
        namesLongestFirst =
            exposedTypeNames
                |> Set.toList
                |> List.sortBy (\s -> -(String.length s))

        replaceOne target text =
            case String.split target text of
                [] ->
                    text

                [ _ ] ->
                    text

                first :: rest ->
                    List.foldl
                        (\part acc ->
                            let
                                precededOk =
                                    case lastChar acc of
                                        Nothing ->
                                            True

                                        Just c ->
                                            not (isWordChar c) && c /= '.'

                                followedOk =
                                    case firstChar part of
                                        Nothing ->
                                            True

                                        Just c ->
                                            not (isWordChar c)
                            in
                            if precededOk && followedOk then
                                acc ++ elementPascal ++ target ++ part

                            else
                                acc ++ target ++ part
                        )
                        first
                        rest
    in
    List.foldl replaceOne annotationText namesLongestFirst


{-| Port of gen-family-package.js:262-268's external-import token test
(`\bT\b` for a bare token, `T\.U\b` — no LEADING boundary — for a dotted
one, e.g. `"Ac.Action"`).
-}
tokenMatches : String -> String -> Bool
tokenMatches token annBlob =
    let
        requireLeadingBoundary =
            not (String.contains "." token)
    in
    case String.split token annBlob of
        [] ->
            False

        [ _ ] ->
            False

        first :: rest ->
            let
                go acc parts =
                    case parts of
                        [] ->
                            False

                        part :: restParts ->
                            let
                                precededOk =
                                    if requireLeadingBoundary then
                                        case lastChar acc of
                                            Nothing ->
                                                True

                                            Just c ->
                                                not (isWordChar c)

                                    else
                                        True

                                followedOk =
                                    case firstChar part of
                                        Nothing ->
                                            True

                                        Just c ->
                                            not (isWordChar c)
                            in
                            if precededOk && followedOk then
                                True

                            else
                                go (acc ++ token ++ part) restParts
            in
            go first rest



-- ── emit one FLAT family module ────────────────────────────────────────────
-- Port of gen-family-package.js:178-317's `generateFamilyModule`.


type alias Member =
    { component : String
    , elementPascal : String
    , elementCamel : String
    , alias_ : String
    , origModuleName : String
    , surface : ComponentSurface
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

        -- The brand's library root (`M3e`, `Sl`, `Hz`, …), taken from the module
        -- name so doc prose stays brand-NEUTRAL (a hardcoded `M3e.Element.*` here
        -- trips the neutrality gate on non-m3e brands' generated output).
        lib =
            familyModuleName |> String.split "." |> List.head |> Maybe.withDefault ""

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
            , "Prefer whichever import reads best — the flat `" ++ lib ++ ".Element.*` modules and"
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


{-| DAG-rework Task 3: render a DEGENERATE single-member family façade for a
STANDALONE element (one not in any declared `_families` family). The composed
`BuildPackage` builder for every element must source its element-tier types +
slot placers through a `<lib>.Component.<Family>` façade (Task 5's gate forbids
`<lib>.Build.* → <lib>.Element.*`); a standalone element's family IS just that
element, so it needs a 1:1 façade module — member label = element name — of the
exact same shape `generateFamilyModule` builds for the declared families. This
reuses `generateFamilyModule` verbatim so a degenerate façade can never drift
from a declared one; the ONLY difference is the module name (caller-supplied,
so Task 3 can emit under the temporary `Component2` namespace and Task 4 promote
it to the real `Component` namespace) and the single-member membership.

`fullModuleName` is the whole `<lib>.<ns>.<Element>` name; `element` is the
element's Pascal component name (used as both the component lookup key and the
member label). Returns the rendered module source, or an `Err` if the element
is not found in `brand.comps`.
-}
degenerateFacadeModule : String -> Brand -> String -> String -> Result String String
degenerateFacadeModule lib brand fullModuleName element =
    resolveMember lib
        brand
        { component = element
        , elementPascal = element
        , elementCamel = lowerFirst element
        , alias_ = element ++ "_"
        }
        |> Result.andThen
            (\member ->
                generateFamilyModule fullModuleName
                    [ member ]
                    ("The **" ++ element ++ "** element — degenerate single-member family façade.")
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
            lib ++ ".Element." ++ pm.component
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
                surface =
                    Component.compSurface brand comp
            in
            Ok
                { component = pm.component
                , elementPascal = pm.elementPascal
                , elementCamel = pm.elementCamel
                , alias_ = pm.alias_
                , origModuleName = origModuleName
                , surface = surface
                }


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


{-| Port of gen-family-package.js:453-482's README template — a fixed,
non-family-parameterized usage example (the JS hardcoded `M3e.Family.Chip`,
now emitted as `M3e.Component.Chip` post-namespace-rename
literally rather than deriving it from any emitted family; preserved
verbatim per the plan's "port line-for-line" rule). Always emitted — same
"only if absent is a no-op here" reasoning as
`Generate.Phantom.Emit.IconModule.iconPackageReadmeFile`.
-}
familyReadmeFile : FamilyPackageConfig -> Elm.File
familyReadmeFile pkg =
    let
        contents =
            String.join "\n"
                [ "# " ++ pkg.name
                , ""
                , pkg.summary
                , ""
                , "This package is a standalone sub-package of [elm-m3e](https://github.com/jackhp95/elm-m3e)."
                , "It is a **purely additive** re-organization: each module here is a **flat**"
                , "family module that re-exports the member elements of one family from the flat"
                , "`M3e.Element.*` surface — element-named constructors (`M3e.Component.Chip.assist`"
                , "delegates to `M3e.Element.AssistChip.component`) plus element-prefixed types"
                , "(`AssistIs`, `AssistAttrs`) and element-prefixed helpers (`assistVariant`) —"
                , "so nothing built against the flat surface regresses. Depends on"
                , "`jackhp95/elm-m3e-components` — it adds no logic of its own."
                , ""
                , "**Generated file.** Do not edit `src/` by hand — run `npm run gen:src` in the"
                , "elm-m3e repo to regenerate from the `_families` config (`config/slots.json`)."
                , ""
                , "## Usage"
                , ""
                , "```elm"
                , "import M3e.Component.Chip as Chip"
                , ""
                , "Chip.set [] [ Chip.child (Chip.assist [] [ Chip.assistChild ... ]) ]"
                , "```"
                , ""
                , "## License"
                , ""
                , "BSD-3-Clause — see [LICENSE](LICENSE)."
                ]
                ++ "\n"
    in
    { path = "../" ++ pkg.dir ++ "/README.md", contents = contents, warnings = [] }


{-| Port of gen-family-package.js:488-500's LICENSE copy — see
`Generate.Phantom.Emit.IconModule.iconPackageLicenseFile`'s doc comment for
the identical `licenseText`/`injectPackageLicense` mechanism.
-}
familyLicenseFile : FamilyPackageConfig -> Maybe Elm.File
familyLicenseFile pkg =
    pkg.licenseText
        |> Maybe.map (\text -> { path = "../" ++ pkg.dir ++ "/LICENSE", contents = text, warnings = [] })


{-| DAG-rework Task 4: the STANDALONE (degenerate) elements — every
builder-bearing element (`homeOf == Nothing`, mirroring `Emit.elm`'s `own`) that
is not a member of any declared `_families` family. Each becomes a 1:1
`<lib>.<ns>.<Element>` façade so the composed Build tier can route EVERY
element's builder through Components (Task 5's gate forbids `Build → Element`),
and so the Components tier and the per-element re-exports cover all 130 elements.
Emitter-computed (OQ-2) — the brand author's `slots.json` surface is unchanged.
-}
degenerateElements : Brand -> FamiliesConfig -> List String
degenerateElements brand cfg =
    let
        claimed =
            cfg.families
                |> List.concatMap
                    (\( _, spec ) ->
                        (case spec.root of
                            Just root ->
                                [ root ]

                            Nothing ->
                                []
                        )
                            ++ (spec.members |> List.map .component)
                    )
                |> Set.fromList
    in
    brand.comps
        |> List.filter (\c -> homeOf c == Nothing && not (Set.member c.name claimed))
        |> List.map .name


{-| Emit every `<lib>.<namespace>.<Family>` flat family module — the declared
`_families` families PLUS a degenerate single-member façade per standalone
element (DAG-rework Task 4) — plus the standalone package's
`elm.json`/`README.md`/`LICENSE`. `Nothing` config is a silent no-op, mirroring
gen-family-package.js's own opt-in behavior when `_families` is absent.
-}
files : Brand -> Maybe FamiliesConfig -> Result String (List Elm.File)
files brand maybeConfig =
    case maybeConfig of
        Nothing ->
            Ok []

        Just cfg ->
            let
                ns =
                    cfg.namespace

                declaredResult =
                    planFamilies cfg.lib ns cfg
                        |> Result.andThen
                            (\plans ->
                                plans
                                    |> List.foldr
                                        (\plan acc -> acc |> Result.andThen (\fs -> renderOneFamily cfg.package.dir cfg.lib brand plan |> Result.map (\f -> f :: fs)))
                                        (Ok [])
                            )

                degenerateResult =
                    degenerateElements brand cfg
                        |> List.foldr
                            (\el acc ->
                                acc
                                    |> Result.andThen
                                        (\rs ->
                                            let
                                                modName =
                                                    cfg.lib ++ "." ++ ns ++ "." ++ el
                                            in
                                            degenerateFacadeModule cfg.lib brand modName el
                                                |> Result.map
                                                    (\src ->
                                                        { moduleName = modName
                                                        , elmFile =
                                                            { path = "../" ++ cfg.package.dir ++ "/src/" ++ String.join "/" (String.split "." modName) ++ ".elm"
                                                            , contents = src
                                                            , warnings = []
                                                            }
                                                        }
                                                            :: rs
                                                    )
                                        )
                            )
                            (Ok [])
            in
            Result.map2 (\declared degenerate -> declared ++ degenerate) declaredResult degenerateResult
                |> Result.map
                    (\rendered ->
                        let
                            exposedModules =
                                rendered |> List.map .moduleName |> List.sort

                            srcFiles =
                                rendered |> List.map .elmFile

                            packageFiles =
                                [ familyElmJsonFile cfg.package exposedModules
                                , familyReadmeFile cfg.package
                                ]
                                    ++ (familyLicenseFile cfg.package |> Maybe.map List.singleton |> Maybe.withDefault [])
                        in
                        srcFiles ++ packageFiles
                    )
