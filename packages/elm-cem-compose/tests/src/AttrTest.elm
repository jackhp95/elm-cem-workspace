module AttrTest exposing (all)

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


start : C.Model
start =
    C.init { facts = FakeFacts.all, attrKinds = kinds, root = "widget" }


names : C.Model -> List String
names model =
    C.attrChips [] model |> List.map .name


all : Test
all =
    describe "attribute chips"
        [ test "enum chips come first, then plain chips deduplicated and sorted" <|
            \_ ->
                names start
                    |> Expect.equal [ "variant", "count", "disabled", "label", "ratio" ]
        , test "an attrRewrites name absent from attrKinds produces no chip" <|
            \_ ->
                names start
                    |> List.member "onClick"
                    |> Expect.equal False
        , test "a name in both enums and attrRewrites produces exactly one chip" <|
            \_ ->
                names start
                    |> List.filter (\n -> n == "variant")
                    |> List.length
                    |> Expect.equal 1
        , test "the variant chip carries its tokens" <|
            \_ ->
                C.attrChips [] start
                    |> List.filter (\c -> c.name == "variant")
                    |> List.map .kind
                    |> Expect.equal [ C.EnumChip [ "filled", "outlined" ] ]
        , test "a plain chip carries its kind" <|
            \_ ->
                C.attrChips [] start
                    |> List.filter (\c -> c.name == "count")
                    |> List.map .kind
                    |> Expect.equal [ C.PlainChip C.IntAttr ]
        , test "isSet is False before any SetAttr" <|
            \_ ->
                C.attrChips [] start
                    |> List.filter (\c -> c.name == "variant")
                    |> List.map .isSet
                    |> Expect.equal [ False ]
        , test "isSet is True after SetAttr, and carries the value" <|
            \_ ->
                start
                    |> C.update (C.SetAttr [] "variant" (C.AttrEnum "filled"))
                    |> C.attrChips []
                    |> List.filter (\c -> c.name == "variant")
                    |> List.map (\c -> ( c.isSet, c.currentValue ))
                    |> Expect.equal [ ( True, Just (C.AttrEnum "filled") ) ]
        , test "ClearAttr returns isSet to False" <|
            \_ ->
                start
                    |> C.update (C.SetAttr [] "variant" (C.AttrEnum "filled"))
                    |> C.update (C.ClearAttr [] "variant")
                    |> C.attrChips []
                    |> List.filter (\c -> c.name == "variant")
                    |> List.map .isSet
                    |> Expect.equal [ False ]
        , test "an unresolvable path yields no chips" <|
            \_ ->
                C.attrChips [ C.IntoSlot "nope" 0 ] start
                    |> Expect.equal []
        , describe "attribute menus"
            [ test "an unset enum offers its tokens with no current selection" <|
                \_ ->
                    C.attrMenuOptions [] "variant" start
                        |> Expect.equal
                            (Just (C.EnumTokens [ "filled", "outlined" ] Nothing))
            , test "a set enum reports the current token" <|
                \_ ->
                    start
                        |> C.update (C.SetAttr [] "variant" (C.AttrEnum "filled"))
                        |> C.attrMenuOptions [] "variant"
                        |> Expect.equal
                            (Just (C.EnumTokens [ "filled", "outlined" ] (Just "filled")))
            , test "an unset boolean defaults to False" <|
                \_ ->
                    C.attrMenuOptions [] "disabled" start
                        |> Expect.equal (Just (C.BoolToggle False))
            , test "an unset string defaults to empty" <|
                \_ ->
                    C.attrMenuOptions [] "label" start
                        |> Expect.equal (Just (C.TextInput ""))
            , test "numbers carry raw entry text, so a half-typed value survives" <|
                \_ ->
                    start
                        |> C.update (C.SetAttr [] "ratio" (C.AttrFloat "1."))
                        |> C.attrMenuOptions [] "ratio"
                        |> Expect.equal (Just (C.NumberInput C.FloatNumber "1."))
            , test "an int attribute reports IntNumber" <|
                \_ ->
                    C.attrMenuOptions [] "count" start
                        |> Expect.equal (Just (C.NumberInput C.IntNumber ""))
            , test "an attribute this node does not offer is Nothing" <|
                \_ ->
                    C.attrMenuOptions [] "nope" start
                        |> Expect.equal Nothing
            , test "an unresolvable path is Nothing" <|
                \_ ->
                    C.attrMenuOptions [ C.IntoSlot "nope" 0 ] "variant" start
                        |> Expect.equal Nothing
            ]
        ]
