module M3e.Component.NavMenuItemGroup exposing
    ( view
    , Is, Attrs, Content, LabelSlot, ChildAdmittedBy
    , label, child
    )

{-| The `m3e-nav-menu-item-group` component — strict per-component surface.

A top-level semantic grouping of items in a navigation menu.

@docs view
@docs Is, Attrs, Content, LabelSlot, ChildAdmittedBy
@docs label, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.NavMenuItemGroup
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-nav-menu-item-group` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.NavMenuItemGroup.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.NavMenuItemGroup.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.NavMenuItemGroup.Content


{-| The kinds the `label` slot admits.
-}
type alias LabelSlot =
    M3e.Internal.Types.NavMenuItemGroup.LabelSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.NavMenuItemGroup.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.navMenuItemGroup


{-| Place an element into the named `label` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
label : Element LabelSlot admittedBy msg -> Element free freeAdmittedBy msg
label element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
