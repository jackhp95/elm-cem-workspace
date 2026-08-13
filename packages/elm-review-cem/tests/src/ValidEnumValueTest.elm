module ValidEnumValueTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.ValidEnumValue exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| A tiny hand-written facts table: a Button whose `variant` accepts only filled/outlined.
-}
facts : List Facts.Fact
facts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "filled", "outlined" ] ) ]
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
    ]


shape4Facts : List Facts.Fact
shape4Facts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "filled", "outlined" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Record ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| Two libraries' facts concatenated, exactly as the dogfood apps do
(`M3e.Review.Facts.facts ++ TypedHtml.Review.Facts.facts`). Before per-namespace
grouping, `rootParts` took only the FIRST fact's namespace (`M3e`), so the
`Tui`-namespace fact here was silently ignored and its violations never flagged.
-}
multiFacts : List Facts.Fact
multiFacts =
    facts
        ++ [ { component = "chip"
             , module_ = "Tui.Chip"
             , enums = [ ( "size", [ "small", "large" ] ) ]
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
           ]


message : String
message =
    "`circular` is not a valid value for this component"


all : Test
all =
    describe "ValidEnumValue"
        [ test "flags a barrel enum setter given a token the component rejects" <|
            \() ->
                """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    button [ variant Value.circular ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details =
                                [ "This component's enum only accepts: filled, outlined."
                                , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                ]
                            , under = "Value.circular"
                            }
                        ]
        , test "accepts a token the component supports" <|
            \() ->
                """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    button [ variant Value.filled ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "ignores components with no facts" <|
            \() ->
                """module A exposing (v)

import M3e exposing (widget, variant)
import M3e.Token as Value

v =
    widget [ variant Value.circular ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "handles the component-module strict form (M3e.Button.view)" <|
            \() ->
                """module A exposing (v)

import M3e.Button as Button
import M3e.Token as Value

v =
    Button.view [ Button.variant Value.circular ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details =
                                [ "This component's enum only accepts: filled, outlined."
                                , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                ]
                            , under = "Value.circular"
                            }
                        ]
        , test "flags an invalid enum token at a Record call site" <|
            \() ->
                """module A exposing (v)

import M3e.Record.Button
import M3e.Token as Value

v =
    M3e.Record.Button.view {} [ M3e.Record.Button.variant Value.circular ] []
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details =
                                [ "This component's enum only accepts: filled, outlined."
                                , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                ]
                            , under = "Value.circular"
                            }
                        ]
        , test "accepts a valid enum token at a Record call site" <|
            \() ->
                """module A exposing (v)

import M3e.Record.Button
import M3e.Token as Value

v =
    M3e.Record.Button.view {} [ M3e.Record.Button.variant Value.filled ] []
"""
                    |> Review.Test.run (rule shape4Facts)
                    |> Review.Test.expectNoErrors
        , test "does not flag an enum-setter-shaped expression in the content list (#90)" <|
            \() ->
                -- `variant Value.circular` appearing in the CONTENT (last) arg is a
                -- child, not an attribute setter; only the attribute args are checked.
                """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    button [] [ variant Value.circular ]
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , test "does not flag a let-bound (non-inline) enum setter — documented false negative" <|
            \() ->
                -- The rule only recognizes an INLINE `<setter> <token>` application as a
                -- setter element. A let-bound setter appears in the attr list as a bare
                -- variable (`setInvalid`), which `tracedList` returns as-is without
                -- expanding it against scope, so `checkSetter` never matches and the
                -- invalid `circular` token slips through. This pins that boundary.
                """module A exposing (v)

import M3e exposing (button, variant)
import M3e.Token as Value

v =
    let
        setInvalid =
            variant Value.circular
    in
    button [ setInvalid ] []
"""
                    |> Review.Test.run (rule facts)
                    |> Review.Test.expectNoErrors
        , describe "per-namespace facts (concatenated libraries)"
            [ test "flags a bad enum in the SECOND library's namespace (previously ignored)" <|
                \() ->
                    """module A exposing (v)

import Tui exposing (chip, size)
import Tui.Token as Value

v =
    chip [ size Value.huge ] []
"""
                        |> Review.Test.run (rule multiFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = "`huge` is not a valid value for this component"
                                , details =
                                    [ "This component's enum only accepts: small, large."
                                    , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                    ]
                                , under = "Value.huge"
                                }
                            ]
            , test "flags bad enums in BOTH namespaces in one module" <|
                \() ->
                    """module A exposing (v, w)

import M3e exposing (button, variant)
import M3e.Token as M3eToken
import Tui exposing (chip, size)
import Tui.Token as TuiToken

v =
    button [ variant M3eToken.circular ] []

w =
    chip [ size TuiToken.huge ] []
"""
                        |> Review.Test.run (rule multiFacts)
                        |> Review.Test.expectErrors
                            [ Review.Test.error
                                { message = message
                                , details =
                                    [ "This component's enum only accepts: filled, outlined."
                                    , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                    ]
                                , under = "M3eToken.circular"
                                }
                            , Review.Test.error
                                { message = "`huge` is not a valid value for this component"
                                , details =
                                    [ "This component's enum only accepts: small, large."
                                    , "The loose top-layer vocabulary lets any token type-check; use one this component actually supports, or the component-module's strict setter (which rejects the wrong token at compile time)."
                                    ]
                                , under = "TuiToken.huge"
                                }
                            ]
            ]
        ]
