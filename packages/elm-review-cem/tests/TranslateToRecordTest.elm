module TranslateToRecordTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.TranslateToRecord exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| `button` — required unnamed slot (`content`) and an action record
(`usesAction`), matching elm-m3e's `M3e.Button`.
-}
buttonFacts : List Facts.Fact
buttonFacts =
    [ { component = "button"
      , module_ = "M3e.Button"
      , enums = [ ( "variant", [ "elevated", "filled", "tonal" ] ) ]
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "variant", "variant" ), ( "selected", "selected" ), ( "onClick", "onClick" ) ]
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


{-| `assistChip` — required unnamed slot but NO action record (`usesAction`
False), so an `onClick` stays a plain attr.
-}
assistChipFacts : List Facts.Fact
assistChipFacts =
    [ { component = "assistChip"
      , module_ = "M3e.AssistChip"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = [ ( "onClick", "onClick" ) ]
      , slotRewrites = [ ( "icon", "icon" ) ]
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record, Build ]
      , requiredAttrs = []
      , actionMap = [ ( "onClick", "onClick" ), ( "href", "link" ) ]
      , usesAction = False
      }
    ]


{-| `expansionPanel` — a NAMED required slot (`header`).
-}
expansionPanelFacts : List Facts.Fact
expansionPanelFacts =
    [ { component = "expansionPanel"
      , module_ = "M3e.ExpansionPanel"
      , enums = []
      , requiredSlots = [ "header" ]
      , multiSlots = [ "actions" ]
      , attrRewrites = [ ( "open", "open" ) ]
      , slotRewrites = [ ( "actions", "actions" ), ( "header", "header" ), ( "toggle-icon", "toggleIcon" ) ]
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


{-| `fab` — required `aria-label`, which has no Standard-surface source, so the
rule must skip it.
-}
fabFacts : List Facts.Fact
fabFacts =
    [ { component = "fab"
      , module_ = "M3e.Fab"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record, Build ]
      , requiredAttrs = [ "aria-label" ]
      , actionMap = [ ( "onClick", "onClick" ) ]
      , usesAction = True
      }
    ]


{-| `avatar` — a component with NO required record (no `Record` facet).
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
    "This Standard `view` call can be rewritten to the required-record (`el`) surface"


details : List String
details =
    [ "The generated component module exposes the same element on another surface; this opt-in transform rewrites the call in place, hoisting the required fields out of the attrs/children per the facts."
    ]


all : Test
all =
    describe "Cem.TranslateToRecord"
        [ test "hoists content + lifts onClick into an action field, adding import M3e.Action" <|
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
    M3e.Button.el { content = c, action = M3e.Action.onClick DoThing } [ M3e.Button.variant v ] [ M3e.Button.icon i ]
"""
                        ]
        , test "usesAction component with no action setter defaults action = M3e.Action.none" <|
            \() ->
                """module A exposing (view)

import M3e.Button

view =
    M3e.Button.view [] [ M3e.Button.child c ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "M3e.Button.view [] [ M3e.Button.child c ]"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (view)

import M3e.Button
import M3e.Action

view =
    M3e.Button.el { content = c, action = M3e.Action.none } [] []
"""
                        ]
        , test "a component without an action record keeps onClick as a plain attr, no action field" <|
            \() ->
                """module A exposing (Msg, view)

import M3e.AssistChip

type Msg
    = DoThing

view =
    M3e.AssistChip.view [ M3e.AssistChip.onClick DoThing ] [ M3e.AssistChip.child c ]
"""
                    |> Review.Test.run (rule assistChipFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "M3e.AssistChip.view [ M3e.AssistChip.onClick DoThing ] [ M3e.AssistChip.child c ]"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (Msg, view)

import M3e.AssistChip

type Msg
    = DoThing

view =
    M3e.AssistChip.el { content = c } [ M3e.AssistChip.onClick DoThing ] []
"""
                        ]
        , test "hoists a NAMED required slot (header) into its record field" <|
            \() ->
                """module A exposing (view)

import M3e.ExpansionPanel

view =
    M3e.ExpansionPanel.view [] [ M3e.ExpansionPanel.header h, body ]
"""
                    |> Review.Test.run (rule expansionPanelFacts)
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "M3e.ExpansionPanel.view [] [ M3e.ExpansionPanel.header h, body ]"
                            }
                            |> Review.Test.whenFixed
                                """module A exposing (view)

import M3e.ExpansionPanel

view =
    M3e.ExpansionPanel.el { header = h } [] [ body ]
"""
                        ]
        , test "IDEMPOTENCE: an el call is left untouched (single-pass fixpoint)" <|
            \() ->
                """module A exposing (Msg, view)

import M3e.Button
import M3e.Action

type Msg
    = DoThing

view =
    M3e.Button.el { content = c, action = M3e.Action.onClick DoThing } [ M3e.Button.variant v ] [ M3e.Button.icon i ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        , test "skips a component whose required record carries aria-label (unsourceable)" <|
            \() ->
                """module A exposing (view)

import M3e.Fab

view =
    M3e.Fab.view [] [ M3e.Fab.child icon ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "no-op for a component without a required record (no Record facet)" <|
            \() ->
                """module A exposing (view)

import M3e.Avatar

view =
    M3e.Avatar.view [] [ c ]
"""
                    |> Review.Test.run (rule avatarFacts)
                    |> Review.Test.expectNoErrors
        , test "no-op on a dynamic attr list (not statically resolvable)" <|
            \() ->
                """module A exposing (view)

import M3e.Button

view =
    M3e.Button.view (extra ++ [ M3e.Button.onClick DoThing ]) [ M3e.Button.child c ]
"""
                    |> Review.Test.run (rule buttonFacts)
                    |> Review.Test.expectNoErrors
        ]
