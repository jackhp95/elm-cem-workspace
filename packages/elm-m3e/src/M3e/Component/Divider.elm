module M3e.Component.Divider exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , inset, insetEnd, insetStart, vertical
    )

{-| The `m3e-divider` component — strict per-component surface.

A thin line that separates content in lists or other containers.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs inset, insetEnd, insetStart, vertical


## Examples


### Examples

<!-- elm-cem:example title="Lists" -->
```elm
M3e.Component.List.component [] [ M3e.Component.ListItem.component [] [ M3e.text "Item 1" ], M3e.Component.Divider.component [] [], M3e.Component.ListItem.component [] [ M3e.text "Item 2" ], M3e.Component.Divider.component [] [], M3e.Component.ListItem.component [] [ M3e.text "Item 3" ] ]
```

<!-- elm-cem:example title="Inset" -->
```elm
[ M3e.Component.Divider.component [] []
    , TypedHtml.br [] []
    , M3e.Component.Divider.component [ M3e.Component.Divider.inset True ] []
    , TypedHtml.br [] []
    , M3e.Component.Divider.component [ M3e.Component.Divider.insetStart True ] []
    , TypedHtml.br [] []
    , M3e.Component.Divider.component [ M3e.Component.Divider.insetEnd True ] []
    ]
```

<!-- elm-cem:example title="Orientation" -->
```elm
[ M3e.Component.Divider.component [ M3e.Component.Divider.vertical True ] []
    , M3e.Component.Divider.component [ M3e.Component.Divider.vertical True, M3e.Component.Divider.inset True ] []
    , M3e.Component.Divider.component [ M3e.Component.Divider.vertical True, M3e.Component.Divider.insetStart True ] []
    , M3e.Component.Divider.component [ M3e.Component.Divider.vertical True, M3e.Component.Divider.insetEnd True ] []
    ]
```

<!-- elm-cem:docmeta category=Containment -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Divider
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-divider` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Divider.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Divider.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Divider.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Divider.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Divider.AttrCaps


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
    H.divider


{-| See `M3e.Attributes.inset`.
-}
inset : Bool -> Attr { c | inset : Supported } msg
inset =
    A.inset


{-| See `M3e.Attributes.insetEnd`.
-}
insetEnd : Bool -> Attr { c | insetEnd : Supported } msg
insetEnd =
    A.insetEnd


{-| See `M3e.Attributes.insetStart`.
-}
insetStart : Bool -> Attr { c | insetStart : Supported } msg
insetStart =
    A.insetStart


{-| See `M3e.Attributes.vertical`.
-}
vertical : Bool -> Attr { c | vertical : Supported } msg
vertical =
    A.vertical
