module Or.Widget exposing
    ( view, build, toElement
    , Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
    , label
    , child
    , withCdir, withCflag, withChild, withClass, withLabel
    )

{-| The `or-widget` component — strict per-component surface.

An element with one attribute of its own, so its `Attrs` row is a mix of global and CEM fields.

@docs view, build, toElement
@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
@docs label
@docs child
@docs withCdir, withCflag, withChild, withClass, withLabel

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Or.Attributes as A
import Or.Build.Internal as B
import Or.Html as H
import Or.Kind exposing (Available, Brand, Ctx, Used)
import Or.Values


{-| The kind row `or-widget` produces (open — composes into any slot naming it).
-}
type alias Is s =
    { s | widget : Brand }


{-| The closed attribute-capability row.
-}
type alias Attrs =
    { cdir : Supported
    , cflag : Supported
    , class : Supported
    , label : Supported
    }


{-| The kinds the default slot admits.
-}
type alias Content =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | widget : Ctx }


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.widget


{-| See `Or.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


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
    { cdir : Available
    , cflag : Available
    , class : Available
    , label : Available
    }


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg
build =
    B.init "or-widget" [] []


{-| Close the pipe-builder (`toElement` is defined once in `Build.Internal`).
-}
toElement : Builder attrCaps slotCaps msg -> Element (Is s) admittedBy msg
toElement =
    B.toElement


{-| Pipe form of `cdir` — consumes its capability (write-once).
-}
withCdir : Value Or.Values.Cdir -> Builder { a | cdir : Available } slotCaps msg -> Builder { a | cdir : Used } slotCaps msg
withCdir value_ =
    B.withAttribute (A.cdir value_)


{-| Pipe form of `cflag` — consumes its capability (write-once).
-}
withCflag : Bool -> Builder { a | cflag : Available } slotCaps msg -> Builder { a | cflag : Used } slotCaps msg
withCflag value_ =
    B.withAttribute (A.cflag value_)


{-| Pipe form of `class` — consumes its capability (write-once).
-}
withClass : String -> Builder { a | class : Available } slotCaps msg -> Builder { a | class : Used } slotCaps msg
withClass value_ =
    B.withAttribute (A.class value_)


{-| Pipe form of `label` — consumes its capability (write-once).
-}
withLabel : String -> Builder { a | label : Available } slotCaps msg -> Builder { a | label : Used } slotCaps msg
withLabel value_ =
    B.withAttribute (A.label value_)


{-| Pipe form of a default-slot child (repeatable).
-}
withChild : Element Content (ChildAdmittedBy childAdm) msg -> Builder attrCaps slotCaps msg -> Builder attrCaps slotCaps msg
withChild element =
    B.withChild (El.toNode element)
