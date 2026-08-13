module M3e.Component.ButtonGroup exposing
    ( view
    , Is, Attrs, Content, ChildAdmittedBy
    , Size, size, Variant, variant
    , multi
    , child
    )

{-| The `m3e-button-group` component — strict per-component surface.

Organizes buttons and adds interactions between them.

@docs view
@docs Is, Attrs, Content, ChildAdmittedBy
@docs Size, size, Variant, variant
@docs multi
@docs child

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.ButtonGroup
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-button-group` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.ButtonGroup.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.ButtonGroup.Attrs


{-| The kinds the default slot admits.
-}
type alias Content =
    M3e.Internal.Types.ButtonGroup.Content


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ButtonGroup.ChildAdmittedBy childAdm


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    M3e.Internal.Types.ButtonGroup.Size


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.ButtonGroup.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.buttonGroup


{-| The size of the group. (default: `"small"`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The appearance variant of the group. (default: `"standard"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.multi`.
-}
multi : Bool -> Attr { c | multi : Supported } msg
multi =
    A.multi


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element Content admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
