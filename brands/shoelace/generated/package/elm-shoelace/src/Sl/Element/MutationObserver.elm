module Sl.Element.MutationObserver exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , attr, attrOldValue, charData, charDataOldValue, childList, disabled, onMutation
    , child
    )

{-| The `sl-mutation-observer` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs attr, attrOldValue, charData, charDataOldValue, childList, disabled, onMutation
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.MutationObserver
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-mutation-observer` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.MutationObserver.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.MutationObserver.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.MutationObserver.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.MutationObserver.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.MutationObserver.AttrCaps


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
    H.mutationObserver


{-| See `Sl.Attributes.attr`.
-}
attr : String -> Attr { c | attr : Supported } msg
attr =
    A.attr


{-| See `Sl.Attributes.attrOldValue`.
-}
attrOldValue : Bool -> Attr { c | attrOldValue : Supported } msg
attrOldValue =
    A.attrOldValue


{-| See `Sl.Attributes.charData`.
-}
charData : Bool -> Attr { c | charData : Supported } msg
charData =
    A.charData


{-| See `Sl.Attributes.charDataOldValue`.
-}
charDataOldValue : Bool -> Attr { c | charDataOldValue : Supported } msg
charDataOldValue =
    A.charDataOldValue


{-| See `Sl.Attributes.childList`.
-}
childList : Bool -> Attr { c | childList : Supported } msg
childList =
    A.childList


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Events.onMutation`.
-}
onMutation : msg -> Attr { c | onMutation : Supported } msg
onMutation =
    Ev.onMutation


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
