module Sl.Build.Tag exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withOnRemove, withPill, withRemovable, withSize, withSlot, withStyle, withVariant, withChild)

{-| The **Tag** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Tag`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withOnRemove, withPill, withRemovable, withSize, withSlot, withStyle, withVariant, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Tag as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.TagIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.TagBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.TagAttrCaps


{-| -}
type alias SlotCaps =
    Component.TagSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.TagChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-tag" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.TagIs kind) admittedBy msg
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
withPill : Bool -> Builder { a | pill : Available } slotCaps msg kind -> Builder { a | pill : Used } slotCaps msg kind
withPill value_ =
    B.withAttribute (A.pill value_)


{-| -}
withRemovable : Bool -> Builder { a | removable : Available } slotCaps msg kind -> Builder { a | removable : Used } slotCaps msg kind
withRemovable value_ =
    B.withAttribute (A.removable value_)


{-| -}
withSize : Value Component.TagSize -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.tagSize value_)


{-| -}
withVariant : Value Component.TagVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.tagVariant value_)


{-| -}
withOnRemove : msg -> Builder { a | onRemove : Available } slotCaps msg kind -> Builder { a | onRemove : Used } slotCaps msg kind
withOnRemove value_ =
    B.withAttribute (Ev.onRemove value_)
