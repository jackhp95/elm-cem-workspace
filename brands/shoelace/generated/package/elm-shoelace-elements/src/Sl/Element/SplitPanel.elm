module Sl.Element.SplitPanel exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Primary, primary
    , disabled, position, positionInPixels, snap, snapThreshold, vertical, onReposition
    )

{-| The `sl-split-panel` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Primary, primary
@docs disabled, position, positionInPixels, snap, snapThreshold, vertical, onReposition

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.SplitPanel
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-split-panel` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.SplitPanel.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.SplitPanel.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.SplitPanel.ChildAdmittedBy childAdm


{-| The `primary` values valid on this component (compile-tight narrowing).
-}
type alias Primary =
    Sl.Internal.Types.SplitPanel.Primary


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.SplitPanel.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.SplitPanel.AttrCaps


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
    H.splitPanel


{-| If no primary panel is designated, both panels will resize proportionally when the host element is resized. If a
primary panel is designated, it will maintain its size and the other panel will grow or shrink as needed when the
host element is resized.
-}
primary : Value Primary -> Attr { c | primary : Supported } msg
primary value_ =
    Ir.attribute "primary" (Val.toString value_)


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.position`.
-}
position : Float -> Attr { c | position : Supported } msg
position =
    A.position


{-| See `Sl.Attributes.positionInPixels`.
-}
positionInPixels : Float -> Attr { c | positionInPixels : Supported } msg
positionInPixels =
    A.positionInPixels


{-| See `Sl.Attributes.snap`.
-}
snap : String -> Attr { c | snap : Supported } msg
snap =
    A.snap


{-| See `Sl.Attributes.snapThreshold`.
-}
snapThreshold : Float -> Attr { c | snapThreshold : Supported } msg
snapThreshold =
    A.snapThreshold


{-| See `Sl.Attributes.vertical`.
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical =
    A.vertical


{-| See `Sl.Events.onReposition`.
-}
onReposition : msg -> Attr { c | onReposition : Supported } msg
onReposition =
    Ev.onReposition
