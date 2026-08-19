module RoundTripTest exposing (all)

{-| Rule-local proof that `PreferBarrel` (per-component → barrel) and
`PreferComponentModules` (barrel → per-component) are inverses.

`Review.Test` validates each error's `whenFixed` against the ORIGINAL source in
isolation, so a full apply-all-fixes round trip over a multi-class example can't
be asserted here — that is the corpus harness's job (it applies every edit at
once and diffs). What IS provable rule-locally:

  - **Clean identity round trips** for the constructor and variant-group classes,
    where a fixture triggers exactly one rewrite in each direction:
    `PreferBarrel A == B` and `PreferComponentModules B == A`.
  - **A documented asymmetry**: the slot class does NOT round-trip to the same
    name — barrelise generalises (`M3e.Button.icon` → `M3e.slotIcon`) while
    specialise re-specialises to the component-specific BARREL name
    (`M3e.slotIcon` → `M3e.buttonSlotIcon`). The endpoints coincide in TYPE
    (`buttonSlotIcon = M3e.Button.icon`, a literal re-export — same phantom row),
    but the intermediate generalised `slotIcon` has a DISTINCT, narrower phantom
    (the component-agnostic `M3e.Html.Vocab` type, e.g. `{ icon }` vs Button's
    `{ icon, loadingIndicator }`) — so barrelise is not phantom-preserving, only
    the full round trip is. Asserted so it stays intentional.

Fixtures import both `M3e` and `M3e.<Comp>` so neither rule needs to insert an
import; the round trip is then clean at the expression level, which is all the
corpus harness compares.

-}

import Cem.Facts as Facts exposing (Facet(..))
import Cem.PreferBarrel
import Cem.PreferComponentModules
import Review.Rule
import Review.Test
import Set
import Test exposing (Test, describe, test)


buttonFacts : List Facts.Fact
buttonFacts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "filled", "tonal" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "shapeAttr", "shape" ) ]
      , slotRewrites = [ ( "unnamed", "child" ), ( "icon", "icon" ) ]
      , slotKinds = []
      , slotUpgrades = [ ( "slotDefault", "buttonSlotDefault" ), ( "slotIcon", "buttonSlotIcon" ) ]
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


progressFacts : List Facts.Fact
progressFacts =
    [ { component = "progress"
      , module_ = "M3e.Progress"
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
      , groupConstructors = [ "circular", "linear" ]
      , usesAction = False
      }
    ]


{-| The details `PreferBarrel` attaches to every flatten, by kind.
-}
flattenDetails : String -> List String
flattenDetails kind =
    [ "The `M3e` barrel re-exports this "
        ++ kind
        ++ " so a single `import M3e` covers the whole example. The per-component facet stays available for callers who want the tighter type."
    ]


preferBarrel : List Facts.Fact -> Review.Rule.Rule
preferBarrel =
    Cem.PreferBarrel.ruleWith Set.empty


all : Test
all =
    describe "RoundTrip (PreferBarrel ∘ PreferComponentModules)"
        [ describe "constructor — clean identity round trip"
            [ test "PreferBarrel: M3e.Button.component [] [] -> M3e.button [] []" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [] []
"""
                        |> Review.Test.run (preferBarrel buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Button.component` can be flattened to the barrel constructor `M3e.button`"
                                , details = flattenDetails "constructor"
                                , under = "M3e.Button.component"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.button [] []
"""
                            ]
            , test "PreferComponentModules: M3e.button [] [] -> M3e.Button.component [] []" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.button [] []
"""
                        |> Review.Test.run (Cem.PreferComponentModules.rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "The barrel call can be replaced with the component-module `M3e.Button.component`"
                                , details = [ "The component-module constructor scopes this call's attrs and slots to button, so the compiler rejects another component's setters." ]
                                , under = "M3e.button"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [] []
"""
                            ]
            ]
        , describe "variant-group constructor — clean identity round trip"
            [ test "PreferBarrel: M3e.Progress.circular -> M3e.circular" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Progress
v = M3e.Progress.circular [] []
"""
                        |> Review.Test.run (preferBarrel progressFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Progress.circular` can be flattened to the barrel constructor `M3e.circular`"
                                , details = flattenDetails "constructor"
                                , under = "M3e.Progress.circular"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Progress
v = M3e.circular [] []
"""
                            ]
            , test "PreferComponentModules: M3e.circular -> M3e.Progress.circular" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Progress
v = M3e.circular [] []
"""
                        |> Review.Test.run (Cem.PreferComponentModules.rule progressFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "The barrel call can be replaced with the component-module `M3e.Progress.circular`"
                                , details = [ "The component-module constructor scopes this call's attrs and slots to progress, so the compiler rejects another component's setters." ]
                                , under = "M3e.circular"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Progress
v = M3e.Progress.circular [] []
"""
                            ]
            ]
        , describe "slot class — DOCUMENTED asymmetry (not a round trip)"
            [ test "barrelise generalises: M3e.Button.icon -> M3e.slotIcon" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.button [] [ M3e.Button.icon someIcon ]
"""
                        |> Review.Test.run (preferBarrel buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Button.icon` can be flattened to the barrel slot setter `M3e.slotIcon`"
                                , details = flattenDetails "slot setter"
                                , under = "M3e.Button.icon"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.button [] [ M3e.slotIcon someIcon ]
"""
                            ]
            , test "specialise re-specialises to the BARREL specific name, not back to M3e.Button.icon" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [] [ M3e.slotIcon someIcon ]
"""
                        |> Review.Test.run (Cem.PreferComponentModules.rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.slotIcon` can be upgraded to the button component setter `M3e.buttonSlotIcon`"
                                , details = [ "Inside `M3e.button` the component setter constrains the slot body to the kinds this component actually accepts, catching mismatched content at compile time." ]
                                , under = "M3e.slotIcon"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [] [ M3e.buttonSlotIcon someIcon ]
"""
                            ]
            ]
        ]
