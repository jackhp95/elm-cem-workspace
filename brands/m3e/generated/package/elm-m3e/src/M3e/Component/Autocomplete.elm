module M3e.Component.Autocomplete exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Filter, filter
    , autoActivate, caseSensitive, for, hideLoading, hideNoData, hideSelectionIndicator, loadingLabel, noDataLabel, panelClass, required, resultsLabel, onChange, onQuery, onToggle
    , loading, noData, child
    )

{-| The `m3e-autocomplete` component — strict per-component surface.

Enhances a text input with suggested options.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Filter, filter
@docs autoActivate, caseSensitive, for, hideLoading, hideNoData, hideSelectionIndicator, loadingLabel, noDataLabel, panelClass, required, resultsLabel, onChange, onQuery, onToggle
@docs loading, noData, child


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fruit" ] [ M3e.text "Choose your favorite fruit" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fruit" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "fruit" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    ]
```

<!-- elm-cem:example title="Filter modes" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fruit5" ] [ M3e.text "Choose your favorite fruit" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fruit5" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "fruit5", M3e.Component.Autocomplete.filter M3e.Values.startsWith, M3e.Component.Autocomplete.caseSensitive True ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    ]
```

<!-- elm-cem:example title="Custom filtering" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fruit4" ] [ M3e.text "Choose your favorite fruit" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fruit4" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Attributes.class "custom-filter", M3e.Component.Autocomplete.for "fruit4" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    ]
```

<!-- elm-cem:example title="No data" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fruit6" ] [ M3e.text "Choose your favorite fruit" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fruit6", TypedHtml.Unsafe.Attributes.customAttribute "value" "Pear" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "fruit6", M3e.Component.Autocomplete.noDataLabel "No data" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    ]
```

<!-- elm-cem:example title="Initial load" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "state" ] [ M3e.text "State" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "state" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Attributes.class "lazy", M3e.Component.Autocomplete.for "state" ] [ M3e.Component.Autocomplete.loading (M3e.Component.LoadingIndicator.component [] []) ]
    ]
```

<!-- elm-cem:example title="Search as you type" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "state2" ] [ M3e.text "State" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "state2" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Attributes.class "search", M3e.Component.Autocomplete.for "state2", M3e.Component.Autocomplete.filter M3e.Values.none ] [ M3e.Component.Autocomplete.loading (M3e.Component.LoadingIndicator.component [] []) ]
    ]
```

<!-- elm-cem:example title="Requiring an option to be selected" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fruit2" ] [ M3e.text "Choose your favorite fruit" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fruit2", TypedHtml.Unsafe.Attributes.customAttribute "value" "Apple" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "fruit2", M3e.Component.Autocomplete.required True ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    ]
```

<!-- elm-cem:example title="Automatic activation" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fruit3" ] [ M3e.text "Choose your favorite fruit" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fruit3" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "fruit3", M3e.Component.Autocomplete.autoActivate True ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    ]
```

<!-- elm-cem:example title="Chips" -->
```elm
[ M3e.Component.FormField.component [] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "fruit7" ] [ M3e.text "Choose your favorite fruits" ]), M3e.Component.InputChipSet.component [ TypedHtml.Aria.label "Enter favorite fruits" ] [ M3e.Component.InputChipSet.input (TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "fruit7", TypedHtml.Unsafe.Attributes.customAttribute "placeholder" "Add fruit..." ] []) ] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "fruit7" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.FormField.component [ M3e.Attributes.class "density-3" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "d1" ] [ M3e.text "Density -3" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "d1" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "d1", M3e.Component.Autocomplete.panelClass "density-3" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    , M3e.Component.FormField.component [ M3e.Attributes.class "density-2" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "d2" ] [ M3e.text "Density -2" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "d2" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "d2", M3e.Component.Autocomplete.panelClass "density-2" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    , M3e.Component.FormField.component [ M3e.Attributes.class "density-1" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "d3" ] [ M3e.text "Density -1" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "d3" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "d3", M3e.Component.Autocomplete.panelClass "density-1" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
    , M3e.Component.FormField.component [ M3e.Attributes.class "density-0" ] [ M3e.Component.FormField.label (TypedHtml.label [ TypedHtml.Unsafe.Attributes.customAttribute "for" "d4" ] [ M3e.text "Density 0" ]), TypedHtml.input [ TypedHtml.Unsafe.Attributes.customAttribute "id" "d4" ] [] ]
    , M3e.Component.Autocomplete.component [ M3e.Component.Autocomplete.for "d4", M3e.Component.Autocomplete.panelClass "density-0" ] [ M3e.Component.Option.component { content = M3e.text "Apples" } [] [], M3e.Component.Option.component { content = M3e.text "Oranges" } [] [], M3e.Component.Option.component { content = M3e.text "Bananas" } [] [], M3e.Component.Option.component { content = M3e.text "Grapes" } [] [] ]
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
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Autocomplete
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-autocomplete` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Autocomplete.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Autocomplete.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Autocomplete.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Autocomplete.ChildAdmittedBy childAdm


{-| The `filter` values valid on this component (compile-tight narrowing).
-}
type alias Filter =
    M3e.Internal.Types.Autocomplete.Filter


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Autocomplete.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Autocomplete.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Autocomplete.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.autocomplete


{-| Mode in which to filter options. (default: `"contains"`)
-}
filter : Value Filter -> Attr { c | filter : Supported } msg
filter value_ =
    Ir.attribute "filter" (Val.toString value_)


{-| See `M3e.Attributes.autoActivate`.
-}
autoActivate : Bool -> Attr { c | autoActivate : Supported } msg
autoActivate =
    A.autoActivate


{-| See `M3e.Attributes.caseSensitive`.
-}
caseSensitive : Bool -> Attr { c | caseSensitive : Supported } msg
caseSensitive =
    A.caseSensitive


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.hideLoading`.
-}
hideLoading : Bool -> Attr { c | hideLoading : Supported } msg
hideLoading =
    A.hideLoading


{-| See `M3e.Attributes.hideNoData`.
-}
hideNoData : Bool -> Attr { c | hideNoData : Supported } msg
hideNoData =
    A.hideNoData


{-| See `M3e.Attributes.hideSelectionIndicator`.
-}
hideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
hideSelectionIndicator =
    A.hideSelectionIndicator


{-| See `M3e.Attributes.loadingLabel`.
-}
loadingLabel : String -> Attr { c | loadingLabel : Supported } msg
loadingLabel =
    A.loadingLabel


{-| See `M3e.Attributes.noDataLabel`.
-}
noDataLabel : String -> Attr { c | noDataLabel : Supported } msg
noDataLabel =
    A.noDataLabel


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


{-| See `M3e.Attributes.resultsLabel`.
-}
resultsLabel : String -> Attr { c | resultsLabel : Supported } msg
resultsLabel =
    A.resultsLabel


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onQuery`.
-}
onQuery : msg -> Attr { c | onQuery : Supported } msg
onQuery =
    Ev.onQuery


{-| See `M3e.Events.onToggle`.
-}
onToggle : msg -> Attr { c | onToggle : Supported } msg
onToggle =
    Ev.onToggle


{-| Place an element into the named `loading` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
loading : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
loading element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "loading") (El.toNode element))


{-| Place an element into the named `no-data` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
noData : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
noData element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "no-data") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
