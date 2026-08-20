module Sl.Build.RelativeTime exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDate, withFormat, withId, withNumeric, withSlot, withStyle, withSync
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDate, withFormat, withId, withNumeric, withSlot, withStyle, withSync

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Component.RelativeTime as Component
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


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
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-relative-time" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
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
withDate : String -> Builder { a | date : Available } slotCaps msg kind -> Builder { a | date : Used } slotCaps msg kind
withDate value_ =
    B.withAttribute (A.date value_)


{-| -}
withFormat : Value Component.Format -> Builder { a | format : Available } slotCaps msg kind -> Builder { a | format : Used } slotCaps msg kind
withFormat value_ =
    B.withAttribute (Component.format value_)


{-| -}
withNumeric : Value Component.Numeric -> Builder { a | numeric : Available } slotCaps msg kind -> Builder { a | numeric : Used } slotCaps msg kind
withNumeric value_ =
    B.withAttribute (Component.numeric value_)


{-| -}
withSync : Bool -> Builder { a | sync : Available } slotCaps msg kind -> Builder { a | sync : Used } slotCaps msg kind
withSync value_ =
    B.withAttribute
        (if value_ then
            Ir.attribute "sync" ""

         else
            Ir.none
        )
