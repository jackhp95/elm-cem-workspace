module M3e.Build.SlideGroup exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, NextIconSlot, PrevIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withId, withNextPageLabel, withPreviousPageLabel, withSlot, withStyle, withThreshold, withVertical
    , nextIcon, prevIcon
    , withNextIcon, withPrevIcon, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, NextIconSlot, PrevIconSlot, ChildAdmittedBy
@docs withClass, withDisabled, withId, withNextPageLabel, withPreviousPageLabel, withSlot, withStyle, withThreshold, withVertical
@docs nextIcon, prevIcon
@docs withNextIcon, withPrevIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.SlideGroup as Component
import M3e.Internal.Types.SlideGroup
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.SlideGroup.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SlideGroup.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.SlideGroup.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.SlideGroup.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SlideGroup.ChildAdmittedBy childAdm


{-| -}
type alias NextIconSlot =
    M3e.Internal.Types.SlideGroup.NextIconSlot


{-| -}
type alias PrevIconSlot =
    M3e.Internal.Types.SlideGroup.PrevIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-slide-group" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
nextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextIconSlot msg
    -> Element free freeAdmittedBy msg
nextIcon builder =
    Component.nextIcon (B.toElement builder)


{-| -}
prevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PrevIconSlot msg
    -> Element free freeAdmittedBy msg
prevIcon builder =
    Component.prevIcon (B.toElement builder)


{-| -}
withNextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextIconSlot msg
    -> Builder attrCaps { s | nextIcon : Available } msg kind
    -> Builder attrCaps { s | nextIcon : Used } msg kind
withNextIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.nextIcon (B.toElement slotBuilder))) builder_


{-| -}
withPrevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PrevIconSlot msg
    -> Builder attrCaps { s | prevIcon : Available } msg kind
    -> Builder attrCaps { s | prevIcon : Used } msg kind
withPrevIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.prevIcon (B.toElement slotBuilder))) builder_


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
