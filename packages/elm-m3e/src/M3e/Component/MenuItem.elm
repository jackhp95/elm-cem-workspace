module M3e.Component.MenuItem exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy
    , disabled, download, href, rel, target, onClick
    , icon, trailingIcon, child
    )

{-| The `m3e-menu-item` component — strict per-component surface.

An item of a menu.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy
@docs disabled, download, href, rel, target, onClick
@docs icon, trailingIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.MenuItem
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-menu-item` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.MenuItem.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.MenuItem.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.MenuItem.Content


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.MenuItem.IconSlot


{-| The kinds the `trailing-icon` slot admits.
-}
type alias TrailingIconSlot =
    M3e.Internal.Types.MenuItem.TrailingIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.MenuItem.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.MenuItem.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.MenuItem.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.MenuItem.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.menuItem


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.download`.
-}
download : String -> Attr { c | download : Supported } msg
download =
    A.download


{-| See `M3e.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    A.href


{-| See `M3e.Attributes.rel`.
-}
rel : String -> Attr { c | rel : Supported } msg
rel =
    A.rel


{-| See `M3e.Attributes.target`.
-}
target : String -> Attr { c | target : Supported } msg
target =
    A.target


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


{-| Place an element into the named `icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
icon : Element IconSlot admittedBy msg -> Element free freeAdmittedBy msg
icon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (El.toNode element))


{-| Place an element into the named `trailing-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
trailingIcon : Element TrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
trailingIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "trailing-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
