module Br.Build.Barren exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withCount, withId, withLabel, withSlot, withStyle, withChild)

{-| The **Barren** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Br.Component.Barren`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Br.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withCount, withId, withLabel, withSlot, withStyle, withChild

-}

import Br.Attributes as A
import Br.Component.Barren as Component
import Br.Forge.Internal as B
import Br.Kind exposing (Available, Brand, Ctx, Used)
import Br.Values
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)


{-| -}
type alias Is s =
    Component.BarrenIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.BarrenBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.BarrenAttrCaps


{-| -}
type alias SlotCaps =
    Component.BarrenSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.BarrenChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.BarrenContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "br-barren" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.BarrenIs kind) admittedBy msg
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
withCount : Float -> Builder { a | count : Available } slotCaps msg kind -> Builder { a | count : Used } slotCaps msg kind
withCount value_ =
    B.withAttribute (A.count value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)
