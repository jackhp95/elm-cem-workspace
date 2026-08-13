module M3e.Build.Heading exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withClass, withEmphasized, withId, withLevel, withSize, withSlot, withStyle, withTocIgnore, withVariant
    , withChild
    )

{-| The builder module for `m3e-heading` — seed, pipe, and close.

This module provides everything you need to BUILD with `Heading`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Heading.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withClass, withEmphasized, withId, withLevel, withSize, withSlot, withStyle, withTocIgnore, withVariant
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Heading as Component
import M3e.Internal.Types.Heading
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Heading.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Heading.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Heading.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Heading.ChildAdmittedBy childAdm


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.Heading.Content


{-| Seed the pipe-builder with required content (and action).
-}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-heading" [] [ El.toNode required_.content ]


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


{-| Pipe form of `emphasized` — consumes its capability (write-once).
-}
withEmphasized : Bool -> Builder { a | emphasized : Available } slotCaps msg kind -> Builder { a | emphasized : Used } slotCaps msg kind
withEmphasized value_ =
    B.withAttribute (A.emphasized value_)


{-| Pipe form of `level` — consumes its capability (write-once).
-}
withLevel : Int -> Builder { a | level : Available } slotCaps msg kind -> Builder { a | level : Used } slotCaps msg kind
withLevel value_ =
    B.withAttribute (A.level value_)


{-| Pipe form of `size` — consumes its capability (write-once).
-}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)


{-| Pipe form of `tocIgnore` — consumes its capability (write-once).
-}
withTocIgnore : Bool -> Builder { a | tocIgnore : Available } slotCaps msg kind -> Builder { a | tocIgnore : Used } slotCaps msg kind
withTocIgnore value_ =
    B.withAttribute (A.tocIgnore value_)


{-| Pipe form of `variant` — consumes its capability (write-once).
-}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)
