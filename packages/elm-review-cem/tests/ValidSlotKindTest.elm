module ValidSlotKindTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.ValidSlotKind exposing (Unresolved(..), rule, ruleWith)
import Review.Test
import Test exposing (Test, describe, test)


{-| Minimal leaf-component fact (no slots) — present in the index so its noun
resolves as a KNOWN kind. `ValidSlotKind` treats a root-namespace child as a
known kind only when its noun names a component in the facts index; a bare
`M3e.text`/`M3e.none` helper is NOT in the index and stays unresolvable.
-}
leaf : String -> Facts.Fact
leaf noun =
    { component = noun
    , module_ = "M3e." ++ String.toUpper (String.left 1 noun) ++ String.dropLeft 1 noun
    , enums = []
    , requiredSlots = []
    , multiSlots = []
    , attrRewrites = []
    , slotRewrites = []
    , slotKinds = []
    , slotUpgrades = []
    , facets = [ Standard ]
    , requiredAttrs = []
    , actionMap = []
    , groupConstructors = []
    , usesAction = False
    }


{-| A `card` whose default (`unnamed`) slot accepts `iconButton`/`button` and
whose named `actions` slot accepts only `iconButton`. Models the POST-refactor
top-layer shape: raw default children live directly in the content list and
named slots are setters that return Elements. `panel` is a container whose
default slot is declared but UNCONSTRAINED (no `slotKinds`). The leaf components
must be in the index so their nouns resolve as known kinds.
-}
cardFacts : List Facts.Fact
cardFacts =
    [ { component = "card"
      , module_ = "M3e.Card"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ), ( "actions", "actions" ) ]
      , slotKinds = [ ( "unnamed", [ "iconButton", "button" ] ), ( "actions", [ "iconButton" ] ) ]
      , slotUpgrades = []
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    , { component = "panel"
      , module_ = "M3e.Panel"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ) ]
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    , { component = "arbitraryBox"
      , module_ = "M3e.ArbitraryBox"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ), ( "actions", "actions" ) ]

      -- The `"arbitrary"` config token encodes as a present-but-EMPTY kind list
      -- (accepts anything). This must read as unconstrained, exactly like the
      -- absent-entry `panel` above — not as "constrained to nothing".
      , slotKinds = [ ( "unnamed", [] ), ( "actions", [] ) ]
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    , leaf "iconButton"
    , leaf "button"
    , leaf "fabMenuItem"
    ]


{-| WS2 facts: a flexCard with a mixed slot (private + shared-atom kinds),
plus the atom component `text` as a known kind. Separate from `cardFacts` so
the existing `M3e.text` non-component test stays unaffected.
-}
ws2Facts : List Facts.Fact
ws2Facts =
    [ { component = "flexCard"
      , module_ = "M3e.FlexCard"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ) ]
      , slotKinds = [ ( "unnamed", [ "iconButton", "shared:text" ] ) ]
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    , leaf "iconButton"
    , leaf "button"
    , leaf "text"
    ]


all : Test
all =
    describe "ValidSlotKind"
        [ describe "Lenient (default)"
            [ test "(a) child stamped with a slot the container doesn't declare -> error" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] [ M3e.Card.header (M3e.iconButton [] []) ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`card` does not declare a slot for `header`"
                                , details =
                                    [ "This child is stamped with a slot the container doesn't declare; it won't render where you expect."
                                    ]
                                , under = "M3e.Card.header (M3e.iconButton [] [])"
                                }
                            ]
            , test "(b) raw default child whose kind is not allowed by the default slot -> error" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] [ M3e.fabMenuItem [] [] ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`fabMenuItem` is not an allowed child of the `default` slot on `card`"
                                , details =
                                    [ "The `default` slot accepts: iconButton, button."
                                    , "Move this child to a slot that accepts it, or use an allowed component."
                                    ]
                                , under = "M3e.fabMenuItem [] []"
                                }
                            ]
            , test "(b') named-slot child whose kind is not allowed -> error" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] [ M3e.Card.actions (M3e.fabMenuItem [] []) ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`fabMenuItem` is not an allowed child of the `actions` slot on `card`"
                                , details =
                                    [ "The `actions` slot accepts: iconButton."
                                    , "Move this child to a slot that accepts it, or use an allowed component."
                                    ]
                                , under = "M3e.Card.actions (M3e.fabMenuItem [] [])"
                                }
                            ]
            , test "(c) valid named slot + allowed kind -> no error" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] [ M3e.Card.actions (M3e.iconButton [] []) ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectNoErrors
            , test "(c') raw default child with an allowed kind -> no error" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] [ M3e.iconButton [] [] ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectNoErrors
            , test "(d) unresolvable child from List.map -> no error under Lenient" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] (List.map render rows)
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectNoErrors
            , test "(d') let-bound child of unknown kind -> no error under Lenient" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v =
    let
        thing = something
    in
    M3e.Card.view [] [ thing ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectNoErrors
            , test "(e) non-component barrel helper in a constrained slot -> no false disallowed error" <|
                -- `M3e.text` resolves via callSite but is NOT a component in the
                -- facts index, so its kind is unresolvable rather than a bogus
                -- noun that would trip the constrained default slot's kind check.
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] [ M3e.text "x" ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectNoErrors
            , test "(f) any child in an `arbitrary` (present-but-empty) default slot -> no error" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.ArbitraryBox
v = M3e.ArbitraryBox.view [] [ M3e.fabMenuItem [] [] ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectNoErrors
            , test "(f') any child in an `arbitrary` (present-but-empty) named slot -> no error" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.ArbitraryBox
v = M3e.ArbitraryBox.view [] [ M3e.ArbitraryBox.actions (M3e.fabMenuItem [] []) ]
"""
                        |> Review.Test.run (rule cardFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "Strict (opt-in)"
            [ test "(d) unresolvable child from List.map -> warning under Strict" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] (List.map render rows)
"""
                        |> Review.Test.run (ruleWith Strict cardFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Cannot statically resolve the kind of a child in the `default` slot on `card`"
                                , details =
                                    [ "Strict mode is on: this child's kind couldn't be determined, so it can't be checked against the slot's allowed kinds."
                                    ]
                                , under = "render"
                                }
                            ]
            , test "(d') let-bound child of unknown kind -> warning under Strict" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v =
    let
        thing = something
    in
    M3e.Card.view [] [ thing ]
"""
                        |> Review.Test.run (ruleWith Strict cardFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "Cannot statically resolve the kind of a child in the `default` slot on `card`"
                                , details =
                                    [ "Strict mode is on: this child's kind couldn't be determined, so it can't be checked against the slot's allowed kinds."
                                    ]
                                , under = "thing"
                                }
                                |> Review.Test.atExactly { start = { row = 8, column = 24 }, end = { row = 8, column = 29 } }
                            ]
            , test "Strict does not warn on statically-resolvable, allowed children" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] [ M3e.iconButton [] [], M3e.Card.actions (M3e.iconButton [] []) ]
"""
                        |> Review.Test.run (ruleWith Strict cardFacts)
                        |> Review.Test.expectNoErrors
            , test "Strict still flags a genuinely disallowed kind" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Card
v = M3e.Card.view [] [ M3e.fabMenuItem [] [] ]
"""
                        |> Review.Test.run (ruleWith Strict cardFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`fabMenuItem` is not an allowed child of the `default` slot on `card`"
                                , details =
                                    [ "The `default` slot accepts: iconButton, button."
                                    , "Move this child to a slot that accepts it, or use an allowed component."
                                    ]
                                , under = "M3e.fabMenuItem [] []"
                                }
                            ]
            , test "Strict stays silent on an unresolvable child in an UNCONSTRAINED slot" <|
                -- `panel`'s default slot is declared but has no `slotKinds`, so
                -- there is nothing to enforce — Strict must not warn even though
                -- the child's kind can't be resolved.
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Panel
v = M3e.Panel.view [] [ mystery ]
"""
                        |> Review.Test.run (ruleWith Strict cardFacts)
                        |> Review.Test.expectNoErrors
            , test "Strict stays silent on an unresolvable child in an `arbitrary` (present-but-empty) slot" <|
                -- `arbitraryBox`'s slots ARE in `slotKinds` but with an empty
                -- list (the `"arbitrary"` encoding) — unconstrained, so Strict
                -- must not warn even when the child's kind can't be resolved.
                \() ->
                    """module A exposing (v)
import M3e
import M3e.ArbitraryBox
v = M3e.ArbitraryBox.view [] [ mystery ]
"""
                        |> Review.Test.run (ruleWith Strict cardFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "WS2: shared-atom kind acceptance (shared: prefix in slotKinds)"
            [ test "a child with kind 'text' is accepted when the slot allows 'shared:text'" <|
                -- flexCard's default slot allows ["iconButton", "shared:text"].
                -- M3e.text is a role-tier element with kind "text".
                -- The review rule must accept it (shared-atom match via shared: prefix).
                \() ->
                    """module A exposing (v)
import M3e
import M3e.FlexCard
v = M3e.FlexCard.view [] [ M3e.text [] [] ]
"""
                        |> Review.Test.run (rule ws2Facts)
                        |> Review.Test.expectNoErrors
            , test "a private-kind child is still accepted in a mixed slot" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.FlexCard
v = M3e.FlexCard.view [] [ M3e.iconButton [] [] ]
"""
                        |> Review.Test.run (rule ws2Facts)
                        |> Review.Test.expectNoErrors
            , test "a foreign private kind is still rejected in a mixed slot" <|
                -- flexCard accepts "iconButton" and "shared:text" but not "button"
                \() ->
                    """module A exposing (v)
import M3e
import M3e.FlexCard
v = M3e.FlexCard.view [] [ M3e.button [] [] ]
"""
                        |> Review.Test.run (rule ws2Facts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`button` is not an allowed child of the `default` slot on `flexCard`"
                                , details =
                                    [ "The `default` slot accepts: iconButton, shared:text."
                                    , "Move this child to a slot that accepts it, or use an allowed component."
                                    ]
                                , under = "M3e.button [] []"
                                }
                            ]
            ]
        ]
