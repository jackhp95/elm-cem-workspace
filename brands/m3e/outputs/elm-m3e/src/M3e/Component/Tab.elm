module M3e.Component.Tab exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, IconSlot, ChildAdmittedBy
    , disabled, for, selected, defaultSelected, onBeforeinput, onInput, onChange, onClick
    , icon, child
    )

{-| The `m3e-tab` component — strict per-component surface.

An interactive element that, when activated, presents an associated tab panel.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, IconSlot, ChildAdmittedBy
@docs disabled, for, selected, defaultSelected, onBeforeinput, onInput, onChange, onClick
@docs icon, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Tab
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-tab` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Tab.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Tab.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Tab.Content


{-| The kinds the `icon` slot admits.
-}
type alias IconSlot =
    M3e.Internal.Types.Tab.IconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Tab.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Tab.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Tab.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Tab.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.tab


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


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


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


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
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
