module Sl.Element.Tree exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , Selection, selection
    , onSelectionChange
    , child
    )

{-| The `sl-tree` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs Selection, selection
@docs onSelectionChange
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Tree
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-tree` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Tree.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Tree.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Sl.Internal.Types.Tree.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Tree.ChildAdmittedBy childAdm


{-| The `selection` values valid on this component (compile-tight narrowing).
-}
type alias Selection =
    Sl.Internal.Types.Tree.Selection


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Tree.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Tree.AttrCaps


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
    H.tree


{-| The selection behavior of the tree. Single selection allows only one node to be selected at a time. Multiple
displays checkboxes and allows more than one node to be selected. Leaf allows only leaf nodes to be selected. (default: `'single'`)
-}
selection : Value Selection -> Attr { c | selection : Supported } msg
selection value_ =
    Ir.attribute "selection" (Val.toString value_)


{-| See `Sl.Events.onSelectionChange`.
-}
onSelectionChange : msg -> Attr { c | onSelectionChange : Supported } msg
onSelectionChange =
    Ev.onSelectionChange


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
