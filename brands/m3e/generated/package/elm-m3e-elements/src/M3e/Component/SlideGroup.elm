module M3e.Component.SlideGroup exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, NextIconSlot, PrevIconSlot, ChildAdmittedBy
    , disabled, nextPageLabel, previousPageLabel, threshold, vertical
    , nextIcon, prevIcon, child
    )

{-| The `m3e-slide-group` component — strict per-component surface.

Presents pagination controls used to scroll overflowing content.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, NextIconSlot, PrevIconSlot, ChildAdmittedBy
@docs disabled, nextPageLabel, previousPageLabel, threshold, vertical
@docs nextIcon, prevIcon, child


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
M3e.Component.SlideGroup.component [] [ TypedHtml.div [] [ M3e.text "Item 1" ], TypedHtml.div [] [ M3e.text "Item 2" ], TypedHtml.div [] [ M3e.text "Item 3" ], TypedHtml.div [] [ M3e.text "Item 4" ], TypedHtml.div [] [ M3e.text "Item 5" ], TypedHtml.div [] [ M3e.text "Item 6" ], TypedHtml.div [] [ M3e.text "Item 7" ], TypedHtml.div [] [ M3e.text "Item 8" ], TypedHtml.div [] [ M3e.text "Item 9" ], TypedHtml.div [] [ M3e.text "Item 10" ], TypedHtml.div [] [ M3e.text "Item 11" ], TypedHtml.div [] [ M3e.text "Item 12" ], TypedHtml.div [] [ M3e.text "Item 13" ], TypedHtml.div [] [ M3e.text "Item 14" ], TypedHtml.div [] [ M3e.text "Item 15" ], TypedHtml.div [] [ M3e.text "Item 16" ], TypedHtml.div [] [ M3e.text "Item 17" ], TypedHtml.div [] [ M3e.text "Item 18" ], TypedHtml.div [] [ M3e.text "Item 19" ], TypedHtml.div [] [ M3e.text "Item 20" ] ]
```

<!-- elm-cem:example title="Orientation" -->
```elm
M3e.Component.SlideGroup.component [ M3e.Component.SlideGroup.vertical True ] [ TypedHtml.div [] [ M3e.text "Item 1" ], TypedHtml.div [] [ M3e.text "Item 2" ], TypedHtml.div [] [ M3e.text "Item 3" ], TypedHtml.div [] [ M3e.text "Item 4" ], TypedHtml.div [] [ M3e.text "Item 5" ], TypedHtml.div [] [ M3e.text "Item 6" ], TypedHtml.div [] [ M3e.text "Item 7" ], TypedHtml.div [] [ M3e.text "Item 8" ], TypedHtml.div [] [ M3e.text "Item 9" ], TypedHtml.div [] [ M3e.text "Item 10" ], TypedHtml.div [] [ M3e.text "Item 11" ], TypedHtml.div [] [ M3e.text "Item 12" ], TypedHtml.div [] [ M3e.text "Item 13" ], TypedHtml.div [] [ M3e.text "Item 14" ], TypedHtml.div [] [ M3e.text "Item 15" ], TypedHtml.div [] [ M3e.text "Item 16" ], TypedHtml.div [] [ M3e.text "Item 17" ], TypedHtml.div [] [ M3e.text "Item 18" ], TypedHtml.div [] [ M3e.text "Item 19" ], TypedHtml.div [] [ M3e.text "Item 20" ] ]
```

<!-- elm-cem:docmeta category=Navigation -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.SlideGroup
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-slide-group` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.SlideGroup.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.SlideGroup.Attrs


{-| The kinds the `next-icon` slot admits.
-}
type alias NextIconSlot =
    M3e.Internal.Types.SlideGroup.NextIconSlot


{-| The kinds the `prev-icon` slot admits.
-}
type alias PrevIconSlot =
    M3e.Internal.Types.SlideGroup.PrevIconSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SlideGroup.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SlideGroup.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.SlideGroup.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    M3e.Internal.Types.SlideGroup.SlotCaps


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
    H.slideGroup


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.nextPageLabel`.
-}
nextPageLabel : String -> Attr { c | nextPageLabel : Supported } msg
nextPageLabel =
    A.nextPageLabel


{-| See `M3e.Attributes.previousPageLabel`.
-}
previousPageLabel : String -> Attr { c | previousPageLabel : Supported } msg
previousPageLabel =
    A.previousPageLabel


{-| See `M3e.Attributes.threshold`.
-}
threshold : Float -> Attr { c | threshold : Supported } msg
threshold =
    A.threshold


{-| See `M3e.Attributes.vertical`.
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical =
    A.vertical


{-| Place an element into the named `next-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
nextIcon : Element NextIconSlot admittedBy msg -> Element free freeAdmittedBy msg
nextIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "next-icon") (El.toNode element))


{-| Place an element into the named `prev-icon` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
prevIcon : Element PrevIconSlot admittedBy msg -> Element free freeAdmittedBy msg
prevIcon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "prev-icon") (El.toNode element))


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
