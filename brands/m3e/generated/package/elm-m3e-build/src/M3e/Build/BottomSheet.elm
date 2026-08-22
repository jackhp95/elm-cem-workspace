module M3e.Build.BottomSheet exposing (BottomSheetBuilder, BottomSheetAttrCaps, BottomSheetSlotCaps, BottomSheetIs, BottomSheetChildAdmittedBy, bottomSheetBuild, bottomSheetToElement, bottomSheetWithClass, bottomSheetWithDetent, bottomSheetWithDetents, bottomSheetWithHandle, bottomSheetWithHandleLabel, bottomSheetWithHideFriction, bottomSheetWithHideable, bottomSheetWithId, bottomSheetWithModal, bottomSheetWithOnCancel, bottomSheetWithOnClosed, bottomSheetWithOnClosing, bottomSheetWithOnOpened, bottomSheetWithOnOpening, bottomSheetWithOpen, bottomSheetWithOvershootLimit, bottomSheetWithSlot, bottomSheetWithStyle, bottomSheetHeader, bottomSheetWithHeader, bottomSheetWithChild, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionIs, ActionContent, ActionChildAdmittedBy, actionBuild, actionToElement, actionWithClass, actionWithId, actionWithSlot, actionWithStyle, actionWithChild, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerIs, TriggerContent, TriggerChildAdmittedBy, triggerBuild, triggerToElement, triggerWithClass, triggerWithDetent, triggerWithFor, triggerWithId, triggerWithSecondary, triggerWithSlot, triggerWithStyle, triggerWithChild)

{-| The **BottomSheet** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.BottomSheet`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs BottomSheetBuilder, BottomSheetAttrCaps, BottomSheetSlotCaps, BottomSheetIs, BottomSheetChildAdmittedBy, bottomSheetBuild, bottomSheetToElement, bottomSheetWithClass, bottomSheetWithDetent, bottomSheetWithDetents, bottomSheetWithHandle, bottomSheetWithHandleLabel, bottomSheetWithHideFriction, bottomSheetWithHideable, bottomSheetWithId, bottomSheetWithModal, bottomSheetWithOnCancel, bottomSheetWithOnClosed, bottomSheetWithOnClosing, bottomSheetWithOnOpened, bottomSheetWithOnOpening, bottomSheetWithOpen, bottomSheetWithOvershootLimit, bottomSheetWithSlot, bottomSheetWithStyle, bottomSheetHeader, bottomSheetWithHeader, bottomSheetWithChild, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionIs, ActionContent, ActionChildAdmittedBy, actionBuild, actionToElement, actionWithClass, actionWithId, actionWithSlot, actionWithStyle, actionWithChild, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerIs, TriggerContent, TriggerChildAdmittedBy, triggerBuild, triggerToElement, triggerWithClass, triggerWithDetent, triggerWithFor, triggerWithId, triggerWithSecondary, triggerWithSlot, triggerWithStyle, triggerWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.BottomSheet as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias BottomSheetIs s =
    Component.BottomSheetIs s


{-| -}
type alias BottomSheetBuilder attrCaps slotCaps msg kind =
    Component.BottomSheetBuilder attrCaps slotCaps msg kind


{-| -}
type alias BottomSheetAttrCaps =
    Component.BottomSheetAttrCaps


{-| -}
type alias BottomSheetSlotCaps =
    Component.BottomSheetSlotCaps


{-| -}
type alias BottomSheetChildAdmittedBy childAdm =
    Component.BottomSheetChildAdmittedBy childAdm


{-| -}
bottomSheetBuild : BottomSheetBuilder BottomSheetAttrCaps BottomSheetSlotCaps msg kind
bottomSheetBuild =
    B.init "m3e-bottom-sheet" [] []


{-| -}
bottomSheetToElement : BottomSheetBuilder attrCaps slotCaps msg kind -> Element (Component.BottomSheetIs kind) admittedBy msg
bottomSheetToElement =
    B.toElement


{-| -}
bottomSheetHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
bottomSheetHeader builder =
    Component.bottomSheetHeader (B.toElement builder)


{-| -}
bottomSheetWithHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> BottomSheetBuilder attrCaps { s | header : Available } msg kind
    -> BottomSheetBuilder attrCaps { s | header : Used } msg kind
bottomSheetWithHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.bottomSheetHeader (B.toElement slotBuilder))) builder_


{-| -}
bottomSheetWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> BottomSheetBuilder attrCaps slotCaps msg kind
    -> BottomSheetBuilder attrCaps slotCaps msg kind
bottomSheetWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
bottomSheetWithClass : String -> BottomSheetBuilder { a | class : Available } slotCaps msg kind -> BottomSheetBuilder { a | class : Used } slotCaps msg kind
bottomSheetWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
bottomSheetWithId : String -> BottomSheetBuilder { a | id : Available } slotCaps msg kind -> BottomSheetBuilder { a | id : Used } slotCaps msg kind
bottomSheetWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
bottomSheetWithSlot : String -> BottomSheetBuilder { a | slot : Available } slotCaps msg kind -> BottomSheetBuilder { a | slot : Used } slotCaps msg kind
bottomSheetWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
bottomSheetWithStyle : String -> String -> BottomSheetBuilder { a | style : Available } slotCaps msg kind -> BottomSheetBuilder { a | style : Used } slotCaps msg kind
bottomSheetWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
bottomSheetWithDetent : Float -> BottomSheetBuilder { a | detent : Available } slotCaps msg kind -> BottomSheetBuilder { a | detent : Used } slotCaps msg kind
bottomSheetWithDetent value_ =
    B.withAttribute (A.detent value_)


{-| -}
bottomSheetWithDetents : String -> BottomSheetBuilder { a | detents : Available } slotCaps msg kind -> BottomSheetBuilder { a | detents : Used } slotCaps msg kind
bottomSheetWithDetents value_ =
    B.withAttribute (A.detents value_)


{-| -}
bottomSheetWithHandle : Bool -> BottomSheetBuilder { a | handle : Available } slotCaps msg kind -> BottomSheetBuilder { a | handle : Used } slotCaps msg kind
bottomSheetWithHandle value_ =
    B.withAttribute (A.handle value_)


{-| -}
bottomSheetWithHandleLabel : String -> BottomSheetBuilder { a | handleLabel : Available } slotCaps msg kind -> BottomSheetBuilder { a | handleLabel : Used } slotCaps msg kind
bottomSheetWithHandleLabel value_ =
    B.withAttribute (A.handleLabel value_)


{-| -}
bottomSheetWithHideFriction : Float -> BottomSheetBuilder { a | hideFriction : Available } slotCaps msg kind -> BottomSheetBuilder { a | hideFriction : Used } slotCaps msg kind
bottomSheetWithHideFriction value_ =
    B.withAttribute (A.hideFriction value_)


{-| -}
bottomSheetWithHideable : Bool -> BottomSheetBuilder { a | hideable : Available } slotCaps msg kind -> BottomSheetBuilder { a | hideable : Used } slotCaps msg kind
bottomSheetWithHideable value_ =
    B.withAttribute (A.hideable value_)


{-| -}
bottomSheetWithModal : Bool -> BottomSheetBuilder { a | modal : Available } slotCaps msg kind -> BottomSheetBuilder { a | modal : Used } slotCaps msg kind
bottomSheetWithModal value_ =
    B.withAttribute (A.modal value_)


{-| -}
bottomSheetWithOpen : Bool -> BottomSheetBuilder { a | open : Available } slotCaps msg kind -> BottomSheetBuilder { a | open : Used } slotCaps msg kind
bottomSheetWithOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
bottomSheetWithOvershootLimit : Float -> BottomSheetBuilder { a | overshootLimit : Available } slotCaps msg kind -> BottomSheetBuilder { a | overshootLimit : Used } slotCaps msg kind
bottomSheetWithOvershootLimit value_ =
    B.withAttribute (A.overshootLimit value_)


{-| -}
bottomSheetWithOnOpening : msg -> BottomSheetBuilder { a | onOpening : Available } slotCaps msg kind -> BottomSheetBuilder { a | onOpening : Used } slotCaps msg kind
bottomSheetWithOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
bottomSheetWithOnClosing : msg -> BottomSheetBuilder { a | onClosing : Available } slotCaps msg kind -> BottomSheetBuilder { a | onClosing : Used } slotCaps msg kind
bottomSheetWithOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
bottomSheetWithOnCancel : msg -> BottomSheetBuilder { a | onCancel : Available } slotCaps msg kind -> BottomSheetBuilder { a | onCancel : Used } slotCaps msg kind
bottomSheetWithOnCancel value_ =
    B.withAttribute (Ev.onCancel value_)


{-| -}
bottomSheetWithOnOpened : msg -> BottomSheetBuilder { a | onOpened : Available } slotCaps msg kind -> BottomSheetBuilder { a | onOpened : Used } slotCaps msg kind
bottomSheetWithOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
bottomSheetWithOnClosed : msg -> BottomSheetBuilder { a | onClosed : Available } slotCaps msg kind -> BottomSheetBuilder { a | onClosed : Used } slotCaps msg kind
bottomSheetWithOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)


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
type alias ActionContent =
    Component.ActionContent


{-| -}
actionBuild : ActionBuilder ActionAttrCaps ActionSlotCaps msg kind
actionBuild =
    B.init "m3e-bottom-sheet-action" [] []


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
type alias TriggerContent =
    Component.TriggerContent


{-| -}
triggerBuild : TriggerBuilder TriggerAttrCaps TriggerSlotCaps msg kind
triggerBuild =
    B.init "m3e-bottom-sheet-trigger" [] []


{-| -}
triggerToElement : TriggerBuilder attrCaps slotCaps msg kind -> Element (Component.TriggerIs kind) admittedBy msg
triggerToElement =
    B.toElement


{-| -}
triggerWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> TriggerBuilder attrCaps slotCaps msg kind
    -> TriggerBuilder attrCaps slotCaps msg kind
triggerWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


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
triggerWithDetent : Float -> TriggerBuilder { a | detent : Available } slotCaps msg kind -> TriggerBuilder { a | detent : Used } slotCaps msg kind
triggerWithDetent value_ =
    B.withAttribute (A.detent value_)


{-| -}
triggerWithFor : String -> TriggerBuilder { a | for : Available } slotCaps msg kind -> TriggerBuilder { a | for : Used } slotCaps msg kind
triggerWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
triggerWithSecondary : Bool -> TriggerBuilder { a | secondary : Available } slotCaps msg kind -> TriggerBuilder { a | secondary : Used } slotCaps msg kind
triggerWithSecondary value_ =
    B.withAttribute (A.secondary value_)
