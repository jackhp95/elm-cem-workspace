module TypedSvg.Element.Shape exposing
    ( circle, ellipse, line, path, polygon, polyline, rect
    , CircleIs, CircleAttrs, CircleContent, CircleChildAdmittedBy, EllipseIs, EllipseAttrs, EllipseContent, EllipseChildAdmittedBy, LineIs, LineAttrs, LineContent, LineChildAdmittedBy, PathIs, PathAttrs, PathContent, PathChildAdmittedBy, PolygonIs, PolygonAttrs, PolygonContent, PolygonChildAdmittedBy, PolylineIs, PolylineAttrs, PolylineContent, PolylineChildAdmittedBy, RectIs, RectAttrs, RectContent, RectChildAdmittedBy
    , cx, cy, d, height, pathLength, points, r, rx, ry, width, x, x1, x2, y, y1, y2
    )

{-| The `Shape` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs circle, ellipse, line, path, polygon, polyline, rect
@docs CircleIs, CircleAttrs, CircleContent, CircleChildAdmittedBy, EllipseIs, EllipseAttrs, EllipseContent, EllipseChildAdmittedBy, LineIs, LineAttrs, LineContent, LineChildAdmittedBy, PathIs, PathAttrs, PathContent, PathChildAdmittedBy, PolygonIs, PolygonAttrs, PolygonContent, PolygonChildAdmittedBy, PolylineIs, PolylineAttrs, PolylineContent, PolylineChildAdmittedBy, RectIs, RectAttrs, RectContent, RectChildAdmittedBy
@docs cx, cy, d, height, pathLength, points, r, rx, ry, width, x, x1, x2, y, y1, y2

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import TypedSvg.Attributes
import TypedSvg.Kind exposing (Brand, Ctx)


{-| The kind row `circle` produces.
-}
type alias CircleIs s =
    { s | circle : Brand }


{-| `circle`'s closed attribute-capability row.
-}
type alias CircleAttrs =
    { class : Supported
    , cx : Supported
    , cy : Supported
    , id : Supported
    , r : Supported
    , style : Supported
    }


{-| The kinds `circle` admits.
-}
type alias CircleContent =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `circle` injects into its children.
-}
type alias CircleChildAdmittedBy childAdm =
    { childAdm | circle : Ctx }


{-| The `circle` element.
-}
circle :
    List (Attr CircleAttrs msg)
    -> List (Element CircleContent (CircleChildAdmittedBy childAdm) msg)
    -> Element (CircleIs s) admittedBy msg
circle attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "circle" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `ellipse` produces.
-}
type alias EllipseIs s =
    { s | ellipse : Brand }


{-| `ellipse`'s closed attribute-capability row.
-}
type alias EllipseAttrs =
    { class : Supported
    , cx : Supported
    , cy : Supported
    , id : Supported
    , rx : Supported
    , ry : Supported
    , style : Supported
    }


{-| The kinds `ellipse` admits.
-}
type alias EllipseContent =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `ellipse` injects into its children.
-}
type alias EllipseChildAdmittedBy childAdm =
    { childAdm | ellipse : Ctx }


{-| The `ellipse` element.
-}
ellipse :
    List (Attr EllipseAttrs msg)
    -> List (Element EllipseContent (EllipseChildAdmittedBy childAdm) msg)
    -> Element (EllipseIs s) admittedBy msg
ellipse attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "ellipse" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `line` produces.
-}
type alias LineIs s =
    { s | line : Brand }


{-| `line`'s closed attribute-capability row.
-}
type alias LineAttrs =
    { class : Supported
    , id : Supported
    , style : Supported
    , x1 : Supported
    , x2 : Supported
    , y1 : Supported
    , y2 : Supported
    }


{-| The kinds `line` admits.
-}
type alias LineContent =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `line` injects into its children.
-}
type alias LineChildAdmittedBy childAdm =
    { childAdm | line : Ctx }


{-| The `line` element.
-}
line :
    List (Attr LineAttrs msg)
    -> List (Element LineContent (LineChildAdmittedBy childAdm) msg)
    -> Element (LineIs s) admittedBy msg
line attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "line" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `path` produces.
-}
type alias PathIs s =
    { s | path : Brand }


{-| `path`'s closed attribute-capability row.
-}
type alias PathAttrs =
    { class : Supported
    , d : Supported
    , id : Supported
    , pathLength : Supported
    , style : Supported
    }


{-| The kinds `path` admits.
-}
type alias PathContent =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `path` injects into its children.
-}
type alias PathChildAdmittedBy childAdm =
    { childAdm | path : Ctx }


{-| The `path` element.
-}
path :
    List (Attr PathAttrs msg)
    -> List (Element PathContent (PathChildAdmittedBy childAdm) msg)
    -> Element (PathIs s) admittedBy msg
path attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "path" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `polygon` produces.
-}
type alias PolygonIs s =
    { s | polygon : Brand }


{-| `polygon`'s closed attribute-capability row.
-}
type alias PolygonAttrs =
    { class : Supported
    , id : Supported
    , points : Supported
    , style : Supported
    }


{-| The kinds `polygon` admits.
-}
type alias PolygonContent =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `polygon` injects into its children.
-}
type alias PolygonChildAdmittedBy childAdm =
    { childAdm | polygon : Ctx }


{-| The `polygon` element.
-}
polygon :
    List (Attr PolygonAttrs msg)
    -> List (Element PolygonContent (PolygonChildAdmittedBy childAdm) msg)
    -> Element (PolygonIs s) admittedBy msg
polygon attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "polygon" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `polyline` produces.
-}
type alias PolylineIs s =
    { s | polyline : Brand }


{-| `polyline`'s closed attribute-capability row.
-}
type alias PolylineAttrs =
    { class : Supported
    , id : Supported
    , points : Supported
    , style : Supported
    }


{-| The kinds `polyline` admits.
-}
type alias PolylineContent =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `polyline` injects into its children.
-}
type alias PolylineChildAdmittedBy childAdm =
    { childAdm | polyline : Ctx }


{-| The `polyline` element.
-}
polyline :
    List (Attr PolylineAttrs msg)
    -> List (Element PolylineContent (PolylineChildAdmittedBy childAdm) msg)
    -> Element (PolylineIs s) admittedBy msg
polyline attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "polyline" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `rect` produces.
-}
type alias RectIs s =
    { s | rect : Brand }


{-| `rect`'s closed attribute-capability row.
-}
type alias RectAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , rx : Supported
    , ry : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `rect` admits.
-}
type alias RectContent =
    { desc : Brand
    , title : Brand
    }


{-| The context demand `rect` injects into its children.
-}
type alias RectChildAdmittedBy childAdm =
    { childAdm | rect : Ctx }


{-| The `rect` element.
-}
rect :
    List (Attr RectAttrs msg)
    -> List (Element RectContent (RectChildAdmittedBy childAdm) msg)
    -> Element (RectIs s) admittedBy msg
rect attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "rect" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedSvg.Attributes.cx`.
-}
cx : String -> Attr { c | cx : Supported } msg
cx =
    TypedSvg.Attributes.cx


{-| See `TypedSvg.Attributes.cy`.
-}
cy : String -> Attr { c | cy : Supported } msg
cy =
    TypedSvg.Attributes.cy


{-| See `TypedSvg.Attributes.d`.
-}
d : String -> Attr { c | d : Supported } msg
d =
    TypedSvg.Attributes.d


{-| See `TypedSvg.Attributes.height`.
-}
height : String -> Attr { c | height : Supported } msg
height =
    TypedSvg.Attributes.height


{-| See `TypedSvg.Attributes.pathLength`.
-}
pathLength : String -> Attr { c | pathLength : Supported } msg
pathLength =
    TypedSvg.Attributes.pathLength


{-| See `TypedSvg.Attributes.points`.
-}
points : String -> Attr { c | points : Supported } msg
points =
    TypedSvg.Attributes.points


{-| See `TypedSvg.Attributes.r`.
-}
r : String -> Attr { c | r : Supported } msg
r =
    TypedSvg.Attributes.r


{-| See `TypedSvg.Attributes.rx`.
-}
rx : String -> Attr { c | rx : Supported } msg
rx =
    TypedSvg.Attributes.rx


{-| See `TypedSvg.Attributes.ry`.
-}
ry : String -> Attr { c | ry : Supported } msg
ry =
    TypedSvg.Attributes.ry


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


{-| See `TypedSvg.Attributes.x1`.
-}
x1 : String -> Attr { c | x1 : Supported } msg
x1 =
    TypedSvg.Attributes.x1


{-| See `TypedSvg.Attributes.x2`.
-}
x2 : String -> Attr { c | x2 : Supported } msg
x2 =
    TypedSvg.Attributes.x2


{-| See `TypedSvg.Attributes.y`.
-}
y : String -> Attr { c | y : Supported } msg
y =
    TypedSvg.Attributes.y


{-| See `TypedSvg.Attributes.y1`.
-}
y1 : String -> Attr { c | y1 : Supported } msg
y1 =
    TypedSvg.Attributes.y1


{-| See `TypedSvg.Attributes.y2`.
-}
y2 : String -> Attr { c | y2 : Supported } msg
y2 =
    TypedSvg.Attributes.y2
