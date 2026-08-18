module M3e.Component.Shape exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Name, name
    , child
    )

{-| The `m3e-shape` component — strict per-component surface.

A shape used to add emphasis and decorative flair.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Name, name
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Shapes" -->
```elm
[ M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.value12SidedCookie ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.value9SidedCookie ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.value8LeafClover ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.value7SidedCookie ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.value6SidedCookie ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.value4SidedCookie ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.value4LeafClover ] []
    , TypedHtml.br [] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.arch ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.arrow ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.boom ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.bun ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.diamond ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.fan ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.flower ] []
    , TypedHtml.br [] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.gem ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.ghostIsh ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.heart ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.hexagon ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.pentagon ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.pill ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.pixelCircle ] []
    , TypedHtml.br [] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.pixelTriangle ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.puffy ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.puffyDiamond ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.semicircle ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.slanted ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.softBoom ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.softBurst ] []
    , TypedHtml.br [] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.square ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.circle ] []
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.triangle ] []
    ]
```

<!-- elm-cem:example title="Images and video" -->
```elm
[ M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.sunny, M3e.Attributes.class "image-shape" ] [ TypedHtml.img [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/thumb/1.jpg?ip=x480" ] [] ]
    , M3e.Component.Shape.component [ M3e.Component.Shape.name M3e.Values.sunny, M3e.Attributes.class "image-shape" ] [ TypedHtml.video [ TypedHtml.Unsafe.Attributes.customAttribute "autoplay" "", TypedHtml.Unsafe.Attributes.customAttribute "loop" "", TypedHtml.Unsafe.Attributes.customAttribute "poster" "https://www.shutterstock.com/shutterstock/videos/1006393/thumb/1.jpg?ip=x480", TypedHtml.Unsafe.Attributes.customAttribute "preload" "auto" ] [ TypedHtml.source [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/preview/stock-footage-business-people-working-in-office.webm", TypedHtml.Unsafe.Attributes.customAttribute "type" "video/webm" ] [], TypedHtml.source [ TypedHtml.Unsafe.Attributes.customAttribute "src" "https://www.shutterstock.com/shutterstock/videos/1006393/preview/stock-footage-business-people-working-in-office.mp4", TypedHtml.Unsafe.Attributes.customAttribute "type" "video/mp4" ] [] ] ]
    ]
```

<!-- elm-cem:example title="Morphing" -->
```elm
M3e.Component.Shape.component [ M3e.Attributes.id "morph" ] []
```

<!-- elm-cem:docmeta category=Layout & style -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Shape
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-shape` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Shape.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Shape.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Shape.ChildAdmittedBy childAdm


{-| The `name` values valid on this component (compile-tight narrowing).
-}
type alias Name =
    M3e.Internal.Types.Shape.Name


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Shape.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Shape.AttrCaps


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
    H.shape


{-| The name of the shape. (default: `null`)
-}
name : Value Name -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" (Val.toString value_)


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
