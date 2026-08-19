module M3e.Component.ExpandableListItem exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, ToggleIconSlot, ChildAdmittedBy
    , disabled, open, onOpening, onOpened, onClosing, onClosed
    , items, leading, overline, supportingText, toggleIcon, child
    )

{-| The `m3e-expandable-list-item` component — strict per-component surface.

An item in a list that can be expanded to show more items.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, ToggleIconSlot, ChildAdmittedBy
@docs disabled, open, onOpening, onOpened, onClosing, onClosed
@docs items, leading, overline, supportingText, toggleIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.ExpandableListItem
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-expandable-list-item` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ExpandableListItem.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ExpandableListItem.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.ExpandableListItem.Content


{-| The kinds the `leading` slot admits.
-}
type alias LeadingSlot =
    M3e.Internal.Types.ExpandableListItem.LeadingSlot


{-| The kinds the `overline` slot admits.
-}
type alias OverlineSlot =
    M3e.Internal.Types.ExpandableListItem.OverlineSlot


{-| The kinds the `supporting-text` slot admits.
-}
type alias SupportingTextSlot =
    M3e.Internal.Types.ExpandableListItem.SupportingTextSlot


{-| The kinds the `toggle-icon` slot admits.
-}
type alias ToggleIconSlot =
    M3e.Internal.Types.ExpandableListItem.ToggleIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ExpandableListItem.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ExpandableListItem.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.ExpandableListItem.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.ExpandableListItem.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.expandableListItem


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `M3e.Events.onOpening`.
-}
onOpening : msg -> Attr { c | onOpening : Supported } msg
onOpening =
    Ev.onOpening


{-| See `M3e.Events.onOpened`.
-}
onOpened : msg -> Attr { c | onOpened : Supported } msg
onOpened =
    Ev.onOpened


{-| See `M3e.Events.onClosing`.
-}
onClosing : msg -> Attr { c | onClosing : Supported } msg
onClosing =
    Ev.onClosing


{-| See `M3e.Events.onClosed`.
-}
onClosed : msg -> Attr { c | onClosed : Supported } msg
onClosed =
    Ev.onClosed


{-| Place an element into the named `items` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
items : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
items element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "items") (El.toNode element))


{-| Place an element into the named `leading` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
leading : Element LeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
leading element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "leading") (El.toNode element))


{-| Place an element into the named `overline` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
overline : Element OverlineSlot admittedBy msg -> Element free freeAdmittedBy msg
overline element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "overline") (El.toNode element))


{-| Place an element into the named `supporting-text` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
supportingText : Element SupportingTextSlot admittedBy msg -> Element free freeAdmittedBy msg
supportingText element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "supporting-text") (El.toNode element))


{-| Place an element into the named `toggle-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
toggleIcon : Element ToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
toggleIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "toggle-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
