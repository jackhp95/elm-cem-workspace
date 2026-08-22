module M3e.Build.Ripple exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withCentered, withClass, withDisabled, withFor, withId, withRadius, withSlot, withStyle, withUnbounded)

{-| The **Ripple** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Ripple`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withCentered, withClass, withDisabled, withFor, withId, withRadius, withSlot, withStyle, withUnbounded

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Ripple as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.RippleIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.RippleBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.RippleAttrCaps


{-| -}
type alias SlotCaps =
    Component.RippleSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.RippleChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-ripple" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.RippleIs kind) admittedBy msg
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
withCentered : Bool -> Builder { a | centered : Available } slotCaps msg kind -> Builder { a | centered : Used } slotCaps msg kind
withCentered value_ =
    B.withAttribute (A.centered value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withRadius : Float -> Builder { a | radius : Available } slotCaps msg kind -> Builder { a | radius : Used } slotCaps msg kind
withRadius value_ =
    B.withAttribute (A.radius value_)


{-| -}
withUnbounded : Bool -> Builder { a | unbounded : Available } slotCaps msg kind -> Builder { a | unbounded : Used } slotCaps msg kind
withUnbounded value_ =
    B.withAttribute (A.unbounded value_)
