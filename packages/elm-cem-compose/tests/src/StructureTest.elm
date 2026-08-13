module StructureTest exposing (all)

import Cem.Compose as C
import Dict
import Expect
import FakeFacts
import Test exposing (Test, describe, test)


kinds : Dict.Dict String C.AttrKind
kinds =
    Dict.fromList
        [ ( "disabled", C.BoolAttr )
        , ( "label", C.StringAttr )
        , ( "count", C.IntAttr )
        , ( "ratio", C.FloatAttr )
        ]


start : String -> C.Model
start root =
    C.init { facts = FakeFacts.all, attrKinds = kinds, root = root }


apply : List C.Msg -> C.Model -> C.Model
apply msgs model =
    List.foldl C.update model msgs


slotCount : C.Path -> String -> C.Model -> Int
slotCount path slot model =
    C.nodeAt path model
        |> Maybe.map C.slotsOf
        |> Maybe.withDefault []
        |> List.filter (\( n, _ ) -> n == slot)
        |> List.head
        |> Maybe.map (Tuple.second >> List.length)
        |> Maybe.withDefault 0


all : Test
all =
    describe "structure and addressing"
        [ test "init makes an empty root of the named component" <|
            \_ ->
                start "container"
                    |> .root
                    |> C.componentOf
                    |> Expect.equal "container"
        , test "an unknown root component still constructs; queries are empty" <|
            \_ ->
                start "nope"
                    |> (\m -> ( C.componentOf m.root, C.slotsOf m.root ))
                    |> Expect.equal ( "nope", [] )
        , test "AddChild on a multi slot appends" <|
            \_ ->
                start "container"
                    |> apply
                        [ C.AddChild [] "unnamed" "widget"
                        , C.AddChild [] "unnamed" "widget"
                        ]
                    |> slotCount [] "unnamed"
                    |> Expect.equal 2
        , test "AddChild on a non-multi slot replaces, keeping the SECOND component" <|
            \_ ->
                start "single"
                    |> apply
                        [ C.AddChild [] "only" "widget"
                        , C.AddChild [] "only" "single"
                        ]
                    |> (\m ->
                            ( slotCount [] "only" m
                            , C.nodeAt [ C.IntoSlot "only" 0 ] m |> Maybe.map C.componentOf
                            )
                       )
                    |> Expect.equal ( 1, Just "single" )
        , test "AddChild with a component absent from facts is a no-op" <|
            \_ ->
                start "container"
                    |> apply [ C.AddChild [] "unnamed" "ghost" ]
                    |> slotCount [] "unnamed"
                    |> Expect.equal 0
        , test "updateAt at depth 2 edits the right node" <|
            \_ ->
                start "container"
                    |> apply
                        [ C.AddChild [] "unnamed" "container"
                        , C.AddChild [ C.IntoSlot "unnamed" 0 ] "unnamed" "widget"
                        , C.SetAttr [ C.IntoSlot "unnamed" 0, C.IntoSlot "unnamed" 0 ] "label" (C.AttrString "deep")
                        ]
                    |> C.nodeAt [ C.IntoSlot "unnamed" 0, C.IntoSlot "unnamed" 0 ]
                    |> Maybe.map C.attrsOf
                    |> Expect.equal (Just [ ( "label", C.AttrString "deep" ) ])
        , test "an edit at depth leaves siblings byte-identical" <|
            \_ ->
                let
                    seeded =
                        start "container"
                            |> apply
                                [ C.AddChild [] "unnamed" "widget"
                                , C.AddChild [] "unnamed" "widget"
                                ]

                    sibling m =
                        C.nodeAt [ C.IntoSlot "unnamed" 1 ] m |> Maybe.map C.attrsOf
                in
                seeded
                    |> apply [ C.SetAttr [ C.IntoSlot "unnamed" 0 ] "label" (C.AttrString "x") ]
                    |> sibling
                    |> Expect.equal (sibling seeded)
        , test "a path landing on a ChildText is a no-op, not a crash" <|
            \_ ->
                let
                    seeded =
                        start "labelled" |> apply [ C.AddTextChild [] "headline" ]
                in
                seeded
                    |> apply [ C.SetAttr [ C.IntoSlot "headline" 0 ] "label" (C.AttrString "x") ]
                    |> Expect.equal seeded
        , test "an out-of-range index is a no-op" <|
            \_ ->
                let
                    seeded =
                        start "container" |> apply [ C.AddChild [] "unnamed" "widget" ]
                in
                seeded
                    |> apply [ C.SetAttr [ C.IntoSlot "unnamed" 7 ] "label" (C.AttrString "x") ]
                    |> Expect.equal seeded
        , test "nodeAt on a text child is Nothing" <|
            \_ ->
                start "labelled"
                    |> apply [ C.AddTextChild [] "headline" ]
                    |> C.nodeAt [ C.IntoSlot "headline" 0 ]
                    |> Expect.equal Nothing
        , test "SetChildContent sets a text payload" <|
            \_ ->
                start "labelled"
                    |> apply
                        [ C.AddTextChild [] "headline"
                        , C.SetChildContent [] "headline" 0 "Inbox"
                        ]
                    |> .root
                    |> C.slotsOf
                    |> Expect.equal [ ( "headline", [ C.ChildText "Inbox" ] ) ]
        , test "AddIconChild defaults to star" <|
            \_ ->
                start "iconic"
                    |> apply [ C.AddIconChild [] "lead" ]
                    |> .root
                    |> C.slotsOf
                    |> Expect.equal [ ( "lead", [ C.ChildIcon "star" ] ) ]
        , test "RemoveChild at index 0 shifts the former index 1 down" <|
            \_ ->
                start "container"
                    |> apply
                        [ C.AddChild [] "unnamed" "widget"
                        , C.AddChild [] "unnamed" "container"
                        , C.RemoveChild [] "unnamed" 0
                        ]
                    |> C.nodeAt [ C.IntoSlot "unnamed" 0 ]
                    |> Maybe.map C.componentOf
                    |> Expect.equal (Just "container")
        , test "RemoveChild drops the whole subtree" <|
            \_ ->
                start "container"
                    |> apply
                        [ C.AddChild [] "unnamed" "container"
                        , C.AddChild [ C.IntoSlot "unnamed" 0 ] "unnamed" "widget"
                        , C.RemoveChild [] "unnamed" 0
                        ]
                    |> slotCount [] "unnamed"
                    |> Expect.equal 0
        , test "the root cannot be removed by any message" <|
            \_ ->
                start "container"
                    |> apply [ C.RemoveChild [] "unnamed" 0 ]
                    |> .root
                    |> C.componentOf
                    |> Expect.equal "container"
        , describe "menu lifecycle"
            [ test "OpenMenu sets openMenu" <|
                \_ ->
                    start "widget"
                        |> apply [ C.OpenMenu [] (C.AttrMenu "variant") ]
                        |> .openMenu
                        |> Expect.equal (Just ( [], C.AttrMenu "variant" ))
            , test "CloseMenu clears it" <|
                \_ ->
                    start "widget"
                        |> apply [ C.OpenMenu [] (C.AttrMenu "variant"), C.CloseMenu ]
                        |> .openMenu
                        |> Expect.equal Nothing
            , test "every structural message clears openMenu" <|
                \_ ->
                    let
                        cleared msg =
                            start "container"
                                |> apply [ C.OpenMenu [] (C.SlotMenu "unnamed"), msg ]
                                |> .openMenu
                    in
                    [ C.SetAttr [] "label" (C.AttrString "x")
                    , C.ClearAttr [] "label"
                    , C.AddChild [] "unnamed" "widget"
                    , C.AddTextChild [] "unnamed"
                    , C.AddIconChild [] "unnamed"
                    , C.SetChildContent [] "unnamed" 0 "x"
                    , C.RemoveChild [] "unnamed" 0
                    ]
                        |> List.map cleared
                        |> Expect.equal (List.repeat 7 Nothing)
            ]
        ]
