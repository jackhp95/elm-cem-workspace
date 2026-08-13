module PreferBarrelTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.PreferBarrel exposing (rule, ruleWith)
import Review.Test
import Set
import Test exposing (Test, describe, test)


buttonFacts : List Facts.Fact
buttonFacts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "elevated", "filled", "tonal" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "attrDisabled", "disabled" ), ( "shapeAttr", "shape" ), ( "onClick", "onClick" ) ]
      , slotRewrites = [ ( "unnamed", "child" ), ( "icon", "icon" ) ]
      , slotKinds = []
      , slotUpgrades = [ ( "slotDefault", "buttonSlotDefault" ), ( "slotIcon", "buttonSlotIcon" ) ]
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| A component (like `Slider`/`Datepicker`) whose `value`/`name` setters are
LEFT OUT of `attrRewrites`. With no explicit barrel mapping they stay on the
per-component facet — the bare barrel `value`/`name` is only correct for the
dominant type, so PreferBarrel never guesses it.
-}
sliderFacts : List Facts.Fact
sliderFacts =
    [ { component = "slider"
      , module_ = "M3e.Slider"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "attrDisabled", "disabled" ) ]
      , slotRewrites = [ ( "unnamed", "child" ) ]
      , slotKinds = []
      , slotUpgrades = [ ( "slotDefault", "sliderSlotDefault" ) ]
      , groupConstructors = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


{-| A component (like `SplitPane`) that DOES carry prefixed `attrValue`/`attrName`
in `attrRewrites` — the explicit, capability-correct barrel mapping. It barrelises
via `attrBarrelName`.
-}
splitPaneFacts : List Facts.Fact
splitPaneFacts =
    [ { component = "splitPane"
      , module_ = "M3e.SplitPane"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "attrValue", "value" ), ( "attrName", "name" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


{-| A VARIANT-GROUP module (like `Progress`) with member constructors
`circular`/`linear` and no `view`. C3 rewrites each member to its identical barrel
name.
-}
progressFacts : List Facts.Fact
progressFacts =
    [ { component = "progress"
      , module_ = "M3e.Progress"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "attrValue", "value" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = [ "circular", "linear" ]
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


{-| A component (like `FormField`) whose UNNAMED slot's per-component setter is
`control` (not `child`). C1: it still folds to the generalized `slotDefault` the
barrel exposes.
-}
formFieldFacts : List Facts.Fact
formFieldFacts =
    [ { component = "formField"
      , module_ = "M3e.FormField"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "control" ), ( "label", "label" ) ]
      , slotKinds = []
      , slotUpgrades = [ ( "slotDefault", "formFieldSlotDefault" ), ( "slotLabel", "formFieldSlotLabel" ) ]
      , groupConstructors = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


{-| A component (like `Shape`) whose ENUM attribute is named `name` — colliding
with the bare scalar `name` the barrel re-exposes. The enum setter has no flat
barrel form other than the static combined, so a DYNAMIC arg must be left
per-component; it must NOT be mis-rewritten to the scalar `M3e.name`.
-}
shapeFacts : List Facts.Fact
shapeFacts =
    [ { component = "shape"
      , module_ = "M3e.Shape"
      , enums = [ ( "name", [ "value4LeafClover", "value4SidedCookie" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = [ ( "unnamed", "child" ) ]
      , slotKinds = []
      , slotUpgrades = [ ( "slotDefault", "shapeSlotDefault" ) ]
      , groupConstructors = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


all : Test
all =
    describe "PreferBarrel"
        [ describe "constructor class"
            [ test "rewrites M3e.Button.view to M3e.button" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
v = M3e.Button.view [] []
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Button.view` can be flattened to the barrel constructor `M3e.button`"
                                , details = detailsFor "constructor"
                                , under = "M3e.Button.view"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Button
import M3e
v = M3e.button [] []
"""
                            ]
            ]
        , describe "scalar attribute class"
            [ test "rewrites a scalar per-component setter to its `attr`-prefixed barrel name" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
v = M3e.Button.disabled True
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Button.disabled` can be flattened to the barrel attribute setter `M3e.attrDisabled`"
                                , details = detailsFor "attribute setter"
                                , under = "M3e.Button.disabled"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Button
import M3e
v = M3e.attrDisabled True
"""
                            ]
            , test "rewrites collision-suffixed barrel name (shape -> shapeAttr)" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
v = M3e.Button.shape rounded
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Button.shape` can be flattened to the barrel attribute setter `M3e.shapeAttr`"
                                , details = detailsFor "attribute setter"
                                , under = "M3e.Button.shape"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Button
import M3e
v = M3e.shapeAttr rounded
"""
                            ]
            ]
        , describe "enum value class (combined collapse)"
            [ test "collapses `M3e.<Comp>.<enumAttr> M3e.Token.<lit>` to the `M3e.<attr><Value>` combined" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
import M3e.Token
v = M3e.Button.variant M3e.Token.filled
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Button.variant M3e.Token.filled` can be flattened to the barrel enum value `M3e.variantFilled`"
                                , details = detailsFor "enum value"
                                , under = "M3e.Button.variant M3e.Token.filled"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Button
import M3e.Token
import M3e
v = M3e.variantFilled
"""
                            ]
            , test "leaves a DYNAMIC enum arg per-component (no static value to fold)" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
v = M3e.Button.variant chosen
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectNoErrors
            , test "leaves an enum applied to a NON-listed token per-component" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
import M3e.Token
v = M3e.Button.variant M3e.Token.bogus
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "slot class"
            [ test "rewrites per-component slot setter to generalized barrel slot" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
v = M3e.Button.child body
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Button.child` can be flattened to the barrel slot setter `M3e.slotDefault`"
                                , details = detailsFor "slot setter"
                                , under = "M3e.Button.child"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Button
import M3e
v = M3e.slotDefault body
"""
                            ]
            , test "generalized slot name matches the barrel CONTRACT — FormField `.control` (unnamed slot) folds to `M3e.slotDefault`" <|
                \() ->
                    """module A exposing (v)
import M3e.FormField
v = M3e.FormField.control field
"""
                        |> Review.Test.run (rule formFieldFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.FormField.control` can be flattened to the barrel slot setter `M3e.slotDefault`"
                                , details = detailsFor "slot setter"
                                , under = "M3e.FormField.control"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.FormField
import M3e
v = M3e.slotDefault field
"""
                            ]
            ]
        , describe "scalar value/name (multi-type: barrelised only via an explicit attrRewrites entry)"
            [ test "leaves `.value` per-component when it has NO attrRewrites entry (a bare `M3e.value` would be the wrong type)" <|
                \() ->
                    """module A exposing (v)
import M3e.Slider
v = M3e.Slider.value 5
"""
                        |> Review.Test.run (rule sliderFacts)
                        |> Review.Test.expectNoErrors
            , test "leaves `.name` per-component when it has NO attrRewrites entry" <|
                \() ->
                    """module A exposing (v)
import M3e.Slider
v = M3e.Slider.name "vol"
"""
                        |> Review.Test.run (rule sliderFacts)
                        |> Review.Test.expectNoErrors
            , test "a component carrying the capability-correct barrel name in `attrRewrites` (`attrValue`) barrelises to it" <|
                \() ->
                    """module A exposing (v)
import M3e.SplitPane
v = M3e.SplitPane.value 5
"""
                        |> Review.Test.run (rule splitPaneFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.SplitPane.value` can be flattened to the barrel attribute setter `M3e.attrValue`"
                                , details = detailsFor "attribute setter"
                                , under = "M3e.SplitPane.value"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.SplitPane
import M3e
v = M3e.attrValue 5
"""
                            ]
            ]
        , describe "variant-group constructor class (C3)"
            [ test "rewrites `M3e.Progress.circular` group constructor to `M3e.circular`" <|
                \() ->
                    """module A exposing (v)
import M3e.Progress
v = M3e.Progress.circular [] []
"""
                        |> Review.Test.run (rule progressFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Progress.circular` can be flattened to the barrel constructor `M3e.circular`"
                                , details = detailsFor "constructor"
                                , under = "M3e.Progress.circular"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Progress
import M3e
v = M3e.circular [] []
"""
                            ]
            , test "rewrites the sibling `M3e.Progress.linear` group constructor to `M3e.linear`" <|
                \() ->
                    """module A exposing (v)
import M3e.Progress
v = M3e.Progress.linear [] []
"""
                        |> Review.Test.run (rule progressFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Progress.linear` can be flattened to the barrel constructor `M3e.linear`"
                                , details = detailsFor "constructor"
                                , under = "M3e.Progress.linear"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Progress
import M3e
v = M3e.linear [] []
"""
                            ]
            ]
        , describe "value token class"
            [ test "rewrites re-exposed M3e.Token token to barrel token" <|
                \() ->
                    """module A exposing (v)
import M3e.Token
v = M3e.Token.rounded
"""
                        |> Review.Test.run (ruleWith (Set.singleton "rounded") buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Token.rounded` can be flattened to the barrel value token `M3e.rounded`"
                                , details = detailsFor "value token"
                                , under = "M3e.Token.rounded"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Token
import M3e
v = M3e.rounded
"""
                            ]
            , test "leaves non-re-exposed M3e.Token token alone (default rule)" <|
                \() ->
                    """module A exposing (v)
import M3e.Token
v = M3e.Token.elevated
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "universal aria class"
            [ test "rewrites a universal M3e.Aria setter to its flat `aria*` barrel name" <|
                \() ->
                    """module A exposing (v)
import M3e.Aria
v = M3e.Aria.label "Back"
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Aria.label` can be flattened to the barrel aria setter `M3e.ariaLabel`"
                                , details = detailsFor "aria setter"
                                , under = "M3e.Aria.label"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Aria
import M3e
v = M3e.ariaLabel "Back"
"""
                            ]
            ]
        , describe "scope discipline"
            [ test "never touches the Html / Record / Build facets" <|
                \() ->
                    """module A exposing (v)
import M3e.Html.Button
import M3e.Record.Button
import M3e.Build.Button
v =
    ( M3e.Html.Button.view [] []
    , M3e.Record.Button.view {} [] []
    , M3e.Build.Button.button
    )
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectNoErrors
            , test "no-op when already barrel-first" <|
                \() ->
                    """module A exposing (v)
import M3e
v = M3e.button [ M3e.variantFilled, M3e.attrDisabled True ] [ M3e.slotDefault body ]
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "event setter (identity-mapped attrRewrite)"
            [ test "leaves an event setter per-component (barrel form is a different, decoder-based function)" <|
                \() ->
                    -- Events are identity-mapped in `attrRewrites` (`onClick` ->
                    -- `onClick`) because the barrel re-exposes a GENERALIZED,
                    -- decoder-based `onClick : Decoder msg -> …`, not the
                    -- per-component msg-convenience `onClick : msg -> …`. They are
                    -- not type-interchangeable, so the rewrite must be skipped.
                    """module A exposing (v)
import M3e.Button
v = M3e.Button.onClick handler
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectNoErrors
            ]
        , describe "enum attr named `name`/`value` (scalar collision)"
            [ test "leaves an enum attr named `name` per-component on a DYNAMIC arg" <|
                \() ->
                    -- `M3e.Shape.name token` is an ENUM setter; the bare barrel
                    -- `M3e.name` is a DIFFERENT (scalar) setter, so rewriting to
                    -- it produces non-compiling code. Only the static combined
                    -- has a barrel form; a dynamic arg stays per-component.
                    """module A exposing (v)
import M3e.Shape
v = M3e.Shape.name token
"""
                        |> Review.Test.run (rule shapeFacts)
                        |> Review.Test.expectNoErrors
            , test "collapses an enum attr named `name` with a STATIC token to the combined" <|
                \() ->
                    """module A exposing (v)
import M3e.Shape
import M3e.Token
v = M3e.Shape.name M3e.Token.value4LeafClover
"""
                        |> Review.Test.run (rule shapeFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Shape.name M3e.Token.value4LeafClover` can be flattened to the barrel enum value `M3e.nameValue4LeafClover`"
                                , details = detailsFor "enum value"
                                , under = "M3e.Shape.name M3e.Token.value4LeafClover"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Shape
import M3e.Token
import M3e
v = M3e.nameValue4LeafClover
"""
                            ]
            ]
        , describe "barrel import insertion (soundness)"
            [ test "does NOT duplicate `import M3e` when the barrel is already imported" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.view [] []
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.Button.view` can be flattened to the barrel constructor `M3e.button`"
                                , details = detailsFor "constructor"
                                , under = "M3e.Button.view"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.button [] []
"""
                            ]
            ]
        ]


detailsFor : String -> List String
detailsFor kind =
    [ "The `M3e` barrel re-exports this "
        ++ kind
        ++ " so a single `import M3e` covers the whole example. The per-component facet stays available for callers who want the tighter type."
    ]
