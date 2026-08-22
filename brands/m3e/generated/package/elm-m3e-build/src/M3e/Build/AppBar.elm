module M3e.Build.AppBar exposing (Builder, AttrCaps, SlotCaps, Is, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withCentered, withClass, withFor, withId, withSize, withSlot, withStyle, leading, leadingIcon, subtitle, title, trailing, trailingIcon, withLeadingIcon, withSubtitle, withTitle, withTrailingIcon, withLeading, withTrailing)

{-| The **AppBar** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.AppBar`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, LeadingSlot, SubtitleSlot, TitleSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withCentered, withClass, withFor, withId, withSize, withSlot, withStyle, leading, leadingIcon, subtitle, title, trailing, trailingIcon, withLeadingIcon, withSubtitle, withTitle, withTrailingIcon, withLeading, withTrailing

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.AppBar as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.AppBarIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.AppBarBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AppBarAttrCaps


{-| -}
type alias SlotCaps =
    Component.AppBarSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.AppBarChildAdmittedBy childAdm


{-| -}
type alias LeadingSlot =
    Component.AppBarLeadingSlot


{-| -}
type alias SubtitleSlot =
    Component.AppBarSubtitleSlot


{-| -}
type alias TitleSlot =
    Component.AppBarTitleSlot


{-| -}
type alias TrailingSlot =
    Component.AppBarTrailingSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-app-bar" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.AppBarIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.AppBarLeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.appBarLeading (B.toElement builder)


{-| -}
leadingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
leadingIcon builder =
    Component.appBarLeadingIcon (B.toElement builder)


{-| -}
subtitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.AppBarSubtitleSlot msg
    -> Element free freeAdmittedBy msg
subtitle builder =
    Component.appBarSubtitle (B.toElement builder)


{-| -}
title :
    B.Builder childRow childAttrCaps childSlotCaps Component.AppBarTitleSlot msg
    -> Element free freeAdmittedBy msg
title builder =
    Component.appBarTitle (B.toElement builder)


{-| -}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.AppBarTrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.appBarTrailing (B.toElement builder)


{-| -}
trailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
trailingIcon builder =
    Component.appBarTrailingIcon (B.toElement builder)


{-| -}
withLeadingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | leadingIcon : Available } msg kind
    -> Builder attrCaps { s | leadingIcon : Used } msg kind
withLeadingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.appBarLeadingIcon (B.toElement slotBuilder))) builder_


{-| -}
withSubtitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.AppBarSubtitleSlot msg
    -> Builder attrCaps { s | subtitle : Available } msg kind
    -> Builder attrCaps { s | subtitle : Used } msg kind
withSubtitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.appBarSubtitle (B.toElement slotBuilder))) builder_


{-| -}
withTitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.AppBarTitleSlot msg
    -> Builder attrCaps { s | title : Available } msg kind
    -> Builder attrCaps { s | title : Used } msg kind
withTitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.appBarTitle (B.toElement slotBuilder))) builder_


{-| -}
withTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | trailingIcon : Available } msg kind
    -> Builder attrCaps { s | trailingIcon : Used } msg kind
withTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.appBarTrailingIcon (B.toElement slotBuilder))) builder_


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.AppBarLeadingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.appBarLeading (B.toElement slotBuilder))) builder_


{-| -}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.AppBarTrailingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.appBarTrailing (B.toElement slotBuilder))) builder_


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
withSize : Value Component.AppBarSize -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.appBarSize value_)
