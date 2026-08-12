module RequireFabLabelTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.RequireFabLabel exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| The real `m3e-fab` fact shape (Standard + Record + Build facets, `label`
slot, required `unnamed` icon slot). Includes `icon` so the required icon child
resolves as a recognised component literal.
-}
fabFacts : List Facts.Fact
fabFacts =
    [ { component = "fab"
      , module_ = "M3e.Fab"
      , enums = [ ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = [ ( "extended", "extended" ), ( "variant", "variant" ), ( "onClick", "onClick" ) ]
      , slotRewrites = [ ( "close-icon", "closeIcon" ), ( "label", "label" ) ]
      , slotKinds = [ ( "unnamed", [ "shared:icon" ] ), ( "close-icon", [ "shared:icon" ] ), ( "label", [ "shared:text" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = True
      }
    , { component = "icon"
      , module_ = "M3e.Icon"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
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


expectedError : String -> Review.Test.ExpectedError
expectedError under =
    Review.Test.error
        { message = "FAB `fab` has no accessible name"
        , details =
            [ "This `fab` has no discoverable accessible name, so assistive technology cannot announce it. A FAB needs an accessible name — from its extended label or an `aria-label`."
            , "Provide one of: a `M3e.Fab.label [...]` slot child (the extended-FAB label), an `aria-label` on the FAB (e.g. `M3e.Aria.label \"...\"`), or an `id` on the FAB that a `<label for=\"...\">` associates with."
            ]
        , under = under
        }


all : Test
all =
    describe "RequireFabLabel"
        [ test "flags an icon-only FAB with no name" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import M3e.Icon
v = M3e.Fab.view [] [ M3e.Icon.view [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectErrors [ expectedError "M3e.Fab.view" ]
        , test "flags the barrel facet too" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.fab [] [ M3e.icon [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectErrors [ expectedError "M3e.fab" ]
        , test "flags an empty FAB (no name at all)" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
v = M3e.Fab.view [] []
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectErrors [ expectedError "M3e.Fab.view" ]
        , test "accepts a slot=label child (M3e.Fab.label)" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import M3e.Icon
v = M3e.Fab.view [] [ M3e.Fab.label [ M3e.Fab.text "Add" ], M3e.Icon.view [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts aria-label on the FAB (M3e.Aria.label)" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import M3e.Icon
import M3e.Aria
v = M3e.Fab.view [ M3e.Aria.label "Add" ] [ M3e.Icon.view [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts aria-labelledby via any *.Aria module" <|
            \() ->
                [ """module A exposing (v)
import M3e.Fab
import M3e.Icon
import TypedHtml.Aria
v = M3e.Fab.view [ TypedHtml.Aria.labelledby "lbl" ] [ M3e.Icon.view [] [] ]
"""
                , """module TypedHtml.Aria exposing (labelledby)
labelledby : String -> Int
labelledby _ = 0
"""
                ]
                    |> Review.Test.runOnModules (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts the flat barrel aria setter (M3e.ariaLabel)" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.fab [ M3e.ariaLabel "Add" ] [ M3e.icon [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts an id on the FAB (the <label for> proxy)" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import M3e.Icon
v = M3e.Fab.view [ M3e.Fab.id "add" ] [ M3e.Icon.view [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts the raw attribute escape hatch (aria-label)" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import M3e.Icon
import M3e.Html.Attr
v = M3e.Fab.view [ M3e.Html.Attr.attribute "aria-label" "Add" ] [ M3e.Icon.view [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when the content list is unresolved (helper)" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import Seam
v = M3e.Fab.view [] (Seam.fabBody cfg)
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when the FAB attrs list is unresolved" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import M3e.Icon
v = M3e.Fab.view dynAttrs [ M3e.Icon.view [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when a content child is an unrecognised native/helper wrapper" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import Html
v = M3e.Fab.view [] [ Html.div [] [] ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when a content child is a bare (helper-produced) reference" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
v = M3e.Fab.view [] [ someChild ]
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        , test "no-op on a non-fab component" <|
            \() ->
                """module A exposing (v)
import M3e.Card
v = M3e.Card.view [] []
"""
                    |> Review.Test.run
                        (rule [ { component = "card", module_ = "M3e.Card", enums = [], requiredSlots = [], multiSlots = [], attrRewrites = [], slotRewrites = [], slotKinds = [], slotUpgrades = [], facets = [ Standard ], requiredAttrs = [], actionMap = [], groupConstructors = [], usesAction = False } ])
                    |> Review.Test.expectNoErrors
        , test "resolves a let-bound content list via scope and flags" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import M3e.Icon
v =
    let
        content = [ M3e.Icon.view [] [] ]
    in
    M3e.Fab.view [] content
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectErrors [ expectedError "M3e.Fab.view" ]
        , test "does not analyse the Build/pipeline facet" <|
            \() ->
                """module A exposing (v)
import M3e.Fab
import M3e.Icon
v = M3e.Fab.build |> M3e.Fab.withIcon (M3e.Icon.view [] []) |> M3e.Fab.toElement
"""
                    |> Review.Test.run (rule fabFacts)
                    |> Review.Test.expectNoErrors
        ]
