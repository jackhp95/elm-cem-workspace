module M3e.Component.Stepper exposing (StepperIs, StepperAttrs, StepperBuilder, StepperAttrCaps, StepperSlotCaps, StepperPanelSlot, StepperStepSlot, StepperChildAdmittedBy, StepperHeaderPosition, StepperLabelPosition, StepperOrientation, StepIs, StepAttrs, StepBuilder, StepAttrCaps, StepSlotCaps, StepContent, StepDoneIconSlot, StepEditIconSlot, StepErrorSlot, StepErrorIconSlot, StepHintSlot, StepIconSlot, StepChildAdmittedBy, PanelIs, PanelAttrs, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelChildAdmittedBy, NextIs, NextAttrs, NextBuilder, NextAttrCaps, NextSlotCaps, NextChildAdmittedBy, PreviousIs, PreviousAttrs, PreviousBuilder, PreviousAttrCaps, PreviousSlotCaps, PreviousChildAdmittedBy, ResetIs, ResetAttrs, ResetBuilder, ResetAttrCaps, ResetSlotCaps, ResetChildAdmittedBy, stepper, stepperHeaderPosition, stepperLabelPosition, stepperOrientation, stepperLinear, stepperOnChange, stepperOnBeforeinput, stepperOnInput, stepperPanel, stepperStep, step, stepCompleted, stepDisabled, stepEditable, stepFor, stepInvalid, stepOptional, stepSelected, stepDefaultSelected, stepOnBeforeinput, stepOnInput, stepOnChange, stepOnClick, stepDoneIcon, stepEditIcon, stepError, stepErrorIcon, stepHint, stepIcon, stepChild, panel, panelActions, panelChild, next, previous, previousChild, reset, resetChild)

{-| The **Stepper** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Stepper`](M3e.Element.Stepper) as `stepper`, [`M3e.Element.Step`](M3e.Element.Step) as `step`, [`M3e.Element.StepPanel`](M3e.Element.StepPanel) as `panel`, [`M3e.Element.StepperNext`](M3e.Element.StepperNext) as `next`, [`M3e.Element.StepperPrevious`](M3e.Element.StepperPrevious) as `previous`, [`M3e.Element.StepperReset`](M3e.Element.StepperReset) as `reset`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs StepperIs, StepperAttrs, StepperBuilder, StepperAttrCaps, StepperSlotCaps, StepperPanelSlot, StepperStepSlot, StepperChildAdmittedBy, StepperHeaderPosition, StepperLabelPosition, StepperOrientation, StepIs, StepAttrs, StepBuilder, StepAttrCaps, StepSlotCaps, StepContent, StepDoneIconSlot, StepEditIconSlot, StepErrorSlot, StepErrorIconSlot, StepHintSlot, StepIconSlot, StepChildAdmittedBy, PanelIs, PanelAttrs, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelChildAdmittedBy, NextIs, NextAttrs, NextBuilder, NextAttrCaps, NextSlotCaps, NextChildAdmittedBy, PreviousIs, PreviousAttrs, PreviousBuilder, PreviousAttrCaps, PreviousSlotCaps, PreviousChildAdmittedBy, ResetIs, ResetAttrs, ResetBuilder, ResetAttrCaps, ResetSlotCaps, ResetChildAdmittedBy, stepper, stepperHeaderPosition, stepperLabelPosition, stepperOrientation, stepperLinear, stepperOnChange, stepperOnBeforeinput, stepperOnInput, stepperPanel, stepperStep, step, stepCompleted, stepDisabled, stepEditable, stepFor, stepInvalid, stepOptional, stepSelected, stepDefaultSelected, stepOnBeforeinput, stepOnInput, stepOnChange, stepOnClick, stepDoneIcon, stepEditIcon, stepError, stepErrorIcon, stepHint, stepIcon, stepChild, panel, panelActions, panelChild, next, previous, previousChild, reset, resetChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Step as Step_
import M3e.Element.StepPanel as Panel_
import M3e.Element.Stepper as Stepper_
import M3e.Element.StepperNext as Next_
import M3e.Element.StepperPrevious as Previous_
import M3e.Element.StepperReset as Reset_


{-| The `stepper` element of this family — delegates to [`M3e.Element.Stepper.component`](M3e.Element.Stepper#component).
-}
stepper :
    List (Attr StepperAttrs msg)
    -> List (Element childAccepts (StepperChildAdmittedBy childAdm) msg)
    -> Element (StepperIs s) admittedBy msg
stepper =
    Stepper_.component


{-| See [`M3e.Element.Stepper.Is`](M3e.Element.Stepper#Is).
-}
type alias StepperIs s =
    Stepper_.Is s


{-| See [`M3e.Element.Stepper.Attrs`](M3e.Element.Stepper#Attrs).
-}
type alias StepperAttrs =
    Stepper_.Attrs


{-| See [`M3e.Element.Stepper.Builder`](M3e.Element.Stepper#Builder).
-}
type alias StepperBuilder attrCaps slotCaps msg kind =
    Stepper_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Stepper.AttrCaps`](M3e.Element.Stepper#AttrCaps).
-}
type alias StepperAttrCaps =
    Stepper_.AttrCaps


{-| See [`M3e.Element.Stepper.SlotCaps`](M3e.Element.Stepper#SlotCaps).
-}
type alias StepperSlotCaps =
    Stepper_.SlotCaps


{-| See [`M3e.Element.Stepper.PanelSlot`](M3e.Element.Stepper#PanelSlot).
-}
type alias StepperPanelSlot =
    Stepper_.PanelSlot


{-| See [`M3e.Element.Stepper.StepSlot`](M3e.Element.Stepper#StepSlot).
-}
type alias StepperStepSlot =
    Stepper_.StepSlot


{-| See [`M3e.Element.Stepper.ChildAdmittedBy`](M3e.Element.Stepper#ChildAdmittedBy).
-}
type alias StepperChildAdmittedBy childAdm =
    Stepper_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Stepper.HeaderPosition`](M3e.Element.Stepper#HeaderPosition).
-}
type alias StepperHeaderPosition =
    Stepper_.HeaderPosition


{-| See [`M3e.Element.Stepper.headerPosition`](M3e.Element.Stepper#headerPosition).
-}
stepperHeaderPosition : Value StepperHeaderPosition -> Attr { c | headerPosition : Supported } msg
stepperHeaderPosition =
    Stepper_.headerPosition


{-| See [`M3e.Element.Stepper.LabelPosition`](M3e.Element.Stepper#LabelPosition).
-}
type alias StepperLabelPosition =
    Stepper_.LabelPosition


{-| See [`M3e.Element.Stepper.labelPosition`](M3e.Element.Stepper#labelPosition).
-}
stepperLabelPosition : Value StepperLabelPosition -> Attr { c | labelPosition : Supported } msg
stepperLabelPosition =
    Stepper_.labelPosition


{-| See [`M3e.Element.Stepper.Orientation`](M3e.Element.Stepper#Orientation).
-}
type alias StepperOrientation =
    Stepper_.Orientation


{-| See [`M3e.Element.Stepper.orientation`](M3e.Element.Stepper#orientation).
-}
stepperOrientation : Value StepperOrientation -> Attr { c | orientation : Supported } msg
stepperOrientation =
    Stepper_.orientation


{-| See [`M3e.Element.Stepper.linear`](M3e.Element.Stepper#linear).
-}
stepperLinear : Bool -> Attr { c | linear : Supported } msg
stepperLinear =
    Stepper_.linear


{-| See [`M3e.Element.Stepper.onChange`](M3e.Element.Stepper#onChange).
-}
stepperOnChange : msg -> Attr { c | onChange : Supported } msg
stepperOnChange =
    Stepper_.onChange


{-| See [`M3e.Element.Stepper.onBeforeinput`](M3e.Element.Stepper#onBeforeinput).
-}
stepperOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
stepperOnBeforeinput =
    Stepper_.onBeforeinput


{-| See [`M3e.Element.Stepper.onInput`](M3e.Element.Stepper#onInput).
-}
stepperOnInput : msg -> Attr { c | onInput : Supported } msg
stepperOnInput =
    Stepper_.onInput


{-| See [`M3e.Element.Stepper.panel`](M3e.Element.Stepper#panel).
-}
stepperPanel : Element StepperPanelSlot admittedBy msg -> Element free freeAdmittedBy msg
stepperPanel =
    Stepper_.panel


{-| See [`M3e.Element.Stepper.step`](M3e.Element.Stepper#step).
-}
stepperStep : Element StepperStepSlot admittedBy msg -> Element free freeAdmittedBy msg
stepperStep =
    Stepper_.step


{-| The `step` element of this family — delegates to [`M3e.Element.Step.component`](M3e.Element.Step#component).
-}
step :
    { content : Element StepContent (StepChildAdmittedBy childAdm) msg }
    -> List (Attr StepAttrs msg)
    -> List (Element StepContent (StepChildAdmittedBy childAdm) msg)
    -> Element (StepIs s) admittedBy msg
step =
    Step_.component


{-| See [`M3e.Element.Step.Is`](M3e.Element.Step#Is).
-}
type alias StepIs s =
    Step_.Is s


{-| See [`M3e.Element.Step.Attrs`](M3e.Element.Step#Attrs).
-}
type alias StepAttrs =
    Step_.Attrs


{-| See [`M3e.Element.Step.Builder`](M3e.Element.Step#Builder).
-}
type alias StepBuilder attrCaps slotCaps msg kind =
    Step_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Step.AttrCaps`](M3e.Element.Step#AttrCaps).
-}
type alias StepAttrCaps =
    Step_.AttrCaps


{-| See [`M3e.Element.Step.SlotCaps`](M3e.Element.Step#SlotCaps).
-}
type alias StepSlotCaps =
    Step_.SlotCaps


{-| See [`M3e.Element.Step.Content`](M3e.Element.Step#Content).
-}
type alias StepContent =
    Step_.Content


{-| See [`M3e.Element.Step.DoneIconSlot`](M3e.Element.Step#DoneIconSlot).
-}
type alias StepDoneIconSlot =
    Step_.DoneIconSlot


{-| See [`M3e.Element.Step.EditIconSlot`](M3e.Element.Step#EditIconSlot).
-}
type alias StepEditIconSlot =
    Step_.EditIconSlot


{-| See [`M3e.Element.Step.ErrorSlot`](M3e.Element.Step#ErrorSlot).
-}
type alias StepErrorSlot =
    Step_.ErrorSlot


{-| See [`M3e.Element.Step.ErrorIconSlot`](M3e.Element.Step#ErrorIconSlot).
-}
type alias StepErrorIconSlot =
    Step_.ErrorIconSlot


{-| See [`M3e.Element.Step.HintSlot`](M3e.Element.Step#HintSlot).
-}
type alias StepHintSlot =
    Step_.HintSlot


{-| See [`M3e.Element.Step.IconSlot`](M3e.Element.Step#IconSlot).
-}
type alias StepIconSlot =
    Step_.IconSlot


{-| See [`M3e.Element.Step.ChildAdmittedBy`](M3e.Element.Step#ChildAdmittedBy).
-}
type alias StepChildAdmittedBy childAdm =
    Step_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Step.completed`](M3e.Element.Step#completed).
-}
stepCompleted : Bool -> Attr { c | completed : Supported } msg
stepCompleted =
    Step_.completed


{-| See [`M3e.Element.Step.disabled`](M3e.Element.Step#disabled).
-}
stepDisabled : Bool -> Attr { c | disabled : Supported } msg
stepDisabled =
    Step_.disabled


{-| See [`M3e.Element.Step.editable`](M3e.Element.Step#editable).
-}
stepEditable : Bool -> Attr { c | editable : Supported } msg
stepEditable =
    Step_.editable


{-| See [`M3e.Element.Step.for`](M3e.Element.Step#for).
-}
stepFor : String -> Attr { c | for : Supported } msg
stepFor =
    Step_.for


{-| See [`M3e.Element.Step.invalid`](M3e.Element.Step#invalid).
-}
stepInvalid : Bool -> Attr { c | invalid : Supported } msg
stepInvalid =
    Step_.invalid


{-| See [`M3e.Element.Step.optional`](M3e.Element.Step#optional).
-}
stepOptional : Bool -> Attr { c | optional : Supported } msg
stepOptional =
    Step_.optional


{-| See [`M3e.Element.Step.selected`](M3e.Element.Step#selected).
-}
stepSelected : Bool -> Attr { c | selected : Supported } msg
stepSelected =
    Step_.selected


{-| See [`M3e.Element.Step.defaultSelected`](M3e.Element.Step#defaultSelected).
-}
stepDefaultSelected : Bool -> Attr { c | selected : Supported } msg
stepDefaultSelected =
    Step_.defaultSelected


{-| See [`M3e.Element.Step.onBeforeinput`](M3e.Element.Step#onBeforeinput).
-}
stepOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
stepOnBeforeinput =
    Step_.onBeforeinput


{-| See [`M3e.Element.Step.onInput`](M3e.Element.Step#onInput).
-}
stepOnInput : msg -> Attr { c | onInput : Supported } msg
stepOnInput =
    Step_.onInput


{-| See [`M3e.Element.Step.onChange`](M3e.Element.Step#onChange).
-}
stepOnChange : msg -> Attr { c | onChange : Supported } msg
stepOnChange =
    Step_.onChange


{-| See [`M3e.Element.Step.onClick`](M3e.Element.Step#onClick).
-}
stepOnClick : msg -> Attr { c | onClick : Supported } msg
stepOnClick =
    Step_.onClick


{-| See [`M3e.Element.Step.doneIcon`](M3e.Element.Step#doneIcon).
-}
stepDoneIcon : Element StepDoneIconSlot admittedBy msg -> Element free freeAdmittedBy msg
stepDoneIcon =
    Step_.doneIcon


{-| See [`M3e.Element.Step.editIcon`](M3e.Element.Step#editIcon).
-}
stepEditIcon : Element StepEditIconSlot admittedBy msg -> Element free freeAdmittedBy msg
stepEditIcon =
    Step_.editIcon


{-| See [`M3e.Element.Step.error`](M3e.Element.Step#error).
-}
stepError : Element StepErrorSlot admittedBy msg -> Element free freeAdmittedBy msg
stepError =
    Step_.error


{-| See [`M3e.Element.Step.errorIcon`](M3e.Element.Step#errorIcon).
-}
stepErrorIcon : Element StepErrorIconSlot admittedBy msg -> Element free freeAdmittedBy msg
stepErrorIcon =
    Step_.errorIcon


{-| See [`M3e.Element.Step.hint`](M3e.Element.Step#hint).
-}
stepHint : Element StepHintSlot admittedBy msg -> Element free freeAdmittedBy msg
stepHint =
    Step_.hint


{-| See [`M3e.Element.Step.icon`](M3e.Element.Step#icon).
-}
stepIcon : Element StepIconSlot admittedBy msg -> Element free freeAdmittedBy msg
stepIcon =
    Step_.icon


{-| See [`M3e.Element.Step.child`](M3e.Element.Step#child).
-}
stepChild : Element StepContent admittedBy msg -> Element free freeAdmittedBy msg
stepChild =
    Step_.child


{-| The `panel` element of this family — delegates to [`M3e.Element.StepPanel.component`](M3e.Element.StepPanel#component).
-}
panel :
    List (Attr PanelAttrs msg)
    -> List (Element childAccepts (PanelChildAdmittedBy childAdm) msg)
    -> Element (PanelIs s) admittedBy msg
panel =
    Panel_.component


{-| See [`M3e.Element.StepPanel.Is`](M3e.Element.StepPanel#Is).
-}
type alias PanelIs s =
    Panel_.Is s


{-| See [`M3e.Element.StepPanel.Attrs`](M3e.Element.StepPanel#Attrs).
-}
type alias PanelAttrs =
    Panel_.Attrs


{-| See [`M3e.Element.StepPanel.Builder`](M3e.Element.StepPanel#Builder).
-}
type alias PanelBuilder attrCaps slotCaps msg kind =
    Panel_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.StepPanel.AttrCaps`](M3e.Element.StepPanel#AttrCaps).
-}
type alias PanelAttrCaps =
    Panel_.AttrCaps


{-| See [`M3e.Element.StepPanel.SlotCaps`](M3e.Element.StepPanel#SlotCaps).
-}
type alias PanelSlotCaps =
    Panel_.SlotCaps


{-| See [`M3e.Element.StepPanel.ChildAdmittedBy`](M3e.Element.StepPanel#ChildAdmittedBy).
-}
type alias PanelChildAdmittedBy childAdm =
    Panel_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.StepPanel.actions`](M3e.Element.StepPanel#actions).
-}
panelActions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelActions =
    Panel_.actions


{-| See [`M3e.Element.StepPanel.child`](M3e.Element.StepPanel#child).
-}
panelChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelChild =
    Panel_.child


{-| The `next` element of this family — delegates to [`M3e.Element.StepperNext.component`](M3e.Element.StepperNext#component).
-}
next :
    List (Attr NextAttrs msg)
    -> List (Element childAccepts (NextChildAdmittedBy childAdm) msg)
    -> Element (NextIs s) admittedBy msg
next =
    Next_.component


{-| See [`M3e.Element.StepperNext.Is`](M3e.Element.StepperNext#Is).
-}
type alias NextIs s =
    Next_.Is s


{-| See [`M3e.Element.StepperNext.Attrs`](M3e.Element.StepperNext#Attrs).
-}
type alias NextAttrs =
    Next_.Attrs


{-| See [`M3e.Element.StepperNext.Builder`](M3e.Element.StepperNext#Builder).
-}
type alias NextBuilder attrCaps slotCaps msg kind =
    Next_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.StepperNext.AttrCaps`](M3e.Element.StepperNext#AttrCaps).
-}
type alias NextAttrCaps =
    Next_.AttrCaps


{-| See [`M3e.Element.StepperNext.SlotCaps`](M3e.Element.StepperNext#SlotCaps).
-}
type alias NextSlotCaps =
    Next_.SlotCaps


{-| See [`M3e.Element.StepperNext.ChildAdmittedBy`](M3e.Element.StepperNext#ChildAdmittedBy).
-}
type alias NextChildAdmittedBy childAdm =
    Next_.ChildAdmittedBy childAdm


{-| The `previous` element of this family — delegates to [`M3e.Element.StepperPrevious.component`](M3e.Element.StepperPrevious#component).
-}
previous :
    List (Attr PreviousAttrs msg)
    -> List (Element childAccepts (PreviousChildAdmittedBy childAdm) msg)
    -> Element (PreviousIs s) admittedBy msg
previous =
    Previous_.component


{-| See [`M3e.Element.StepperPrevious.Is`](M3e.Element.StepperPrevious#Is).
-}
type alias PreviousIs s =
    Previous_.Is s


{-| See [`M3e.Element.StepperPrevious.Attrs`](M3e.Element.StepperPrevious#Attrs).
-}
type alias PreviousAttrs =
    Previous_.Attrs


{-| See [`M3e.Element.StepperPrevious.Builder`](M3e.Element.StepperPrevious#Builder).
-}
type alias PreviousBuilder attrCaps slotCaps msg kind =
    Previous_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.StepperPrevious.AttrCaps`](M3e.Element.StepperPrevious#AttrCaps).
-}
type alias PreviousAttrCaps =
    Previous_.AttrCaps


{-| See [`M3e.Element.StepperPrevious.SlotCaps`](M3e.Element.StepperPrevious#SlotCaps).
-}
type alias PreviousSlotCaps =
    Previous_.SlotCaps


{-| See [`M3e.Element.StepperPrevious.ChildAdmittedBy`](M3e.Element.StepperPrevious#ChildAdmittedBy).
-}
type alias PreviousChildAdmittedBy childAdm =
    Previous_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.StepperPrevious.child`](M3e.Element.StepperPrevious#child).
-}
previousChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
previousChild =
    Previous_.child


{-| The `reset` element of this family — delegates to [`M3e.Element.StepperReset.component`](M3e.Element.StepperReset#component).
-}
reset :
    List (Attr ResetAttrs msg)
    -> List (Element childAccepts (ResetChildAdmittedBy childAdm) msg)
    -> Element (ResetIs s) admittedBy msg
reset =
    Reset_.component


{-| See [`M3e.Element.StepperReset.Is`](M3e.Element.StepperReset#Is).
-}
type alias ResetIs s =
    Reset_.Is s


{-| See [`M3e.Element.StepperReset.Attrs`](M3e.Element.StepperReset#Attrs).
-}
type alias ResetAttrs =
    Reset_.Attrs


{-| See [`M3e.Element.StepperReset.Builder`](M3e.Element.StepperReset#Builder).
-}
type alias ResetBuilder attrCaps slotCaps msg kind =
    Reset_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.StepperReset.AttrCaps`](M3e.Element.StepperReset#AttrCaps).
-}
type alias ResetAttrCaps =
    Reset_.AttrCaps


{-| See [`M3e.Element.StepperReset.SlotCaps`](M3e.Element.StepperReset#SlotCaps).
-}
type alias ResetSlotCaps =
    Reset_.SlotCaps


{-| See [`M3e.Element.StepperReset.ChildAdmittedBy`](M3e.Element.StepperReset#ChildAdmittedBy).
-}
type alias ResetChildAdmittedBy childAdm =
    Reset_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.StepperReset.child`](M3e.Element.StepperReset#child).
-}
resetChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
resetChild =
    Reset_.child
