module Sl.Build.SplitPanel exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withOnReposition, withPosition, withPositionInPixels, withPrimary, withSlot, withSnap, withSnapThreshold, withStyle, withVertical)

{-| The **SplitPanel** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.SplitPanel`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withOnReposition, withPosition, withPositionInPixels, withPrimary, withSlot, withSnap, withSnapThreshold, withStyle, withVertical

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.SplitPanel as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.SplitPanelIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SplitPanelBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SplitPanelAttrCaps


{-| -}
type alias SlotCaps =
    Component.SplitPanelSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SplitPanelChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-split-panel" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SplitPanelIs kind) admittedBy msg
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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withPosition : Float -> Builder { a | position : Available } slotCaps msg kind -> Builder { a | position : Used } slotCaps msg kind
withPosition value_ =
    B.withAttribute (A.position value_)


{-| -}
withPositionInPixels : Float -> Builder { a | positionInPixels : Available } slotCaps msg kind -> Builder { a | positionInPixels : Used } slotCaps msg kind
withPositionInPixels value_ =
    B.withAttribute (A.positionInPixels value_)


{-| -}
withPrimary : Value Component.SplitPanelPrimary -> Builder { a | primary : Available } slotCaps msg kind -> Builder { a | primary : Used } slotCaps msg kind
withPrimary value_ =
    B.withAttribute (Component.splitPanelPrimary value_)


{-| -}
withSnap : String -> Builder { a | snap : Available } slotCaps msg kind -> Builder { a | snap : Used } slotCaps msg kind
withSnap value_ =
    B.withAttribute (A.snap value_)


{-| -}
withSnapThreshold : Float -> Builder { a | snapThreshold : Available } slotCaps msg kind -> Builder { a | snapThreshold : Used } slotCaps msg kind
withSnapThreshold value_ =
    B.withAttribute (A.snapThreshold value_)


{-| -}
withVertical : Bool -> Builder { a | vertical : Available } slotCaps msg kind -> Builder { a | vertical : Used } slotCaps msg kind
withVertical value_ =
    B.withAttribute (A.vertical value_)


{-| -}
withOnReposition : msg -> Builder { a | onReposition : Available } slotCaps msg kind -> Builder { a | onReposition : Used } slotCaps msg kind
withOnReposition value_ =
    B.withAttribute (Ev.onReposition value_)
