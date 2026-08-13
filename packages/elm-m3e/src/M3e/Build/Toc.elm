module M3e.Build.Toc exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, OverlineSlot, TitleSlot, ChildAdmittedBy
    , withClass, withFor, withId, withMaxDepth, withSlot, withStyle
    , overline, title
    , withOverline, withTitle, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, OverlineSlot, TitleSlot, ChildAdmittedBy
@docs withClass, withFor, withId, withMaxDepth, withSlot, withStyle
@docs overline, title
@docs withOverline, withTitle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Toc as Component
import M3e.Internal.Types.Toc
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.Toc.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Toc.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.Toc.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.Toc.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Toc.ChildAdmittedBy childAdm


{-| -}
type alias OverlineSlot =
    M3e.Internal.Types.Toc.OverlineSlot


{-| -}
type alias TitleSlot =
    M3e.Internal.Types.Toc.TitleSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-toc" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
overline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OverlineSlot msg
    -> Element free freeAdmittedBy msg
overline builder =
    Component.overline (B.toElement builder)


{-| -}
title :
    B.Builder childRow childAttrCaps childSlotCaps Component.TitleSlot msg
    -> Element free freeAdmittedBy msg
title builder =
    Component.title (B.toElement builder)


{-| -}
withOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OverlineSlot msg
    -> Builder attrCaps { s | overline : Available } msg kind
    -> Builder attrCaps { s | overline : Used } msg kind
withOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.overline (B.toElement slotBuilder))) builder_


{-| -}
withTitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.TitleSlot msg
    -> Builder attrCaps { s | title : Available } msg kind
    -> Builder attrCaps { s | title : Used } msg kind
withTitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.title (B.toElement slotBuilder))) builder_


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
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withMaxDepth : Float -> Builder { a | maxDepth : Available } slotCaps msg kind -> Builder { a | maxDepth : Used } slotCaps msg kind
withMaxDepth value_ =
    B.withAttribute (A.maxDepth value_)
