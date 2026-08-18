module M3e.Component.Slider exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Size, size
    , disabled, discrete, labelled, max, min, step, onBeforeinput, onInput, onChange
    , child
    )

{-| The `m3e-slider` component — strict per-component surface.

Allows for the selection of numeric values from a range.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Size, size
@docs disabled, discrete, labelled, max, min, step, onBeforeinput, onInput, onChange
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [] [] } [] []
```

<!-- elm-cem:example title="Selecting a value" -->
```elm
M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 1.5 ] [] } [ M3e.Component.Slider.min 1, M3e.Component.Slider.max 5, M3e.Component.Slider.step 0.5 ] []
```

<!-- elm-cem:example title="Selecting a range" -->
```elm
M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 20 ] [] } [] [ M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 80 ] [] ]
```

<!-- elm-cem:example title="Negative value ranges" -->
```elm
M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value -20 ] [] } [ M3e.Component.Slider.min -50 ] []
```

<!-- elm-cem:example title="Labels" -->
```elm
M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 20 ] [] } [ M3e.Component.Slider.labelled True ] []
```

<!-- elm-cem:example title="Tick marks" -->
```elm
M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 20 ] [] } [ M3e.Component.Slider.discrete True, M3e.Component.Slider.step 10 ] []
```

<!-- elm-cem:example title="Disabling" -->
```elm
M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 20 ] [] } [ M3e.Component.Slider.labelled True, M3e.Component.Slider.disabled True ] []
```

<!-- elm-cem:example title="Disabling (2)" -->
```elm
M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 20 ] [] } [ M3e.Component.Slider.labelled True ] [ M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.disabled True, M3e.Component.SliderThumb.value 80 ] [] ]
```


### Sizes

<!-- elm-cem:example title="Sizes" -->
```elm
[ M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 50 ] [] } [ M3e.Component.Slider.size M3e.Values.extraSmall ] []
    , M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 50 ] [] } [ M3e.Component.Slider.size M3e.Values.small ] []
    , M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 50 ] [] } [ M3e.Component.Slider.size M3e.Values.medium ] []
    , M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 50 ] [] } [ M3e.Component.Slider.size M3e.Values.large ] []
    , M3e.Component.Slider.component { content = M3e.Component.SliderThumb.component [ M3e.Component.SliderThumb.value 50 ] [] } [ M3e.Component.Slider.size M3e.Values.extraLarge ] []
    ]
```

<!-- elm-cem:docmeta category=Selection -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Slider
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-slider` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Slider.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Slider.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Slider.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.Slider.Size


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Slider.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Slider.AttrCaps


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
    H.slider attrs (required_.content :: children)


{-| The size of the slider. (default: `"extra-small"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.discrete`.
-}
discrete : Bool -> Attr { c | discrete : Supported } msg
discrete =
    A.discrete


{-| See `M3e.Attributes.labelled`.
-}
labelled : Bool -> Attr { c | labelled : Supported } msg
labelled =
    A.labelled


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


{-| See `M3e.Attributes.step`.
-}
step : Float -> Attr { c | step : Supported } msg
step =
    A.step


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
