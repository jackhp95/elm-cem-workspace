module M3e.Build.Step exposing (Builder, AttrCaps, SlotCaps, Is, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy, build, toElement, withClass, withCompleted, withDisabled, withEditable, withFor, withId, withInvalid, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withOptional, withSelected, withSlot, withStyle, doneIcon, editIcon, error, errorIcon, hint, icon, withDoneIcon, withEditIcon, withError, withErrorIcon, withHint, withIcon, withChild)

{-| The **Step** element — the flat per-element builder surface,
sourced through the **Stepper** family façade
(`M3e.Component.Stepper`). This module and the aggregated
`M3e.Build.Stepper` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, DoneIconSlot, EditIconSlot, ErrorSlot, ErrorIconSlot, HintSlot, IconSlot, ChildAdmittedBy, build, toElement, withClass, withCompleted, withDisabled, withEditable, withFor, withId, withInvalid, withOnBeforeinput, withOnChange, withOnClick, withOnInput, withOptional, withSelected, withSlot, withStyle, doneIcon, editIcon, error, errorIcon, hint, icon, withDoneIcon, withEditIcon, withError, withErrorIcon, withHint, withIcon, withChild

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
type alias Is s =
    Component.StepIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.StepBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.StepAttrCaps


{-| -}
type alias SlotCaps =
    Component.StepSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.StepChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.StepContent


{-| -}
type alias DoneIconSlot =
    Component.StepDoneIconSlot


{-| -}
type alias EditIconSlot =
    Component.StepEditIconSlot


{-| -}
type alias ErrorSlot =
    Component.StepErrorSlot


{-| -}
type alias ErrorIconSlot =
    Component.StepErrorIconSlot


{-| -}
type alias HintSlot =
    Component.StepHintSlot


{-| -}
type alias IconSlot =
    Component.StepIconSlot


{-| -}
build :
    { content : Element Component.StepContent (Component.StepChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-step" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.StepIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
doneIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepDoneIconSlot msg
    -> Element free freeAdmittedBy msg
doneIcon builder =
    Component.stepDoneIcon (B.toElement builder)


{-| -}
editIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepEditIconSlot msg
    -> Element free freeAdmittedBy msg
editIcon builder =
    Component.stepEditIcon (B.toElement builder)


{-| -}
error :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepErrorSlot msg
    -> Element free freeAdmittedBy msg
error builder =
    Component.stepError (B.toElement builder)


{-| -}
errorIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepErrorIconSlot msg
    -> Element free freeAdmittedBy msg
errorIcon builder =
    Component.stepErrorIcon (B.toElement builder)


{-| -}
hint :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepHintSlot msg
    -> Element free freeAdmittedBy msg
hint builder =
    Component.stepHint (B.toElement builder)


{-| -}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepIconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.stepIcon (B.toElement builder)


{-| -}
withDoneIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepDoneIconSlot msg
    -> Builder attrCaps { s | doneIcon : Available } msg kind
    -> Builder attrCaps { s | doneIcon : Used } msg kind
withDoneIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepDoneIcon (B.toElement slotBuilder))) builder_


{-| -}
withEditIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepEditIconSlot msg
    -> Builder attrCaps { s | editIcon : Available } msg kind
    -> Builder attrCaps { s | editIcon : Used } msg kind
withEditIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepEditIcon (B.toElement slotBuilder))) builder_


{-| -}
withError :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepErrorSlot msg
    -> Builder attrCaps { s | error : Available } msg kind
    -> Builder attrCaps { s | error : Used } msg kind
withError slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepError (B.toElement slotBuilder))) builder_


{-| -}
withErrorIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepErrorIconSlot msg
    -> Builder attrCaps { s | errorIcon : Available } msg kind
    -> Builder attrCaps { s | errorIcon : Used } msg kind
withErrorIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepErrorIcon (B.toElement slotBuilder))) builder_


{-| -}
withHint :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepHintSlot msg
    -> Builder attrCaps { s | hint : Available } msg kind
    -> Builder attrCaps { s | hint : Used } msg kind
withHint slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepHint (B.toElement slotBuilder))) builder_


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.StepIconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.stepIcon (B.toElement slotBuilder))) builder_


{-| -}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withCompleted : Bool -> Builder { a | completed : Available } slotCaps msg kind -> Builder { a | completed : Used } slotCaps msg kind
withCompleted value_ =
    B.withAttribute (A.completed value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withEditable : Bool -> Builder { a | editable : Available } slotCaps msg kind -> Builder { a | editable : Used } slotCaps msg kind
withEditable value_ =
    B.withAttribute (A.editable value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withInvalid : Bool -> Builder { a | invalid : Available } slotCaps msg kind -> Builder { a | invalid : Used } slotCaps msg kind
withInvalid value_ =
    B.withAttribute (A.invalid value_)


{-| -}
withOptional : Bool -> Builder { a | optional : Available } slotCaps msg kind -> Builder { a | optional : Used } slotCaps msg kind
withOptional value_ =
    B.withAttribute (A.optional value_)


{-| -}
withSelected : Bool -> Builder { a | selected : Available } slotCaps msg kind -> Builder { a | selected : Used } slotCaps msg kind
withSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
