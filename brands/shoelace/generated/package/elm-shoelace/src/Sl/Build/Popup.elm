module Sl.Build.Popup exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withActive, withAnchor, withArrow, withArrowPadding, withArrowPlacement, withAutoSize, withAutoSizePadding, withAutosizeboundary, withClass, withDistance, withFlip, withFlipFallbackPlacements, withFlipFallbackStrategy, withFlipPadding, withFlipboundary, withHoverBridge, withId, withOnReposition, withPlacement, withShift, withShiftPadding, withShiftboundary, withSkidding, withSlot, withStrategy, withStyle, withSync
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withActive, withAnchor, withArrow, withArrowPadding, withArrowPlacement, withAutoSize, withAutoSizePadding, withAutosizeboundary, withClass, withDistance, withFlip, withFlipFallbackPlacements, withFlipFallbackStrategy, withFlipPadding, withFlipboundary, withHoverBridge, withId, withOnReposition, withPlacement, withShift, withShiftPadding, withShiftboundary, withSkidding, withSlot, withStrategy, withStyle, withSync

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Component.Popup as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-popup" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
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
withActive : Bool -> Builder { a | active : Available } slotCaps msg kind -> Builder { a | active : Used } slotCaps msg kind
withActive value_ =
    B.withAttribute (A.active value_)


{-| -}
withAnchor : String -> Builder { a | anchor : Available } slotCaps msg kind -> Builder { a | anchor : Used } slotCaps msg kind
withAnchor value_ =
    B.withAttribute (A.anchor value_)


{-| -}
withArrow : Bool -> Builder { a | arrow : Available } slotCaps msg kind -> Builder { a | arrow : Used } slotCaps msg kind
withArrow value_ =
    B.withAttribute (A.arrow value_)


{-| -}
withArrowPadding : Float -> Builder { a | arrowPadding : Available } slotCaps msg kind -> Builder { a | arrowPadding : Used } slotCaps msg kind
withArrowPadding value_ =
    B.withAttribute (A.arrowPadding value_)


{-| -}
withArrowPlacement : Value Component.ArrowPlacement -> Builder { a | arrowPlacement : Available } slotCaps msg kind -> Builder { a | arrowPlacement : Used } slotCaps msg kind
withArrowPlacement value_ =
    B.withAttribute (Component.arrowPlacement value_)


{-| -}
withAutoSize : Value Component.AutoSize -> Builder { a | autoSize : Available } slotCaps msg kind -> Builder { a | autoSize : Used } slotCaps msg kind
withAutoSize value_ =
    B.withAttribute (Component.autoSize value_)


{-| -}
withAutoSizePadding : Float -> Builder { a | autoSizePadding : Available } slotCaps msg kind -> Builder { a | autoSizePadding : Used } slotCaps msg kind
withAutoSizePadding value_ =
    B.withAttribute (A.autoSizePadding value_)


{-| -}
withAutosizeboundary : String -> Builder { a | autosizeboundary : Available } slotCaps msg kind -> Builder { a | autosizeboundary : Used } slotCaps msg kind
withAutosizeboundary value_ =
    B.withAttribute (A.autosizeboundary value_)


{-| -}
withDistance : Float -> Builder { a | distance : Available } slotCaps msg kind -> Builder { a | distance : Used } slotCaps msg kind
withDistance value_ =
    B.withAttribute (A.distance value_)


{-| -}
withFlip : Bool -> Builder { a | flip : Available } slotCaps msg kind -> Builder { a | flip : Used } slotCaps msg kind
withFlip value_ =
    B.withAttribute (A.flip value_)


{-| -}
withFlipFallbackPlacements : String -> Builder { a | flipFallbackPlacements : Available } slotCaps msg kind -> Builder { a | flipFallbackPlacements : Used } slotCaps msg kind
withFlipFallbackPlacements value_ =
    B.withAttribute (A.flipFallbackPlacements value_)


{-| -}
withFlipFallbackStrategy : Value Component.FlipFallbackStrategy -> Builder { a | flipFallbackStrategy : Available } slotCaps msg kind -> Builder { a | flipFallbackStrategy : Used } slotCaps msg kind
withFlipFallbackStrategy value_ =
    B.withAttribute (Component.flipFallbackStrategy value_)


{-| -}
withFlipPadding : Float -> Builder { a | flipPadding : Available } slotCaps msg kind -> Builder { a | flipPadding : Used } slotCaps msg kind
withFlipPadding value_ =
    B.withAttribute (A.flipPadding value_)


{-| -}
withFlipboundary : String -> Builder { a | flipboundary : Available } slotCaps msg kind -> Builder { a | flipboundary : Used } slotCaps msg kind
withFlipboundary value_ =
    B.withAttribute (A.flipboundary value_)


{-| -}
withHoverBridge : Bool -> Builder { a | hoverBridge : Available } slotCaps msg kind -> Builder { a | hoverBridge : Used } slotCaps msg kind
withHoverBridge value_ =
    B.withAttribute (A.hoverBridge value_)


{-| -}
withPlacement : Value Component.Placement -> Builder { a | placement : Available } slotCaps msg kind -> Builder { a | placement : Used } slotCaps msg kind
withPlacement value_ =
    B.withAttribute (Component.placement value_)


{-| -}
withShift : Bool -> Builder { a | shift : Available } slotCaps msg kind -> Builder { a | shift : Used } slotCaps msg kind
withShift value_ =
    B.withAttribute (A.shift value_)


{-| -}
withShiftPadding : Float -> Builder { a | shiftPadding : Available } slotCaps msg kind -> Builder { a | shiftPadding : Used } slotCaps msg kind
withShiftPadding value_ =
    B.withAttribute (A.shiftPadding value_)


{-| -}
withShiftboundary : String -> Builder { a | shiftboundary : Available } slotCaps msg kind -> Builder { a | shiftboundary : Used } slotCaps msg kind
withShiftboundary value_ =
    B.withAttribute (A.shiftboundary value_)


{-| -}
withSkidding : Float -> Builder { a | skidding : Available } slotCaps msg kind -> Builder { a | skidding : Used } slotCaps msg kind
withSkidding value_ =
    B.withAttribute (A.skidding value_)


{-| -}
withStrategy : Value Component.Strategy -> Builder { a | strategy : Available } slotCaps msg kind -> Builder { a | strategy : Used } slotCaps msg kind
withStrategy value_ =
    B.withAttribute (Component.strategy value_)


{-| -}
withSync : Value Component.Sync -> Builder { a | sync : Available } slotCaps msg kind -> Builder { a | sync : Used } slotCaps msg kind
withSync value_ =
    B.withAttribute (Component.sync value_)


{-| -}
withOnReposition : msg -> Builder { a | onReposition : Available } slotCaps msg kind -> Builder { a | onReposition : Used } slotCaps msg kind
withOnReposition value_ =
    B.withAttribute (Ev.onReposition value_)
