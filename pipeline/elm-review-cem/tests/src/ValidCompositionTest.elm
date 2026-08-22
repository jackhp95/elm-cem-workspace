module ValidCompositionTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.ValidComposition exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| A minimal fact for a component with a default (`unnamed`) content slot that
admits anything (empty `slotKinds` = unconstrained), so `ValidComposition` — which
does not itself constrain kinds, only relational structure — can walk arbitrary
nesting without `ValidSlotKind`-style rejection getting in the way. `noun` is the
component noun; the module is `H.<Capitalized>` under the `H` barrel root
(matching how the html brand is imported as `import H`).
-}
container : String -> Facts.Fact
container noun =
    { component = noun
    , module_ = "H." ++ capitalize noun
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


capitalize : String -> String
capitalize s =
    String.toUpper (String.left 1 s) ++ String.dropLeft 1 s


{-| The full html-shaped fixture: the interactive parents (button/a/label/summary),
some interactive controls (input/select), plain containers (div/span), a nested
label case, and the ARIA relational nouns (menu/menuItem, tabGroup/tab). All under
the `H` barrel root so `H.button [] [ … ]` resolves.
-}
htmlFacts : List Facts.Fact
htmlFacts =
    List.map container
        [ "button"
        , "a"
        , "label"
        , "summary"
        , "input"
        , "select"
        , "textarea"
        , "div"
        , "span"
        , "menu"
        , "menuItem"
        , "tabGroup"
        , "tab"
        ]


{-| SVG-shaped fixture: a non-rendered element (`defs`) and a rendered one (`g`),
plus a `role` attribute setter noun so `H.role "x"` resolves as an attribute. The
`role` setter is NOT a component (it lives in an attributes list), so it does not
need a fact — the rule scans attribute-setter HEAD NAMES syntactically.
-}
svgFacts : List Facts.Fact
svgFacts =
    List.map container [ "defs", "g", "rect" ]


all : Test
all =
    describe "ValidComposition"
        [ describe "(a) interactive-content-descendant, ARBITRARY DEPTH — HARD"
            [ test "passing: button with a non-interactive nested tree" <|
                \() ->
                    """module A exposing (v)
import H
v = H.button [] [ H.span [] [ H.div [] [] ] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectNoErrors
            , test "failing: button with an interactive `a` descendant three levels deep" <|
                \() ->
                    """module A exposing (v)
import H
v = H.button [] [ H.span [] [ H.div [] [ H.a [] [] ] ] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`a` is interactive content and may not be a descendant of `button`"
                                , details =
                                    [ "The `button` content model forbids any interactive-content descendant at any depth (WHATWG). `a` is interactive content."
                                    , "Move `a` out of `button`, or use a non-interactive element in its place."
                                    ]
                                , under = "H.a [] []"
                                }
                            ]
            , test "failing: `a` with an `a` descendant (no-self-descendant)" <|
                \() ->
                    """module A exposing (v)
import H
v = H.a [] [ H.span [] [ H.a [] [] ] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`a` is interactive content and may not be a descendant of `a`"
                                , details =
                                    [ "The `a` content model forbids any interactive-content descendant at any depth (WHATWG). `a` is interactive content."
                                    , "Move `a` out of `a`, or use a non-interactive element in its place."
                                    ]
                                , under = "H.a [] []"
                                }
                            ]
            ]
        , describe "(b) label single-labeled-control + no-nested-label — HARD"
            [ test "passing: label with exactly one labelable control" <|
                \() ->
                    """module A exposing (v)
import H
v = H.label [] [ H.span [] [], H.input [] [] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectNoErrors
            , test "failing: label with a nested label" <|
                \() ->
                    """module A exposing (v)
import H
v = H.label [] [ H.span [] [ H.label [] [] ] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`label` may not have a descendant `label`"
                                , details =
                                    [ "A `label`'s content model forbids any descendant `label` element (WHATWG)."
                                    , "Split the nested `label` out so each labeled control has its own label."
                                    ]
                                , under = "H.label [] []"
                                }
                            ]
            , test "failing: label with two labelable controls" <|
                \() ->
                    """module A exposing (v)
import H
v = H.label [] [ H.input [] [], H.select [] [] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`label` may contain at most one labelable control; `select` is an extra one"
                                , details =
                                    [ "A `label` may contain a labelable descendant only if it is the element's single labeled control (WHATWG). A second labelable descendant (`select`) has no defined association."
                                    , "Give each labelable control its own `label`."
                                    ]
                                , under = "H.select [] []"
                                }
                            ]
            ]
        , describe "(c) ARIA required-context — WARN"
            [ test "passing: tab inside its required tabGroup ancestor" <|
                \() ->
                    """module A exposing (v)
import H
v = H.tabGroup [] [ H.div [] [ H.tab [] [] ] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectNoErrors
            , test "failing: a bare tab with no tablist/tabGroup ancestor -> WARN" <|
                \() ->
                    """module A exposing (v)
import H
v = H.div [] [ H.tab [] [] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "warning: `tab` requires an ancestor of role one of `tablist`, `tabList`, `tabGroup`"
                                , details =
                                    [ "WAI-ARIA gives `tab` a required context role: it must be contained in one of `tablist`, `tabList`, `tabGroup`."
                                    , "Place `tab` inside its required container."
                                    , "This is an advisory (WARN posture): it is often a real bug but can be intentional composition (e.g. the child is owned from elsewhere via aria-owns). It does not, on its own, fail the strict content-model gate."
                                    ]
                                , under = "H.tab [] []"
                                }
                            ]
            , test "failing: a bare menuItem with no menu ancestor -> WARN, single report only" <|
                \() ->
                    """module A exposing (v)
import H
v = H.menuItem [] []
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "warning: `menuItem` requires an ancestor of role one of `menu`, `menubar`, `menuBar`, `group`"
                                , details =
                                    [ "WAI-ARIA gives `menuItem` a required context role: it must be contained in one of `menu`, `menubar`, `menuBar`, `group`."
                                    , "Place `menuItem` inside its required container."
                                    , "This is an advisory (WARN posture): it is often a real bug but can be intentional composition (e.g. the child is owned from elsewhere via aria-owns). It does not, on its own, fail the strict content-model gate."
                                    ]
                                , under = "H.menuItem [] []"
                                }
                            ]
            , test "passing: menuItem inside its menu (not double-reported by nested roots)" <|
                \() ->
                    """module A exposing (v)
import H
v = H.menu [] [ H.menuItem [] [], H.menuItem [] [] ]
"""
                        |> Review.Test.run (rule htmlFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "(d) SVG-AAM no-role-on-non-rendered-element overlay — WARN"
            [ test "passing: role on a rendered element (g) is fine" <|
                \() ->
                    """module A exposing (v)
import H
v = H.g [ H.role "group" ] []
"""
                        |> Review.Test.run (rule svgFacts)
                        |> Review.Test.expectNoErrors
            , test "failing: role on a non-rendered `defs` element -> WARN" <|
                \() ->
                    """module A exposing (v)
import H
v = H.defs [ H.role "group" ] []
"""
                        |> Review.Test.run (rule svgFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "warning: `role` on a non-rendered SVG element `defs` is not allowed"
                                , details =
                                    [ "SVG Accessibility API Mappings: `defs` creates no accessible object, so no role may be applied and `aria-roledescription` must not be exposed on it."
                                    , "Remove the role / aria-roledescription attribute from `defs`."
                                    , "This is an advisory (WARN posture): it is often a real bug but can be intentional composition (e.g. the child is owned from elsewhere via aria-owns). It does not, on its own, fail the strict content-model gate."
                                    ]
                                , under = "H.role \"group\""
                                }
                            ]
            ]
        ]
