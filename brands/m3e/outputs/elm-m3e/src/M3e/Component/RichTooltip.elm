module M3e.Component.RichTooltip exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, SubheadSlot, ChildAdmittedBy
    , Position, position, TouchGestures, touchGestures
    , disabled, for, hideDelay, showDelay, onBeforetoggle, onToggle
    , actions, subhead, child
    )

{-| The `m3e-rich-tooltip` component — strict per-component surface.

Provides contextual details for a control, such as explaining the value or purpose of a feature.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, SubheadSlot, ChildAdmittedBy
@docs Position, position, TouchGestures, touchGestures
@docs disabled, for, hideDelay, showDelay, onBeforetoggle, onToggle
@docs actions, subhead, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.RichTooltip
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-rich-tooltip` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.RichTooltip.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.RichTooltip.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.RichTooltip.Content


{-| The kinds the `subhead` slot admits.
-}
type alias SubheadSlot =
    M3e.Internal.Types.RichTooltip.SubheadSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.RichTooltip.ChildAdmittedBy childAdm


{-| The `position` values valid on this component (compile-tight narrowing).
-}
type alias Position =
    M3e.Internal.Types.RichTooltip.Position


{-| The `touchGestures` values valid on this component (compile-tight narrowing).
-}
type alias TouchGestures =
    M3e.Internal.Types.RichTooltip.TouchGestures


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.RichTooltip.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.RichTooltip.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.RichTooltip.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.richTooltip attrs (required_.content :: children)


{-| The position of the tooltip. (default: `"below-after"`)
-}
position : Value Position -> Attr { c | position : Supported } msg
position value_ =
    Ir.attribute "position" (Val.toString value_)


{-| The mode in which to handle touch gestures. (default: `"auto"`)
-}
touchGestures : Value TouchGestures -> Attr { c | touchGestures : Supported } msg
touchGestures value_ =
    Ir.attribute "touch-gestures" (Val.toString value_)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.hideDelay`.
-}
hideDelay : Float -> Attr { c | hideDelay : Supported } msg
hideDelay =
    A.hideDelay


{-| See `M3e.Attributes.showDelay`.
-}
showDelay : Float -> Attr { c | showDelay : Supported } msg
showDelay =
    A.showDelay


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


{-| Place an element into the named `actions` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
actions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
actions element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "actions") (El.toNode element))


{-| Place an element into the named `subhead` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
subhead : Element SubheadSlot admittedBy msg -> Element free freeAdmittedBy msg
subhead element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "subhead") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
