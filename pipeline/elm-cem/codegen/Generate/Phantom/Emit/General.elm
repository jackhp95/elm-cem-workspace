module Generate.Phantom.Emit.General exposing (..)


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
import Generate.Phantom.Emit.SubstrateReExports exposing (..)


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



