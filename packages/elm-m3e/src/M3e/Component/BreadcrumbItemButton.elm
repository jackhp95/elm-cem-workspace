module M3e.Component.BreadcrumbItemButton exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , Current, current
    , disabled, download, href, rel, target, onClick
    , child
    )

{-| The `m3e-breadcrumb-item-button` component — strict per-component surface.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs Current, current
@docs disabled, download, href, rel, target, onClick
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.BreadcrumbItemButton
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-breadcrumb-item-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.BreadcrumbItemButton.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.BreadcrumbItemButton.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.BreadcrumbItemButton.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.BreadcrumbItemButton.ChildAdmittedBy childAdm


{-| The `current` values valid on this component (compile-tight narrowing).
-}
type alias Current =
    M3e.Internal.Types.BreadcrumbItemButton.Current


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.breadcrumbItemButton


{-| Indicates the current item in the breadcrumb path.
-}
current : Value Current -> Attr { c | current : Supported } msg
current value_ =
    Ir.attribute "current" (Val.toString value_)


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


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
