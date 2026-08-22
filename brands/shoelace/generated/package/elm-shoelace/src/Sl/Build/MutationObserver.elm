module Sl.Build.MutationObserver exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAttr, withAttrOldValue, withCharData, withCharDataOldValue, withChildList, withClass, withDisabled, withId, withOnMutation, withSlot, withStyle, withChild)

{-| The **MutationObserver** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.MutationObserver`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAttr, withAttrOldValue, withCharData, withCharDataOldValue, withChildList, withClass, withDisabled, withId, withOnMutation, withSlot, withStyle, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.MutationObserver as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.MutationObserverIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.MutationObserverBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.MutationObserverAttrCaps


{-| -}
type alias SlotCaps =
    Component.MutationObserverSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.MutationObserverChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-mutation-observer" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.MutationObserverIs kind) admittedBy msg
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
withAttr : String -> Builder { a | attr : Available } slotCaps msg kind -> Builder { a | attr : Used } slotCaps msg kind
withAttr value_ =
    B.withAttribute (A.attr value_)


{-| -}
withAttrOldValue : Bool -> Builder { a | attrOldValue : Available } slotCaps msg kind -> Builder { a | attrOldValue : Used } slotCaps msg kind
withAttrOldValue value_ =
    B.withAttribute (A.attrOldValue value_)


{-| -}
withCharData : Bool -> Builder { a | charData : Available } slotCaps msg kind -> Builder { a | charData : Used } slotCaps msg kind
withCharData value_ =
    B.withAttribute (A.charData value_)


{-| -}
withCharDataOldValue : Bool -> Builder { a | charDataOldValue : Available } slotCaps msg kind -> Builder { a | charDataOldValue : Used } slotCaps msg kind
withCharDataOldValue value_ =
    B.withAttribute (A.charDataOldValue value_)


{-| -}
withChildList : Bool -> Builder { a | childList : Available } slotCaps msg kind -> Builder { a | childList : Used } slotCaps msg kind
withChildList value_ =
    B.withAttribute (A.childList value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withOnMutation : msg -> Builder { a | onMutation : Available } slotCaps msg kind -> Builder { a | onMutation : Used } slotCaps msg kind
withOnMutation value_ =
    B.withAttribute (Ev.onMutation value_)
