module M3e.Component.Select exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ArrowSlot, ChildAdmittedBy
    , disabled, hideSelectionIndicator, multi, name, panelClass, required, validationmessages, onChange, onToggle, onBeforeinput, onInput
    , arrow, value, child
    )

{-| The `m3e-select` component — strict per-component surface.

A form control that allows users to select a value from a set of predefined options.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ArrowSlot, ChildAdmittedBy
@docs disabled, hideSelectionIndicator, multi, name, panelClass, required, validationmessages, onChange, onToggle, onBeforeinput, onInput
@docs arrow, value, child


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "select1" ] [ M3e.text "Favorite fruit" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "Apples" } [] [] } [ M3e.Attributes.id "select1" ] [ M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
```

<!-- elm-cem:example title="Empty options" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "select2" ] [ M3e.text "Favorite fruit" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "None" } [ M3e.Component.Option.value "" ] [] } [ M3e.Attributes.id "select2" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
```

<!-- elm-cem:example title="Option groups" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "select3" ] [ M3e.text "Pokemon" ]), M3e.Component.Select.component { content = M3e.Component.Optgroup.component [] [ M3e.Component.Optgroup.label (M3e.text "Grass"), M3e.Component.Option.component { content = M3e.text "Bulbasaur" } [] [], M3e.Component.Option.component { content = M3e.text "Oddish" } [] [], M3e.Component.Option.component { content = M3e.text "Bellsprout" } [] [] ] } [ M3e.Attributes.id "select3" ] [ M3e.Component.Optgroup.component [] [ M3e.Component.Optgroup.label (M3e.text "Water"), M3e.Component.Option.component { content = M3e.text "Squirtle" } [] [], M3e.Component.Option.component { content = M3e.text "Psyduck" } [] [], M3e.Component.Option.component { content = M3e.text "Horsea" } [] [] ], M3e.Component.Optgroup.component [] [ M3e.Component.Optgroup.label (M3e.text "Fire"), M3e.Component.Option.component { content = M3e.text "Charmander" } [] [], M3e.Component.Option.component { content = M3e.text "Vulpix" } [] [], M3e.Component.Option.component { content = M3e.text "Flareon" } [] [] ] ] ]
```

<!-- elm-cem:example title="Selection" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "select4" ] [ M3e.text "Toppings" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "Extra cheese" } [ M3e.Component.Option.selected True ] [] } [ M3e.Attributes.id "select4", M3e.Component.Select.multi True ] [ M3e.Component.Option.component { content = M3e.text "Mushroom" } [ M3e.Component.Option.selected True ] [], M3e.Component.Option.component { content = M3e.text "Onion" } [] [], M3e.Component.Option.component { content = M3e.text "Pepperoni" } [] [], M3e.Component.Option.component { content = M3e.text "Sausage" } [] [], M3e.Component.Option.component { content = M3e.text "Tomato" } [] [] ] ]
```

<!-- elm-cem:example title="Disabling" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "select5" ] [ M3e.text "Favorite fruit" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "Apples" } [ M3e.Component.Option.selected True ] [] } [ M3e.Attributes.id "select5", M3e.Component.Select.disabled True ] [ M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
```

<!-- elm-cem:example title="Disabling (2)" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "select6" ] [ M3e.text "Favorite fruit" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "Apples" } [ M3e.Component.Option.disabled True ] [] } [ M3e.Attributes.id "select6" ] [ M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
```

<!-- elm-cem:example title="Required" -->
```elm
M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "select7" ] [ M3e.text "Favorite fruit" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "None" } [ M3e.Component.Option.value "" ] [] } [ M3e.Attributes.id "select7", M3e.Component.Select.required True ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.FormField.component [ M3e.Attributes.class "density-3" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "ds1" ] [ M3e.text "Density -3" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "Apples" } [] [] } [ M3e.Attributes.id "ds1", M3e.Component.Select.panelClass "density-3" ] [ M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
    , M3e.Component.FormField.component [ M3e.Attributes.class "density-2" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "ds2" ] [ M3e.text "Density -2" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "Apples" } [] [] } [ M3e.Attributes.id "ds2", M3e.Component.Select.panelClass "density-2" ] [ M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
    , M3e.Component.FormField.component [ M3e.Attributes.class "density-1" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "ds3" ] [ M3e.text "Density -1" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "Apples" } [] [] } [ M3e.Attributes.id "ds3", M3e.Component.Select.panelClass "density-1" ] [ M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
    , M3e.Component.FormField.component [ M3e.Attributes.class "density-0" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "ds4" ] [ M3e.text "Density 0" ]), M3e.Component.Select.component { content = M3e.Component.Option.component { content = M3e.text "Apples" } [] [] } [ M3e.Attributes.id "ds4", M3e.Component.Select.panelClass "density-0" ] [ M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ] ]
    ]
```

<!-- elm-cem:docmeta category=Text inputs -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import Json.Decode
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Select
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-select` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Select.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Select.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Select.Content


{-| The kinds the `arrow` slot admits.
-}
type alias ArrowSlot =
    M3e.Internal.Types.Select.ArrowSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Select.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Select.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Select.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Select.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.select attrs (required_.content :: children)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.hideSelectionIndicator`.
-}
hideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
hideSelectionIndicator =
    A.hideSelectionIndicator


{-| See `M3e.Attributes.multi`.
-}
multi : Bool -> Attr { c | multi : Supported } msg
multi =
    A.multi


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.panelClass`.
-}
panelClass : String -> Attr { c | panelClass : Supported } msg
panelClass =
    A.panelClass


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


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Typed `toggle` event: decodes `newState` as String.
-}
onToggle : (String -> msg) -> Attr { c | onToggle : Supported } msg
onToggle toMsg =
    Ir.on "toggle" (Json.Decode.map toMsg (Json.Decode.at [ "newState" ] Json.Decode.string))


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


{-| Place an element into the named `arrow` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
arrow : Element ArrowSlot admittedBy msg -> Element free freeAdmittedBy msg
arrow element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "arrow") (El.toNode element))


{-| Place an element into the named `value` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
value : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
value element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "value") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
