module M3e.Component.MenuItemCheckbox exposing
    ( view
    , Is, Attrs, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy
    , checked, disabled, defaultChecked, onClick
    , icon, trailingIcon, child
    )

{-| The `m3e-menu-item-checkbox` component — strict per-component surface.

An item of a menu which supports a checkable state.

@docs view
@docs Is, Attrs, Content, IconSlot, TrailingIconSlot, ChildAdmittedBy
@docs checked, disabled, defaultChecked, onClick
@docs icon, trailingIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.MenuItemCheckbox
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-menu-item-checkbox` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.MenuItemCheckbox.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.MenuItemCheckbox.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.MenuItemCheckbox.Content


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.MenuItemCheckbox.IconSlot


{-| The kinds the `trailing-icon` slot admits.
-}
type alias TrailingIconSlot =
    M3e.Internal.Types.MenuItemCheckbox.TrailingIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.MenuItemCheckbox.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.menuItemCheckbox


{-| See `M3e.Attributes.checked`.
-}
checked : Bool -> Attr { c | checked : Supported } msg
checked =
    A.checked


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.defaultChecked`.
-}
defaultChecked : Bool -> Attr { c | checked : Supported } msg
defaultChecked =
    A.defaultChecked


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
