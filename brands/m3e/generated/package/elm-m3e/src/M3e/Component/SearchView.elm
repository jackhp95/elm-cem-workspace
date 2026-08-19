module M3e.Component.SearchView exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ClearIconSlot, CloseIconSlot, ClosedLeadingSlot, ClosedTrailingSlot, OpenLeadingSlot, OpenTrailingSlot, SearchIconSlot, ChildAdmittedBy
    , Mode, mode
    , clearLabel, closeLabel, contained, hideSearchIcon, open, onQuery, onClear, onBeforetoggle, onToggle
    , clearIcon, closeIcon, closedLeading, closedTrailing, input, openLeading, openTrailing, searchIcon, child
    )

{-| The `m3e-search-view` component — strict per-component surface.

A surface that presents suggestions and results for a search.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ClearIconSlot, CloseIconSlot, ClosedLeadingSlot, ClosedTrailingSlot, OpenLeadingSlot, OpenTrailingSlot, SearchIconSlot, ChildAdmittedBy
@docs Mode, mode
@docs clearLabel, closeLabel, contained, hideSearchIcon, open, onQuery, onClear, onBeforetoggle, onToggle
@docs clearIcon, closeIcon, closedLeading, closedTrailing, input, openLeading, openTrailing, searchIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.SearchView
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-search-view` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.SearchView.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.SearchView.Attrs


{-| The kinds the `clear-icon` slot admits.
-}
type alias ClearIconSlot =
    M3e.Internal.Types.SearchView.ClearIconSlot


{-| The kinds the `close-icon` slot admits.
-}
type alias CloseIconSlot =
    M3e.Internal.Types.SearchView.CloseIconSlot


{-| The kinds the `closed-leading` slot admits.
-}
type alias ClosedLeadingSlot =
    M3e.Internal.Types.SearchView.ClosedLeadingSlot


{-| The kinds the `closed-trailing` slot admits.
-}
type alias ClosedTrailingSlot =
    M3e.Internal.Types.SearchView.ClosedTrailingSlot


{-| The kinds the `open-leading` slot admits.
-}
type alias OpenLeadingSlot =
    M3e.Internal.Types.SearchView.OpenLeadingSlot


{-| The kinds the `open-trailing` slot admits.
-}
type alias OpenTrailingSlot =
    M3e.Internal.Types.SearchView.OpenTrailingSlot


{-| The kinds the `search-icon` slot admits.
-}
type alias SearchIconSlot =
    M3e.Internal.Types.SearchView.SearchIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SearchView.ChildAdmittedBy childAdm


{-| The `mode` values valid on this component (compile-tight narrowing).
-}
type alias Mode =
    M3e.Internal.Types.SearchView.Mode


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SearchView.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.SearchView.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.SearchView.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { input : Element childAccepts (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.searchView attrs (Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "input") (El.toNode required_.input)) :: children)


{-| The behavior mode of the view. (default: `"docked"`)
-}
mode : Value Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (Val.toString value_)


{-| See `M3e.Attributes.clearLabel`.
-}
clearLabel : String -> Attr { c | clearLabel : Supported } msg
clearLabel =
    A.clearLabel


{-| See `M3e.Attributes.closeLabel`.
-}
closeLabel : String -> Attr { c | closeLabel : Supported } msg
closeLabel =
    A.closeLabel


{-| See `M3e.Attributes.contained`.
-}
contained : Bool -> Attr { c | contained : Supported } msg
contained =
    A.contained


{-| See `M3e.Attributes.hideSearchIcon`.
-}
hideSearchIcon : Bool -> Attr { c | hideSearchIcon : Supported } msg
hideSearchIcon =
    A.hideSearchIcon


{-| See `M3e.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `M3e.Events.onQuery`.
-}
onQuery : msg -> Attr { c | onQuery : Supported } msg
onQuery =
    Ev.onQuery


{-| See `M3e.Events.onClear`.
-}
onClear : msg -> Attr { c | onClear : Supported } msg
onClear =
    Ev.onClear


{-| See `M3e.Events.onBeforetoggle`.
-}
onBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
onBeforetoggle =
    Ev.onBeforetoggle


{-| See `M3e.Events.onToggle`.
-}
onToggle : msg -> Attr { c | onToggle : Supported } msg
onToggle =
    Ev.onToggle


{-| Place an element into the named `clear-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
clearIcon : Element ClearIconSlot admittedBy msg -> Element free freeAdmittedBy msg
clearIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "clear-icon") (El.toNode element))


{-| Place an element into the named `close-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
closeIcon : Element CloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
closeIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "close-icon") (El.toNode element))


{-| Place an element into the named `closed-leading` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
closedLeading : Element ClosedLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
closedLeading element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "closed-leading") (El.toNode element))


{-| Place an element into the named `closed-trailing` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
closedTrailing : Element ClosedTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
closedTrailing element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "closed-trailing") (El.toNode element))


{-| Place an element into the named `input` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
input : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
input element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "input") (El.toNode element))


{-| Place an element into the named `open-leading` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
openLeading : Element OpenLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
openLeading element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "open-leading") (El.toNode element))


{-| Place an element into the named `open-trailing` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
openTrailing : Element OpenTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
openTrailing element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "open-trailing") (El.toNode element))


{-| Place an element into the named `search-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
searchIcon : Element SearchIconSlot admittedBy msg -> Element free freeAdmittedBy msg
searchIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "search-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
