module Sl.Build.Menu exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withOnSelect, withSlot, withStyle)

{-| The **Menu** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Menu`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withOnSelect, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Menu as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.MenuIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.MenuBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.MenuAttrCaps


{-| -}
type alias SlotCaps =
    Component.MenuSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.MenuChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-menu" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.MenuIs kind) admittedBy msg
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
withOnSelect : msg -> Builder { a | onSelect : Available } slotCaps msg kind -> Builder { a | onSelect : Used } slotCaps msg kind
withOnSelect value_ =
    B.withAttribute (Ev.onSelect value_)
