module Sl.Build.Tree exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withOnSelectionChange, withSelection, withSlot, withStyle, withChild)

{-| The **Tree** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Tree`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withId, withOnSelectionChange, withSelection, withSlot, withStyle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Tree as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.TreeIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.TreeBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.TreeAttrCaps


{-| -}
type alias SlotCaps =
    Component.TreeSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.TreeChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.TreeContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-tree" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.TreeIs kind) admittedBy msg
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
withSelection : Value Component.TreeSelection -> Builder { a | selection : Available } slotCaps msg kind -> Builder { a | selection : Used } slotCaps msg kind
withSelection value_ =
    B.withAttribute (Component.treeSelection value_)


{-| -}
withOnSelectionChange : msg -> Builder { a | onSelectionChange : Available } slotCaps msg kind -> Builder { a | onSelectionChange : Used } slotCaps msg kind
withOnSelectionChange value_ =
    B.withAttribute (Ev.onSelectionChange value_)
