module Generate.Phantom.Emit.Guard exposing (..)


import Attr
import Cem
import Char
import Dict
import Docs
import Elm
import Generate.Phantom.Model as M exposing (Brand, Comp, EnumSpec, KindField, Marker(..), ResolvedSlot, SlotContent(..))
import Json.Encode as Encode
import Naming

import Generate.Phantom.Emit.AttrsRow exposing (..)
import Generate.Phantom.Emit.Shared exposing (..)


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
        , guardActionModule brand
        , guardAriaModule brand
        , guardSharedAtoms brand
        ]


{-| Every `Shared`-marked field about to be written must be in the canonical
cross-library vocabulary (`Model.sharedAtomVocabulary`).

`Model.resolveWith` already enforces this, earlier and in config vocabulary, which
is the message a config author wants. This is the same rule stated at the output,
and it is worth stating twice for one reason: the resolution check ENUMERATES the
routes a shared role can take (`_atoms`, a component's `kind`, a slot's `kinds`).
Enumerating routes is exactly the mistake that produced the defect this
vocabulary exists to prevent — a route was once left off the list for a
release, and the symptom was `shared:phrasing : Brand` appearing in a
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
— `reExportBlock` is fed `members |> List.concatMap .attrs |> deduplicateBy .elmName` — so
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
`members |> List.concatMap .attrs |> deduplicateBy .elmName`), so if `<input>` and
`<progress>` shared a home, `deduplicateBy` would keep whichever the manifest lists first
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



