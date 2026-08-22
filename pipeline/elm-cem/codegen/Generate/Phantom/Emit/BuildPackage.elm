module Generate.Phantom.Emit.BuildPackage exposing (files)

{-| DAG-rework Task 1 (dual-emit PoC scaffold). Emits `<lib>.Build2.<Family>`
COMPOSED builder modules that source their type surface and slot placers from
the `<lib>.Component.<Family>` FAÇADE (`FamilyPackage`'s output) instead of
per-CEM-element `<lib>.Element.*`.

This is the Shape A emitter of `docs/plans/2026-08-21-dag-rework-plan.md`
(§T2, §M1). It is DUAL-EMIT scaffolding: it runs ALONGSIDE the existing
per-element `compBuildModule` (`Emit.elm`'s `own` concatMap), under a
TEMPORARY `Build2` namespace, so nothing shipped changes and the whole thing
is reversible by simply not wiring it into the real `Build` namespace
(Task 4 / materialize is explicitly out of scope for the PoC dispatch).

Sourcing rule (the crux the rework proves): for each family, one module
carrying every member (root + members) builder surface, member-prefixed so
members never collide within the one module — the SAME prefixing scheme
`FamilyPackage.generateFamilyModule` uses (`elementPascal ++ TypeName`,
`elementCamel ++ upperFirst valueName`). Every reference to a member's
element-tier type or slot-placer resolves through
`import <lib>.Component.<Family> as Component` (the façade's member-prefixed
re-export, e.g. `Component.ItemBadgeSlot`, `Component.itemBadge`), NOT
`import <lib>.Element.<X>`. The builder MECHANICS (`B.init`, `B.withChild`,
`B.withAttribute`, `B.toElement`) come from `<lib>.Forge.Internal as B` — a
brand-level module, unchanged.

This module reads `Brand.comps`/`Comp` records directly (same in-memory model
`compBuildModule` renders from) — there is no re-parse of rendered `.elm`
text, matching the anti-drift discipline `FamilyPackage.elm`'s header
describes. It reuses the shared `Generate.Phantom.Emit.Component` and
`Generate.Phantom.Emit.Shared` helpers for every attribute/setter/slot
decision so the composed builder can never diverge from the per-element one
on those decisions.

Standalone elements (in no `_families` member list) are handled as degenerate
single-member families (plan §T2 / Step 1.3) — but under the PoC dispatch
this module is scoped to the families the config actually declares; the
degenerate expansion is recorded as the Task 3 whole-brand extension and is
NOT exercised here (see `files`' doc comment).

@docs files

-}

import Elm
import Generate.Phantom.Emit.AttrsRow exposing (attrsFields, divergesFromCanonical, isEnumSpec, overrideTypes, setterExpr, unionFor)
import Generate.Phantom.Emit.Component exposing (globalSetterInputType)
import Generate.Phantom.Emit.Shared exposing (file, handlerName, payloadTypeAndDecoder, setterInputType)
import Generate.Phantom.Model exposing (Brand, Comp, ResolvedSlot, SlotContent(..))
import Generate.Types exposing (FamiliesConfig, FamilySpec)
import Naming


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
    -- prefixes every emitted name AND the façade reference for this member.
    , label : String
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


{-| The member-prefixed EXPOSED name for one of this member's builder decls.
Types Pascal-prefix (`ItemBuilder`), values camel-prefix
(`itemBuild`, `itemWithClass`, `itemBadge`), matching `FamilyPackage`.
-}
expType : Member -> String -> String
expType member t =
    member.label ++ t


expValue : Member -> String -> String
expValue member v =
    lowerFirst member.label ++ upperFirst v



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
                    Ok { comp = comp, label = label }
    in
    pairs
        |> List.foldr
            (\p acc -> acc |> Result.andThen (\ms -> resolveOne p |> Result.map (\m -> m :: ms)))
            (Ok [])



-- ── render one composed <lib>.Build2.<Family> module ───────────────────────


renderFamily : Brand -> String -> List Member -> Elm.File
renderFamily brand family members =
    let
        lib =
            brand.lib

        modName =
            lib ++ ".Build2." ++ family

        exposedNames =
            members |> List.concatMap (memberExposed brand)

        exposingList =
            String.join "\n    , " exposedNames

        moduleLine =
            "module " ++ modName ++ " exposing\n    ( " ++ exposingList ++ "\n    )"

        docLines =
            String.join "\n"
                [ "{-| The **" ++ family ++ "** family — COMPOSED builders (DAG-rework Task 1 dual-emit PoC)."
                , ""
                , "One module carrying every member's builder surface, member-prefixed,"
                , "sourced through `" ++ lib ++ ".Component." ++ family ++ "` (the family façade) rather"
                , "than the per-element `" ++ lib ++ ".Element.*` modules. This is the Shape A"
                , "`Build2` scaffold; it emits ALONGSIDE the shipped per-element `" ++ lib ++ ".Build.*`"
                , "surface and does not replace it."
                , ""
                , "@docs " ++ String.join ", " exposedNames
                , "-}"
                ]

        imports =
            String.join "\n"
                [ "import HtmlIr.Element as El exposing (Element)"
                , "import HtmlIr.Internal as Ir"
                , "import HtmlIr.Kind exposing (Shared, Supported)"
                , "import HtmlIr.Value exposing (Value)"
                , "import " ++ lib ++ ".Action as Ac"
                , "import " ++ lib ++ ".Attributes as A"
                , "import " ++ lib ++ ".Component." ++ family ++ " as Component"
                , "import " ++ lib ++ ".Events as Ev"
                , "import " ++ lib ++ ".Forge.Internal as B"
                , "import " ++ lib ++ ".Kind exposing (Available, Brand, Ctx, Used)"
                , "import " ++ lib ++ ".Values"
                ]

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
    file (String.split "." modName) contents


{-| Emit every `<lib>.Build2.<Family>` composed-builder module.

`Nothing` config is a silent no-op (a brand with no `_families` — e.g. shoelace
under the PoC — emits nothing here; its degenerate single-member families are
the Task 3 whole-brand extension, out of scope for the PoC).

DUAL-EMIT PoC scoping: this emits for EVERY declared family, under the
temporary `Build2` namespace, alongside the shipped per-element `Build`
tier — nothing shipped changes.

-}
files : Brand -> Maybe FamiliesConfig -> Result (List String) (List Elm.File)
files brand maybeConfig =
    case maybeConfig of
        Nothing ->
            Ok []

        Just cfg ->
            cfg.families
                |> List.foldr
                    (\( family, spec ) acc ->
                        acc
                            |> Result.andThen
                                (\fs ->
                                    resolveMembers brand family spec
                                        |> Result.map (\members -> renderFamily brand family members :: fs)
                                )
                    )
                    (Ok [])
                |> Result.mapError List.singleton
