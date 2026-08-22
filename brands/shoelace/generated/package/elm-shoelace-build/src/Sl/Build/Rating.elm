module Sl.Build.Rating exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisabled, withGetsymbol, withId, withLabel, withMax, withOnChange, withOnHover, withPrecision, withReadonly, withSlot, withStyle, withValue)

{-| The **Rating** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Rating`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisabled, withGetsymbol, withId, withLabel, withMax, withOnChange, withOnHover, withPrecision, withReadonly, withSlot, withStyle, withValue

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Component.Rating as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.RatingIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.RatingBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.RatingAttrCaps


{-| -}
type alias SlotCaps =
    Component.RatingSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.RatingChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-rating" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.RatingIs kind) admittedBy msg
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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withGetsymbol : String -> Builder { a | getsymbol : Available } slotCaps msg kind -> Builder { a | getsymbol : Used } slotCaps msg kind
withGetsymbol value_ =
    B.withAttribute (A.getsymbol value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withMax : Float -> Builder { a | max : Available } slotCaps msg kind -> Builder { a | max : Used } slotCaps msg kind
withMax value_ =
    B.withAttribute (Ir.attribute "max" (String.fromFloat value_))


{-| -}
withPrecision : Float -> Builder { a | precision : Available } slotCaps msg kind -> Builder { a | precision : Used } slotCaps msg kind
withPrecision value_ =
    B.withAttribute (A.precision value_)


{-| -}
withReadonly : Bool -> Builder { a | readonly : Available } slotCaps msg kind -> Builder { a | readonly : Used } slotCaps msg kind
withReadonly value_ =
    B.withAttribute (A.readonly value_)


{-| -}
withValue : Float -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (Ir.property "value" (Json.Encode.float value_))


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnHover : msg -> Builder { a | onHover : Available } slotCaps msg kind -> Builder { a | onHover : Used } slotCaps msg kind
withOnHover value_ =
    B.withAttribute (Ev.onHover value_)
