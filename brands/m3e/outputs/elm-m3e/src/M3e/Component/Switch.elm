module M3e.Component.Switch exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Icons, icons
    , checked, disabled, name, validationmessages, value, defaultChecked, defaultValue, onBeforeinput, onInput, onChange, onClick
    )

{-| The `m3e-switch` component — strict per-component surface.

An on/off control that can be toggled by clicking.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Icons, icons
@docs checked, disabled, name, validationmessages, value, defaultChecked, defaultValue, onBeforeinput, onInput, onChange, onClick


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
M3e.Component.Switch.component [ M3e.Component.Switch.checked True ] []
```

<!-- elm-cem:example title="Labels" -->
```elm
[ M3e.Unsafe.customElement "label" [] [ M3e.Component.Switch.component [] [], M3e.text "Switch 1" ]
    , M3e.Component.Switch.component [ M3e.Attributes.id "switch2" ] []
    , TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "switch2" ] [ M3e.text "Switch 2" ]
    ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
[ M3e.Unsafe.customElement "label" [] [ M3e.Component.Switch.component [ M3e.Component.Switch.disabled True ] [], M3e.text "Disabled Switch 1" ]
    , M3e.Component.Switch.component [ M3e.Attributes.id "chk3", M3e.Component.Switch.disabled True ] []
    , TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "chk3" ] [ M3e.text "Disabled Switch 2" ]
    ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.Switch.component [ M3e.Attributes.class "density-3" ] []
    , M3e.Component.Switch.component [ M3e.Attributes.class "density-2" ] []
    , M3e.Component.Switch.component [ M3e.Attributes.class "density-1" ] []
    , M3e.Component.Switch.component [ M3e.Attributes.class "density-0" ] []
    ]
```


### Icons

<!-- elm-cem:example title="Icons" -->
```elm
[ M3e.Component.Switch.component [ M3e.Component.Switch.icons M3e.Values.selected, M3e.Component.Switch.checked True ] []
    , M3e.Component.Switch.component [ M3e.Component.Switch.icons M3e.Values.both ] []
    ]
```

<!-- elm-cem:docmeta category=Selection -->

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
import M3e.Internal.Types.Switch
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-switch` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Switch.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Switch.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Switch.ChildAdmittedBy childAdm


{-| The `icons` values valid on this component (compile-tight narrowing).
-}
type alias Icons =
    M3e.Internal.Types.Switch.Icons


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Switch.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Switch.AttrCaps


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
    H.switch


{-| The icons to present. (default: `"none"`)
-}
icons : Value Icons -> Attr { c | icons : Supported } msg
icons value_ =
    Ir.attribute "icons" (Val.toString value_)


{-| See `M3e.Attributes.checked`.
-}
checked : Bool -> Attr { c | checked : Supported } msg
checked =
    A.checked


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


{-| See `M3e.Attributes.validationmessages`.
-}
validationmessages : String -> Attr { c | validationmessages : Supported } msg
validationmessages =
    A.validationmessages


{-| See `M3e.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `M3e.Attributes.defaultChecked`.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked =
    A.defaultChecked


{-| See `M3e.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


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


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick
