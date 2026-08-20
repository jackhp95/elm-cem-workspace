module Sl.Component.CopyButton exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , TooltipPlacement, tooltipPlacement
    , copyLabel, disabled, errorLabel, feedbackDuration, from, hoist, successLabel, value, defaultValue, onCopy, onError
    )

{-| The `sl-copy-button` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs TooltipPlacement, tooltipPlacement
@docs copyLabel, disabled, errorLabel, feedbackDuration, from, hoist, successLabel, value, defaultValue, onCopy, onError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.CopyButton
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-copy-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.CopyButton.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.CopyButton.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.CopyButton.ChildAdmittedBy childAdm


{-| The `tooltipPlacement` values valid on this component (compile-tight narrowing).
-}
type alias TooltipPlacement =
    Sl.Internal.Types.CopyButton.TooltipPlacement


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.CopyButton.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.CopyButton.AttrCaps


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
    H.copyButton


{-| The preferred placement of the tooltip. (default: `'top'`)
-}
tooltipPlacement : Value TooltipPlacement -> Attr { c | tooltipPlacement : Supported } msg
tooltipPlacement value_ =
    Ir.attribute "tooltip-placement" (Val.toString value_)


{-| See `Sl.Attributes.copyLabel`.
-}
copyLabel : String -> Attr { c | copyLabel : Supported } msg
copyLabel =
    A.copyLabel


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.errorLabel`.
-}
errorLabel : String -> Attr { c | errorLabel : Supported } msg
errorLabel =
    A.errorLabel


{-| See `Sl.Attributes.feedbackDuration`.
-}
feedbackDuration : Float -> Attr { c | feedbackDuration : Supported } msg
feedbackDuration =
    A.feedbackDuration


{-| See `Sl.Attributes.from`.
-}
from : String -> Attr { c | from : Supported } msg
from =
    A.from


{-| See `Sl.Attributes.hoist`.
-}
hoist : Bool -> Attr { c | hoist : Supported } msg
hoist =
    A.hoist


{-| See `Sl.Attributes.successLabel`.
-}
successLabel : String -> Attr { c | successLabel : Supported } msg
successLabel =
    A.successLabel


{-| See `Sl.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `Sl.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


{-| See `Sl.Events.onCopy`.
-}
onCopy : msg -> Attr { c | onCopy : Supported } msg
onCopy =
    Ev.onCopy


{-| See `Sl.Events.onError`.
-}
onError : msg -> Attr { c | onError : Supported } msg
onError =
    Ev.onError
