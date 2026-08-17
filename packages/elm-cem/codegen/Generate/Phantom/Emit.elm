module Generate.Phantom.Emit exposing (files, factsBundleFile)

{-| The phantom emitter: a pure projection of `Generate.Phantom.Model.Brand`
into the 2-shape module layout on the `elm-html-intermediate-representation`
substrate. Emits raw source strings (elm-format normalizes downstream) —
every signature references aliases, nothing is ever inlined.

`files` returns `Result (List String) (List Elm.File)`. On a post-resolution
collision that the rename rules could not resolve — two identifiers colliding in
one module's top-level namespace, a duplicate record-field, or an empty exposing
list — generation fails loudly with a message naming the module, the colliding
identifier, the raw CEM sources, and a ready-to-paste `_renames` snippet.

`factsBundleFile` is the M1.c facts-bundle Face C emitter: the SAME `Brand`
projection `files` reads, surfaced as data instead of Elm source text, so a
downstream consumer never re-measures what this module already emitted. Callers
gate it behind their own flag — see `bin/elm-cem.js`'s `--facts-bundle` handling
— so `files`' byte output is never affected by whether Face C is requested.

@docs files, factsBundleFile

-}

import Attr
import Cem
import Char
import Dict
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming


{-| Route a component: rich per-component module (DS default), or the
home-grouped view-only path (native families; also any component using
`transparent`/`roles`, which only that path renders).
-}
homeOf : Comp -> Maybe String
homeOf comp =
    case comp.home of
        Just h ->
            Just h

        Nothing ->
            if comp.transparent || comp.roles /= Nothing then
                Just comp.name

            else
                Nothing


{-| Every emitted file for the brand, or a list of collision errors.

Runs the fail-loud guard after building all files: checks that every emitted
module's exposing list is non-empty and duplicate-free, and that every record
row has unique fields. On residual collision, returns `Err` with messages naming
the module, identifier, raw CEM sources, and a ready-to-paste `_renames` snippet.

-}
files : Brand -> Result (List String) (List Elm.File)
files brand =
    let
        own =
            brand.comps |> List.filter (\c -> homeOf c == Nothing)

        homeNames =
            brand.comps
                |> List.filterMap homeOf
                |> List.foldr
                    (\h acc ->
                        if List.member h acc then
                            acc

                        else
                            h :: acc
                    )
                    []
                |> List.sort

        homeGroups =
            homeNames
                |> List.map
                    (\h ->
                        ( h, brand.comps |> List.filter (\c -> homeOf c == Just h) )
                    )

        allFiles =
            [ generalModule brand
            , attributesModule brand
            , eventsModule brand
            , kindModule brand
            ]
                -- K6: omit Values entirely when there are no unions and no tokens.
                -- An empty Values module would emit `exposing ()` which is invalid Elm.
                -- syncExposedModules in bin/elm-cem.js rebuilds elm.json from the
                -- emitted file tree, so omitting the file self-heals exposed-modules.
                ++ (if List.isEmpty brand.unions then
                        []

                    else
                        [ valuesModule brand ]
                   )
                ++ ariaModule brand
                ++ [ factsModule brand ]
                ++ unsafeModule brand
                ++ actionModule brand
                -- R3: the shared pipe-builder mechanics live once per brand.
                -- Only emitted when at least one rich per-component module
                -- exists (native/home-only brands have no `Builder`).
                ++ (if List.isEmpty own then
                        []

                    else
                        [ buildInternalModule brand, buildModule brand own ]
                   )
                -- R2: the loose elm/html-like producer layer (owns `Ir.node`),
                -- emitted only when a rich per-component shape exists.
                ++ htmlModule brand
                -- Per-component modules: the internal-types, component surface, and builder module.
                ++ List.concatMap (\comp -> [ internalTypesModule brand comp, compModule brand comp, compBuildModule brand comp ]) own
                ++ List.map (homeModule brand) homeGroups

        guardErrors =
            runGuard brand
    in
    if List.isEmpty guardErrors then
        Ok allFiles

    else
        Err guardErrors


file : List String -> String -> Elm.File
file modulePath contents =
    { path = String.join "/" modulePath ++ ".elm"
    , contents = contents
    , warnings = []
    }



-- FAIL-LOUD GUARD


{-| Check the brand's resolved namespaces for collisions and empty exposing
lists. Returns a list of error messages; empty list means clean.

Checks (per the spec §4.3):

  - Per emitted module: all top-level value identifiers unique; all exposed type
    aliases unique; every exposing/@docs list non-empty and duplicate-free.
  - Per record row (Attrs, AttrCaps, content aliases): field names unique.

The guard operates on the same data structures that feed exposeBlock/docsBlock,
so no declaration IR is needed.

-}
runGuard : Brand -> List String
runGuard brand =
    List.concat
        [ guardGeneralModule brand

        -- Static namespace (CEM-independent): factsModule (review-only JSON wiring,
        -- no public Elm namespace) and unsafeModule (single static `fromHtml` decl).
        , guardAttributesModule brand
        , guardEventsModule brand
        , guardValuesModule brand
        , guardKindModule brand
        , brand.comps |> List.concatMap (guardCompModule brand)
        , brand.comps
            |> List.filterMap homeOf
            |> List.foldr
                (\h acc ->
                    if List.member h acc then
                        acc

                    else
                        h :: acc
                )
                []
            |> List.sort
            |> List.concatMap
                (\h ->
                    let
                        members =
                            brand.comps |> List.filter (\c -> homeOf c == Just h)
                    in
                    guardHomeModule brand h members
                )
        , guardCoerceModule brand
        , guardActionModule brand
        , guardAriaModule brand
        , guardSharedAtoms brand
        ]


{-| Every `Shared`-marked field about to be written must be in the canonical
cross-library vocabulary (`Model.sharedAtomVocabulary`).

`Model.resolveWith` already enforces this, earlier and in config vocabulary, which
is the message a config author wants. This is the same rule stated at the output,
and it is worth stating twice for one reason: the resolution check ENUMERATES the
routes a shared role can take (`_atoms`, a component's `kind`, a slot's `kinds`,
both ends of a `_coerce` entry). Enumerating routes is exactly the mistake that
produced the defect this vocabulary exists to prevent — `_coerce` was left off the
list for a release, and the symptom was `shared:phrasing : Brand` appearing in a
generated type annotation with nothing in the failure naming the config key.

A guard positioned at the bytes cannot be bypassed by adding a route. It is
unreachable from any config today, which is the point: it fires only if some
future emitter path invents a field name, and `tests/src/SharedAtomVocabTest.elm`
poisons a resolved `Brand` directly to keep it honest.

-}
guardSharedAtoms : Brand -> List String
guardSharedAtoms brand =
    let
        fieldErrors where_ fields =
            fields
                |> List.filterMap
                    (\f ->
                        case f.marker of
                            MShared ->
                                if M.knownSharedRole (M.sharedRoleOfField f.field) then
                                    Nothing

                                else
                                    Just (M.unknownSharedFieldError where_ f.field)

                            MBrand ->
                                Nothing
                    )

        spellingErrors where_ spelling =
            case M.sharedRoleOf spelling of
                Just role ->
                    if M.knownSharedRole role then
                        []

                    else
                        [ M.unknownSharedRoleError where_ role ]

                Nothing ->
                    []

        slotFields slot =
            case slot.content of
                Permissive ->
                    []

                SetContent set ->
                    set.fields

                Fields fs ->
                    fs
    in
    List.concat
        [ brand.atoms |> List.concatMap (spellingErrors (brand.lib ++ " `_atoms`") << (++) "shared:")
        , brand.comps
            |> List.concatMap
                (\c ->
                    fieldErrors (brand.lib ++ "." ++ c.name ++ " produces") [ c.produces ]
                        ++ (c.slots
                                |> List.concatMap
                                    (\s -> fieldErrors (brand.lib ++ "." ++ c.name ++ " slot '" ++ s.name ++ "'") (slotFields s))
                           )
                )
        , brand.sets |> List.concatMap (\s -> fieldErrors (brand.lib ++ ".Kind." ++ s.pascal) s.fields)
        , brand.coercions
            |> List.concatMap
                (\c ->
                    spellingErrors (brand.lib ++ ".Coerce." ++ c.name ++ ".fromKind") c.fromKind
                        ++ spellingErrors (brand.lib ++ ".Coerce." ++ c.name ++ ".to") c.to
                )
        ]
        |> List.foldr
            (\e acc ->
                if List.member e acc then
                    acc

                else
                    e :: acc
            )
            []


guardDuplicates : String -> String -> List String -> List String
guardDuplicates moduleName context names =
    let
        dups =
            names
                |> List.foldl
                    (\n ( seen, found ) ->
                        if List.member n seen then
                            ( seen, n :: found )

                        else
                            ( n :: seen, found )
                    )
                    ( [], [] )
                |> Tuple.second
                |> List.reverse
    in
    dups
        |> List.map
            (\d ->
                "COLLISION in module "
                    ++ moduleName
                    ++ " ("
                    ++ context
                    ++ "): duplicate identifier '"
                    ++ d
                    ++ "'. Add a `_renames` override to resolve."
            )


{-| Rich duplicate guard: takes `(ident, rawSource)` pairs where `rawSource` is
a human-readable label for the CEM artifact (e.g. `"attr \"with-hint\""`,
`"event \"wa-error\""`, `"token \"AUTO\""`). On collision, emits a message
naming the module, identifier, each raw source, and a ready-to-paste `_renames`
snippet hint. `snippetHint` is a short string inserted into the snippet body
(e.g. `"\"_tokens\": { \"AUTO\": \"autoUpper\" }"`).
-}
guardDuplicatesRich : String -> String -> String -> List ( String, String ) -> List String
guardDuplicatesRich moduleName context snippetHint pairs =
    let
        -- Group by ident; collect all rawSources for each ident.
        grouped =
            pairs
                |> List.foldl
                    (\( ident, rawSrc ) acc ->
                        case List.filter (\( k, _ ) -> k == ident) acc of
                            [] ->
                                acc ++ [ ( ident, [ rawSrc ] ) ]

                            _ ->
                                acc
                                    |> List.map
                                        (\( k, vs ) ->
                                            if k == ident then
                                                ( k, vs ++ [ rawSrc ] )

                                            else
                                                ( k, vs )
                                        )
                    )
                    []
    in
    grouped
        |> List.filterMap
            (\( ident, rawSrcs ) ->
                if List.length rawSrcs > 1 then
                    Just
                        ("COLLISION in module "
                            ++ moduleName
                            ++ " ("
                            ++ context
                            ++ "): identifier '"
                            ++ ident
                            ++ "' — raw sources: "
                            ++ String.join ", " rawSrcs
                            ++ "\n_renames snippet:\n{ "
                            ++ snippetHint
                            ++ " }"
                        )

                else
                    Nothing
            )


guardNonEmpty : String -> String -> List String -> List String
guardNonEmpty moduleName context names =
    if List.isEmpty names then
        [ "EMPTY EXPOSING LIST in module " ++ moduleName ++ " (" ++ context ++ "): would emit `exposing ()` which is invalid Elm." ]

    else
        []


guardGeneralModule : Brand -> List String
guardGeneralModule brand =
    let
        moduleName =
            brand.lib

        ctorPairs =
            brand.comps |> List.map (\c -> ( c.resolvedCtor, "element \"" ++ c.name ++ "\"" ))

        atomPairs =
            brand.atoms |> List.map (\a -> ( a, "atom \"" ++ a ++ "\"" ))

        slotResult =
            looseSlotPlacers brand

        slotPairs =
            slotResult.placers |> List.map (\p -> ( p.ident, "slot placer \"" ++ p.htmlName ++ "\"" ))

        -- Camel-collisions between different HTML slot strings are a fatal error.
        slotCollisionErrors =
            slotResult.collisions
                |> List.map
                    (\col ->
                        "SLOT COLLISION in module "
                            ++ moduleName
                            ++ ": slot names "
                            ++ String.join ", " (List.map (\n -> "\"" ++ n ++ "\"") col.htmlNames)
                            ++ " all map to identifier '"
                            ++ col.ident
                            ++ "'. Add a `_renames` override to resolve."
                    )

        allPairs =
            ctorPairs ++ atomPairs ++ slotPairs ++ [ ( "toHtml", "render bridge" ) ]

        topLevel =
            allPairs |> List.map Tuple.first

        snippetHint =
            "\"_elements\": { \"<tagName>\": \"customCtorName\" }"
    in
    List.concat
        [ guardNonEmpty moduleName "top-level" topLevel
        , guardDuplicatesRich moduleName "top-level" snippetHint allPairs
        , slotCollisionErrors
        ]


guardAttributesModule : Brand -> List String
guardAttributesModule brand =
    let
        moduleName =
            brand.lib ++ ".Attributes"

        plainSpecs =
            brand.sharedAttrs
                |> List.filter
                    (\a ->
                        not (isEnumSpec a)
                            && not (List.any (\e -> e.elmName == a.elmName) brand.unions)
                    )

        plainAttrPairs =
            plainSpecs
                |> List.map (\a -> ( a.elmName, "attr \"" ++ a.htmlName ++ "\"" ))

        -- The `default*` companions share this namespace. A brand whose manifest already
        -- has (say) a `default-value` attribute would collide here, and must say so with
        -- a `_controlled` companion rename rather than emitting two `defaultValue`s.
        companionPairs =
            companionsFor brand (brandSuppressed brand) plainSpecs
                |> List.map (\( _, n, a ) -> ( n, "controlled companion for attr \"" ++ a.htmlName ++ "\"" ))

        -- The `_variants` setters share this namespace too. A variant named after an
        -- attribute the manifest already declares (or after another variant) collides
        -- here rather than emitting two setters of one name.
        variantPairs =
            variantsFor brand plainSpecs
                |> List.map (\( v, a ) -> ( v.name, "variant of attr \"" ++ a.htmlName ++ "\"" ))

        -- An ENUM GLOBAL is in `brand.unions` too (that is where its `<Lib>.Values`
        -- row is minted), but its setter is emitted by the globals block, not the
        -- enum block. Counting it in both would report a phantom self-collision.
        enumAttrPairs =
            brand.unions
                |> List.filter (\u -> not (isGlobalName brand u.elmName))
                |> List.map (\u -> ( u.elmName, "enum attr \"" ++ u.elmName ++ "\"" ))

        -- Globals are a fixed hand-curated set per brand (`_globals`); they're
        -- included in topLevel for the non-empty check but don't need rich source
        -- tracking (they never collide with each other).
        globalPairs =
            allGlobals brand |> List.map (\g -> ( g.elmName, "global attr \"" ++ g.elmName ++ "\"" ))

        basePairs =
            globalPairs ++ plainAttrPairs ++ companionPairs ++ variantPairs ++ enumAttrPairs

        -- Portmanteau attributes (`<attr><ValuePascal>`) share this namespace.
        -- Computed against the already-taken names so dropped portmanteaus never
        -- trigger a false collision; only the ones actually emitted are checked.
        attrPortmanteauPairs =
            enumAttrPortmanteaus brand (basePairs |> List.map Tuple.first)
                |> List.map (\p -> ( p.name, "enum attr portmanteau \"" ++ p.capName ++ "\" + \"" ++ p.tokenValue ++ "\"" ))

        allPairs =
            basePairs ++ attrPortmanteauPairs

        topLevel =
            allPairs |> List.map Tuple.first

        snippetHint =
            "\"<compName>\": { \"attr:<htmlName>\": \"customName\" }"
    in
    List.concat
        [ guardNonEmpty moduleName "top-level" topLevel
        , guardDuplicatesRich moduleName "top-level" snippetHint allPairs
        ]


guardEventsModule : Brand -> List String
guardEventsModule brand =
    let
        moduleName =
            brand.lib ++ ".Events"

        -- Pairs of (handler ident, raw event name) for rich error messages.
        handlerPairs =
            distinctSetterEvents brand
                |> List.concatMap
                    (\ev ->
                        let
                            n =
                                handlerName brand ev

                            rawLabel =
                                "event \"" ++ ev.name ++ "\""
                        in
                        [ ( n, rawLabel ), ( n ++ "With", rawLabel ) ]
                    )
                |> List.sortBy Tuple.first

        topLevel =
            (handlerPairs |> List.map Tuple.first) ++ [ "delegate" ]

        snippetHint =
            "\"_events\": { \"<eventName>\": \"onCustomName\" }"
    in
    List.concat
        [ guardNonEmpty moduleName "top-level" topLevel
        , guardDuplicatesRich moduleName "top-level" snippetHint handlerPairs
        ]


guardValuesModule : Brand -> List String
guardValuesModule brand =
    if List.isEmpty brand.unions then
        -- K6: Values module is omitted when empty; no guard needed.
        []

    else
        let
            moduleName =
                brand.lib ++ ".Values"

            -- All raw tokens brand-wide (sorted for determinism; true dups of the
            -- SAME raw string are collapsed — they're the same token minted once).
            allRawTokens =
                brand.unions
                    |> List.concatMap .tokens
                    |> List.sort
                    |> List.foldl
                        (\t acc ->
                            if List.member t acc then
                                acc

                            else
                                acc ++ [ t ]
                        )
                        []

            -- FIX 1: detect when two DIFFERENT raw strings resolve to the same ident.
            -- Policy (§4.1): this is not a true dup — it's a collision with no
            -- deterministic rename rule → generation FAILS loudly.
            tokenCollisionErrors =
                allRawTokens
                    |> List.foldl
                        (\t ( seen, errs ) ->
                            let
                                ident =
                                    tokenIdentResolved brand t
                            in
                            case List.filter (\existing -> tokenIdentResolved brand existing == ident) seen of
                                [] ->
                                    ( seen ++ [ t ], errs )

                                colliders ->
                                    -- Different raw strings, same ident → fail-loud.
                                    let
                                        allRaw =
                                            colliders ++ [ t ]

                                        rawList =
                                            allRaw |> List.map (\r -> "token \"" ++ r ++ "\"") |> String.join ", "

                                        -- Suggest renaming the first collider (alphabetically).
                                        firstCollider =
                                            colliders |> List.head |> Maybe.withDefault t

                                        snippet =
                                            "{ \"_tokens\": { \""
                                                ++ firstCollider
                                                ++ "\": \""
                                                ++ ident
                                                ++ "Upper\" } }"
                                    in
                                    ( seen
                                    , errs
                                        ++ [ "COLLISION in module "
                                                ++ moduleName
                                                ++ " (top-level): identifier '"
                                                ++ ident
                                                ++ "' — raw sources: "
                                                ++ rawList
                                                ++ "\n_renames snippet:\n"
                                                ++ snippet
                                           ]
                                    )
                        )
                        ( [], [] )
                    |> Tuple.second

            -- After collision check, dedup on ident for the remaining clean tokens
            -- (used for non-empty and duplicate guard below).
            allTokens =
                allRawTokens
                    |> List.foldl
                        (\t acc ->
                            if List.any (\existing -> tokenIdentResolved brand existing == tokenIdentResolved brand t) acc then
                                acc

                            else
                                acc ++ [ t ]
                        )
                        []

            baseNames =
                (brand.unions |> List.map .aliasName |> List.sort)
                    ++ (allTokens |> List.map (tokenIdentResolved brand))
                    -- The Value↔primitive round-trip surface shares this namespace
                    -- too. It must be listed here for two reasons: so a token whose
                    -- ident lands on `<enum>Values` / `<enum>FromString` fails loudly
                    -- like any other collision, and so the portmanteau list computed
                    -- below matches the one `valuesModule` emits (it feeds the same
                    -- names into `enumPortmanteaus`' `taken` set).
                    ++ (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                    ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                    ++ [ "toString" ]

            -- R5: portmanteaus share the module namespace; include them in the
            -- duplicate/non-empty guards (already deduped against baseNames).
            topLevel =
                baseNames
                    ++ (enumPortmanteaus brand baseNames |> List.map .name)
        in
        List.concat
            [ tokenCollisionErrors
            , guardNonEmpty moduleName "top-level" topLevel
            , guardDuplicates moduleName "top-level" topLevel
            ]


guardCompModule : Brand -> Comp -> List String
guardCompModule brand comp =
    -- The 3-package layout splits each component's surface across two modules:
    --   Wa.Component.<Name>  — component, re-exports, events, slot values
    --   Wa.Build.<Name>      — build/toElement, attr pipes, slot pipes
    -- Guard each namespace independently so attrReExportNames and attrPipeNames
    -- never collide (they live in different modules). This dissolves K5.
    List.concat
        [ guardComponentModule brand comp
        , guardBuildModule brand comp
        ]


guardComponentModule : Brand -> Comp -> List String
guardComponentModule brand comp =
    let
        moduleName =
            brand.lib ++ ".Component." ++ comp.name

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        reExportedSpecs =
            comp.attrs
                |> List.filter (\a -> not (List.member a.elmName (comp.ctor :: (comp.enums |> List.map .elmName) ++ (namedSlots |> List.map (\s -> Naming.camel s.name)))))
                |> List.filter (\a -> List.any (\sa -> sa.elmName == a.elmName) brand.sharedAttrs)

        attrReExportNames =
            (reExportedSpecs |> List.map .elmName)
                -- The `default*` companions share this namespace (see `companionsFor`).
                ++ (companionsFor brand comp.propertyOnly reExportedSpecs |> List.map (\( _, n, _ ) -> n))
                -- …and so do the `_variants` setters (see `variantsFor`).
                ++ (variantsFor brand reExportedSpecs |> List.map (\( v, _ ) -> v.name))

        eventNames =
            comp.events |> List.map (handlerName brand)

        -- Component module top-level values: component, enums, re-exports, events, slot values.
        -- Does NOT include attrPipeNames (those live in Build module only).
        topLevelValues =
            List.concat
                [ [ "component" ]
                , comp.enums |> List.concatMap (\e -> [ e.elmName ])
                , attrReExportNames
                , eventNames
                , namedSlots |> List.map (\s -> Naming.camel s.name)
                , case comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head of
                    Just _ ->
                        [ "child" ]

                    Nothing ->
                        []
                ]

        -- Exposed type aliases in the Component module.
        contentAliasNames =
            comp.slots
                |> List.filterMap
                    (\s ->
                        case ( s.name, s.content ) of
                            ( "unnamed", M.Fields _ ) ->
                                Just "Content"

                            ( name_, M.Fields _ ) ->
                                Just (Naming.pascal name_ ++ "Slot")

                            _ ->
                                Nothing
                    )

        topLevelTypes =
            List.concat
                [ [ "Is", "Attrs" ]
                , contentAliasNames
                , [ "ChildAdmittedBy" ]
                , case comp.admittedBy of
                    Just _ ->
                        [ "AdmittedBy" ]

                    Nothing ->
                        []
                , case comp.actionCaps of
                    Just _ ->
                        [ "ActionCaps" ]

                    Nothing ->
                        []
                , comp.enums |> List.map .aliasName
                ]

        -- Snippet hint for collision messages.
        compSnippetHint =
            let
                exampleHtmlName =
                    nonEnumAttrs comp
                        |> List.head
                        |> Maybe.map .htmlName
                        |> Maybe.withDefault "<htmlName>"
            in
            "\"" ++ comp.name ++ "\": { \"attr:" ++ exampleHtmlName ++ "\": \"customName\" }"

        -- Rich pairs for top-level value collision messages.
        topLevelValuePairs =
            List.concat
                [ [ ( "component", "static decl" ) ]
                , comp.enums |> List.concatMap (\e -> [ ( e.elmName, "enum attr \"" ++ e.elmName ++ "\"" ) ])
                , attrReExportNames |> List.map (\n -> ( n, "attr re-export \"" ++ n ++ "\"" ))
                , eventNames |> List.map (\n -> ( n, "event handler" ))
                , namedSlots |> List.map (\s -> ( Naming.camel s.name, "slot \"" ++ s.name ++ "\"" ))
                , case comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head of
                    Just _ ->
                        [ ( "child", "static decl" ) ]

                    Nothing ->
                        []
                ]
    in
    List.concat
        [ guardNonEmpty moduleName "top-level values" topLevelValues
        , guardDuplicatesRich moduleName "top-level values" compSnippetHint topLevelValuePairs
        , guardDuplicates moduleName "top-level types" topLevelTypes
        ]


guardBuildModule : Brand -> Comp -> List String
guardBuildModule brand comp =
    let
        moduleName =
            brand.lib ++ ".Build." ++ comp.name

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        variadicSlots =
            namedSlots |> List.filter .multi

        attrPipeNames_ =
            attrsFields brand comp |> List.map (\f -> "with" ++ Naming.pascal f)

        -- Mirror the slot-pipe naming logic from compBuildModule so the guard
        -- checks exactly what the emitter produces.
        compTopLevelNs =
            List.concat
                [ [ comp.resolvedCtor ]
                , comp.attrs |> List.map .elmName
                , attrPipeNames_
                , comp.events |> List.map (handlerName brand)
                ]

        slotPipeNameOf_ s =
            let
                plain =
                    "with" ++ Naming.pascal s.name
            in
            if List.member plain compTopLevelNs then
                plain ++ "Slot"

            else
                plain

        contentAliasNames =
            comp.slots
                |> List.filterMap
                    (\s ->
                        case ( s.name, s.content ) of
                            ( "unnamed", M.Fields _ ) ->
                                Just "Content"

                            ( name_, M.Fields _ ) ->
                                Just (Naming.pascal name_ ++ "Slot")

                            _ ->
                                Nothing
                    )

        -- Build module top-level values: build, toElement, slot placers, slot pipes, attr pipes.
        topLevelValues =
            List.concat
                [ [ "build", "toElement" ]
                , attrPipeNames_
                , namedSlots |> List.map (\s -> Naming.camel s.name)
                , singularSlots |> List.map slotPipeNameOf_
                , variadicSlots |> List.map slotPipeNameOf_
                , case comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head of
                    Just _ ->
                        [ "withChild" ]

                    Nothing ->
                        []
                ]

        -- Build module type aliases.
        topLevelTypes =
            List.concat
                [ [ "Builder", "AttrCaps", "SlotCaps", "Is" ]
                , contentAliasNames
                , [ "ChildAdmittedBy" ]
                , case comp.admittedBy of
                    Just _ ->
                        [ "AdmittedBy" ]

                    Nothing ->
                        []
                , case comp.actionCaps of
                    Just _ ->
                        [ "ActionCaps" ]

                    Nothing ->
                        []
                ]

        -- Attrs record row fields (AttrCaps row).
        attrCapsFields =
            attrsFields brand comp

        -- SlotCaps record row fields.
        slotCapsFields =
            singularSlots |> List.map (.name >> Naming.camel)

        compSnippetHint =
            let
                exampleHtmlName =
                    nonEnumAttrs comp
                        |> List.head
                        |> Maybe.map .htmlName
                        |> Maybe.withDefault "<htmlName>"
            in
            "\"" ++ comp.name ++ "\": { \"attr:" ++ exampleHtmlName ++ "\": \"customName\" }"

        topLevelValuePairs =
            List.concat
                [ [ ( "build", "static decl" ), ( "toElement", "static decl" ) ]
                , attrPipeNames_ |> List.map (\n -> ( n, "attr pipe \"" ++ n ++ "\"" ))
                , namedSlots |> List.map (\s -> ( Naming.camel s.name, "slot placer \"" ++ s.name ++ "\"" ))
                , singularSlots |> List.map (\s -> ( slotPipeNameOf_ s, "slot pipe \"" ++ s.name ++ "\"" ))
                , variadicSlots |> List.map (\s -> ( slotPipeNameOf_ s, "slot pipe \"" ++ s.name ++ "\"" ))
                , case comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head of
                    Just _ ->
                        [ ( "withChild", "static decl" ) ]

                    Nothing ->
                        []
                ]
    in
    List.concat
        [ guardNonEmpty moduleName "top-level values" topLevelValues
        , guardDuplicatesRich moduleName "top-level values" compSnippetHint topLevelValuePairs
        , guardDuplicates moduleName "top-level types" topLevelTypes
        , guardDuplicates moduleName "AttrCaps row" attrCapsFields
        , guardDuplicates moduleName "SlotCaps row" slotCapsFields
        ]


guardKindModule : Brand -> List String
guardKindModule brand =
    let
        moduleName =
            brand.lib ++ ".Kind"

        -- Static markers: Brand, Ctx, Role (optional), Available, Used, plus the
        -- Supported/Shared re-exports from HtmlIr.Kind.
        -- Only the _sets aliases are CEM-derived (from config `_sets` keys).
        staticNames =
            [ "Brand", "Ctx", "Available", "Used", "Supported", "Shared" ]
                ++ (case brand.aria of
                        Just _ ->
                            [ "Role" ]

                        Nothing ->
                            []
                   )

        setPairs =
            brand.sets |> List.map (\s -> ( s.pascal, "set \"" ++ s.name ++ "\"" ))

        allPairs =
            (staticNames |> List.map (\n -> ( n, "static marker" ))) ++ setPairs

        topLevel =
            allPairs |> List.map Tuple.first

        snippetHint =
            "\"_sets\": { \"<setName>\": ... }"
    in
    List.concat
        [ guardNonEmpty moduleName "top-level" topLevel
        , guardDuplicatesRich moduleName "top-level" snippetHint setPairs
        ]


guardHomeModule : Brand -> String -> List Comp -> List String
guardHomeModule brand home members =
    let
        moduleName =
            brand.lib ++ "." ++ home

        -- Home modules expose member ctors (CEM-derived) plus type aliases
        -- (prefixed, so collision risk is between ctors only).
        ctorPairs =
            members |> List.map (\c -> ( c.ctor, "element \"" ++ c.name ++ "\"" ))

        topLevel =
            ctorPairs |> List.map Tuple.first

        snippetHint =
            "\"_elements\": { \"<tagName>\": \"customCtorName\" }"
    in
    List.concat
        [ guardNonEmpty moduleName "top-level ctors" topLevel
        , guardDuplicatesRich moduleName "top-level ctors" snippetHint ctorPairs
        , guardHomeAttrTypes brand moduleName members
        , guardHomeAttrForms brand moduleName members
        ]


{-| FAIL-LOUD: two members of ONE home module declaring the same attribute name with
DIFFERENT scalar setter types.

This is the guard for the `datetime` regression (elm-typed-html). The manifest typed
`<ins>`/`<del>`'s `datetime` as `string` and `<time>`'s as `number`; all three elements
live in the `Text` home. A home module emits ONE re-exported setter per attribute name
— `reExportBlock` is fed `members |> List.concatMap .attrs |> dedupBy_ .elmName` — so
the two specs were reduced to one and the survivor's type (`Float`) was published for
all three. `<ins datetime="2024-01-01">` became unexpressible with no diagnostic
anywhere: the shared vocabulary agreed with the survivor, so `conflictsWithCanonical`
(the mechanism that DOES handle a cross-MODULE type conflict, by emitting a local
correctly-typed setter) saw nothing to disagree with.

There is no output that could be correct here: one Elm module cannot expose one
`datetime` at two types, and minting a suffixed second name would silently rename a
setter the author never asked for. So the honest response is to refuse to generate and
name the fix.

Keyed on `setterInputType`, not on `Attr.AttrType`, because that is exactly what the
emitted signature reads: enum-vs-enum and enum-vs-free-string both spell `String` at
the setter boundary (their per-token safety lives in `<Lib>.Values`), so they are NOT
a conflict and must not trip this. Only a genuine `Bool`/`Int`/`Float`/`String`
disagreement does.

Cross-MODULE conflicts are deliberately NOT fatal: each element's own module keeps a
locally-typed setter (`conflictsWithCanonical`), and `Model.resolve` emits an info note
naming which type the shared canonical took. A library like @m3e/web legitimately has
them (`value` is `string` on some components and `number` on others).

-}
guardHomeAttrTypes : Brand -> String -> List Comp -> List String
guardHomeAttrTypes brand moduleName members =
    let
        -- ( elmName, setterInputType, "<Element> (<type>)" ) for every member attr,
        -- restricted to names the home module actually re-exports. An attr excluded
        -- from `reExportBlock` (no shared-vocab canonical) is emitted per member under
        -- a prefixed alias, so it cannot collide.
        occurrences =
            members
                |> List.concatMap
                    (\c ->
                        c.attrs
                            |> List.filter (\a -> canonicalFor brand a.elmName /= Nothing)
                            |> List.map (\a -> ( a.elmName, setterInputType a, c.name ))
                    )
    in
    occurrences
        |> List.map (\( n, _, _ ) -> n)
        |> dedup
        |> List.sort
        |> List.filterMap
            (\name ->
                let
                    forName =
                        occurrences |> List.filter (\( n, _, _ ) -> n == name)

                    distinctTypes =
                        forName |> List.map (\( _, t, _ ) -> t) |> dedup |> List.sort
                in
                if List.length distinctTypes < 2 then
                    Nothing

                else
                    Just
                        ("TYPE CONFLICT in module "
                            ++ moduleName
                            ++ ": attribute '"
                            ++ name
                            ++ "' is declared at "
                            ++ String.fromInt (List.length distinctTypes)
                            ++ " different types by elements sharing this home — "
                            ++ (forName
                                    |> List.sortBy (\( _, _, c ) -> c)
                                    |> List.map (\( _, t, c ) -> c ++ " : " ++ t)
                                    |> String.join ", "
                               )
                            ++ ". One module cannot expose one setter at two types, so"
                            ++ " generation stops rather than silently publishing one of them"
                            ++ " (the elm-typed-html `datetime` regression). Fix the manifest"
                            ++ " `type.text` if the elements really do agree; else force one"
                            ++ " with `attrTypes`, give one element a distinct setter name with"
                            ++ " `_renames`, or move it to another `home`."
                        )
            )


{-| FAIL-LOUD: two members of ONE home module declaring the same attribute name at
DIFFERENT attribute-vs-property FORMS.

The `datetime` guard above, transposed from TYPE to FORM — and it exists because
`_controlled`'s element scope made the situation reachable. A home module emits ONE
re-exported setter per attribute name (`reExportBlock` is fed
`members |> List.concatMap .attrs |> dedupBy_ .elmName`), so if `<input>` and
`<progress>` shared a home, `dedupBy_` would keep whichever the manifest lists first
and publish its FORM for both. Whichever way that fell, one of the two elements would
get a setter that writes the wrong kind of fact — a stale content attribute on the
controlled input, or an IDL-coercing property write on the numeric progress bar. The
type checker sees nothing wrong either way, which is precisely the failure mode worth
refusing.

Cross-MODULE form splits are the normal, supported case and are NOT fatal: the shared
canonical takes the PROPERTY form and each content-attribute element keeps a local
setter (`divergesFromCanonical`), with an info note from `Model.resolve`. Only ONE
module holding both is unrepresentable.

-}
guardHomeAttrForms : Brand -> String -> List Comp -> List String
guardHomeAttrForms brand moduleName members =
    let
        formLabel a =
            if emitsAsProperty a then
                "property"

            else
                "attribute"

        -- Restricted to names the home module actually re-exports, for the same reason
        -- `guardHomeAttrTypes` restricts: an attr with no shared-vocab canonical is
        -- emitted per member under a prefixed alias, so it cannot collide.
        occurrences =
            members
                |> List.concatMap
                    (\c ->
                        c.attrs
                            |> List.filter (\a -> canonicalFor brand a.elmName /= Nothing)
                            |> List.map (\a -> ( a.elmName, formLabel a, c.name ))
                    )
    in
    occurrences
        |> List.map (\( n, _, _ ) -> n)
        |> dedup
        |> List.sort
        |> List.filterMap
            (\name ->
                let
                    forName =
                        occurrences |> List.filter (\( n, _, _ ) -> n == name)

                    distinctForms =
                        forName |> List.map (\( _, f, _ ) -> f) |> dedup |> List.sort
                in
                if List.length distinctForms < 2 then
                    Nothing

                else
                    Just
                        ("FORM CONFLICT in module "
                            ++ moduleName
                            ++ ": attribute '"
                            ++ name
                            ++ "' is a DOM property on some members of this home and a content"
                            ++ " attribute on others — "
                            ++ (forName
                                    |> List.sortBy (\( _, _, c ) -> c)
                                    |> List.map (\( _, f, c ) -> c ++ " : " ++ f)
                                    |> String.join ", "
                               )
                            ++ ". One module cannot expose one setter in two forms, and the"
                            ++ " wrong one is a silent runtime bug rather than a type error, so"
                            ++ " generation stops. Fix by giving the elements different `home`"
                            ++ " modules, or by aligning them — widen/narrow the attribute's"
                            ++ " `_controlled` `elements` scope, or set the element's"
                            ++ " `attrForm`."
                        )
            )


guardCoerceModule : Brand -> List String
guardCoerceModule brand =
    if List.isEmpty brand.coercions then
        -- Coerce module is omitted when empty; no guard needed.
        []

    else
        let
            moduleName =
                brand.lib ++ ".Coerce"

            -- Coerce function names come from `_coerce` config; purely config-driven.
            fnPairs =
                brand.coercions |> List.map (\c -> ( c.name, "coerce \"" ++ c.name ++ "\"" ))

            topLevel =
                fnPairs |> List.map Tuple.first

            snippetHint =
                "\"_coerce\": change the `name` field in the coerce entry"
        in
        List.concat
            [ guardNonEmpty moduleName "top-level" topLevel
            , guardDuplicatesRich moduleName "top-level" snippetHint fnPairs
            ]


guardActionModule : Brand -> List String
guardActionModule brand =
    case brand.actions of
        Nothing ->
            -- Action module is omitted when there are no actions; no guard needed.
            []

        Just roster ->
            let
                moduleName =
                    brand.lib ++ ".Action"

                -- Static names (CEM-independent); never collide with each other.
                -- Exempted from rich check; listed for non-empty assertion only.
                staticNames =
                    [ "Action", "LinkSpec", "link", "linkWith", "none", "onClick", "remove", "toAttrs", "wrapContent" ]

                -- CEM-derived: wrapper ctor names from the action roster.
                wrapperPairs =
                    (roster.forWrappers |> List.map (\w -> ( w.ctor, "action wrapper \"" ++ w.ctor ++ "\"" )))
                        ++ (roster.nullaryWrappers |> List.map (\w -> ( w.ctor, "nullary action \"" ++ w.ctor ++ "\"" )))

                allPairs =
                    (staticNames |> List.map (\n -> ( n, "static decl" ))) ++ wrapperPairs

                topLevel =
                    allPairs |> List.map Tuple.first

                snippetHint =
                    "change the `ctor` field in the action roster entry"
            in
            List.concat
                [ guardNonEmpty moduleName "top-level" topLevel
                , guardDuplicatesRich moduleName "top-level" snippetHint wrapperPairs
                ]


guardAriaModule : Brand -> List String
guardAriaModule brand =
    case brand.aria of
        Nothing ->
            -- Aria module is omitted when there is no aria config; no guard needed.
            []

        Just aria ->
            let
                moduleName =
                    brand.lib ++ ".Aria"

                roleTokenPairs =
                    aria.roles
                        |> List.sort
                        |> List.map (\r -> ( roleName r, "role token \"" ++ r ++ "\"" ))

                roleTokenNames =
                    aria.roles |> List.map roleName

                stateTokenNames_ =
                    aria.states
                        |> List.concatMap Tuple.second
                        |> List.sort
                        |> List.foldl
                            (\v acc ->
                                if List.member v acc then
                                    acc

                                else
                                    acc ++ [ v ]
                            )
                            []

                stateTokenName v =
                    let
                        n =
                            Naming.safeField (Naming.camel v)
                    in
                    if List.member n roleTokenNames then
                        n ++ "Value"

                    else
                        n

                stateTokenPairs =
                    stateTokenNames_ |> List.map (\v -> ( stateTokenName v, "state token \"" ++ v ++ "\"" ))

                allPairs =
                    roleTokenPairs ++ stateTokenPairs

                topLevel =
                    allPairs |> List.map Tuple.first

                snippetHint =
                    "\"_aria\": { \"roles\": [...] } — check for duplicate role/state token names"
            in
            List.concat
                [ guardNonEmpty moduleName "top-level" topLevel
                , guardDuplicatesRich moduleName "top-level" snippetHint allPairs
                ]



-- SHARED RENDERING


doc : String -> String
doc text =
    "{-| " ++ text ++ "\n-}"


handlerName : Brand -> Cem.Event -> String
handlerName brand event =
    case event.setter of
        -- A config `eventPayloads` annotation names the setter/capability
        -- explicitly (e.g. `input`'s `change` event → `onCheck`). This lets the
        -- SAME raw event name resolve to different setters on different elements
        -- (input.change → onCheck, select.change → onChange).
        Just s ->
            s

        Nothing ->
            -- K4: use the pre-resolved handler name from the brand model. On collision
            -- between a lossless native event and a prefix-stripped brand event, the
            -- brand event reverts to its full-prefix form (e.g. onWaError). The
            -- resolution lives in Brand.resolvedEventHandlers (computed in Model.resolve).
            Dict.get event.name brand.resolvedEventHandlers
                |> Maybe.withDefault ("on" ++ Naming.pascal (String.replace brand.eventPrefix "" event.name))


{-| The closed-vocabulary payload decoder: the Elm payload type and the baked
`Json.Decode` expression for each standard native-control decoder.
-}
payloadTypeAndDecoder : Cem.Payload -> ( String, String )
payloadTypeAndDecoder payload =
    case payload of
        Cem.TargetValue ->
            ( "String", "Json.Decode.at [ \"target\", \"value\" ] Json.Decode.string" )

        Cem.TargetChecked ->
            ( "Bool", "Json.Decode.at [ \"target\", \"checked\" ] Json.Decode.bool" )


{-| Distinct event SETTERS across the whole brand, deduped by resolved setter
name (`handlerName`), then ordered by raw event name to preserve the emitted
order for unannotated brands. Unlike `brand.sharedEvents` (deduped by raw event
NAME), this keeps two setters that share one raw event — e.g. `onCheck` and
`onChange` both listening on `change` — which is what payload annotations need.
For brands with no annotations this is byte-identical to `brand.sharedEvents`.
-}
distinctSetterEvents : Brand -> List Cem.Event
distinctSetterEvents brand =
    brand.comps
        |> List.concatMap .events
        -- Prefer the ANNOTATED occurrence when several elements share one setter
        -- name: a single shared Events module gives each setter ONE shape, so an
        -- element that leaves the event bare (e.g. select's `input`) still adopts
        -- the payload-typed setter another element annotated (input's `input`).
        -- Stable sort keeps unannotated brands' order byte-identical.
        |> List.sortBy
            (\ev ->
                if ev.payload == Nothing then
                    1

                else
                    0
            )
        |> dedupeBy (handlerName brand)
        |> List.sortBy .name


dedupeBy : (a -> comparable) -> List a -> List a
dedupeBy key xs =
    xs
        |> List.foldl
            (\x ( seen, acc ) ->
                let
                    k =
                        key x
                in
                if List.member k seen then
                    ( seen, acc )

                else
                    ( k :: seen, x :: acc )
            )
            ( [], [] )
        |> Tuple.second
        |> List.reverse


markerName : Marker -> String
markerName m =
    case m of
        MBrand ->
            "Brand"

        MShared ->
            "Shared"


kindRow : List KindField -> String
kindRow fields =
    "{ "
        ++ (fields |> List.map (\f -> f.field ++ " : " ++ markerName f.marker) |> String.join "\n    , ")
        ++ "\n    }"


{-| Closed row rendered on one line when it has a single field.
-}
kindRowCompact : List KindField -> String
kindRowCompact fields =
    case fields of
        [ f ] ->
            "{ " ++ f.field ++ " : " ++ markerName f.marker ++ " }"

        _ ->
            kindRow fields


supportedRow : List String -> String
supportedRow fields =
    "{ "
        ++ (fields |> List.map (\f -> f ++ " : Supported") |> String.join "\n    , ")
        ++ "\n    }"


capsRecord : String -> List String -> String
capsRecord marker fields =
    case fields of
        [] ->
            "{}"

        _ ->
            "{ "
                ++ (fields |> List.map (\f -> f ++ " : " ++ marker) |> String.join "\n    , ")
                ++ "\n    }"


exposeBlock : List (List String) -> String
exposeBlock groups =
    let
        gs =
            groups |> List.filter (not << List.isEmpty)
    in
    "    ( "
        ++ (gs |> List.map (String.join ", ") |> String.join "\n    , ")
        ++ "\n    )"


docsBlock : List (List String) -> String
docsBlock groups =
    groups
        |> List.filter (not << List.isEmpty)
        |> List.map (\g -> "@docs " ++ String.join ", " g)
        |> String.join "\n"



-- COMPONENT ATTRS ROW


{-| The component's closed capability field list: globals + CEM attrs + event
handlers, sorted.
-}
attrsFields : Brand -> Comp -> List String
attrsFields brand comp =
    (List.map .capName brand.globals
        ++ List.map .capName comp.attrs
        ++ List.map (handlerName brand) comp.events
    )
        |> List.sort


nonEnumAttrs : Comp -> List Attr.AttrSpec
nonEnumAttrs comp =
    comp.attrs |> List.filter (not << isEnumSpec)


{-| `main` follows elm/html's `main_` convention everywhere a declaration name
is minted from it (ctor handled in Model; this covers ARIA role names).
-}
roleName : String -> String
roleName r =
    case Naming.safeField (Naming.camel r) of
        "main" ->
            "main_"

        other ->
            other


{-| An enum token string as a safe Elm identifier / record-field name WITH renames applied.

Applies `_renames._tokens` config overrides FIRST (e.g. "AUTO" -> "autoUpper");
then delegates to `Naming.tokenIdent` which applies the K1 unconditional rule:
a leading-`_` token like `"_top"` maps to `"top_"` (not `"top"`). All other
tokens go through the standard camel -> safeField chain. The raw token payload
passed to `Ir.token` stays unchanged.

-}
tokenIdentResolved : Brand -> String -> String
tokenIdentResolved brand rawToken =
    Dict.get rawToken brand.tokenRenames
        |> Maybe.withDefault (Naming.tokenIdent rawToken)


{-| Legacy: enum token string as a safe Elm identifier, no rename support.
-}
tokenIdent : String -> String
tokenIdent =
    Naming.tokenIdent


{-| The STRING an enum token renders to — what `Ir.token` carries, and therefore what
reaches the DOM attribute.

The identity for every token that came from an `AEnum`, which is all of them unless a
config `attrTypes` MAP override asked for a token whose Elm name differs from its HTML
value (`{"always": "true"}` mints `Values.always = Ir.token "true"`). See
`Brand.tokenValues`, which is where the map is built and where "one token, one string"
is enforced.

This is the exact mirror of `tokenIdentResolved`: that one resolves the IDENTIFIER and
leaves the payload alone, this one resolves the PAYLOAD and leaves the identifier
alone. Both are needed, and confusing them is silent: swapping them would name every
token after the string it emits, collapsing `always`/`never` back onto `true`/`false`.

The `withDefault` is not defensive — an `AEnum` token is a genuine identity pair, and
`Model` records it as such, so the lookup succeeds for every token a `Brand` carries.
It is here so this function is total over any raw string a caller has to hand.

-}
tokenValueOf : Brand -> String -> String
tokenValueOf brand rawToken =
    Dict.get rawToken brand.tokenValues
        |> Maybe.withDefault rawToken


{-| Enum portmanteau globals: for each enum ATTRIBUTE and each of its VALUES a
`<attrName><ValueName>` identifier (camelCase, e.g. `variant` + `Filled` →
`variantFilled`, `shape` + `Rounded` → `shapeRounded`), bound to the SAME open
row `Value { v | <value> : Supported }` as the bare token. Purely additive to
the bare tokens; it exists for IDE discovery — type `variant` and autocomplete
lists every valid variant value.

`taken` is the set of value names already claimed in the module (bare tokens,
union aliases). A portmanteau whose name collides with a taken name — or with an
earlier portmanteau — is dropped, so the bare token always wins and the Values
guard never sees a duplicate. Brand-wide token-ident collisions are already
failed loudly by `guardValuesModule`, so within one attribute every value has a
distinct ident and thus a distinct portmanteau.

-}
enumPortmanteaus :
    Brand
    -> List String
    -> List { name : String, attr : String, token : String, ident : String }
enumPortmanteaus brand taken =
    brand.unions
        |> List.sortBy .elmName
        |> List.concatMap (\u -> u.tokens |> List.sort |> List.map (\t -> ( u.elmName, t )))
        |> List.foldl
            (\( attr, t ) ( seen, acc ) ->
                let
                    ident =
                        tokenIdentResolved brand t

                    name =
                        attr ++ Naming.capitalize ident
                in
                if List.member name seen then
                    ( seen, acc )

                else
                    ( name :: seen
                    , acc ++ [ { name = name, attr = attr, token = t, ident = ident } ]
                    )
            )
            ( taken, [] )
        |> Tuple.second


{-| Enum portmanteau ATTRIBUTES: for each enum ATTRIBUTE and each of its VALUES a
nullary `<attrName><ValuePascal>` identifier in `<Lib>.Attributes`, pre-applying
the token value into the attribute body.

  - `variantRainbow : Attr { c | variant : Supported } msg`
  - `variantRainbow = Ir.attribute "variant" "rainbow"`

Naming matches the existing `MV.variantRainbow` value-alias convention so `MA` and
`MV` identifiers align. One portmanteau per (attr, token) pair; collisions with
already-taken names are dropped (the enum setter wins, bare tokens in `Values` win).

`taken` is the set of names already claimed in `<Lib>.Attributes` (globals,
plain attrs, companions, variants, enum setters).

-}
enumAttrPortmanteaus :
    Brand
    -> List String
    -> List { name : String, capName : String, htmlName : String, tokenValue : String }
enumAttrPortmanteaus brand taken =
    brand.unions
        |> List.filter (\u -> not (isGlobalName brand u.elmName))
        |> List.sortBy .elmName
        |> List.concatMap
            (\u ->
                let
                    htmlName =
                        brand.sharedAttrs
                            |> List.filter (\a -> a.elmName == u.elmName)
                            |> List.head
                            |> Maybe.map .htmlName
                            |> Maybe.withDefault u.elmName
                in
                u.tokens
                    |> List.sort
                    |> List.map
                        (\t ->
                            { name = u.elmName ++ Naming.capitalize (tokenIdentResolved brand t)
                            , capName = u.elmName
                            , htmlName = htmlName
                            , tokenValue = tokenValueOf brand t
                            }
                        )
            )
        |> List.foldl
            (\p ( seen, acc ) ->
                if List.member p.name seen then
                    ( seen, acc )

                else
                    ( p.name :: seen, acc ++ [ p ] )
            )
            ( taken, [] )
        |> Tuple.second


{-| Design-C loose slot placers for the general `M3e` surface.

Computes the DISTINCT set of slot names across all `brand` comps (excluding the
`"unnamed"` default slot), deduplicated by their Elm identifier
(`"slot" ++ Naming.capitalize (Naming.camel name)`).

When two DIFFERENT HTML slot strings map to the SAME identifier (a camel
collision), the pair is returned in the second element so the caller can FAIL
generation loudly via the guard machinery. Identical slot names on different
components collapse to ONE placer (the intended behaviour — breadth loss is
accepted per Jack's decision).

-}
looseSlotPlacers :
    Brand
    -> { placers : List { ident : String, htmlName : String }, collisions : List { ident : String, htmlNames : List String } }
looseSlotPlacers brand =
    let
        -- Collect (ident, htmlSlotName) pairs across all comps, excluding "unnamed".
        rawPairs =
            brand.comps
                |> List.concatMap
                    (\c ->
                        c.slots
                            |> List.filterMap
                                (\s ->
                                    if s.name == "unnamed" then
                                        Nothing

                                    else
                                        Just
                                            { ident = "slot" ++ Naming.capitalize (Naming.camel s.name)
                                            , htmlName = s.name
                                            }
                                )
                    )

        -- Group by ident; collect all distinct htmlNames for each ident.
        grouped =
            rawPairs
                |> List.sortBy .ident
                |> List.foldl
                    (\pair acc ->
                        case List.filter (\( k, _ ) -> k == pair.ident) acc of
                            [] ->
                                acc ++ [ ( pair.ident, [ pair.htmlName ] ) ]

                            _ ->
                                acc
                                    |> List.map
                                        (\( k, vs ) ->
                                            if k == pair.ident then
                                                ( k
                                                , if List.member pair.htmlName vs then
                                                    vs

                                                  else
                                                    vs ++ [ pair.htmlName ]
                                                )

                                            else
                                                ( k, vs )
                                        )
                    )
                    []
    in
    grouped
        |> List.foldl
            (\( ident, htmlNames ) { placers, collisions } ->
                case htmlNames of
                    [ single ] ->
                        { placers = placers ++ [ { ident = ident, htmlName = single } ]
                        , collisions = collisions
                        }

                    many ->
                        -- Two different HTML slot strings camel-collapsed to the same
                        -- identifier — FAIL loudly.
                        { placers = placers
                        , collisions = collisions ++ [ { ident = ident, htmlNames = many } ]
                        }
            )
            { placers = [], collisions = [] }


{-| Payload Elm type + Json.Decode primitive for a typed event override.
`date` decodes the ISO string (parse app-side).
-}
overrideTypes : String -> ( String, String )
overrideTypes ty =
    case ty of
        "int" ->
            ( "Int", "Json.Decode.int" )

        "float" ->
            ( "Float", "Json.Decode.float" )

        "number" ->
            ( "Float", "Json.Decode.float" )

        "bool" ->
            ( "Bool", "Json.Decode.bool" )

        _ ->
            ( "String", "Json.Decode.string" )


{-| Is this member's own classification an enum?

Delegates to `Attr.isTokenEnum` rather than matching `Attr.AEnum` here. Every filter
in this module that has to keep an enum out of the plain-setter path goes through
this one predicate for the same reason `Attr.setterType` is the one definition of
"same type": a local `case … of AEnum _ ->` at each site is how `AEnumMap` came to be
matched at ZERO of them and emitted as a bare `String` setter.

-}
isEnumSpec : Attr.AttrSpec -> Bool
isEnumSpec a =
    Attr.isTokenEnum a.type_


{-| The brand-wide union spec for an attr name, when it is an enum anywhere.
-}
unionFor : Brand -> String -> Maybe EnumSpec
unionFor brand elmName =
    brand.unions |> List.filter (\e -> e.elmName == elmName) |> List.head


{-| Every global the brand declares, both row shapes.

The DEFAULT reading of `_globals`. Only two consumers want `brand.globals` alone,
and both are the closed-row question itself: `attrsFields` (which _is_ the closed
`Attrs` alias) and `attrPipes` (whose `with<Field>` pipes consume a capability
field an open global never has). Everything else — namespace collision checks,
union minting, the exposing list, `Review.Facts` — is asking "is this a global?",
to which an open global's answer is yes.

Getting this backwards is quiet rather than loud, which is why it is one function:
an open enum global reaching `enumAttrs` is a SECOND declaration of a name the
globals block already emitted, and a name missing from `globalNames` is a setter
that compiles but is never exposed.

-}
allGlobals : Brand -> List Attr.AttrSpec
allGlobals brand =
    brand.globals ++ brand.openGlobals


{-| Is this identifier one of the brand's `_globals`?

Globals share the `<Lib>.Attributes` namespace with the shared vocabulary and (for
an ENUM global) the `brand.unions` roster, so every place that walks `unions` to
emit or count a setter has to ask whether the globals block already owns it.

Both row shapes, because `brand.unions` is where an enum global's `<Lib>.Values`
row is minted REGARDLESS of row shape (`Model.globalEnums`). So an open enum
global is in `unions` too, and a check that missed it would let `enumAttrs` emit
a duplicate setter under the same name — in the same module, from the same list.

-}
isGlobalName : Brand -> String -> Bool
isGlobalName brand elmName =
    allGlobals brand |> List.any (\g -> g.elmName == elmName)


{-| Does the brand have at least one ENUM global?

Such a global's setter is annotated `Value <Lib>.Values.<Row>`, so `<Lib>.Values`
and `HtmlIr.Value` become mandatory imports in `<Lib>.Attributes` and in every
per-component module (which gets a `with<Global>` pipe for it) — even when the
brand has no enum ATTRIBUTE anywhere and would otherwise import neither.

-}
hasEnumGlobal : Brand -> Bool
hasEnumGlobal brand =
    allGlobals brand |> List.any (\g -> unionFor brand g.elmName /= Nothing)


{-| The canonical spec for an attr name (first in brand.sharedAttrs).
-}
canonicalFor : Brand -> String -> Maybe Attr.AttrSpec
canonicalFor brand elmName =
    brand.sharedAttrs |> List.filter (\a -> a.elmName == elmName) |> List.head


{-| Does this member's scalar type disagree with the brand-canonical setter?
(The capability ROW is type-free — `value : Supported` — so a locally-typed
setter is sound; only DELEGATION would be ill-typed.)
-}
conflictsWithCanonical : Brand -> Attr.AttrSpec -> Bool
conflictsWithCanonical brand a =
    case canonicalFor brand a.elmName of
        Just c ->
            setterInputType c /= setterInputType a

        Nothing ->
            False


{-| Does this member's setter DIVERGE from the brand-canonical one in any way that
makes `<attr> = A.<attr>` the wrong body — not just an ill-typed one?

Two ways it can, and delegation is wrong for both:

  - the SETTER TYPE differs (`conflictsWithCanonical`) — delegation would not compile;
  - the attribute-vs-PROPERTY FORM differs — delegation compiles and is SILENTLY
    WRONG. This is the case `_controlled`'s element scope creates: `value` is the live
    DOM property of an `<input>` and a reflected content attribute of a `<button>`,
    and the shared canonical takes the PROPERTY form (see `Model.sharedAttrs`), so
    `TypedHtml.Button.value` delegating to it would quietly stop serializing to
    server-rendered markup — a property write on a node that has no live/default split
    to justify one, past a type checker that has nothing to object to. It fell the
    other way once, and then `TypedHtml.Input.value` delegating to a content-attribute
    canonical handed the controlled input a `defaultValue` write — issue #41,
    reintroduced through the re-export layer. Either direction needs a local setter;
    that is why this predicate is about DIVERGENCE and not about which form won.

This is deliberately a SUPERSET of `conflictsWithCanonical` rather than a widening of
it: that function answers "would delegation be ill-typed", which is what
`guardHomeAttrTypes` and `Model`'s conflict notes are about, and it is named for that.
Every DELEGATION site asks this one instead. (The comments at those sites already
claimed form was covered, back when only the type actually was.)

A third divergence — the same `elmName` carrying a different DOM NAME on two
components, via a CEM `fieldName` on one and not the other — is knowingly NOT tested
here. It is silently wrong for exactly the same reason, but no brand in this repo's
fixtures or downstreams exhibits it, and folding it in would move emitted bytes for a
case nobody has yet hit. Add it with its own fixture, not as a drive-by.

-}
divergesFromCanonical : Brand -> Attr.AttrSpec -> Bool
divergesFromCanonical brand a =
    -- Literally `conflictsWithCanonical` plus the form clause, and it CALLS it rather
    -- than restating `setterInputType c /= setterInputType a`. A second copy of "same
    -- type" is precisely the `datetime` bug — three code paths that disagreed about
    -- what a type conflict is.
    conflictsWithCanonical brand a
        || (case canonicalFor brand a.elmName of
                Just c ->
                    c.attrForm /= a.attrForm

                Nothing ->
                    False
           )


{-| The `Json.Encode.*` call that lifts a scalar setter's `value_` into the JSON
value a DOM property expects, chosen by the attribute's classified type.
-}
propEncoder : Attr.AttrType -> String
propEncoder t =
    case t of
        Attr.ABool ->
            "Json.Encode.bool value_"

        Attr.ANumber ->
            "Json.Encode.float value_"

        Attr.AInt ->
            "Json.Encode.int value_"

        _ ->
            "Json.Encode.string value_"


{-| Does a scalar setter emit as a DOM **property** (`Ir.property`) rather than a
content attribute?

Exactly one thing decides this: the spec's `attrForm`, which `Generate.Phantom.Model`
sets from the brand's `_controlled` roster and the per-component `attrForm` override.
This function used to be `List.member a.htmlName [ "value", "checked", "selected" ]` —
a second, hardcoded mechanism that shadowed the config one (`Attr.applyForm`, which
nothing called). One decision, one home.

Every other scalar — including a reflected scalar the CEM links to a backing property
via `fieldName` — emits as an **attribute**: setting the attribute reflects to the
property AND serializes to SSR, so a separate property write is redundant (and left
the value invisible to server-rendered markup — issue #41).

-}
emitsAsProperty : Attr.AttrSpec -> Bool
emitsAsProperty a =
    a.attrForm == Attr.AsProperty


{-| Does a module emitting LOCAL setters for `specs` need `import Json.Encode`?

Two things in a local setter body reach for it: a `Value <Row>` enum setter for an
attribute that also has a brand union, and a `Ir.property` write (`propEncoder`). A
module whose members all DELEGATE needs neither, because the encoding happens in
`<Lib>.Attributes`.

The property clause is `divergesFromCanonical` AND `emitsAsProperty`, not just the
first. Divergence is what makes the setter LOCAL; the FORM is what decides whether its
body mentions `Json.Encode` at all. The looser condition was harmless only as long as
divergence implied the property form, and it stopped implying it when the shared
canonical became the property form (`Model.sharedAttrs`): the elements that diverge from
it now are the content-attribute ones — `<button>`, `<data>`, `<option>` each keep a
local `Ir.attribute "value"` — so every one of their home modules got an import nothing
in the file used.

Shared by the per-component and per-home emitters rather than restated at each: the two
carried this condition spelled out twice, identically, and that is how a generated
import ends up present in one surface and absent in the other.

-}
needsJsonEncodeImport : Brand -> List Attr.AttrSpec -> Bool
needsJsonEncodeImport brand specs =
    specs
        |> List.any
            (\a ->
                (unionFor brand a.elmName /= Nothing && not (isEnumSpec a))
                    || (divergesFromCanonical brand a && emitsAsProperty a)
            )


{-| The brand's `_controlled` entry for a spec, if the roster covers it.
-}
controlledFor : Brand -> Attr.AttrSpec -> Maybe M.Controlled
controlledFor brand a =
    brand.controlled |> List.filter (\c -> c.htmlName == a.htmlName) |> List.head


{-| The RESYNC caveat, appended to a controlled property's docs when the roster says
it cannot resync (`"resyncs": false`).

`elm/virtual-dom`'s controlled-input machinery is hardcoded to two NAMES.
`_VirtualDom_diffFacts` re-emits a fact whose value is unchanged only for `value` and
`checked`, and `_VirtualDom_applyFacts` writes-when-the-DOM-differs only for those
two. `organizeFacts` stores PROP facts as raw JS values, so for every other name
`true === true` short-circuits the diff and the setter is skipped forever.

Consequence, and the reason this text is mandatory rather than nice-to-have: the
property form fixes INERTNESS (the content attribute only ever set the DEFAULT state)
but NOT resync. Once the user changes the selection, or unmutes with the native
controls, re-rendering the same model value cannot push the DOM back.

-}
resyncCaveat : M.Controlled -> String
resyncCaveat c =
    let
        listen =
            case c.resyncWith of
                Just ev ->
                    "a `" ++ ev ++ "` handler"

                Nothing ->
                    "a handler for the element's own change event"
    in
    "\n\nCAVEAT — this setter cannot RESYNC. `elm/virtual-dom` only re-forces an"
        ++ " unchanged controlled property for the names `value` and `checked`; `"
        ++ c.htmlName
        ++ "` is compared by identity, so re-rendering the same model value after the user"
        ++ " has changed it through the element's own UI will NOT push it back to the DOM."
        ++ " Keep the model in sync with "
        ++ listen
        ++ "."


{-| The elements whose `<attr>` takes the PROPERTY form, paired with the qualified
setter that reaches it. Empty when nothing in the brand does.

Used to point a caller reading a CONTENT-ATTRIBUTE setter at the live one. That
signpost is load-bearing rather than decorative: an element-scoped `_controlled` entry
leaves the out-of-scope elements on the content-attribute form in their own modules
(`TypedHtml.Button.value`, `TypedHtml.Select.value`), and nothing else in the emitted
output would say that `TypedHtml.Input.value` is the one that keeps tracking after the
user types (issue #41).

It does NOT describe the shared `<Lib>.Attributes` setter, which takes the PROPERTY
form when the brand's forms are split (see `Model.sharedAttrs`) and so is already the
live one.

-}
propertyFormOwners : Brand -> Attr.AttrSpec -> List ( String, String )
propertyFormOwners brand a =
    brand.comps
        |> List.filterMap
            (\comp ->
                if comp.attrs |> List.any (\x -> x.elmName == a.elmName && emitsAsProperty x) then
                    Just
                        ( "<" ++ comp.tag ++ ">"
                        , brand.lib ++ "." ++ (memberRef brand comp).module_ ++ "." ++ a.elmName
                        )

                else
                    Nothing
            )
        |> dedupBy_ Tuple.second
        |> List.sortBy Tuple.second


{-| The doc string for a controlled property's setter: the CEM description plus the
live-vs-default note, plus the resync caveat when the roster denies resync.

Keyed on the emitted FORM, not on roster membership: an attribute a component opted
back out of (`attrForm: { "<attr>": "attribute" }`), or one on an element outside the
roster entry's `elements` scope, writes the content attribute — so promising the caller
a live property would be a lie.

The attribute-form arm is not silent, though. When the SAME name is the live property
somewhere else in the brand, it names the elements and the setters that reach it: the
whole hazard of a split form is that both setters compile everywhere the capability row
admits them, so the only place the distinction can live is the docs.

-}
controlledDoc : Brand -> Attr.AttrSpec -> String
controlledDoc brand a =
    case
        if emitsAsProperty a then
            controlledFor brand a

        else
            Nothing
    of
        Nothing ->
            case ( controlledFor brand a, propertyFormOwners brand a ) of
                ( Just _, (_ :: _) as owners ) ->
                    Attr.docString a
                        ++ ("\n\nWrites the `" ++ a.htmlName ++ "` CONTENT attribute — correct for every")
                        ++ (" element whose `" ++ a.htmlName ++ "` REFLECTS, and the only form that")
                        ++ " serializes to server-rendered markup."
                        ++ (" It is NOT the live state on "
                                ++ (owners |> List.map Tuple.first |> String.join ", ")
                                ++ ", where the content attribute sets only the element's DEFAULT/initial `"
                                ++ a.htmlName
                                ++ "` and stops taking effect once the user has changed it; use "
                                ++ (owners |> List.map (\( _, ref ) -> "`" ++ ref ++ "`") |> String.join " / ")
                                ++ " for that."
                           )

                _ ->
                    Attr.docString a

        Just c ->
            Attr.docString a
                ++ ("\n\nSets the LIVE DOM property `" ++ Attr.propertyName a ++ "`, not the content attribute.")
                ++ (case c.companion of
                        Just companion ->
                            " The content attribute — the element's INITIAL state, and the only"
                                ++ " form that serializes to server-rendered markup — is `"
                                ++ companion
                                ++ "`."

                        Nothing ->
                            " This element has no backing content attribute for it."
                   )
                ++ (if c.resyncs then
                        ""

                    else
                        resyncCaveat c
                   )


{-| The `default*` companion for one controlled attribute of one brand: the CONTENT
attribute half of HTML's own live/default IDL split (`value` / `defaultValue`,
`checked` / `defaultChecked`, `selected` / `defaultSelected`, `muted` / `defaultMuted`).

It deliberately SHARES the base attribute's capability field (`defaultValue` claims
`{ c | value : Supported }`). Minting `defaultValue : Supported` instead would add a
field to every `Attrs` row in the library for no safety gain: an element that admits
`value` admits its default, and an element that does not admit `value` already rejects
`defaultValue` through the shared row.

-}
companionDecl : Brand -> M.Controlled -> String -> Attr.AttrSpec -> List String
companionDecl brand c companion a =
    let
        docText =
            "Set the `"
                ++ a.htmlName
                ++ "` CONTENT attribute — the element's DEFAULT/initial `"
                ++ a.htmlName
                ++ "`, mirroring HTML's own `"
                ++ companion
                ++ "` IDL attribute."
                ++ " Unlike `"
                ++ a.elmName
                ++ "` (which writes the live DOM property) this one SERIALIZES: it is what"
                ++ " server-rendered markup and `outerHTML` show, and it is what a form reset"
                ++ " restores to."
                ++ (if c.resyncs then
                        ""

                    else
                        " Pair it with `"
                            ++ a.elmName
                            ++ "` for the live state; see that setter's resync caveat."
                   )

        body =
            case a.type_ of
                Attr.ABool ->
                    -- A boolean CONTENT attribute is present/absent: any value at all
                    -- is the true state, so `False` must contribute NO fact (`Ir.none`),
                    -- never `Ir.attribute "muted" "false"`.
                    [ companion ++ " value_ ="
                    , "    if value_ then"
                    , "        Ir.attribute \"" ++ a.htmlName ++ "\" \"\""
                    , ""
                    , "    else"
                    , "        Ir.none"
                    ]

                Attr.ANumber ->
                    [ companion ++ " value_ ="
                    , "    Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromFloat value_)"
                    ]

                Attr.AInt ->
                    [ companion ++ " value_ ="
                    , "    Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromInt value_)"
                    ]

                _ ->
                    [ companion ++ " ="
                    , "    Ir.attribute \"" ++ a.htmlName ++ "\""
                    ]
    in
    [ ""
    , ""
    , doc docText
    , companion ++ " : " ++ setterInputType a ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
    ]
        ++ body


{-| Every `default*` companion earned by a list of specs: the roster entry, its
companion name, and the base spec it mirrors.

`suppressed` names the controlled attributes whose companion must NOT be emitted here
— the per-element `propertyOnly` list, for an element whose live property has no
backing content attribute. `<output>`'s `defaultValue` is a property with no content
attribute at all, and `<textarea>`'s default value is its CHILD TEXT (there is no
`value` content attribute on `<textarea>`), so for those the honest output is nothing
rather than an `Ir.attribute "value"` the browser ignores.

A spec that is in the roster but did NOT take the property form is skipped: either a
per-component `attrForm: { "<attr>": "attribute" }` opt-out or an element outside the
entry's `elements` scope means the plain setter already writes the content attribute,
so a `default*` beside it would be a second setter for the same fact. This is also
what stops the misleading companions the name-only roster used to mint: HTML gives
`HTMLOptionElement` and `HTMLButtonElement` no `defaultValue` IDL attribute at all, so
once `value` is scoped to `<input>` the `defaultValue` beside `<option>`'s `value`
disappears with it — and `<option>`'s own setter keeps writing the content attribute
that element actually wants, under the name HTML gives it.

Enum-typed controlled attributes are skipped: their setter is the `Value <Row>` one,
which this shape does not cover.

-}
companionsFor : Brand -> List String -> List Attr.AttrSpec -> List ( M.Controlled, String, Attr.AttrSpec )
companionsFor brand suppressed specs =
    specs
        |> List.filter emitsAsProperty
        |> List.filterMap
            (\a ->
                case ( controlledFor brand a, isEnumSpec a || unionFor brand a.elmName /= Nothing ) of
                    ( Just c, False ) ->
                        c.companion
                            |> Maybe.andThen
                                (\companion ->
                                    if List.member a.htmlName suppressed then
                                        Nothing

                                    else
                                        Just ( c, companion, a )
                                )

                    _ ->
                        Nothing
            )
        |> List.sortBy (\( _, companion, _ ) -> companion)


{-| Every `_variants` ergonomic setter earned by a list of specs: the roster entry
paired with the BASE spec it is emitted from.

Paired with the base spec because that is what carries the DOM name, the emitted
form (attribute vs property) and — critically — the capability row the variant
claims. `stepAsNumber` is `Float -> Attr { c | step : Supported } msg`: the same row
as `step`, so no element's `Attrs` record grows a field. Same reasoning as
`companionsFor`; see `M.Variant`.

`specs` is whatever surface is being emitted (the shared vocabulary's `plainAttrs`, a
module's re-exported specs), so a variant appears exactly where its base does and
never anywhere its base is absent.

-}
variantsFor : Brand -> List Attr.AttrSpec -> List ( M.Variant, Attr.AttrSpec )
variantsFor brand specs =
    brand.variants
        |> List.filterMap
            (\v ->
                -- Matched on the SETTER name, not the DOM name. See `M.Variant.base`:
                -- several elements can declare one HTML name under DIFFERENT setter names
                -- and therefore different capability rows (`_renames` moves `elmName` and
                -- `capName` together), and a variant belongs to exactly one of those rows.
                -- Filtering on `htmlName` matched them all and let `List.head` pick — an
                -- arbitrary row, silently, which is the `datetime` failure shape. `elmName`
                -- is unique on every surface this is called with (all of them dedupe by
                -- it), so there is nothing left to pick.
                specs
                    |> List.filter (\a -> a.elmName == v.base)
                    |> List.head
                    |> Maybe.map (\a -> ( v, a ))
            )


{-| The expression rendering a variant's `value_` into the attribute's string form.
One arm per `M.VariantInput` constructor — the closed set is the point: config cannot
ask for a renderer that does not exist.
-}
variantRender : M.VariantInput -> String
variantRender input =
    case input of
        M.VFloat ->
            "String.fromFloat value_"

        M.VInt ->
            "String.fromInt value_"

        M.VInts sep ->
            "String.join \"" ++ sep ++ "\" (List.map String.fromInt value_)"


{-| The Elm type a variant's setter takes.
-}
variantInputType : M.VariantInput -> String
variantInputType input =
    case input of
        M.VFloat ->
            "Float"

        M.VInt ->
            "Int"

        M.VInts _ ->
            "List Int"


{-| One `_variants` setter, emitted from its base spec.

It writes the SAME fact as the base setter — same DOM name, same attribute-vs-property
form — differing only in the Elm type it accepts and how that renders to a string. In
particular a variant on a CONTROLLED base goes through `Json.Encode.string`, not
`Json.Encode.float`: `elm/virtual-dom` compares property facts by identity against the
previously-organized raw JS value, so alternating a number fact and a string fact under
one property name across renders would make every diff a false positive. Writing the
same JS type as the base setter keeps `value` / `valueAsNumber` interchangeable
mid-render, and keeps virtual-dom's `value`-and-`checked` resync special-case working.

-}
variantDecl : M.Variant -> Attr.AttrSpec -> List String
variantDecl v a =
    let
        rendered =
            variantRender v.input

        body =
            if emitsAsProperty a then
                [ v.name ++ " value_ ="
                , "    Ir.property \"" ++ Attr.propertyName a ++ "\" (Json.Encode.string (" ++ rendered ++ "))"
                ]

            else
                [ v.name ++ " value_ ="
                , "    Ir.attribute \"" ++ a.htmlName ++ "\" (" ++ rendered ++ ")"
                ]

        docText =
            "Set the `"
                ++ a.htmlName
                ++ "` attribute from "
                ++ (case v.input of
                        M.VInts sep ->
                            "a list of integers, joined with `" ++ sep ++ "`"

                        M.VFloat ->
                            "a number"

                        M.VInt ->
                            "an integer"
                   )
                ++ ". An ergonomic alternative to `"
                ++ a.elmName
                ++ "`, which keeps the spec-correct `"
                ++ setterInputType a
                ++ "` type; this one cannot express every legal value, so reach for `"
                ++ a.elmName
                ++ "` when you need one it cannot. Both claim the same capability, mirroring"
                ++ " HTML's own `value` / `valueAsNumber` split."
    in
    [ ""
    , ""
    , doc docText
    , v.name ++ " : " ++ variantInputType v.input ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
    ]
        ++ body


{-| Controlled attributes whose companion is suppressed for the WHOLE brand: those
where every component declaring the attribute also declares it `propertyOnly`.

Suppression is per element, so the shared `<Lib>.Attributes` companion survives as
long as one element still has a backing content attribute for it; the element that
does not simply never re-exports it.

-}
brandSuppressed : Brand -> List String
brandSuppressed brand =
    brand.controlled
        |> List.filterMap
            (\c ->
                let
                    owners =
                        brand.comps
                            |> List.filter (\comp -> comp.attrs |> List.any (\a -> a.htmlName == c.htmlName))
                in
                if not (List.isEmpty owners) && List.all (\comp -> List.member c.htmlName comp.propertyOnly) owners then
                    Just c.htmlName

                else
                    Nothing
            )


{-| An inline expression applying a member-local setter to `value_`
(parenthesized where needed). Used when delegation to the canonical would be
ill-typed (cross-component scalar conflicts).
-}
setterExpr : Attr.AttrSpec -> String
setterExpr a =
    if emitsAsProperty a then
        -- Controlled attribute → DOM property so it updates after user input.
        "Ir.property \"" ++ Attr.propertyName a ++ "\" (" ++ propEncoder a.type_ ++ ")"

    else
        case ( a.type_, a.reactiveProp ) of
            ( Attr.ABool, _ ) ->
                -- Boolean → attribute present/absent (NEVER a JS property nor
                -- `classList []`), so web components observe it and no sibling
                -- `class` is clobbered.
                "(if value_ then\n        Ir.attribute \"" ++ a.htmlName ++ "\" \"\"\n\n     else\n        Ir.none\n    )"

            ( Attr.ANumber, _ ) ->
                -- Non-controlled number → attribute regardless of a `fieldName`
                -- reflection link: the attribute serializes to SSR and reflects
                -- to the backing property (#41).
                "Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromFloat value_)"

            ( Attr.AInt, _ ) ->
                "Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromInt value_)"

            _ ->
                "Ir.attribute \"" ++ a.htmlName ++ "\" value_"


{-| Canonical-typed co-located re-exports: each name delegates to (and is
annotated exactly like) the `<Lib>.Attributes` canonical — union-typed when
the attr is an enum anywhere in the brand. Names colliding with the module's
own declarations are skipped (the canonical in `<Lib>.Attributes` remains).
Returns ( exposedNames, sourceLines, needsValuesImport ).

`attrsRef` is the module reference used to reach the `<Lib>.Attributes`
canonical in the emitting module's import scope — the alias `"A"` in the
per-component modules (R4), or the full `<Lib>.Attributes` in the home modules.

`suppressed` is the union of the emitting module's members' `propertyOnly` lists: a
controlled attribute whose `default*` companion must NOT appear here because on those
elements the live property has no backing content attribute.

-}
reExportBlock : Brand -> String -> List String -> List String -> List Attr.AttrSpec -> ( List String, List String, Bool )
reExportBlock brand attrsRef excludeNames suppressed memberSpecs =
    let
        unionOf elmName =
            brand.unions |> List.filter (\e -> e.elmName == elmName) |> List.head

        canon =
            memberSpecs
                |> List.filter (\a -> not (List.member a.elmName excludeNames))
                |> List.filter (\a -> canonicalFor brand a.elmName /= Nothing)
                |> List.sortBy .elmName

        -- The `default*` companions the module's members earn, filtered by the same
        -- exclusion rules as their base setters: only what the shared vocabulary
        -- actually declares, and never a name the module already uses for something
        -- else.
        companions =
            companionsFor brand suppressed canon
                |> List.filter (\( _, n, _ ) -> not (List.member n excludeNames))

        lines =
            canon
                |> List.concatMap
                    (\a ->
                        if unionOf a.elmName /= Nothing || divergesFromCanonical brand a then
                            -- This member's setter differs from the shared canonical
                            -- in TYPE (delegating would be ill-typed) or in
                            -- attribute-vs-property FORM (delegating would compile and
                            -- write the wrong kind of fact — `<input>`'s live `value`
                            -- property vs `<progress>`'s content attribute). Either
                            -- way: emit a LOCAL setter. The row field is `Supported`
                            -- regardless, so this is sound.
                            [ ""
                            , ""
                            , doc (controlledDoc brand a)
                            , a.elmName ++ " : " ++ setterInputType a ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
                            , a.elmName ++ " value_ ="
                            , "    " ++ setterExpr a
                            ]

                        else
                            let
                                sig =
                                    setterInputType a ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
                            in
                            [ ""
                            , ""
                            , doc ("See `" ++ brand.lib ++ ".Attributes." ++ a.elmName ++ "`.")
                            , a.elmName ++ " : " ++ sig
                            , a.elmName ++ " ="
                            , "    " ++ attrsRef ++ "." ++ a.elmName
                            ]
                    )

        companionLines =
            companions
                |> List.concatMap
                    (\( c, n, a ) ->
                        if divergesFromCanonical brand a then
                            -- Same reason as the base setter above: the canonical
                            -- `default*` is emitted from the DOMINANT member's spec, so
                            -- a member that diverges in type or form gets its own. When
                            -- the divergence is the FORM, the canonical `default*` does
                            -- not exist at all (the canonical plain setter already
                            -- writes the content attribute, so `companionsFor` emits no
                            -- companion beside it) — delegating would not even resolve.
                            companionDecl brand c n a

                        else
                            [ ""
                            , ""
                            , doc ("See `" ++ brand.lib ++ ".Attributes." ++ n ++ "`.")
                            , n ++ " : " ++ setterInputType a ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
                            , n ++ " ="
                            , "    " ++ attrsRef ++ "." ++ n
                            ]
                    )

        -- The `_variants` setters the module's members earn, under the same exclusion
        -- rules as the companions.
        variants =
            variantsFor brand canon
                |> List.filter (\( v, _ ) -> not (List.member v.name excludeNames))

        variantLines =
            variants
                |> List.concatMap
                    (\( v, a ) ->
                        if divergesFromCanonical brand a then
                            -- Same reason as the base setter above: the canonical
                            -- variant is emitted from the canonical's spec, so a
                            -- member diverging in type or in attribute-vs-property form
                            -- gets its own rather than delegating. This is what keeps a
                            -- variant on a SCOPED controlled base honest: where `value`
                            -- is a content attribute, `valueAsNumber` must be
                            -- `Ir.attribute "value" (String.fromFloat …)`; where it is
                            -- the live property, `Json.Encode.string (String.fromFloat
                            -- …)` — see `variantDecl` for why the property form goes
                            -- through `string` and never `float`.
                            variantDecl v a

                        else
                            [ ""
                            , ""
                            , doc ("See `" ++ brand.lib ++ ".Attributes." ++ v.name ++ "`.")
                            , v.name ++ " : " ++ variantInputType v.input ++ " -> Attr { c | " ++ a.capName ++ " : Supported } msg"
                            , v.name ++ " ="
                            , "    " ++ attrsRef ++ "." ++ v.name
                            ]
                    )

        needsValues =
            False
    in
    ( (canon |> List.map .elmName)
        ++ (companions |> List.map (\( _, n, _ ) -> n))
        ++ (variants |> List.map (\( v, _ ) -> v.name))
    , lines ++ companionLines ++ variantLines
    , needsValues
    )



-- SHARED BUILD (R3): the pipe-builder mechanics, defined ONCE per brand.
--
-- `<Lib>.Forge.Internal` is the builder forge — the single place a `Builder`'s
-- capability rows are minted/mutated and where its record constructor is
-- exposed, so per-component modules can seed (`init`), advance
-- (`withAttribute`/`withChild`), and close (`toElement`) builders. It is a
-- NEUTRAL core module (NOT the `<Lib>.Build.*` builder surface), so both the
-- component `Internal.Types` modules and the `<Lib>.Build.*` modules depend on
-- it WITHOUT a cycle across the split-package DAG (core ← components ← builder).
-- Untrusted code importing it can forge any capability claim (an echo of the
-- `HtmlIr.Internal` forge decision); the `NoInternalImportOutsideAllowed` fence
-- holds the line. `<Lib>.Build` is the safe surface: opaque `Builder` + the
-- single `toElement`. Per-component `withX` are thin composed aliases over
-- `withAttribute`/`withChild`, and each component's `Builder` is a type alias
-- over `Internal.Builder` with its own closed attribute `row` (so cross-builder
-- composition stays guarded by the phantom `row`).


buildInternalModule : Brand -> Elm.File
buildInternalModule brand =
    let
        lib =
            brand.lib
    in
    file [ lib, "Forge", "Internal" ]
        (String.join "\n"
            [ "module " ++ lib ++ ".Forge.Internal exposing"
            , "    ( Builder(..)"
            , "    , init, withAttribute, withChild, toElement"
            , "    )"
            , ""
            , "{-| The builder forge for the `" ++ lib ++ "` brand — the ONE place a `Builder`'s"
            , "capability rows are minted and its record constructor is exposed. Every"
            , "per-component `build`/`withX`/`toElement` composes these levers; the mechanics"
            , "are defined here exactly once. Untrusted code that imports this module can forge"
            , "any capability claim, exactly like `HtmlIr.Internal` — the"
            , "`NoInternalImportOutsideAllowed` fence is load-bearing."
            , ""
            , "@docs Builder"
            , "@docs init, withAttribute, withChild, toElement"
            , ""
            , "-}"
            , ""
            , "import HtmlIr.Attribute exposing (Attr)"
            , "import HtmlIr.Element exposing (Element)"
            , "import HtmlIr.Internal as Ir"
            , "import HtmlIr.Node exposing (Node)"
            , ""
            , ""
            , "{-| The shared pipe-builder. `attrCaps`/`slotCaps` are phantom write-once"
            , "capability rows; `row` is the host element's closed attribute row; `accepts` is"
            , "the element-kind phantom produced on close; `tag` is the custom-element tag"
            , "closed over at `init`. Each component aliases this with its own `row` and"
            , "`accepts = (Is s)`, and exposes narrowed `withX` setters."
            , "-}"
            , "type Builder row attrCaps slotCaps accepts msg"
            , "    = Builder"
            , "        { tag : String"
            , "        , attrs : List (Attr row msg)"
            , "        , children : List (Node msg)"
            , "        }"
            , ""
            , ""
            , "{-| Seed a builder with its tag, initial attributes, and initial children."
            , "-}"
            , "init : String -> List (Attr row msg) -> List (Node msg) -> Builder row attrCaps slotCaps accepts msg"
            , "init tag attrs children ="
            , "    Builder { tag = tag, attrs = attrs, children = children }"
            , ""
            , ""
            , "{-| Prepend one attribute, advancing the attribute-capability row (phantom)."
            , "-}"
            , "withAttribute : Attr row msg -> Builder row attrCapsIn slotCaps accepts msg -> Builder row attrCapsOut slotCaps accepts msg"
            , "withAttribute attr (Builder b) ="
            , "    Builder { b | attrs = attr :: b.attrs }"
            , ""
            , ""
            , "{-| Prepend one child node, advancing the slot-capability row (phantom)."
            , "-}"
            , "withChild : Node msg -> Builder row attrCaps slotCapsIn accepts msg -> Builder row attrCaps slotCapsOut accepts msg"
            , "withChild child (Builder b) ="
            , "    Builder { b | children = child :: b.children }"
            , ""
            , ""
            , "{-| Close the builder into an element — defined ONCE for the brand. Attributes"
            , "and children are reversed so they render in the order they were piped on."
            , "-}"
            , "toElement : Builder row attrCaps slotCaps accepts msg -> Element accepts admittedBy msg"
            , "toElement (Builder b) ="
            , "    Ir.fromNode (Ir.node b.tag (List.reverse b.attrs) (List.reverse b.children))"
            , ""
            ]
        )


buildModule : Brand -> List Comp -> Elm.File
buildModule brand comps =
    let
        lib =
            brand.lib

        isAliasNames =
            comps |> List.map (\c -> Naming.pascal c.name ++ "Is")

        isAliases =
            comps
                |> List.concatMap
                    (\c ->
                        let
                            isName =
                                Naming.pascal c.name ++ "Is"

                            aliasFrom =
                                lib ++ ".Build." ++ c.name ++ ".Is"
                        in
                        [ ""
                        , ""
                        , doc ("The `" ++ c.name ++ "` kind phantom — annotate with `List (Element (" ++ isName ++ " s) admittedBy msg)`.")
                        , "type alias " ++ isName ++ " s ="
                        , "    " ++ aliasFrom ++ " s"
                        ]
                    )
    in
    file [ lib, "Build" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Build exposing"
                  , exposeBlock
                        [ [ "Builder", "toElement" ]
                        , isAliasNames
                        ]
                  , ""
                  , "{-| The shared builder surface for the `" ++ lib ++ "` brand: the opaque `Builder`"
                  , "and the single `toElement` that closes any component's builder. Per-component"
                  , "modules provide the seeds (`build`) and the narrowed `withX` setters; they all"
                  , "share this one representation, so `toElement` is defined once (in"
                  , "`" ++ lib ++ ".Forge.Internal`) and re-exported here."
                  , ""
                  , "The `Is` aliases (`ButtonIs`, `CardIs`, …) let you annotate a phantom-kind"
                  , "type without importing the component or its builder module."
                  , ""
                  , "@docs Builder"
                  , "@docs toElement"
                  , "@docs " ++ String.join ", " isAliasNames
                  , ""
                  , "-}"
                  , ""
                  ]
                , [ "import HtmlIr.Element exposing (Element)"
                  , "import " ++ lib ++ ".Forge.Internal as Internal"
                  ]
                    ++ (comps
                            |> List.map (\c -> "import " ++ lib ++ ".Build." ++ c.name)
                            |> List.sort
                       )
                    ++ [ ""
                       , ""
                       , "{-| The shared pipe-builder — see each component's `Builder` alias for its"
                       , "narrowed, brand-typed form."
                       , "-}"
                       , "type alias Builder row attrCaps slotCaps accepts msg ="
                       , "    Internal.Builder row attrCaps slotCaps accepts msg"
                       , ""
                       , ""
                       , "{-| Close any builder into its element."
                       , "-}"
                       , "toElement : Builder row attrCaps slotCaps accepts msg -> Element accepts admittedBy msg"
                       , "toElement ="
                       , "    Internal.toElement"
                       ]
                    ++ isAliases
                    ++ [ "" ]
                ]
            )
        )



-- PER-COMPONENT MODULE


compModule : Brand -> Comp -> Elm.File
compModule brand comp =
    let
        lib =
            brand.lib

        unnamed =
            comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        requiredSlots =
            comp.slots |> List.filter .required

        -- config `requiredAttrs` (kebab manifest names, e.g. `aria-label`) as
        -- ( elm record field, html attr name ) pairs. These become REQUIRED
        -- fields on the `component`/`build` record — an accessible name can't be
        -- omitted on an icon-only control (a11y by construction).
        reqAttrFields =
            comp.requiredAttrs |> List.map (\a -> ( Naming.camel a, a ))

        hasEl =
            not (List.isEmpty requiredSlots) || comp.actionCaps /= Nothing || not (List.isEmpty reqAttrFields)

        contentAlias : ResolvedSlot -> Maybe { alias_ : String, slotName : String, row : String }
        contentAlias s =
            case s.content of
                Fields fs ->
                    Just
                        { alias_ =
                            if s.name == "unnamed" then
                                "Content"

                            else
                                Naming.pascal s.name ++ "Slot"
                        , slotName = s.name
                        , row = kindRowCompact fs
                        }

                _ ->
                    Nothing

        contentAliases =
            comp.slots |> List.filterMap contentAlias

        contentTypeOf : ResolvedSlot -> String
        contentTypeOf s =
            case s.content of
                Permissive ->
                    "childAccepts"

                SetContent set ->
                    set.pascal

                Fields _ ->
                    if s.name == "unnamed" then
                        "Content"

                    else
                        Naming.pascal s.name ++ "Slot"

        childListType : ResolvedSlot -> String
        childListType s =
            "List (Element " ++ contentTypeOf s ++ " (ChildAdmittedBy childAdm) msg)"

        returnType =
            "Element (Is s) "
                ++ (case comp.admittedBy of
                        Just _ ->
                            "AdmittedBy"

                        Nothing ->
                            "admittedBy"
                   )
                ++ " msg"

        childrenSig =
            case unnamed of
                Just s ->
                    childListType s

                Nothing ->
                    "List (Element childAccepts (ChildAdmittedBy childAdm) msg)"

        setNames =
            comp.slots
                |> List.filterMap
                    (\s ->
                        case s.content of
                            SetContent set ->
                                Just set.pascal

                            _ ->
                                Nothing
                    )

        usesShared =
            comp.produces.marker
                == MShared
                || List.any (\a -> String.contains "Shared" a.row) contentAliases

        eventNames =
            comp.events |> List.map (handlerName brand)

        exposeGroups =
            [ [ "component" ]
            , [ "Is", "Attrs", "Builder", "AttrCaps", "SlotCaps" ]
                ++ List.map .alias_ contentAliases
                ++ [ "ChildAdmittedBy" ]
                ++ (case comp.admittedBy of
                        Just _ ->
                            [ "AdmittedBy" ]

                        Nothing ->
                            []
                   )
                ++ (case comp.actionCaps of
                        Just _ ->
                            [ "ActionCaps" ]

                        Nothing ->
                            []
                   )
            , comp.enums |> List.concatMap (\e -> [ e.aliasName, e.elmName ])
            , attrReExportNames ++ eventNames
            , (namedSlots |> List.map (\s -> Naming.camel s.name))
                ++ (case unnamed of
                        Just _ ->
                            [ "child" ]

                        Nothing ->
                            []
                   )
            ]

        exposing_ =
            exposeBlock exposeGroups

        docs_ =
            docsBlock exposeGroups

        kindImports =
            (([ "Available", "Brand", "Ctx", "Used" ]
                |> List.filter
                    (\m ->
                        m
                            /= "Brand"
                            || comp.produces.marker
                            == MBrand
                            || List.any (\a -> String.contains ": Brand" a.row) contentAliases
                    )
             )
                ++ setNames
            )
                |> List.sort

        irKindExposing =
            (if usesShared then
                [ "Shared", "Supported" ]

             else
                [ "Supported" ]
            )
                |> String.join ", "

        -- R4: alias the frequently-referenced imports to cut per-use bytes.
        -- `A` = <Lib>.Attributes, `Ev` = <Lib>.Events, `Ac` = <Lib>.Action,
        -- `B` = <Lib>.Forge.Internal (the shared builder forge), `El` =
        -- HtmlIr.Element, `Val` = HtmlIr.Value. The one-time header cost buys a
        -- shorter body on every setter/builder line.
        imports =
            List.concat
                [ [ "import HtmlIr.Attribute exposing (Attr)"
                  , "import HtmlIr.Element as El exposing (Element)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (" ++ irKindExposing ++ ")"
                  ]
                , if not (List.isEmpty comp.enums) || attrReExportNeedsValues then
                    -- `Val.toString` is called by this module's OWN enum setters.
                    [ "import HtmlIr.Value as Val exposing (Value)" ]

                  else if hasEnumGlobal brand then
                    -- Only the global pipes' SIGNATURES need `Value`; nothing here
                    -- calls `Val.toString` (the global setter in `<Lib>.Attributes`
                    -- does), so the alias is omitted rather than left dangling.
                    [ "import HtmlIr.Value exposing (Value)" ]

                  else
                    []
                , if attrReExportNeedsValues || hasEnumGlobal brand then
                    [ "import " ++ lib ++ ".Values" ]

                  else
                    []
                , if needsJsonEncodeImport brand comp.attrs then
                    [ "import Json.Encode" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Attributes as A" ]
                , [ "import " ++ lib ++ ".Html as H" ]
                , [ "import " ++ lib ++ ".Internal.Types." ++ comp.name ]
                , if List.isEmpty eventNames then
                    []

                  else
                    [ "import " ++ lib ++ ".Events as Ev" ]
                , case comp.actionCaps of
                    Just _ ->
                        [ "import " ++ lib ++ ".Action as Ac" ]

                    Nothing ->
                        []
                , if List.isEmpty comp.eventOverrides then
                    []

                  else
                    [ "import Json.Decode" ]
                , [ "import " ++ lib ++ ".Kind exposing (" ++ String.join ", " kindImports ++ ")" ]
                ]
                |> List.sort

        isDoc =
            case comp.produces.marker of
                MShared ->
                    "The kind row `"
                        ++ comp.tag
                        ++ "` produces — the SHARED "
                        ++ Naming.camel (String.dropLeft 6 comp.produces.field)
                        ++ " atom kind, admissible\ninto any library's opted-in slot."

                MBrand ->
                    "The kind row `" ++ comp.tag ++ "` produces (open — composes into any slot naming it)."

        internalRef n =
            lib ++ ".Internal.Types." ++ comp.name ++ "." ++ n

        aliasDecls =
            [ doc isDoc
            , "type alias Is s ="
            , "    " ++ internalRef "Is" ++ " s"
            , ""
            , ""
            , doc "The closed attribute-capability row."
            , "type alias Attrs ="
            , "    " ++ internalRef "Attrs"
            ]
                ++ (contentAliases
                        |> List.concatMap
                            (\a ->
                                [ ""
                                , ""
                                , doc
                                    (if a.alias_ == "Content" then
                                        "The kinds the default slot admits."

                                     else
                                        "The kinds the `" ++ a.slotName ++ "` slot admits."
                                    )
                                , "type alias " ++ a.alias_ ++ " ="
                                , "    " ++ internalRef a.alias_
                                ]
                            )
                   )
                ++ [ ""
                   , ""
                   , doc "The context demand this container injects into each child's admittedBy row."
                   , "type alias ChildAdmittedBy childAdm ="
                   , "    " ++ internalRef "ChildAdmittedBy" ++ " childAdm"
                   ]
                ++ (case comp.admittedBy of
                        Just parents ->
                            let
                                parentTags =
                                    parents
                                        |> List.map
                                            (\p ->
                                                brand.comps
                                                    |> List.filter (\c -> c.ctor == p)
                                                    |> List.head
                                                    |> Maybe.map .tag
                                                    |> Maybe.withDefault p
                                            )
                                        |> List.map (\t -> "`" ++ t ++ "`")
                                        |> String.join ", "
                            in
                            [ ""
                            , ""
                            , doc
                                ("The CLOSED parent contexts this element is valid inside — `"
                                    ++ comp.tag
                                    ++ "` is\nonly writable as a direct child of "
                                    ++ parentTags
                                    ++ "."
                                )
                            , "type alias AdmittedBy ="
                            , "    " ++ internalRef "AdmittedBy"
                            ]

                        Nothing ->
                            []
                   )
                ++ (comp.enums
                        |> List.concatMap
                            (\e ->
                                [ ""
                                , ""
                                , doc ("The `" ++ e.elmName ++ "` values valid on this component (compile-tight narrowing).")
                                , "type alias " ++ e.aliasName ++ " ="
                                , "    " ++ internalRef e.aliasName
                                ]
                            )
                   )
                ++ (case comp.actionCaps of
                        Just caps ->
                            [ ""
                            , ""
                            , doc ("The behaviours this component's required action admits (see `" ++ lib ++ ".Action`).")
                            , "type alias ActionCaps ="
                            , "    " ++ internalRef "ActionCaps"
                            ]

                        Nothing ->
                            []
                   )
                ++ [ ""
                   , ""
                   , doc ("The narrowed pipe-builder this component's `" ++ lib ++ ".Build.<X>` module exposes.")
                   , "type alias Builder attrCaps slotCaps msg kind ="
                   , "    " ++ internalRef "Builder" ++ " attrCaps slotCaps msg kind"
                   , ""
                   , ""
                   , doc "The attribute capabilities this component's builder admits."
                   , "type alias AttrCaps ="
                   , "    " ++ internalRef "AttrCaps"
                   ]
                ++ (let
                        slotCapsBody =
                            capsRecord "Available" (singularSlots |> List.map (.name >> Naming.camel))
                    in
                    [ ""
                    , ""
                    , doc "The singular-slot capabilities this component's builder admits."
                    , "type alias SlotCaps ="
                    , "    "
                        ++ (if String.trim slotCapsBody == "{}" then
                                slotCapsBody

                            else
                                internalRef "SlotCaps"
                           )
                    ]
                   )

        viewDocText =
            case Maybe.map .content unnamed of
                Just Permissive ->
                    "Standard constructor: `[attributes] [children]`. The default slot is\nkind-permissive (`any`): children of any kind compose, but each child's OWN\nadmittedBy must still admit this context — a restricted-parent element is\nrejected here at compile time."

                Just (SetContent set) ->
                    "Standard constructor: `[attributes] [children]`. The default slot admits\nthe `" ++ set.name ++ "` kind set — see `" ++ lib ++ ".Kind." ++ set.pascal ++ "`."

                _ ->
                    "Standard constructor: `[attributes] [children]`."

        -- The single per-component constructor, `component`. TWO ARITIES:
        --   * zero required fields  -> bare `component : attrs -> children -> Element`
        --     (formerly the `view` function),
        --   * >=1 required field    -> record-arg
        --     `component : { .. } -> attrs -> children -> Element`.
        -- Exactly one public function name per component either way.
        elDecl =
            if not hasEl then
                [ doc viewDocText
                , "component :"
                , "    List (Attr Attrs msg)"
                , "    -> " ++ childrenSig
                , "    -> " ++ returnType
                , "component ="
                , "    H." ++ comp.resolvedCtor
                ]

            else
                let
                    reqField s =
                        ( if s.name == "unnamed" then
                            "content"

                          else
                            Naming.camel s.name
                        , "Element " ++ contentTypeOf s ++ " (ChildAdmittedBy childAdm) msg"
                        )

                    reqFields =
                        (requiredSlots |> List.map reqField)
                            ++ (reqAttrFields |> List.map (\( f, _ ) -> ( f, "String" )))
                            ++ (case comp.actionCaps of
                                    Just _ ->
                                        [ ( "action", "Ac.Action ActionCaps msg" ) ]

                                    Nothing ->
                                        []
                               )

                    reqRecord =
                        "{ "
                            ++ (reqFields |> List.map (\( n, t ) -> n ++ " : " ++ t) |> String.join "\n    , ")
                            ++ " }"

                    place s =
                        if s.name == "unnamed" then
                            case comp.actionCaps of
                                Just _ ->
                                    "actioned"

                                Nothing ->
                                    "required_.content"

                        else
                            "Ir.fromNode (Ir.addAttribute (Ir.attribute \"slot\" \"" ++ s.name ++ "\") (El.toNode required_." ++ Naming.camel s.name ++ "))"

                    consed =
                        requiredSlots
                            |> List.map place
                            |> List.foldr (\p acc -> p ++ " :: " ++ acc) "children"

                    -- required-attr setters, prepended to the attrs list so an
                    -- accessible name (etc.) is always stamped. Emitted inline
                    -- (`Ir.attribute "<html-name>"`) so the required-name
                    -- enforcement is self-contained — it does NOT depend on the
                    -- attr being exposed as a global/plain setter.
                    reqAttrsPrefix =
                        reqAttrFields
                            |> List.map (\( f, html ) -> "Ir.attribute \"" ++ html ++ "\" required_." ++ f ++ " :: ")
                            |> String.concat

                    body =
                        case comp.actionCaps of
                            Just _ ->
                                [ "component required_ attrs children ="
                                , "    let"
                                , "        actioned ="
                                , "            Ir.fromNode (" ++ "Ac.wrapContent required_.action (El.toNode required_.content))"
                                , "    in"
                                , "    H." ++ comp.resolvedCtor
                                , "        (" ++ reqAttrsPrefix ++ "Ac.toAttrs required_.action ++ attrs)"
                                , "        (" ++ consed ++ ")"
                                ]

                            Nothing ->
                                [ "component required_ attrs children ="
                                , "    H."
                                    ++ comp.resolvedCtor
                                    ++ " "
                                    ++ (if String.isEmpty reqAttrsPrefix then
                                            "attrs"

                                        else
                                            "(" ++ reqAttrsPrefix ++ "attrs)"
                                       )
                                    ++ " ("
                                    ++ consed
                                    ++ ")"
                                ]
                in
                [ doc "Required-content (and action) constructor — omissions are unwritable."
                , "component :"
                , "    " ++ reqRecord
                , "    -> List (Attr Attrs msg)"
                , "    -> " ++ childrenSig
                , "    -> " ++ returnType
                ]
                    ++ body

        enumSetters =
            comp.enums
                |> List.concatMap
                    (\e ->
                        let
                            matchingAttr =
                                comp.attrs
                                    |> List.filter (\a -> a.elmName == e.elmName)
                                    |> List.head

                            htmlName =
                                matchingAttr
                                    |> Maybe.map .htmlName
                                    |> Maybe.withDefault e.elmName

                            docText =
                                matchingAttr
                                    |> Maybe.map Attr.docString
                                    |> Maybe.withDefault ("Set the `" ++ e.elmName ++ "` value.")
                        in
                        [ ""
                        , ""
                        , doc docText
                        , e.elmName ++ " : Value " ++ e.aliasName ++ " -> Attr { c | " ++ e.elmName ++ " : Supported } msg"
                        , e.elmName ++ " value_ ="
                        , "    Ir.attribute \"" ++ htmlName ++ "\" (Val.toString value_)"
                        ]
                    )

        ( attrReExportNames, attrReExports, attrReExportNeedsValues ) =
            reExportBlock brand
                "A"
                (comp.ctor
                    :: (comp.enums |> List.map .elmName)
                    ++ (namedSlots |> List.map (\s -> Naming.camel s.name))
                )
                comp.propertyOnly
                comp.attrs

        overrideFor evName =
            comp.eventOverrides |> List.filter (\o -> o.name == evName) |> List.head

        eventReExports =
            comp.events
                |> List.concatMap
                    (\ev ->
                        let
                            n =
                                handlerName brand ev
                        in
                        case overrideFor ev.name of
                            Just o ->
                                let
                                    ( elmTy, dec ) =
                                        overrideTypes o.type_

                                    pathExpr =
                                        "[ " ++ (o.path |> List.map (\s -> "\"" ++ s ++ "\"") |> String.join ", ") ++ " ]"
                                in
                                [ ""
                                , ""
                                , doc ("Typed `" ++ ev.name ++ "` event: decodes `" ++ String.join "." o.path ++ "` as " ++ elmTy ++ ".")
                                , n ++ " : (" ++ elmTy ++ " -> msg) -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ " toMsg ="
                                , "    Ir.on \"" ++ ev.name ++ "\" (Json.Decode.map toMsg (Json.Decode.at " ++ pathExpr ++ " " ++ dec ++ "))"
                                ]

                            Nothing ->
                                case ev.payload of
                                    Just payload ->
                                        -- A standard-payload annotation: re-export the
                                        -- payload-typed setter from the shared Events
                                        -- module, matching its `(payload -> msg)` shape.
                                        let
                                            ( elmTy, _ ) =
                                                payloadTypeAndDecoder payload
                                        in
                                        [ ""
                                        , ""
                                        , doc ("See `" ++ lib ++ ".Events." ++ n ++ "`.")
                                        , n ++ " : (" ++ elmTy ++ " -> msg) -> Attr { c | " ++ n ++ " : Supported } msg"
                                        , n ++ " ="
                                        , "    Ev." ++ n
                                        ]

                                    Nothing ->
                                        [ ""
                                        , ""
                                        , doc ("See `" ++ lib ++ ".Events." ++ n ++ "`.")
                                        , n ++ " : msg -> Attr { c | " ++ n ++ " : Supported } msg"
                                        , n ++ " ="
                                        , "    Ev." ++ n
                                        ]
                    )

        slotSetters =
            namedSlots
                |> List.concatMap
                    (\s ->
                        [ ""
                        , ""
                        , doc
                            ("Place an element into the named `"
                                ++ s.name
                                ++ "` slot (input constrained to the\nslot's kinds; output row free so it composes into the child list)."
                            )
                        , Naming.camel s.name ++ " : Element " ++ contentTypeOf s ++ " admittedBy msg -> Element free freeAdmittedBy msg"
                        , Naming.camel s.name ++ " element ="
                        , "    Ir.fromNode (Ir.addAttribute (Ir.attribute \"slot\" \"" ++ s.name ++ "\") (El.toNode element))"
                        ]
                    )

        -- Default-slot wrapper: the list-form sibling of the builder's `withChild`.
        -- Mirrors the named-slot wrappers' shape (input constrained to the default
        -- slot's kinds; output row freed so it composes into the child list), but
        -- adds no `slot` attribute — the default slot is the absence of one.
        defaultChildSetter =
            case unnamed of
                Just s ->
                    [ ""
                    , ""
                    , doc "Place a pre-built element into the default (unnamed) slot (input\nconstrained to the slot's kinds; output row free so it composes into the\nchild list). The list-form sibling of the builder's `withChild`."
                    , "child : Element " ++ contentTypeOf s ++ " admittedBy msg -> Element free freeAdmittedBy msg"
                    , "child element ="
                    , "    Ir.fromNode (El.toNode element)"
                    ]

                Nothing ->
                    []

    in
    file [ lib, "Component", comp.name ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Component." ++ comp.name ++ " exposing"
                  , exposing_
                  , ""
                  , "{-| The `" ++ comp.tag ++ "` component — strict per-component surface."
                  , ""
                  , comp.description
                  , ""
                  , docs_
                  , ""
                  , "-}"
                  , ""
                  ]
                , imports
                , [ "", "" ]
                , aliasDecls
                , [ "", "" ]
                , elDecl
                , enumSetters
                , attrReExports
                , eventReExports
                , slotSetters
                , defaultChildSetter
                , [ "" ]
                ]
            )
        )


{-| Emit the unexposed internal-types module (`M3e.Internal.Types.<Component>`).
Contains the heavy record-row type definitions currently inline in `compModule`.
This module is NOT in any package's `exposed-modules`, so its types appear as
short qualified references in docs.json rather than expanded record rows.

The empty-row skip rule: trivial aliases (empty `{}`) are NOT moved here —
kept inline in the component module to avoid a net-negative savings.
-}
internalTypesModule : Brand -> Comp -> Elm.File
internalTypesModule brand comp =
    let
        lib =
            brand.lib

        unnamed =
            comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        contentAlias : ResolvedSlot -> Maybe { alias_ : String, slotName : String, row : String }
        contentAlias s =
            case s.content of
                Fields fs ->
                    Just
                        { alias_ =
                            if s.name == "unnamed" then
                                "Content"

                            else
                                Naming.pascal s.name ++ "Slot"
                        , slotName = s.name
                        , row = kindRowCompact fs
                        }

                _ ->
                    Nothing

        contentAliases =
            comp.slots |> List.filterMap contentAlias

        kindImports =
            ([ "Available", "Brand", "Ctx", "Used" ]
                |> List.filter
                    (\m ->
                        m
                            /= "Brand"
                            || comp.produces.marker
                            == MBrand
                            || List.any (\a -> String.contains ": Brand" a.row) contentAliases
                    )
            )
                ++ (comp.slots
                        |> List.filterMap
                            (\s ->
                                case s.content of
                                    SetContent set ->
                                        Just set.pascal

                                    _ ->
                                        Nothing
                            )
                   )
                |> List.sort

        usesShared =
            comp.produces.marker
                == MShared
                || List.any (\a -> String.contains "Shared" a.row) contentAliases

        needsValueImport =
            not (List.isEmpty comp.enums) || (comp.attrs |> List.any (\a -> isEnumSpec a)) || hasEnumGlobal brand

        imports =
            List.concat
                [ [ "import HtmlIr.Kind exposing (" ++ (if usesShared then "Shared, Supported" else "Supported") ++ ")" ]
                , [ "import " ++ lib ++ ".Kind exposing (" ++ String.join ", " kindImports ++ ")" ]
                , if needsValueImport then
                    [ "import HtmlIr.Value as Val exposing (Value)" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Forge.Internal as B" ]
                ]

        slotCapsBody =
            capsRecord "Available" (singularSlots |> List.map (.name >> Naming.camel))

        isEmptyBody body =
            String.trim body == "{}"

        aliasDefs =
            [ ""
            , "type alias Is s ="
            , "    { s | " ++ comp.produces.field ++ " : " ++ markerName comp.produces.marker ++ " }"
            , ""
            , ""
            , "type alias Attrs ="
            , "    " ++ supportedRow (attrsFields brand comp)
            ]
                ++ (contentAliases
                        |> List.concatMap
                            (\a ->
                                [ ""
                                , ""
                                , "type alias " ++ a.alias_ ++ " ="
                                , "    " ++ a.row
                                ]
                            )
                   )
                ++ [ ""
                   , ""
                   , "type alias ChildAdmittedBy childAdm ="
                   , "    { childAdm | " ++ comp.ctor ++ " : Ctx }"
                   ]
                ++ (case comp.admittedBy of
                        Just parents ->
                            [ ""
                            , ""
                            , "type alias AdmittedBy ="
                            , "    { " ++ (parents |> List.map (\p -> p ++ " : Ctx") |> String.join ", ") ++ " }"
                            ]

                        Nothing ->
                            []
                   )
                ++ (comp.enums
                        |> List.concatMap
                            (\e ->
                                [ ""
                                , ""
                                , "type alias " ++ e.aliasName ++ " ="
                                , "    " ++ supportedRow (e.tokens |> List.map (tokenIdentResolved brand))
                                ]
                            )
                   )
                ++ (case comp.actionCaps of
                        Just caps ->
                            [ ""
                            , ""
                            , "type alias ActionCaps ="
                            , "    " ++ supportedRow (caps |> List.map Naming.safeField |> List.sort)
                            ]

                        Nothing ->
                            []
                   )
                ++ [ ""
                   , ""
                   , "type alias Builder attrCaps slotCaps msg s ="
                   , "    B.Builder Attrs attrCaps slotCaps (Is s) msg"
                   , ""
                   , ""
                   , "type alias AttrCaps ="
                   , "    " ++ capsRecord "Available" (attrsFields brand comp)
                   ]
                ++ (if isEmptyBody slotCapsBody then
                        []

                    else
                        [ ""
                        , ""
                        , "type alias SlotCaps ="
                        , "    " ++ slotCapsBody
                        ]
                   )
    in
    file [ lib, "Internal", "Types", comp.name ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Internal.Types." ++ comp.name ++ " exposing (..)"
                  , ""
                  , "{-| Internal type definitions for " ++ comp.name ++ " — unexposed so docs.json"
                  , "shows short qualified references instead of expanded record rows."
                  , "-}"
                  , ""
                  ]
                , imports
                , [ ""
                  , ""
                  ]
                , aliasDefs
                , [ "" ]
                ]
            )
        )


{-| Emit the per-component builder module (`M3e.<Component>.Build`). Each
builder module encapsulates the builder pattern for one component: seeds
(`build`), builder-accepting slot placers/pipes, and attr pipes re-exported
from the component module. The `accepts` phantom is pinned to `(Component.Is s)`,
so `toElement` produces `Element (Component.Is s) admittedBy msg`.
-}
compBuildModule : Brand -> Comp -> Elm.File
compBuildModule brand comp =
    let
        lib =
            brand.lib

        unnamed =
            comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        variadicSlots =
            namedSlots |> List.filter .multi

        requiredSlots =
            comp.slots |> List.filter .required

        reqAttrFields =
            comp.requiredAttrs |> List.map (\a -> ( Naming.camel a, a ))

        hasEl =
            not (List.isEmpty requiredSlots) || comp.actionCaps /= Nothing || not (List.isEmpty reqAttrFields)

        eventNames =
            comp.events |> List.map (handlerName brand)

        overrideFor evName =
            comp.eventOverrides |> List.filter (\o -> o.name == evName) |> List.head

        contentAlias : ResolvedSlot -> Maybe { alias_ : String, slotName : String, row : String }
        contentAlias s =
            case s.content of
                Fields fs ->
                    Just
                        { alias_ =
                            if s.name == "unnamed" then
                                "Content"

                            else
                                Naming.pascal s.name ++ "Slot"
                        , slotName = s.name
                        , row = kindRowCompact fs
                        }

                _ ->
                    Nothing

        contentAliases =
            comp.slots |> List.filterMap contentAlias

        contentTypeOf : ResolvedSlot -> String
        contentTypeOf s =
            case s.content of
                Permissive ->
                    "childAccepts"

                SetContent set ->
                    set.pascal

                Fields _ ->
                    if s.name == "unnamed" then
                        "Component.Content"

                    else
                        "Component." ++ Naming.pascal s.name ++ "Slot"

        returnType =
            "Element ("
                ++ lib
                ++ "."
                ++ comp.name
                ++ ".Is s) "
                ++ (case comp.admittedBy of
                        Just _ ->
                            "(" ++ lib ++ "." ++ comp.name ++ ".AdmittedBy)"

                        Nothing ->
                            "admittedBy"
                   )
                ++ " msg"

        -- K5: full top-level namespace from the component module, used so
        -- slot pipe naming matches what the component module used (avoids
        -- a spurious conflict where one module renames and the other doesn't).
        attrPipeNames =
            attrsFields brand comp |> List.map (\f -> "with" ++ Naming.pascal f)

        compTopLevelNamespace =
            List.concat
                [ [ comp.resolvedCtor ]
                , comp.attrs |> List.map .elmName
                , attrPipeNames
                , comp.events |> List.map (handlerName brand)
                ]

        slotPipeNameOf s =
            let
                plain =
                    "with" ++ Naming.pascal s.name
            in
            if List.member plain compTopLevelNamespace then
                plain ++ "Slot"

            else
                plain

        slotPlacerNames =
            namedSlots |> List.map (\s -> Naming.camel s.name)

        singularSlotPipeNames =
            singularSlots |> List.map slotPipeNameOf

        variadicSlotPipeNames =
            variadicSlots |> List.map slotPipeNameOf

        contentAliasNames =
            contentAliases |> List.map .alias_

        -- Builder-relevant type aliases to expose
        typeAliasExposeNames =
            [ "Builder", "AttrCaps", "SlotCaps", "Is" ]
                ++ contentAliasNames
                ++ [ "ChildAdmittedBy" ]
                ++ (case comp.admittedBy of
                        Just _ ->
                            [ "AdmittedBy" ]

                        Nothing ->
                            []
                   )
                ++ (case comp.actionCaps of
                        Just _ ->
                            [ "ActionCaps" ]

                        Nothing ->
                            []
                   )

        internalRef n =
            "Component." ++ n

        -- Re-export component's content type aliases
        contentAliasReExports =
            contentAliases
                |> List.concatMap
                    (\a ->
                        [ ""
                        , ""
                        , "{-| -}"
                        , "type alias " ++ a.alias_ ++ " ="
                        , "    " ++ internalRef a.alias_
                        ]
                    )

        contentAliasDocs =
            contentAliases
                |> List.concatMap
                    (\a ->
                        [ ""
                        , "@docs " ++ a.alias_
                        ]
                    )

        exposeGroups =
            [ [ "build", "toElement" ]
            , typeAliasExposeNames
            , attrPipeNames
            , slotPlacerNames
            , singularSlotPipeNames
                ++ variadicSlotPipeNames
                ++ (case unnamed of
                        Just _ ->
                            [ "withChild" ]

                        Nothing ->
                            []
                   )
            ]

        exposing_ =
            exposeBlock exposeGroups

        docs_ =
            docsBlock exposeGroups

        buildDecl =
            if hasEl then
                let
                    seedChildren =
                        requiredSlots
                            |> List.map
                                (\s ->
                                    if s.name == "unnamed" then
                                        "El.toNode required_.content"

                                    else
                                        "El.toNode (Component." ++ Naming.camel s.name ++ " required_." ++ Naming.camel s.name ++ ")"
                                )

                    seedAttrs =
                        case comp.actionCaps of
                            Just _ ->
                                "Ac.toAttrs required_.action"

                            Nothing ->
                                if List.isEmpty reqAttrFields then
                                    "[]"

                                else
                                    "[ "
                                        ++ (reqAttrFields |> List.map (\( f, html ) -> "Ir.attribute \"" ++ html ++ "\" required_." ++ f) |> String.join ", ")
                                        ++ " ]"

                    seedChildren_ =
                        case comp.actionCaps of
                            Just _ ->
                                seedChildren
                                    |> List.map
                                        (\s ->
                                            if s == "El.toNode required_.content" then
                                                "Ac.wrapContent required_.action (El.toNode required_.content)"

                                            else
                                                s
                                        )

                            Nothing ->
                                seedChildren

                    reqFields =
                        (requiredSlots
                            |> List.map
                                (\s ->
                                    ( if s.name == "unnamed" then
                                        "content"

                                      else
                                        Naming.camel s.name
                                    , "Element (" ++ contentTypeOf s ++ ") (" ++ "Component.ChildAdmittedBy childAdm) msg"
                                    )
                                )
                        )
                            ++ (reqAttrFields |> List.map (\( f, _ ) -> ( f, "String" )))
                            ++ (case comp.actionCaps of
                                    Just _ ->
                                        [ ( "action", "Ac.Action (Component.ActionCaps) msg" ) ]

                                    Nothing ->
                                        []
                               )
                in
                [ ""
                , ""
                , "{-| -}"
                , "build :"
                , "    { "
                    ++ (reqFields |> List.map (\( n, t ) -> n ++ " : " ++ t) |> String.join "\n    , ")
                    ++ " }"
                , "    -> Builder AttrCaps SlotCaps msg kind"
                , "build required_ ="
                , "    B.init \"" ++ comp.tag ++ "\" (" ++ seedAttrs ++ ") [ " ++ String.join ", " seedChildren_ ++ " ]"
                ]

            else
                [ ""
                , ""
                , "{-| -}"
                , "build : Builder AttrCaps SlotCaps msg kind"
                , "build ="
                , "    B.init \"" ++ comp.tag ++ "\" [] []"
                ]

        -- Slot placers: builder-accepting versions of the component's slot setters.
        -- Each takes a B.Builder, calls B.toElement internally, then delegates to
        -- the component's slot placer. Constrains `accepts` to the slot's content
        -- type for a better error message (the error points at the call site).
        slotPlacers =
            namedSlots
                |> List.concatMap
                    (\s ->
                        [ ""
                        , ""
                        , "{-| -}"
                        , Naming.camel s.name ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> Element free freeAdmittedBy msg"
                        , Naming.camel s.name ++ " builder ="
                        , "    " ++ "Component." ++ Naming.camel s.name ++ " (B.toElement builder)"
                        ]
                    )

        -- Slot pipes: builder-accepting versions that consume slot capabilities.
        singularSlotPipes =
            singularSlots
                |> List.concatMap
                    (\s ->
                        let
                            n =
                                slotPipeNameOf s
                        in
                        [ ""
                        , ""
                        , "{-| -}"
                        , n ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> Builder attrCaps { s | " ++ Naming.camel s.name ++ " : Available } msg kind"
                        , "    -> Builder attrCaps { s | " ++ Naming.camel s.name ++ " : Used } msg kind"
                        , n ++ " slotBuilder builder_ ="
                        , "    B.withChild (El.toNode (" ++ "Component." ++ Naming.camel s.name ++ " (B.toElement slotBuilder))) builder_"
                        ]
                    )

        variadicSlotPipes =
            variadicSlots
                |> List.concatMap
                    (\s ->
                        let
                            n =
                                slotPipeNameOf s
                        in
                        [ ""
                        , ""
                        , "{-| -}"
                        , n ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> Builder attrCaps slotCaps msg kind"
                        , "    -> Builder attrCaps slotCaps msg kind"
                        , n ++ " slotBuilder builder_ ="
                        , "    B.withChild (El.toNode (" ++ "Component." ++ Naming.camel s.name ++ " (B.toElement slotBuilder))) builder_"
                        ]
                    )

        -- Default child pipe (builder-accepting, universally quantified accepts)
        childPipe =
            case unnamed of
                Just s ->
                    [ ""
                    , ""
                    , "{-| -}"
                    , "withChild :"
                    , "    B.Builder childRow childAttrCaps childSlotCaps accepts msg"
                    , "    -> Builder attrCaps slotCaps msg kind"
                    , "    -> Builder attrCaps slotCaps msg kind"
                    , "withChild childBuilder builder_ ="
                    , "    B.withChild (El.toNode (B.toElement childBuilder)) builder_"
                    ]

                Nothing ->
                    []

        -- R2/R3: each `withX` is a thin `B.withAttribute` wrapper; the
        -- phantom-row transition lives in the signature.
        pipeFor : String -> String -> String -> List String
        pipeFor capField inputSig applied =
            pipeForParams capField
                inputSig
                (if String.isEmpty inputSig then
                    []

                 else
                    [ "value_" ]
                )
                applied

        -- Explicit parameter names, because not every setter is unary: `style`
        -- takes a property AND a value (the elm/html 0.19 shape).
        pipeForParams : String -> String -> List String -> String -> List String
        pipeForParams capField inputSig params applied =
            let
                n =
                    "with" ++ Naming.pascal capField
            in
            [ ""
            , ""
            , "{-| -}"
            , n ++ " : " ++ inputSig ++ "Builder { a | " ++ capField ++ " : Available } slotCaps msg kind -> Builder { a | " ++ capField ++ " : Used } slotCaps msg kind"
            , n
                ++ (if List.isEmpty params then
                        " ="

                    else
                        " " ++ String.join " " params ++ " ="
                   )
            , "    B.withAttribute (" ++ applied ++ ")"
            ]

        attrPipes =
            (brand.globals
                |> List.map
                    (\g ->
                        if g.elmName == "style" then
                            -- The one non-unary global (the elm/html 0.19 shape),
                            -- so it cannot go through `pipeFor`.
                            pipeForParams "style" "String -> String -> " [ "property", "value_" ] "A.style property value_"

                        else
                            pipeFor g.capName (globalSetterInputType brand g ++ " -> ") ("A." ++ g.elmName ++ " value_")
                    )
            )
                ++ (comp.attrs
                        |> List.map
                            (\a ->
                                case ( isEnumSpec a, unionFor brand a.elmName ) of
                                    ( True, _ ) ->
                                        -- Component-local enum: delegate to the component's
                                        -- own setter (which holds the right Value row).
                                        pipeFor a.capName ("Value Component." ++ Naming.pascal a.elmName ++ " -> ") ("Component." ++ a.elmName ++ " value_")

                                    ( _, Just _ ) ->
                                        -- Enum ELSEWHERE but plain on this member: inline
                                        -- the member's own setter rather than delegating.
                                        pipeFor a.capName (setterInputType a ++ " -> ") (setterExpr a)

                                    ( _, Nothing ) ->
                                        if divergesFromCanonical brand a then
                                            -- Type OR form divergence: inline rather than
                                            -- delegating to `A.<attr>`, which would write
                                            -- the canonical's kind of fact.
                                            pipeFor a.capName (setterInputType a ++ " -> ") (setterExpr a)

                                        else
                                            pipeFor a.capName (setterInputType a ++ " -> ") ("A." ++ a.elmName ++ " value_")
                            )
                   )
                ++ (comp.events
                        |> List.map
                            (\ev ->
                                case overrideFor ev.name of
                                    Just o ->
                                        let
                                            ( elmTy, _ ) =
                                                overrideTypes o.type_
                                        in
                                        -- Override handler lives in the Component module.
                                        pipeFor (handlerName brand ev) ("(" ++ elmTy ++ " -> msg) -> ") ("Component." ++ handlerName brand ev ++ " value_")

                                    Nothing ->
                                        case ev.payload of
                                            Just payload ->
                                                let
                                                    ( elmTy, _ ) =
                                                        payloadTypeAndDecoder payload
                                                in
                                                pipeFor (handlerName brand ev) ("(" ++ elmTy ++ " -> msg) -> ") ("Ev." ++ handlerName brand ev ++ " value_")

                                            Nothing ->
                                                pipeFor (handlerName brand ev) "msg -> " ("Ev." ++ handlerName brand ev ++ " value_")
                            )
                   )
                |> List.concat

        kindImports =
            ([ "Available", "Brand", "Ctx", "Used" ]
                |> List.filter
                    (\m ->
                        m
                            /= "Brand"
                            || comp.produces.marker
                            == MBrand
                            || List.any (\a -> String.contains ": Brand" a.row) contentAliases
                    )
            )
                ++ (comp.slots
                        |> List.filterMap
                            (\s ->
                                case s.content of
                                    SetContent set ->
                                        Just set.pascal

                                    _ ->
                                        Nothing
                            )
                   )
                |> List.sort

        usesShared =
            comp.produces.marker
                == MShared
                || List.any (\a -> String.contains "Shared" a.row) contentAliases

        irKindExposing =
            (if usesShared then
                [ "Shared", "Supported" ]

             else
                [ "Supported" ]
            )
                |> String.join ", "

        needsValuesImport =
            not (List.isEmpty comp.enums)
                || hasEnumGlobal brand
                || (comp.attrs |> List.any (\a -> isEnumSpec a))

        imports =
            List.concat
                [ [ "import HtmlIr.Element as El exposing (Element)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (" ++ irKindExposing ++ ")"
                  ]
                , if not (List.isEmpty comp.enums) || hasEnumGlobal brand then
                    [ "import HtmlIr.Value as Val exposing (Value)" ]

                  else
                    []
                , if needsValuesImport then
                    [ "import " ++ lib ++ ".Values" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Attributes as A" ]
                , [ "import " ++ lib ++ ".Forge.Internal as B" ]
                , if List.isEmpty eventNames then
                    []

                  else
                    [ "import " ++ lib ++ ".Events as Ev" ]
                , if needsJsonEncodeImport brand comp.attrs then
                    [ "import Json.Encode" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Kind exposing (" ++ String.join ", " kindImports ++ ")" ]
                , [ "import " ++ lib ++ ".Component." ++ comp.name ++ " as Component" ]
                ]
                ++ (case comp.actionCaps of
                        Just _ ->
                            [ "import " ++ lib ++ ".Action as Ac" ]

                        Nothing ->
                            []
                   )
                |> List.sort

        isDoc =
            if comp.transparent then
                "The kind this element produces is transparent — it inherits its parent's kind."

            else
                "The kind this element produces — a `Brand` that marks the phantom row."

        kindReturnType =
            "Element (Component.Is kind) "
                ++ (case comp.admittedBy of
                        Just _ ->
                            "(Component.AdmittedBy)"

                        Nothing ->
                            "admittedBy"
                   )
                ++ " msg"
    in
    file [ lib, "Build", comp.name ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Build." ++ comp.name ++ " exposing"
                  , exposing_
                  , ""
                  , "{-|"
                  , docs_
                  , "-}"
                  , ""
                  ]
                , imports
                , [ ""
                  , ""
                  , "{-| -}"
                  , "type alias Is s ="
                  , "    " ++ internalRef "Is" ++ " s"
                  , ""
                  , ""
                  , "{-| -}"
                  , "type alias Builder attrCaps slotCaps msg kind ="
                  , "    " ++ internalRef "Builder" ++ " attrCaps slotCaps msg kind"
                  , ""
                  , ""
                  , "{-| -}"
                  , "type alias AttrCaps ="
                  , "    " ++ internalRef "AttrCaps"
                  , ""
                  , ""
                  ]
                    ++ (let
                            slotCapsBody =
                                capsRecord "Available" (singularSlots |> List.map (.name >> Naming.camel))
                        in
                        if String.trim slotCapsBody == "{}" then
                            [ "{-| -}"
                            , "type alias SlotCaps ="
                            , "    " ++ slotCapsBody
                            ]

                        else
                            [ "{-| -}"
                            , "type alias SlotCaps ="
                            , "    " ++ internalRef "SlotCaps"
                            ]
                       )
                    ++ [ ""
                       , ""
                       , "{-| -}"
                       , "type alias ChildAdmittedBy childAdm ="
                       , "    " ++ internalRef "ChildAdmittedBy" ++ " childAdm"
                       ]
                     ++ (case comp.admittedBy of
                            Just _ ->
                                [ ""
                                , ""
                                , "{-| -}"
                                , "type alias AdmittedBy ="
                                , "    " ++ internalRef "AdmittedBy"
                                ]

                            Nothing ->
                                []
                       )
                     ++ (case comp.actionCaps of
                            Just _ ->
                                [ ""
                                , ""
                                , "{-| -}"
                                , "type alias ActionCaps ="
                                , "    " ++ internalRef "ActionCaps"
                                ]

                            Nothing ->
                                []
                       )
                    ++ contentAliasReExports
                    ++ buildDecl
                    ++ [ ""
                       , ""
                       , "{-| -}"
                       , "toElement : Builder attrCaps slotCaps msg kind -> " ++ kindReturnType
                       , "toElement ="
                       , "    B.toElement"
                       ]
                    ++ slotPlacers
                    ++ singularSlotPipes
                    ++ variadicSlotPipes
                    ++ childPipe
                    ++ attrPipes
                    ++ [ "" ]
                ]
            )
        )


{-| The Elm input type a scalar attribute's setter takes. A thin projection of
`Attr.setterType` (the ONE definition; see there for why enums spell `String`).
-}
setterInputType : Attr.AttrSpec -> String
setterInputType a =
    Attr.setterType a.type_


{-| The input type a GLOBAL's setter takes, spelled for a module that reaches the
setter through `<Lib>.Attributes` (a builder pipe, a re-export).

Scalars follow `setterInputType`; an ENUM global resolves to its brand-wide
`<Lib>.Values` row — unlike a per-component enum, whose row alias is declared
locally in the component module, a global's row has exactly one home.

The `Nothing` arm is unreachable: `Model.resolveWith` puts an `EnumSpec` into
`Brand.unions` for every enum global, so an enum global always has a row.

-}
globalSetterInputType : Brand -> Attr.AttrSpec -> String
globalSetterInputType brand g =
    case ( isEnumSpec g, unionFor brand g.elmName ) of
        ( True, Just union ) ->
            "Value " ++ brand.lib ++ ".Values." ++ union.aliasName

        _ ->
            setterInputType g



-- HTML (LOOSE PRODUCER) MODULE
--
-- R2 inversion: the loose, elm/html-like producer layer. One open-rowed
-- constructor per rich element, each OWNING `Ir.node "<tag>"`. This is the
-- foundation the `<Lib>-html` split package exposes; every rich
-- `<Lib>.<Component>` imports its producer here and re-exposes it under a
-- tightened signature. Depends only on the IR substrate — imports NO component
-- module, so it compiles standalone. Native/home-shaped brands already own
-- their `Ir.node` in the home modules (which ARE the loose layer), so this
-- module is emitted only for the rich per-component (`own`) shape.
-- SUBSTRATE RE-EXPORTS
--
-- The substrate types a caller needs to write a type annotation. Every brand
-- surface re-exports them so `HtmlIr.*` never has to appear in userland code.
--
-- Kept as ONE list + ONE declaration block, shared verbatim by the barrel and
-- by the published `<Lib>.Html` producer layer. Before this, the barrel's
-- exposing list held a hardcoded `[ "Element", "Attr", "mapMsg" ]` that had
-- already drifted from what the other emitters shipped: `Value` and
-- `Supported`/`Shared` were used in every generated signature but re-exported
-- nowhere, so annotating a token forced an `HtmlIr.Value` import.


{-| Names re-exported by both the barrel and `<Lib>.Html`.
-}
substrateReExportNames : List String
substrateReExportNames =
    [ "Element"
    , "Attr"
    , "Node"
    , "toHtml"
    , "toNode"
    , "mapMsg"
    , "mapNode"
    , "key"
    , "lazy"
    , "lazy2"
    , "lazy3"
    , "lazy4"
    , "lazy5"
    , "lazy6"
    , "lazy7"
    , "lazy8"
    , "addClass"
    , "attrIf"
    , "when"
    , "testId"
    ]


{-| Imports that [`substrateReExportDecls`](#substrateReExportDecls) needs.
Qualified, never `exposing` — the local aliases below shadow the names.
-}
substrateReExportImports : List String
substrateReExportImports =
    [ "import Html"
    , "import HtmlIr.Attribute"
    , "import HtmlIr.Element"
    , "import HtmlIr.Node"
    ]


{-| The declarations behind [`substrateReExportNames`](#substrateReExportNames).
-}
substrateReExportDecls : List String
substrateReExportDecls =
    [ ""
    , ""
    , doc "The typed IR element every constructor here produces. Re-exported so callers never import `HtmlIr.Element` directly."
    , "type alias Element accepts admittedBy msg ="
    , "    HtmlIr.Element.Element accepts admittedBy msg"
    , ""
    , ""
    , doc "A typed attribute. Re-exported so callers never import `HtmlIr.Attribute` directly."
    , "type alias Attr capability msg ="
    , "    HtmlIr.Attribute.Attr capability msg"
    , ""
    , ""
    , doc "The untyped IR node an `Element` wraps — the erased form, carrying no phantom claims. Re-exported for the boundaries that must store renderable content in a monomorphic field (a framework `View` record, a cache); lift it back with `<Lib>.Unsafe.fromNode`."
    , "type alias Node msg ="
    , "    HtmlIr.Node.Node msg"
    , ""
    , ""
    , doc "Render any element from this library to `elm/html`."
    , "toHtml : Element accepts admittedBy msg -> Html.Html msg"
    , "toHtml ="
    , "    HtmlIr.Element.toNode >> HtmlIr.Node.toHtml"
    , ""
    , ""
    , doc "Erase an element to its untyped [`Node`](#Node) — the safe out-bound direction; the phantom rows are discarded, never re-asserted."
    , "toNode : Element accepts admittedBy msg -> Node msg"
    , "toNode ="
    , "    HtmlIr.Element.toNode"
    , ""
    , ""
    , doc "Map the `msg` type of any element from this library (the typed IR's `Html.map`). Structural: the tree is not rendered, rows are preserved."
    , "mapMsg : (a -> b) -> Element accepts admittedBy a -> Element accepts admittedBy b"
    , "mapMsg ="
    , "    HtmlIr.Element.map"
    , ""
    , ""
    , doc "[`mapMsg`](#mapMsg) for an erased [`Node`](#Node)."
    , "mapNode : (a -> b) -> Node a -> Node b"
    , "mapNode ="
    , "    HtmlIr.Node.map"
    , ""
    , ""
    , doc "Attach a diff key to a child so its parent container renders as a keyed node. State and animations survive reorders, insertions, and removals. Phantom rows are preserved — a keyed chip is still a chip."
    , "key : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "key ="
    , "    HtmlIr.Element.key"
    , ""
    , ""
    , doc "Memoise a subtree while its input is referentially unchanged. The result keeps its phantom rows and drops into any slot. **The view function must be a stable top-level binding** — an inline lambda allocates a fresh closure each render and silently never memoises."
    , "lazy : (a -> Element accepts admittedBy msg) -> a -> Element accepts admittedBy msg"
    , "lazy ="
    , "    HtmlIr.Element.lazy"
    , ""
    , ""
    , doc "2-argument variant of [`lazy`](#lazy)."
    , "lazy2 : (a -> b -> Element accepts admittedBy msg) -> a -> b -> Element accepts admittedBy msg"
    , "lazy2 ="
    , "    HtmlIr.Element.lazy2"
    , ""
    , ""
    , doc "3-argument variant of [`lazy`](#lazy)."
    , "lazy3 : (a -> b -> c -> Element accepts admittedBy msg) -> a -> b -> c -> Element accepts admittedBy msg"
    , "lazy3 ="
    , "    HtmlIr.Element.lazy3"
    , ""
    , ""
    , doc "4-argument variant of [`lazy`](#lazy)."
    , "lazy4 : (a -> b -> c -> d -> Element accepts admittedBy msg) -> a -> b -> c -> d -> Element accepts admittedBy msg"
    , "lazy4 ="
    , "    HtmlIr.Element.lazy4"
    , ""
    , ""
    , doc "5-argument variant of [`lazy`](#lazy)."
    , "lazy5 : (a -> b -> c -> d -> e -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> Element accepts admittedBy msg"
    , "lazy5 ="
    , "    HtmlIr.Element.lazy5"
    , ""
    , ""
    , doc "6-argument variant of [`lazy`](#lazy). Note type params skip `f` to match the underlying `VirtualDom.lazy6` convention."
    , "lazy6 : (a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> Element accepts admittedBy msg"
    , "lazy6 ="
    , "    HtmlIr.Element.lazy6"
    , ""
    , ""
    , doc "7-argument variant of [`lazy`](#lazy)."
    , "lazy7 : (a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> Element accepts admittedBy msg"
    , "lazy7 ="
    , "    HtmlIr.Element.lazy7"
    , ""
    , ""
    , doc "8-argument variant of [`lazy`](#lazy). **This variant does not memoise** — the Element→Html bridge only has room for seven memoised data arguments, so the eighth forces a fresh closure each render and defeats the reference check. For real memoisation, fold the extra state into one of the first seven arguments and use [`lazy7`](#lazy7)."
    , "lazy8 : (a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg) -> a -> b -> c -> d -> e -> g -> h -> i -> Element accepts admittedBy msg"
    , "lazy8 ="
    , "    HtmlIr.Element.lazy8"
    , ""
    , ""
    , doc "Add a CSS class, participating in the `class` merge. Phantom rows preserved."
    , "addClass : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "addClass ="
    , "    HtmlIr.Element.addClass"
    , ""
    , ""
    , doc "Conditionally attach an attribute — applied when the flag is `True`, a no-op when `False`. Phantom rows preserved."
    , "attrIf : Bool -> Attr capability msg -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "attrIf ="
    , "    HtmlIr.Element.attrIf"
    , ""
    , ""
    , doc "Keep an element only when the flag is `True`; `False` collapses it to an empty node that renders nothing. Phantom rows preserved."
    , "when : Bool -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "when ="
    , "    HtmlIr.Element.when"
    , ""
    , ""
    , doc "Stamp a `data-testid` attribute for test hooks. Phantom rows preserved."
    , "testId : String -> Element accepts admittedBy msg -> Element accepts admittedBy msg"
    , "testId ="
    , "    HtmlIr.Element.testId"
    ]



-- HTML MODULE


htmlModule : Brand -> List Elm.File
htmlModule brand =
    let
        lib =
            brand.lib

        own =
            brand.comps |> List.filter (\c -> homeOf c == Nothing)

        producer comp =
            [ ""
            , ""
            , doc
                ("The loose `"
                    ++ comp.tag
                    ++ "` producer — open attribute/child rows, elm/html call\nshape. `"
                    ++ lib
                    ++ "."
                    ++ comp.name
                    ++ "` tightens it (closed rows, slot admittance, narrowed values)."
                )
            , comp.resolvedCtor ++ " :"
            , "    List (Attr attrs msg)"
            , "    -> List (Element children childAdmittedBy msg)"
            , "    -> Element produced admittedBy msg"
            , comp.resolvedCtor ++ " attrs children ="
            , "    Ir.fromNode (Ir.node \"" ++ comp.tag ++ "\" attrs (List.map HtmlIr.Element.toNode children))"
            ]
    in
    if List.isEmpty own then
        []

    else
        [ file [ lib, "Html" ]
            (String.join "\n"
                (List.concat
                    [ [ "module " ++ lib ++ ".Html exposing"
                      , exposeBlock
                            [ own |> List.map .resolvedCtor
                            , substrateReExportNames
                            ]
                      , ""
                      , "{-| The loose, elm/html-like producer layer: one open-rowed constructor"
                      , "per element, each owning `Ir.node \"<tag>\"`. This is the foundation the"
                      , "`" ++ lib ++ "-html` package exposes; every rich `" ++ lib ++ ".<Component>` imports"
                      , "its producer here and re-exposes it under a tightened signature. Depends"
                      , "only on the IR substrate — no component module is imported."
                      , ""
                      , "The substrate types are re-exported here too, so a consumer of the"
                      , "published package can write type annotations without importing"
                      , "`HtmlIr.*` directly."
                      , ""
                      , docsBlock
                            [ own |> List.map .resolvedCtor
                            , substrateReExportNames
                            ]
                      , ""
                      , "-}"
                      , ""
                      ]
                    , (substrateReExportImports ++ [ "import HtmlIr.Internal as Ir" ]) |> List.sort
                    , own |> List.concatMap producer
                    , substrateReExportDecls
                    , [ "" ]
                    ]
                )
            )
        ]



-- GENERAL MODULE


generalModule : Brand -> Elm.File
generalModule brand =
    let
        lib =
            brand.lib

        ctorSig comp =
            let
                ref =
                    memberRef brand comp

                q n =
                    lib ++ ".Component." ++ ref.module_ ++ "." ++ ref.prefix ++ n

                -- Single per-component constructor, `component` (post view/el unification).
                -- For home members the flat re-export decl still lives at `comp.ctor`
                -- inside the home module (a loose, everything-optional producer built
                -- directly from `Ir.node`), so those keep re-exporting `comp.ctor`.
                -- Flat members whose `component` demands a required record get the SAME
                -- treatment inline (see `looseBody` below) rather than a point-free
                -- re-export, so the barrel stays the loose, elm/html-shaped surface for
                -- EVERY element — required-ness is a `Component`-surface-only concept.
                target =
                    case homeOf comp of
                        Nothing ->
                            lib ++ ".Component." ++ comp.name ++ ".component"

                        Just _ ->
                            lib ++ ".Component." ++ ref.module_ ++ "." ++ comp.ctor

                childType =
                    if comp.transparent then
                        "childAccepts"

                    else
                        case comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head |> Maybe.map .content of
                            Just Permissive ->
                                "childAccepts"

                            Just (SetContent set) ->
                                lib ++ ".Kind." ++ set.pascal

                            Just (Fields _) ->
                                q "Content"

                            Nothing ->
                                "childAccepts"

                produced =
                    if comp.transparent then
                        "childAccepts"

                    else
                        "(" ++ q "Is" ++ " s)"

                ret =
                    case comp.admittedBy of
                        Just _ ->
                            "Element " ++ produced ++ " " ++ q "AdmittedBy" ++ " msg"

                        Nothing ->
                            "Element " ++ produced ++ " admittedBy msg"

                -- K7: use the resolved barrel ctor name. When this component's ctor
                -- collides with an _atoms name, resolvedCtor is the full-tag camel
                -- form; otherwise it equals ctor.
                rCtor =
                    comp.resolvedCtor

                -- The barrel re-exports the SAME single `component` function. When a
                -- component has required fields, `component` carries a leading required
                -- record, so the barrel re-export must carry it too (arity match).
                -- Home members keep the loose `comp.ctor` producer, which never has
                -- a required record — only flat (no-home) members can be required.
                requiredRecord =
                    case homeOf comp of
                        Just _ ->
                            Nothing

                        Nothing ->
                            let
                                requiredSlots =
                                    comp.slots |> List.filter .required

                                reqAttrFields =
                                    comp.requiredAttrs |> List.map Naming.camel

                                slotField s =
                                    ( if s.name == "unnamed" then
                                        "content"

                                      else
                                        Naming.camel s.name
                                    , "Element "
                                        ++ (case s.content of
                                                Fields _ ->
                                                    if s.name == "unnamed" then
                                                        q "Content"

                                                    else
                                                        q (Naming.pascal s.name ++ "Slot")

                                                SetContent set ->
                                                    lib ++ ".Kind." ++ set.pascal

                                                Permissive ->
                                                    "childAccepts"
                                           )
                                        ++ " ("
                                        ++ q "ChildAdmittedBy"
                                        ++ " childAdm) msg"
                                    )

                                reqFields =
                                    (requiredSlots |> List.map slotField)
                                        ++ (reqAttrFields |> List.map (\f -> ( f, "String" )))
                                        ++ (case comp.actionCaps of
                                                Just _ ->
                                                    [ ( "action", "Ac.Action (" ++ q "ActionCaps" ++ ") msg" ) ]

                                                Nothing ->
                                                    []
                                           )
                            in
                            if List.isEmpty reqFields then
                                Nothing

                            else
                                Just
                                    ("{ "
                                        ++ (reqFields |> List.map (\( n, t ) -> n ++ " : " ++ t) |> String.join "\n    , ")
                                        ++ " }"
                                    )

                -- The barrel is the loose, elm/html-shaped surface for every element —
                -- ALWAYS two positional lists (attrs, children), regardless of whether
                -- the tightened `Component.<E>.component` demands a required record.
                -- (Required-ness is a `Component`-surface concept; the barrel's own
                -- narrowed types still come from that module, only the arity/body
                -- diverge when a record would otherwise be forced.)
                sigLines =
                    [ "    List (Attr " ++ q "Attrs" ++ " msg)"
                    , "    -> List (Element " ++ childType ++ " (" ++ q "ChildAdmittedBy" ++ " childAdm) msg)"
                    , "    -> " ++ ret
                    ]

                -- When `component` requires a record, the barrel can't point-free
                -- re-export it (arity mismatch) — build the loose `Ir.node "<tag>"`
                -- producer directly instead, same as `M3e.Html`'s internal layer,
                -- but keeping this component's own narrowed types.
                looseBody =
                    [ rCtor ++ " attrs children ="
                    , "    Ir.fromNode (Ir.node \"" ++ comp.tag ++ "\" attrs (List.map HtmlIr.Element.toNode children))"
                    ]

                bodyLines =
                    case requiredRecord of
                        Just _ ->
                            looseBody

                        Nothing ->
                            [ rCtor ++ " ="
                            , "    " ++ target
                            ]

                docLine =
                    case requiredRecord of
                        Just _ ->
                            "The loose `" ++ comp.tag ++ "` producer — open attribute/child rows, no required record. See `" ++ target ++ "` for the required-content form."

                        Nothing ->
                            "See `" ++ target ++ "`."
            in
            [ ""
            , ""
            , doc docLine
            , rCtor ++ " :"
            ]
                ++ sigLines
                ++ bodyLines

        atoms =
            brand.atoms
                |> List.concatMap
                    (\role ->
                        [ ""
                        , ""
                        , doc ("The shared " ++ role ++ " atom — admissible into any library's opted-in slot.")
                        , role ++ " : String -> Element { s | shared" ++ Naming.pascal role ++ " : Shared } admittedBy msg"
                        , role ++ " value_ ="
                        , "    Ir.fromNode (Ir.text value_)"
                        ]
                    )

        slotPlacerResult =
            looseSlotPlacers brand

        slotPlacerNames =
            slotPlacerResult.placers |> List.map .ident

        -- Design C loose slot placer declarations.
        -- One placer per distinct HTML slot name; broad open `accepts` row (the
        -- same single-import trade-off as `M3e.Attributes.variant`). Wrong-kind
        -- narrowing is deferred to elm-review `ValidSlotKind`.
        slotPlacerDecls =
            slotPlacerResult.placers
                |> List.concatMap
                    (\p ->
                        [ ""
                        , ""
                        , doc
                            ("Place a child element into the `\""
                                ++ p.htmlName
                                ++ "\"` named slot. Broad admittance by design — wrong-kind placements are flagged by the `Cem.ValidSlotKind` elm-review rule."
                            )
                        , p.ident ++ " : Element accepts admittedBy msg -> Element free freeAdm msg"
                        , p.ident ++ " el_ ="
                        , "    Ir.fromNode (Ir.addAttribute (Ir.attribute \"slot\" \"" ++ p.htmlName ++ "\") (HtmlIr.Element.toNode el_))"
                        ]
                    )

        needsKindImport =
            brand.comps
                |> List.any
                    (\c ->
                        case c.slots |> List.filter (\s -> s.name == "unnamed") |> List.head |> Maybe.map .content of
                            Just (SetContent _) ->
                                True

                            _ ->
                                False
                    )

        -- A flat component whose `component` ctor requires a record forces the
        -- barrel's loose Ir.node body (see `ctorSig`'s `looseBody`).
        anyFlatRequiredContent =
            brand.comps
                |> List.any
                    (\c ->
                        homeOf c
                            == Nothing
                            && (not (List.isEmpty (c.slots |> List.filter .required))
                                    || not (List.isEmpty c.requiredAttrs)
                                    || c.actionCaps /= Nothing
                               )
                    )

        -- Ir is needed for atoms, slot placers (Ir.fromNode, Ir.addAttribute,
        -- Ir.attribute), AND any flat required-content component's loose body.
        needsIrImport =
            not (List.isEmpty brand.atoms) || not (List.isEmpty slotPlacerResult.placers) || anyFlatRequiredContent

        imports =
            (substrateReExportImports
                ++ (if needsIrImport then
                        [ "import HtmlIr.Internal as Ir" ]

                    else
                        []
                   )
                ++ (if List.isEmpty brand.atoms then
                        []

                    else
                        [ "import HtmlIr.Kind exposing (Shared)" ]
                   )
                ++ (brand.comps
                        |> List.map (\c -> "import " ++ lib ++ ".Component." ++ (memberRef brand c).module_)
                        |> List.foldr
                            (\i acc ->
                                if List.member i acc then
                                    acc

                                else
                                    i :: acc
                            )
                            []
                   )
                ++ (if needsKindImport then
                        [ "import " ++ lib ++ ".Kind" ]

                    else
                        []
                   )
            )
                |> List.sort
    in
    file [ lib ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ " exposing"
                  , exposeBlock
                        [ brand.comps |> List.map .resolvedCtor
                        , brand.atoms
                        , slotPlacerNames
                        , substrateReExportNames
                        ]
                  , ""
                  , "{-| The general surface: every component constructor in the elm/html call"
                  , "shape, one import. Signatures reference each component's aliases — reach for"
                  , "`" ++ lib ++ ".<Component>` when you want the strict per-component surface (required"
                  , "content, builder, narrowed values), and `" ++ lib ++ ".Attributes` / `" ++ lib ++ ".Events` /"
                  , "`" ++ lib ++ ".Values` for the shared vocabulary."
                  , ""
                  , "`toHtml` is the render bridge to `elm/html`."
                  , ""
                  , "The `slot<Name>` placers assign a child element to a named slot in any"
                  , "component that accepts it. Admittance is open (broad row) — wrong-kind"
                  , "placements are caught by `Cem.ValidSlotKind` (elm-review)."
                  , ""
                  , docsBlock
                        [ brand.comps |> List.map .resolvedCtor
                        , brand.atoms
                        , slotPlacerNames
                        , substrateReExportNames
                        ]
                  , ""
                  , "-}"
                  , ""
                  ]
                , imports
                , brand.comps |> List.concatMap ctorSig
                , atoms
                , slotPlacerDecls
                , substrateReExportDecls
                , [ "" ]
                ]
            )
        )



-- ATTRIBUTES MODULE


attributesModule : Brand -> Elm.File
attributesModule brand =
    let
        lib =
            brand.lib

        -- Exposed global setter names: the brand globals plus the companion
        -- setters `classList` / `styleList`, which SHARE their partner's
        -- capability row (so they are extra setters, not extra capability
        -- fields). The pairs mirror elm/html exactly:
        --
        --   class : String                     classList : List (String, Bool)
        --   style : String -> String           styleList : List (String, String)
        --
        -- `style` is the elm 0.19 two-argument form (one declaration) and
        -- `styleList` the 0.18 form (many). Both emit `Ir.styles`, so
        -- declarations MERGE across setters the way classes do, instead of the
        -- last `style` attribute clobbering the rest.
        -- `allGlobals`, not `brand.globals`: this list feeds `exposeBlock` AND
        -- `docsBlock`, so an open global missing here is DECLARED but never EXPOSED —
        -- private to its own module, unreachable from any consumer, and invisible in
        -- elm-typed-html's own build (nothing there imports it). It surfaces as a
        -- mystery "I don't recognize this name" in a downstream brand instead.
        globalNames =
            List.map .elmName (allGlobals brand)
                ++ companionOf "class" "classList"
                ++ companionOf "style" "styleList"

        companionOf global companion =
            if isGlobalName brand global then
                [ companion ]

            else
                []

        globalDoc g =
            case g.elmName of
                "slot" ->
                    "The global `slot` attribute (named-slot placement by hand)."

                "class" ->
                    "The global `class` attribute. Repeats ACCUMULATE: `[ class \"a\", class \"b\" ]` renders `class=\"a b\"`."

                "style" ->
                    "One inline-style declaration (the `elm/html` 0.19 shape). Declarations MERGE across every `style` / `styleList` on the element, last-wins per property."

                _ ->
                    "The global `" ++ g.htmlName ++ "` attribute."

        globals =
            brand.globals
                |> List.concatMap
                    (\g ->
                        case g.elmName of
                            "style" ->
                                -- Two arguments, and `Ir.styles` rather than a
                                -- pre-joined attribute string: the IR merges
                                -- declarations per property, which a whole
                                -- cssText blob cannot participate in.
                                [ ""
                                , ""
                                , doc (globalDoc g)
                                , "style : String -> String -> Attr { c | style : Supported } msg"
                                , "style property value_ ="
                                , "    Ir.styles [ ( property, value_ ) ]"
                                , ""
                                , ""
                                , doc "Inline-style declarations as a `( property, value )` list (the `elm/html` 0.18 shape). Merges exactly as `style` does."
                                , "styleList : List ( String, String ) -> Attr { c | style : Supported } msg"
                                , "styleList ="
                                , "    Ir.styles"
                                ]

                            "class" ->
                                [ ""
                                , ""
                                , doc (globalDoc g)
                                , "class : String -> Attr { c | class : Supported } msg"
                                , "class ="
                                , "    Ir.attribute \"class\""
                                , ""
                                , ""
                                , doc "The classes whose flag is `True`, space-joined. Accumulates with every other `class` / `classList` on the element."
                                , "classList : List ( String, Bool ) -> Attr { c | class : Supported } msg"
                                , "classList pairs ="
                                , "    Ir.attribute \"class\" (String.join \" \" (List.map Tuple.first (List.filter Tuple.second pairs)))"
                                ]

                            _ ->
                                -- Every other global is emitted by the SAME two
                                -- setter emitters the shared vocabulary uses, keyed
                                -- off its `_globals` type: `Bool` globals get the
                                -- present/absent body, `Int`/`Float` the stringified
                                -- one, enum globals the `Value <Row>` one. Routing
                                -- them through a bespoke switch here is how they all
                                -- ended up `String -> Attr` in the first place.
                                case ( isEnumSpec g, unionFor brand g.elmName ) of
                                    ( True, Just union ) ->
                                        enumSetterDecl False (globalDoc g) g.htmlName union

                                    _ ->
                                        plainSetterDecl False (globalDoc g) g
                    )

        -- The `"row": "open"` globals, through the SAME two emitters with the row flag
        -- flipped. Same routing (enum vs plain), same doc source, same bodies — so an
        -- open global cannot disagree with a closed one about how it reaches the DOM,
        -- only about which elements admit it.
        --
        -- `class` and `style` need no special-case here (unlike the closed block
        -- above): both are closed, per the spec's Non-goals, so the bespoke
        -- `classList`/`styleList` companions never reach this path. Opening either
        -- later means teaching this block their two-argument / companion shapes.
        openGlobalDecls =
            brand.openGlobals
                |> List.concatMap
                    (\g ->
                        case ( isEnumSpec g, unionFor brand g.elmName ) of
                            ( True, Just union ) ->
                                enumSetterDecl True (globalDoc g) g.htmlName union

                            _ ->
                                plainSetterDecl True (globalDoc g) g
                    )

        -- An ENUM GLOBAL lives in `brand.unions` (that is where `<Lib>.Values` mints
        -- its row and tokens) but its setter is emitted by the globals block above,
        -- so it must not be emitted a second time here.
        enumAttrs =
            brand.unions
                |> List.filter (\u -> not (isGlobalName brand u.elmName))

        plainAttrs =
            brand.sharedAttrs
                |> List.filter
                    (\a ->
                        -- An attr that is an ENUM on any component gets ONLY the
                        -- union setter — a second plain setter under the same name
                        -- would clash (e.g. `autocomplete` is enum on form,
                        -- free-string on input).
                        not (isEnumSpec a)
                            && not (List.any (\e -> e.elmName == a.elmName) brand.unions)
                    )

        plainSetter a =
            plainSetterDecl False (controlledDoc brand a) a

        -- The `default*` companions: one per controlled attribute the brand actually
        -- declares somewhere. They live HERE, in the shared vocabulary, alongside the
        -- live-property setters they mirror; the home / per-component modules re-export
        -- them through `reExportBlock`.
        companions =
            companionsFor brand (brandSuppressed brand) plainAttrs

        companionNames =
            companions |> List.map (\( _, n, _ ) -> n)

        companionDecls =
            companions |> List.concatMap (\( c, n, a ) -> companionDecl brand c n a)

        -- The `_variants` ergonomic setters (`stepAsNumber`, `coordsAsInts`), beside the
        -- base setters whose capability row they share. Re-exported by the home /
        -- per-component modules through `reExportBlock`, exactly like the companions.
        variants =
            variantsFor brand plainAttrs

        variantNames =
            variants |> List.map (\( v, _ ) -> v.name)

        variantDecls =
            variants |> List.concatMap (\( v, a ) -> variantDecl v a)

        -- The scalar/free-string setter, with its doc string passed IN: the shared
        -- vocabulary derives it from the CEM description (`Attr.docString`), a global
        -- from `globalDoc`. Everything below the doc line — signature and body — is
        -- shared, so a global can never disagree with a shared attr of the same type
        -- about how it reaches the DOM.
        plainSetterDecl rowOpen docText a =
            let
                -- The ONE line the `row` axis changes. `"c"` admits the setter onto
                -- every element structurally; the refinement admits it only onto
                -- elements whose closed `Attrs` alias declares the field. Argument
                -- type, body and doc are identical either way, which is what makes a
                -- closed entry's output byte-identical to before the axis existed.
                rowType =
                    if rowOpen then
                        "c"

                    else
                        "{ c | " ++ a.capName ++ " : Supported }"

                body =
                    if emitsAsProperty a then
                        -- Controlled attribute → DOM property so it updates
                        -- after user input (NB2c).
                        [ a.elmName ++ " value_ ="
                        , "    Ir.property \"" ++ Attr.propertyName a ++ "\" (" ++ propEncoder a.type_ ++ ")"
                        ]

                    else
                        case ( a.type_, a.reactiveProp ) of
                            ( Attr.ABool, _ ) ->
                                -- Boolean → attribute present/absent (NEVER a JS
                                -- property nor `classList []`): web components
                                -- observe attributes, and the false branch must
                                -- not clobber a sibling `class` (NB2a/NB2b).
                                --
                                -- The false branch is `Ir.none` — genuinely
                                -- nothing. It used to be
                                -- `Html.Attributes.style "" ""`, which is a real
                                -- STYLE fact: visible to `Test.Html.Query`, and
                                -- enough to force a style-bucket diff on every
                                -- node carrying a false boolean.
                                [ a.elmName ++ " value_ ="
                                , "    if value_ then"
                                , "        Ir.attribute \"" ++ a.htmlName ++ "\" \"\""
                                , ""
                                , "    else"
                                , "        Ir.none"
                                ]

                            ( Attr.ANumber, _ ) ->
                                -- Non-controlled number → attribute (serializes to
                                -- SSR; reflects to the property when the CEM links
                                -- one via fieldName). Was Ir.property when
                                -- fieldName-backed, which left it invisible to
                                -- server-rendered markup (#41).
                                [ a.elmName ++ " value_ ="
                                , "    Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromFloat value_)"
                                ]

                            ( Attr.AInt, _ ) ->
                                [ a.elmName ++ " value_ ="
                                , "    Ir.attribute \"" ++ a.htmlName ++ "\" (String.fromInt value_)"
                                ]

                            _ ->
                                [ a.elmName ++ " ="
                                , "    Ir.attribute \"" ++ a.htmlName ++ "\""
                                ]
            in
            [ ""
            , ""
            , doc docText
            , a.elmName ++ " : " ++ setterInputType a ++ " -> Attr " ++ rowType ++ " msg"
            ]
                ++ body

        enumSetter e =
            let
                matchingAttr =
                    brand.sharedAttrs
                        |> List.filter (\a -> a.elmName == e.elmName)
                        |> List.head

                htmlName =
                    matchingAttr
                        |> Maybe.map .htmlName
                        |> Maybe.withDefault e.elmName

                docText =
                    matchingAttr
                        |> Maybe.map Attr.docString
                        |> Maybe.withDefault ("Set the `" ++ e.elmName ++ "` value.")
            in
            enumSetterDecl False docText htmlName e

        -- The `Value <Row>` setter, with its doc string and DOM attribute name passed
        -- IN (the globals block has both to hand; `enumSetter` recovers them from the
        -- shared vocabulary).
        enumSetterDecl rowOpen docText htmlName e =
            let
                rowType =
                    if rowOpen then
                        "c"

                    else
                        "{ c | " ++ e.elmName ++ " : Supported }"
            in
            [ ""
            , ""
            , doc docText
            , e.elmName ++ " : Value " ++ lib ++ ".Values." ++ e.aliasName ++ " -> Attr " ++ rowType ++ " msg"
            , e.elmName ++ " value_ ="
            , "    Ir.attribute \"" ++ htmlName ++ "\" (HtmlIr.Value.toString value_)"
            ]

        -- Any setter emitted as a DOM property needs `Json.Encode`. Globals are never
        -- controlled form props (`value`/`checked`/`selected` are not global), so only
        -- the shared vocabulary and its `_variants` can pull this import in.
        needsEncode =
            (plainAttrs |> List.any emitsAsProperty)
                || (variants |> List.any (\( _, a ) -> emitsAsProperty a))

        -- A brand whose ONLY enums are globals has an empty `enumAttrs` and still needs
        -- these two imports, or the emitted module does not compile.
        -- The "no, this is not missing" paragraph. Every name here IS declared by the
        -- manifest and IS real HTML; what it has no setter for is `elm/virtual-dom`,
        -- which rewrites or ignores the name on the way to the DOM. A setter would
        -- type-check, render, raise no error and do something else — so the surface
        -- omits it, and this note says which kernel function is responsible so the
        -- next reader does not "fix" the gap by adding one back.
        --
        -- Empty for a brand with nothing blocked, which keeps every existing brand's
        -- bytes unchanged. See `Attr.kernelBlockedReason` and `Model.Brand.kernelBlocked`.
        kernelBlockedNote =
            if List.isEmpty brand.kernelBlocked then
                []

            else
                [ ""
                , "**Deliberately absent.** These attributes are declared by the manifest and"
                , "are real HTML, but `elm/virtual-dom` cannot write them, so this library does"
                , "not pretend to: a setter would compile, render, and silently do something"
                , "else. None of them is reachable from Elm at all — reach for a port or a"
                , "custom element instead of restoring a setter here."
                , ""
                ]
                    ++ (brand.kernelBlocked
                            |> List.map (\( name, reason ) -> "  - `" ++ name ++ "` — " ++ reason ++ ".")
                       )

        -- Portmanteau attribute nullaries: `<attr><ValuePascal>` for every (enum attr,
        -- token) pair that is not already claimed by a plain name. The `taken` set
        -- mirrors `guardAttributesModule`'s `allPairs` (minus portmanteaus, which are
        -- computed from it — same logic, same drop rule).
        attrPortmanteauTaken =
            globalNames
                ++ (plainAttrs |> List.map .elmName)
                ++ companionNames
                ++ variantNames
                ++ (enumAttrs |> List.map .elmName)

        attrPortmanteauList =
            enumAttrPortmanteaus brand attrPortmanteauTaken

        attrPortmanteauNames =
            attrPortmanteauList |> List.map .name

        attrPortmanteauDecls =
            attrPortmanteauList
                |> List.concatMap
                    (\p ->
                        [ ""
                        , ""
                        , doc
                            ("Set the `"
                                ++ p.htmlName
                                ++ "` attribute to `\""
                                ++ p.tokenValue
                                ++ "\"`. Portmanteau of `"
                                ++ p.capName
                                ++ "` + `"
                                ++ p.tokenValue
                                ++ "` — for IDE discovery and single-import ergonomics."
                            )
                        , p.name ++ " : Attr { c | " ++ p.capName ++ " : Supported } msg"
                        , p.name ++ " ="
                        , "    Ir.attribute \"" ++ p.htmlName ++ "\" \"" ++ p.tokenValue ++ "\""
                        ]
                    )

        needsValues =
            not (List.isEmpty enumAttrs) || hasEnumGlobal brand

        imports =
            List.concat
                [ [ "import HtmlIr.Attribute exposing (Attr)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (Supported)"
                  ]
                , if needsEncode then
                    [ "import Json.Encode" ]

                  else
                    []
                , if needsValues then
                    [ "import HtmlIr.Value exposing (Value)"
                    , "import " ++ lib ++ ".Values"
                    ]

                  else
                    []
                ]
                |> List.sort
    in
    file [ lib, "Attributes" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Attributes exposing"
                  , exposeBlock
                        [ globalNames
                        , plainAttrs |> List.map .elmName
                        , companionNames
                        , variantNames
                        , enumAttrs |> List.map .elmName
                        , attrPortmanteauNames
                        ]
                  , ""
                  , "{-| The canonical shared attribute vocabulary. Every setter is an open"
                  , "producer (`{ c | attr : Supported }`); each element's closed `Attrs` row"
                  , "decides admittance. Enum setters here close over the library-wide UNION of"
                  , "values — cross-component misuse is caught by elm-review; reach for the"
                  , "per-component setters (`" ++ lib ++ ".<Component>.<attr>`) for compile-tight narrowing."
                  , ""
                  , "Portmanteau setters (`variantRainbow`, `shapeRounded`, …) are nullary"
                  , "aliases that pre-apply one enum token. They exist for IDE discovery:"
                  , "type `variant` and autocomplete lists every value inline. Each claims"
                  , "the same capability row as its base enum setter, so admittance is identical."
                  ]
                , kernelBlockedNote
                , [ ""
                  , docsBlock
                        [ globalNames
                        , plainAttrs |> List.map .elmName
                        , companionNames
                        , variantNames
                        , enumAttrs |> List.map .elmName
                        , attrPortmanteauNames
                        ]
                  , ""
                  , "-}"
                  , ""
                  ]
                , imports
                , globals

                -- Spliced HERE, beside `globals`, because this `List.concat` IS the
                -- emitted file text. `openGlobalDecls` left computed-but-unreferenced
                -- would be dropped with no error from any tool in the chain — the
                -- generator would exit 0, `<Lib>.Attributes` would compile, and the
                -- setter would simply not exist.
                , openGlobalDecls
                , plainAttrs |> List.concatMap plainSetter
                , companionDecls
                , variantDecls
                , enumAttrs |> List.concatMap enumSetter
                , attrPortmanteauDecls
                , [ "" ]
                ]
            )
        )



-- EVENTS MODULE


eventsModule : Brand -> Elm.File
eventsModule brand =
    let
        setters =
            distinctSetterEvents brand
                |> List.concatMap
                    (\ev ->
                        let
                            n =
                                handlerName brand ev
                        in
                        case ev.payload of
                            Just payload ->
                                -- Annotated: bake the standard decoder into a
                                -- payload-typed `(payload -> msg)` setter, and keep
                                -- the `…With` custom-decoder form alongside it.
                                let
                                    ( elmTy, dec ) =
                                        payloadTypeAndDecoder payload
                                in
                                [ ""
                                , ""
                                , doc ("The `" ++ ev.name ++ "` event, decoding the standard `" ++ elmTy ++ "` payload.")
                                , n ++ " : (" ++ elmTy ++ " -> msg) -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ " tagger ="
                                , "    Ir.on \"" ++ ev.name ++ "\" (Json.Decode.map tagger (" ++ dec ++ "))"
                                , ""
                                , ""
                                , doc ("The `" ++ ev.name ++ "` event with a custom payload decoder.")
                                , n ++ "With : Json.Decode.Decoder msg -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ "With ="
                                , "    Ir.on \"" ++ ev.name ++ "\""
                                ]

                            Nothing ->
                                [ ""
                                , ""
                                , doc ("The `" ++ ev.name ++ "` event.")
                                , n ++ " : msg -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ " msg ="
                                , "    Ir.on \"" ++ ev.name ++ "\" (Json.Decode.succeed msg)"
                                , ""
                                , ""
                                , doc ("The `" ++ ev.name ++ "` event with a custom payload decoder.")
                                , n ++ "With : Json.Decode.Decoder msg -> Attr { c | " ++ n ++ " : Supported } msg"
                                , n ++ "With ="
                                , "    Ir.on \"" ++ ev.name ++ "\""
                                ]
                    )
    in
    file [ brand.lib, "Events" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ brand.lib ++ ".Events exposing"
                  , exposeBlock
                        [ distinctSetterEvents brand |> List.concatMap (\e -> [ handlerName brand e, handlerName brand e ++ "With" ]) |> List.sort
                        , [ "delegate" ]
                        ]
                  , ""
                  , "{-| Events as capabilities: each setter is an open producer admitted only by"
                  , "elements whose closed `Attrs` row lists the event — `onClick` on a"
                  , "non-interactive element is a compile error."
                  , ""
                  , "`delegate` is the ONE loud escape for bubbling: it forgets an event's"
                  , "capability so it can be placed on a container and rely on DOM bubbling from an"
                  , "interactive descendant. Pair it with a real interactive child and a keyboard"
                  , "path (lint-checked)."
                  , ""
                  , docsBlock
                        [ distinctSetterEvents brand |> List.concatMap (\e -> [ handlerName brand e, handlerName brand e ++ "With" ]) |> List.sort
                        , [ "delegate" ]
                        ]
                  , ""
                  , "-}"
                  , ""
                  , "import HtmlIr.Attribute exposing (Attr)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (Supported)"
                  , "import Json.Decode"
                  ]
                , setters
                , [ ""
                  , ""
                  , doc "Forget an event's capability row (the bubbling escape)."
                  , "delegate : Attr capability msg -> Attr anyCapability msg"
                  , "delegate attr ="
                  , "    Ir.recast attr"
                  , ""
                  ]
                ]
            )
        )



-- VALUES MODULE


valuesModule : Brand -> Elm.File
valuesModule brand =
    let
        -- Dedup tokens on their resolved Elm identifier (tokenIdentResolved), not the raw
        -- string. Two raw tokens that normalize to the same ident (e.g. "AUTO" and
        -- "auto" both → "auto") must collapse to one emission; without this the
        -- guard would correctly detect a duplicate-identifier collision. The first
        -- raw token (alphabetical order after List.sort) wins.
        tokens =
            brand.unions
                |> List.concatMap .tokens
                |> List.sort
                |> List.foldl
                    (\t acc ->
                        let
                            ident =
                                tokenIdentResolved brand t
                        in
                        if List.any (\existing -> tokenIdentResolved brand existing == ident) acc then
                            acc

                        else
                            acc ++ [ t ]
                    )
                    []

        tokenDecl t =
            let
                n =
                    tokenIdentResolved brand t

                v =
                    tokenValueOf brand t
            in
            [ ""
            , ""
            , doc
                ("The `"
                    ++ t
                    ++ "` token."
                    ++ (if v == t then
                            ""

                        else
                            -- The two differ only for a config `attrTypes` MAP override,
                            -- and then the emitted string is the whole reason the map form
                            -- was used. Saying so in the docs is what stops a reader
                            -- concluding `always` writes `always`.
                            " Writes `\"" ++ v ++ "\"`."
                       )
                )
            , n ++ " : Value { v | " ++ n ++ " : Supported }"
            , n ++ " ="
            , "    Ir.token \"" ++ v ++ "\""
            ]

        unionDecl e =
            [ ""
            , ""
            , doc
                ("The union row for `"
                    ++ e.elmName
                    ++ "`"
                    ++ (case e.provenance of
                            Just p ->
                                " (from `" ++ p ++ "`)"

                            Nothing ->
                                ""
                       )
                    ++ "."
                )
            , "type alias " ++ e.aliasName ++ " ="
            , "    " ++ supportedRow (e.tokens |> List.map (tokenIdentResolved brand))
            ]

        -- The union's tokens paired with the string they actually write, deduped
        -- on that WIRE STRING. Two distinct tokens in one union may render the
        -- same string (an `attrTypes` MAP override permits it: `tokenValues`
        -- guards token→one-string, not string→one-token). They evaluate to the
        -- SAME `Ir.token`, so keeping one is lossless — but keeping both would
        -- emit a duplicate `case` branch and a duplicate list entry. Sort first
        -- so the survivor is deterministic.
        unionTokens e =
            e.tokens
                |> List.sort
                |> List.foldl
                    (\t acc ->
                        let
                            wire =
                                tokenValueOf brand t
                        in
                        if List.any (\( _, w ) -> w == wire) acc then
                            acc

                        else
                            acc ++ [ ( tokenIdentResolved brand t, wire ) ]
                    )
                    []

        fromStringDecl e =
            [ ""
            , ""
            , doc
                ("Parse a `"
                    ++ e.elmName
                    ++ "` value from the string it writes to the DOM. The inverse of `toString`."
                )
            , e.elmName ++ "FromString : String -> Maybe (Value " ++ e.aliasName ++ ")"
            , e.elmName ++ "FromString s ="
            , "    case s of"
            ]
                ++ List.concatMap
                    (\( ident, wire ) ->
                        [ "        \"" ++ wire ++ "\" ->"
                        , "            Just " ++ ident
                        , ""
                        ]
                    )
                    (unionTokens e)
                ++ [ "        _ ->"
                   , "            Nothing"
                   ]

        valuesDecl e =
            [ ""
            , ""
            , doc
                ("Every `"
                    ++ e.elmName
                    ++ "` value. Map a UI over this and adding a value to the manifest cannot silently miss it."
                )
            , e.elmName ++ "Values : List (Value " ++ e.aliasName ++ ")"
            , e.elmName ++ "Values ="
            , "    [ " ++ (unionTokens e |> List.map Tuple.first |> String.join ", ") ++ " ]"
            ]

        -- R5: enum portmanteaus — attribute-prefixed value globals for IDE
        -- discovery (type `variant`, see `variantFilled`, `variantOutlined`, …).
        -- Deduped against the union aliases and bare tokens already claimed.
        portmanteaus =
            enumPortmanteaus brand
                ((brand.unions |> List.map .aliasName)
                    ++ (tokens |> List.map (tokenIdentResolved brand))
                    ++ (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                    ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                    ++ [ "toString" ]
                )

        portmanteauDecl p =
            [ ""
            , ""
            , doc
                ("The `"
                    ++ p.token
                    ++ "` value of the `"
                    ++ p.attr
                    ++ "` enum — same open row as `"
                    ++ p.ident
                    ++ "`, prefixed for discovery."
                )
            , p.name ++ " : Value { v | " ++ p.ident ++ " : Supported }"
            , p.name ++ " ="
            , "    Ir.token \"" ++ tokenValueOf brand p.token ++ "\""
            ]
    in
    file [ brand.lib, "Values" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ brand.lib ++ ".Values exposing"
                  , exposeBlock
                        [ [ "Value" ]
                        , [ "toString" ]
                        , brand.unions |> List.map .aliasName |> List.sort
                        , (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                            ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                            |> List.sort
                        , tokens |> List.map (tokenIdentResolved brand)
                        , portmanteaus |> List.map .name
                        ]
                  , ""
                  , "{-| The enum-value vocabulary: every token minted once (open row), plus the"
                  , "library-wide union row per enum attribute, plus attribute-prefixed"
                  , "portmanteaus (`variantFilled`, `shapeRounded`, …) for IDE discovery."
                  , "General setters close over the union; per-component setters narrow — both"
                  , "are fed by these same tokens."
                  , ""
                  , "`Value` is re-exported here so annotating a token never requires an"
                  , "`HtmlIr.Value` import."
                  , ""
                  , docsBlock
                        [ [ "Value" ]
                        , [ "toString" ]
                        , brand.unions |> List.map .aliasName |> List.sort
                        , (brand.unions |> List.map (\e -> e.elmName ++ "FromString"))
                            ++ (brand.unions |> List.map (\e -> e.elmName ++ "Values"))
                            |> List.sort
                        , tokens |> List.map (tokenIdentResolved brand)
                        , portmanteaus |> List.map .name
                        ]
                  , ""
                  , "-}"
                  , ""
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (Supported)"
                  , "import HtmlIr.Value"
                  , ""
                  , ""
                  , doc "The phantom-tagged enum token. Re-exported so callers never import `HtmlIr.Value` directly."
                  , "type alias Value tags ="
                  , "    HtmlIr.Value.Value tags"
                  , ""
                  , ""
                  , doc "The token's underlying string — the safe out-bound direction. Re-exported so callers never import `HtmlIr.Value` directly."
                  , "toString : Value tags -> String"
                  , "toString ="
                  , "    HtmlIr.Value.toString"
                  ]
                , brand.unions |> List.sortBy .aliasName |> List.concatMap unionDecl
                , brand.unions |> List.sortBy .aliasName |> List.concatMap fromStringDecl
                , brand.unions |> List.sortBy .aliasName |> List.concatMap valuesDecl
                , tokens |> List.concatMap tokenDecl
                , portmanteaus |> List.concatMap portmanteauDecl
                , [ "" ]
                ]
            )
        )



-- KIND MODULE


kindModule : Brand -> Elm.File
kindModule brand =
    let
        roleMarker =
            case brand.aria of
                Just _ ->
                    [ ""
                    , ""
                    , doc "The private ARIA-role marker (never constructed)."
                    , "type Role"
                    , "    = Role_"
                    ]

                Nothing ->
                    []

        markerNames =
            [ "Brand", "Ctx" ]
                ++ (case brand.aria of
                        Just _ ->
                            [ "Role" ]

                        Nothing ->
                            []
                   )

        setDecl s =
            [ ""
            , ""
            , doc ("The `" ++ s.name ++ "` kind set.")
            , "type alias " ++ s.pascal ++ " ="
            , "    " ++ kindRow s.fields
            ]
    in
    file [ brand.lib, "Kind" ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ brand.lib ++ ".Kind exposing"
                  , exposeBlock
                        [ markerNames
                        , [ "Available", "Used" ]
                        , [ "Supported", "Shared" ]
                        , brand.sets |> List.map .pascal
                        ]
                  , ""
                  , "{-| The library's private phantom markers and named kind/context sets."
                  , ""
                  , "`Brand` marks this library's kind-row fields; `Ctx` marks its context-row"
                  , "fields. Both are nominal and private to this library — a foreign library's"
                  , "markers never unify with them, even under the same field name."
                  , "`Available`/`Used` are the pipe-builder's write-once capability markers."
                  , ""
                  , "`Supported` and `Shared` are the CROSS-library markers, re-exported from"
                  , "the IR substrate so callers never import `HtmlIr.Kind` directly. Unlike"
                  , "`Brand`/`Ctx` these are deliberately shared: every brand's `Supported` is"
                  , "the same type, and a `Shared`-marked atom is admissible into any brand's"
                  , "opted-in slot."
                  , ""
                  , docsBlock
                        [ markerNames
                        , [ "Available", "Used" ]
                        , [ "Supported", "Shared" ]
                        , brand.sets |> List.map .pascal
                        ]
                  , ""
                  , "-}"
                  , ""
                  , "import HtmlIr.Kind"
                  , ""
                  , ""
                  , doc "Admission marker for capability and value rows. Re-exported from `HtmlIr.Kind`."
                  , "type alias Supported ="
                  , "    HtmlIr.Kind.Supported"
                  , ""
                  , ""
                  , doc "The cross-library atom marker. Re-exported from `HtmlIr.Kind`."
                  , "type alias Shared ="
                  , "    HtmlIr.Kind.Shared"
                  , ""
                  , ""
                  , doc "The private kind marker (never constructed)."
                  , "type Brand"
                  , "    = Brand_"
                  , ""
                  , ""
                  , doc "The private context marker (never constructed)."
                  , "type Ctx"
                  , "    = Ctx_"
                  ]
                , roleMarker
                , [ ""
                  , ""
                  , doc "Pipe-builder capability: still writable."
                  , "type Available"
                  , "    = Available_"
                  , ""
                  , ""
                  , doc "Pipe-builder capability: consumed."
                  , "type Used"
                  , "    = Used_"
                  ]
                , brand.sets |> List.concatMap setDecl
                , [ "" ]
                ]
            )
        )



-- HOME-GROUPED MODULES (native families: view-only, member-prefixed aliases)


{-| Where a component's constructor lives and which alias prefix it uses:
own-module comps → (<Name>, ""); home members → (<Home>, Pascal ctor when the
home has >1 member, "" when it is a single-member home).
-}
memberRef : Brand -> Comp -> { module_ : String, prefix : String }
memberRef brand comp =
    case homeOf comp of
        Nothing ->
            { module_ = comp.name, prefix = "" }

        Just h ->
            let
                groupSize =
                    brand.comps |> List.filter (\c -> homeOf c == Just h) |> List.length
            in
            { module_ = h
            , prefix =
                if groupSize > 1 then
                    Naming.pascal comp.ctor

                else
                    ""
            }


{-| A member's Attrs field list, with the ARIA `role` field folded in
(role-gated members pin `role : <P>Roles`; un-gated get `role : Supported`
only when the brand has ARIA data at all).
-}
memberAttrsRow : Brand -> String -> Comp -> String
memberAttrsRow brand prefix comp =
    let
        base =
            attrsFields brand comp |> List.map (\f -> ( f, "Supported" ))

        withRole =
            case ( brand.aria, comp.roles ) of
                ( Just _, Just _ ) ->
                    ( "role", prefix ++ "Roles" ) :: base

                ( Just _, Nothing ) ->
                    ( "role", "Supported" ) :: base

                _ ->
                    base
    in
    "{ "
        ++ (withRole
                |> List.sortBy Tuple.first
                |> List.map (\( f, t ) -> f ++ " : " ++ t)
                |> String.join "\n    , "
           )
        ++ "\n    }"


homeModule : Brand -> ( String, List Comp ) -> Elm.File
homeModule brand ( home, members ) =
    let
        lib =
            brand.lib

        prefixOf comp =
            (memberRef brand comp).prefix

        anyShared =
            members
                |> List.any
                    (\c ->
                        c.produces.marker
                            == MShared
                            || (c.slots
                                    |> List.any
                                        (\s ->
                                            case s.content of
                                                Fields fs ->
                                                    List.any (\f -> f.marker == MShared) fs

                                                _ ->
                                                    False
                                        )
                               )
                    )

        anyRoles =
            members |> List.any (\c -> c.roles /= Nothing)

        anyBrandMarker =
            members
                |> List.any
                    (\c ->
                        (c.produces.marker == MBrand && not c.transparent)
                            || (c.slots
                                    |> List.any
                                        (\s ->
                                            case s.content of
                                                Fields fs ->
                                                    List.any (\f -> f.marker == MBrand) fs

                                                _ ->
                                                    False
                                        )
                               )
                    )

        ( reExportNames, reExportDecls, reExportNeedsValues ) =
            reExportBlock brand
                (lib ++ ".Attributes")
                (members |> List.map .ctor)
                -- A home module's members share one re-export block, so a companion is
                -- suppressed here only when EVERY member declaring that attribute is
                -- `propertyOnly` for it. A mixed home (one element with a backing
                -- content attribute, one without) keeps the companion: the row is
                -- shared by design, so this is the honest limit of the mechanism.
                (dedup
                    (brand.controlled
                        |> List.filterMap
                            (\c ->
                                let
                                    owners =
                                        members
                                            |> List.filter (\comp -> comp.attrs |> List.any (\a -> a.htmlName == c.htmlName))
                                in
                                if not (List.isEmpty owners) && List.all (\comp -> List.member c.htmlName comp.propertyOnly) owners then
                                    Just c.htmlName

                                else
                                    Nothing
                            )
                    )
                )
                (members |> List.concatMap .attrs |> dedupBy_ .elmName)

        memberAliasNames comp =
            let
                p =
                    prefixOf comp
            in
            List.concat
                [ if comp.transparent then
                    []

                  else
                    [ p ++ "Is" ]
                , [ p ++ "Attrs" ]
                , comp.slots
                    |> List.filterMap
                        (\s ->
                            case ( s.name, s.content ) of
                                ( "unnamed", Fields _ ) ->
                                    Just (p ++ "Content")

                                _ ->
                                    Nothing
                        )
                , [ p ++ "ChildAdmittedBy" ]
                , case comp.admittedBy of
                    Just _ ->
                        [ p ++ "AdmittedBy" ]

                    Nothing ->
                        []
                , case comp.roles of
                    Just _ ->
                        [ p ++ "Roles" ]

                    Nothing ->
                        []
                ]

        exposeGroups =
            [ members |> List.map .ctor
            , members |> List.concatMap memberAliasNames
            , reExportNames
            ]

        memberDecls comp =
            let
                p =
                    prefixOf comp

                contentType =
                    case comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head |> Maybe.map .content of
                        Just Permissive ->
                            "childAccepts"

                        Just (SetContent set) ->
                            -- Set aliases live in <Lib>.Kind; home modules
                            -- reference them QUALIFIED (they import Kind
                            -- exposing only the markers).
                            lib ++ ".Kind." ++ set.pascal

                        Just (Fields _) ->
                            p ++ "Content"

                        Nothing ->
                            "childAccepts"

                producedType =
                    if comp.transparent then
                        "childAccepts"

                    else
                        "(" ++ p ++ "Is s)"

                returnAdm =
                    case comp.admittedBy of
                        Just _ ->
                            p ++ "AdmittedBy"

                        Nothing ->
                            "admittedBy"

                childrenType =
                    if comp.transparent then
                        "List (Element childAccepts (" ++ p ++ "ChildAdmittedBy childAdm) msg)"

                    else
                        "List (Element " ++ contentType ++ " (" ++ p ++ "ChildAdmittedBy childAdm) msg)"
            in
            List.concat
                [ if comp.transparent then
                    []

                  else
                    [ ""
                    , ""
                    , doc ("The kind row `" ++ comp.tag ++ "` produces.")
                    , "type alias " ++ p ++ "Is s ="
                    , "    { s | " ++ comp.produces.field ++ " : " ++ markerName comp.produces.marker ++ " }"
                    ]
                , [ ""
                  , ""
                  , doc ("`" ++ comp.tag ++ "`'s closed attribute-capability row.")
                  , "type alias " ++ p ++ "Attrs ="
                  , "    " ++ memberAttrsRow brand p comp
                  ]
                , comp.slots
                    |> List.concatMap
                        (\s ->
                            case ( s.name, s.content ) of
                                ( "unnamed", Fields fs ) ->
                                    [ ""
                                    , ""
                                    , doc ("The kinds `" ++ comp.tag ++ "` admits.")
                                    , "type alias " ++ p ++ "Content ="
                                    , "    " ++ kindRowCompact fs
                                    ]

                                _ ->
                                    []
                        )
                , [ ""
                  , ""
                  , doc ("The context demand `" ++ comp.tag ++ "` injects into its children.")
                  , "type alias " ++ p ++ "ChildAdmittedBy childAdm ="
                  , "    { childAdm | " ++ comp.ctor ++ " : Ctx }"
                  ]
                , case comp.admittedBy of
                    Just parents ->
                        [ ""
                        , ""
                        , doc ("The CLOSED parent contexts `" ++ comp.tag ++ "` is valid inside.")
                        , "type alias " ++ p ++ "AdmittedBy ="
                        , "    { " ++ (parents |> List.map (\pp -> pp ++ " : Ctx") |> String.join ", ") ++ " }"
                        ]

                    Nothing ->
                        []
                , case comp.roles of
                    Just roles ->
                        [ ""
                        , ""
                        , doc ("The ARIA roles `" ++ comp.tag ++ "` admits (see `" ++ lib ++ ".Aria`).")
                        , "type alias " ++ p ++ "Roles ="
                        , "    { "
                            ++ (roles |> List.sort |> List.map (\r -> roleName r ++ " : Role") |> String.join "\n    , ")
                            ++ "\n    }"
                        ]

                    Nothing ->
                        []
                , [ ""
                  , ""
                  , doc
                        ("The `"
                            ++ comp.tag
                            ++ "` element."
                            ++ (if comp.transparent then
                                    " Transparent content model: its produced kind row IS its\nchildren's accepts row — it inherits its context's content model."

                                else
                                    ""
                               )
                        )
                  , comp.ctor ++ " :"
                  , "    List (Attr " ++ p ++ "Attrs msg)"
                  , "    -> " ++ childrenType
                  , "    -> Element " ++ producedType ++ " " ++ returnAdm ++ " msg"
                  , comp.ctor ++ " attrs children ="
                  , "    Ir.fromNode (Ir.node \"" ++ comp.tag ++ "\" attrs (List.map HtmlIr.Element.toNode children))"
                  ]
                ]

        imports =
            List.concat
                [ [ "import HtmlIr.Attribute exposing (Attr)"
                  , "import HtmlIr.Element exposing (Element)"
                  , "import HtmlIr.Internal as Ir"
                  ]
                , [ "import HtmlIr.Kind exposing ("
                        ++ ((if anyShared then
                                [ "Shared", "Supported" ]

                             else
                                [ "Supported" ]
                            )
                                |> String.join ", "
                           )
                        ++ ")"
                  ]
                , if reExportNeedsValues then
                    [ "import HtmlIr.Value exposing (Value)"
                    , "import " ++ lib ++ ".Values"
                    ]

                  else
                    []
                , if needsJsonEncodeImport brand (members |> List.concatMap .attrs) then
                    [ "import Json.Encode" ]

                  else
                    []
                , if List.isEmpty reExportNames then
                    []

                  else
                    [ "import " ++ lib ++ ".Attributes" ]
                , [ "import "
                        ++ lib
                        ++ ".Kind exposing ("
                        ++ (((if anyBrandMarker then
                                [ "Brand", "Ctx" ]

                              else
                                [ "Ctx" ]
                             )
                                ++ (if anyRoles then
                                        [ "Role" ]

                                    else
                                        []
                                   )
                            )
                                |> List.sort
                                |> String.join ", "
                           )
                        ++ ")"
                  ]
                ]
                |> List.sort
    in
    file [ lib, "Component", home ]
        (String.join "\n"
            (List.concat
                [ [ "module " ++ lib ++ ".Component." ++ home ++ " exposing"
                  , exposeBlock exposeGroups
                  , ""
                  , "{-| The `" ++ home ++ "` element home: constructors, per-element rows, and"
                  , "co-located re-exports of the shared attributes its elements admit."
                  , ""
                  , docsBlock exposeGroups
                  , ""
                  , "-}"
                  , ""
                  ]
                , imports
                , members |> List.sortBy .ctor |> List.concatMap memberDecls
                , reExportDecls
                , [ "" ]
                ]
            )
        )



-- REVIEW FACTS (the elm-review-cem contract, emitted from the phantom model)


factsModule : Brand -> Elm.File
factsModule brand =
    let
        lib =
            brand.lib

        str s =
            "\"" ++ s ++ "\""

        strList xs =
            "[ " ++ (xs |> List.map str |> String.join ", ") ++ " ]"

        pairList ps =
            "[ " ++ (ps |> List.map (\( a, b ) -> "( " ++ str a ++ ", " ++ str b ++ " )") |> String.join ", ") ++ " ]"

        enumPairs es =
            "[ "
                ++ (es
                        |> List.map (\e -> "( " ++ str e.elmName ++ ", " ++ strList (List.map (tokenIdentResolved brand) e.tokens) ++ " )")
                        |> String.join ", "
                   )
                ++ " ]"

        slotKindPairs comp =
            -- Permissive (kind-`any`) slots are OMITTED: an unlisted slot is
            -- unchecked by ValidSlotKind (listing "arbitrary" as a literal
            -- kind made everything a violation).
            "[ "
                ++ (comp.slots
                        |> List.filterMap
                            (\s ->
                                let
                                    -- The Cem.Facts contract speaks the CONFIG
                                    -- vocabulary: shared atoms are
                                    -- "shared:<role>", brand kinds are ctor
                                    -- names (field == ctor for private kinds).
                                    kindString f =
                                        case f.marker of
                                            MShared ->
                                                "shared:" ++ Naming.decapitalize (String.dropLeft 6 f.field)

                                            MBrand ->
                                                f.field
                                in
                                case s.content of
                                    Permissive ->
                                        Nothing

                                    SetContent set ->
                                        Just ( s.name, set.fields |> List.map kindString )

                                    Fields fs ->
                                        Just ( s.name, fs |> List.map kindString )
                            )
                        |> List.map (\( n, kinds ) -> "( " ++ str n ++ ", " ++ strList kinds ++ " )")
                        |> String.join ", "
                   )
                ++ " ]"

        facetsOf comp =
            "[ Standard"
                ++ (if not (List.isEmpty (comp.slots |> List.filter .required)) || comp.actionCaps /= Nothing then
                        ", Record"

                    else
                        ""
                   )
                ++ ", Build ]"

        factOf comp =
            let
                moduleName =
                    lib ++ ".Component." ++ (memberRef brand comp).module_

                attrRewrites =
                    (comp.attrs |> List.map (\a -> ( a.elmName, a.elmName )))
                        -- The `default*` companions are real setters on this component's
                        -- module, so elm-review's barrel/per-component rules have to see
                        -- them; an unlisted setter reads as "not an attr of this element".
                        ++ (companionsFor brand comp.propertyOnly comp.attrs |> List.map (\( _, n, _ ) -> ( n, n )))
                        -- …and so are the `_variants` setters.
                        ++ (variantsFor brand comp.attrs |> List.map (\( v, _ ) -> ( v.name, v.name )))
                        ++ (comp.events |> List.map (\e -> ( handlerName brand e, handlerName brand e )))

                namedSlots =
                    comp.slots |> List.filter (\s -> s.name /= "unnamed")
            in
            String.join "\n"
                [ "    { component = " ++ str comp.ctor
                , "    , module_ = " ++ str moduleName
                , "    , enums = " ++ enumPairs comp.enums
                , "    , requiredSlots = " ++ strList (comp.slots |> List.filter .required |> List.map .name)
                , "    , multiSlots = " ++ strList (comp.slots |> List.filter .multi |> List.map .name)
                , "    , attrRewrites = " ++ pairList attrRewrites
                , "    , slotRewrites = " ++ pairList (namedSlots |> List.map (\s -> ( s.name, Naming.camel s.name )))
                , "    , slotKinds = " ++ slotKindPairs comp
                , "    , slotUpgrades = []"
                , "    , groupConstructors = []"
                , "    , facets = " ++ facetsOf comp
                , "    , requiredAttrs = " ++ strList comp.requiredAttrs
                , "    , actionMap = " ++ pairList comp.actionMap
                , "    , usesAction = "
                    ++ (if comp.actionCaps /= Nothing then
                            "True"

                        else
                            "False"
                       )
                , "    }"
                ]
    in
    file [ lib, "Review", "Facts" ]
        (String.join "\n"
            [ "module " ++ lib ++ ".Review.Facts exposing (facts, globalAttributes, reExposedValueTokens)"
            , ""
            , "{-| GENERATED review facts for the elm-review-cem rules (phantom pipeline)."
            , ""
            , "@docs facts, globalAttributes, reExposedValueTokens"
            , ""
            , "-}"
            , ""
            , "import Cem.Facts exposing (Fact, Facet(..))"
            , ""
            , ""
            , "{-| Per-component facts."
            , "-}"
            , "facts : List Fact"
            , "facts ="
            , "    [ "
                ++ (brand.comps |> List.map factOf |> String.join "\n    , " |> String.dropLeft 4)
            , "    ]"
            , ""
            , ""
            , "{-| The document-wide attributes EVERY element of this brand admits — the"
            , "`_globals` roster."
            , ""
            , "Emitted for the escape-discipline rules, which may only suggest a typed"
            , "setter when the attribute's meaning is **element-independent**. A global"
            , "qualifies by definition; an element-specific attribute does not, because from"
            , "an escape call site `content` on a `<meta>` is indistinguishable from"
            , "`content` on a custom element that gives the name its own meaning."
            , ""
            , "-}"
            , "globalAttributes : List String"
            , "globalAttributes ="

            -- Both row shapes: `globalAttributes` answers "is this attribute's
            -- meaning element-INDEPENDENT?", which is the very property that
            -- justified opening the row. Reading `brand.globals` alone would
            -- silently shrink this roster the moment a brand opened an entry.
            , "    " ++ strList (allGlobals brand |> List.map .htmlName |> List.sort)
            , ""
            , ""
            , "{-| Kept for the PreferBarrel flatten class; inert on the phantom surface."
            , "-}"
            , "reExposedValueTokens : List String"
            , "reExposedValueTokens ="
            , "    []"
            , ""
            ]
        )



-- UNSAFE MODULE (the ONE loud legacy-Html escape, when `_legacyHtml` is set)


unsafeModule : Brand -> List Elm.File
unsafeModule brand =
    if not brand.legacyHtml then
        []

    else
        [ file [ brand.lib, "Unsafe" ]
            (String.join "\n"
                [ "module " ++ brand.lib ++ ".Unsafe exposing (customElement, fromHtml, fromNode, recast, recastAll)"
                , ""
                , "{-| THE loud legacy-interop escapes: wrap raw `Html` as an `Element`,"
                , "re-assert rows on an erased `Node`, re-kind an existing `Element`, or forge"
                , "an element from a tag name this library has no generated producer for — all"
                , "with FREE phantom rows, so the compiler checks nothing about the result. For"
                , "incremental migration and slot-fit only; every use site is a grep target and"
                , "a lint finding."
                , ""
                , "@docs fromHtml"
                , "@docs fromNode"
                , "@docs recast, recastAll"
                , "@docs customElement"
                , ""
                , "-}"
                , ""
                , "import Html exposing (Html)"
                , "import HtmlIr.Attribute exposing (Attr)"
                , "import HtmlIr.Element exposing (Element)"
                , "import HtmlIr.Internal as Ir"
                , "import HtmlIr.Node exposing (Node)"
                , ""
                , ""
                , doc "Wrap raw `Html` with FREE rows. Loud on purpose."
                , "fromHtml : Html msg -> Element accepts admittedBy msg"
                , "fromHtml h ="
                , "    Ir.fromNode (Ir.fromHtml h)"
                , ""
                , ""
                , doc "Re-assert FREE rows on an erased [`Node`](HtmlIr-Node#Node) — the exact dual of the safe `HtmlIr.Element.toNode`. For the boundary where a typed tree was flattened to the IR and must be lifted back (a framework `View` record, a cache). Loud on purpose: the rows it re-asserts were never checked."
                , "fromNode : Node msg -> Element accepts admittedBy msg"
                , "fromNode ="
                , "    Ir.fromNode"
                , ""
                , ""
                , doc "Re-kind an `Element` to FREE rows so it fits any slot — the blessed form of the hand-forged `Ir.fromNode << HtmlIr.Element.toNode` recast. Loud on purpose."
                , "recast : Element aAccepts aAdmittedBy msg -> Element bAccepts bAdmittedBy msg"
                , "recast element ="
                , "    Ir.fromNode (HtmlIr.Element.toNode element)"
                , ""
                , ""
                , doc "`recast` mapped over a list of elements."
                , "recastAll : List (Element aAccepts aAdmittedBy msg) -> List (Element bAccepts bAdmittedBy msg)"
                , "recastAll ="
                , "    List.map recast"
                , ""
                , ""
                , doc "Forge an element from a raw tag name, with FREE rows — for a CUSTOM ELEMENT this library has no generated producer for (`<model-viewer>`, `<slide-panels>`). Loud on purpose: for a standard HTML tag reach for the native brand's typed constructor instead, and for a component this library already ships, use that."
                , "customElement : String -> List (Attr capability msg) -> List (Element childAccepts childAdmittedBy msg) -> Element accepts admittedBy msg"
                , "customElement tagName attrs children ="
                , "    Ir.fromNode (Ir.node tagName attrs (List.map HtmlIr.Element.toNode children))"
                , ""
                ]
            )
        , file [ brand.lib, "Unsafe", "Attributes" ]
            (String.join "\n"
                [ "module " ++ brand.lib ++ ".Unsafe.Attributes exposing (customAttribute, fromHtmlAttribute, recastAttr, recastAttrAll)"
                , ""
                , "{-| The attribute-side twins of [`" ++ brand.lib ++ ".Unsafe`](" ++ brand.lib ++ "-Unsafe): lift a raw"
                , "`Html.Attribute`, re-kind an existing `Attr`, or set an attribute this library"
                , "has no typed setter for — all with a FREE capability row, so the compiler checks"
                , "nothing about which element the attribute may land on. For incremental migration"
                , "and slot-fit only; every use site is a grep target and a lint finding."
                , ""
                , "@docs fromHtmlAttribute"
                , "@docs recastAttr, recastAttrAll"
                , "@docs customAttribute"
                , ""
                , "-}"
                , ""
                , "import Html"
                , "import Html.Attributes"
                , "import HtmlIr.Attribute exposing (Attr)"
                , "import HtmlIr.Internal as Ir"
                , ""
                , ""
                , doc "Lift a raw `Html.Attribute` into an `Attr` with a FREE capability row. Loud on purpose."
                , "fromHtmlAttribute : Html.Attribute msg -> Attr capability msg"
                , "fromHtmlAttribute ="
                , "    Ir.fromHtmlAttribute"
                , ""
                , ""
                , doc "Re-kind an `Attr` to a FREE capability row so it fits any element — the attribute-side recast. Loud on purpose."
                , "recastAttr : Attr aCapability msg -> Attr bCapability msg"
                , "recastAttr attr ="
                , "    Ir.recast attr"
                , ""
                , ""
                , doc "`recastAttr` mapped over a list of attributes."
                , "recastAttrAll : List (Attr aCapability msg) -> List (Attr bCapability msg)"
                , "recastAttrAll ="
                , "    List.map recastAttr"
                , ""
                , ""
                , doc ("Set an attribute by raw name, with a FREE capability row — the twin of `" ++ brand.lib ++ ".Unsafe.customElement`, for the custom-element attributes this library has no typed setter for (`active-index`, `camera-controls`). Loud on purpose: for an attribute the library DOES model, use its typed setter, which checks the element admits it.")
                , "customAttribute : String -> String -> Attr capability msg"
                , "customAttribute name value ="
                , "    Ir.fromHtmlAttribute (Html.Attributes.attribute name value)"
                , ""
                ]
            )
        ]



-- ACTION MODULE (m3e behavioural actions — emitted from the _actions roster)


actionModule : Brand -> List Elm.File
actionModule brand =
    case brand.actions of
        Nothing ->
            []

        Just roster ->
            let
                lib =
                    brand.lib

                tagOf compName =
                    brand.comps
                        |> List.filter (\c -> c.name == compName)
                        |> List.head
                        |> Maybe.map .tag

                -- roster entries whose wrapper component exists in the manifest
                forW =
                    roster.forWrappers
                        |> List.filterMap (\w -> tagOf w.comp |> Maybe.map (\tag -> ( w, tag )))

                nullW =
                    roster.nullaryWrappers
                        |> List.filterMap (\w -> tagOf w.comp |> Maybe.map (\tag -> ( w, tag )))

                bottomSheet =
                    roster.bottomSheetComp |> Maybe.andThen (\c -> tagOf c |> Maybe.map (Tuple.pair c))

                dialogAction =
                    roster.dialogActionComp |> Maybe.andThen (\c -> tagOf c |> Maybe.map (Tuple.pair c))

                payloadVariants =
                    [ "None", "OnClick msg", "Link LinkSpec", "Remove msg" ]
                        ++ (forW |> List.map (\( w, _ ) -> w.variant ++ " String"))
                        ++ (nullW |> List.map (\( w, _ ) -> w.variant))
                        ++ (bottomSheet |> Maybe.map (\_ -> [ "OpensBottomSheet BottomSheetSpec" ]) |> Maybe.withDefault [])
                        ++ (dialogAction |> Maybe.map (\_ -> [ "DialogAction String" ]) |> Maybe.withDefault [])

                producers =
                    (forW
                        |> List.concatMap
                            (\( w, _ ) ->
                                [ ""
                                , ""
                                , doc w.doc
                                , w.ctor ++ " : String -> Action { c | " ++ w.cap ++ " : Supported } msg"
                                , w.ctor ++ " for_ ="
                                , "    Action (" ++ w.variant ++ " for_)"
                                ]
                            )
                    )
                        ++ (nullW
                                |> List.concatMap
                                    (\( w, _ ) ->
                                        [ ""
                                        , ""
                                        , doc w.doc
                                        , w.ctor ++ " : Action { c | " ++ w.cap ++ " : Supported } msg"
                                        , w.ctor ++ " ="
                                        , "    Action " ++ w.variant
                                        ]
                                    )
                           )
                        ++ (bottomSheet
                                |> Maybe.map
                                    (\_ ->
                                        [ ""
                                        , ""
                                        , doc "Open the bottom sheet whose id is `for` (full spec via the record)."
                                        , "opensBottomSheet : BottomSheetSpec -> Action { c | bottomSheetTrigger : Supported } msg"
                                        , "opensBottomSheet spec ="
                                        , "    Action (OpensBottomSheet spec)"
                                        ]
                                    )
                                |> Maybe.withDefault []
                           )
                        ++ (dialogAction
                                |> Maybe.map
                                    (\_ ->
                                        [ ""
                                        , ""
                                        , doc "Close the enclosing dialog with `returnValue`."
                                        , "dialogAction : String -> Action { c | dialogAction : Supported } msg"
                                        , "dialogAction returnValue ="
                                        , "    Action (DialogAction returnValue)"
                                        ]
                                    )
                                |> Maybe.withDefault []
                           )

                wrapBranch ( w, tag ) =
                    [ "        " ++ w.variant ++ " for_ ->"
                    , "            Ir.node \"" ++ tag ++ "\" [ Ir.attribute \"for\" for_ ] [ label ]"
                    , ""
                    ]

                nullBranch ( w, tag ) =
                    [ "        " ++ w.variant ++ " ->"
                    , "            Ir.node \"" ++ tag ++ "\" [] [ label ]"
                    , ""
                    ]

                bsBranch =
                    case bottomSheet of
                        Just ( _, tag ) ->
                            [ "        OpensBottomSheet spec ->"
                            , "            Ir.node \"" ++ tag ++ "\""
                            , "                (Ir.attribute \"for\" spec.for"
                            , "                    :: List.filterMap identity"
                            , "                        [ Maybe.map (\\d -> Ir.attribute \"detent\" (String.fromFloat d)) spec.detent"
                            , "                        , Maybe.map (\\s -> Ir.attribute \"secondary\" \"\") spec.secondary"
                            , "                        ]"
                            , "                )"
                            , "                [ label ]"
                            , ""
                            ]

                        Nothing ->
                            []

                daBranch =
                    case dialogAction of
                        Just ( _, tag ) ->
                            [ "        DialogAction returnValue ->"
                            , "            Ir.node \"" ++ tag ++ "\" [ Ir.attribute \"return-value\" returnValue ] [ label ]"
                            , ""
                            ]

                        Nothing ->
                            []

                exposeGroups =
                    [ [ "Action", "LinkSpec" ]
                        ++ (bottomSheet |> Maybe.map (\_ -> [ "BottomSheetSpec" ]) |> Maybe.withDefault [])
                    , [ "link", "linkWith", "none", "onClick", "remove" ]
                    , ((forW ++ nullW) |> List.map (\( w, _ ) -> w.ctor))
                        ++ (bottomSheet |> Maybe.map (\_ -> [ "opensBottomSheet" ]) |> Maybe.withDefault [])
                        ++ (dialogAction |> Maybe.map (\_ -> [ "dialogAction" ]) |> Maybe.withDefault [])
                        |> List.sort
                    , [ "toAttrs", "wrapContent" ]
                    ]
            in
            [ file [ lib, "Action" ]
                (String.join "\n"
                    (List.concat
                        [ [ "module " ++ lib ++ ".Action exposing"
                          , exposeBlock exposeGroups
                          , ""
                          , "{-| Behavioural actions: exactly one of the supported behaviours, consumed"
                          , "by a component's `component`/`build` required record. Attribute behaviours"
                          , "(`onClick`/`link`/`remove`) become host attributes; wrapper behaviours nest"
                          , "the content in their trigger element."
                          , ""
                          , docsBlock exposeGroups
                          , ""
                          , "-}"
                          , ""
                          , "import HtmlIr.Attribute exposing (Attr)"
                          , "import HtmlIr.Internal as Ir"
                          , "import HtmlIr.Kind exposing (Supported)"
                          , "import HtmlIr.Node exposing (Node)"
                          , "import Json.Decode"
                          , ""
                          , ""
                          , doc "An opaque behavioural value: exactly one of the supported behaviours."
                          , "type Action capability msg"
                          , "    = Action (Payload msg)"
                          , ""
                          , ""
                          , "type Payload msg"
                          , "    = " ++ String.join "\n    | " payloadVariants
                          , ""
                          , ""
                          , doc "The parts of a link action."
                          , "type alias LinkSpec ="
                          , "    { href : String, target : Maybe String, rel : Maybe String, download : Maybe String }"
                          ]
                        , bottomSheet
                            |> Maybe.map
                                (\_ ->
                                    [ ""
                                    , ""
                                    , doc "The parts of a bottom-sheet trigger."
                                    , "type alias BottomSheetSpec ="
                                    , "    { for : String, detent : Maybe Float, secondary : Maybe Bool }"
                                    ]
                                )
                            |> Maybe.withDefault []
                        , [ ""
                          , ""
                          , doc "No behaviour."
                          , "none : Action capability msg"
                          , "none ="
                          , "    Action None"
                          , ""
                          , ""
                          , doc "A click action: emit `msg` on activation."
                          , "onClick : msg -> Action { c | click : Supported } msg"
                          , "onClick m ="
                          , "    Action (OnClick m)"
                          , ""
                          , ""
                          , doc "A link action pointing at `url`."
                          , "link : String -> Action { c | link : Supported } msg"
                          , "link url ="
                          , "    Action (Link { href = url, target = Nothing, rel = Nothing, download = Nothing })"
                          , ""
                          , ""
                          , doc "A link action from a full `LinkSpec`."
                          , "linkWith : LinkSpec -> Action { c | link : Supported } msg"
                          , "linkWith spec ="
                          , "    Action (Link spec)"
                          , ""
                          , ""
                          , doc "A remove action: emit `msg` when the element requests removal."
                          , "remove : msg -> Action { c | remove : Supported } msg"
                          , "remove m ="
                          , "    Action (Remove m)"
                          ]
                        , producers
                        , [ ""
                          , ""
                          , doc "The host-attribute wiring: attribute behaviours produce attrs; wrappers none."
                          , "toAttrs : Action capability msg -> List (Attr c msg)"
                          , "toAttrs (Action payload) ="
                          , "    case payload of"
                          , "        OnClick m ->"
                          , "            [ Ir.on \"click\" (Json.Decode.succeed m) ]"
                          , ""
                          , "        Remove m ->"
                          , "            [ Ir.on \"remove\" (Json.Decode.succeed m) ]"
                          , ""
                          , "        Link spec ->"
                          , "            Ir.attribute \"href\" spec.href"
                          , "                :: List.filterMap identity"
                          , "                    [ Maybe.map (Ir.attribute \"target\") spec.target"
                          , "                    , Maybe.map (Ir.attribute \"rel\") spec.rel"
                          , "                    , Maybe.map (Ir.attribute \"download\") spec.download"
                          , "                    ]"
                          , ""
                          , "        _ ->"
                          , "            []"
                          , ""
                          , ""
                          , doc "The content wiring: wrapper behaviours nest the label in their trigger element."
                          , "wrapContent : Action capability msg -> Node msg -> Node msg"
                          , "wrapContent (Action payload) label ="
                          , "    case payload of"
                          ]
                        , List.concatMap wrapBranch forW
                        , List.concatMap nullBranch nullW
                        , bsBranch
                        , daBranch
                        , [ "        _ ->"
                          , "            label"
                          , ""
                          ]
                        ]
                    )
                )
            ]



-- ARIA MODULE


ariaModule : Brand -> List Elm.File
ariaModule brand =
    case brand.aria of
        Nothing ->
            []

        Just aria ->
            let
                lib =
                    brand.lib

                roleTokens =
                    aria.roles
                        |> List.sort
                        |> List.concatMap
                            (\r ->
                                let
                                    n =
                                        roleName r
                                in
                                [ ""
                                , ""
                                , doc ("The `" ++ r ++ "` role token.")
                                , n ++ " : Value { r | " ++ n ++ " : Role }"
                                , n ++ " ="
                                , "    Ir.token \"" ++ r ++ "\""
                                ]
                            )

                roleTokenNames =
                    aria.roles |> List.map roleName

                -- The ROW FIELD stays the plain name (it must unify with the
                -- state alias rows); only the token FUNCTION is suffixed.
                stateFieldName v =
                    Naming.safeField (Naming.camel v)

                -- A state VALUE that collides with a role token name
                -- (`listbox`/`menu`/`dialog`… are both roles and
                -- aria-haspopup values) gets a `Value` suffix.
                stateTokenName v =
                    let
                        n =
                            Naming.safeField (Naming.camel v)
                    in
                    if List.member n roleTokenNames then
                        n ++ "Value"

                    else
                        n

                stateTokenNames =
                    aria.states
                        |> List.concatMap Tuple.second
                        |> List.sort
                        |> dedup

                stateTokens =
                    stateTokenNames
                        |> List.concatMap
                            (\v ->
                                let
                                    n =
                                        stateTokenName v
                                in
                                [ ""
                                , ""
                                , doc ("The `" ++ v ++ "` state token.")
                                , n ++ " : Value { v | " ++ stateFieldName v ++ " : Supported }"
                                , n ++ " ="
                                , "    Ir.token \"" ++ v ++ "\""
                                ]
                            )

                stateSetters =
                    aria.states
                        |> List.sortBy Tuple.first
                        |> List.concatMap
                            (\( name, values ) ->
                                let
                                    aliasName =
                                        Naming.pascal name
                                in
                                [ ""
                                , ""
                                , doc ("The values `aria-" ++ name ++ "` admits.")
                                , "type alias " ++ aliasName ++ " ="
                                , "    { "
                                    ++ (values |> List.sort |> List.map (\v -> Naming.safeField (Naming.camel v) ++ " : Supported") |> String.join "\n    , ")
                                    ++ "\n    }"
                                , ""
                                , ""
                                , doc ("Value-typed `aria-" ++ name ++ "` (universal: any element admits it).")
                                , Naming.camel name ++ " : Value " ++ aliasName ++ " -> Attr c msg"
                                , Naming.camel name ++ " value_ ="
                                , "    Ir.attribute \"aria-" ++ name ++ "\" (HtmlIr.Value.toString value_)"
                                ]
                            )

                universalSetters =
                    aria.universal
                        |> List.sort
                        |> List.concatMap
                            (\name ->
                                [ ""
                                , ""
                                , doc ("The open `aria-" ++ name ++ "` attribute (universal).")
                                , Naming.camel name ++ " : String -> Attr c msg"
                                , Naming.camel name ++ " ="
                                , "    Ir.attribute \"aria-" ++ name ++ "\""
                                ]
                            )

                exposeGroups =
                    [ [ "role", "roleString" ]
                    , aria.roles |> List.map roleName |> List.sort
                    , (aria.states |> List.map (Tuple.first >> Naming.pascal))
                        ++ (aria.states |> List.map (Tuple.first >> Naming.camel))
                        |> List.sort
                    , stateTokenNames |> List.map stateTokenName
                    , aria.universal |> List.map Naming.camel |> List.sort
                    ]
            in
            [ file [ lib, "Aria" ]
                (String.join "\n"
                    (List.concat
                        [ [ "module " ++ lib ++ ".Aria exposing"
                          , exposeBlock exposeGroups
                          , ""
                          , "{-| The ARIA concern axis — the HYBRID design: `role` is TYPE-GATED per"
                          , "element where it earns its keep (an element's `<El>Roles` alias closes the"
                          , "legal set; a wrong role is a compile error), enumerated aria-* states are"
                          , "value-typed, and the universal aria-* attributes stay open. The role×state"
                          , "dependency is lint territory."
                          , ""
                          , docsBlock exposeGroups
                          , ""
                          , "-}"
                          , ""
                          , "import HtmlIr.Attribute exposing (Attr)"
                          , "import HtmlIr.Internal as Ir"
                          , "import HtmlIr.Kind exposing (Supported)"
                          , "import HtmlIr.Value exposing (Value)"
                          , "import " ++ lib ++ ".Kind exposing (Role)"
                          , ""
                          , ""
                          , doc "Set a TYPED role: the token's row must fit the element's closed role set."
                          , "role : Value tags -> Attr { c | role : tags } msg"
                          , "role value_ ="
                          , "    Ir.attribute \"role\" (HtmlIr.Value.toString value_)"
                          , ""
                          , ""
                          , doc "Set a raw role string on a role-UNGATED element (its row has `role : Supported`)."
                          , "roleString : String -> Attr { c | role : Supported } msg"
                          , "roleString ="
                          , "    Ir.attribute \"role\""
                          ]
                        , roleTokens
                        , stateSetters
                        , stateTokens
                        , universalSetters
                        , [ "" ]
                        ]
                    )
                )
            ]


dedupBy_ : (a -> b) -> List a -> List a
dedupBy_ key =
    List.foldr
        (\x acc ->
            if List.any (\y -> key y == key x) acc then
                acc

            else
                x :: acc
        )
        []


dedup : List comparable -> List comparable
dedup =
    List.foldr
        (\x acc ->
            if List.member x acc then
                acc

            else
                x :: acc
        )
        []



-- FACTS BUNDLE FACE C (elm-api-facts.json — M1.c)
--
-- Surfaces the same `Brand` projection `files` already reads into the
-- generated-Elm API projection docs/facts-bundle/schema.json calls Face C.
-- Provenance (versions/commits/config identity) is NOT known here — the CLI
-- wrapper stamps it after reading this file back (see bin/elm-cem.js) — so the
-- object this function emits carries every OTHER required `faceC` field and
-- omits `provenance`.


{-| Canonical join key: lowercase, non-alphanumerics stripped.
-}
factKey : String -> String
factKey s =
    s
        |> String.toLower
        |> String.filter Char.isAlphaNum


factsBundleFile : Brand -> Elm.File
factsBundleFile brand =
    { path = "elm-api-facts.generated.json"
    , contents = Encode.encode 2 (encodeFaceC brand)
    , warnings = []
    }


encodeFaceC : Brand -> Encode.Value
encodeFaceC brand =
    let
        lib =
            brand.lib

        tokenModule =
            if List.isEmpty brand.unions then
                Nothing

            else
                Just (lib ++ ".Values")

        actionModule_ =
            case brand.actions of
                Nothing ->
                    Nothing

                Just _ ->
                    Just (lib ++ ".Action")

        surfaceKeysUsed =
            brand.comps
                |> List.concatMap (\c -> Dict.keys (surfacesOf brand tokenModule actionModule_ c))
                |> dedup
                |> List.sort

        facets =
            [ { key = "top", facet = "Standard", form = "double-list", finalizer = Nothing }
            , { key = "build", facet = "Build", form = "pipeline", finalizer = Just "toElement" }
            , { key = "record", facet = "Record", form = "record-double-list", finalizer = Nothing }
            , { key = "html", facet = "Html", form = "double-list", finalizer = Nothing }
            ]
                |> List.filter (\f -> List.member f.key surfaceKeysUsed)
                |> List.map
                    (\f ->
                        Encode.object
                            [ ( "key", Encode.string f.key )
                            , ( "facet", Encode.string f.facet )
                            , ( "form", Encode.string f.form )
                            , ( "finalizer", nullableString f.finalizer )
                            ]
                    )
    in
    Encode.object
        [ ( "schemaVersion", Encode.int 1 )
        , ( "lib", Encode.string lib )
        , ( "surfaceKeys", Encode.list Encode.string surfaceKeysUsed )
        , ( "defaultSurface", Encode.string "top" )
        , ( "facets", Encode.list identity facets )
        , ( "components"
          , Encode.object
                (brand.comps |> List.map (\c -> ( c.tag, encodeComponent brand tokenModule actionModule_ c )))
          )
        ]


nullableString : Maybe String -> Encode.Value
nullableString =
    Maybe.map Encode.string >> Maybe.withDefault Encode.null


hasElOf : Comp -> Bool
hasElOf comp =
    let
        requiredSlots =
            comp.slots |> List.filter .required

        reqAttrFields =
            comp.requiredAttrs
    in
    not (List.isEmpty requiredSlots) || comp.actionCaps /= Nothing || not (List.isEmpty reqAttrFields)


surfacesOf : Brand -> Maybe String -> Maybe String -> Comp -> Dict.Dict String Encode.Value
surfacesOf brand tokenModule actionModule_ comp =
    let
        moduleName =
            brand.lib ++ "." ++ (memberRef brand comp).module_

        -- The single `component` ctor IS the top surface. Its form is the loose
        -- double-list when nothing is required, and the required-record form when
        -- a slot/attr/action is mandatory (post view/el unification — there is no
        -- separate `el` function anymore, so no separate `record` surface).
        top =
            ( "top"
            , Encode.object
                [ ( "facet", Encode.string "Standard" )
                , ( "module", Encode.string moduleName )
                , ( "entry", Encode.string "component" )
                , ( "form"
                  , Encode.string
                        (if hasElOf comp then
                            "record-double-list"

                         else
                            "double-list"
                        )
                  )
                , ( "finalizer", Encode.null )
                ]
            )

        build =
            ( "build"
            , Encode.object
                [ ( "facet", Encode.string "Build" )
                , ( "module", Encode.string moduleName )
                , ( "entry", Encode.string "build" )
                , ( "form", Encode.string "pipeline" )
                , ( "finalizer", Encode.string "toElement" )
                ]
            )

        -- No separate `record` surface post view/el unification: the required-
        -- record form is carried by `top` (see `component`'s conditional form).
        record =
            []

        html =
            if homeOf comp == Nothing then
                [ ( "html"
                  , Encode.object
                        [ ( "facet", Encode.string "Html" )
                        , ( "module", Encode.string (brand.lib ++ ".Html") )
                        , ( "entry", Encode.string comp.resolvedCtor )
                        , ( "form", Encode.string "double-list" )
                        , ( "finalizer", Encode.null )
                        ]
                  )
                ]

            else
                []
    in
    Dict.fromList (top :: build :: record ++ html)


attrTypeKind : Attr.AttrType -> String
attrTypeKind t =
    case t of
        Attr.ABool ->
            "bool"

        Attr.ANumber ->
            "float"

        Attr.AInt ->
            "int"

        Attr.AEnum _ ->
            "enum"

        Attr.AEnumNum _ ->
            "enum"

        Attr.AEnumMap _ ->
            "enum"

        Attr.AString ->
            "string"

        Attr.ASkip _ ->
            "opaque"


encodeEnum : Brand -> Maybe String -> EnumSpec -> Encode.Value
encodeEnum brand tokenModule e =
    Encode.object
        [ ( "aliasName"
          , if e.aliasName == "" then
                Encode.null

            else
                Encode.string e.aliasName
          )
        , ( "values"
          , Encode.list
                (\raw ->
                    let
                        elmIdent =
                            tokenIdentResolved brand raw
                    in
                    Encode.object
                        [ ( "elm", Encode.string elmIdent )
                        , ( "key", Encode.string (factKey raw) )
                        , ( "token"
                          , case tokenModule of
                                Just tm ->
                                    Encode.string (tm ++ "." ++ elmIdent)

                                Nothing ->
                                    Encode.null
                          )
                        , ( "raw", Encode.string (tokenValueOf brand raw) )
                        ]
                )
                e.tokens
          )
        ]


encodeComponent : Brand -> Maybe String -> Maybe String -> Comp -> Encode.Value
encodeComponent brand tokenModule actionModule_ comp =
    let
        ref =
            memberRef brand comp

        moduleName =
            brand.lib ++ "." ++ ref.module_

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        variadicSlots =
            namedSlots |> List.filter .multi

        attrPipeNames =
            attrsFields brand comp |> List.map (\f -> "with" ++ Naming.pascal f)

        compTopLevelNamespace =
            List.concat
                [ [ comp.resolvedCtor ]
                , comp.attrs |> List.map .elmName
                , attrPipeNames
                , comp.events |> List.map (handlerName brand)
                ]

        slotPipeNameOf s =
            let
                plain =
                    "with" ++ Naming.pascal s.name
            in
            if List.member plain compTopLevelNamespace then
                plain ++ "Slot"

            else
                plain

        pipeSetters =
            (attrsFields brand comp |> List.map (\f -> ( f, "with" ++ Naming.pascal f )))
                ++ (singularSlots |> List.map (\s -> ( s.name, slotPipeNameOf s )))
                ++ (variadicSlots |> List.map (\s -> ( s.name, slotPipeNameOf s )))

        slotKindsOf =
            comp.slots
                |> List.filterMap
                    (\s ->
                        let
                            kindString f =
                                case f.marker of
                                    MShared ->
                                        "shared:" ++ Naming.decapitalize (String.dropLeft 6 f.field)

                                    MBrand ->
                                        f.field
                        in
                        case s.content of
                            Permissive ->
                                Nothing

                            SetContent set ->
                                Just ( s.name, set.fields |> List.map kindString )

                            Fields fs ->
                                Just ( s.name, fs |> List.map kindString )
                    )

        group =
            case homeOf comp of
                Nothing ->
                    Encode.null

                Just h ->
                    Encode.object
                        [ ( "module", Encode.string (brand.lib ++ "." ++ h) )
                        , ( "constructor", Encode.string comp.resolvedCtor )
                        ]
    in
    Encode.object
        [ ( "cemTag", Encode.string comp.tag )
        , ( "component", Encode.string comp.ctor )
        , ( "module", Encode.string moduleName )
        , ( "rootNamespace", Encode.string brand.lib )
        , ( "memberPrefix"
          , if ref.prefix == "" then
                Encode.null

            else
                Encode.string ref.prefix
          )
        , ( "tokenModule", nullableString tokenModule )
        , ( "actionModule", nullableString actionModule_ )
        , ( "usesAction", Encode.bool (comp.actionCaps /= Nothing) )
        , ( "actionMap", Encode.object (comp.actionMap |> List.map (\( a, b ) -> ( a, Encode.string b ))) )
        , ( "setters", Encode.object (comp.attrs |> List.map (\a -> ( a.htmlName, Encode.string a.elmName ))) )
        , ( "setterArgTypes", Encode.object (comp.attrs |> List.map (\a -> ( a.elmName, Encode.string (attrTypeKind a.type_) ))) )
        , ( "enums", Encode.object (comp.enums |> List.map (\e -> ( e.elmName, encodeEnum brand tokenModule e ))) )
        , ( "pipeSetters", Encode.object (pipeSetters |> List.map (\( a, b ) -> ( a, Encode.string b ))) )
        , ( "eventHandlers", Encode.object (comp.events |> List.map (\e -> ( e.name, Encode.string (handlerName brand e) ))) )
        , ( "slotSetters", Encode.list Encode.string (namedSlots |> List.map (\s -> Naming.camel s.name)) )
        , ( "slotSetterMap", Encode.object (namedSlots |> List.map (\s -> ( s.name, Encode.string (Naming.camel s.name) ))) )
        , ( "slotUpgrades", Encode.list Encode.string [] )
        , ( "requiredSlots", Encode.list Encode.string (comp.slots |> List.filter .required |> List.map .name) )
        , ( "multiSlots", Encode.list Encode.string (comp.slots |> List.filter .multi |> List.map .name) )
        , ( "slotKinds", Encode.object (slotKindsOf |> List.map (\( n, ks ) -> ( n, Encode.list Encode.string ks ))) )
        , ( "requiredAttrs", Encode.list Encode.string comp.requiredAttrs )
        , ( "group", group )
        , ( "groupConstructors", Encode.list Encode.string [] )
        , ( "surfaces", Encode.object (Dict.toList (surfacesOf brand tokenModule actionModule_ comp)) )
        ]
