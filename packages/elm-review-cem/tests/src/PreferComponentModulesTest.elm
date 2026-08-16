module PreferComponentModulesTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.PreferComponentModules exposing (rule)
import RealFactsFixture
import Review.Test
import Test exposing (Test, describe, test)


buttonFacts : List Facts.Fact
buttonFacts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "variant", "variant" ), ( "shapeAttr", "shape" ) ]
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


{-| Button with an enum attribute, for the value-combined class:
`M3e.variantFilled` (barrel constant) → `M3e.Button.variant M3e.Token.filled`.
-}
enumFacts : List Facts.Fact
enumFacts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "filled", "outlined" ] ), ( "type_", [ "button", "submit" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "variant", "variant" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| A variant-group component (`progress`) whose members are flat barrel
constructors (`M3e.circular`) that specialise to `M3e.Progress.circular`.
-}
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


all : Test
all =
    describe "PreferComponentModules"
        [ describe "four-package shape (real generated facts, barrel-root resolution)"
            -- Runs against the VERBATIM `RealFactsFixture.facts` snapshot, whose
            -- every `module_` carries the `.Component.` intermediate segment. The
            -- rule builds its index via `Cem.Internal.Facts.buildIndex`, so a barrel
            -- call (`M3e.appBar`, resolved under the barrel root `["M3e"]`) finds the
            -- `M3e.Component.AppBar` fact through the barrel-alias key. Before the
            -- barrel-root fix this whole rule was INERT on this shape (it detected
            -- and replaced against `["M3e","Component"]`, which no barrel reference
            -- resolves to). These pins would all report NO errors on the buggy rule.
            [ test "rewrites a loose barrel producer M3e.appBar to M3e.Component.AppBar.component (no-required-field component)" <|
                \() ->
                    """module A exposing (v)
import M3e
v = M3e.appBar [] []
"""
                        |> Review.Test.run (rule RealFactsFixture.facts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "The barrel call can be replaced with the component-module `M3e.Component.AppBar.component`"
                                , details =
                                    [ "The component-module constructor scopes this call's attrs and slots to appBar, so the compiler rejects another component's setters."
                                    ]
                                , under = "M3e.appBar"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Component.AppBar
v = M3e.Component.AppBar.component [] []
"""
                            ]
            , test "does NOT specialise a record-form barrel producer M3e.button (requiredSlots + usesAction)" <|
                -- The loose barrel producer `M3e.button` and the record-form
                -- `M3e.Component.Button.component` (`{ content, action } -> …`) are
                -- different functions; specialising one to the other is a type
                -- error, so the constructor case is skipped. Mirror of PreferBarrel.
                \() ->
                    """module A exposing (v)
import M3e
v = M3e.button [] []
"""
                        |> Review.Test.run (rule RealFactsFixture.facts)
                        |> Review.Test.expectNoErrors
            , test "specialises a barrel attr M3e.size inside a four-package per-component call" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Component.AppBar
v = M3e.Component.AppBar.component [ M3e.size s ] []
"""
                        |> Review.Test.run (rule RealFactsFixture.facts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`size` can be replaced with the component setter `M3e.Component.AppBar.size`"
                                , details =
                                    [ "The barrel-level setter accepts every component's tokens; the component setter only accepts appBar's."
                                    ]
                                , under = "M3e.size"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Component.AppBar
v = M3e.Component.AppBar.component [ M3e.Component.AppBar.size s ] []
"""
                            ]
            , test "targets the BARREL-ROOT aria module M3e.Aria (not M3e.Component.Aria)" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Component.AppBar
v = M3e.Component.AppBar.component [ M3e.ariaLabel "Menu" ] []
"""
                        |> Review.Test.run (rule RealFactsFixture.facts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`ariaLabel` can be replaced with the universal setter `M3e.Aria.label`"
                                , details =
                                    [ "`M3e.Aria` is the canonical home for the accessible-name setters; the barrel `ariaLabel` is a flat re-export of it." ]
                                , under = "M3e.ariaLabel"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Component.AppBar
import M3e.Aria
v = M3e.Component.AppBar.component [ M3e.Aria.label "Menu" ] []
"""
                            ]
            , test "targets the BARREL-ROOT token module M3e.Token when un-folding a combined constant" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Component.AppBar
v = M3e.Component.AppBar.component [ M3e.sizeLarge ] []
"""
                        |> Review.Test.run (rule RealFactsFixture.facts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`sizeLarge` can be replaced with the component-module `M3e.Component.AppBar.size M3e.Token.large`"
                                , details =
                                    [ "The barrel constant folds the setter and its token into one; the component setter names the appBar setter and the token separately, so only this component's tokens typecheck."
                                    ]
                                , under = "M3e.sizeLarge"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Component.AppBar
import M3e.Token
v = M3e.Component.AppBar.component [ M3e.Component.AppBar.size M3e.Token.large ] []
"""
                            ]
            ]
        , describe "attr case"
            [ test "rewrites M3e.variant to M3e.Button.variant" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.variant filled ] []
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`variant` can be replaced with the component setter `M3e.Button.variant`"
                                , details =
                                    [ "The barrel-level setter accepts every component's tokens; the component setter only accepts button's."
                                    ]
                                , under = "M3e.variant"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.Button.variant filled ] []
"""
                            ]
            , test "rewrites shape-collision-suffixed name" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.shapeAttr rounded ] []
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`shapeAttr` can be replaced with the component setter `M3e.Button.shape`"
                                , details =
                                    [ "The barrel-level setter accepts every component's tokens; the component setter only accepts button's."
                                    ]
                                , under = "M3e.shapeAttr"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.Button.shape rounded ] []
"""
                            ]
            ]
        , describe "slot case"
            [ test "rewrites M3e.Content.slot to per-component setter" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
import M3e.Content
v = M3e.Button.component [] [ M3e.Content.slot "icon" someIcon ]
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`.slot \"icon\"` can be replaced with the typed setter `M3e.Button.icon`"
                                , details =
                                    [ "The typed setter enforces the slot's kinds at compile time."
                                    ]
                                , under = "M3e.Content.slot \"icon\" someIcon"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Button
import M3e.Content
v = M3e.Button.component [] [ M3e.Button.icon (someIcon) ]
"""
                            ]
            , test "wraps multi-arg application body in parens" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
import M3e.Content
import M3e.Icon
v = M3e.Button.component [] [ M3e.Content.slot "icon" (M3e.Icon.component [] []) ]
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`.slot \"icon\"` can be replaced with the typed setter `M3e.Button.icon`"
                                , details =
                                    [ "The typed setter enforces the slot's kinds at compile time."
                                    ]
                                , under = "M3e.Content.slot \"icon\" (M3e.Icon.component [] [])"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e.Button
import M3e.Content
import M3e.Icon
v = M3e.Button.component [] [ M3e.Button.icon ((M3e.Icon.component [] [])) ]
"""
                            ]
            ]
        , describe "slot upgrade case (generalized barrel slot -> specific)"
            [ test "upgrades M3e.slotIcon to M3e.buttonSlotIcon inside a per-component call" <|
                -- Uses M3e.Button.component (already specific) so this stays focused on
                -- the slot-upgrade class without also triggering a constructor rewrite.
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [] [ M3e.slotIcon theIcon ]
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`M3e.slotIcon` can be upgraded to the button component setter `M3e.buttonSlotIcon`"
                                , details =
                                    [ "Inside `M3e.button` the component setter constrains the slot body to the kinds this component actually accepts, catching mismatched content at compile time."
                                    ]
                                , under = "M3e.slotIcon"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [] [ M3e.buttonSlotIcon theIcon ]
"""
                            ]
            , test "leaves M3e.slotIcon alone outside any known call site" <|
                \() ->
                    """module A exposing (v)
import M3e
v = M3e.slotIcon theIcon
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectNoErrors
            ]
        , test "rewrites barrel attr in Record call" <|
            \() ->
                """module A exposing (v)
import M3e
import M3e.Button
import M3e.Record.Button
v = M3e.Record.Button.component {} [ M3e.variant filled ] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`variant` can be replaced with the component setter `M3e.Button.variant`"
                            , details =
                                [ "The barrel-level setter accepts every component's tokens; the component setter only accepts button's."
                                ]
                            , under = "M3e.variant"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (v)
import M3e
import M3e.Button
import M3e.Record.Button
v = M3e.Record.Button.component {} [ M3e.Button.variant filled ] []
"""
                        ]
        , test "inserts missing import M3e.Button when only M3e is imported" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.Button.component [ M3e.variant filled ] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`variant` can be replaced with the component setter `M3e.Button.variant`"
                            , details =
                                [ "The barrel-level setter accepts every component's tokens; the component setter only accepts button's."
                                ]
                            , under = "M3e.variant"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.Button.variant filled ] []
"""
                        ]
        , describe "constructor case (barrel noun -> per-component view)"
            [ test "rewrites M3e.button to M3e.Button.component and inserts the import" <|
                \() ->
                    """module A exposing (v)
import M3e
v = M3e.button [] []
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "The barrel call can be replaced with the component-module `M3e.Button.component`"
                                , details =
                                    [ "The component-module constructor scopes this call's attrs and slots to button, so the compiler rejects another component's setters."
                                    ]
                                , under = "M3e.button"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [] []
"""
                            ]
            , test "leaves an already-specific M3e.Button.component alone" <|
                \() ->
                    """module A exposing (v)
import M3e.Button
v = M3e.Button.component [] []
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectNoErrors
            , test "rewrites a variant-group member M3e.circular to M3e.Progress.circular" <|
                \() ->
                    """module A exposing (v)
import M3e
v = M3e.circular [] []
"""
                        |> Review.Test.run (rule progressFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "The barrel call can be replaced with the component-module `M3e.Progress.circular`"
                                , details =
                                    [ "The component-module constructor scopes this call's attrs and slots to progress, so the compiler rejects another component's setters."
                                    ]
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
        , describe "aria case (barrel ariaX -> M3e.Aria.x)"
            [ test "rewrites M3e.ariaLabel to M3e.Aria.label and inserts the import" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.ariaLabel "Save" ] []
"""
                        |> Review.Test.run (rule buttonFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`ariaLabel` can be replaced with the universal setter `M3e.Aria.label`"
                                , details =
                                    [ "`M3e.Aria` is the canonical home for the accessible-name setters; the barrel `ariaLabel` is a flat re-export of it." ]
                                , under = "M3e.ariaLabel"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
import M3e.Aria
v = M3e.Button.component [ M3e.Aria.label "Save" ] []
"""
                            ]
            ]
        , describe "value combined case (barrel constant -> per-component enum + Value)"
            [ test "un-folds M3e.variantFilled to M3e.Button.variant M3e.Token.filled" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.variantFilled ] []
"""
                        |> Review.Test.run (rule enumFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`variantFilled` can be replaced with the component-module `M3e.Button.variant M3e.Token.filled`"
                                , details =
                                    [ "The barrel constant folds the setter and its token into one; the component setter names the button setter and the token separately, so only this component's tokens typecheck."
                                    ]
                                , under = "M3e.variantFilled"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
import M3e.Token
v = M3e.Button.component [ M3e.Button.variant M3e.Token.filled ] []
"""
                            ]
            , test "un-folds a keyword-attr combined (typeButton -> type_ M3e.Token.button)" <|
                \() ->
                    """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.typeButton ] []
"""
                        |> Review.Test.run (rule enumFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`typeButton` can be replaced with the component-module `M3e.Button.type_ M3e.Token.button`"
                                , details =
                                    [ "The barrel constant folds the setter and its token into one; the component setter names the button setter and the token separately, so only this component's tokens typecheck."
                                    ]
                                , under = "M3e.typeButton"
                                }
                                |> Review.Test.whenFixed
                                    """module A exposing (v)
import M3e
import M3e.Button
import M3e.Token
v = M3e.Button.component [ M3e.Button.type_ M3e.Token.button ] []
"""
                            ]
            ]
        , test "no-op when already using per-component setter" <|
            \() ->
                """module A exposing (v)
import M3e
import M3e.Button
v = M3e.Button.component [ M3e.Button.variant filled ] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "flags barrel attr in let-bound attrs list" <|
            \() ->
                """module A exposing (v)
import M3e
import M3e.Button
v =
    let
        attrs = [ M3e.variant filled ]
    in
    M3e.Button.component attrs []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "`variant` can be replaced with the component setter `M3e.Button.variant`"
                            , details =
                                [ "The barrel-level setter accepts every component's tokens; the component setter only accepts button's."
                                ]
                            , under = "M3e.variant"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (v)
import M3e
import M3e.Button
v =
    let
        attrs = [ M3e.Button.variant filled ]
    in
    M3e.Button.component attrs []
"""
                        ]
        ]
