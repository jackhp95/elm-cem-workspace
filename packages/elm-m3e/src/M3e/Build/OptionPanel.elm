module M3e.Build.OptionPanel exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, LoadingSlot, ChildAdmittedBy
    , withAnchorOffset, withClass, withFitAnchorWidth, withId, withOnBeforetoggle, withOnToggle, withScrollStrategy, withSlot, withState, withStyle
    , loading, noData
    , withNoData, withLoading, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, LoadingSlot, ChildAdmittedBy
@docs withAnchorOffset, withClass, withFitAnchorWidth, withId, withOnBeforetoggle, withOnToggle, withScrollStrategy, withSlot, withState, withStyle
@docs loading, noData
@docs withNoData, withLoading, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Component.OptionPanel as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    Component.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.Content


{-| -}
type alias LoadingSlot =
    Component.LoadingSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-option-panel" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
loading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LoadingSlot msg
    -> Element free freeAdmittedBy msg
loading builder =
    Component.loading (B.toElement builder)


{-| -}
noData :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
noData builder =
    Component.noData (B.toElement builder)


{-| -}
withNoData :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | noData : Available } msg kind
    -> Builder attrCaps { s | noData : Used } msg kind
withNoData slotBuilder builder_ =
    B.withChild (El.toNode (Component.noData (B.toElement slotBuilder))) builder_


{-| -}
withLoading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LoadingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withLoading slotBuilder builder_ =
    B.withChild (El.toNode (Component.loading (B.toElement slotBuilder))) builder_


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
withAnchorOffset : Float -> Builder { a | anchorOffset : Available } slotCaps msg kind -> Builder { a | anchorOffset : Used } slotCaps msg kind
withAnchorOffset value_ =
    B.withAttribute (A.anchorOffset value_)


{-| -}
withFitAnchorWidth : Bool -> Builder { a | fitAnchorWidth : Available } slotCaps msg kind -> Builder { a | fitAnchorWidth : Used } slotCaps msg kind
withFitAnchorWidth value_ =
    B.withAttribute (A.fitAnchorWidth value_)


{-| -}
withScrollStrategy : Value Component.ScrollStrategy -> Builder { a | scrollStrategy : Available } slotCaps msg kind -> Builder { a | scrollStrategy : Used } slotCaps msg kind
withScrollStrategy value_ =
    B.withAttribute (Component.scrollStrategy value_)


{-| -}
withState : Value Component.State -> Builder { a | state : Available } slotCaps msg kind -> Builder { a | state : Used } slotCaps msg kind
withState value_ =
    B.withAttribute (Component.state value_)


{-| -}
withOnBeforetoggle : msg -> Builder { a | onBeforetoggle : Available } slotCaps msg kind -> Builder { a | onBeforetoggle : Used } slotCaps msg kind
withOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)
