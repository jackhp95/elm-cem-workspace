module M3e.Component.ListItem exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy
    , leading, overline, supportingText, trailing, child
    )

{-| The `m3e-list-item` component — strict per-component surface.

An item in a list.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy
@docs leading, overline, supportingText, trailing, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.ListItem
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-list-item` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ListItem.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ListItem.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.ListItem.Content


{-| The kinds the `leading` slot admits.
-}
type alias LeadingSlot =
    M3e.Internal.Types.ListItem.LeadingSlot


{-| The kinds the `overline` slot admits.
-}
type alias OverlineSlot =
    M3e.Internal.Types.ListItem.OverlineSlot


{-| The kinds the `supporting-text` slot admits.
-}
type alias SupportingTextSlot =
    M3e.Internal.Types.ListItem.SupportingTextSlot


{-| The kinds the `trailing` slot admits.
-}
type alias TrailingSlot =
    M3e.Internal.Types.ListItem.TrailingSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ListItem.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ListItem.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.ListItem.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.ListItem.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.listItem


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


{-| Place an element into the named `trailing` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trailing : Element TrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
trailing element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
