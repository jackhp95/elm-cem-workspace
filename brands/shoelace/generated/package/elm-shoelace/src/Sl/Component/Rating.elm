module Sl.Component.Rating exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , disabled, getsymbol, label, max, precision, readonly, value, defaultValue, onChange, onHover
    )

{-| The `sl-rating` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs disabled, getsymbol, label, max, precision, readonly, value, defaultValue, onChange, onHover

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Encode
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Rating
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-rating` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Rating.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Rating.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Rating.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Rating.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Rating.AttrCaps


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
    H.rating


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.getsymbol`.
-}
getsymbol : String -> Attr { c | getsymbol : Supported } msg
getsymbol =
    A.getsymbol


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| The highest rating to show. (default: `5`)
-}
max : Float -> Attr { c | max : Supported } msg
max value_ =
    Ir.attribute "max" (String.fromFloat value_)


{-| See `Sl.Attributes.precision`.
-}
precision : Float -> Attr { c | precision : Supported } msg
precision =
    A.precision


{-| See `Sl.Attributes.readonly`.
-}
readonly : Bool -> Attr { c | readonly : Supported } msg
readonly =
    A.readonly


{-| The current rating. (default: `0`)

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.

-}
value : Float -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.float value_)


{-| Set the `value` CONTENT attribute — the element's DEFAULT/initial `value`, mirroring HTML's own `defaultValue` IDL attribute. Unlike `value` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultValue : Float -> Attr { c | value : Supported } msg
defaultValue value_ =
    Ir.attribute "value" (String.fromFloat value_)


{-| See `Sl.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `Sl.Events.onHover`.
-}
onHover : msg -> Attr { c | onHover : Supported } msg
onHover =
    Ev.onHover
