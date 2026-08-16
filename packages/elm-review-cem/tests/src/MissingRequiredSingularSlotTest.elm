module MissingRequiredSingularSlotTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.MissingRequiredSingularSlot exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| Real-generated-shape fixtures (four-package `component` ctor): `module_` carries the
`Component` intermediate segment elm-m3e actually emits (`"M3e.Component.Button"`,
NOT the flat `"M3e.Button"` a synthetic fixture would use), and required-content
components carry the required content through their single `component` ctor, which takes a
required record as its leading argument. These are trimmed copies of the real
`M3e.Review.Facts` entries (elm-m3e four-package regen,
`src/M3e/Review/Facts.elm`) for `button`, `expansionPanel`, and `splitButton`.
-}
buttonFacts : List Facts.Fact
buttonFacts =
    [ { component = "button"
      , module_ = "M3e.Component.Button"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = [ ( "onClick", "onClick" ) ]
      , groupConstructors = []
      , usesAction = True
      }
    ]


{-| A component with a NAMED required-singular slot (`header`), whose record
field name is the plain camelCase of the slot (`header`), not a `slotRewrites`
content-list setter (which no longer exists for required slots at all).
-}
expansionPanelFacts : List Facts.Fact
expansionPanelFacts =
    [ { component = "expansionPanel"
      , module_ = "M3e.Component.ExpansionPanel"
      , enums = []
      , requiredSlots = [ "header" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


{-| A component with TWO named required-singular slots, whose raw (kebab-case)
slot names must camelize to their record field names (`"leading-button"` →
`leadingButton`), exercising the multi-field case.
-}
splitButtonFacts : List Facts.Fact
splitButtonFacts =
    [ { component = "splitButton"
      , module_ = "M3e.Component.SplitButton"
      , enums = []
      , requiredSlots = [ "leading-button", "trailing-button" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , groupConstructors = []
      , usesAction = False
      }
    ]


all : Test
all =
    describe "MissingRequiredSingularSlot"
        [ test "accepts a barrel el call whose record literal fills the default slot" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.button { content = a, action = act } [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "flags a barrel el call whose record literal omits the default slot's field" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.button { action = act } [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `button` requires content slot `unnamed` but the record argument doesn't set it"
                            , details =
                                [ "Add `content = <value>` to the record passed to `M3e.button` (the leading record of its `component` constructor), which enforces this at the type level."
                                ]
                            , under = "M3e.button"
                            }
                        ]
        , test "flags a barrel el call with an entirely empty record" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.button {} [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `button` requires content slot `unnamed` but the record argument doesn't set it"
                            , details =
                                [ "Add `content = <value>` to the record passed to `M3e.button` (the leading record of its `component` constructor), which enforces this at the type level."
                                ]
                            , under = "M3e.button"
                            }
                        ]
        , test "silent when the record argument is an unresolved (external/opaque) value" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.button someRecordFromElsewhere [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when the record argument is built by a function call" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.button (buildRecord a) [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "resolves a let-bound record literal filling the slot" <|
            \() ->
                """module A exposing (v)
import M3e
v =
    let
        record = { content = a, action = act }
    in
    M3e.button record [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "resolves a let-bound record literal missing the slot" <|
            \() ->
                """module A exposing (v)
import M3e
v =
    let
        record = { action = act }
    in
    M3e.button record [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `button` requires content slot `unnamed` but the record argument doesn't set it"
                            , details =
                                [ "Add `content = <value>` to the record passed to `M3e.button` (the leading record of its `component` constructor), which enforces this at the type level."
                                ]
                            , under = "M3e.button"
                            }
                        ]
        , test "scope reset: second declaration does not inherit let-bindings of first" <|
            \() ->
                """module A exposing (v1, v2)
import M3e
v1 =
    let
        record = { content = a, action = act }
    in
    M3e.button record [] []
v2 =
    let
        record = { action = act }
    in
    M3e.button record [] []
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `button` requires content slot `unnamed` but the record argument doesn't set it"
                            , details =
                                [ "Add `content = <value>` to the record passed to `M3e.button` (the leading record of its `component` constructor), which enforces this at the type level."
                                ]
                            , under = "M3e.button"
                            }
                            |> Review.Test.atExactly { start = { row = 12, column = 5 }, end = { row = 12, column = 15 } }
                        ]
        , test "named slot: accepts M3e.expansionPanel record literal filling `header`" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.expansionPanel { header = h } [] []
"""
                    |> Review.Test.run (rule expansionPanelFacts)
                    |> Review.Test.expectNoErrors
        , test "named slot: flags M3e.expansionPanel record literal missing `header`" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.expansionPanel {} [] []
"""
                    |> Review.Test.run (rule expansionPanelFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `expansionPanel` requires content slot `header` but the record argument doesn't set it"
                            , details =
                                [ "Add `header = <value>` to the record passed to `M3e.expansionPanel` (the leading record of its `component` constructor), which enforces this at the type level."
                                ]
                            , under = "M3e.expansionPanel"
                            }
                        ]
        , test "kebab-case slots: accepts both leading-button/trailing-button fields camelized" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.splitButton { leadingButton = lb, trailingButton = tb } [] []
"""
                    |> Review.Test.run (rule splitButtonFacts)
                    |> Review.Test.expectNoErrors
        , test "kebab-case slots: flags each missing field independently" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.splitButton { leadingButton = lb } [] []
"""
                    |> Review.Test.run (rule splitButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `splitButton` requires content slot `trailing-button` but the record argument doesn't set it"
                            , details =
                                [ "Add `trailingButton = <value>` to the record passed to `M3e.splitButton` (the leading record of its `component` constructor), which enforces this at the type level."
                                ]
                            , under = "M3e.splitButton"
                            }
                        ]
        , test "kebab-case slots: flags both fields missing on an entirely empty record" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.splitButton {} [] []
"""
                    |> Review.Test.run (rule splitButtonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = "Component `splitButton` requires content slot `leading-button` but the record argument doesn't set it"
                            , details =
                                [ "Add `leadingButton = <value>` to the record passed to `M3e.splitButton` (the leading record of its `component` constructor), which enforces this at the type level."
                                ]
                            , under = "M3e.splitButton"
                            }
                        , Review.Test.error
                            { message = "Component `splitButton` requires content slot `trailing-button` but the record argument doesn't set it"
                            , details =
                                [ "Add `trailingButton = <value>` to the record passed to `M3e.splitButton` (the leading record of its `component` constructor), which enforces this at the type level."
                                ]
                            , under = "M3e.splitButton"
                            }
                        ]
        , test "no requiredSlots at all: never flags (e.g. a bare-arity el component)" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.chip [] []
"""
                    |> Review.Test.run
                        (rule
                            [ { component = "chip"
                              , module_ = "M3e.Component.Chip"
                              , enums = []
                              , requiredSlots = []
                              , multiSlots = []
                              , attrRewrites = []
                              , slotRewrites = []
                              , slotKinds = []
                              , slotUpgrades = []
                              , facets = [ Standard, Build ]
                              , requiredAttrs = []
                              , actionMap = []
                              , groupConstructors = []
                              , usesAction = False
                              }
                            ]
                        )
                    |> Review.Test.expectNoErrors
        ]
