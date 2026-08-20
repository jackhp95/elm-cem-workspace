module Sl.Component.TreeItem exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , disabled, expanded, lazy, selected, defaultSelected, onExpand, onAfterExpand, onCollapse, onAfterCollapse, onLazyChange, onLazyLoad
    )

{-| The `sl-tree-item` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs disabled, expanded, lazy, selected, defaultSelected, onExpand, onAfterExpand, onCollapse, onAfterCollapse, onLazyChange, onLazyLoad

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
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
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
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
