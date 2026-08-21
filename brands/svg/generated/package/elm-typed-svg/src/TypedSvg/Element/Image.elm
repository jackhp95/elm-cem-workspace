module TypedSvg.Element.Image exposing
    ( image
    , Is, Attrs, Content, ChildAdmittedBy
    , height, href, preserveAspectRatio, width, x, y
    )

{-| The `Image` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs image
@docs Is, Attrs, Content, ChildAdmittedBy
@docs height, href, preserveAspectRatio, width, x, y

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import TypedSvg.Attributes
import TypedSvg.Kind exposing (Brand, Ctx)


{-| The kind row `image` produces.
-}
type alias Is s =
    { s | image : Brand }


{-| `image`'s closed attribute-capability row.
-}
type alias Attrs =
    { class : Supported
    , height : Supported
    , href : Supported
    , id : Supported
    , preserveAspectRatio : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `image` admits.
-}
type alias Content =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `image` injects into its children.
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | image : Ctx }


{-| The `image` element.
-}
image :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
image attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "image" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedSvg.Attributes.height`.
-}
height : String -> Attr { c | height : Supported } msg
height =
    TypedSvg.Attributes.height


{-| See `TypedSvg.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    TypedSvg.Attributes.href


{-| See `TypedSvg.Attributes.preserveAspectRatio`.
-}
preserveAspectRatio : String -> Attr { c | preserveAspectRatio : Supported } msg
preserveAspectRatio =
    TypedSvg.Attributes.preserveAspectRatio


{-| See `TypedSvg.Attributes.width`.
-}
width : String -> Attr { c | width : Supported } msg
width =
    TypedSvg.Attributes.width


{-| See `TypedSvg.Attributes.x`.
-}
x : String -> Attr { c | x : Supported } msg
x =
    TypedSvg.Attributes.x


{-| See `TypedSvg.Attributes.y`.
-}
y : String -> Attr { c | y : Supported } msg
y =
    TypedSvg.Attributes.y
