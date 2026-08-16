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
