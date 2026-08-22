module Generate.Phantom.Emit.BuildPackage exposing (files)

{-| DAG-rework Task 3/4: the COMPOSED Build tier. Emits the whole
`<lib>.Build.*` surface — one aggregated `<lib>.Build.<Family>` per family plus
a flat per-element `<lib>.Build.<Element>` for each non-root family member — that
sources its type surface and slot placers from the `<lib>.Component.<Family>`
FAÇADE (`FamilyPackage`'s output) instead of per-CEM-element `<lib>.Element.*`.
This is the one real, Components-driven builder implementation: the linear DAG
`Build → Components → Elements → Core`.

This is the Shape A emitter of `docs/plans/2026-08-21-dag-rework-plan.md`
(§T2, §M1). It replaces the old per-CEM-element `compBuildModule`
(`Emit.elm`'s `own` concatMap, now removed).

Sourcing rule (the crux the rework proves): for each family, one module
carrying every member (root + members) builder surface, member-prefixed so
members never collide within the one module — the SAME prefixing scheme
`FamilyPackage.generateFamilyModule` uses (`elementPascal ++ TypeName`,
`elementCamel ++ upperFirst valueName`). A flat per-element module uses an EMPTY
prefix, giving the un-prefixed surface consumers use today (`build`, `Builder`,
`withClass`), still sourced through the façade. Every reference to a member's
element-tier type or slot-placer resolves through
`import <lib>.Component.<Family> as Component` (the façade's member-prefixed
re-export, e.g. `Component.ItemBadgeSlot`, `Component.itemBadge`), NEVER
`import <lib>.Element.<X>`. The builder MECHANICS (`B.init`, `B.withChild`,
`B.withAttribute`, `B.toElement`) come from `<lib>.Forge.Internal as B` — a
brand-level module, unchanged.

Every element not in a declared `_families` family is a DEGENERATE single-member
family (emitter-computed, OQ-2), so every element retains a builder. A SPLIT
brand (with a components package config) emits Build as its own sibling
family-generated package; a MONOLITH brand (no `_families`) emits the Build
modules AND the degenerate `<lib>.Component.*` façades FLAT into the same src.
Both route Build through Components.

This module reads `Brand.comps`/`Comp` records directly (same in-memory model
the per-element emitter renders from) — no re-parse of rendered `.elm` text,
matching the anti-drift discipline `FamilyPackage.elm`'s header describes. It
reuses the shared `Generate.Phantom.Emit.Component`/`AttrsRow`/`Shared` helpers
for every attribute/setter/slot decision so the composed builder can never
diverge from the per-element one on those decisions.

@docs files

-}

import Elm
import Generate.Phantom.Emit.AttrsRow exposing (attrsFields, divergesFromCanonical, hasEnumGlobal, isEnumSpec, needsJsonEncodeImport, overrideTypes, setterExpr, unionFor)
import Generate.Phantom.Emit.Component exposing (globalSetterInputType)
import Generate.Phantom.Emit.FamilyPackage exposing (degenerateFacadeModule, familyElmJsonFile, familyLicenseFile, familyReadmeFile)
import Generate.Phantom.Emit.Shared exposing (file, handlerName, homeOf, payloadTypeAndDecoder, setterInputType)
import Generate.Phantom.Model exposing (Brand, Comp, ResolvedSlot, SlotContent(..))
import Generate.Types exposing (FamiliesConfig, FamilyPackageConfig, FamilySpec)
import Naming
import Set


upperFirst : String -> String
upperFirst s =
    case String.uncons s of
        Nothing ->
            s

        Just ( c, tail ) ->
            String.cons (Char.toUpper c) tail


lowerFirst : String -> String
lowerFirst s =
    case String.uncons s of
        Nothing ->
            s

        Just ( c, tail ) ->
            String.cons (Char.toLower c) tail



-- ── one member's place in the composed module ─────────────────────────────


type alias Member =
    { comp : Comp

    -- element label WITHIN the family (`path` in _families; e.g. "Item",
    -- "ItemGroup", or the family name itself for the root). Pascal-cased; it
    -- prefixes the FAÇADE reference for this member (`Component.<label><T>`),
    -- because the `FamilyPackage` façade always member-prefixes its re-exports.
    , label : String

    -- The EXPOSED-name prefix for this member's builder decls in the composed
    -- module. For a member of a real multi-member family this equals `label`
    -- (so members never collide: `ItemBuilder`, `itemBuild`). For a DEGENERATE
    -- single-member family (a standalone element) this is EMPTY, so the
    -- composed module exposes the flat, un-prefixed surface (`Builder`,
    -- `build`, `withClass`) byte-identical to today's per-element
    -- `<lib>.Build.<Element>` — Jack's "degenerate re-export is 1:1/trivial".
    , exposedPrefix : String
    }


{-| A member's exposed TYPE reference, resolved through the façade. The façade
(`FamilyPackage`) re-exports each member's element type `T` as
`<elementPascal>T` — so `Component.<label><T>`.
-}
typeRef : Member -> String -> String
typeRef member t =
    "Component." ++ member.label ++ t


{-| A member's exposed VALUE reference (a slot placer / local enum setter /
override handler), resolved through the façade. The façade re-exports each
member's element value `v` as `<elementCamel><UpperFirst v>` — so
`Component.<elementCamel><UpperFirst v>`.
-}
valueRef : Member -> String -> String
valueRef member v =
    "Component." ++ lowerFirst member.label ++ upperFirst v


{-| The EXPOSED name for one of this member's builder decls. For a real
multi-member family, types Pascal-prefix (`ItemBuilder`), values camel-prefix
(`itemBuild`), matching `FamilyPackage`. For a degenerate single-member family
the prefix is empty, so the surface is flat (`Builder`, `build`) —
byte-identical to today's per-element builder.
-}
expType : Member -> String -> String
expType member t =
    member.exposedPrefix ++ t


expValue : Member -> String -> String
expValue member v =
    if String.isEmpty member.exposedPrefix then
        v

    else
        lowerFirst member.exposedPrefix ++ upperFirst v



-- ── render one member's composed builder decls ────────────────────────────
-- Mirrors compBuildModule (Component.elm:1164-1813) decl-for-decl, but:
--   * every emitted decl name is member-prefixed (collision-safe within the
--     one family module), and
--   * every element-tier reference resolves through the Component façade
--     (typeRef/valueRef) instead of a bare `Component.` alias onto
--     <lib>.Element.<X>.
-- Builder mechanics stay `B.*` (brand-level Forge.Internal), unchanged.


memberDecls : Brand -> Member -> List String
memberDecls brand member =
    let
        comp =
            member.comp

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

        -- Local builder-tier alias names, member-prefixed. These are declared
        -- IN this module (Builder/AttrCaps/SlotCaps/Is/Content/…), pointing at
        -- the façade's member-prefixed re-exports.
        builderT =
            expType member "Builder"

        attrCapsT =
            expType member "AttrCaps"

        slotCapsT =
            expType member "SlotCaps"

        isT =
            expType member "Is"

        childAdmT =
            expType member "ChildAdmittedBy"

        -- slot content type name for a slot, as exposed on THIS module.
        contentAliasName : ResolvedSlot -> Maybe String
        contentAliasName s =
            case s.content of
                Fields _ ->
                    Just
                        (if s.name == "unnamed" then
                            expType member "Content"

                         else
                            expType member (Naming.pascal s.name ++ "Slot")
                        )

                _ ->
                    Nothing

        -- the RHS a slot content type / expression resolves to, through the façade.
        contentTypeOf : ResolvedSlot -> String
        contentTypeOf s =
            case s.content of
                Permissive ->
                    "childAccepts"

                SetContent set ->
                    set.pascal

                Fields _ ->
                    if s.name == "unnamed" then
                        typeRef member "Content"

                    else
                        typeRef member (Naming.pascal s.name ++ "Slot")

        slotPipeNameBase s =
            "with" ++ Naming.pascal s.name

        -- naming-collision guard between a slot pipe and an attr pipe, same as
        -- compBuildModule's compTopLevelNamespace check, evaluated on the
        -- member's own (unprefixed) namespace since prefixing is uniform.
        attrPipeBases =
            attrsPipeBases brand comp

        compTopLevelNamespace =
            List.concat
                [ [ comp.resolvedCtor ]
                , comp.attrs |> List.map .elmName
                , attrPipeBases
                , comp.events |> List.map (handlerName brand)
                ]

        slotPipeBase s =
            let
                plain =
                    slotPipeNameBase s
            in
            if List.member plain compTopLevelNamespace then
                plain ++ "Slot"

            else
                plain

        -- ── type-alias decls (member-prefixed, façade-sourced RHS) ──
        typeAliasDecls =
            [ ""
            , ""
            , "{-| -}"
            , "type alias " ++ isT ++ " s ="
            , "    " ++ typeRef member "Is" ++ " s"
            , ""
            , ""
            , "{-| -}"
            , "type alias " ++ builderT ++ " attrCaps slotCaps msg kind ="
            , "    " ++ typeRef member "Builder" ++ " attrCaps slotCaps msg kind"
            , ""
            , ""
            , "{-| -}"
            , "type alias " ++ attrCapsT ++ " ="
            , "    " ++ typeRef member "AttrCaps"
            , ""
            , ""
            , "{-| -}"
            , "type alias " ++ slotCapsT ++ " ="
            , "    " ++ typeRef member "SlotCaps"
            , ""
            , ""
            , "{-| -}"
            , "type alias " ++ childAdmT ++ " childAdm ="
            , "    " ++ typeRef member "ChildAdmittedBy" ++ " childAdm"
            ]
                ++ (comp.slots
                        |> List.filterMap
                            (\s ->
                                contentAliasName s
                                    |> Maybe.map
                                        (\nm ->
                                            let
                                                rhs =
                                                    if s.name == "unnamed" then
                                                        typeRef member "Content"

                                                    else
                                                        typeRef member (Naming.pascal s.name ++ "Slot")
                                            in
                                            String.join "\n"
                                                [ "", "", "{-| -}", "type alias " ++ nm ++ " =", "    " ++ rhs ]
                                        )
                            )
                   )

        -- ── build seed ──
        buildName =
            expValue member "build"

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
                                        "El.toNode (" ++ valueRef member (Naming.camel s.name) ++ " required_." ++ Naming.camel s.name ++ ")"
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
                                    , "Element (" ++ contentTypeOf s ++ ") (" ++ typeRef member "ChildAdmittedBy" ++ " childAdm) msg"
                                    )
                                )
                        )
                            ++ (reqAttrFields |> List.map (\( f, _ ) -> ( f, "String" )))
                            ++ (case comp.actionCaps of
                                    Just _ ->
                                        [ ( "action", "Ac.Action (" ++ typeRef member "ActionCaps" ++ ") msg" ) ]

                                    Nothing ->
                                        []
                               )
                in
                [ ""
                , ""
                , "{-| -}"
                , buildName ++ " :"
                , "    { "
                    ++ (reqFields |> List.map (\( n, t ) -> n ++ " : " ++ t) |> String.join "\n    , ")
                    ++ " }"
                , "    -> " ++ builderT ++ " " ++ attrCapsT ++ " " ++ slotCapsT ++ " msg kind"
                , buildName ++ " required_ ="
                , "    B.init \"" ++ comp.tag ++ "\" (" ++ seedAttrs ++ ") [ " ++ String.join ", " seedChildren_ ++ " ]"
                ]

            else
                [ ""
                , ""
                , "{-| -}"
                , buildName ++ " : " ++ builderT ++ " " ++ attrCapsT ++ " " ++ slotCapsT ++ " msg kind"
                , buildName ++ " ="
                , "    B.init \"" ++ comp.tag ++ "\" [] []"
                ]

        -- ── toElement ──
        toElName =
            expValue member "toElement"

        kindReturnType =
            "Element ("
                ++ typeRef member "Is"
                ++ " kind) "
                ++ (case comp.admittedBy of
                        Just _ ->
                            "(" ++ typeRef member "AdmittedBy" ++ ")"

                        Nothing ->
                            "admittedBy"
                   )
                ++ " msg"

        toElementDecl =
            [ ""
            , ""
            , "{-| -}"
            , toElName ++ " : " ++ builderT ++ " attrCaps slotCaps msg kind -> " ++ kindReturnType
            , toElName ++ " ="
            , "    B.toElement"
            ]

        -- ── slot placers (member-prefixed, delegate to façade slot placer) ──
        slotPlacers =
            namedSlots
                |> List.concatMap
                    (\s ->
                        [ ""
                        , ""
                        , "{-| -}"
                        , expValue member (Naming.camel s.name) ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> Element free freeAdmittedBy msg"
                        , expValue member (Naming.camel s.name) ++ " builder ="
                        , "    " ++ valueRef member (Naming.camel s.name) ++ " (B.toElement builder)"
                        ]
                    )

        singularSlotPipes =
            singularSlots
                |> List.concatMap
                    (\s ->
                        let
                            n =
                                expValue member (slotPipeBase s)
                        in
                        [ ""
                        , ""
                        , "{-| -}"
                        , n ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> " ++ builderT ++ " attrCaps { s | " ++ Naming.camel s.name ++ " : Available } msg kind"
                        , "    -> " ++ builderT ++ " attrCaps { s | " ++ Naming.camel s.name ++ " : Used } msg kind"
                        , n ++ " slotBuilder builder_ ="
                        , "    B.withChild (El.toNode (" ++ valueRef member (Naming.camel s.name) ++ " (B.toElement slotBuilder))) builder_"
                        ]
                    )

        variadicSlotPipes =
            variadicSlots
                |> List.concatMap
                    (\s ->
                        let
                            n =
                                expValue member (slotPipeBase s)
                        in
                        [ ""
                        , ""
                        , "{-| -}"
                        , n ++ " :"
                        , "    B.Builder childRow childAttrCaps childSlotCaps (" ++ contentTypeOf s ++ ") msg"
                        , "    -> " ++ builderT ++ " attrCaps slotCaps msg kind"
                        , "    -> " ++ builderT ++ " attrCaps slotCaps msg kind"
                        , n ++ " slotBuilder builder_ ="
                        , "    B.withChild (El.toNode (" ++ valueRef member (Naming.camel s.name) ++ " (B.toElement slotBuilder))) builder_"
                        ]
                    )

        childPipe =
            case unnamed of
                Just _ ->
                    [ ""
                    , ""
                    , "{-| -}"
                    , expValue member "withChild" ++ " :"
                    , "    B.Builder childRow childAttrCaps childSlotCaps accepts msg"
                    , "    -> " ++ builderT ++ " attrCaps slotCaps msg kind"
                    , "    -> " ++ builderT ++ " attrCaps slotCaps msg kind"
                    , expValue member "withChild" ++ " childBuilder builder_ ="
                    , "    B.withChild (El.toNode (B.toElement childBuilder)) builder_"
                    ]

                Nothing ->
                    []

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

        pipeForParams : String -> String -> List String -> String -> List String
        pipeForParams capField inputSig params applied =
            let
                n =
                    expValue member ("with" ++ Naming.pascal capField)
            in
            [ ""
            , ""
            , "{-| -}"
            , n ++ " : " ++ inputSig ++ builderT ++ " { a | " ++ capField ++ " : Available } slotCaps msg kind -> " ++ builderT ++ " { a | " ++ capField ++ " : Used } slotCaps msg kind"
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
                                        pipeFor a.capName ("Value " ++ typeRef member (Naming.pascal a.elmName) ++ " -> ") (valueRef member a.elmName ++ " value_")

                                    ( _, Just _ ) ->
                                        pipeFor a.capName (setterInputType a ++ " -> ") (setterExpr a)

                                    ( _, Nothing ) ->
                                        if divergesFromCanonical brand a then
                                            pipeFor a.capName (setterInputType a ++ " -> ") (setterExpr a)

                                        else
                                            pipeFor a.capName (setterInputType a ++ " -> ") ("A." ++ a.elmName ++ " value_")
                            )
                   )
                ++ (comp.events
                        |> List.map
                            (\ev ->
                                case comp.eventOverrides |> List.filter (\o -> o.name == ev.name) |> List.head of
                                    Just o ->
                                        let
                                            ( elmTy, _ ) =
                                                overrideTypes o.type_
                                        in
                                        pipeFor (handlerName brand ev) ("(" ++ elmTy ++ " -> msg) -> ") (valueRef member (handlerName brand ev) ++ " value_")

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
    in
    typeAliasDecls
        ++ (case comp.admittedBy of
                Just _ ->
                    [ "", "", "{-| -}", "type alias " ++ expType member "AdmittedBy" ++ " =", "    " ++ typeRef member "AdmittedBy" ]

                Nothing ->
                    []
           )
        ++ (case comp.actionCaps of
                Just _ ->
                    [ "", "", "{-| -}", "type alias " ++ expType member "ActionCaps" ++ " =", "    " ++ typeRef member "ActionCaps" ]

                Nothing ->
                    []
           )
        ++ buildDecl
        ++ toElementDecl
        ++ slotPlacers
        ++ singularSlotPipes
        ++ variadicSlotPipes
        ++ childPipe
        ++ attrPipes


{-| The attr-pipe base names for a comp (unprefixed `with<X>`), lifted from
`compBuildModule`'s `attrPipeNames` so the slot/attr collision guard here
matches the per-element emitter's exactly.
-}
attrsPipeBases : Brand -> Comp -> List String
attrsPipeBases brand comp =
    attrsFields brand comp |> List.map (\f -> "with" ++ Naming.pascal f)



-- ── exposed-name collection (drives the module's exposing list) ────────────


memberExposed : Brand -> Member -> List String
memberExposed brand member =
    let
        comp =
            member.comp

        namedSlots =
            comp.slots |> List.filter (\s -> s.name /= "unnamed")

        singularSlots =
            namedSlots |> List.filter (not << .multi)

        variadicSlots =
            namedSlots |> List.filter .multi

        unnamed =
            comp.slots |> List.filter (\s -> s.name == "unnamed") |> List.head

        attrPipeBases =
            attrsPipeBases brand comp

        compTopLevelNamespace =
            List.concat
                [ [ comp.resolvedCtor ]
                , comp.attrs |> List.map .elmName
                , attrPipeBases
                , comp.events |> List.map (handlerName brand)
                ]

        slotPipeBase s =
            let
                plain =
                    "with" ++ Naming.pascal s.name
            in
            if List.member plain compTopLevelNamespace then
                plain ++ "Slot"

            else
                plain

        contentAliasNames =
            comp.slots
                |> List.filterMap
                    (\s ->
                        case s.content of
                            Fields _ ->
                                Just
                                    (if s.name == "unnamed" then
                                        "Content"

                                     else
                                        Naming.pascal s.name ++ "Slot"
                                    )

                            _ ->
                                Nothing
                    )

        types =
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

        values =
            [ "build", "toElement" ]
                ++ attrPipeBases
                ++ (namedSlots |> List.map (\s -> Naming.camel s.name))
                ++ (singularSlots |> List.map slotPipeBase)
                ++ (variadicSlots |> List.map slotPipeBase)
                ++ (case unnamed of
                        Just _ ->
                            [ "withChild" ]

                        Nothing ->
                            []
                   )
    in
    (types |> List.map (expType member))
        ++ (values |> List.map (expValue member))



-- ── resolve a family into its members against Brand.comps ──────────────────


{-| A resolved family ready to render: its module-suffix name (`<Family>` for
declared families, `<Element>` for degenerate ones — both become
`<lib>.Build.<name>`), its members, and whether it is degenerate (drives the
per-element re-export decision in Task 4 and the `Component2` façade emission).
-}
type alias ResolvedFamily =
    { name : String
    , members : List Member
    , degenerate : Bool
    }


{-| Resolve ONE declared family's members. Members keep `label` as both their
façade-reference prefix and their exposed-name prefix (real multi-member
families member-prefix so members never collide within the one module).
-}
resolveMembers : Brand -> String -> FamilySpec -> Result String (List Member)
resolveMembers brand family spec =
    let
        pairs =
            (case spec.root of
                Just root ->
                    [ ( root, family ) ]

                Nothing ->
                    []
            )
                ++ (spec.members |> List.map (\m -> ( m.component, m.path )))

        resolveOne ( compName, label ) =
            case brand.comps |> List.filter (\c -> c.name == compName) |> List.head of
                Nothing ->
                    Err ("BuildPackage: component not found for family member: " ++ compName ++ " (family " ++ family ++ ").")

                Just comp ->
                    Ok { comp = comp, label = label, exposedPrefix = label }
    in
    pairs
        |> List.foldr
            (\p acc -> acc |> Result.andThen (\ms -> resolveOne p |> Result.map (\m -> m :: ms)))
            (Ok [])


{-| The FULL family list a brand's Build tier composes over: every declared
`_families` family, PLUS a degenerate single-member family for every
builder-bearing element (`homeOf == Nothing`, matching `Emit.elm`'s `own`) not
already a declared-family member. This is the OQ-2 emitter-computed expansion —
the brand author's `slots.json` surface is unchanged; standalone elements get a
1:1 family so no element loses its builder, and every element's builder routes
uniformly through a `<lib>.Component.<Family>` façade.
-}
resolveAllFamilies : Brand -> Maybe FamiliesConfig -> Result String (List ResolvedFamily)
resolveAllFamilies brand maybeConfig =
    let
        declared =
            case maybeConfig of
                Nothing ->
                    []

                Just cfg ->
                    cfg.families

        declaredResult =
            declared
                |> List.foldr
                    (\( family, spec ) acc ->
                        acc
                            |> Result.andThen
                                (\fs ->
                                    resolveMembers brand family spec
                                        |> Result.map (\members -> { name = family, members = members, degenerate = False } :: fs)
                                )
                    )
                    (Ok [])

        -- Every component name already claimed by a declared family (root or member).
        claimed =
            declared
                |> List.concatMap
                    (\( family, spec ) ->
                        (case spec.root of
                            Just root ->
                                [ root ]

                            Nothing ->
                                []
                        )
                            ++ (spec.members |> List.map .component)
                    )
                |> Set.fromList

        -- Builder-bearing elements NOT in any declared family → degenerate
        -- single-member families. `homeOf == Nothing` mirrors Emit.elm's `own`
        -- filter exactly, so the degenerate set + declared members == every
        -- element that has a per-element builder today.
        degenerateFamilies =
            brand.comps
                |> List.filter (\c -> homeOf c == Nothing && not (Set.member c.name claimed))
                |> List.map
                    (\c ->
                        { name = c.name
                        , members = [ { comp = c, label = c.name, exposedPrefix = "" } ]
                        , degenerate = True
                        }
                    )
    in
    declaredResult
        |> Result.map (\fams -> fams ++ degenerateFamilies)



-- ── render one composed <lib>.Build2.<Family> module ───────────────────────


{-| Render a Build module for a set of members, all sourced through ONE family
façade (`<lib>.Component.<facadeFamily>`). Used two ways:

  - the aggregated `<lib>.Build.<Family>` module (all members, member-prefixed);
  - a flat per-element `<lib>.Build.<Element>` module (one member, EMPTY
    exposedPrefix → the flat un-prefixed surface consumers use), whose member's
    `label` still points at that element's member-prefixed re-exports in the
    family façade.

Both are first-class permanent surfaces (Jack's OQ-3/OQ-4 dual-surface
decision). There is ONE real implementation shape (`memberDecls`); the two
callers differ only in which members and what exposedPrefix they pass.
-}
renderModule : Brand -> (String -> String) -> { modName : String, facadeFamily : String, members : List Member, blurb : List String } -> Rendered
renderModule brand pathOf spec =
    let
        lib =
            brand.lib

        modName =
            spec.modName

        members =
            spec.members

        facadeModule =
            lib ++ ".Component." ++ spec.facadeFamily

        exposedNames =
            members |> List.concatMap (memberExposed brand)

        exposingList =
            String.join "\n    , " exposedNames

        moduleLine =
            "module " ++ modName ++ " exposing\n    ( " ++ exposingList ++ "\n    )"

        docLines =
            String.join "\n"
                (spec.blurb
                    ++ [ ""
                       , "@docs " ++ String.join ", " exposedNames
                       , "-}"
                       ]
                )

        -- Conditional imports, computed as the UNION of the shipped per-element
        -- emitter's conditions (`Component.elm`'s compBuildModule) over the
        -- family's members — so a composed module never imports a namespace no
        -- member uses (the `auditPackage`/NB1 gate flags undeclared foreign
        -- namespaces, so an unconditional-but-unused `<lib>.Action` import would
        -- force a spurious dep). A member's builder references:
        --   * `Ac.*` only when it has actionCaps;
        --   * `Ev.*` only when it has events;
        --   * `Json.Encode.float` only when a float-property setter fires.
        anyMember pred =
            members |> List.any (\m -> pred m.comp)

        needsAction =
            anyMember (\c -> c.actionCaps /= Nothing)

        needsEvents =
            anyMember (\c -> not (List.isEmpty c.events))

        needsJsonEncode =
            anyMember (\c -> needsJsonEncodeImport brand c.attrs)

        imports =
            List.concat
                [ [ "import HtmlIr.Element as El exposing (Element)"
                  , "import HtmlIr.Internal as Ir"
                  , "import HtmlIr.Kind exposing (Shared, Supported)"
                  , "import HtmlIr.Value exposing (Value)"
                  ]
                , if needsAction then
                    [ "import " ++ lib ++ ".Action as Ac" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Attributes as A"
                  , "import " ++ facadeModule ++ " as Component"
                  ]
                , if needsEvents then
                    [ "import " ++ lib ++ ".Events as Ev" ]

                  else
                    []
                , [ "import " ++ lib ++ ".Forge.Internal as B"
                  , "import " ++ lib ++ ".Kind exposing (Available, Brand, Ctx, Used)"
                  , "import " ++ lib ++ ".Values"
                  ]
                , if needsJsonEncode then
                    [ "import Json.Encode" ]

                  else
                    []
                ]
                |> String.join "\n"

        body =
            members
                |> List.concatMap (memberDecls brand)
                |> String.join "\n"

        contents =
            String.join "\n"
                [ moduleLine
                , ""
                , docLines
                , ""
                , imports
                , body
                , ""
                ]
    in
    { moduleName = modName
    , elmFile = { path = pathOf modName, contents = contents, warnings = [] }
    }


{-| The aggregated `<lib>.Build.<Family>` module — every member, member-prefixed
(or, for a degenerate single-member family, the flat un-prefixed surface — which
makes it ALSO the element's per-element module, so no separate one is emitted).
-}
renderFamilyModule : Brand -> (String -> String) -> ResolvedFamily -> Rendered
renderFamilyModule brand pathOf fam =
    let
        lib =
            brand.lib
    in
    renderModule brand
        pathOf
        { modName = lib ++ ".Build." ++ fam.name
        , facadeFamily = fam.name
        , members = fam.members
        , blurb =
            [ "{-| The **" ++ fam.name ++ "** family — the COMPOSED builder tier."
            , ""
            , if fam.degenerate then
                "A degenerate single-member family: the flat, un-prefixed per-element"

              else
                "One module carrying every member's builder surface, member-prefixed"
            , if fam.degenerate then
                "builder surface, sourced through `" ++ lib ++ ".Component." ++ fam.name ++ "`"

              else
                "(the per-element flat surface lives at `" ++ lib ++ ".Build.<Element>`), sourced through `" ++ lib ++ ".Component." ++ fam.name ++ "`"
            , "— the one real Components-driven builder implementation (DAG"
            , "`Build → Components → Elements → Core`), never `" ++ lib ++ ".Element.*`."
            ]
        }


{-| A flat per-element `<lib>.Build.<Element>` module for one member of a
MULTI-member declared family: the exact flat un-prefixed surface consumers use
today (`build`, `Builder`, `withClass`), but sourced through the member's
member-prefixed re-exports in its family's `<lib>.Component.<Family>` façade
(NEVER `<lib>.Element.*`). Jack's permanent dual surface: this element module and
its `<lib>.Build.<Family>` sibling both ship, both first-class.
-}
renderElementModule : Brand -> (String -> String) -> String -> Member -> Rendered
renderElementModule brand pathOf family member =
    let
        lib =
            brand.lib

        element =
            member.comp.name
    in
    renderModule brand
        pathOf
        { modName = lib ++ ".Build." ++ element
        , facadeFamily = family
        , members = [ { member | exposedPrefix = "" } ]
        , blurb =
            [ "{-| The **" ++ element ++ "** element — the flat per-element builder surface,"
            , "sourced through the **" ++ family ++ "** family façade"
            , "(`" ++ lib ++ ".Component." ++ family ++ "`). This module and the aggregated"
            , "`" ++ lib ++ ".Build." ++ family ++ "` are both first-class, permanent surfaces"
            , "(DAG-rework OQ-3/OQ-4)."
            ]
        }



-- ── package plumbing (Build becomes a family-generated package) ────────────


type alias Rendered =
    { moduleName : String
    , elmFile : Elm.File
    }


{-| The `../<build-pkg-dir>/src/<Mod/Path>.elm` path for a Build module (relative
to `--output=src`, so `src/../../<dir>` lands it at the sibling package dir). The
build package dir is DERIVED per-brand from the components config
(`FamiliesConfig`), never hardcoded — see `buildPkgDir`.
-}
buildSrcPath : FamiliesConfig -> String -> String
buildSrcPath cfg modName =
    "../" ++ buildPkgDir cfg ++ "/src/" ++ String.join "/" (String.split "." modName) ++ ".elm"


{-| The build package's directory — DERIVED from the components config's
`package.dir` (the "template = components package" rule): the same sibling-dir
convention with the trailing `components` token swapped for `build` (a
`"../<pfx>-components"` dir yields `"../<pfx>-build"`). Brand-agnostic: it is
computed from whatever the brand's components package dir is.
-}
buildPkgDir : FamiliesConfig -> String
buildPkgDir cfg =
    replaceSuffix "components" "build" cfg.package.dir


{-| The build package's directory, name, summary, and deps — derived from the
components `FamiliesConfig.package` (the "template = components package" rule):
same version/license, the `components` token swapped for `build` in dir + name +
summary, and the components package itself ADDED as a dep (the composed builders
import `<lib>.Component.*`). The components-derived `<pfx>-elements` dep is
dropped (Build reaches Elements transitively through Components — it never imports
`<lib>.Element.*` directly). `family-deps.js` `auditPackage` verifies this
declared set against the emitted imports (D-DAG4).
-}
buildPackageConfig : FamiliesConfig -> FamilyPackageConfig
buildPackageConfig cfg =
    let
        comps =
            cfg.package
    in
    { dir = buildPkgDir cfg
    , name = replaceSuffix "components" "build" comps.name
    , summary = "Composed phantom builder API (" ++ cfg.lib ++ ".Build.*) for " ++ cfg.lib ++ "."
    , version = comps.version
    , deps =
        (comps.deps
            |> List.filter (\( k, _ ) -> k /= replaceSuffix "components" "elements" comps.name)
        )
            ++ [ ( comps.name, familyRange ) ]
    , licenseText = comps.licenseText
    }


{-| Swap a trailing `from` token for `to` (e.g. the `-components` suffix of a
package dir/name for `-build`). If the string does not end with `from`, it is
returned unchanged (defensive; the components convention always ends in it). -}
replaceSuffix : String -> String -> String -> String
replaceSuffix from to s =
    if String.endsWith from s then
        String.dropRight (String.length from) s ++ to

    else
        s


{-| The standard unpublished-family version range every sibling family dep uses
(single-sourced the same way `bin/family-deps.js` does). -}
familyRange : String
familyRange =
    "1.0.0 <= v < 2.0.0"


{-| The `<lib>.Build` barrel: `Builder`, `toElement`, and one `<Element>Is`
alias per builder-bearing element (so a consumer can annotate a phantom-kind
type without importing the element's builder module).

Unlike the shipped `AttrsRow.buildModule`, this is family-root-aware: an
`<Element>Is` alias forwards to wherever that element's `Is` actually lives —
`<lib>.Build.<Element>.Is` for a degenerate element or a non-root family member
(both have a flat per-element module exposing `Is`), but
`<lib>.Build.<Family>.<Family>Is` for a family ROOT (whose flat module name is
occupied by the aggregated member-prefixed family module, exactly as the
Components tier treats its own roots). This is why the barrel is emitted HERE
(where the family structure is known) rather than by the per-element emitter.
-}
renderBarrel : Brand -> (String -> String) -> List ResolvedFamily -> Elm.File
renderBarrel brand pathOf families =
    let
        lib =
            brand.lib

        own =
            brand.comps |> List.filter (\c -> homeOf c == Nothing)

        -- element name → { module it lives in, its Is alias name there }
        isSource : String -> { modName : String, isName : String }
        isSource element =
            let
                owning =
                    families
                        |> List.filter (\f -> f.members |> List.any (\m -> m.comp.name == element))
                        |> List.head
            in
            case owning of
                Just fam ->
                    if fam.degenerate || element /= fam.name then
                        -- flat per-element module exists → un-prefixed `Is`
                        { modName = lib ++ ".Build." ++ element, isName = "Is" }

                    else
                        -- family root → member-prefixed alias in the family module
                        { modName = lib ++ ".Build." ++ fam.name, isName = fam.name ++ "Is" }

                Nothing ->
                    -- unreachable (every own element is in some family), but keep
                    -- total: fall back to the flat per-element assumption.
                    { modName = lib ++ ".Build." ++ element, isName = "Is" }

        isAliasNames =
            own |> List.map (\c -> Naming.pascal c.name ++ "Is")

        moduleNames =
            own |> List.map (\c -> (isSource c.name).modName) |> uniqueSorted

        isAliases =
            own
                |> List.concatMap
                    (\c ->
                        let
                            isName =
                                Naming.pascal c.name ++ "Is"

                            src =
                                isSource c.name
                        in
                        [ ""
                        , ""
                        , "{-| The `" ++ c.name ++ "` kind phantom — annotate with `List (Element (" ++ isName ++ " s) admittedBy msg)`."
                        , "-}"
                        , "type alias " ++ isName ++ " s ="
                        , "    " ++ src.modName ++ "." ++ src.isName ++ " s"
                        ]
                    )

        contents =
            String.join "\n"
                (List.concat
                    [ [ "module " ++ lib ++ ".Build exposing"
                      , "    ( Builder, toElement"
                      , "    , " ++ String.join ", " isAliasNames
                      , "    )"
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
                      , "import HtmlIr.Element exposing (Element)"
                      , "import " ++ lib ++ ".Forge.Internal as Internal"
                      ]
                        ++ (moduleNames |> List.map (\m -> "import " ++ m))
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
    in
    { path = pathOf (lib ++ ".Build"), contents = contents, warnings = [] }


uniqueSorted : List String -> List String
uniqueSorted =
    Set.fromList >> Set.toList


{-| Emit the whole composed Build tier as a family-generated package
(`<pfx>-build`) — the DAG-rework Task 4 materialize.

For EVERY builder-bearing element — the 21 declared `_families` families PLUS a
degenerate single-member family per standalone element — this emits:

  - one aggregated `<lib>.Build.<Family>` module, sourced through the
    `<lib>.Component.<Family>` façade, never `<lib>.Element.*`;
  - for each member of a MULTI-member declared family, a flat per-element
    `<lib>.Build.<Element>` module (the flat un-prefixed surface consumers use
    today), ALSO sourced through the family façade — Jack's permanent dual
    surface. A degenerate family's aggregated module already IS the flat
    per-element module (single member, un-prefixed), so no separate one is
    emitted for it; and
  - the `<lib>.Build` barrel + the package `elm.json`/`README`/`LICENSE`.

A brand with no builder-bearing elements emits nothing. A brand with a Build
tier but no `_families` emits every element as a degenerate family (Shape A).

-}
files : Brand -> Maybe FamiliesConfig -> Result (List String) (List Elm.File)
files brand maybeConfig =
    let
        lib =
            brand.lib

        -- SPLIT brand (has a `_families`/components package config): Build is its
        -- own sibling family-generated package — modules land at
        -- `../<build-dir>/src/...` and it ships its own elm.json/README/LICENSE.
        -- Components' degenerate façades are emitted by `FamilyPackage` INTO the
        -- components package (not here).
        --
        -- MONOLITH brand (no `_families`): there is no split at all — every
        -- module lives in the flat
        -- `--output` src. So the Build modules, the degenerate `<lib>.Component.*`
        -- façades, and the barrel are all emitted FLAT (no sibling dir, no package
        -- manifest), and the Build tier routes through those flat Component façades
        -- exactly as a split brand routes through its components package. This is
        -- the Shape A "every builder is a degenerate single-member family" case
        -- (plan blast-radius table) — Build never imports `<lib>.Element.*` in
        -- either brand shape.
        pathOf =
            case maybeConfig of
                Just cfg ->
                    buildSrcPath cfg

                Nothing ->
                    \modName -> String.join "/" (String.split "." modName) ++ ".elm"
    in
    resolveAllFamilies brand maybeConfig
        |> Result.mapError List.singleton
        |> Result.andThen
            (\families ->
                let
                    familyModules =
                        families |> List.map (renderFamilyModule brand pathOf)

                    elementModules =
                        families
                            |> List.filter (not << .degenerate)
                            |> List.concatMap
                                (\fam ->
                                    fam.members
                                        |> List.filter (\m -> m.comp.name /= fam.name)
                                        |> List.map (renderElementModule brand pathOf fam.name)
                                )

                    allRendered =
                        familyModules ++ elementModules

                    -- A brand with no builder-bearing elements emits nothing.
                    hasBuilders =
                        not (List.isEmpty (brand.comps |> List.filter (\c -> homeOf c == Nothing)))

                    barrel =
                        renderBarrel brand pathOf families

                    srcFiles =
                        (allRendered |> List.map .elmFile) ++ [ barrel ]
                in
                if not hasBuilders then
                    Ok []

                else
                    case maybeConfig of
                        Just cfg ->
                            -- Split brand: ship the build package's own manifest.
                            let
                                exposedModules =
                                    (allRendered |> List.map .moduleName)
                                        ++ [ lib ++ ".Build" ]
                                        |> List.sort

                                pkg =
                                    buildPackageConfig cfg

                                packageFiles =
                                    [ familyElmJsonFile pkg exposedModules
                                    , familyReadmeFile pkg
                                    ]
                                        ++ (familyLicenseFile pkg |> Maybe.map List.singleton |> Maybe.withDefault [])
                            in
                            Ok (srcFiles ++ packageFiles)

                        Nothing ->
                            -- Monolith brand: also emit the degenerate
                            -- `<lib>.Component.*` façades FLAT (a monolith has no
                            -- components package to host them; FamilyPackage only
                            -- emits when `_families` is present). Every builder-
                            -- bearing element is a degenerate family, so this
                            -- covers all of them.
                            families
                                |> List.filter .degenerate
                                |> List.foldr
                                    (\fam acc ->
                                        acc
                                            |> Result.andThen
                                                (\fs ->
                                                    let
                                                        modName =
                                                            lib ++ ".Component." ++ fam.name
                                                    in
                                                    degenerateFacadeModule lib brand modName fam.name
                                                        |> Result.map (\src -> file (String.split "." modName) src :: fs)
                                                )
                                    )
                                    (Ok [])
                                |> Result.mapError List.singleton
                                |> Result.map (\facades -> srcFiles ++ facades)
            )
