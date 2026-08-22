module Sl.Build.Drawer exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withContained, withId, withLabel, withNoHeader, withOnAfterHide, withOnAfterShow, withOnHide, withOnInitialFocus, withOnRequestClose, withOnShow, withOpen, withPlacement, withSlot, withStyle)

{-| The **Drawer** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Drawer`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withContained, withId, withLabel, withNoHeader, withOnAfterHide, withOnAfterShow, withOnHide, withOnInitialFocus, withOnRequestClose, withOnShow, withOpen, withPlacement, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Drawer as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.DrawerIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.DrawerBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.DrawerAttrCaps


{-| -}
type alias SlotCaps =
    Component.DrawerSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.DrawerChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-drawer" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.DrawerIs kind) admittedBy msg
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
withContained : Bool -> Builder { a | contained : Available } slotCaps msg kind -> Builder { a | contained : Used } slotCaps msg kind
withContained value_ =
    B.withAttribute (A.contained value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withNoHeader : Bool -> Builder { a | noHeader : Available } slotCaps msg kind -> Builder { a | noHeader : Used } slotCaps msg kind
withNoHeader value_ =
    B.withAttribute (A.noHeader value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withPlacement : Value Component.DrawerPlacement -> Builder { a | placement : Available } slotCaps msg kind -> Builder { a | placement : Used } slotCaps msg kind
withPlacement value_ =
    B.withAttribute (Component.drawerPlacement value_)


{-| -}
withOnShow : msg -> Builder { a | onShow : Available } slotCaps msg kind -> Builder { a | onShow : Used } slotCaps msg kind
withOnShow value_ =
    B.withAttribute (Ev.onShow value_)


{-| -}
withOnAfterShow : msg -> Builder { a | onAfterShow : Available } slotCaps msg kind -> Builder { a | onAfterShow : Used } slotCaps msg kind
withOnAfterShow value_ =
    B.withAttribute (Ev.onAfterShow value_)


{-| -}
withOnHide : msg -> Builder { a | onHide : Available } slotCaps msg kind -> Builder { a | onHide : Used } slotCaps msg kind
withOnHide value_ =
    B.withAttribute (Ev.onHide value_)


{-| -}
withOnAfterHide : msg -> Builder { a | onAfterHide : Available } slotCaps msg kind -> Builder { a | onAfterHide : Used } slotCaps msg kind
withOnAfterHide value_ =
    B.withAttribute (Ev.onAfterHide value_)


{-| -}
withOnInitialFocus : msg -> Builder { a | onInitialFocus : Available } slotCaps msg kind -> Builder { a | onInitialFocus : Used } slotCaps msg kind
withOnInitialFocus value_ =
    B.withAttribute (Ev.onInitialFocus value_)


{-| -}
withOnRequestClose : msg -> Builder { a | onRequestClose : Available } slotCaps msg kind -> Builder { a | onRequestClose : Used } slotCaps msg kind
withOnRequestClose value_ =
    B.withAttribute (Ev.onRequestClose value_)
