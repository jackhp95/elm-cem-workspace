module Mini.Component.Surface exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , grid, gridAsInts
    , child
    )

{-| The `mini-surface` component — strict per-component surface.

A kind-permissive layout container (still context-gating).

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs grid, gridAsInts
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import Mini.Attributes as A
import Mini.Html as H
import Mini.Internal.Types.Surface
import Mini.Kind exposing (Available, Brand, Ctx, Used)
import Mini.Values


{-| The kind row `mini-surface` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Mini.Internal.Types.Surface.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Mini.Internal.Types.Surface.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Mini.Internal.Types.Surface.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Mini.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Mini.Internal.Types.Surface.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Mini.Internal.Types.Surface.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.surface


{-| See `Mini.Attributes.grid`.
-}
grid : String -> Attr { c | grid : Supported } msg
grid =
    A.grid


{-| See `Mini.Attributes.gridAsInts`.
-}
gridAsInts : List Int -> Attr { c | grid : Supported } msg
gridAsInts =
    A.gridAsInts


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
