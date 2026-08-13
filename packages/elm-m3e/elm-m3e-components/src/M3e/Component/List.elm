module M3e.Component.List exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , Variant, variant
    , child
    )

{-| The `m3e-list` component — strict per-component surface.

A list of items.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs Variant, variant
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.List
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-list` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.List.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.List.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.List.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.List.ChildAdmittedBy childAdm


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.List.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.list


{-| The appearance variant of the list. (default: `"standard"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
