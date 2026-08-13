module M3e.Build.DrawerContainer exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withEnd, withEndDivider, withEndMode, withId, withOnChange, withSlot, withStart, withStartDivider, withStartMode, withStyle
    , end, start
    , withEndSlot, withStartSlot, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withEnd, withEndDivider, withEndMode, withId, withOnChange, withSlot, withStart, withStartDivider, withStartMode, withStyle
@docs end, start
@docs withEndSlot, withStartSlot, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.DrawerContainer as Component
import M3e.Events as Ev
import M3e.Internal.Types.DrawerContainer
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.DrawerContainer.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.DrawerContainer.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.DrawerContainer.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.DrawerContainer.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.DrawerContainer.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-drawer-container" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
end :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
end builder =
    Component.end (B.toElement builder)


{-| -}
start :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
start builder =
    Component.start (B.toElement builder)


{-| -}
withEndSlot :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | end : Available } msg kind
    -> Builder attrCaps { s | end : Used } msg kind
withEndSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.end (B.toElement slotBuilder))) builder_


{-| -}
withStartSlot :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | start : Available } msg kind
    -> Builder attrCaps { s | start : Used } msg kind
withStartSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.start (B.toElement slotBuilder))) builder_


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
withEnd : Bool -> Builder { a | end : Available } slotCaps msg kind -> Builder { a | end : Used } slotCaps msg kind
withEnd value_ =
    B.withAttribute (A.end value_)


{-| -}
withEndDivider : Bool -> Builder { a | endDivider : Available } slotCaps msg kind -> Builder { a | endDivider : Used } slotCaps msg kind
withEndDivider value_ =
    B.withAttribute (A.endDivider value_)


{-| -}
withEndMode : Value Component.EndMode -> Builder { a | endMode : Available } slotCaps msg kind -> Builder { a | endMode : Used } slotCaps msg kind
withEndMode value_ =
    B.withAttribute (Component.endMode value_)


{-| -}
withStart : Bool -> Builder { a | start : Available } slotCaps msg kind -> Builder { a | start : Used } slotCaps msg kind
withStart value_ =
    B.withAttribute (A.start value_)


{-| -}
withStartDivider : Bool -> Builder { a | startDivider : Available } slotCaps msg kind -> Builder { a | startDivider : Used } slotCaps msg kind
withStartDivider value_ =
    B.withAttribute (A.startDivider value_)


{-| -}
withStartMode : Value Component.StartMode -> Builder { a | startMode : Available } slotCaps msg kind -> Builder { a | startMode : Used } slotCaps msg kind
withStartMode value_ =
    B.withAttribute (Component.startMode value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)
