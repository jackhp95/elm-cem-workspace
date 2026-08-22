module TypedSvg.Element.Clip exposing
    ( clipPath, marker, mask
    , ClipPathIs, ClipPathAttrs, ClipPathContent, ClipPathChildAdmittedBy, MarkerIs, MarkerAttrs, MarkerContent, MarkerChildAdmittedBy, MaskIs, MaskAttrs, MaskContent, MaskChildAdmittedBy
    , clipPathUnits, height, markerHeight, markerUnits, markerWidth, maskContentUnits, maskUnits, orient, preserveAspectRatio, refX, refY, viewBox, width, x, y
    )

{-| The `Clip` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs clipPath, marker, mask
@docs ClipPathIs, ClipPathAttrs, ClipPathContent, ClipPathChildAdmittedBy, MarkerIs, MarkerAttrs, MarkerContent, MarkerChildAdmittedBy, MaskIs, MaskAttrs, MaskContent, MaskChildAdmittedBy
@docs clipPathUnits, height, markerHeight, markerUnits, markerWidth, maskContentUnits, maskUnits, orient, preserveAspectRatio, refX, refY, viewBox, width, x, y

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import TypedSvg.Attributes
import TypedSvg.Kind exposing (Brand, Ctx)


{-| The kind row `clipPath` produces.
-}
type alias ClipPathIs s =
    { s | clipPath : Brand }


{-| `clipPath`'s closed attribute-capability row.
-}
type alias ClipPathAttrs =
    { class : Supported
    , clipPathUnits : Supported
    , id : Supported
    , style : Supported
    }


{-| The kinds `clipPath` admits.
-}
type alias ClipPathContent =
    { circle : Brand
    , desc : Brand
    , ellipse : Brand
    , line : Brand
    , path : Brand
    , polygon : Brand
    , polyline : Brand
    , rect : Brand
    , text : Brand
    , title : Brand
    , use : Brand
    }


{-| The context demand `clipPath` injects into its children.
-}
type alias ClipPathChildAdmittedBy childAdm =
    { childAdm | clipPath : Ctx }


{-| The `clipPath` element.
-}
clipPath :
    List (Attr ClipPathAttrs msg)
    -> List (Element ClipPathContent (ClipPathChildAdmittedBy childAdm) msg)
    -> Element (ClipPathIs s) admittedBy msg
clipPath attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "clipPath" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `marker` produces.
-}
type alias MarkerIs s =
    { s | marker : Brand }


{-| `marker`'s closed attribute-capability row.
-}
type alias MarkerAttrs =
    { class : Supported
    , id : Supported
    , markerHeight : Supported
    , markerUnits : Supported
    , markerWidth : Supported
    , orient : Supported
    , preserveAspectRatio : Supported
    , refX : Supported
    , refY : Supported
    , style : Supported
    , viewBox : Supported
    }


{-| The kinds `marker` admits.
-}
type alias MarkerContent =
    { a : Brand
    , circle : Brand
    , clipPath : Brand
    , defs : Brand
    , desc : Brand
    , ellipse : Brand
    , g : Brand
    , image : Brand
    , line : Brand
    , linearGradient : Brand
    , marker : Brand
    , mask : Brand
    , path : Brand
    , pattern : Brand
    , polygon : Brand
    , polyline : Brand
    , radialGradient : Brand
    , rect : Brand
    , svg : Brand
    , switch : Brand
    , symbol : Brand
    , text : Brand
    , title : Brand
    , use : Brand
    }


{-| The context demand `marker` injects into its children.
-}
type alias MarkerChildAdmittedBy childAdm =
    { childAdm | marker : Ctx }


{-| The `marker` element.
-}
marker :
    List (Attr MarkerAttrs msg)
    -> List (Element MarkerContent (MarkerChildAdmittedBy childAdm) msg)
    -> Element (MarkerIs s) admittedBy msg
marker attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "marker" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `mask` produces.
-}
type alias MaskIs s =
    { s | mask : Brand }


{-| `mask`'s closed attribute-capability row.
-}
type alias MaskAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , maskContentUnits : Supported
    , maskUnits : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `mask` admits.
-}
type alias MaskContent =
    { a : Brand
    , circle : Brand
    , clipPath : Brand
    , defs : Brand
    , desc : Brand
    , ellipse : Brand
    , g : Brand
    , image : Brand
    , line : Brand
    , linearGradient : Brand
    , marker : Brand
    , mask : Brand
    , path : Brand
    , pattern : Brand
    , polygon : Brand
    , polyline : Brand
    , radialGradient : Brand
    , rect : Brand
    , svg : Brand
    , switch : Brand
    , symbol : Brand
    , text : Brand
    , title : Brand
    , use : Brand
    }


{-| The context demand `mask` injects into its children.
-}
type alias MaskChildAdmittedBy childAdm =
    { childAdm | mask : Ctx }


{-| The `mask` element.
-}
mask :
    List (Attr MaskAttrs msg)
    -> List (Element MaskContent (MaskChildAdmittedBy childAdm) msg)
    -> Element (MaskIs s) admittedBy msg
mask attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "mask" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedSvg.Attributes.clipPathUnits`.
-}
clipPathUnits : String -> Attr { c | clipPathUnits : Supported } msg
clipPathUnits =
    TypedSvg.Attributes.clipPathUnits


{-| See `TypedSvg.Attributes.height`.
-}
height : String -> Attr { c | height : Supported } msg
height =
    TypedSvg.Attributes.height


{-| See `TypedSvg.Attributes.markerHeight`.
-}
markerHeight : String -> Attr { c | markerHeight : Supported } msg
markerHeight =
    TypedSvg.Attributes.markerHeight


{-| See `TypedSvg.Attributes.markerUnits`.
-}
markerUnits : String -> Attr { c | markerUnits : Supported } msg
markerUnits =
    TypedSvg.Attributes.markerUnits


{-| See `TypedSvg.Attributes.markerWidth`.
-}
markerWidth : String -> Attr { c | markerWidth : Supported } msg
markerWidth =
    TypedSvg.Attributes.markerWidth


{-| See `TypedSvg.Attributes.maskContentUnits`.
-}
maskContentUnits : String -> Attr { c | maskContentUnits : Supported } msg
maskContentUnits =
    TypedSvg.Attributes.maskContentUnits


{-| See `TypedSvg.Attributes.maskUnits`.
-}
maskUnits : String -> Attr { c | maskUnits : Supported } msg
maskUnits =
    TypedSvg.Attributes.maskUnits


{-| See `TypedSvg.Attributes.orient`.
-}
orient : String -> Attr { c | orient : Supported } msg
orient =
    TypedSvg.Attributes.orient


{-| See `TypedSvg.Attributes.preserveAspectRatio`.
-}
preserveAspectRatio : String -> Attr { c | preserveAspectRatio : Supported } msg
preserveAspectRatio =
    TypedSvg.Attributes.preserveAspectRatio


{-| See `TypedSvg.Attributes.refX`.
-}
refX : String -> Attr { c | refX : Supported } msg
refX =
    TypedSvg.Attributes.refX


{-| See `TypedSvg.Attributes.refY`.
-}
refY : String -> Attr { c | refY : Supported } msg
refY =
    TypedSvg.Attributes.refY


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


{-| See `TypedSvg.Attributes.y`.
-}
y : String -> Attr { c | y : Supported } msg
y =
    TypedSvg.Attributes.y
