module M3e.Component.ContentPane exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , child
    )

{-| The `m3e-content-pane` component — strict per-component surface.

A shaped surface for vertically scrollable content.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Usage" -->
```elm
M3e.Component.ContentPane.component [] [ M3e.Component.Heading.component { content = M3e.text "Content header" } [ M3e.Component.Heading.tocIgnore True, M3e.Component.Heading.variant M3e.Values.display, M3e.Component.Heading.size M3e.Values.large ] [], TypedHtml.p [] [ M3e.text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed vitae ligula at ipsum pulvinar tincidunt.\n    Integer feugiat, tortor non aliquet facilisis, velit risus faucibus lorem, vitae porttitor justo arcu\n    nec sapien. Curabitur euismod, urna vel placerat dictum, augue sem ullamcorper velit, id interdum neque\n    magna non nisl. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae.\n    Suspendisse potenti. Praesent ac orci eget urna volutpat fermentum. Donec non mi sed sapien gravida\n    aliquet. Vivamus at orci id libero scelerisque convallis. Pellentesque habitant morbi tristique senectus\n    et netus et malesuada fames ac turpis egestas. Cras ac erat id velit pharetra luctus. Mauris sed nisl\n    sed arcu facilisis tincidunt. Aliquam erat volutpat. Sed sit amet massa non magna gravida cursus. Sed\n    vulputate, velit id suscipit convallis, lorem ipsum varius neque, sed porttitor lacus justo vitae\n    libero. Integer at felis vel lacus porta posuere. Aenean non lorem ac nulla gravida tincidunt.\n    Pellentesque vel urna id libero dictum gravida. Donec sit amet velit nec sapien ultricies tincidunt.\n    Vivamus in augue id libero sodales tincidunt. Integer id lorem nec sapien bibendum tincidunt. Sed id\n    lacus non justo viverra tincidunt. Curabitur id risus vitae justo tincidunt gravida. Vivamus id ligula\n    non ipsum porta tincidunt. Pellentesque id lorem nec sapien dictum tincidunt. Integer id lorem nec\n    sapien bibendum tincidunt." ] ]
```

<!-- elm-cem:example title="Content header" -->
```elm
M3e.Component.ContentPane.component [] [ M3e.Component.Heading.component { content = M3e.text "Content header" } [ M3e.Component.Heading.variant M3e.Values.display, M3e.Component.Heading.size M3e.Values.large ] [], TypedHtml.p [] [] ]
```

<!-- elm-cem:docmeta category=Containment -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.ContentPane
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-content-pane` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ContentPane.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ContentPane.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ContentPane.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ContentPane.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.ContentPane.AttrCaps


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
    H.contentPane


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
