module M3e.Build.AppBar exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy
    , withCentered, withClass, withFor, withId, withSize, withSlot, withStyle
    , leading, leadingIcon, subtitle, title, trailing, trailingIcon
    , withLeadingIcon, withSubtitle, withTitle, withTrailingIcon, withLeading, withTrailing
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy
@docs withCentered, withClass, withFor, withId, withSize, withSlot, withStyle
@docs leading, leadingIcon, subtitle, title, trailing, trailingIcon
@docs withLeadingIcon, withSubtitle, withTitle, withTrailingIcon, withLeading, withTrailing

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Component.AppBar as Component
import M3e.Forge.Internal as B
import M3e.Internal.Types.AppBar
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.AppBar.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.AppBar.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.AppBar.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.AppBar.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.AppBar.ChildAdmittedBy childAdm


{-| -}
type alias LeadingSlot =
    M3e.Internal.Types.AppBar.LeadingSlot


{-| -}
type alias SubtitleSlot =
    M3e.Internal.Types.AppBar.SubtitleSlot


{-| -}
type alias TitleSlot =
    M3e.Internal.Types.AppBar.TitleSlot


{-| -}
type alias TrailingSlot =
    M3e.Internal.Types.AppBar.TrailingSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-app-bar" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.leading (B.toElement builder)


{-| -}
leadingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
leadingIcon builder =
    Component.leadingIcon (B.toElement builder)


{-| -}
subtitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubtitleSlot msg
    -> Element free freeAdmittedBy msg
subtitle builder =
    Component.subtitle (B.toElement builder)


{-| -}
title :
    B.Builder childRow childAttrCaps childSlotCaps Component.TitleSlot msg
    -> Element free freeAdmittedBy msg
title builder =
    Component.title (B.toElement builder)


{-| -}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.trailing (B.toElement builder)


{-| -}
trailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
trailingIcon builder =
    Component.trailingIcon (B.toElement builder)


{-| -}
withLeadingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | leadingIcon : Available } msg kind
    -> Builder attrCaps { s | leadingIcon : Used } msg kind
withLeadingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.leadingIcon (B.toElement slotBuilder))) builder_


{-| -}
withSubtitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.SubtitleSlot msg
    -> Builder attrCaps { s | subtitle : Available } msg kind
    -> Builder attrCaps { s | subtitle : Used } msg kind
withSubtitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.subtitle (B.toElement slotBuilder))) builder_


{-| -}
withTitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.TitleSlot msg
    -> Builder attrCaps { s | title : Available } msg kind
    -> Builder attrCaps { s | title : Used } msg kind
withTitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.title (B.toElement slotBuilder))) builder_


{-| -}
withTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | trailingIcon : Available } msg kind
    -> Builder attrCaps { s | trailingIcon : Used } msg kind
withTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.trailingIcon (B.toElement slotBuilder))) builder_


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.leading (B.toElement slotBuilder))) builder_


{-| -}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.trailing (B.toElement slotBuilder))) builder_


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
withCentered : Bool -> Builder { a | centered : Available } slotCaps msg kind -> Builder { a | centered : Used } slotCaps msg kind
withCentered value_ =
    B.withAttribute (A.centered value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)
