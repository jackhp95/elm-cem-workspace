module Hz.Build.Duplicate exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, withValue, withChild)

{-| The **Duplicate** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Hz.Component.Duplicate`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Hz.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withSlot, withStyle, withValue, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Hz.Attributes as A
import Hz.Component.Duplicate as Component
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)
import Hz.Values


{-| -}
type alias Is s =
    Component.DuplicateIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.DuplicateBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.DuplicateAttrCaps


{-| -}
type alias SlotCaps =
    Component.DuplicateSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.DuplicateChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.DuplicateContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "hz-duplicate" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.DuplicateIs kind) admittedBy msg
toElement =
    B.toElement


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
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)
