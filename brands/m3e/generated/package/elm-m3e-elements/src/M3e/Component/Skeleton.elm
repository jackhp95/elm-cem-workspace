module M3e.Component.Skeleton exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Animation, animation, Shape, shape
    , loaded
    , child
    )

{-| The `m3e-skeleton` component — strict per-component surface.

A visual placeholder that mimics the layout of content while it's still loading.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Animation, animation, Shape, shape
@docs loaded
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Basic usage" -->
```elm
[ M3e.Unsafe.customElement "label" [] [ M3e.Component.Checkbox.component [ M3e.Attributes.id "toggle1" ] [], M3e.text "Loaded" ]
    , TypedHtml.br [] []
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Attributes.id "skeleton1" ] [ M3e.Component.Card.component [] [ M3e.Component.Card.header (M3e.Component.Heading.component { content = M3e.text "Card Header" } [ M3e.Component.Heading.variant M3e.Values.display, M3e.Component.Heading.size M3e.Values.small ] []), M3e.Component.Card.content (TypedHtml.div [] [ M3e.text "Card Content" ]), M3e.Component.Card.actions (TypedHtml.div [] [ M3e.Component.Button.component { content = M3e.text "Action", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled ] [] ]), M3e.Component.Card.footer (TypedHtml.div [] [ M3e.text "Card Footer" ]) ] ]
    ]
```

<!-- elm-cem:example title="Card Header" -->
```elm
M3e.Component.Skeleton.component [] [ M3e.Component.Card.component [] [ M3e.Component.Card.header (M3e.Component.Heading.component { content = M3e.text "Card Header" } [ M3e.Component.Heading.variant M3e.Values.display, M3e.Component.Heading.size M3e.Values.small ] []), M3e.Component.Card.content (TypedHtml.div [] [ M3e.text "Card Content" ]), M3e.Component.Card.actions (TypedHtml.div [] [ M3e.Component.Button.component { content = M3e.text "Action", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled ] [] ]), M3e.Component.Card.footer (TypedHtml.div [] [ M3e.text "Card Footer" ]) ] ]
```

<!-- elm-cem:example title="Shape" -->
```elm
[ M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.circular ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.rounded ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.square ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.auto ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px; border-radius: 16px" ] [] ]
    ]
```

<!-- elm-cem:example title="Animation" -->
```elm
[ M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.circular, M3e.Component.Skeleton.animation M3e.Values.pulse ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.rounded, M3e.Component.Skeleton.animation M3e.Values.pulse ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.square, M3e.Component.Skeleton.animation M3e.Values.pulse ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.auto, M3e.Component.Skeleton.animation M3e.Values.pulse ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px; border-radius: 16px" ] [] ]
    ]
```

<!-- elm-cem:example title="Animation (2)" -->
```elm
[ M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.circular, M3e.Component.Skeleton.animation M3e.Values.none ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.rounded, M3e.Component.Skeleton.animation M3e.Values.none ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.square, M3e.Component.Skeleton.animation M3e.Values.none ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px" ] [] ]
    , TypedHtml.br [] []
    , M3e.Component.Skeleton.component [ M3e.Component.Skeleton.shape M3e.Values.auto, M3e.Component.Skeleton.animation M3e.Values.none ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "style" "width: 100px; height: 100px; border-radius: 16px" ] [] ]
    ]
```

<!-- elm-cem:docmeta category=Communication -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Skeleton
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-skeleton` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Skeleton.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Skeleton.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Skeleton.ChildAdmittedBy childAdm


{-| The `animation` values valid on this component (compile-tight narrowing).
-}
type alias Animation =
    M3e.Internal.Types.Skeleton.Animation


{-| The `shape` values valid on this component (compile-tight narrowing).
-}
type alias Shape =
    M3e.Internal.Types.Skeleton.Shape


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Skeleton.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Skeleton.AttrCaps


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
    H.skeleton


{-| The animation effect of the skeleton. (default: `"wave"`)
-}
animation : Value Animation -> Attr { c | animation : Supported } msg
animation value_ =
    Ir.attribute "animation" (Val.toString value_)


{-| The shape of the skeleton. (default: `"auto"`)
-}
shape : Value Shape -> Attr { c | shape : Supported } msg
shape value_ =
    Ir.attribute "shape" (Val.toString value_)


{-| See `M3e.Attributes.loaded`.
-}
loaded : Bool -> Attr { c | loaded : Supported } msg
loaded =
    A.loaded


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
