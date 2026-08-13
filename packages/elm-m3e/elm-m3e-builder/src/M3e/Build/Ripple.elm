module M3e.Build.Ripple exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withCentered, withClass, withDisabled, withFor, withId, withRadius, withSlot, withStyle, withUnbounded
    )

{-| The builder module for `m3e-ripple` — seed, pipe, and close.

This module provides everything you need to BUILD with `Ripple`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Ripple.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withCentered, withClass, withDisabled, withFor, withId, withRadius, withSlot, withStyle, withUnbounded

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Ripple as Component
import M3e.Internal.Types.Ripple
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Ripple.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Ripple.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Ripple.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Ripple.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-ripple" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


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


{-| Pipe form of `centered` — consumes its capability (write-once).
-}
withCentered : Bool -> Builder { a | centered : Available } slotCaps msg kind -> Builder { a | centered : Used } slotCaps msg kind
withCentered value_ =
    B.withAttribute (A.centered value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `for` — consumes its capability (write-once).
-}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| Pipe form of `radius` — consumes its capability (write-once).
-}
withRadius : Float -> Builder { a | radius : Available } slotCaps msg kind -> Builder { a | radius : Used } slotCaps msg kind
withRadius value_ =
    B.withAttribute (A.radius value_)


{-| Pipe form of `unbounded` — consumes its capability (write-once).
-}
withUnbounded : Bool -> Builder { a | unbounded : Available } slotCaps msg kind -> Builder { a | unbounded : Used } slotCaps msg kind
withUnbounded value_ =
    B.withAttribute (A.unbounded value_)
