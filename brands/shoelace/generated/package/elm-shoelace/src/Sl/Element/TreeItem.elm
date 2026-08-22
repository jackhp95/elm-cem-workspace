module Sl.Element.TreeItem exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
    , disabled, expanded, lazy, selected, defaultSelected, onExpand, onAfterExpand, onCollapse, onAfterCollapse, onLazyChange, onLazyLoad
    , child
    )

{-| The `sl-tree-item` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, Content, ChildAdmittedBy
@docs disabled, expanded, lazy, selected, defaultSelected, onExpand, onAfterExpand, onCollapse, onAfterCollapse, onLazyChange, onLazyLoad
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.TreeItem
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-tree-item` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.TreeItem.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.TreeItem.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    Sl.Internal.Types.TreeItem.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.TreeItem.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.TreeItem.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.TreeItem.AttrCaps


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
    H.treeItem


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.expanded`.
-}
expanded : Bool -> Attr { c | expanded : Supported } msg
expanded =
    A.expanded


{-| See `Sl.Attributes.lazy`.
-}
lazy : Bool -> Attr { c | lazy : Supported } msg
lazy =
    A.lazy


{-| See `Sl.Attributes.selected`.
-}
selected : Bool -> Attr { c | selected : Supported } msg
selected =
    A.selected


{-| See `Sl.Attributes.defaultSelected`.
-}
defaultSelected : Bool -> Attr { c | selected : Supported } msg
defaultSelected =
    A.defaultSelected


{-| See `Sl.Events.onExpand`.
-}
onExpand : msg -> Attr { c | onExpand : Supported } msg
onExpand =
    Ev.onExpand


{-| See `Sl.Events.onAfterExpand`.
-}
onAfterExpand : msg -> Attr { c | onAfterExpand : Supported } msg
onAfterExpand =
    Ev.onAfterExpand


{-| See `Sl.Events.onCollapse`.
-}
onCollapse : msg -> Attr { c | onCollapse : Supported } msg
onCollapse =
    Ev.onCollapse


{-| See `Sl.Events.onAfterCollapse`.
-}
onAfterCollapse : msg -> Attr { c | onAfterCollapse : Supported } msg
onAfterCollapse =
    Ev.onAfterCollapse


{-| See `Sl.Events.onLazyChange`.
-}
onLazyChange : msg -> Attr { c | onLazyChange : Supported } msg
onLazyChange =
    Ev.onLazyChange


{-| See `Sl.Events.onLazyLoad`.
-}
onLazyLoad : msg -> Attr { c | onLazyLoad : Supported } msg
onLazyLoad =
    Ev.onLazyLoad


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
