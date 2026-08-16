module M3e.Component.Select exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ArrowSlot, ChildAdmittedBy
    , disabled, hideSelectionIndicator, multi, name, panelClass, required, validationmessages, onChange, onToggle, onBeforeinput, onInput
    , arrow, value, child
    )

{-| The `m3e-select` component — strict per-component surface.

A form control that allows users to select a value from a set of predefined options.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ArrowSlot, ChildAdmittedBy
@docs disabled, hideSelectionIndicator, multi, name, panelClass, required, validationmessages, onChange, onToggle, onBeforeinput, onInput
@docs arrow, value, child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import Json.Decode
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Select
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-select` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Select.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Select.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Select.Content


{-| The kinds the `arrow` slot admits.
-}
type alias ArrowSlot =
    M3e.Internal.Types.Select.ArrowSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Select.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Select.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Select.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.Select.SlotCaps


{-| Required-content (and action) constructor — omissions are unwritable.
-}
component :
    { content : Element Content (ChildAdmittedBy childAdm) msg }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component required_ attrs children =
    H.select attrs (required_.content :: children)


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.hideSelectionIndicator`.
-}
hideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
hideSelectionIndicator =
    A.hideSelectionIndicator


{-| See `M3e.Attributes.multi`.
-}
multi : Bool -> Attr { c | multi : Supported } msg
multi =
    A.multi


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.panelClass`.
-}
panelClass : String -> Attr { c | panelClass : Supported } msg
panelClass =
    A.panelClass


{-| See `M3e.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    A.required


{-| See `M3e.Attributes.validationmessages`.
-}
validationmessages : String -> Attr { c | validationmessages : Supported } msg
validationmessages =
    A.validationmessages


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Typed `toggle` event: decodes `newState` as String.
-}
onToggle : (String -> msg) -> Attr { c | onToggle : Supported } msg
onToggle toMsg =
    Ir.on "toggle" (Json.Decode.map toMsg (Json.Decode.at [ "newState" ] Json.Decode.string))


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


{-| Place an element into the named `arrow` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
arrow : Element ArrowSlot admittedBy msg -> Element free freeAdmittedBy msg
arrow element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "arrow") (El.toNode element))


{-| Place an element into the named `value` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
value : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
value element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "value") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
