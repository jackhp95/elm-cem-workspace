module RequireFormFieldLabelTest exposing (all)

import Cem.Facts as Facts exposing (Facet(..))
import Cem.RequireFormFieldLabel exposing (rule)
import Review.Test
import Test exposing (Test, describe, test)


{-| The real `m3e-form-field` fact shape (Standard + Build facets, `label` slot,
multi default slot).
-}
formFieldFacts : List Facts.Fact
formFieldFacts =
    [ { component = "formField"
      , module_ = "M3e.FormField"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = [ ( "error", "error" ), ( "hint", "hint" ), ( "label", "label" ), ( "prefix", "prefix" ), ( "prefix-text", "prefixText" ), ( "suffix", "suffix" ), ( "suffix-text", "suffixText" ) ]
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "textField"
      , module_ = "M3e.TextField"
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
        { message = "Form field `formField` wraps a control with no accessible name"
        , details =
            [ "This `formField` contains a control, but nothing in this call gives that control an accessible name. A form control needs an accessible name so assistive technology can announce it."
            , "Provide one of: a `M3e.FormField.label [...]` slot child, an `aria-label` on the control (e.g. `M3e.Aria.label \"...\"`), or an `id` on the control that a `<label for=\"...\">` associates with."
            ]
        , under = under
        }


all : Test
all =
    describe "RequireFormFieldLabel"
        [ test "flags a form-field whose only control has no name" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
v = M3e.FormField.view [] [ M3e.TextField.view [] [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectErrors [ expectedError "M3e.FormField.view" ]
        , test "flags the barrel facet too" <|
            \() ->
                """module A exposing (v)
import M3e
v = M3e.formField [] [ M3e.textField [] [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectErrors [ expectedError "M3e.formField" ]
        , test "accepts a slot=label child (M3e.FormField.label)" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
v = M3e.FormField.view [] [ M3e.FormField.label [ M3e.TextField.view [] [] ], M3e.TextField.view [] [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts aria-label on the control (M3e.Aria.label)" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
import M3e.Aria
v = M3e.FormField.view [] [ M3e.TextField.view [ M3e.Aria.label "Email" ] [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts aria-labelledby via any *.Aria module" <|
            \() ->
                [ """module A exposing (v)
import M3e.FormField
import M3e.TextField
import TypedHtml.Aria
v = M3e.FormField.view [] [ M3e.TextField.view [ TypedHtml.Aria.labelledby "lbl" ] [] ]
"""
                , """module TypedHtml.Aria exposing (labelledby)
labelledby : String -> Int
labelledby _ = 0
"""
                ]
                    |> Review.Test.runOnModules (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts an id on the control (the <label for> proxy)" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
v = M3e.FormField.view [] [ M3e.TextField.view [ M3e.TextField.id "email" ] [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts the raw attribute escape hatch (aria-label)" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
import M3e.Html.Attr
v = M3e.FormField.view [] [ M3e.TextField.view [ M3e.Html.Attr.attribute "aria-label" "Email" ] [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "accepts aria-label on the form-field host itself" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
import M3e.Aria
v = M3e.FormField.view [ M3e.Aria.label "Email" ] [ M3e.TextField.view [] [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "unwraps the default-slot setter (M3e.FormField.child) and still flags" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
v = M3e.FormField.view [] [ M3e.FormField.child (M3e.TextField.view [] []) ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectErrors [ expectedError "M3e.FormField.view" ]
        , test "unwraps M3e.FormField.child and accepts an aria-labelled control" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
import M3e.Aria
v = M3e.FormField.view [] [ M3e.FormField.child (M3e.TextField.view [ M3e.Aria.label "Email" ] []) ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when the content list is unresolved (Seam.field helper)" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import Seam
v = M3e.FormField.view [] (Seam.field "email" cfg)
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when the form-field attrs list is unresolved" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
v = M3e.FormField.view dynAttrs [ M3e.TextField.view [] [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when the control is wrapped in an unrecognised native/helper child" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
import Html
v = M3e.FormField.view [] [ Html.div [] [ M3e.TextField.view [] [] ] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "silent when a default-slot child's attrs are unresolved" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
v = M3e.FormField.view [] [ M3e.TextField.view dynAttrs [] ]
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "silent on an empty form-field (no control to name)" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
v = M3e.FormField.view [] []
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        , test "no-op on a non-form-field component" <|
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
import M3e.FormField
import M3e.TextField
v =
    let
        content = [ M3e.TextField.view [] [] ]
    in
    M3e.FormField.view [] content
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectErrors [ expectedError "M3e.FormField.view" ]
        , test "does not analyse the Build/pipeline facet" <|
            \() ->
                """module A exposing (v)
import M3e.FormField
import M3e.TextField
v = M3e.FormField.build |> M3e.FormField.withChild (M3e.TextField.view [] []) |> M3e.FormField.toElement
"""
                    |> Review.Test.run (rule formFieldFacts)
                    |> Review.Test.expectNoErrors
        ]
