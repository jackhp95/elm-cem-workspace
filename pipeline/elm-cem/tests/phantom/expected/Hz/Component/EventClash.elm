module Hz.Component.EventClash exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , onError, onHzError, onLoad, onHzLoad
    , child
    )

{-| The `hz-event-clash` component — strict per-component surface.

Tests K4: native error + hz-error events.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs onError, onHzError, onLoad, onHzLoad
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Events as Ev
import Hz.Html as H
import Hz.Internal.Types.EventClash
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-event-clash` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Hz.Internal.Types.EventClash.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Hz.Internal.Types.EventClash.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Hz.Internal.Types.EventClash.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Hz.Internal.Types.EventClash.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Hz.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Hz.Internal.Types.EventClash.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Hz.Internal.Types.EventClash.AttrCaps


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
