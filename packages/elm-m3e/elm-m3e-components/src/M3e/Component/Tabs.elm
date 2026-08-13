module M3e.Component.Tabs exposing
    ( view
    , Is, Attrs, Content, NextIconSlot, PanelSlot, PrevIconSlot, ChildAdmittedBy
    , DisablePagination, disablePagination, HeaderPosition, headerPosition, Variant, variant
    , nextPageLabel, previousPageLabel, stretch, onChange, onBeforeinput, onInput
    , nextIcon, panel, prevIcon, child
    )

{-| The `m3e-tabs` component — strict per-component surface.

Organizes content into separate views where only one view can be visible at a time.

@docs view
@docs Is, Attrs, Content, NextIconSlot, PanelSlot, PrevIconSlot, ChildAdmittedBy
@docs DisablePagination, disablePagination, HeaderPosition, headerPosition, Variant, variant
@docs nextPageLabel, previousPageLabel, stretch, onChange, onBeforeinput, onInput
@docs nextIcon, panel, prevIcon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Tabs
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-tabs` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Tabs.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Tabs.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Tabs.Content


{-| The kinds the `next-icon` slot admits.
-}
type alias NextIconSlot =
    M3e.Internal.Types.Tabs.NextIconSlot


{-| The kinds the `panel` slot admits.
-}
type alias PanelSlot =
    M3e.Internal.Types.Tabs.PanelSlot


{-| The kinds the `prev-icon` slot admits.
-}
type alias PrevIconSlot =
    M3e.Internal.Types.Tabs.PrevIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Tabs.ChildAdmittedBy childAdm


{-| The `disablePagination` values valid on this component (compile-tight narrowing).
-}
type alias DisablePagination =
    M3e.Internal.Types.Tabs.DisablePagination


{-| The `headerPosition` values valid on this component (compile-tight narrowing).
-}
type alias HeaderPosition =
    M3e.Internal.Types.Tabs.HeaderPosition


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Tabs.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.tabs


{-| Whether scroll buttons are disabled.
-}
disablePagination : Value DisablePagination -> Attr { c | disablePagination : Supported } msg
disablePagination value_ =
    Ir.attribute "disable-pagination" (Val.toString value_)


{-| The position of the tab headers. (default: `"before"`)
-}
headerPosition : Value HeaderPosition -> Attr { c | headerPosition : Supported } msg
headerPosition value_ =
    Ir.attribute "header-position" (Val.toString value_)


{-| The appearance variant of the tabs. (default: `"secondary"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.nextPageLabel`.
-}
nextPageLabel : String -> Attr { c | nextPageLabel : Supported } msg
nextPageLabel =
    A.nextPageLabel


{-| See `M3e.Attributes.previousPageLabel`.
-}
previousPageLabel : String -> Attr { c | previousPageLabel : Supported } msg
previousPageLabel =
    A.previousPageLabel


{-| See `M3e.Attributes.stretch`.
-}
stretch : Bool -> Attr { c | stretch : Supported } msg
stretch =
    A.stretch


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onBeforeinput`.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput =
    Ev.onBeforeinput


{-| See `M3e.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| Place an element into the named `next-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
nextIcon : Element NextIconSlot admittedBy msg -> Element free freeAdmittedBy msg
nextIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "next-icon") (El.toNode element))


{-| Place an element into the named `panel` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
panel : Element PanelSlot admittedBy msg -> Element free freeAdmittedBy msg
panel element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "panel") (El.toNode element))


{-| Place an element into the named `prev-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
prevIcon : Element PrevIconSlot admittedBy msg -> Element free freeAdmittedBy msg
prevIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "prev-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
