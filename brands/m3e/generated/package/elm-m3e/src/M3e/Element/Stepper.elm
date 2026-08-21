module M3e.Element.Stepper exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, PanelSlot, StepSlot, ChildAdmittedBy
    , HeaderPosition, headerPosition, LabelPosition, labelPosition, Orientation, orientation
    , linear, onChange, onBeforeinput, onInput
    , panel, step
    )

{-| The `m3e-stepper` component — strict per-component surface.

Provides a wizard-like workflow by dividing content into logical steps.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, PanelSlot, StepSlot, ChildAdmittedBy
@docs HeaderPosition, headerPosition, LabelPosition, labelPosition, Orientation, orientation
@docs linear, onChange, onBeforeinput, onInput
@docs panel, step


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
M3e.Element.Stepper.component [] [ M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your name" } [ M3e.Element.Step.for "step1" ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your address" } [ M3e.Element.Step.for "step2" ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Done" } [ M3e.Element.Step.for "step3" ] []), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step1" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "name" ] [ M3e.text "Name" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "name", TypedHtml.Unsafe.Attributes.customAttribute "id" "name", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step2" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "address" ] [ M3e.text "Address" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "address", TypedHtml.Unsafe.Attributes.customAttribute "id" "address", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step3" ] [ M3e.text "Done", M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperReset.component [] [ M3e.text "Reset" ], action = M3e.Action.none } [] [] ]) ]) ]
```

<!-- elm-cem:example title="Orientation" -->
```elm
M3e.Element.Stepper.component [ M3e.Element.Stepper.orientation M3e.Values.vertical ] [ M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your name" } [ M3e.Element.Step.for "step4" ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your address" } [ M3e.Element.Step.for "step5" ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Done" } [ M3e.Element.Step.for "step6" ] []), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step4" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "name2" ] [ M3e.text "Name" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "name2", TypedHtml.Unsafe.Attributes.customAttribute "id" "name2", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step5" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "address2" ] [ M3e.text "Address" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "address2", TypedHtml.Unsafe.Attributes.customAttribute "id" "address2", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step6" ] [ M3e.text "Done", M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperReset.component [] [ M3e.text "Reset" ], action = M3e.Action.none } [] [] ]) ]) ]
```

<!-- elm-cem:example title="Header positions" -->
```elm
M3e.Element.Stepper.component [ M3e.Element.Stepper.headerPosition M3e.Values.below ] [ M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your name" } [ M3e.Element.Step.for "step7" ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your address" } [ M3e.Element.Step.for "step8" ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Done" } [ M3e.Element.Step.for "step9" ] []), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step7" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "name3" ] [ M3e.text "Name" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "name3", TypedHtml.Unsafe.Attributes.customAttribute "id" "name3", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step8" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "address3" ] [ M3e.text "Address" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "address3", TypedHtml.Unsafe.Attributes.customAttribute "id" "address3", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step9" ] [ M3e.text "Done", M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperReset.component [] [ M3e.text "Reset" ], action = M3e.Action.none } [] [] ]) ]) ]
```

<!-- elm-cem:example title="Label positions" -->
```elm
M3e.Element.Stepper.component [ M3e.Element.Stepper.labelPosition M3e.Values.below ] [ M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your name" } [ M3e.Element.Step.for "step10" ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your address" } [ M3e.Element.Step.for "step11" ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Done" } [ M3e.Element.Step.for "step12" ] []), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step10" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "name4" ] [ M3e.text "Name" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "name4", TypedHtml.Unsafe.Attributes.customAttribute "id" "name4", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step11" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "address4" ] [ M3e.text "Address" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "address4", TypedHtml.Unsafe.Attributes.customAttribute "id" "address4", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step12" ] [ M3e.text "Done", M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperReset.component [] [ M3e.text "Reset" ], action = M3e.Action.none } [] [] ]) ]) ]
```

<!-- elm-cem:example title="Stepper buttons" -->
```elm
M3e.Element.StepPanel.component [] [ M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]
```

<!-- elm-cem:example title="Linear stepper" -->
```elm
M3e.Element.Stepper.component [ M3e.Element.Stepper.linear True ] [ M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your name" } [ M3e.Element.Step.for "step13", M3e.Element.Step.editable True ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Fill out your address" } [ M3e.Element.Step.for "step14", M3e.Element.Step.editable True ] []), M3e.Element.Stepper.step (M3e.Element.Step.component { content = M3e.text "Done" } [ M3e.Element.Step.for "step15" ] []), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step13" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "name5" ] [ M3e.text "Name" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "name5", TypedHtml.Unsafe.Attributes.customAttribute "id" "name5", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step14" ] [ TypedHtml.form [] [ M3e.Element.FormField.component [] [ M3e.Element.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "address5" ] [ M3e.text "Address" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "name" "address5", TypedHtml.Unsafe.Attributes.customAttribute "id" "address5", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ] ], M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperNext.component [] [ M3e.text "Next" ], action = M3e.Action.none } [] [] ]) ]), M3e.Element.Stepper.panel (M3e.Element.StepPanel.component [ M3e.Attributes.id "step15" ] [ M3e.text "Done", M3e.Element.StepPanel.actions (TypedHtml.div [] [ M3e.Element.Button.component { content = M3e.Element.StepperPrevious.component [] [ M3e.text "Back" ], action = M3e.Action.none } [] [], M3e.Element.Button.component { content = M3e.Element.StepperReset.component [] [ M3e.text "Reset" ], action = M3e.Action.none } [] [] ]) ]) ]
```

<!-- elm-cem:docmeta category=Navigation -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Stepper
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-stepper` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Stepper.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Stepper.Attrs


{-| The kinds the `panel` slot admits.
-}
type alias PanelSlot =
    M3e.Internal.Types.Stepper.PanelSlot


{-| The kinds the `step` slot admits.
-}
type alias StepSlot =
    M3e.Internal.Types.Stepper.StepSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Stepper.ChildAdmittedBy childAdm


{-| The `headerPosition` values valid on this component (compile-tight narrowing).
-}
type alias HeaderPosition =
    M3e.Internal.Types.Stepper.HeaderPosition


{-| The `labelPosition` values valid on this component (compile-tight narrowing).
-}
type alias LabelPosition =
    M3e.Internal.Types.Stepper.LabelPosition


{-| The `orientation` values valid on this component (compile-tight narrowing).
-}
type alias Orientation =
    M3e.Internal.Types.Stepper.Orientation


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Stepper.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Stepper.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.stepper


{-| The position of the step header, when oriented horizontally. (default: `"above"`)
-}
headerPosition : Value HeaderPosition -> Attr { c | headerPosition : Supported } msg
headerPosition value_ =
    Ir.attribute "header-position" (Val.toString value_)


{-| The position of the step labels, when oriented horizontally. (default: `"end"`)
-}
labelPosition : Value LabelPosition -> Attr { c | labelPosition : Supported } msg
labelPosition value_ =
    Ir.attribute "label-position" (Val.toString value_)


{-| The orientation of the stepper. (default: `"horizontal"`)
-}
orientation : Value Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (Val.toString value_)


{-| See `M3e.Attributes.linear`.
-}
linear : Bool -> Attr { c | linear : Supported } msg
linear =
    A.linear


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onBeforeinput`.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput =
    Ev.onBeforeinput


{-| See `M3e.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| Place an element into the named `panel` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
panel : Element PanelSlot admittedBy msg -> Element free freeAdmittedBy msg
panel element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "panel") (El.toNode element))


{-| Place an element into the named `step` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
step : Element StepSlot admittedBy msg -> Element free freeAdmittedBy msg
step element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "step") (El.toNode element))
