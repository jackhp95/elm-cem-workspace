module TypedSvg.Element.Paint exposing
    ( linearGradient, pattern, radialGradient, stop
    , LinearGradientIs, LinearGradientAttrs, LinearGradientContent, LinearGradientChildAdmittedBy, PatternIs, PatternAttrs, PatternChildAdmittedBy, RadialGradientIs, RadialGradientAttrs, RadialGradientContent, RadialGradientChildAdmittedBy, StopIs, StopAttrs, StopChildAdmittedBy
    , cx, cy, fr, fx, fy, gradientTransform, gradientUnits, height, href, offset, patternContentUnits, patternTransform, patternUnits, preserveAspectRatio, r, spreadMethod, stopColor, stopOpacity, viewBox, width, x, x1, x2, y, y1, y2
    )

{-| The `Paint` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs linearGradient, pattern, radialGradient, stop
@docs LinearGradientIs, LinearGradientAttrs, LinearGradientContent, LinearGradientChildAdmittedBy, PatternIs, PatternAttrs, PatternChildAdmittedBy, RadialGradientIs, RadialGradientAttrs, RadialGradientContent, RadialGradientChildAdmittedBy, StopIs, StopAttrs, StopChildAdmittedBy
@docs cx, cy, fr, fx, fy, gradientTransform, gradientUnits, height, href, offset, patternContentUnits, patternTransform, patternUnits, preserveAspectRatio, r, spreadMethod, stopColor, stopOpacity, viewBox, width, x, x1, x2, y, y1, y2

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import TypedSvg.Attributes
import TypedSvg.Kind exposing (Brand, Ctx)


{-| The kind row `linearGradient` produces.
-}
type alias LinearGradientIs s =
    { s | linearGradient : Brand }


{-| `linearGradient`'s closed attribute-capability row.
-}
type alias LinearGradientAttrs =
    { class : Supported
    , gradientTransform : Supported
    , gradientUnits : Supported
    , href : Supported
    , id : Supported
    , spreadMethod : Supported
    , style : Supported
    , x1 : Supported
    , x2 : Supported
    , y1 : Supported
    , y2 : Supported
    }


{-| The kinds `linearGradient` admits.
-}
type alias LinearGradientContent =
    { desc : Brand
    , stop : Brand
    , title : Brand
    }


{-| The context demand `linearGradient` injects into its children.
-}
type alias LinearGradientChildAdmittedBy childAdm =
    { childAdm | linearGradient : Ctx }


{-| The `linearGradient` element.
-}
linearGradient :
    List (Attr LinearGradientAttrs msg)
    -> List (Element LinearGradientContent (LinearGradientChildAdmittedBy childAdm) msg)
    -> Element (LinearGradientIs s) admittedBy msg
linearGradient attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "linearGradient" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `pattern` produces.
-}
type alias PatternIs s =
    { s | pattern : Brand }


{-| `pattern`'s closed attribute-capability row.
-}
type alias PatternAttrs =
    { class : Supported
    , height : Supported
    , href : Supported
    , id : Supported
    , patternContentUnits : Supported
    , patternTransform : Supported
    , patternUnits : Supported
    , preserveAspectRatio : Supported
    , style : Supported
    , viewBox : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `pattern` injects into its children.
-}
type alias PatternChildAdmittedBy childAdm =
    { childAdm | pattern : Ctx }


{-| The `pattern` element.
-}
pattern :
    List (Attr PatternAttrs msg)
    -> List (Element childAccepts (PatternChildAdmittedBy childAdm) msg)
    -> Element (PatternIs s) admittedBy msg
pattern attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "pattern" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `radialGradient` produces.
-}
type alias RadialGradientIs s =
    { s | radialGradient : Brand }


{-| `radialGradient`'s closed attribute-capability row.
-}
type alias RadialGradientAttrs =
    { class : Supported
    , cx : Supported
    , cy : Supported
    , fr : Supported
    , fx : Supported
    , fy : Supported
    , gradientTransform : Supported
    , gradientUnits : Supported
    , href : Supported
    , id : Supported
    , r : Supported
    , spreadMethod : Supported
    , style : Supported
    }


{-| The kinds `radialGradient` admits.
-}
type alias RadialGradientContent =
    { desc : Brand
    , stop : Brand
    , title : Brand
    }


{-| The context demand `radialGradient` injects into its children.
-}
type alias RadialGradientChildAdmittedBy childAdm =
    { childAdm | radialGradient : Ctx }


{-| The `radialGradient` element.
-}
radialGradient :
    List (Attr RadialGradientAttrs msg)
    -> List (Element RadialGradientContent (RadialGradientChildAdmittedBy childAdm) msg)
    -> Element (RadialGradientIs s) admittedBy msg
radialGradient attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "radialGradient" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `stop` produces.
-}
type alias StopIs s =
    { s | stop : Brand }


{-| `stop`'s closed attribute-capability row.
-}
type alias StopAttrs =
    { class : Supported
    , id : Supported
    , offset : Supported
    , stopColor : Supported
    , stopOpacity : Supported
    , style : Supported
    }


{-| The context demand `stop` injects into its children.
-}
type alias StopChildAdmittedBy childAdm =
    { childAdm | stop : Ctx }


{-| The `stop` element.
-}
stop :
    List (Attr StopAttrs msg)
    -> List (Element childAccepts (StopChildAdmittedBy childAdm) msg)
    -> Element (StopIs s) admittedBy msg
stop attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "stop" attrs (List.map HtmlIr.Element.toNode children))


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


{-| See `TypedSvg.Attributes.fr`.
-}
fr : String -> Attr { c | fr : Supported } msg
fr =
    TypedSvg.Attributes.fr


{-| See `TypedSvg.Attributes.fx`.
-}
fx : String -> Attr { c | fx : Supported } msg
fx =
    TypedSvg.Attributes.fx


{-| See `TypedSvg.Attributes.fy`.
-}
fy : String -> Attr { c | fy : Supported } msg
fy =
    TypedSvg.Attributes.fy


{-| See `TypedSvg.Attributes.gradientTransform`.
-}
gradientTransform : String -> Attr { c | gradientTransform : Supported } msg
gradientTransform =
    TypedSvg.Attributes.gradientTransform


{-| See `TypedSvg.Attributes.gradientUnits`.
-}
gradientUnits : String -> Attr { c | gradientUnits : Supported } msg
gradientUnits =
    TypedSvg.Attributes.gradientUnits


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


{-| See `TypedSvg.Attributes.offset`.
-}
offset : String -> Attr { c | offset : Supported } msg
offset =
    TypedSvg.Attributes.offset


{-| See `TypedSvg.Attributes.patternContentUnits`.
-}
patternContentUnits : String -> Attr { c | patternContentUnits : Supported } msg
patternContentUnits =
    TypedSvg.Attributes.patternContentUnits


{-| See `TypedSvg.Attributes.patternTransform`.
-}
patternTransform : String -> Attr { c | patternTransform : Supported } msg
patternTransform =
    TypedSvg.Attributes.patternTransform


{-| See `TypedSvg.Attributes.patternUnits`.
-}
patternUnits : String -> Attr { c | patternUnits : Supported } msg
patternUnits =
    TypedSvg.Attributes.patternUnits


{-| See `TypedSvg.Attributes.preserveAspectRatio`.
-}
preserveAspectRatio : String -> Attr { c | preserveAspectRatio : Supported } msg
preserveAspectRatio =
    TypedSvg.Attributes.preserveAspectRatio


{-| See `TypedSvg.Attributes.r`.
-}
r : String -> Attr { c | r : Supported } msg
r =
    TypedSvg.Attributes.r


{-| See `TypedSvg.Attributes.spreadMethod`.
-}
spreadMethod : String -> Attr { c | spreadMethod : Supported } msg
spreadMethod =
    TypedSvg.Attributes.spreadMethod


{-| See `TypedSvg.Attributes.stopColor`.
-}
stopColor : String -> Attr { c | stopColor : Supported } msg
stopColor =
    TypedSvg.Attributes.stopColor


{-| See `TypedSvg.Attributes.stopOpacity`.
-}
stopOpacity : String -> Attr { c | stopOpacity : Supported } msg
stopOpacity =
    TypedSvg.Attributes.stopOpacity


{-| See `TypedSvg.Attributes.viewBox`.
-}
viewBox : String -> Attr { c | viewBox : Supported } msg
viewBox =
    TypedSvg.Attributes.viewBox


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
