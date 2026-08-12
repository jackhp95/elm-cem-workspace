module Mini.Chip exposing
    ( view, build, toElement
    , Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
    , Size, size
    , disabled
    , child
    , withChild, withClass, withDir, withDisabled, withId, withInert, withSize, withSlot, withStyle, withTabindex
    )

{-| The `mini-chip` component — strict per-component surface.

A compact labelled element.

@docs view, build, toElement
@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
@docs Size, size
@docs disabled
@docs child
@docs withChild, withClass, withDir, withDisabled, withId, withInert, withSize, withSlot, withStyle, withTabindex

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Attributes as A
import Mini.Build.Internal as B
import Mini.Html as H
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| The kind row `mini-chip` produces (open — composes into any slot naming it).
-}
type alias Is s =
    { s | chip : Brand }


{-| The closed attribute-capability row.
-}
type alias Attrs =
    { class : Supported
    , dir : Supported
    , disabled : Supported
    , id : Supported
    , inert : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The kinds the default slot admits.
-}
type alias Content =
    { sharedText : Shared }


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | chip : Ctx }


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    { big : Supported
    , small : Supported
    }


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.chip


{-| Chip size.
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| See `Mini.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)


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
    , dir : Available
    , disabled : Available
    , id : Available
    , inert : Available
    , size : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    }


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg
build =
    B.init "mini-chip" [] []


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


{-| Pipe form of `dir` — consumes its capability (write-once).
-}
withDir : Value Mini.Values.Dir -> Builder { a | dir : Available } slotCaps msg -> Builder { a | dir : Used } slotCaps msg
withDir value_ =
    B.withAttribute (A.dir value_)


{-| Pipe form of `id` — consumes its capability (write-once).
-}
withId : String -> Builder { a | id : Available } slotCaps msg -> Builder { a | id : Used } slotCaps msg
withId value_ =
    B.withAttribute (A.id value_)


{-| Pipe form of `inert` — consumes its capability (write-once).
-}
withInert : Bool -> Builder { a | inert : Available } slotCaps msg -> Builder { a | inert : Used } slotCaps msg
withInert value_ =
    B.withAttribute (A.inert value_)


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


{-| Pipe form of `tabindex` — consumes its capability (write-once).
-}
withTabindex : Int -> Builder { a | tabindex : Available } slotCaps msg -> Builder { a | tabindex : Used } slotCaps msg
withTabindex value_ =
    B.withAttribute (A.tabindex value_)


{-| Pipe form of `disabled` — consumes its capability (write-once).
-}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg -> Builder { a | disabled : Used } slotCaps msg
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| Pipe form of `size` — consumes its capability (write-once).
-}
withSize : Value Size -> Builder { a | size : Available } slotCaps msg -> Builder { a | size : Used } slotCaps msg
withSize value_ =
    B.withAttribute (size value_)


{-| Pipe form of a default-slot child (repeatable).
-}
withChild : Element Content (ChildAdmittedBy childAdm) msg -> Builder attrCaps slotCaps msg -> Builder attrCaps slotCaps msg
withChild element =
    B.withChild (El.toNode element)
