module SlotTest exposing (all)

import Cem.Compose as C
import Dict
import Expect
import FakeFacts
import Test exposing (Test, describe, test)


start : String -> C.Model
start root =
    C.init { facts = FakeFacts.all, attrKinds = Dict.empty, root = root }


chip : String -> String -> Maybe C.SlotChipInfo
chip root slot =
    C.slotChips [] (start root)
        |> List.filter (\c -> c.name == slot)
        |> List.head


affordances : String -> String -> Maybe C.SlotAffordances
affordances root slot =
    Maybe.map .affordances (chip root slot)


all : Test
all =
    describe "slot affordances"
        [ test "a slot naming BOTH text and a component offers BOTH" <|
            \_ ->
                affordances "mixed" "any"
                    |> Expect.equal
                        (Just { text = True, icon = True, components = [ "widget" ] })
        , test "shared:flow counts as text, and coexists with a component" <|
            \_ ->
                affordances "mixed" "flowy"
                    |> Expect.equal
                        (Just { text = True, icon = False, components = [ "widget" ] })
        , test "empty kinds means text-only, never every-component" <|
            \_ ->
                affordances "mixed" "unconstrained"
                    |> Expect.equal
                        (Just { text = True, icon = False, components = [] })
        , test "a text-only slot" <|
            \_ ->
                affordances "labelled" "headline"
                    |> Expect.equal
                        (Just { text = True, icon = False, components = [] })
        , test "an icon-only slot" <|
            \_ ->
                affordances "iconic" "lead"
                    |> Expect.equal
                        (Just { text = False, icon = True, components = [] })
        , test "a components-only slot affords no text" <|
            \_ ->
                affordances "container" "unnamed"
                    |> Expect.equal
                        (Just { text = False, icon = False, components = [ "widget", "container" ] })
        , test "a component absent from facts is silently omitted" <|
            \_ ->
                affordances "container" "unnamed"
                    |> Maybe.map (.components >> List.member "ghost")
                    |> Expect.equal (Just False)
        , test "required is read from requiredSlots" <|
            \_ ->
                Maybe.map .required (chip "labelled" "headline")
                    |> Expect.equal (Just True)
        , test "max is Nothing for a multi slot" <|
            \_ ->
                Maybe.map .max (chip "container" "unnamed")
                    |> Expect.equal (Just Nothing)
        , test "max is Just 1 for a non-multi slot" <|
            \_ ->
                Maybe.map .max (chip "single" "only")
                    |> Expect.equal (Just (Just 1))
        , test "filled counts current children" <|
            \_ ->
                start "container"
                    |> C.update (C.AddChild [] "unnamed" "widget")
                    |> C.slotChips []
                    |> List.filter (\c -> c.name == "unnamed")
                    |> List.map .filled
                    |> Expect.equal [ 1 ]
        , test "required slots come first, then the rest alphabetically" <|
            \_ ->
                C.slotChips [] (start "mixed")
                    |> List.map .name
                    |> Expect.equal [ "any", "flowy", "unconstrained" ]
        , test "the slot set is the union of requiredSlots, multiSlots and slotKinds keys" <|
            \_ ->
                C.slotChips [] (start "labelled")
                    |> List.map .name
                    |> Expect.equal [ "headline" ]
        , test "an unresolvable path yields no chips" <|
            \_ ->
                C.slotChips [ C.IntoSlot "nope" 0 ] (start "container")
                    |> Expect.equal []
        ]
