module M3e.Component.Icon exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , Grade, grade, Variant, variant
    , filled, name, opticalSize, weight
    )

{-| The `m3e-icon` component — strict per-component surface.

A small symbol used to easily identify an action or category.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs Grade, grade, Variant, variant
@docs filled, name, opticalSize, weight

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.Icon
import M3e.Kind exposing (Available, Ctx, Used)


{-| The kind row `m3e-icon` produces — the SHARED icon atom kind, admissible
into any library's opted-in slot.
-}
type alias Is s =
    M3e.Internal.Types.Icon.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Icon.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Icon.ChildAdmittedBy childAdm


{-| The `grade` values valid on this component (compile-tight narrowing).
-}
type alias Grade =
    M3e.Internal.Types.Icon.Grade


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Icon.Variant


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.icon


{-| The grade of the icon. (default: `"medium"`)
-}
grade : Value Grade -> Attr { c | grade : Supported } msg
grade value_ =
    Ir.attribute "grade" (Val.toString value_)


{-| The appearance variant of the icon. (default: `"outlined"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.filled`.
-}
filled : Bool -> Attr { c | filled : Supported } msg
filled =
    A.filled


{-| The name of the icon. (default: `""`)
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.opticalSize`.
-}
opticalSize : Float -> Attr { c | opticalSize : Supported } msg
opticalSize =
    A.opticalSize


{-| See `M3e.Attributes.weight`.
-}
weight : Int -> Attr { c | weight : Supported } msg
weight =
    A.weight
