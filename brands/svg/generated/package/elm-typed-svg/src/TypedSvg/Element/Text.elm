module TypedSvg.Element.Text exposing
    ( text, textPath, tspan
    , TextIs, TextAttrs, TextContent, TextChildAdmittedBy, TextPathIs, TextPathAttrs, TextPathContent, TextPathChildAdmittedBy, TspanIs, TspanAttrs, TspanContent, TspanChildAdmittedBy
    , dx, dy, href, lengthAdjust, method, rotate, side, spacing, startOffset, textLength, x, y
    )

{-| The `Text` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs text, textPath, tspan
@docs TextIs, TextAttrs, TextContent, TextChildAdmittedBy, TextPathIs, TextPathAttrs, TextPathContent, TextPathChildAdmittedBy, TspanIs, TspanAttrs, TspanContent, TspanChildAdmittedBy
@docs dx, dy, href, lengthAdjust, method, rotate, side, spacing, startOffset, textLength, x, y

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import TypedSvg.Attributes
import TypedSvg.Kind exposing (Brand, Ctx)


{-| The kind row `text` produces.
-}
type alias TextIs s =
    { s | text : Brand }


{-| `text`'s closed attribute-capability row.
-}
type alias TextAttrs =
    { class : Supported
    , dx : Supported
    , dy : Supported
    , id : Supported
    , lengthAdjust : Supported
    , rotate : Supported
    , style : Supported
    , textLength : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `text` admits.
-}
type alias TextContent =
    { sharedText : Shared
    , textPath : Brand
    , tspan : Brand
    }


{-| The context demand `text` injects into its children.
-}
type alias TextChildAdmittedBy childAdm =
    { childAdm | text : Ctx }


{-| The `text` element.
-}
text :
    List (Attr TextAttrs msg)
    -> List (Element TextContent (TextChildAdmittedBy childAdm) msg)
    -> Element (TextIs s) admittedBy msg
text attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "text" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `textPath` produces.
-}
type alias TextPathIs s =
    { s | textPath : Brand }


{-| `textPath`'s closed attribute-capability row.
-}
type alias TextPathAttrs =
    { class : Supported
    , href : Supported
    , id : Supported
    , method : Supported
    , side : Supported
    , spacing : Supported
    , startOffset : Supported
    , style : Supported
    }


{-| The kinds `textPath` admits.
-}
type alias TextPathContent =
    { sharedText : Shared
    , tspan : Brand
    }


{-| The context demand `textPath` injects into its children.
-}
type alias TextPathChildAdmittedBy childAdm =
    { childAdm | textPath : Ctx }


{-| The `textPath` element.
-}
textPath :
    List (Attr TextPathAttrs msg)
    -> List (Element TextPathContent (TextPathChildAdmittedBy childAdm) msg)
    -> Element (TextPathIs s) admittedBy msg
textPath attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "textPath" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `tspan` produces.
-}
type alias TspanIs s =
    { s | tspan : Brand }


{-| `tspan`'s closed attribute-capability row.
-}
type alias TspanAttrs =
    { class : Supported
    , dx : Supported
    , dy : Supported
    , id : Supported
    , rotate : Supported
    , style : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `tspan` admits.
-}
type alias TspanContent =
    { sharedText : Shared
    , tspan : Brand
    }


{-| The context demand `tspan` injects into its children.
-}
type alias TspanChildAdmittedBy childAdm =
    { childAdm | tspan : Ctx }


{-| The `tspan` element.
-}
tspan :
    List (Attr TspanAttrs msg)
    -> List (Element TspanContent (TspanChildAdmittedBy childAdm) msg)
    -> Element (TspanIs s) admittedBy msg
tspan attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "tspan" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedSvg.Attributes.dx`.
-}
dx : String -> Attr { c | dx : Supported } msg
dx =
    TypedSvg.Attributes.dx


{-| See `TypedSvg.Attributes.dy`.
-}
dy : String -> Attr { c | dy : Supported } msg
dy =
    TypedSvg.Attributes.dy


{-| See `TypedSvg.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    TypedSvg.Attributes.href


{-| See `TypedSvg.Attributes.lengthAdjust`.
-}
lengthAdjust : String -> Attr { c | lengthAdjust : Supported } msg
lengthAdjust =
    TypedSvg.Attributes.lengthAdjust


{-| See `TypedSvg.Attributes.method`.
-}
method : String -> Attr { c | method : Supported } msg
method =
    TypedSvg.Attributes.method


{-| See `TypedSvg.Attributes.rotate`.
-}
rotate : String -> Attr { c | rotate : Supported } msg
rotate =
    TypedSvg.Attributes.rotate


{-| See `TypedSvg.Attributes.side`.
-}
side : String -> Attr { c | side : Supported } msg
side =
    TypedSvg.Attributes.side


{-| See `TypedSvg.Attributes.spacing`.
-}
spacing : String -> Attr { c | spacing : Supported } msg
spacing =
    TypedSvg.Attributes.spacing


{-| See `TypedSvg.Attributes.startOffset`.
-}
startOffset : String -> Attr { c | startOffset : Supported } msg
startOffset =
    TypedSvg.Attributes.startOffset


{-| See `TypedSvg.Attributes.textLength`.
-}
textLength : String -> Attr { c | textLength : Supported } msg
textLength =
    TypedSvg.Attributes.textLength


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
