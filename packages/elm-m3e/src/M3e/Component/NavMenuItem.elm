module M3e.Component.NavMenuItem exposing
    ( view, el
    , Is, Attrs, Content, BadgeSlot, IconSlot, LabelSlot, SelectedIconSlot, ToggleIconSlot, ChildAdmittedBy
    , disabled, open, selected, defaultSelected, onOpening, onOpened, onClosing, onClosed, onClick
    , badge, icon, label, selectedIcon, toggleIcon, child
    )

{-| The `m3e-nav-menu-item` component — strict per-component surface.

An expandable item, selectable item within a navigation menu.

@docs view, el
@docs Is, Attrs, Content, BadgeSlot, IconSlot, LabelSlot, SelectedIconSlot, ToggleIconSlot, ChildAdmittedBy
@docs disabled, open, selected, defaultSelected, onOpening, onOpened, onClosing, onClosed, onClick
@docs badge, icon, label, selectedIcon, toggleIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.NavMenuItem
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-nav-menu-item` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.NavMenuItem.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.NavMenuItem.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.NavMenuItem.Content


{-| The kinds the `badge` slot admits.
-}
type alias BadgeSlot =
    M3e.Internal.Types.NavMenuItem.BadgeSlot


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.NavMenuItem.IconSlot


{-| The kinds the `label` slot admits.
-}
type alias LabelSlot =
    M3e.Internal.Types.NavMenuItem.LabelSlot


{-| The kinds the `selected-icon` slot admits.
-}
type alias SelectedIconSlot =
    M3e.Internal.Types.NavMenuItem.SelectedIconSlot


{-| The kinds the `toggle-icon` slot admits.
-}
type alias ToggleIconSlot =
    M3e.Internal.Types.NavMenuItem.ToggleIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.NavMenuItem.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.navMenuItem


{-| Required-content (and action) constructor — omissions are unwritable.
-}
el :
    { label : Element LabelSlot (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
el required_ attrs children =
    view attrs (Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (El.toNode required_.label)) :: children)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


{-| See `M3e.Attributes.selected`.
-}
selected : Bool -> Attr { c | selected : Supported } msg
selected =
    A.selected


{-| See `M3e.Attributes.defaultSelected`.
-}
defaultSelected : Bool -> Attr { c | selected : Supported } msg
defaultSelected =
    A.defaultSelected


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


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


{-| Place an element into the named `badge` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
badge : Element BadgeSlot admittedBy msg -> Element free freeAdmittedBy msg
badge element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "badge") (El.toNode element))


{-| Place an element into the named `icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
icon : Element IconSlot admittedBy msg -> Element free freeAdmittedBy msg
icon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (El.toNode element))


{-| Place an element into the named `label` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
label : Element LabelSlot admittedBy msg -> Element free freeAdmittedBy msg
label element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (El.toNode element))


{-| Place an element into the named `selected-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
selectedIcon : Element SelectedIconSlot admittedBy msg -> Element free freeAdmittedBy msg
selectedIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "selected-icon") (El.toNode element))


{-| Place an element into the named `toggle-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
toggleIcon : Element ToggleIconSlot admittedBy msg -> Element free freeAdmittedBy msg
toggleIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "toggle-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
