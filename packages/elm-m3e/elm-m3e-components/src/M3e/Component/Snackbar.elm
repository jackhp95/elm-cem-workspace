module M3e.Component.Snackbar exposing
    ( view, el
    , Is, Attrs, Content, CloseIconSlot, ChildAdmittedBy
    , action, closeLabel, dismissible, duration, onBeforetoggle, onToggle
    , closeIcon, child
    )

{-| The `m3e-snackbar` component — strict per-component surface.

Presents short updates about application processes at the bottom of the screen.

@docs view, el
@docs Is, Attrs, Content, CloseIconSlot, ChildAdmittedBy
@docs action, closeLabel, dismissible, duration, onBeforetoggle, onToggle
@docs closeIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Snackbar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-snackbar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Snackbar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Snackbar.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Snackbar.Content


{-| The kinds the `close-icon` slot admits.
-}
type alias CloseIconSlot =
    M3e.Internal.Types.Snackbar.CloseIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Snackbar.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.snackbar


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (required_.content :: children)


{-| See `M3e.Attributes.action`.
-}
action : String -> Attr { c | action : Supported } msg
action =
    A.action


{-| See `M3e.Attributes.closeLabel`.
-}
closeLabel : String -> Attr { c | closeLabel : Supported } msg
closeLabel =
    A.closeLabel


{-| See `M3e.Attributes.dismissible`.
-}
dismissible : Bool -> Attr { c | dismissible : Supported } msg
dismissible =
    A.dismissible


{-| See `M3e.Attributes.duration`.
-}
duration : Float -> Attr { c | duration : Supported } msg
duration =
    A.duration


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


{-| Place an element into the named `close-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
closeIcon : Element CloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
closeIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "close-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
