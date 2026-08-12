module Hz.AttrSlot exposing
    ( view, build, toElement
    , Is, Attrs, HintSlot, LabelSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
    , withHint, withLabel
    , hint, label
    , withClass, withHintSlot, withId, withLabelSlot, withSlot, withStyle, withWithHint, withWithLabel
    )

{-| The `hz-attr-slot` component — strict per-component surface.

Tests K5: attr with-hint + slot hint collision, and with-label/label.

@docs view, build, toElement
@docs Is, Attrs, HintSlot, LabelSlot, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
@docs withHint, withLabel
@docs hint, label
@docs withClass, withHintSlot, withId, withLabelSlot, withSlot, withStyle, withWithHint, withWithLabel

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Build.Internal as B
import Hz.Html as H
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-attr-slot` produces (open — composes into any slot naming it).
-}
type alias Is s =
    { s | attrSlot : Brand }


{-| The closed attribute-capability row.
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , withHint : Supported
    , withLabel : Supported
    }


{-| The kinds the `hint` slot admits.
-}
type alias HintSlot =
    {}


{-| The kinds the `label` slot admits.
-}
type alias LabelSlot =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | attrSlot : Ctx }


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.attrSlot


{-| See `Hz.Attributes.withHint`.
-}
withHint : Bool -> Attr { c | withHint : Supported } msg
withHint =
    A.withHint


{-| See `Hz.Attributes.withLabel`.
-}
withLabel : Bool -> Attr { c | withLabel : Supported } msg
withLabel =
    A.withLabel


{-| Place an element into the named `hint` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
hint : Element HintSlot admittedBy msg -> Element free freeAdmittedBy msg
hint element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "hint") (El.toNode element))


{-| Place an element into the named `label` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
label : Element LabelSlot admittedBy msg -> Element free freeAdmittedBy msg
label element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (El.toNode element))


{-| The pipe-builder: capabilities are consumed Available→Used, so writing
a singular attribute or slot twice is unwritable. Aliases the shared builder in
`Build.Internal`, closed over this component's `Attrs` row.
-}
type alias Builder attrCaps slotCaps msg =
    B.Builder Attrs attrCaps slotCaps msg


{-| Every attribute/event capability, still writable.
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , slot : Available
    , style : Available
    , withHint : Available
    , withLabel : Available
    }


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    { hint : Available
    , label : Available
    }


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg
build =
    B.init "hz-attr-slot" [] []


{-| Close the pipe-builder (`toElement` is defined once in `Build.Internal`).
-}
toElement : Builder attrCaps slotCaps msg -> Element (Is s) admittedBy msg
toElement =
    B.toElement


{-| Pipe form of `class` — consumes its capability (write-once).
-}
withClass : String -> Builder { a | class : Available } slotCaps msg -> Builder { a | class : Used } slotCaps msg
withClass value_ =
    B.withAttribute (A.class value_)


{-| Pipe form of `id` — consumes its capability (write-once).
-}
withId : String -> Builder { a | id : Available } slotCaps msg -> Builder { a | id : Used } slotCaps msg
withId value_ =
    B.withAttribute (A.id value_)


{-| Pipe form of `slot` — consumes its capability (write-once).
-}
withSlot : String -> Builder { a | slot : Available } slotCaps msg -> Builder { a | slot : Used } slotCaps msg
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| Pipe form of `style` — consumes its capability (write-once).
-}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg -> Builder { a | style : Used } slotCaps msg
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| Pipe form of `withHint` — consumes its capability (write-once).
-}
withWithHint : Bool -> Builder { a | withHint : Available } slotCaps msg -> Builder { a | withHint : Used } slotCaps msg
withWithHint value_ =
    B.withAttribute (A.withHint value_)


{-| Pipe form of `withLabel` — consumes its capability (write-once).
-}
withWithLabel : Bool -> Builder { a | withLabel : Available } slotCaps msg -> Builder { a | withLabel : Used } slotCaps msg
withWithLabel value_ =
    B.withAttribute (A.withLabel value_)


{-| Pipe form of the `hint` slot — consumes its capability (write-once).
-}
withHintSlot : Element HintSlot admittedBy msg -> Builder attrCaps { s | hint : Available } msg -> Builder attrCaps { s | hint : Used } msg
withHintSlot element =
    B.withChild (El.toNode (hint element))


{-| Pipe form of the `label` slot — consumes its capability (write-once).
-}
withLabelSlot : Element LabelSlot admittedBy msg -> Builder attrCaps { s | label : Available } msg -> Builder attrCaps { s | label : Used } msg
withLabelSlot element =
    B.withChild (El.toNode (label element))
