module Hz.Component.Global exposing
    ( view
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , child
    )

{-| The `hz-global` component — strict per-component surface.

Tests K2: redeclares global attrs id, class, slot, style.

@docs view
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Html as H
import Hz.Internal.Types.Global
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-global` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Hz.Internal.Types.Global.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Hz.Internal.Types.Global.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Hz.Internal.Types.Global.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Hz.Internal.Types.Global.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Hz.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Hz.Internal.Types.Global.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Hz.Internal.Types.Global.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.global


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
