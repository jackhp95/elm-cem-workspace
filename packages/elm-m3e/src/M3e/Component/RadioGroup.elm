module M3e.Component.RadioGroup exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , ariaInvalid, disabled, name, required, validationmessages, onBeforeinput, onInput, onChange
    , child
    )

{-| The `m3e-radio-group` component — strict per-component surface.

A container for a set of radio buttons.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs ariaInvalid, disabled, name, required, validationmessages, onBeforeinput, onInput, onChange
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Radio groups" -->
```elm
M3e.Component.RadioGroup.component { content = M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "1" ] [], M3e.text "Option 1" ] } [] [ M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "2" ] [], M3e.text "Option 2" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "3" ] [], M3e.text "Option 3" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "4" ] [], M3e.text "Option 4" ] ]
```

<!-- elm-cem:example title="Labels" -->
```elm
[ TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "radio-group" ] [ M3e.text "Select an option" ]
    , TypedHtml.br [] []
    , M3e.Component.RadioGroup.component { content = M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "1" ] [], M3e.text "Option 1" ] } [ M3e.Attributes.id "radio-group" ] [ M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "2" ] [], M3e.text "Option 2" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "3" ] [], M3e.text "Option 3" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "4" ] [], M3e.text "Option 4" ] ]
    ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
[ TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "radio-group2" ] [ M3e.text "Select an option" ]
    , TypedHtml.br [] []
    , M3e.Component.RadioGroup.component { content = M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.disabled True, M3e.Component.Radio.value "1" ] [], M3e.text "Option 1" ] } [ M3e.Attributes.id "radio-group2" ] [ M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "2" ] [], M3e.text "Option 2" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "3" ] [], M3e.text "Option 3" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "4" ] [], M3e.text "Option 4" ] ]
    ]
```

<!-- elm-cem:example title="Disabling (2)" -->
```elm
[ TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "radio-group3" ] [ M3e.text "Select an option" ]
    , TypedHtml.br [] []
    , M3e.Component.RadioGroup.component { content = M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "1" ] [], M3e.text "Option 1" ] } [ M3e.Attributes.id "radio-group3", M3e.Component.RadioGroup.disabled True ] [ M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "2" ] [], M3e.text "Option 2" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "3" ] [], M3e.text "Option 3" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "4" ] [], M3e.text "Option 4" ] ]
    ]
```

<!-- elm-cem:example title="Required" -->
```elm
[ TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "radio-group4" ] [ M3e.text "Select an option" ]
    , TypedHtml.br [] []
    , M3e.Component.RadioGroup.component { content = M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "1" ] [], M3e.text "Option 1" ] } [ M3e.Attributes.id "radio-group4", M3e.Component.RadioGroup.required True ] [ M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "2" ] [], M3e.text "Option 2" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "3" ] [], M3e.text "Option 3" ], M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Component.Radio.value "4" ] [], M3e.text "Option 4" ] ]
    ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Attributes.class "density-3" ] [], M3e.text "Density -3" ]
    , M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Attributes.class "density-2" ] [], M3e.text "Density -2" ]
    , M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Attributes.class "density-1" ] [], M3e.text "Density -1" ]
    , M3e.Unsafe.customElement "label" [] [ M3e.Component.Radio.component [ M3e.Attributes.class "density-0" ] [], M3e.text "Density 0" ]
    ]
```

<!-- elm-cem:docmeta category=Selection -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.RadioGroup
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-radio-group` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.RadioGroup.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.RadioGroup.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.RadioGroup.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.RadioGroup.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.RadioGroup.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element childAccepts (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.radioGroup attrs (required_.content :: children)


{-| See `M3e.Attributes.ariaInvalid`.
-}
ariaInvalid : String -> Attr { c | ariaInvalid : Supported } msg
ariaInvalid =
    A.ariaInvalid


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    A.required


{-| See `M3e.Attributes.validationmessages`.
-}
validationmessages : String -> Attr { c | validationmessages : Supported } msg
validationmessages =
    A.validationmessages


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


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
