module Sl.Build.QrCode exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withBackground, withClass, withErrorCorrection, withFill, withId, withLabel, withRadius, withSize, withSlot, withStyle, withValue)

{-| The **QrCode** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.QrCode`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withBackground, withClass, withErrorCorrection, withFill, withId, withLabel, withRadius, withSize, withSlot, withStyle, withValue

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Component.QrCode as Component
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.QrCodeIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.QrCodeBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.QrCodeAttrCaps


{-| -}
type alias SlotCaps =
    Component.QrCodeSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.QrCodeChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-qr-code" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.QrCodeIs kind) admittedBy msg
toElement =
    B.toElement


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
withBackground : String -> Builder { a | background : Available } slotCaps msg kind -> Builder { a | background : Used } slotCaps msg kind
withBackground value_ =
    B.withAttribute (A.background value_)


{-| -}
withErrorCorrection : Value Component.QrCodeErrorCorrection -> Builder { a | errorCorrection : Available } slotCaps msg kind -> Builder { a | errorCorrection : Used } slotCaps msg kind
withErrorCorrection value_ =
    B.withAttribute (Component.qrCodeErrorCorrection value_)


{-| -}
withFill : String -> Builder { a | fill : Available } slotCaps msg kind -> Builder { a | fill : Used } slotCaps msg kind
withFill value_ =
    B.withAttribute (A.fill value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withRadius : Float -> Builder { a | radius : Available } slotCaps msg kind -> Builder { a | radius : Used } slotCaps msg kind
withRadius value_ =
    B.withAttribute (A.radius value_)


{-| -}
withSize : Float -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Ir.attribute "size" (String.fromFloat value_))


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)
