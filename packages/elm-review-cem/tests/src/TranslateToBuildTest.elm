module TranslateToBuildTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.TranslateToBuild exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| `button` — required unnamed slot + action record, and a `selected` name that
is BOTH an attr and a slot (so the slot setter takes the `Slot` suffix).
-}
buttonFacts : List Facts.Fact
buttonFacts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "elevated", "filled", "tonal" ] ) ]
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "variant", "variant" ), ( "selected", "selected" ), ( "type_", "type_" ), ( "onClick", "onClick" ) ]
      , slotRewrites = [ ( "icon", "icon" ), ( "selected", "selected" ) ]
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record, Build ]
      , requiredAttrs = []
      , actionMap = [ ( "onClick", "onClick" ), ( "href", "link" ) ]
      , usesAction = True
      }
    ]


{-| `avatar` — no required record, so `build` takes no argument.
-}
avatarFacts : List Facts.Fact
avatarFacts =
    [ { component = "avatar"
      , module_ = "M3e.Avatar"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


message : String
message =
    "This Standard `view` call can be rewritten to the builder pipeline (`build … |> toElement`) surface"


details : List String
details =
    [ "The generated component module exposes the same element on another surface; this opt-in transform rewrites the call in place, hoisting the required fields out of the attrs/children per the facts."
    ]


all : Test
all =
    describe "Cem.TranslateToBuild"
        [ test "seeds build with the required record, then withX pipes and toElement" <|
            \() ->
                """module A exposing (Msg, view)

import M3e.Button

type Msg
    = DoThing

view =
    M3e.Button.view [ M3e.Button.variant v, M3e.Button.onClick DoThing ] [ M3e.Button.child c, M3e.Button.icon i ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "M3e.Button.view [ M3e.Button.variant v, M3e.Button.onClick DoThing ] [ M3e.Button.child c, M3e.Button.icon i ]"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (Msg, view)

import M3e.Button
import M3e.Action

type Msg
    = DoThing

view =
    M3e.Button.build { content = c, action = M3e.Action.onClick DoThing } |> M3e.Button.withVariant v |> M3e.Button.withIcon i |> M3e.Button.toElement
"""
                        ]
        , test "the selected slot setter takes a Slot suffix (collides with the selected attr)" <|
            \() ->
                """module A exposing (view)

import M3e.Button

view =
    M3e.Button.view [ M3e.Button.selected True ] [ M3e.Button.child c, M3e.Button.selected s ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "M3e.Button.view [ M3e.Button.selected True ] [ M3e.Button.child c, M3e.Button.selected s ]"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (view)

import M3e.Button
import M3e.Action

view =
    M3e.Button.build { content = c, action = M3e.Action.none } |> M3e.Button.withSelected True |> M3e.Button.withSelectedSlot s |> M3e.Button.toElement
"""
                        ]
        , test "a component with no required record has an argument-less build" <|
            \() ->
                """module A exposing (view)

import M3e.Avatar

view =
    M3e.Avatar.view [] [ c ]
"""
                    |> Review.Test.run (rule avatarFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "M3e.Avatar.view [] [ c ]"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (view)

import M3e.Avatar

view =
    M3e.Avatar.build |> M3e.Avatar.withChild c |> M3e.Avatar.toElement
"""
                        ]
        , test "IDEMPOTENCE: a build pipeline is left untouched (single-pass fixpoint)" <|
            \() ->
                """module A exposing (Msg, view)

import M3e.Button
import M3e.Action

type Msg
    = DoThing

view =
    M3e.Button.build { content = c, action = M3e.Action.onClick DoThing } |> M3e.Button.withVariant v |> M3e.Button.withIcon i |> M3e.Button.toElement
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "no-op when a residual attr does not resolve to a per-component setter" <|
            \() ->
                """module A exposing (view)

import M3e.Button

view =
    M3e.Button.view [ someOtherAttr ] [ M3e.Button.child c ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        ]
