module M3e.Build.RichTooltip exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, SubheadSlot, ChildAdmittedBy
    , withClass, withDisabled, withFor, withHideDelay, withId, withOnBeforetoggle, withOnToggle, withPosition, withShowDelay, withSlot, withStyle, withTouchGestures
    , actions, subhead
    , withActions, withSubhead, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, SubheadSlot, ChildAdmittedBy
@docs withClass, withDisabled, withFor, withHideDelay, withId, withOnBeforetoggle, withOnToggle, withPosition, withShowDelay, withSlot, withStyle, withTouchGestures
@docs actions, subhead
@docs withActions, withSubhead, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.RichTooltip as Component
import M3e.Events as Ev
import M3e.Internal.Types.RichTooltip
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.RichTooltip.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.RichTooltip.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.RichTooltip.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.RichTooltip.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.RichTooltip.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    M3e.Internal.Types.RichTooltip.Content


{-| -}
type alias SubheadSlot =
    M3e.Internal.Types.RichTooltip.SubheadSlot


{-| -}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-rich-tooltip" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
actions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
actions builder =
    Component.actions (B.toElement builder)


{-| -}
subhead :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubheadSlot msg
    -> Element free freeAdmittedBy msg
subhead builder =
    Component.subhead (B.toElement builder)


{-| -}
withActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | actions : Available } msg kind
    -> Builder attrCaps { s | actions : Used } msg kind
withActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.actions (B.toElement slotBuilder))) builder_


{-| -}
withSubhead :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubheadSlot msg
    -> Builder attrCaps { s | subhead : Available } msg kind
    -> Builder attrCaps { s | subhead : Used } msg kind
withSubhead slotBuilder builder_ =
    B.withChild (El.toNode (Component.subhead (B.toElement slotBuilder))) builder_


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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withHideDelay : Float -> Builder { a | hideDelay : Available } slotCaps msg kind -> Builder { a | hideDelay : Used } slotCaps msg kind
withHideDelay value_ =
    B.withAttribute (A.hideDelay value_)


{-| -}
withPosition : Value Component.Position -> Builder { a | position : Available } slotCaps msg kind -> Builder { a | position : Used } slotCaps msg kind
withPosition value_ =
    B.withAttribute (Component.position value_)


{-| -}
withShowDelay : Float -> Builder { a | showDelay : Available } slotCaps msg kind -> Builder { a | showDelay : Used } slotCaps msg kind
withShowDelay value_ =
    B.withAttribute (A.showDelay value_)


{-| -}
withTouchGestures : Value Component.TouchGestures -> Builder { a | touchGestures : Available } slotCaps msg kind -> Builder { a | touchGestures : Used } slotCaps msg kind
withTouchGestures value_ =
    B.withAttribute (Component.touchGestures value_)


{-| -}
withOnBeforetoggle : msg -> Builder { a | onBeforetoggle : Available } slotCaps msg kind -> Builder { a | onBeforetoggle : Used } slotCaps msg kind
withOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)
