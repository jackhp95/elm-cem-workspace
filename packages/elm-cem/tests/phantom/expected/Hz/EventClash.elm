module Hz.EventClash exposing
    ( view, build, toElement
    , Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
    , onError, onHzError, onLoad, onHzLoad
    , child
    , withChild, withClass, withId, withOnError, withOnHzError, withOnHzLoad, withOnLoad, withSlot, withStyle
    )

{-| The `hz-event-clash` component — strict per-component surface.

Tests K4: native error + hz-error events.

@docs view, build, toElement
@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps, SlotCaps
@docs onError, onHzError, onLoad, onHzLoad
@docs child
@docs withChild, withClass, withId, withOnError, withOnHzError, withOnHzLoad, withOnLoad, withSlot, withStyle

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


{-| The kind row `hz-event-clash` produces (open — composes into any slot naming it).
-}
type alias Is s =
    { s | eventClash : Brand }


{-| The closed attribute-capability row.
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onError : Supported
    , onHzError : Supported
    , onHzLoad : Supported
    , onLoad : Supported
    , slot : Supported
    , style : Supported
    }


{-| The kinds the default slot admits.
-}
type alias Content =
    {}


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | eventClash : Ctx }


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.eventClash


{-| See `Hz.Events.onError`.
-}
onError : msg -> Attr { c | onError : Supported } msg
onError =
    Ev.onError


{-| See `Hz.Events.onHzError`.
-}
onHzError : msg -> Attr { c | onHzError : Supported } msg
onHzError =
    Ev.onHzError


{-| See `Hz.Events.onLoad`.
-}
onLoad : msg -> Attr { c | onLoad : Supported } msg
onLoad =
    Ev.onLoad


{-| See `Hz.Events.onHzLoad`.
-}
onHzLoad : msg -> Attr { c | onHzLoad : Supported } msg
onHzLoad =
    Ev.onHzLoad


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
    , id : Available
    , onError : Available
    , onHzError : Available
    , onHzLoad : Available
    , onLoad : Available
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
    B.init "hz-event-clash" [] []


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


{-| Pipe form of `onError` — consumes its capability (write-once).
-}
withOnError : msg -> Builder { a | onError : Available } slotCaps msg -> Builder { a | onError : Used } slotCaps msg
withOnError value_ =
    B.withAttribute (Ev.onError value_)


{-| Pipe form of `onHzError` — consumes its capability (write-once).
-}
withOnHzError : msg -> Builder { a | onHzError : Available } slotCaps msg -> Builder { a | onHzError : Used } slotCaps msg
withOnHzError value_ =
    B.withAttribute (Ev.onHzError value_)


{-| Pipe form of `onLoad` — consumes its capability (write-once).
-}
withOnLoad : msg -> Builder { a | onLoad : Available } slotCaps msg -> Builder { a | onLoad : Used } slotCaps msg
withOnLoad value_ =
    B.withAttribute (Ev.onLoad value_)


{-| Pipe form of `onHzLoad` — consumes its capability (write-once).
-}
withOnHzLoad : msg -> Builder { a | onHzLoad : Available } slotCaps msg -> Builder { a | onHzLoad : Used } slotCaps msg
withOnHzLoad value_ =
    B.withAttribute (Ev.onHzLoad value_)


{-| Pipe form of a default-slot child (repeatable).
-}
withChild : Element Content (ChildAdmittedBy childAdm) msg -> Builder attrCaps slotCaps msg -> Builder attrCaps slotCaps msg
withChild element =
    B.withChild (El.toNode element)
