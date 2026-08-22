module M3e.Build.Stepper exposing (StepperBuilder, StepperAttrCaps, StepperSlotCaps, StepperIs, StepperPanelSlot, StepperStepSlot, StepperChildAdmittedBy, stepperBuild, stepperToElement, stepperWithClass, stepperWithHeaderPosition, stepperWithId, stepperWithLabelPosition, stepperWithLinear, stepperWithOnBeforeinput, stepperWithOnChange, stepperWithOnInput, stepperWithOrientation, stepperWithSlot, stepperWithStyle, stepperPanel, stepperStep, stepperWithPanel, stepperWithStep, StepBuilder, StepAttrCaps, StepSlotCaps, StepIs, StepContent, StepDoneIconSlot, StepEditIconSlot, StepErrorSlot, StepErrorIconSlot, StepHintSlot, StepIconSlot, StepChildAdmittedBy, stepBuild, stepToElement, stepWithClass, stepWithCompleted, stepWithDisabled, stepWithEditable, stepWithFor, stepWithId, stepWithInvalid, stepWithOnBeforeinput, stepWithOnChange, stepWithOnClick, stepWithOnInput, stepWithOptional, stepWithSelected, stepWithSlot, stepWithStyle, stepDoneIcon, stepEditIcon, stepError, stepErrorIcon, stepHint, stepIcon, stepWithDoneIcon, stepWithEditIcon, stepWithError, stepWithErrorIcon, stepWithHint, stepWithIcon, stepWithChild, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelIs, PanelChildAdmittedBy, panelBuild, panelToElement, panelWithClass, panelWithId, panelWithSlot, panelWithStyle, panelActions, panelWithActions, panelWithChild, NextBuilder, NextAttrCaps, NextSlotCaps, NextIs, NextChildAdmittedBy, nextBuild, nextToElement, nextWithClass, nextWithId, nextWithSlot, nextWithStyle, PreviousBuilder, PreviousAttrCaps, PreviousSlotCaps, PreviousIs, PreviousChildAdmittedBy, previousBuild, previousToElement, previousWithClass, previousWithId, previousWithSlot, previousWithStyle, previousWithChild, ResetBuilder, ResetAttrCaps, ResetSlotCaps, ResetIs, ResetChildAdmittedBy, resetBuild, resetToElement, resetWithClass, resetWithId, resetWithSlot, resetWithStyle, resetWithChild)

{-| The **Stepper** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Stepper`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs StepperBuilder, StepperAttrCaps, StepperSlotCaps, StepperIs, StepperPanelSlot, StepperStepSlot, StepperChildAdmittedBy, stepperBuild, stepperToElement, stepperWithClass, stepperWithHeaderPosition, stepperWithId, stepperWithLabelPosition, stepperWithLinear, stepperWithOnBeforeinput, stepperWithOnChange, stepperWithOnInput, stepperWithOrientation, stepperWithSlot, stepperWithStyle, stepperPanel, stepperStep, stepperWithPanel, stepperWithStep, StepBuilder, StepAttrCaps, StepSlotCaps, StepIs, StepContent, StepDoneIconSlot, StepEditIconSlot, StepErrorSlot, StepErrorIconSlot, StepHintSlot, StepIconSlot, StepChildAdmittedBy, stepBuild, stepToElement, stepWithClass, stepWithCompleted, stepWithDisabled, stepWithEditable, stepWithFor, stepWithId, stepWithInvalid, stepWithOnBeforeinput, stepWithOnChange, stepWithOnClick, stepWithOnInput, stepWithOptional, stepWithSelected, stepWithSlot, stepWithStyle, stepDoneIcon, stepEditIcon, stepError, stepErrorIcon, stepHint, stepIcon, stepWithDoneIcon, stepWithEditIcon, stepWithError, stepWithErrorIcon, stepWithHint, stepWithIcon, stepWithChild, PanelBuilder, PanelAttrCaps, PanelSlotCaps, PanelIs, PanelChildAdmittedBy, panelBuild, panelToElement, panelWithClass, panelWithId, panelWithSlot, panelWithStyle, panelActions, panelWithActions, panelWithChild, NextBuilder, NextAttrCaps, NextSlotCaps, NextIs, NextChildAdmittedBy, nextBuild, nextToElement, nextWithClass, nextWithId, nextWithSlot, nextWithStyle, PreviousBuilder, PreviousAttrCaps, PreviousSlotCaps, PreviousIs, PreviousChildAdmittedBy, previousBuild, previousToElement, previousWithClass, previousWithId, previousWithSlot, previousWithStyle, previousWithChild, ResetBuilder, ResetAttrCaps, ResetSlotCaps, ResetIs, ResetChildAdmittedBy, resetBuild, resetToElement, resetWithClass, resetWithId, resetWithSlot, resetWithStyle, resetWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Stepper as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias StepperIs s =
    Component.StepperIs s


{-| -}
type alias StepperBuilder attrCaps slotCaps msg kind =
    Component.StepperBuilder attrCaps slotCaps msg kind


{-| -}
type alias StepperAttrCaps =
    Component.StepperAttrCaps


{-| -}
type alias StepperSlotCaps =
    Component.StepperSlotCaps


{-| -}
type alias StepperChildAdmittedBy childAdm =
    Component.StepperChildAdmittedBy childAdm


{-| -}
type alias StepperPanelSlot =
    Component.StepperPanelSlot


{-| -}
type alias StepperStepSlot =
    Component.StepperStepSlot


{-| -}
stepperBuild : StepperBuilder StepperAttrCaps StepperSlotCaps msg kind
stepperBuild =
    B.init "m3e-stepper" [] []


{-| -}
stepperToElement : StepperBuilder attrCaps slotCaps msg kind -> Element (Component.StepperIs kind) admittedBy msg
stepperToElement =
    B.toElement


{-| -}
stepperPanel :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepperPanelSlot msg
    -> Element free freeAdmittedBy msg
stepperPanel builder =
    Component.stepperPanel (B.toElement builder)


{-| -}
stepperStep :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepperStepSlot msg
    -> Element free freeAdmittedBy msg
stepperStep builder =
    Component.stepperStep (B.toElement builder)


{-| -}
stepperWithPanel :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepperPanelSlot msg
    -> StepperBuilder attrCaps slotCaps msg kind
    -> StepperBuilder attrCaps slotCaps msg kind
stepperWithPanel slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepperPanel (B.toElement slotBuilder))) builder_


{-| -}
stepperWithStep :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepperStepSlot msg
    -> StepperBuilder attrCaps slotCaps msg kind
    -> StepperBuilder attrCaps slotCaps msg kind
stepperWithStep slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepperStep (B.toElement slotBuilder))) builder_


{-| -}
stepperWithClass : String -> StepperBuilder { a | class : Available } slotCaps msg kind -> StepperBuilder { a | class : Used } slotCaps msg kind
stepperWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
stepperWithId : String -> StepperBuilder { a | id : Available } slotCaps msg kind -> StepperBuilder { a | id : Used } slotCaps msg kind
stepperWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
stepperWithSlot : String -> StepperBuilder { a | slot : Available } slotCaps msg kind -> StepperBuilder { a | slot : Used } slotCaps msg kind
stepperWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
stepperWithStyle : String -> String -> StepperBuilder { a | style : Available } slotCaps msg kind -> StepperBuilder { a | style : Used } slotCaps msg kind
stepperWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
stepperWithHeaderPosition : Value Component.StepperHeaderPosition -> StepperBuilder { a | headerPosition : Available } slotCaps msg kind -> StepperBuilder { a | headerPosition : Used } slotCaps msg kind
stepperWithHeaderPosition value_ =
    B.withAttribute (Component.stepperHeaderPosition value_)


{-| -}
stepperWithLabelPosition : Value Component.StepperLabelPosition -> StepperBuilder { a | labelPosition : Available } slotCaps msg kind -> StepperBuilder { a | labelPosition : Used } slotCaps msg kind
stepperWithLabelPosition value_ =
    B.withAttribute (Component.stepperLabelPosition value_)


{-| -}
stepperWithLinear : Bool -> StepperBuilder { a | linear : Available } slotCaps msg kind -> StepperBuilder { a | linear : Used } slotCaps msg kind
stepperWithLinear value_ =
    B.withAttribute (A.linear value_)


{-| -}
stepperWithOrientation : Value Component.StepperOrientation -> StepperBuilder { a | orientation : Available } slotCaps msg kind -> StepperBuilder { a | orientation : Used } slotCaps msg kind
stepperWithOrientation value_ =
    B.withAttribute (Component.stepperOrientation value_)


{-| -}
stepperWithOnChange : msg -> StepperBuilder { a | onChange : Available } slotCaps msg kind -> StepperBuilder { a | onChange : Used } slotCaps msg kind
stepperWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
stepperWithOnBeforeinput : msg -> StepperBuilder { a | onBeforeinput : Available } slotCaps msg kind -> StepperBuilder { a | onBeforeinput : Used } slotCaps msg kind
stepperWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
stepperWithOnInput : msg -> StepperBuilder { a | onInput : Available } slotCaps msg kind -> StepperBuilder { a | onInput : Used } slotCaps msg kind
stepperWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
type alias StepIs s =
    Component.StepIs s


{-| -}
type alias StepBuilder attrCaps slotCaps msg kind =
    Component.StepBuilder attrCaps slotCaps msg kind


{-| -}
type alias StepAttrCaps =
    Component.StepAttrCaps


{-| -}
type alias StepSlotCaps =
    Component.StepSlotCaps


{-| -}
type alias StepChildAdmittedBy childAdm =
    Component.StepChildAdmittedBy childAdm


{-| -}
type alias StepContent =
    Component.StepContent


{-| -}
type alias StepDoneIconSlot =
    Component.StepDoneIconSlot


{-| -}
type alias StepEditIconSlot =
    Component.StepEditIconSlot


{-| -}
type alias StepErrorSlot =
    Component.StepErrorSlot


{-| -}
type alias StepErrorIconSlot =
    Component.StepErrorIconSlot


{-| -}
type alias StepHintSlot =
    Component.StepHintSlot


{-| -}
type alias StepIconSlot =
    Component.StepIconSlot


{-| -}
stepBuild :
    { content : Element Component.StepContent (Component.StepChildAdmittedBy childAdm) msg }
    -> StepBuilder StepAttrCaps StepSlotCaps msg kind
stepBuild required_ =
    B.init "m3e-step" [] [ El.toNode required_.content ]


{-| -}
stepToElement : StepBuilder attrCaps slotCaps msg kind -> Element (Component.StepIs kind) admittedBy msg
stepToElement =
    B.toElement


{-| -}
stepDoneIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepDoneIconSlot msg
    -> Element free freeAdmittedBy msg
stepDoneIcon builder =
    Component.stepDoneIcon (B.toElement builder)


{-| -}
stepEditIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepEditIconSlot msg
    -> Element free freeAdmittedBy msg
stepEditIcon builder =
    Component.stepEditIcon (B.toElement builder)


{-| -}
stepError :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepErrorSlot msg
    -> Element free freeAdmittedBy msg
stepError builder =
    Component.stepError (B.toElement builder)


{-| -}
stepErrorIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepErrorIconSlot msg
    -> Element free freeAdmittedBy msg
stepErrorIcon builder =
    Component.stepErrorIcon (B.toElement builder)


{-| -}
stepHint :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepHintSlot msg
    -> Element free freeAdmittedBy msg
stepHint builder =
    Component.stepHint (B.toElement builder)


{-| -}
stepIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepIconSlot msg
    -> Element free freeAdmittedBy msg
stepIcon builder =
    Component.stepIcon (B.toElement builder)


{-| -}
stepWithDoneIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepDoneIconSlot msg
    -> StepBuilder attrCaps { s | doneIcon : Available } msg kind
    -> StepBuilder attrCaps { s | doneIcon : Used } msg kind
stepWithDoneIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepDoneIcon (B.toElement slotBuilder))) builder_


{-| -}
stepWithEditIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepEditIconSlot msg
    -> StepBuilder attrCaps { s | editIcon : Available } msg kind
    -> StepBuilder attrCaps { s | editIcon : Used } msg kind
stepWithEditIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepEditIcon (B.toElement slotBuilder))) builder_


{-| -}
stepWithError :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepErrorSlot msg
    -> StepBuilder attrCaps { s | error : Available } msg kind
    -> StepBuilder attrCaps { s | error : Used } msg kind
stepWithError slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepError (B.toElement slotBuilder))) builder_


{-| -}
stepWithErrorIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepErrorIconSlot msg
    -> StepBuilder attrCaps { s | errorIcon : Available } msg kind
    -> StepBuilder attrCaps { s | errorIcon : Used } msg kind
stepWithErrorIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepErrorIcon (B.toElement slotBuilder))) builder_


{-| -}
stepWithHint :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepHintSlot msg
    -> StepBuilder attrCaps { s | hint : Available } msg kind
    -> StepBuilder attrCaps { s | hint : Used } msg kind
stepWithHint slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepHint (B.toElement slotBuilder))) builder_


{-| -}
stepWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepIconSlot msg
    -> StepBuilder attrCaps { s | icon : Available } msg kind
    -> StepBuilder attrCaps { s | icon : Used } msg kind
stepWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepIcon (B.toElement slotBuilder))) builder_


{-| -}
stepWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> StepBuilder attrCaps slotCaps msg kind
    -> StepBuilder attrCaps slotCaps msg kind
stepWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
stepWithClass : String -> StepBuilder { a | class : Available } slotCaps msg kind -> StepBuilder { a | class : Used } slotCaps msg kind
stepWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
stepWithId : String -> StepBuilder { a | id : Available } slotCaps msg kind -> StepBuilder { a | id : Used } slotCaps msg kind
stepWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
stepWithSlot : String -> StepBuilder { a | slot : Available } slotCaps msg kind -> StepBuilder { a | slot : Used } slotCaps msg kind
stepWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
stepWithStyle : String -> String -> StepBuilder { a | style : Available } slotCaps msg kind -> StepBuilder { a | style : Used } slotCaps msg kind
stepWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
stepWithCompleted : Bool -> StepBuilder { a | completed : Available } slotCaps msg kind -> StepBuilder { a | completed : Used } slotCaps msg kind
stepWithCompleted value_ =
    B.withAttribute (A.completed value_)


{-| -}
stepWithDisabled : Bool -> StepBuilder { a | disabled : Available } slotCaps msg kind -> StepBuilder { a | disabled : Used } slotCaps msg kind
stepWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
stepWithEditable : Bool -> StepBuilder { a | editable : Available } slotCaps msg kind -> StepBuilder { a | editable : Used } slotCaps msg kind
stepWithEditable value_ =
    B.withAttribute (A.editable value_)


{-| -}
stepWithFor : String -> StepBuilder { a | for : Available } slotCaps msg kind -> StepBuilder { a | for : Used } slotCaps msg kind
stepWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
stepWithInvalid : Bool -> StepBuilder { a | invalid : Available } slotCaps msg kind -> StepBuilder { a | invalid : Used } slotCaps msg kind
stepWithInvalid value_ =
    B.withAttribute (A.invalid value_)


{-| -}
stepWithOptional : Bool -> StepBuilder { a | optional : Available } slotCaps msg kind -> StepBuilder { a | optional : Used } slotCaps msg kind
stepWithOptional value_ =
    B.withAttribute (A.optional value_)


{-| -}
stepWithSelected : Bool -> StepBuilder { a | selected : Available } slotCaps msg kind -> StepBuilder { a | selected : Used } slotCaps msg kind
stepWithSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
stepWithOnBeforeinput : msg -> StepBuilder { a | onBeforeinput : Available } slotCaps msg kind -> StepBuilder { a | onBeforeinput : Used } slotCaps msg kind
stepWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
stepWithOnInput : msg -> StepBuilder { a | onInput : Available } slotCaps msg kind -> StepBuilder { a | onInput : Used } slotCaps msg kind
stepWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
stepWithOnChange : msg -> StepBuilder { a | onChange : Available } slotCaps msg kind -> StepBuilder { a | onChange : Used } slotCaps msg kind
stepWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
stepWithOnClick : msg -> StepBuilder { a | onClick : Available } slotCaps msg kind -> StepBuilder { a | onClick : Used } slotCaps msg kind
stepWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias PanelIs s =
    Component.PanelIs s


{-| -}
type alias PanelBuilder attrCaps slotCaps msg kind =
    Component.PanelBuilder attrCaps slotCaps msg kind


{-| -}
type alias PanelAttrCaps =
    Component.PanelAttrCaps


{-| -}
type alias PanelSlotCaps =
    Component.PanelSlotCaps


{-| -}
type alias PanelChildAdmittedBy childAdm =
    Component.PanelChildAdmittedBy childAdm


{-| -}
panelBuild : PanelBuilder PanelAttrCaps PanelSlotCaps msg kind
panelBuild =
    B.init "m3e-step-panel" [] []


{-| -}
panelToElement : PanelBuilder attrCaps slotCaps msg kind -> Element (Component.PanelIs kind) admittedBy msg
panelToElement =
    B.toElement


{-| -}
panelActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
panelActions builder =
    Component.panelActions (B.toElement builder)


{-| -}
panelWithActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> PanelBuilder attrCaps { s | actions : Available } msg kind
    -> PanelBuilder attrCaps { s | actions : Used } msg kind
panelWithActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.panelActions (B.toElement slotBuilder))) builder_


{-| -}
panelWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> PanelBuilder attrCaps slotCaps msg kind
    -> PanelBuilder attrCaps slotCaps msg kind
panelWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
panelWithClass : String -> PanelBuilder { a | class : Available } slotCaps msg kind -> PanelBuilder { a | class : Used } slotCaps msg kind
panelWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
panelWithId : String -> PanelBuilder { a | id : Available } slotCaps msg kind -> PanelBuilder { a | id : Used } slotCaps msg kind
panelWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
panelWithSlot : String -> PanelBuilder { a | slot : Available } slotCaps msg kind -> PanelBuilder { a | slot : Used } slotCaps msg kind
panelWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
panelWithStyle : String -> String -> PanelBuilder { a | style : Available } slotCaps msg kind -> PanelBuilder { a | style : Used } slotCaps msg kind
panelWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
type alias NextIs s =
    Component.NextIs s


{-| -}
type alias NextBuilder attrCaps slotCaps msg kind =
    Component.NextBuilder attrCaps slotCaps msg kind


{-| -}
type alias NextAttrCaps =
    Component.NextAttrCaps


{-| -}
type alias NextSlotCaps =
    Component.NextSlotCaps


{-| -}
type alias NextChildAdmittedBy childAdm =
    Component.NextChildAdmittedBy childAdm


{-| -}
nextBuild : NextBuilder NextAttrCaps NextSlotCaps msg kind
nextBuild =
    B.init "m3e-stepper-next" [] []


{-| -}
nextToElement : NextBuilder attrCaps slotCaps msg kind -> Element (Component.NextIs kind) admittedBy msg
nextToElement =
    B.toElement


{-| -}
nextWithClass : String -> NextBuilder { a | class : Available } slotCaps msg kind -> NextBuilder { a | class : Used } slotCaps msg kind
nextWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
nextWithId : String -> NextBuilder { a | id : Available } slotCaps msg kind -> NextBuilder { a | id : Used } slotCaps msg kind
nextWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
nextWithSlot : String -> NextBuilder { a | slot : Available } slotCaps msg kind -> NextBuilder { a | slot : Used } slotCaps msg kind
nextWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
nextWithStyle : String -> String -> NextBuilder { a | style : Available } slotCaps msg kind -> NextBuilder { a | style : Used } slotCaps msg kind
nextWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
type alias PreviousIs s =
    Component.PreviousIs s


{-| -}
type alias PreviousBuilder attrCaps slotCaps msg kind =
    Component.PreviousBuilder attrCaps slotCaps msg kind


{-| -}
type alias PreviousAttrCaps =
    Component.PreviousAttrCaps


{-| -}
type alias PreviousSlotCaps =
    Component.PreviousSlotCaps


{-| -}
type alias PreviousChildAdmittedBy childAdm =
    Component.PreviousChildAdmittedBy childAdm


{-| -}
previousBuild : PreviousBuilder PreviousAttrCaps PreviousSlotCaps msg kind
previousBuild =
    B.init "m3e-stepper-previous" [] []


{-| -}
previousToElement : PreviousBuilder attrCaps slotCaps msg kind -> Element (Component.PreviousIs kind) admittedBy msg
previousToElement =
    B.toElement


{-| -}
previousWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> PreviousBuilder attrCaps slotCaps msg kind
    -> PreviousBuilder attrCaps slotCaps msg kind
previousWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
previousWithClass : String -> PreviousBuilder { a | class : Available } slotCaps msg kind -> PreviousBuilder { a | class : Used } slotCaps msg kind
previousWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
previousWithId : String -> PreviousBuilder { a | id : Available } slotCaps msg kind -> PreviousBuilder { a | id : Used } slotCaps msg kind
previousWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
previousWithSlot : String -> PreviousBuilder { a | slot : Available } slotCaps msg kind -> PreviousBuilder { a | slot : Used } slotCaps msg kind
previousWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
previousWithStyle : String -> String -> PreviousBuilder { a | style : Available } slotCaps msg kind -> PreviousBuilder { a | style : Used } slotCaps msg kind
previousWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
type alias ResetIs s =
    Component.ResetIs s


{-| -}
type alias ResetBuilder attrCaps slotCaps msg kind =
    Component.ResetBuilder attrCaps slotCaps msg kind


{-| -}
type alias ResetAttrCaps =
    Component.ResetAttrCaps


{-| -}
type alias ResetSlotCaps =
    Component.ResetSlotCaps


{-| -}
type alias ResetChildAdmittedBy childAdm =
    Component.ResetChildAdmittedBy childAdm


{-| -}
resetBuild : ResetBuilder ResetAttrCaps ResetSlotCaps msg kind
resetBuild =
    B.init "m3e-stepper-reset" [] []


{-| -}
resetToElement : ResetBuilder attrCaps slotCaps msg kind -> Element (Component.ResetIs kind) admittedBy msg
resetToElement =
    B.toElement


{-| -}
resetWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ResetBuilder attrCaps slotCaps msg kind
    -> ResetBuilder attrCaps slotCaps msg kind
resetWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
resetWithClass : String -> ResetBuilder { a | class : Available } slotCaps msg kind -> ResetBuilder { a | class : Used } slotCaps msg kind
resetWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
resetWithId : String -> ResetBuilder { a | id : Available } slotCaps msg kind -> ResetBuilder { a | id : Used } slotCaps msg kind
resetWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
resetWithSlot : String -> ResetBuilder { a | slot : Available } slotCaps msg kind -> ResetBuilder { a | slot : Used } slotCaps msg kind
resetWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
resetWithStyle : String -> String -> ResetBuilder { a | style : Available } slotCaps msg kind -> ResetBuilder { a | style : Used } slotCaps msg kind
resetWithStyle property value_ =
    B.withAttribute (A.style property value_)
