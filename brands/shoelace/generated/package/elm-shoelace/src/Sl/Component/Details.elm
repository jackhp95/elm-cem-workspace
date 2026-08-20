module Sl.Component.Details exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , disabled, open, summary, onShow, onAfterShow, onHide, onAfterHide
    )

{-| The `sl-details` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs disabled, open, summary, onShow, onAfterShow, onHide, onAfterHide

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Details
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-details` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Details.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Details.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Details.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Details.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Details.AttrCaps


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
    H.details


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `Sl.Attributes.summary`.
-}
summary : String -> Attr { c | summary : Supported } msg
summary =
    A.summary


{-| See `Sl.Events.onShow`.
-}
onShow : msg -> Attr { c | onShow : Supported } msg
onShow =
    Ev.onShow


{-| See `Sl.Events.onAfterShow`.
-}
onAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
onAfterShow =
    Ev.onAfterShow


{-| See `Sl.Events.onHide`.
-}
onHide : msg -> Attr { c | onHide : Supported } msg
onHide =
    Ev.onHide


{-| See `Sl.Events.onAfterHide`.
-}
onAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
onAfterHide =
    Ev.onAfterHide
