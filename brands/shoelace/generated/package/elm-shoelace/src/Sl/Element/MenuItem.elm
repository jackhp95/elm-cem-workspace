module Sl.Element.MenuItem exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, SubmenuSlot, ChildAdmittedBy
    , Type, type_
    , checked, disabled, loading, value, defaultChecked, defaultValue
    , submenu, child
    )

{-| The `sl-menu-item` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, SubmenuSlot, ChildAdmittedBy
@docs Type, type_
@docs checked, disabled, loading, value, defaultChecked, defaultValue
@docs submenu, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Html as H
import Sl.Internal.Types.MenuItem
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-menu-item` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.MenuItem.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.MenuItem.Attrs


{-| The kinds the `submenu` slot admits.
-}
type alias SubmenuSlot =
    Sl.Internal.Types.MenuItem.SubmenuSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.MenuItem.ChildAdmittedBy childAdm


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    Sl.Internal.Types.MenuItem.Type


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.MenuItem.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.MenuItem.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    Sl.Internal.Types.MenuItem.SlotCaps


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.menuItem


{-| The type of menu item to render. To use `checked`, this value must be set to `checkbox`. (default: `'normal'`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| See `Sl.Attributes.checked`.
-}
checked : Bool -> Attr { c | checked : Supported } msg
checked =
    A.checked


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| Draws the menu item in a loading state. (default: `false`)
-}
loading : Bool -> Attr { c | loading : Supported } msg
loading value_ =
    if value_ then
        Ir.attribute "loading" ""

    else
        Ir.none


{-| See `Sl.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `Sl.Attributes.defaultChecked`.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked =
    A.defaultChecked


{-| See `Sl.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


{-| Place an element into the named `submenu` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
submenu : Element SubmenuSlot admittedBy msg -> Element free freeAdmittedBy msg
submenu element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "submenu") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
