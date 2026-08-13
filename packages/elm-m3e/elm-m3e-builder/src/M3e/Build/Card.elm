module M3e.Build.Card exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withActionable, withClass, withDisabled, withDisabledInteractive, withDownload, withHref, withId, withInline, withName, withOnClick, withOrientation, withRel, withSlot, withStyle, withTarget, withType, withValue, withVariant
    , actions, content, footer, header
    , withActions, withContent, withFooter, withHeader, withChild
    )

{-| The builder module for `m3e-card` — seed, pipe, and close.

This module provides everything you need to BUILD with `Card`
using the pipe-builder pattern. Slot placers and slot pipes accept builders
directly — no `.toElement` needed at the call site.

For the standard `[attrs] [children]` constructor, use `M3e.Component.Card.view`.

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withActionable, withClass, withDisabled, withDisabledInteractive, withDownload, withHref, withId, withInline, withName, withOnClick, withOrientation, withRel, withSlot, withStyle, withTarget, withType, withValue, withVariant
@docs actions, content, footer, header
@docs withActions, withContent, withFooter, withHeader, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.Card as Component
import M3e.Events as Ev
import M3e.Internal.Types.Card
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| The kind this element produces — a `Brand` that marks the phantom row.
-}
type alias Is s =
    M3e.Internal.Types.Card.Is s


{-| The pipe-builder, closed over this component's `Attrs` row and `Is s` kind.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Card.Builder attrCaps slotCaps msg kind


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    M3e.Internal.Types.Card.AttrCaps


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    M3e.Internal.Types.Card.SlotCaps


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Card.ChildAdmittedBy childAdm


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-card" [] []


{-| Close the pipe-builder.
-}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| Place a builder-built element into the named `actions` slot — calls `B.toElement` internally.
-}
actions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
actions builder =
    Component.actions (B.toElement builder)


{-| Place a builder-built element into the named `content` slot — calls `B.toElement` internally.
-}
content :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
content builder =
    Component.content (B.toElement builder)


{-| Place a builder-built element into the named `footer` slot — calls `B.toElement` internally.
-}
footer :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
footer builder =
    Component.footer (B.toElement builder)


{-| Place a builder-built element into the named `header` slot — calls `B.toElement` internally.
-}
header :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
header builder =
    Component.header (B.toElement builder)


{-| Pipe form of the `actions` slot — accepts a builder directly (no `.toElement`).
-}
withActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | actions : Available } msg kind
    -> Builder attrCaps { s | actions : Used } msg kind
withActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.actions (B.toElement slotBuilder))) builder_


{-| Pipe form of the `content` slot — accepts a builder directly (no `.toElement`).
-}
withContent :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | content : Available } msg kind
    -> Builder attrCaps { s | content : Used } msg kind
withContent slotBuilder builder_ =
    B.withChild (El.toNode (Component.content (B.toElement slotBuilder))) builder_


{-| Pipe form of the `footer` slot — accepts a builder directly (no `.toElement`).
-}
withFooter :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | footer : Available } msg kind
    -> Builder attrCaps { s | footer : Used } msg kind
withFooter slotBuilder builder_ =
    B.withChild (El.toNode (Component.footer (B.toElement slotBuilder))) builder_


{-| Pipe form of the `header` slot — accepts a builder directly (no `.toElement`).
-}
withHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | header : Available } msg kind
    -> Builder attrCaps { s | header : Used } msg kind
withHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.header (B.toElement slotBuilder))) builder_


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


{-| Pipe form of `actionable` — consumes its capability (write-once).
-}
withActionable : Bool -> Builder { a | actionable : Available } slotCaps msg kind -> Builder { a | actionable : Used } slotCaps msg kind
withActionable value_ =
    B.withAttribute (A.actionable value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `disabledInteractive` — consumes its capability (write-once).
-}
withDisabledInteractive : Bool -> Builder { a | disabledInteractive : Available } slotCaps msg kind -> Builder { a | disabledInteractive : Used } slotCaps msg kind
withDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| Pipe form of `download` — consumes its capability (write-once).
-}
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| Pipe form of `href` — consumes its capability (write-once).
-}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| Pipe form of `inline` — consumes its capability (write-once).
-}
withInline : Bool -> Builder { a | inline : Available } slotCaps msg kind -> Builder { a | inline : Used } slotCaps msg kind
withInline value_ =
    B.withAttribute (A.inline value_)


{-| Pipe form of `name` — consumes its capability (write-once).
-}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| Pipe form of `orientation` — consumes its capability (write-once).
-}
withOrientation : Value Component.Orientation -> Builder { a | orientation : Available } slotCaps msg kind -> Builder { a | orientation : Used } slotCaps msg kind
withOrientation value_ =
    B.withAttribute (Component.orientation value_)


{-| Pipe form of `rel` — consumes its capability (write-once).
-}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| Pipe form of `target` — consumes its capability (write-once).
-}
withTarget : String -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (A.target value_)


{-| Pipe form of `type_` — consumes its capability (write-once).
-}
withType : Value Component.Type -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.type_ value_)


{-| Pipe form of `value` — consumes its capability (write-once).
-}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| Pipe form of `variant` — consumes its capability (write-once).
-}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| Pipe form of `onClick` — consumes its capability (write-once).
-}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
