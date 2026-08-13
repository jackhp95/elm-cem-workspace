module M3e.Component.SplitPane exposing
    ( view, el
    , Is, Attrs, ChildAdmittedBy
    , Orientation, orientation
    , detents, disabled, label, max, min, name, overshootLimit, step, value, wrapDetents, defaultValue, onChange, onBeforeinput, onInput
    , end, start
    )

{-| The `m3e-split-pane` component — strict per-component surface.

A dual-view layout that separates content with a movable drag handle.

@docs view, el
@docs Is, Attrs, ChildAdmittedBy
@docs Orientation, orientation
@docs detents, disabled, label, max, min, name, overshootLimit, step, value, wrapDetents, defaultValue, onChange, onBeforeinput, onInput
@docs end, start

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.SplitPane
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-split-pane` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.SplitPane.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.SplitPane.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SplitPane.ChildAdmittedBy childAdm


{-| The `orientation` values valid on this component (compile-tight narrowing).
-}
type alias Orientation =
    M3e.Internal.Types.SplitPane.Orientation


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.splitPane


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { end : Element childAccepts (ChildAdmittedBy childAdm) msg
    , start : Element childAccepts (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "end") (El.toNode required_.end)) :: Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "start") (El.toNode required_.start)) :: children)


{-| The orientation of the split. (default: `"horizontal"`)
-}
orientation : Value Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (Val.toString value_)


{-| See `M3e.Attributes.detents`.
-}
detents : String -> Attr { c | detents : Supported } msg
detents =
    A.detents


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| See `M3e.Attributes.max`.
-}
max : Float -> Attr { c | max : Supported } msg
max =
    A.max


{-| See `M3e.Attributes.min`.
-}
min : Float -> Attr { c | min : Supported } msg
min =
    A.min


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.overshootLimit`.
-}
overshootLimit : Float -> Attr { c | overshootLimit : Supported } msg
overshootLimit =
    A.overshootLimit


{-| See `M3e.Attributes.step`.
-}
step : Float -> Attr { c | step : Supported } msg
step =
    A.step


{-| A fractional value, between 0 and 100, indicating the size of the start pane. (default: `50`)

Sets the LIVE DOM property `value`, not the content attribute. The content attribute — the element's INITIAL state, and the only form that serializes to server-rendered markup — is `defaultValue`.
-}
value : Float -> Attr { c | value : Supported } msg
value value_ =
    Ir.property "value" (Json.Encode.float value_)


{-| See `M3e.Attributes.wrapDetents`.
-}
wrapDetents : Bool -> Attr { c | wrapDetents : Supported } msg
wrapDetents =
    A.wrapDetents


{-| Set the `value` CONTENT attribute — the element's DEFAULT/initial `value`, mirroring HTML's own `defaultValue` IDL attribute. Unlike `value` (which writes the live DOM property) this one SERIALIZES: it is what server-rendered markup and `outerHTML` show, and it is what a form reset restores to.
-}
defaultValue : Float -> Attr { c | value : Supported } msg
defaultValue value_ =
    Ir.attribute "value" (String.fromFloat value_)


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onBeforeinput`.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput =
    Ev.onBeforeinput


{-| See `M3e.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| Place an element into the named `end` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
end : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
end element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "end") (El.toNode element))


{-| Place an element into the named `start` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
start : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
start element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "start") (El.toNode element))
