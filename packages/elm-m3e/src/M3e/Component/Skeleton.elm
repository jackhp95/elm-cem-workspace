module M3e.Component.Skeleton exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Animation, animation, Shape, shape
    , loaded
    , child
    )

{-| The `m3e-skeleton` component — strict per-component surface.

A visual placeholder that mimics the layout of content while it's still loading.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Animation, animation, Shape, shape
@docs loaded
@docs child

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


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
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
