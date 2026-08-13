module M3e.Component.NavMenu exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , child
    )

{-| The `m3e-nav-menu` component — strict per-component surface.

A hierarchical menu, typically used on larger devices, that allows a user to switch between views.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.NavMenu
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-nav-menu` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.NavMenu.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.NavMenu.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.NavMenu.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.NavMenu.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.navMenu


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
