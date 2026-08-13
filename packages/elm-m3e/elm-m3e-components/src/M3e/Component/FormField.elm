module M3e.Component.FormField exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , FloatLabel, floatLabel, HideSubscript, hideSubscript, Variant, variant
    , hideRequiredMarker
    , error, hint, label, prefix, prefixText, suffix, suffixText, child
    )

{-| The `m3e-form-field` component — strict per-component surface.

A container for form controls that applies Material Design styling and behavior.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs FloatLabel, floatLabel, HideSubscript, hideSubscript, Variant, variant
@docs hideRequiredMarker
@docs error, hint, label, prefix, prefixText, suffix, suffixText, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.FormField
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-form-field` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.FormField.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.FormField.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FormField.ChildAdmittedBy childAdm


{-| The `floatLabel` values valid on this component (compile-tight narrowing).
-}
type alias FloatLabel =
    M3e.Internal.Types.FormField.FloatLabel


{-| The `hideSubscript` values valid on this component (compile-tight narrowing).
-}
type alias HideSubscript =
    M3e.Internal.Types.FormField.HideSubscript


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.FormField.Variant


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.formField


{-| Specifies whether the label should float always or only when necessary. (default: `"auto"`)
-}
floatLabel : Value FloatLabel -> Attr { c | floatLabel : Supported } msg
floatLabel value_ =
    Ir.attribute "float-label" (Val.toString value_)


{-| Whether subscript content is hidden. (default: `"auto"`)
-}
hideSubscript : Value HideSubscript -> Attr { c | hideSubscript : Supported } msg
hideSubscript value_ =
    Ir.attribute "hide-subscript" (Val.toString value_)


{-| The appearance variant of the field. (default: `"outlined"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.hideRequiredMarker`.
-}
hideRequiredMarker : Bool -> Attr { c | hideRequiredMarker : Supported } msg
hideRequiredMarker =
    A.hideRequiredMarker


{-| Place an element into the named `error` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
error : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
error element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "error") (El.toNode element))


{-| Place an element into the named `hint` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
hint : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
hint element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "hint") (El.toNode element))


{-| Place an element into the named `label` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
label : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
label element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (El.toNode element))


{-| Place an element into the named `prefix` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
prefix : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
prefix element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "prefix") (El.toNode element))


{-| Place an element into the named `prefix-text` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
prefixText : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
prefixText element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "prefix-text") (El.toNode element))


{-| Place an element into the named `suffix` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
suffix : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
suffix element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "suffix") (El.toNode element))


{-| Place an element into the named `suffix-text` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
suffixText : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
suffixText element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "suffix-text") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
