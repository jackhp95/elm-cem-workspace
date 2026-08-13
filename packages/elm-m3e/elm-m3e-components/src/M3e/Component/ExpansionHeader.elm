module M3e.Component.ExpansionHeader exposing
    ( view
    , Is, Attrs, Content, ToggleIconSlot, ChildAdmittedBy
    , ToggleDirection, toggleDirection, TogglePosition, togglePosition
    , disabled, hideToggle, onClick
    , toggleIcon, child
    )

{-| The `m3e-expansion-header` component — strict per-component surface.

A button used to toggle the expanded state of an expansion panel.

@docs view
@docs Is, Attrs, Content, ToggleIconSlot, ChildAdmittedBy
@docs ToggleDirection, toggleDirection, TogglePosition, togglePosition
@docs disabled, hideToggle, onClick
@docs toggleIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.ExpansionHeader
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-expansion-header` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ExpansionHeader.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ExpansionHeader.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.ExpansionHeader.Content


{-| The kinds the `toggle-icon` slot admits.
-}
type alias ToggleIconSlot =
    M3e.Internal.Types.ExpansionHeader.ToggleIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ExpansionHeader.ChildAdmittedBy childAdm


{-| The `toggleDirection` values valid on this component (compile-tight narrowing).
-}
type alias ToggleDirection =
    M3e.Internal.Types.ExpansionHeader.ToggleDirection


{-| The `togglePosition` values valid on this component (compile-tight narrowing).
-}
type alias TogglePosition =
    M3e.Internal.Types.ExpansionHeader.TogglePosition


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.expansionHeader


{-| The direction of the expansion toggle. (default: `"vertical"`)
-}
toggleDirection : Value ToggleDirection -> Attr { c | toggleDirection : Supported } msg
toggleDirection value_ =
    Ir.attribute "toggle-direction" (Val.toString value_)


{-| The position of the expansion toggle. (default: `"after"`)
-}
togglePosition : Value TogglePosition -> Attr { c | togglePosition : Supported } msg
togglePosition value_ =
    Ir.attribute "toggle-position" (Val.toString value_)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.hideToggle`.
-}
hideToggle : Bool -> Attr { c | hideToggle : Supported } msg
hideToggle =
    A.hideToggle


{-| See `M3e.Events.onClick`.
-}
onClick : msg -> Attr { c | onClick : Supported } msg
onClick =
    Ev.onClick


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
