module M3e.Component.ChipSet exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , vertical
    , child
    )

{-| The `m3e-chip-set` component — strict per-component surface.

A container used to organize chips into a cohesive unit.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs vertical
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.ChipSet
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-chip-set` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ChipSet.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ChipSet.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.ChipSet.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ChipSet.ChildAdmittedBy childAdm


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.chipSet


{-| See `M3e.Attributes.vertical`.
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical =
    A.vertical


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
