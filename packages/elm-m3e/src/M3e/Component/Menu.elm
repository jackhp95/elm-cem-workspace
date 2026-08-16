module M3e.Component.Menu exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , PositionX, positionX, PositionY, positionY, Variant, variant
    , submenu, onBeforetoggle, onToggle
    , child
    )

{-| The `m3e-menu` component — strict per-component surface.

Presents a list of choices on a temporary surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs PositionX, positionX, PositionY, positionY, Variant, variant
@docs submenu, onBeforetoggle, onToggle
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Decode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Menu
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-menu` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Menu.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Menu.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Menu.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Menu.ChildAdmittedBy childAdm


{-| The `positionX` values valid on this component (compile-tight narrowing).
-}
type alias PositionX =
    M3e.Internal.Types.Menu.PositionX


{-| The `positionY` values valid on this component (compile-tight narrowing).
-}
type alias PositionY =
    M3e.Internal.Types.Menu.PositionY


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Menu.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Menu.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Menu.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.menu


{-| The position of the menu, on the x-axis. (default: `"after"`)
-}
positionX : Value PositionX -> Attr { c | positionX : Supported } msg
positionX value_ =
    Ir.attribute "position-x" (Val.toString value_)


{-| The position of the menu, on the y-axis. (default: `"below"`)
-}
positionY : Value PositionY -> Attr { c | positionY : Supported } msg
positionY value_ =
    Ir.attribute "position-y" (Val.toString value_)


{-| The appearance variant of the menu. (default: `"standard"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.submenu`.
-}
submenu : Bool -> Attr { c | submenu : Supported } msg
submenu =
    A.submenu


{-| See `M3e.Events.onBeforetoggle`.
-}
onBeforetoggle : msg -> Attr { c | onBeforetoggle : Supported } msg
onBeforetoggle =
    Ev.onBeforetoggle


{-| Typed `toggle` event: decodes `newState` as String.
-}
onToggle : (String -> msg) -> Attr { c | onToggle : Supported } msg
onToggle toMsg =
    Ir.on "toggle" (Json.Decode.map toMsg (Json.Decode.at [ "newState" ] Json.Decode.string))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
