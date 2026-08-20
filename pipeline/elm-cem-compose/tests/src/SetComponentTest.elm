module SetComponentTest exposing (all)

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
    describe "componentOptions and SetComponent"
        [ describe "componentOptions"
            [ test "at root: every fact minus the current component, sorted" <|
                \_ ->
                    C.componentOptions [] (start "container")
                        |> Expect.equal [ "gadget", "iconic", "labelled", "mixed", "narrow", "single", "widget" ]
            , test "at a nested node: the parent slot's afforded components minus the current one" <|
                \_ ->
                    start "container"
                        |> apply [ C.AddChild [] "unnamed" "widget" ]
                        |> C.componentOptions [ C.IntoSlot "unnamed" 0 ]
                        |> Expect.equal [ "container" ]
            , test "an unresolvable path yields no options" <|
                \_ ->
                    C.componentOptions [ C.IntoSlot "nope" 0 ] (start "container")
                        |> Expect.equal []
            ]
        , describe "SetComponent"
            [ test "to a component the parent slot does not afford is a no-op" <|
                \_ ->
                    let
                        seeded =
                            start "container" |> apply [ C.AddChild [] "unnamed" "widget" ]
                    in
                    seeded
                        |> apply [ C.SetComponent [ C.IntoSlot "unnamed" 0 ] "labelled" ]
                        |> Expect.equal seeded
            , test "swaps componentOf" <|
                \_ ->
                    start "container"
                        |> apply
                            [ C.AddChild [] "unnamed" "widget"
                            , C.SetComponent [ C.IntoSlot "unnamed" 0 ] "container"
                            ]
                        |> C.nodeAt [ C.IntoSlot "unnamed" 0 ]
                        |> Maybe.map C.componentOf
                        |> Expect.equal (Just "container")
            , test "keeps attrs the target still offers, drops the rest" <|
                \_ ->
                    start "widget"
                        |> apply
                            [ C.SetAttr [] "disabled" (C.AttrBool True)
                            , C.SetAttr [] "count" (C.AttrInt "3")
                            , C.SetComponent [] "gadget"
                            ]
                        |> .root
                        |> C.attrsOf
                        |> Expect.equal [ ( "disabled", C.AttrBool True ) ]
            , test "drops a child in a slot the target does not declare" <|
                \_ ->
                    start "container"
                        |> apply
                            [ C.AddChild [] "unnamed" "widget"
                            , C.SetComponent [] "single"
                            ]
                        |> .root
                        |> C.slotsOf
                        |> Expect.equal []
            , test "drops a child whose kind the target's (same-named) slot no longer affords" <|
                \_ ->
                    start "container"
                        |> apply
                            [ C.AddChild [] "unnamed" "widget"
                            , C.AddChild [] "unnamed" "container"
                            , C.SetComponent [] "narrow"
                            ]
                        |> slotCount [] "unnamed"
                        |> Expect.equal 1
            , test "keeps a child whose kind the target's (same-named) slot still affords" <|
                \_ ->
                    start "container"
                        |> apply
                            [ C.AddChild [] "unnamed" "widget"
                            , C.AddChild [] "unnamed" "container"
                            , C.SetComponent [] "narrow"
                            ]
                        |> C.nodeAt [ C.IntoSlot "unnamed" 0 ]
                        |> Maybe.map C.componentOf
                        |> Expect.equal (Just "container")
            , test "enforces the target's non-multi cap after a swap: two survivors collapse to the first" <|
                \_ ->
                    start "container"
                        |> apply
                            [ C.AddChild [] "unnamed" "container"
                            , C.AddChild [] "unnamed" "container"
                            , C.SetComponent [] "narrow"
                            ]
                        |> slotCount [] "unnamed"
                        |> Expect.equal 1
            , test "clears openMenu, like every structural message" <|
                \_ ->
                    start "container"
                        |> apply [ C.OpenMenu [] (C.SlotMenu "unnamed"), C.SetComponent [] "widget" ]
                        |> .openMenu
                        |> Expect.equal Nothing
            , test "every componentOptions entry changes the model when applied" <|
                \_ ->
                    let
                        checkAt path model =
                            C.componentOptions path model
                                |> List.map (\target -> C.update (C.SetComponent path target) model /= model)

                        results =
                            List.concat
                                [ checkAt [] (start "container")
                                , checkAt [ C.IntoSlot "unnamed" 0 ]
                                    (start "container" |> apply [ C.AddChild [] "unnamed" "widget" ])
                                ]
                    in
                    results |> Expect.equal (List.repeat (List.length results) True)
            ]
        ]
