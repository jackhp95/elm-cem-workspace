module Sl.Build.Tab exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withActive, withClass, withClosable, withDisabled, withId, withOnClose, withPanel, withSlot, withStyle, withChild)

{-| The **Tab** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Tab`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withActive, withClass, withClosable, withDisabled, withId, withOnClose, withPanel, withSlot, withStyle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Tab as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.TabIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.TabBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.TabAttrCaps


{-| -}
type alias SlotCaps =
    Component.TabSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.TabChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.TabContent


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-tab" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.TabIs kind) admittedBy msg
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
withActive : Bool -> Builder { a | active : Available } slotCaps msg kind -> Builder { a | active : Used } slotCaps msg kind
withActive value_ =
    B.withAttribute (A.active value_)


{-| -}
withClosable : Bool -> Builder { a | closable : Available } slotCaps msg kind -> Builder { a | closable : Used } slotCaps msg kind
withClosable value_ =
    B.withAttribute (A.closable value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withPanel : String -> Builder { a | panel : Available } slotCaps msg kind -> Builder { a | panel : Used } slotCaps msg kind
withPanel value_ =
    B.withAttribute (A.panel value_)


{-| -}
withOnClose : msg -> Builder { a | onClose : Available } slotCaps msg kind -> Builder { a | onClose : Used } slotCaps msg kind
withOnClose value_ =
    B.withAttribute (Ev.onClose value_)
