module M3e.Family.Stepper exposing (StepperIs, StepperAttrs, StepperBuilder, StepperAttrCaps, StepperSlotCaps, StepperPanelSlot, StepperStepSlot, StepperChildAdmittedBy, StepperHeaderPosition, StepperLabelPosition, StepperOrientation, StepIs, StepAttrs, StepBuilder, StepAttrCaps, StepSlotCaps, StepContent, StepDoneIconSlot, StepEditIconSlot, StepErrorSlot, StepErrorIconSlot, StepHintSlot, StepIconSlot, StepChildAdmittedBy, PanelIs, PanelAttrs, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelChildAdmittedBy, NextIs, NextAttrs, NextBuilder, NextAttrCaps, NextSlotCaps, NextChildAdmittedBy, PreviousIs, PreviousAttrs, PreviousBuilder, PreviousAttrCaps, PreviousSlotCaps, PreviousChildAdmittedBy, ResetIs, ResetAttrs, ResetBuilder, ResetAttrCaps, ResetSlotCaps, ResetChildAdmittedBy, stepper, stepperHeaderPosition, stepperLabelPosition, stepperOrientation, stepperLinear, stepperOnChange, stepperOnBeforeinput, stepperOnInput, stepperPanel, stepperStep, step, stepCompleted, stepDisabled, stepEditable, stepFor, stepInvalid, stepOptional, stepSelected, stepDefaultSelected, stepOnBeforeinput, stepOnInput, stepOnChange, stepOnClick, stepDoneIcon, stepEditIcon, stepError, stepErrorIcon, stepHint, stepIcon, stepChild, panel, panelActions, panelChild, next, previous, previousChild, reset, resetChild)

{-| The **Stepper** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Stepper`](M3e.Component.Stepper) as `stepper`, [`M3e.Component.Step`](M3e.Component.Step) as `step`, [`M3e.Component.StepPanel`](M3e.Component.StepPanel) as `panel`, [`M3e.Component.StepperNext`](M3e.Component.StepperNext) as `next`, [`M3e.Component.StepperPrevious`](M3e.Component.StepperPrevious) as `previous`, [`M3e.Component.StepperReset`](M3e.Component.StepperReset) as `reset`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs StepperIs, StepperAttrs, StepperBuilder, StepperAttrCaps, StepperSlotCaps, StepperPanelSlot, StepperStepSlot, StepperChildAdmittedBy, StepperHeaderPosition, StepperLabelPosition, StepperOrientation, StepIs, StepAttrs, StepBuilder, StepAttrCaps, StepSlotCaps, StepContent, StepDoneIconSlot, StepEditIconSlot, StepErrorSlot, StepErrorIconSlot, StepHintSlot, StepIconSlot, StepChildAdmittedBy, PanelIs, PanelAttrs, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelChildAdmittedBy, NextIs, NextAttrs, NextBuilder, NextAttrCaps, NextSlotCaps, NextChildAdmittedBy, PreviousIs, PreviousAttrs, PreviousBuilder, PreviousAttrCaps, PreviousSlotCaps, PreviousChildAdmittedBy, ResetIs, ResetAttrs, ResetBuilder, ResetAttrCaps, ResetSlotCaps, ResetChildAdmittedBy, stepper, stepperHeaderPosition, stepperLabelPosition, stepperOrientation, stepperLinear, stepperOnChange, stepperOnBeforeinput, stepperOnInput, stepperPanel, stepperStep, step, stepCompleted, stepDisabled, stepEditable, stepFor, stepInvalid, stepOptional, stepSelected, stepDefaultSelected, stepOnBeforeinput, stepOnInput, stepOnChange, stepOnClick, stepDoneIcon, stepEditIcon, stepError, stepErrorIcon, stepHint, stepIcon, stepChild, panel, panelActions, panelChild, next, previous, previousChild, reset, resetChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Component.Step as Step_
import M3e.Component.StepPanel as Panel_
import M3e.Component.Stepper as Stepper_
import M3e.Component.StepperNext as Next_
import M3e.Component.StepperPrevious as Previous_
import M3e.Component.StepperReset as Reset_


{-| The `stepper` element of this family — delegates to [`M3e.Component.Stepper.component`](M3e.Component.Stepper#component).
-}
stepper :
    List (Attr StepperAttrs msg)
    -> List (Element childAccepts (StepperChildAdmittedBy childAdm) msg)
    -> Element (StepperIs s) admittedBy msg
stepper =
    Stepper_.component


{-| See [`M3e.Component.Stepper.Is`](M3e.Component.Stepper#Is).
-}
type alias StepperIs s =
    Stepper_.Is s


{-| See [`M3e.Component.Stepper.Attrs`](M3e.Component.Stepper#Attrs).
-}
type alias StepperAttrs =
    Stepper_.Attrs


{-| See [`M3e.Component.Stepper.Builder`](M3e.Component.Stepper#Builder).
-}
type alias StepperBuilder attrCaps slotCaps msg kind =
    Stepper_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Stepper.AttrCaps`](M3e.Component.Stepper#AttrCaps).
-}
type alias StepperAttrCaps =
    Stepper_.AttrCaps


{-| See [`M3e.Component.Stepper.SlotCaps`](M3e.Component.Stepper#SlotCaps).
-}
type alias StepperSlotCaps =
    Stepper_.SlotCaps


{-| See [`M3e.Component.Stepper.PanelSlot`](M3e.Component.Stepper#PanelSlot).
-}
type alias StepperPanelSlot =
    Stepper_.PanelSlot


{-| See [`M3e.Component.Stepper.StepSlot`](M3e.Component.Stepper#StepSlot).
-}
type alias StepperStepSlot =
    Stepper_.StepSlot


{-| See [`M3e.Component.Stepper.ChildAdmittedBy`](M3e.Component.Stepper#ChildAdmittedBy).
-}
type alias StepperChildAdmittedBy childAdm =
    Stepper_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Stepper.HeaderPosition`](M3e.Component.Stepper#HeaderPosition).
-}
type alias StepperHeaderPosition =
    Stepper_.HeaderPosition


{-| See [`M3e.Component.Stepper.headerPosition`](M3e.Component.Stepper#headerPosition).
-}
stepperHeaderPosition : Value StepperHeaderPosition -> Attr { c | headerPosition : Supported } msg
stepperHeaderPosition =
    Stepper_.headerPosition


{-| See [`M3e.Component.Stepper.LabelPosition`](M3e.Component.Stepper#LabelPosition).
-}
type alias StepperLabelPosition =
    Stepper_.LabelPosition


{-| See [`M3e.Component.Stepper.labelPosition`](M3e.Component.Stepper#labelPosition).
-}
stepperLabelPosition : Value StepperLabelPosition -> Attr { c | labelPosition : Supported } msg
stepperLabelPosition =
    Stepper_.labelPosition


{-| See [`M3e.Component.Stepper.Orientation`](M3e.Component.Stepper#Orientation).
-}
type alias StepperOrientation =
    Stepper_.Orientation


{-| See [`M3e.Component.Stepper.orientation`](M3e.Component.Stepper#orientation).
-}
stepperOrientation : Value StepperOrientation -> Attr { c | orientation : Supported } msg
stepperOrientation =
    Stepper_.orientation


{-| See [`M3e.Component.Stepper.linear`](M3e.Component.Stepper#linear).
-}
stepperLinear : Bool -> Attr { c | linear : Supported } msg
stepperLinear =
    Stepper_.linear


{-| See [`M3e.Component.Stepper.onChange`](M3e.Component.Stepper#onChange).
-}
stepperOnChange : msg -> Attr { c | onChange : Supported } msg
stepperOnChange =
    Stepper_.onChange


{-| See [`M3e.Component.Stepper.onBeforeinput`](M3e.Component.Stepper#onBeforeinput).
-}
stepperOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
stepperOnBeforeinput =
    Stepper_.onBeforeinput


{-| See [`M3e.Component.Stepper.onInput`](M3e.Component.Stepper#onInput).
-}
stepperOnInput : msg -> Attr { c | onInput : Supported } msg
stepperOnInput =
    Stepper_.onInput


{-| See [`M3e.Component.Stepper.panel`](M3e.Component.Stepper#panel).
-}
stepperPanel : Element StepperPanelSlot admittedBy msg -> Element free freeAdmittedBy msg
stepperPanel =
    Stepper_.panel


{-| See [`M3e.Component.Stepper.step`](M3e.Component.Stepper#step).
-}
stepperStep : Element StepperStepSlot admittedBy msg -> Element free freeAdmittedBy msg
stepperStep =
    Stepper_.step


{-| The `step` element of this family — delegates to [`M3e.Component.Step.component`](M3e.Component.Step#component).
-}
step :
    { content : Element StepContent (StepChildAdmittedBy childAdm) msg }
    -> List (Attr StepAttrs msg)
    -> List (Element StepContent (StepChildAdmittedBy childAdm) msg)
    -> Element (StepIs s) admittedBy msg
step =
    Step_.component


{-| See [`M3e.Component.Step.Is`](M3e.Component.Step#Is).
-}
type alias StepIs s =
    Step_.Is s


{-| See [`M3e.Component.Step.Attrs`](M3e.Component.Step#Attrs).
-}
type alias StepAttrs =
    Step_.Attrs


{-| See [`M3e.Component.Step.Builder`](M3e.Component.Step#Builder).
-}
type alias StepBuilder attrCaps slotCaps msg kind =
    Step_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Step.AttrCaps`](M3e.Component.Step#AttrCaps).
-}
type alias StepAttrCaps =
    Step_.AttrCaps


{-| See [`M3e.Component.Step.SlotCaps`](M3e.Component.Step#SlotCaps).
-}
type alias StepSlotCaps =
    Step_.SlotCaps


{-| See [`M3e.Component.Step.Content`](M3e.Component.Step#Content).
-}
type alias StepContent =
    Step_.Content


{-| See [`M3e.Component.Step.DoneIconSlot`](M3e.Component.Step#DoneIconSlot).
-}
type alias StepDoneIconSlot =
    Step_.DoneIconSlot


{-| See [`M3e.Component.Step.EditIconSlot`](M3e.Component.Step#EditIconSlot).
-}
type alias StepEditIconSlot =
    Step_.EditIconSlot


{-| See [`M3e.Component.Step.ErrorSlot`](M3e.Component.Step#ErrorSlot).
-}
type alias StepErrorSlot =
    Step_.ErrorSlot


{-| See [`M3e.Component.Step.ErrorIconSlot`](M3e.Component.Step#ErrorIconSlot).
-}
type alias StepErrorIconSlot =
    Step_.ErrorIconSlot


{-| See [`M3e.Component.Step.HintSlot`](M3e.Component.Step#HintSlot).
-}
type alias StepHintSlot =
    Step_.HintSlot


{-| See [`M3e.Component.Step.IconSlot`](M3e.Component.Step#IconSlot).
-}
type alias StepIconSlot =
    Step_.IconSlot


{-| See [`M3e.Component.Step.ChildAdmittedBy`](M3e.Component.Step#ChildAdmittedBy).
-}
type alias StepChildAdmittedBy childAdm =
    Step_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Step.completed`](M3e.Component.Step#completed).
-}
stepCompleted : Bool -> Attr { c | completed : Supported } msg
stepCompleted =
    Step_.completed


{-| See [`M3e.Component.Step.disabled`](M3e.Component.Step#disabled).
-}
stepDisabled : Bool -> Attr { c | disabled : Supported } msg
stepDisabled =
    Step_.disabled


{-| See [`M3e.Component.Step.editable`](M3e.Component.Step#editable).
-}
stepEditable : Bool -> Attr { c | editable : Supported } msg
stepEditable =
    Step_.editable


{-| See [`M3e.Component.Step.for`](M3e.Component.Step#for).
-}
stepFor : String -> Attr { c | for : Supported } msg
stepFor =
    Step_.for


{-| See [`M3e.Component.Step.invalid`](M3e.Component.Step#invalid).
-}
stepInvalid : Bool -> Attr { c | invalid : Supported } msg
stepInvalid =
    Step_.invalid


{-| See [`M3e.Component.Step.optional`](M3e.Component.Step#optional).
-}
stepOptional : Bool -> Attr { c | optional : Supported } msg
stepOptional =
    Step_.optional


{-| See [`M3e.Component.Step.selected`](M3e.Component.Step#selected).
-}
stepSelected : Bool -> Attr { c | selected : Supported } msg
stepSelected =
    Step_.selected


{-| See [`M3e.Component.Step.defaultSelected`](M3e.Component.Step#defaultSelected).
-}
stepDefaultSelected : Bool -> Attr { c | selected : Supported } msg
stepDefaultSelected =
    Step_.defaultSelected


{-| See [`M3e.Component.Step.onBeforeinput`](M3e.Component.Step#onBeforeinput).
-}
stepOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
stepOnBeforeinput =
    Step_.onBeforeinput


{-| See [`M3e.Component.Step.onInput`](M3e.Component.Step#onInput).
-}
stepOnInput : msg -> Attr { c | onInput : Supported } msg
stepOnInput =
    Step_.onInput


{-| See [`M3e.Component.Step.onChange`](M3e.Component.Step#onChange).
-}
stepOnChange : msg -> Attr { c | onChange : Supported } msg
stepOnChange =
    Step_.onChange


{-| See [`M3e.Component.Step.onClick`](M3e.Component.Step#onClick).
-}
stepOnClick : msg -> Attr { c | onClick : Supported } msg
stepOnClick =
    Step_.onClick


{-| See [`M3e.Component.Step.doneIcon`](M3e.Component.Step#doneIcon).
-}
stepDoneIcon : Element StepDoneIconSlot admittedBy msg -> Element free freeAdmittedBy msg
stepDoneIcon =
    Step_.doneIcon


{-| See [`M3e.Component.Step.editIcon`](M3e.Component.Step#editIcon).
-}
stepEditIcon : Element StepEditIconSlot admittedBy msg -> Element free freeAdmittedBy msg
stepEditIcon =
    Step_.editIcon


{-| See [`M3e.Component.Step.error`](M3e.Component.Step#error).
-}
stepError : Element StepErrorSlot admittedBy msg -> Element free freeAdmittedBy msg
stepError =
    Step_.error


{-| See [`M3e.Component.Step.errorIcon`](M3e.Component.Step#errorIcon).
-}
stepErrorIcon : Element StepErrorIconSlot admittedBy msg -> Element free freeAdmittedBy msg
stepErrorIcon =
    Step_.errorIcon


{-| See [`M3e.Component.Step.hint`](M3e.Component.Step#hint).
-}
stepHint : Element StepHintSlot admittedBy msg -> Element free freeAdmittedBy msg
stepHint =
    Step_.hint


{-| See [`M3e.Component.Step.icon`](M3e.Component.Step#icon).
-}
stepIcon : Element StepIconSlot admittedBy msg -> Element free freeAdmittedBy msg
stepIcon =
    Step_.icon


{-| See [`M3e.Component.Step.child`](M3e.Component.Step#child).
-}
stepChild : Element StepContent admittedBy msg -> Element free freeAdmittedBy msg
stepChild =
    Step_.child


{-| The `panel` element of this family — delegates to [`M3e.Component.StepPanel.component`](M3e.Component.StepPanel#component).
-}
panel :
    List (Attr PanelAttrs msg)
    -> List (Element childAccepts (PanelChildAdmittedBy childAdm) msg)
    -> Element (PanelIs s) admittedBy msg
panel =
    Panel_.component


{-| See [`M3e.Component.StepPanel.Is`](M3e.Component.StepPanel#Is).
-}
type alias PanelIs s =
    Panel_.Is s


{-| See [`M3e.Component.StepPanel.Attrs`](M3e.Component.StepPanel#Attrs).
-}
type alias PanelAttrs =
    Panel_.Attrs


{-| See [`M3e.Component.StepPanel.Builder`](M3e.Component.StepPanel#Builder).
-}
type alias PanelBuilder attrCaps slotCaps msg kind =
    Panel_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.StepPanel.AttrCaps`](M3e.Component.StepPanel#AttrCaps).
-}
type alias PanelAttrCaps =
    Panel_.AttrCaps


{-| See [`M3e.Component.StepPanel.SlotCaps`](M3e.Component.StepPanel#SlotCaps).
-}
type alias PanelSlotCaps =
    Panel_.SlotCaps


{-| See [`M3e.Component.StepPanel.ChildAdmittedBy`](M3e.Component.StepPanel#ChildAdmittedBy).
-}
type alias PanelChildAdmittedBy childAdm =
    Panel_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.StepPanel.actions`](M3e.Component.StepPanel#actions).
-}
panelActions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelActions =
    Panel_.actions


{-| See [`M3e.Component.StepPanel.child`](M3e.Component.StepPanel#child).
-}
panelChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
panelChild =
    Panel_.child


{-| The `next` element of this family — delegates to [`M3e.Component.StepperNext.component`](M3e.Component.StepperNext#component).
-}
next :
    List (Attr NextAttrs msg)
    -> List (Element childAccepts (NextChildAdmittedBy childAdm) msg)
    -> Element (NextIs s) admittedBy msg
next =
    Next_.component


{-| See [`M3e.Component.StepperNext.Is`](M3e.Component.StepperNext#Is).
-}
type alias NextIs s =
    Next_.Is s


{-| See [`M3e.Component.StepperNext.Attrs`](M3e.Component.StepperNext#Attrs).
-}
type alias NextAttrs =
    Next_.Attrs


{-| See [`M3e.Component.StepperNext.Builder`](M3e.Component.StepperNext#Builder).
-}
type alias NextBuilder attrCaps slotCaps msg kind =
    Next_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.StepperNext.AttrCaps`](M3e.Component.StepperNext#AttrCaps).
-}
type alias NextAttrCaps =
    Next_.AttrCaps


{-| See [`M3e.Component.StepperNext.SlotCaps`](M3e.Component.StepperNext#SlotCaps).
-}
type alias NextSlotCaps =
    Next_.SlotCaps


{-| See [`M3e.Component.StepperNext.ChildAdmittedBy`](M3e.Component.StepperNext#ChildAdmittedBy).
-}
type alias NextChildAdmittedBy childAdm =
    Next_.ChildAdmittedBy childAdm


{-| The `previous` element of this family — delegates to [`M3e.Component.StepperPrevious.component`](M3e.Component.StepperPrevious#component).
-}
previous :
    List (Attr PreviousAttrs msg)
    -> List (Element childAccepts (PreviousChildAdmittedBy childAdm) msg)
    -> Element (PreviousIs s) admittedBy msg
previous =
    Previous_.component


{-| See [`M3e.Component.StepperPrevious.Is`](M3e.Component.StepperPrevious#Is).
-}
type alias PreviousIs s =
    Previous_.Is s


{-| See [`M3e.Component.StepperPrevious.Attrs`](M3e.Component.StepperPrevious#Attrs).
-}
type alias PreviousAttrs =
    Previous_.Attrs


{-| See [`M3e.Component.StepperPrevious.Builder`](M3e.Component.StepperPrevious#Builder).
-}
type alias PreviousBuilder attrCaps slotCaps msg kind =
    Previous_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.StepperPrevious.AttrCaps`](M3e.Component.StepperPrevious#AttrCaps).
-}
type alias PreviousAttrCaps =
    Previous_.AttrCaps


{-| See [`M3e.Component.StepperPrevious.SlotCaps`](M3e.Component.StepperPrevious#SlotCaps).
-}
type alias PreviousSlotCaps =
    Previous_.SlotCaps


{-| See [`M3e.Component.StepperPrevious.ChildAdmittedBy`](M3e.Component.StepperPrevious#ChildAdmittedBy).
-}
type alias PreviousChildAdmittedBy childAdm =
    Previous_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.StepperPrevious.child`](M3e.Component.StepperPrevious#child).
-}
previousChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
previousChild =
    Previous_.child


{-| The `reset` element of this family — delegates to [`M3e.Component.StepperReset.component`](M3e.Component.StepperReset#component).
-}
reset :
    List (Attr ResetAttrs msg)
    -> List (Element childAccepts (ResetChildAdmittedBy childAdm) msg)
    -> Element (ResetIs s) admittedBy msg
reset =
    Reset_.component


{-| See [`M3e.Component.StepperReset.Is`](M3e.Component.StepperReset#Is).
-}
type alias ResetIs s =
    Reset_.Is s


{-| See [`M3e.Component.StepperReset.Attrs`](M3e.Component.StepperReset#Attrs).
-}
type alias ResetAttrs =
    Reset_.Attrs


{-| See [`M3e.Component.StepperReset.Builder`](M3e.Component.StepperReset#Builder).
-}
type alias ResetBuilder attrCaps slotCaps msg kind =
    Reset_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.StepperReset.AttrCaps`](M3e.Component.StepperReset#AttrCaps).
-}
type alias ResetAttrCaps =
    Reset_.AttrCaps


{-| See [`M3e.Component.StepperReset.SlotCaps`](M3e.Component.StepperReset#SlotCaps).
-}
type alias ResetSlotCaps =
    Reset_.SlotCaps


{-| See [`M3e.Component.StepperReset.ChildAdmittedBy`](M3e.Component.StepperReset#ChildAdmittedBy).
-}
type alias ResetChildAdmittedBy childAdm =
    Reset_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.StepperReset.child`](M3e.Component.StepperReset#child).
-}
resetChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
resetChild =
    Reset_.child
