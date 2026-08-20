module Sl.Component.Popup exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , ArrowPlacement, arrowPlacement, AutoSize, autoSize, FlipFallbackStrategy, flipFallbackStrategy, Placement, placement, Strategy, strategy, Sync, sync
    , active, anchor, arrow, arrowPadding, autoSizePadding, autosizeboundary, distance, flip, flipFallbackPlacements, flipPadding, flipboundary, hoverBridge, shift, shiftPadding, shiftboundary, skidding, onReposition
    )

{-| The `sl-popup` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs ArrowPlacement, arrowPlacement, AutoSize, autoSize, FlipFallbackStrategy, flipFallbackStrategy, Placement, placement, Strategy, strategy, Sync, sync
@docs active, anchor, arrow, arrowPadding, autoSizePadding, autosizeboundary, distance, flip, flipFallbackPlacements, flipPadding, flipboundary, hoverBridge, shift, shiftPadding, shiftboundary, skidding, onReposition

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Popup
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-popup` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Popup.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Popup.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Popup.ChildAdmittedBy childAdm


{-| The `arrowPlacement` values valid on this component (compile-tight narrowing).
-}
type alias ArrowPlacement =
    Sl.Internal.Types.Popup.ArrowPlacement


{-| The `autoSize` values valid on this component (compile-tight narrowing).
-}
type alias AutoSize =
    Sl.Internal.Types.Popup.AutoSize


{-| The `flipFallbackStrategy` values valid on this component (compile-tight narrowing).
-}
type alias FlipFallbackStrategy =
    Sl.Internal.Types.Popup.FlipFallbackStrategy


{-| The `placement` values valid on this component (compile-tight narrowing).
-}
type alias Placement =
    Sl.Internal.Types.Popup.Placement


{-| The `strategy` values valid on this component (compile-tight narrowing).
-}
type alias Strategy =
    Sl.Internal.Types.Popup.Strategy


{-| The `sync` values valid on this component (compile-tight narrowing).
-}
type alias Sync =
    Sl.Internal.Types.Popup.Sync


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Popup.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Popup.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.popup


{-| The placement of the arrow. The default is `anchor`, which will align the arrow as close to the center of the
anchor as possible, considering available space and `arrow-padding`. A value of `start`, `end`, or `center` will
align the arrow to the start, end, or center of the popover instead. (default: `'anchor'`)
-}
arrowPlacement : Value ArrowPlacement -> Attr { c | arrowPlacement : Supported } msg
arrowPlacement value_ =
    Ir.attribute "arrow-placement" (Val.toString value_)


{-| When set, this will cause the popup to automatically resize itself to prevent it from overflowing.
-}
autoSize : Value AutoSize -> Attr { c | autoSize : Supported } msg
autoSize value_ =
    Ir.attribute "auto-size" (Val.toString value_)


{-| When neither the preferred placement nor the fallback placements fit, this value will be used to determine whether
the popup should be positioned using the best available fit based on available space or as it was initially
preferred. (default: `'best-fit'`)
-}
flipFallbackStrategy : Value FlipFallbackStrategy -> Attr { c | flipFallbackStrategy : Supported } msg
flipFallbackStrategy value_ =
    Ir.attribute "flip-fallback-strategy" (Val.toString value_)


{-| The preferred placement of the popup. Note that the actual placement will vary as configured to keep the
panel inside of the viewport. (default: `'top'`)
-}
placement : Value Placement -> Attr { c | placement : Supported } msg
placement value_ =
    Ir.attribute "placement" (Val.toString value_)


{-| Determines how the popup is positioned. The `absolute` strategy works well in most cases, but if overflow is
clipped, using a `fixed` position strategy can often workaround it. (default: `'absolute'`)
-}
strategy : Value Strategy -> Attr { c | strategy : Supported } msg
strategy value_ =
    Ir.attribute "strategy" (Val.toString value_)


{-| Syncs the popup's width or height to that of the anchor element.
-}
sync : Value Sync -> Attr { c | sync : Supported } msg
sync value_ =
    Ir.attribute "sync" (Val.toString value_)


{-| See `Sl.Attributes.active`.
-}
active : Bool -> Attr { c | active : Supported } msg
active =
    A.active


{-| See `Sl.Attributes.anchor`.
-}
anchor : String -> Attr { c | anchor : Supported } msg
anchor =
    A.anchor


{-| See `Sl.Attributes.arrow`.
-}
arrow : Bool -> Attr { c | arrow : Supported } msg
arrow =
    A.arrow


{-| See `Sl.Attributes.arrowPadding`.
-}
arrowPadding : Float -> Attr { c | arrowPadding : Supported } msg
arrowPadding =
    A.arrowPadding


{-| See `Sl.Attributes.autoSizePadding`.
-}
autoSizePadding : Float -> Attr { c | autoSizePadding : Supported } msg
autoSizePadding =
    A.autoSizePadding


{-| See `Sl.Attributes.autosizeboundary`.
-}
autosizeboundary : String -> Attr { c | autosizeboundary : Supported } msg
autosizeboundary =
    A.autosizeboundary


{-| See `Sl.Attributes.distance`.
-}
distance : Float -> Attr { c | distance : Supported } msg
distance =
    A.distance


{-| See `Sl.Attributes.flip`.
-}
flip : Bool -> Attr { c | flip : Supported } msg
flip =
    A.flip


{-| See `Sl.Attributes.flipFallbackPlacements`.
-}
flipFallbackPlacements : String -> Attr { c | flipFallbackPlacements : Supported } msg
flipFallbackPlacements =
    A.flipFallbackPlacements


{-| See `Sl.Attributes.flipPadding`.
-}
flipPadding : Float -> Attr { c | flipPadding : Supported } msg
flipPadding =
    A.flipPadding


{-| See `Sl.Attributes.flipboundary`.
-}
flipboundary : String -> Attr { c | flipboundary : Supported } msg
flipboundary =
    A.flipboundary


{-| See `Sl.Attributes.hoverBridge`.
-}
hoverBridge : Bool -> Attr { c | hoverBridge : Supported } msg
hoverBridge =
    A.hoverBridge


{-| See `Sl.Attributes.shift`.
-}
shift : Bool -> Attr { c | shift : Supported } msg
shift =
    A.shift


{-| See `Sl.Attributes.shiftPadding`.
-}
shiftPadding : Float -> Attr { c | shiftPadding : Supported } msg
shiftPadding =
    A.shiftPadding


{-| See `Sl.Attributes.shiftboundary`.
-}
shiftboundary : String -> Attr { c | shiftboundary : Supported } msg
shiftboundary =
    A.shiftboundary


{-| See `Sl.Attributes.skidding`.
-}
skidding : Float -> Attr { c | skidding : Supported } msg
skidding =
    A.skidding


{-| See `Sl.Events.onReposition`.
-}
onReposition : msg -> Attr { c | onReposition : Supported } msg
onReposition =
    Ev.onReposition
