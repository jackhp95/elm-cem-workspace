module M3e.Build.SlideGroup exposing (Builder, AttrCaps, SlotCaps, Is, NextIconSlot, PrevIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withNextPageLabel, withPreviousPageLabel, withSlot, withStyle, withThreshold, withVertical, nextIcon, prevIcon, withNextIcon, withPrevIcon, withChild)

{-| The **SlideGroup** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.SlideGroup`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, NextIconSlot, PrevIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withNextPageLabel, withPreviousPageLabel, withSlot, withStyle, withThreshold, withVertical, nextIcon, prevIcon, withNextIcon, withPrevIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.SlideGroup as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.SlideGroupIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SlideGroupBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SlideGroupAttrCaps


{-| -}
type alias SlotCaps =
    Component.SlideGroupSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SlideGroupChildAdmittedBy childAdm


{-| -}
type alias NextIconSlot =
    Component.SlideGroupNextIconSlot


{-| -}
type alias PrevIconSlot =
    Component.SlideGroupPrevIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-slide-group" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SlideGroupIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
nextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SlideGroupNextIconSlot msg
    -> Element free freeAdmittedBy msg
nextIcon builder =
    Component.slideGroupNextIcon (B.toElement builder)


{-| -}
prevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SlideGroupPrevIconSlot msg
    -> Element free freeAdmittedBy msg
prevIcon builder =
    Component.slideGroupPrevIcon (B.toElement builder)


{-| -}
withNextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SlideGroupNextIconSlot msg
    -> Builder attrCaps { s | nextIcon : Available } msg kind
    -> Builder attrCaps { s | nextIcon : Used } msg kind
withNextIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.slideGroupNextIcon (B.toElement slotBuilder))) builder_


{-| -}
withPrevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SlideGroupPrevIconSlot msg
    -> Builder attrCaps { s | prevIcon : Available } msg kind
    -> Builder attrCaps { s | prevIcon : Used } msg kind
withPrevIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.slideGroupPrevIcon (B.toElement slotBuilder))) builder_


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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withNextPageLabel : String -> Builder { a | nextPageLabel : Available } slotCaps msg kind -> Builder { a | nextPageLabel : Used } slotCaps msg kind
withNextPageLabel value_ =
    B.withAttribute (A.nextPageLabel value_)


{-| -}
withPreviousPageLabel : String -> Builder { a | previousPageLabel : Available } slotCaps msg kind -> Builder { a | previousPageLabel : Used } slotCaps msg kind
withPreviousPageLabel value_ =
    B.withAttribute (A.previousPageLabel value_)


{-| -}
withThreshold : Float -> Builder { a | threshold : Available } slotCaps msg kind -> Builder { a | threshold : Used } slotCaps msg kind
withThreshold value_ =
    B.withAttribute (A.threshold value_)


{-| -}
withVertical : Bool -> Builder { a | vertical : Available } slotCaps msg kind -> Builder { a | vertical : Used } slotCaps msg kind
withVertical value_ =
    B.withAttribute (A.vertical value_)
