module M3e.Component.Collapsible exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Orientation, orientation
    , noAnimate, open, onOpening, onOpened, onClosing, onClosed
    , child
    )

{-| The `m3e-collapsible` component — strict per-component surface.

A container used to expand and collapse content.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Orientation, orientation
@docs noAnimate, open, onOpening, onOpened, onClosing, onClosed
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Collapsible
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-collapsible` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Collapsible.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Collapsible.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Collapsible.ChildAdmittedBy childAdm


{-| The `orientation` values valid on this component (compile-tight narrowing).
-}
type alias Orientation =
    M3e.Internal.Types.Collapsible.Orientation


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
    H.collapsible


{-| Orientation of collapsible content. (default: `"vertical"`)
-}
orientation : Value Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (Val.toString value_)


{-| See `M3e.Attributes.noAnimate`.
-}
noAnimate : Bool -> Attr { c | noAnimate : Supported } msg
noAnimate =
    A.noAnimate


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


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
