module M3e.Component.FabMenuItem exposing
    ( view
    , Is, Attrs, IconSlot, ChildAdmittedBy
    , disabled, download, href, rel, target, onClick
    , icon, child
    )

{-| The `m3e-fab-menu-item` component — strict per-component surface.

An item of a floating action button (FAB) menu.

@docs view
@docs Is, Attrs, IconSlot, ChildAdmittedBy
@docs disabled, download, href, rel, target, onClick
@docs icon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.FabMenuItem
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-fab-menu-item` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.FabMenuItem.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.FabMenuItem.Attrs


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.FabMenuItem.IconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.FabMenuItem.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.fabMenuItem


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


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
