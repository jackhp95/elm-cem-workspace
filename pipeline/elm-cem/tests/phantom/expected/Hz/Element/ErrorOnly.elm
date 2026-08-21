module Hz.Element.ErrorOnly exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , onHzError
    )

{-| The `hz-error-only` component — strict per-component surface.

Tests K4 acid probe: component with only hz-error event, no native error.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs onHzError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Events as Ev
import Hz.Html as H
import Hz.Internal.Types.ErrorOnly
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-error-only` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Hz.Internal.Types.ErrorOnly.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Hz.Internal.Types.ErrorOnly.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Hz.Internal.Types.ErrorOnly.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Hz.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Hz.Internal.Types.ErrorOnly.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Hz.Internal.Types.ErrorOnly.AttrCaps


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
    H.errorOnly


{-| See `Hz.Events.onHzError`.
-}
onHzError : msg -> Attr { c | onHzError : Supported } msg
onHzError =
    Ev.onHzError
