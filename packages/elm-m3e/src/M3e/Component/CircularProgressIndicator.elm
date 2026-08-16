module M3e.Component.CircularProgressIndicator exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Variant, variant
    , indeterminate, max, value, defaultValue
    , child
    )

{-| The `m3e-circular-progress-indicator` component — strict per-component surface.

A circular indicator of progress and activity.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Variant, variant
@docs indeterminate, max, value, defaultValue
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.CircularProgressIndicator
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-circular-progress-indicator` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.CircularProgressIndicator.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.CircularProgressIndicator.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.CircularProgressIndicator.ChildAdmittedBy childAdm


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.CircularProgressIndicator.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.CircularProgressIndicator.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.CircularProgressIndicator.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.circularProgressIndicator


{-| The appearance of the indicator. (default: `"flat"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.indeterminate`.
-}
indeterminate : Bool -> Attr { c | indeterminate : Supported } msg
indeterminate =
    A.indeterminate


{-| See `M3e.Attributes.max`.
-}
max : Float -> Attr { c | max : Supported } msg
max =
    A.max


{-| A fractional value, between 0 and `max`, indicating progress. (default: `0`)

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


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
