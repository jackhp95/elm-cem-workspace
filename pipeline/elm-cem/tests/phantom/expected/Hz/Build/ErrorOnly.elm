module Hz.Build.ErrorOnly exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withOnHzError, withSlot, withStyle)

{-| The **ErrorOnly** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Hz.Component.ErrorOnly`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Hz.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withOnHzError, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Hz.Attributes as A
import Hz.Component.ErrorOnly as Component
import Hz.Events as Ev
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)
import Hz.Values


{-| -}
type alias Is s =
    Component.ErrorOnlyIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ErrorOnlyBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ErrorOnlyAttrCaps


{-| -}
type alias SlotCaps =
    Component.ErrorOnlySlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ErrorOnlyChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "hz-error-only" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ErrorOnlyIs kind) admittedBy msg
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
withOnHzError : msg -> Builder { a | onHzError : Available } slotCaps msg kind -> Builder { a | onHzError : Used } slotCaps msg kind
withOnHzError value_ =
    B.withAttribute (Ev.onHzError value_)
