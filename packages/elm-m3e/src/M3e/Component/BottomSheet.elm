module M3e.Component.BottomSheet exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , detent, detents, handle, handleLabel, hideFriction, hideable, modal, open, overshootLimit, onOpening, onClosing, onCancel, onOpened, onClosed
    , header, child
    )

{-| The `m3e-bottom-sheet` component — strict per-component surface.

A sheet used to show secondary content anchored to the bottom of the screen.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs detent, detents, handle, handleLabel, hideFriction, hideable, modal, open, overshootLimit, onOpening, onClosing, onCancel, onOpened, onClosed
@docs header, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.BottomSheet
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-bottom-sheet` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.BottomSheet.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.BottomSheet.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.BottomSheet.ChildAdmittedBy childAdm


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
    H.bottomSheet


{-| See `M3e.Attributes.detent`.
-}
detent : Float -> Attr { c | detent : Supported } msg
detent =
    A.detent


{-| See `M3e.Attributes.detents`.
-}
detents : String -> Attr { c | detents : Supported } msg
detents =
    A.detents


{-| See `M3e.Attributes.handle`.
-}
handle : Bool -> Attr { c | handle : Supported } msg
handle =
    A.handle


{-| See `M3e.Attributes.handleLabel`.
-}
handleLabel : String -> Attr { c | handleLabel : Supported } msg
handleLabel =
    A.handleLabel


{-| See `M3e.Attributes.hideFriction`.
-}
hideFriction : Float -> Attr { c | hideFriction : Supported } msg
hideFriction =
    A.hideFriction


{-| See `M3e.Attributes.hideable`.
-}
hideable : Bool -> Attr { c | hideable : Supported } msg
hideable =
    A.hideable


{-| See `M3e.Attributes.modal`.
-}
modal : Bool -> Attr { c | modal : Supported } msg
modal =
    A.modal


{-| See `M3e.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `M3e.Attributes.overshootLimit`.
-}
overshootLimit : Float -> Attr { c | overshootLimit : Supported } msg
overshootLimit =
    A.overshootLimit


{-| See `M3e.Events.onOpening`.
-}
onOpening : msg -> Attr { c | onOpening : Supported } msg
onOpening =
    Ev.onOpening


{-| See `M3e.Events.onClosing`.
-}
onClosing : msg -> Attr { c | onClosing : Supported } msg
onClosing =
    Ev.onClosing


{-| See `M3e.Events.onCancel`.
-}
onCancel : msg -> Attr { c | onCancel : Supported } msg
onCancel =
    Ev.onCancel


{-| See `M3e.Events.onOpened`.
-}
onOpened : msg -> Attr { c | onOpened : Supported } msg
onOpened =
    Ev.onOpened


{-| See `M3e.Events.onClosed`.
-}
onClosed : msg -> Attr { c | onClosed : Supported } msg
onClosed =
    Ev.onClosed


{-| Place an element into the named `header` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
header : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
header element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
