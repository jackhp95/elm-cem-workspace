# The four test classes (concrete Review.Test shapes)

Every new rule's `tests/YourRuleTest.elm` must cover these four. Snippets use a
neutral `Lib.*` example namespace; copy the fixture shape from an existing test
(e.g. `tests/SingularAttributeTest.elm`) and reuse shared fixtures where possible.

Contents:
- [Fixture setup](#fixture-setup)
- [1. Positive](#1-positive)
- [2. Negative](#2-negative)
- [3. False-positive bait](#3-false-positive-bait)
- [4. Inverse / round-trip](#4-inverse--round-trip)
- [Fixture-defaulting note](#fixture-defaulting-note)

## Fixture setup

A fixture is a `List Cem.Facts.Fact`. Build the minimal fact your rule reads;
default every other field so the record type-checks.

```elm
libFacts : List Facts.Fact
libFacts =
    [ { component = "button"
      , module_ = "Lib.Button"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]
```

## 1. Positive

The violation is flagged with the exact neutral message, non-empty details, and
`under`. Pin the location with `atExactly` when the token appears more than once.

```elm
test "flags the violation" <|
    \() ->
        """module A exposing (v)
import Lib.Button
v = Lib.Button.view [ ... ] []
"""
            |> Review.Test.run (rule libFacts)
            |> Review.Test.expectErrors
                [ Review.Test.error
                    { message = "…concise, facts-derived sentence…"
                    , details = [ "Why, sourced from the component's declared facts.", "What to do." ]
                    , under = "Lib.Button.view"
                    }
                ]
```

## 2. Negative

Correct code produces no errors.

```elm
test "accepts correct usage" <|
    \() ->
        """module A exposing (v)
import Lib.Button
v = Lib.Button.view [ ... ] [ ... ]
"""
            |> Review.Test.run (rule libFacts)
            |> Review.Test.expectNoErrors
```

## 3. False-positive bait

The unresolvable case — a dynamic list, a `let`-bound value, a helper return, or
`List.map` output — must produce `expectNoErrors`. This proves the advisory
posture: the rule stays silent on what it can't resolve statically rather than
false-positiving.

```elm
test "silent on an unresolved (dynamically built) list" <|
    \() ->
        """module A exposing (v)
import Lib.Button
v = Lib.Button.view dynamicAttrs []
"""
            |> Review.Test.run (rule libFacts)
            |> Review.Test.expectNoErrors
```

## 4. Inverse / round-trip

For an autofix rule. MANDATORY for the barrel pair (`preferBarrel` ⟷
`preferComponentModules`): applying the fix and its inverse returns the original.
See `tests/RoundTripTest.elm` for the canonical shape. For a lone autofix, at
minimum assert the fixed source (via `Review.Test.expectErrors` with
`Review.Test.whenFixed`) and that re-running the rule on the fixed output finds
nothing (idempotence).

```elm
test "fix is idempotent (re-running finds nothing)" <|
    \() ->
        fixedSource
            |> Review.Test.run (rule libFacts)
            |> Review.Test.expectNoErrors
```

## Fixture-defaulting note

Any change to `Cem.Facts.Fact` (a new field) must be defaulted across EVERY
hand-built fixture in `tests/` — the existing fixtures set every field
explicitly, so a new field is a compile error until it's added everywhere. This
is the mechanical cost of the versioned facts contract; budget for touching all
fixtures whenever you widen `Fact`.
