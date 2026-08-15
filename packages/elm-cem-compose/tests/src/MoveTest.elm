module MoveTest exposing (all)

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


{-| Seed "unnamed" with three distinguishable widgets by giving each a
different `label`, so identity survives the move and can be checked by
attribute rather than just position.
-}
seedThree : C.Path -> C.Model -> C.Model
seedThree parentPath model =
    model
        |> apply
            [ C.AddChild parentPath "unnamed" "widget"
            , C.AddChild parentPath "unnamed" "widget"
            , C.AddChild parentPath "unnamed" "widget"
            ]
        |> apply
            [ C.SetAttr (parentPath ++ [ C.IntoSlot "unnamed" 0 ]) "label" (C.AttrString "a")
            , C.SetAttr (parentPath ++ [ C.IntoSlot "unnamed" 1 ]) "label" (C.AttrString "b")
            , C.SetAttr (parentPath ++ [ C.IntoSlot "unnamed" 2 ]) "label" (C.AttrString "c")
            ]


labelsAt : C.Path -> C.Model -> List (Maybe String)
labelsAt parentPath model =
    C.nodeAt parentPath model
        |> Maybe.map C.slotsOf
        |> Maybe.withDefault []
        |> List.filter (\( n, _ ) -> n == "unnamed")
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault []
        |> List.map
            (\child ->
                case child of
                    C.ChildNode node ->
                        C.attrsOf node
                            |> List.filter (\( name, _ ) -> name == "label")
                            |> List.head
                            |> Maybe.map
                                (\( _, value ) ->
                                    case value of
                                        C.AttrString s ->
                                            s

                                        _ ->
                                            ""
                                )

                    _ ->
                        Nothing
            )


all : Test
all =
    describe "MoveChild"
        [ test "move down: [a,b,c], MoveChild ...0 1 -> [b,a,c]" <|
            \_ ->
                start "container"
                    |> seedThree []
                    |> apply [ C.MoveChild [] "unnamed" 0 1 ]
                    |> labelsAt []
                    |> Expect.equal [ Just "b", Just "a", Just "c" ]
        , test "move up: [a,b,c], MoveChild ...2 1 -> [a,c,b]" <|
            \_ ->
                start "container"
                    |> seedThree []
                    |> apply [ C.MoveChild [] "unnamed" 2 1 ]
                    |> labelsAt []
                    |> Expect.equal [ Just "a", Just "c", Just "b" ]
        , test "no-op at top: MoveChild ...0 -1 leaves list unchanged" <|
            \_ ->
                let
                    seeded =
                        start "container" |> seedThree []
                in
                seeded
                    |> apply [ C.MoveChild [] "unnamed" 0 -1 ]
                    |> Expect.equal seeded
        , test "no-op at bottom: MoveChild ...2 3 leaves list unchanged" <|
            \_ ->
                let
                    seeded =
                        start "container" |> seedThree []
                in
                seeded
                    |> apply [ C.MoveChild [] "unnamed" 2 3 ]
                    |> Expect.equal seeded
        , test "fromIndex out of bounds -> unchanged model" <|
            \_ ->
                let
                    seeded =
                        start "container" |> seedThree []
                in
                seeded
                    |> apply [ C.MoveChild [] "unnamed" 7 1 ]
                    |> Expect.equal seeded
        , test "negative fromIndex -> unchanged model" <|
            \_ ->
                let
                    seeded =
                        start "container" |> seedThree []
                in
                seeded
                    |> apply [ C.MoveChild [] "unnamed" -1 1 ]
                    |> Expect.equal seeded
        , test "fromIndex == toIndex (after clamp) -> unchanged model" <|
            \_ ->
                let
                    seeded =
                        start "container" |> seedThree []
                in
                seeded
                    |> apply [ C.MoveChild [] "unnamed" 1 1 ]
                    |> Expect.equal seeded
        , test "unresolvable path -> unchanged model" <|
            \_ ->
                let
                    seeded =
                        start "container" |> seedThree []
                in
                seeded
                    |> apply [ C.MoveChild [ C.IntoSlot "unnamed" 99 ] "unnamed" 0 1 ]
                    |> Expect.equal seeded
        , test "nested-path move: reorders siblings under a nested container" <|
            \_ ->
                let
                    nestedPath =
                        [ C.IntoSlot "unnamed" 0 ]
                in
                start "container"
                    |> apply [ C.AddChild [] "unnamed" "container" ]
                    |> seedThree nestedPath
                    |> apply [ C.MoveChild nestedPath "unnamed" 0 2 ]
                    |> labelsAt nestedPath
                    |> Expect.equal [ Just "b", Just "c", Just "a" ]
        , test "move preserves other slots and other children untouched (full-tree identity)" <|
            \_ ->
                let
                    seeded =
                        start "mixed"
                            |> apply
                                [ C.AddTextChild [] "any"
                                , C.AddChild [] "unnamed" "container"
                                ]
                            |> apply [ C.SetChildContent [] "any" 0 "kept" ]

                    nestedPath =
                        [ C.IntoSlot "unnamed" 0 ]

                    seededNested =
                        seedThree nestedPath seeded

                    moved =
                        seededNested |> apply [ C.MoveChild nestedPath "unnamed" 0 2 ]

                    otherSlots model =
                        C.nodeAt [] model
                            |> Maybe.map C.slotsOf
                            |> Maybe.withDefault []
                            |> List.filter (\( n, _ ) -> n == "any")
                in
                otherSlots moved
                    |> Expect.equal (otherSlots seededNested)
        , test "MoveChild clears openMenu, mirroring RemoveChild" <|
            \_ ->
                start "container"
                    |> seedThree []
                    |> apply [ C.OpenMenu [] (C.SlotMenu "unnamed"), C.MoveChild [] "unnamed" 0 1 ]
                    |> .openMenu
                    |> Expect.equal Nothing
        ]
