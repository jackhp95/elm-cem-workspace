module M3e.Component.FormField exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , FloatLabel, floatLabel, HideSubscript, hideSubscript, Variant, variant
    , hideRequiredMarker
    , error, hint, label, prefix, prefixText, suffix, suffixText, child
    )

{-| The `m3e-form-field` component — strict per-component surface.

A container for form controls that applies Material Design styling and behavior.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs FloatLabel, floatLabel, HideSubscript, hideSubscript, Variant, variant
@docs hideRequiredMarker
@docs error, hint, label, prefix, prefixText, suffix, suffixText, child


## Examples


### Variants

<!-- elm-cem:example title="Variants" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld1" ] [ M3e.text "Outlined" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fld1" ] [] ]
    , M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.filled ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld2" ] [ M3e.text "Filled" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fld2" ] [] ]
    ]
```


### Examples

<!-- elm-cem:example title="Float label" -->
```elm
M3e.Component.FormField.component [ M3e.Component.FormField.floatLabel M3e.Values.always ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld3" ] [ M3e.text "Always float label" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fld3" ] [] ]
```

<!-- elm-cem:example title="Hint labels" -->
```elm
M3e.Component.FormField.component [ M3e.Component.FormField.hideSubscript M3e.Values.auto ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld4" ] [ M3e.text "Field w/ hint" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fld4" ] [], M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "Hint text" ]) ]
```

<!-- elm-cem:example title="Error messages" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld5" ] [ M3e.text "Required field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fld5", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [], M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "Hint text" ]) ]
```

<!-- elm-cem:example title="Error messages (2)" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld6" ] [ M3e.text "Required field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fld6", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [], M3e.Component.FormField.hint (TypedHtml.span [] [ M3e.text "Hint text" ]), M3e.Component.FormField.error (TypedHtml.span [] [ M3e.text "Custom error message" ]) ]
```

<!-- elm-cem:example title="Hiding the required marker" -->
```elm
M3e.Component.FormField.component [ M3e.Component.FormField.hideRequiredMarker True ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld7" ] [ M3e.text "Required field" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fld7", TypedHtml.Unsafe.Attributes.customAttribute "required" "" ] [] ]
```

<!-- elm-cem:example title="Prefix and suffix" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fld8" ] [ M3e.text "Amount" ]), M3e.Component.FormField.prefixText (TypedHtml.span [] [ M3e.text "$" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fld8", TypedHtml.Unsafe.Attributes.customAttribute "type" "number", TypedHtml.Unsafe.Attributes.customAttribute "placeholder" "0" ] [], M3e.Component.FormField.suffixText (TypedHtml.span [] [ M3e.text ".00" ]), M3e.Component.FormField.suffix (M3e.Component.IconButton.component { content = M3e.Component.Icon.component [ M3e.Component.Icon.name "clear" ] [], ariaLabel = "Clear", action = M3e.Action.none } [] []) ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined, M3e.Attributes.class "density-3" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "dfld1" ] [ M3e.text "Density -3" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "dfld1" ] [] ]
    , M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined, M3e.Attributes.class "density-2" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "dfld2" ] [ M3e.text "Density -2" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "dfld2" ] [] ]
    , M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined, M3e.Attributes.class "density-1" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "dfld3" ] [ M3e.text "Density -1" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "dfld3" ] [] ]
    , M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.outlined, M3e.Attributes.class "density-0" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "dfld4" ] [ M3e.text "Density 0" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "dfld4" ] [] ]
    ]
```

<!-- elm-cem:example title="Density (2)" -->
```elm
[ M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.filled, M3e.Attributes.class "density-3" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "dfld5" ] [ M3e.text "Density -3" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "dfld5" ] [] ]
    , M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.filled, M3e.Attributes.class "density-2" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "dfld6" ] [ M3e.text "Density -2" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "dfld6" ] [] ]
    , M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.filled, M3e.Attributes.class "density-1" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "dfld7" ] [ M3e.text "Density -1" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "dfld7" ] [] ]
    , M3e.Component.FormField.component [ M3e.Component.FormField.variant M3e.Values.filled, M3e.Attributes.class "density-0" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "dfld8" ] [ M3e.text "Density 0" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "dfld8" ] [] ]
    ]
```

<!-- elm-cem:docmeta category=Text inputs -->

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


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.FormField.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.FormField.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.FormField.SlotCaps


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
