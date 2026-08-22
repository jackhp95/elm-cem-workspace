module M3e.Build.Dialog exposing (DialogBuilder, DialogAttrCaps, DialogSlotCaps, DialogIs, DialogCloseIconSlot, DialogHeaderSlot, DialogChildAdmittedBy, dialogBuild, dialogToElement, dialogWithAlert, dialogWithClass, dialogWithCloseLabel, dialogWithDisableClose, dialogWithDismissible, dialogWithId, dialogWithNoFocusTrap, dialogWithOnCancel, dialogWithOnClosed, dialogWithOnClosing, dialogWithOnOpened, dialogWithOnOpening, dialogWithOpen, dialogWithSlot, dialogWithStyle, dialogActions, dialogCloseIcon, dialogHeader, dialogWithActions, dialogWithCloseIcon, dialogWithHeader, dialogWithChild, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionIs, ActionChildAdmittedBy, actionBuild, actionToElement, actionWithClass, actionWithId, actionWithReturnValue, actionWithSlot, actionWithStyle, actionWithChild, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerIs, TriggerChildAdmittedBy, triggerBuild, triggerToElement, triggerWithClass, triggerWithFor, triggerWithId, triggerWithSlot, triggerWithStyle)

{-| The **Dialog** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Dialog`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs DialogBuilder, DialogAttrCaps, DialogSlotCaps, DialogIs, DialogCloseIconSlot, DialogHeaderSlot, DialogChildAdmittedBy, dialogBuild, dialogToElement, dialogWithAlert, dialogWithClass, dialogWithCloseLabel, dialogWithDisableClose, dialogWithDismissible, dialogWithId, dialogWithNoFocusTrap, dialogWithOnCancel, dialogWithOnClosed, dialogWithOnClosing, dialogWithOnOpened, dialogWithOnOpening, dialogWithOpen, dialogWithSlot, dialogWithStyle, dialogActions, dialogCloseIcon, dialogHeader, dialogWithActions, dialogWithCloseIcon, dialogWithHeader, dialogWithChild, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionIs, ActionChildAdmittedBy, actionBuild, actionToElement, actionWithClass, actionWithId, actionWithReturnValue, actionWithSlot, actionWithStyle, actionWithChild, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerIs, TriggerChildAdmittedBy, triggerBuild, triggerToElement, triggerWithClass, triggerWithFor, triggerWithId, triggerWithSlot, triggerWithStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Dialog as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias DialogIs s =
    Component.DialogIs s


{-| -}
type alias DialogBuilder attrCaps slotCaps msg kind =
    Component.DialogBuilder attrCaps slotCaps msg kind


{-| -}
type alias DialogAttrCaps =
    Component.DialogAttrCaps


{-| -}
type alias DialogSlotCaps =
    Component.DialogSlotCaps


{-| -}
type alias DialogChildAdmittedBy childAdm =
    Component.DialogChildAdmittedBy childAdm


{-| -}
type alias DialogCloseIconSlot =
    Component.DialogCloseIconSlot


{-| -}
type alias DialogHeaderSlot =
    Component.DialogHeaderSlot


{-| -}
dialogBuild : DialogBuilder DialogAttrCaps DialogSlotCaps msg kind
dialogBuild =
    B.init "m3e-dialog" [] []


{-| -}
dialogToElement : DialogBuilder attrCaps slotCaps msg kind -> Element (Component.DialogIs kind) admittedBy msg
dialogToElement =
    B.toElement


{-| -}
dialogActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
dialogActions builder =
    Component.dialogActions (B.toElement builder)


{-| -}
dialogCloseIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.DialogCloseIconSlot msg
    -> Element free freeAdmittedBy msg
dialogCloseIcon builder =
    Component.dialogCloseIcon (B.toElement builder)


{-| -}
dialogHeader :
    B.Builder childRow childAttrCaps childSlotCaps Component.DialogHeaderSlot msg
    -> Element free freeAdmittedBy msg
dialogHeader builder =
    Component.dialogHeader (B.toElement builder)


{-| -}
dialogWithActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> DialogBuilder attrCaps { s | actions : Available } msg kind
    -> DialogBuilder attrCaps { s | actions : Used } msg kind
dialogWithActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.dialogActions (B.toElement slotBuilder))) builder_


{-| -}
dialogWithCloseIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.DialogCloseIconSlot msg
    -> DialogBuilder attrCaps { s | closeIcon : Available } msg kind
    -> DialogBuilder attrCaps { s | closeIcon : Used } msg kind
dialogWithCloseIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.dialogCloseIcon (B.toElement slotBuilder))) builder_


{-| -}
dialogWithHeader :
    B.Builder childRow childAttrCaps childSlotCaps Component.DialogHeaderSlot msg
    -> DialogBuilder attrCaps { s | header : Available } msg kind
    -> DialogBuilder attrCaps { s | header : Used } msg kind
dialogWithHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.dialogHeader (B.toElement slotBuilder))) builder_


{-| -}
dialogWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> DialogBuilder attrCaps slotCaps msg kind
    -> DialogBuilder attrCaps slotCaps msg kind
dialogWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
dialogWithClass : String -> DialogBuilder { a | class : Available } slotCaps msg kind -> DialogBuilder { a | class : Used } slotCaps msg kind
dialogWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
dialogWithId : String -> DialogBuilder { a | id : Available } slotCaps msg kind -> DialogBuilder { a | id : Used } slotCaps msg kind
dialogWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
dialogWithSlot : String -> DialogBuilder { a | slot : Available } slotCaps msg kind -> DialogBuilder { a | slot : Used } slotCaps msg kind
dialogWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
dialogWithStyle : String -> String -> DialogBuilder { a | style : Available } slotCaps msg kind -> DialogBuilder { a | style : Used } slotCaps msg kind
dialogWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
dialogWithAlert : Bool -> DialogBuilder { a | alert : Available } slotCaps msg kind -> DialogBuilder { a | alert : Used } slotCaps msg kind
dialogWithAlert value_ =
    B.withAttribute (A.alert value_)


{-| -}
dialogWithCloseLabel : String -> DialogBuilder { a | closeLabel : Available } slotCaps msg kind -> DialogBuilder { a | closeLabel : Used } slotCaps msg kind
dialogWithCloseLabel value_ =
    B.withAttribute (A.closeLabel value_)


{-| -}
dialogWithDisableClose : Bool -> DialogBuilder { a | disableClose : Available } slotCaps msg kind -> DialogBuilder { a | disableClose : Used } slotCaps msg kind
dialogWithDisableClose value_ =
    B.withAttribute (A.disableClose value_)


{-| -}
dialogWithDismissible : Bool -> DialogBuilder { a | dismissible : Available } slotCaps msg kind -> DialogBuilder { a | dismissible : Used } slotCaps msg kind
dialogWithDismissible value_ =
    B.withAttribute (A.dismissible value_)


{-| -}
dialogWithNoFocusTrap : Bool -> DialogBuilder { a | noFocusTrap : Available } slotCaps msg kind -> DialogBuilder { a | noFocusTrap : Used } slotCaps msg kind
dialogWithNoFocusTrap value_ =
    B.withAttribute (A.noFocusTrap value_)


{-| -}
dialogWithOpen : Bool -> DialogBuilder { a | open : Available } slotCaps msg kind -> DialogBuilder { a | open : Used } slotCaps msg kind
dialogWithOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
dialogWithOnOpening : msg -> DialogBuilder { a | onOpening : Available } slotCaps msg kind -> DialogBuilder { a | onOpening : Used } slotCaps msg kind
dialogWithOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
dialogWithOnOpened : msg -> DialogBuilder { a | onOpened : Available } slotCaps msg kind -> DialogBuilder { a | onOpened : Used } slotCaps msg kind
dialogWithOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
dialogWithOnClosing : msg -> DialogBuilder { a | onClosing : Available } slotCaps msg kind -> DialogBuilder { a | onClosing : Used } slotCaps msg kind
dialogWithOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
dialogWithOnClosed : msg -> DialogBuilder { a | onClosed : Available } slotCaps msg kind -> DialogBuilder { a | onClosed : Used } slotCaps msg kind
dialogWithOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)


{-| -}
dialogWithOnCancel : msg -> DialogBuilder { a | onCancel : Available } slotCaps msg kind -> DialogBuilder { a | onCancel : Used } slotCaps msg kind
dialogWithOnCancel value_ =
    B.withAttribute (Ev.onCancel value_)


{-| -}
type alias ActionIs s =
    Component.ActionIs s


{-| -}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Component.ActionBuilder attrCaps slotCaps msg kind


{-| -}
type alias ActionAttrCaps =
    Component.ActionAttrCaps


{-| -}
type alias ActionSlotCaps =
    Component.ActionSlotCaps


{-| -}
type alias ActionChildAdmittedBy childAdm =
    Component.ActionChildAdmittedBy childAdm


{-| -}
actionBuild : ActionBuilder ActionAttrCaps ActionSlotCaps msg kind
actionBuild =
    B.init "m3e-dialog-action" [] []


{-| -}
actionToElement : ActionBuilder attrCaps slotCaps msg kind -> Element (Component.ActionIs kind) admittedBy msg
actionToElement =
    B.toElement


{-| -}
actionWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ActionBuilder attrCaps slotCaps msg kind
    -> ActionBuilder attrCaps slotCaps msg kind
actionWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
actionWithClass : String -> ActionBuilder { a | class : Available } slotCaps msg kind -> ActionBuilder { a | class : Used } slotCaps msg kind
actionWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
actionWithId : String -> ActionBuilder { a | id : Available } slotCaps msg kind -> ActionBuilder { a | id : Used } slotCaps msg kind
actionWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
actionWithSlot : String -> ActionBuilder { a | slot : Available } slotCaps msg kind -> ActionBuilder { a | slot : Used } slotCaps msg kind
actionWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
actionWithStyle : String -> String -> ActionBuilder { a | style : Available } slotCaps msg kind -> ActionBuilder { a | style : Used } slotCaps msg kind
actionWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
actionWithReturnValue : String -> ActionBuilder { a | returnValue : Available } slotCaps msg kind -> ActionBuilder { a | returnValue : Used } slotCaps msg kind
actionWithReturnValue value_ =
    B.withAttribute (A.returnValue value_)


{-| -}
type alias TriggerIs s =
    Component.TriggerIs s


{-| -}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Component.TriggerBuilder attrCaps slotCaps msg kind


{-| -}
type alias TriggerAttrCaps =
    Component.TriggerAttrCaps


{-| -}
type alias TriggerSlotCaps =
    Component.TriggerSlotCaps


{-| -}
type alias TriggerChildAdmittedBy childAdm =
    Component.TriggerChildAdmittedBy childAdm


{-| -}
triggerBuild : TriggerBuilder TriggerAttrCaps TriggerSlotCaps msg kind
triggerBuild =
    B.init "m3e-dialog-trigger" [] []


{-| -}
triggerToElement : TriggerBuilder attrCaps slotCaps msg kind -> Element (Component.TriggerIs kind) admittedBy msg
triggerToElement =
    B.toElement


{-| -}
triggerWithClass : String -> TriggerBuilder { a | class : Available } slotCaps msg kind -> TriggerBuilder { a | class : Used } slotCaps msg kind
triggerWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
triggerWithId : String -> TriggerBuilder { a | id : Available } slotCaps msg kind -> TriggerBuilder { a | id : Used } slotCaps msg kind
triggerWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
triggerWithSlot : String -> TriggerBuilder { a | slot : Available } slotCaps msg kind -> TriggerBuilder { a | slot : Used } slotCaps msg kind
triggerWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
triggerWithStyle : String -> String -> TriggerBuilder { a | style : Available } slotCaps msg kind -> TriggerBuilder { a | style : Used } slotCaps msg kind
triggerWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
triggerWithFor : String -> TriggerBuilder { a | for : Available } slotCaps msg kind -> TriggerBuilder { a | for : Used } slotCaps msg kind
triggerWithFor value_ =
    B.withAttribute (A.for value_)
