module Sl.Component.ProgressBar exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , indeterminate, label, value, defaultValue
    )

{-| The `sl-progress-bar` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs indeterminate, label, value, defaultValue

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Encode
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.ProgressBar
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-progress-bar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.ProgressBar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.ProgressBar.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.ProgressBar.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.ProgressBar.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.ProgressBar.AttrCaps


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
    H.progressBar


{-| See `Sl.Attributes.indeterminate`.
-}
indeterminate : Bool -> Attr { c | indeterminate : Supported } msg
indeterminate =
    A.indeterminate


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| The current progress as a percentage, 0 to 100. (default: `0`)

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
