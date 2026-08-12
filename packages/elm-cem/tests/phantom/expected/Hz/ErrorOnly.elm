module Hz.ErrorOnly exposing
    ( view, build, toElement
    , Is, Attrs, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
    , onHzError
    , withClass, withId, withOnHzError, withSlot, withStyle
    )

{-| The `hz-error-only` component — strict per-component surface.

Tests K4 acid probe: component with only hz-error event, no native error.

@docs view, build, toElement
@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
@docs onHzError
@docs withClass, withId, withOnHzError, withSlot, withStyle

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Build.Internal as B
import Hz.Events as Ev
import Hz.Html as H
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-error-only` produces (open — composes into any slot naming it).
-}
type alias Is s =
    { s | errorOnly : Brand }


{-| The closed attribute-capability row.
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onHzError : Supported
    , slot : Supported
    , style : Supported
    }


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | errorOnly : Ctx }


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.errorOnly


{-| See `Hz.Events.onHzError`.
-}
onHzError : msg -> Attr { c | onHzError : Supported } msg
onHzError =
    Ev.onHzError


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
    , onHzError : Available
    , slot : Available
    , style : Available
    }


{-| Every singular named-slot capability, still writable.
-}
type alias SlotCaps =
    {}


{-| Seed the pipe-builder.
-}
build : Builder AttrCaps SlotCaps msg
build =
    B.init "hz-error-only" [] []


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


{-| Pipe form of `onHzError` — consumes its capability (write-once).
-}
withOnHzError : msg -> Builder { a | onHzError : Available } slotCaps msg -> Builder { a | onHzError : Used } slotCaps msg
withOnHzError value_ =
    B.withAttribute (Ev.onHzError value_)
