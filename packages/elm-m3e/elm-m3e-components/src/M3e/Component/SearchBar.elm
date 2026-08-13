module M3e.Component.SearchBar exposing
    ( view, el
    , Is, Attrs, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy
    , clearLabel, clearable, onClear
    , clearIcon, input, leading, trailing
    )

{-| The `m3e-search-bar` component — strict per-component surface.

A bar that provides a prominent entry point for search.

@docs view, el
@docs Is, Attrs, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy
@docs clearLabel, clearable, onClear
@docs clearIcon, input, leading, trailing

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.SearchBar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-search-bar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.SearchBar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.SearchBar.Attrs


{-| The kinds the `clear-icon` slot admits.
-}
type alias ClearIconSlot =
    M3e.Internal.Types.SearchBar.ClearIconSlot


{-| The kinds the `leading` slot admits.
-}
type alias LeadingSlot =
    M3e.Internal.Types.SearchBar.LeadingSlot


{-| The kinds the `trailing` slot admits.
-}
type alias TrailingSlot =
    M3e.Internal.Types.SearchBar.TrailingSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SearchBar.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.searchBar


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { input : Element childAccepts (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "input") (El.toNode required_.input)) :: children)


{-| See `M3e.Attributes.clearLabel`.
-}
clearLabel : String -> Attr { c | clearLabel : Supported } msg
clearLabel =
    A.clearLabel


{-| See `M3e.Attributes.clearable`.
-}
clearable : Bool -> Attr { c | clearable : Supported } msg
clearable =
    A.clearable


{-| See `M3e.Events.onClear`.
-}
onClear : msg -> Attr { c | onClear : Supported } msg
onClear =
    Ev.onClear


{-| Place an element into the named `clear-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
clearIcon : Element ClearIconSlot admittedBy msg -> Element free freeAdmittedBy msg
clearIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "clear-icon") (El.toNode element))


{-| Place an element into the named `input` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
input : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
input element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "input") (El.toNode element))


{-| Place an element into the named `leading` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
leading : Element LeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
leading element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading") (El.toNode element))


{-| Place an element into the named `trailing` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trailing : Element TrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
trailing element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing") (El.toNode element))
