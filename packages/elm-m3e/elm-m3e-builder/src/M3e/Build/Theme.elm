module M3e.Build.Theme exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withColor, withContrast, withDensity, withId, withMotion, withOnChange, withScheme, withSlot, withStrongFocus, withStyle, withVariant
    , withChild
    )

{-| The builder module for `m3e-theme` — seed, pipe, and close.

This module provides everything you need to BUILD with `Theme`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Theme.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withColor, withContrast, withDensity, withId, withMotion, withOnChange, withScheme, withSlot, withStrongFocus, withStyle, withVariant
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Theme as Component
import M3e.Events as Ev
import M3e.Internal.Types.Theme
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Theme.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Theme.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Theme.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Theme.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-theme" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Pipe form of a default-slot child (repeatable) — accepts a builder directly.
-}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| Pipe form of `class` — consumes its capability (write-once).
-}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| Pipe form of `id` — consumes its capability (write-once).
-}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| Pipe form of `slot` — consumes its capability (write-once).
-}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| Pipe form of `style` — consumes its capability (write-once).
-}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| Pipe form of `color` — consumes its capability (write-once).
-}
withColor : String -> Builder { a | color : Available } slotCaps msg kind -> Builder { a | color : Used } slotCaps msg kind
withColor value_ =
    B.withAttribute (A.color value_)


{-| Pipe form of `contrast` — consumes its capability (write-once).
-}
withContrast : Value Component.Contrast -> Builder { a | contrast : Available } slotCaps msg kind -> Builder { a | contrast : Used } slotCaps msg kind
withContrast value_ =
    B.withAttribute (Component.contrast value_)


{-| Pipe form of `density` — consumes its capability (write-once).
-}
withDensity : Float -> Builder { a | density : Available } slotCaps msg kind -> Builder { a | density : Used } slotCaps msg kind
withDensity value_ =
    B.withAttribute (A.density value_)


{-| Pipe form of `motion` — consumes its capability (write-once).
-}
withMotion : Value Component.Motion -> Builder { a | motion : Available } slotCaps msg kind -> Builder { a | motion : Used } slotCaps msg kind
withMotion value_ =
    B.withAttribute (Component.motion value_)


{-| Pipe form of `scheme` — consumes its capability (write-once).
-}
withScheme : Value Component.Scheme -> Builder { a | scheme : Available } slotCaps msg kind -> Builder { a | scheme : Used } slotCaps msg kind
withScheme value_ =
    B.withAttribute (Component.scheme value_)


{-| Pipe form of `strongFocus` — consumes its capability (write-once).
-}
withStrongFocus : Bool -> Builder { a | strongFocus : Available } slotCaps msg kind -> Builder { a | strongFocus : Used } slotCaps msg kind
withStrongFocus value_ =
    B.withAttribute (A.strongFocus value_)


{-| Pipe form of `variant` — consumes its capability (write-once).
-}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| Pipe form of `onChange` — consumes its capability (write-once).
-}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)
