module TypedSvg.Attributes exposing
    ( class, id, style, alignmentBaseline, baselineShift, clipPath, clipRule, color, colorInterpolation, colorRendering, cursor, direction, display, dominantBaseline, fill, fillOpacity, fillRule, filter, fontFamily, fontSize, fontStyle, fontVariant, fontWeight, glyphOrientationVertical, imageRendering, lang, letterSpacing, lineHeight, markerEnd, markerMid, markerStart, mask, opacity, overflow, paintOrder, pointerEvents, role, shapeRendering, stroke, strokeDasharray, strokeDashoffset, strokeLinecap, strokeLinejoin, strokeMiterlimit, strokeOpacity, strokeWidth, tabindex, textAnchor, textDecoration, textRendering, transform, transformOrigin, vectorEffect, visibility, whiteSpace, wordSpacing, writingMode, xmlSpace, classList, styleList
    , clipPathUnits, cx, cy, d, dx, dy, fr, fx, fy, gradientTransform, gradientUnits, height, href, lengthAdjust, markerHeight, markerUnits, markerWidth, maskContentUnits, maskUnits, method, offset, orient, pathLength, patternContentUnits, patternTransform, patternUnits, points, preserveAspectRatio, r, refX, refY, requiredExtensions, rotate, rx, ry, side, spacing, spreadMethod, startOffset, stopColor, stopOpacity, systemLanguage, target, textLength, viewBox, width, x, x1, x2, xmlns, y, y1, y2
    )

{-| The canonical shared attribute vocabulary. Every setter is an open
producer (`{ c | attr : Supported }`); each element's closed `Attrs` row
decides admittance. Enum setters here close over the library-wide UNION of
values — cross-component misuse is caught by elm-review; reach for the
per-component setters (`TypedSvg.<Component>.<attr>`) for compile-tight narrowing.

Portmanteau setters (`variantRainbow`, `shapeRounded`, …) are nullary
aliases that pre-apply one enum token. They exist for IDE discovery:
type `variant` and autocomplete lists every value inline. Each claims
the same capability row as its base enum setter, so admittance is identical.

@docs class, id, style, alignmentBaseline, baselineShift, clipPath, clipRule, color, colorInterpolation, colorRendering, cursor, direction, display, dominantBaseline, fill, fillOpacity, fillRule, filter, fontFamily, fontSize, fontStyle, fontVariant, fontWeight, glyphOrientationVertical, imageRendering, lang, letterSpacing, lineHeight, markerEnd, markerMid, markerStart, mask, opacity, overflow, paintOrder, pointerEvents, role, shapeRendering, stroke, strokeDasharray, strokeDashoffset, strokeLinecap, strokeLinejoin, strokeMiterlimit, strokeOpacity, strokeWidth, tabindex, textAnchor, textDecoration, textRendering, transform, transformOrigin, vectorEffect, visibility, whiteSpace, wordSpacing, writingMode, xmlSpace, classList, styleList
@docs clipPathUnits, cx, cy, d, dx, dy, fr, fx, fy, gradientTransform, gradientUnits, height, href, lengthAdjust, markerHeight, markerUnits, markerWidth, maskContentUnits, maskUnits, method, offset, orient, pathLength, patternContentUnits, patternTransform, patternUnits, points, preserveAspectRatio, r, refX, refY, requiredExtensions, rotate, rx, ry, side, spacing, spreadMethod, startOffset, stopColor, stopOpacity, systemLanguage, target, textLength, viewBox, width, x, x1, x2, xmlns, y, y1, y2

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import TypedSvg.Values


{-| The global `class` attribute. Repeats ACCUMULATE: `[ class "a", class "b" ]` renders `class="a b"`.
-}
class : String -> Attr { c | class : Supported } msg
class =
    Ir.attribute "class"


{-| The classes whose flag is `True`, space-joined. Accumulates with every other `class` / `classList` on the element.
-}
classList : List ( String, Bool ) -> Attr { c | class : Supported } msg
classList pairs =
    Ir.attribute "class" (String.join " " (List.map Tuple.first (List.filter Tuple.second pairs)))


{-| The global `id` attribute.
-}
id : String -> Attr { c | id : Supported } msg
id =
    Ir.attribute "id"


{-| One inline-style declaration (the `elm/html` 0.19 shape). Declarations MERGE across every `style` / `styleList` on the element, last-wins per property.
-}
style : String -> String -> Attr { c | style : Supported } msg
style property value_ =
    Ir.styles [ ( property, value_ ) ]


{-| Inline-style declarations as a `( property, value )` list (the `elm/html` 0.18 shape). Merges exactly as `style` does.
-}
styleList : List ( String, String ) -> Attr { c | style : Supported } msg
styleList =
    Ir.styles


{-| The global `alignment-baseline` attribute.
-}
alignmentBaseline : Value TypedSvg.Values.AlignmentBaseline -> Attr c msg
alignmentBaseline value_ =
    Ir.attribute "alignment-baseline" (HtmlIr.Value.toString value_)


{-| The global `baseline-shift` attribute.
-}
baselineShift : String -> Attr c msg
baselineShift =
    Ir.attribute "baseline-shift"


{-| The global `clip-path` attribute.
-}
clipPath : String -> Attr c msg
clipPath =
    Ir.attribute "clip-path"


{-| The global `clip-rule` attribute.
-}
clipRule : Value TypedSvg.Values.ClipRule -> Attr c msg
clipRule value_ =
    Ir.attribute "clip-rule" (HtmlIr.Value.toString value_)


{-| The global `color` attribute.
-}
color : String -> Attr c msg
color =
    Ir.attribute "color"


{-| The global `color-interpolation` attribute.
-}
colorInterpolation : Value TypedSvg.Values.ColorInterpolation -> Attr c msg
colorInterpolation value_ =
    Ir.attribute "color-interpolation" (HtmlIr.Value.toString value_)


{-| The global `color-rendering` attribute.
-}
colorRendering : Value TypedSvg.Values.ColorRendering -> Attr c msg
colorRendering value_ =
    Ir.attribute "color-rendering" (HtmlIr.Value.toString value_)


{-| The global `cursor` attribute.
-}
cursor : String -> Attr c msg
cursor =
    Ir.attribute "cursor"


{-| The global `direction` attribute.
-}
direction : Value TypedSvg.Values.Direction -> Attr c msg
direction value_ =
    Ir.attribute "direction" (HtmlIr.Value.toString value_)


{-| The global `display` attribute.
-}
display : Value TypedSvg.Values.Display -> Attr c msg
display value_ =
    Ir.attribute "display" (HtmlIr.Value.toString value_)


{-| The global `dominant-baseline` attribute.
-}
dominantBaseline : Value TypedSvg.Values.DominantBaseline -> Attr c msg
dominantBaseline value_ =
    Ir.attribute "dominant-baseline" (HtmlIr.Value.toString value_)


{-| The global `fill` attribute.
-}
fill : String -> Attr c msg
fill =
    Ir.attribute "fill"


{-| The global `fill-opacity` attribute.
-}
fillOpacity : String -> Attr c msg
fillOpacity =
    Ir.attribute "fill-opacity"


{-| The global `fill-rule` attribute.
-}
fillRule : Value TypedSvg.Values.FillRule -> Attr c msg
fillRule value_ =
    Ir.attribute "fill-rule" (HtmlIr.Value.toString value_)


{-| The global `filter` attribute.
-}
filter : String -> Attr c msg
filter =
    Ir.attribute "filter"


{-| The global `font-family` attribute.
-}
fontFamily : String -> Attr c msg
fontFamily =
    Ir.attribute "font-family"


{-| The global `font-size` attribute.
-}
fontSize : String -> Attr c msg
fontSize =
    Ir.attribute "font-size"


{-| The global `font-style` attribute.
-}
fontStyle : String -> Attr c msg
fontStyle =
    Ir.attribute "font-style"


{-| The global `font-variant` attribute.
-}
fontVariant : Value TypedSvg.Values.FontVariant -> Attr c msg
fontVariant value_ =
    Ir.attribute "font-variant" (HtmlIr.Value.toString value_)


{-| The global `font-weight` attribute.
-}
fontWeight : String -> Attr c msg
fontWeight =
    Ir.attribute "font-weight"


{-| The global `glyph-orientation-vertical` attribute.
-}
glyphOrientationVertical : String -> Attr c msg
glyphOrientationVertical =
    Ir.attribute "glyph-orientation-vertical"


{-| The global `image-rendering` attribute.
-}
imageRendering : Value TypedSvg.Values.ImageRendering -> Attr c msg
imageRendering value_ =
    Ir.attribute "image-rendering" (HtmlIr.Value.toString value_)


{-| The global `lang` attribute.
-}
lang : String -> Attr c msg
lang =
    Ir.attribute "lang"


{-| The global `letter-spacing` attribute.
-}
letterSpacing : String -> Attr c msg
letterSpacing =
    Ir.attribute "letter-spacing"


{-| The global `line-height` attribute.
-}
lineHeight : String -> Attr c msg
lineHeight =
    Ir.attribute "line-height"


{-| The global `marker-end` attribute.
-}
markerEnd : String -> Attr c msg
markerEnd =
    Ir.attribute "marker-end"


{-| The global `marker-mid` attribute.
-}
markerMid : String -> Attr c msg
markerMid =
    Ir.attribute "marker-mid"


{-| The global `marker-start` attribute.
-}
markerStart : String -> Attr c msg
markerStart =
    Ir.attribute "marker-start"


{-| The global `mask` attribute.
-}
mask : String -> Attr c msg
mask =
    Ir.attribute "mask"


{-| The global `opacity` attribute.
-}
opacity : String -> Attr c msg
opacity =
    Ir.attribute "opacity"


{-| The global `overflow` attribute.
-}
overflow : Value TypedSvg.Values.Overflow -> Attr c msg
overflow value_ =
    Ir.attribute "overflow" (HtmlIr.Value.toString value_)


{-| The global `paint-order` attribute.
-}
paintOrder : String -> Attr c msg
paintOrder =
    Ir.attribute "paint-order"


{-| The global `pointer-events` attribute.
-}
pointerEvents : Value TypedSvg.Values.PointerEvents -> Attr c msg
pointerEvents value_ =
    Ir.attribute "pointer-events" (HtmlIr.Value.toString value_)


{-| The global `role` attribute.
-}
role : String -> Attr c msg
role =
    Ir.attribute "role"


{-| The global `shape-rendering` attribute.
-}
shapeRendering : Value TypedSvg.Values.ShapeRendering -> Attr c msg
shapeRendering value_ =
    Ir.attribute "shape-rendering" (HtmlIr.Value.toString value_)


{-| The global `stroke` attribute.
-}
stroke : String -> Attr c msg
stroke =
    Ir.attribute "stroke"


{-| The global `stroke-dasharray` attribute.
-}
strokeDasharray : String -> Attr c msg
strokeDasharray =
    Ir.attribute "stroke-dasharray"


{-| The global `stroke-dashoffset` attribute.
-}
strokeDashoffset : String -> Attr c msg
strokeDashoffset =
    Ir.attribute "stroke-dashoffset"


{-| The global `stroke-linecap` attribute.
-}
strokeLinecap : Value TypedSvg.Values.StrokeLinecap -> Attr c msg
strokeLinecap value_ =
    Ir.attribute "stroke-linecap" (HtmlIr.Value.toString value_)


{-| The global `stroke-linejoin` attribute.
-}
strokeLinejoin : Value TypedSvg.Values.StrokeLinejoin -> Attr c msg
strokeLinejoin value_ =
    Ir.attribute "stroke-linejoin" (HtmlIr.Value.toString value_)


{-| The global `stroke-miterlimit` attribute.
-}
strokeMiterlimit : String -> Attr c msg
strokeMiterlimit =
    Ir.attribute "stroke-miterlimit"


{-| The global `stroke-opacity` attribute.
-}
strokeOpacity : String -> Attr c msg
strokeOpacity =
    Ir.attribute "stroke-opacity"


{-| The global `stroke-width` attribute.
-}
strokeWidth : String -> Attr c msg
strokeWidth =
    Ir.attribute "stroke-width"


{-| The global `tabindex` attribute.
-}
tabindex : String -> Attr c msg
tabindex =
    Ir.attribute "tabindex"


{-| The global `text-anchor` attribute.
-}
textAnchor : Value TypedSvg.Values.TextAnchor -> Attr c msg
textAnchor value_ =
    Ir.attribute "text-anchor" (HtmlIr.Value.toString value_)


{-| The global `text-decoration` attribute.
-}
textDecoration : String -> Attr c msg
textDecoration =
    Ir.attribute "text-decoration"


{-| The global `text-rendering` attribute.
-}
textRendering : Value TypedSvg.Values.TextRendering -> Attr c msg
textRendering value_ =
    Ir.attribute "text-rendering" (HtmlIr.Value.toString value_)


{-| The global `transform` attribute.
-}
transform : String -> Attr c msg
transform =
    Ir.attribute "transform"


{-| The global `transform-origin` attribute.
-}
transformOrigin : String -> Attr c msg
transformOrigin =
    Ir.attribute "transform-origin"


{-| The global `vector-effect` attribute.
-}
vectorEffect : Value TypedSvg.Values.VectorEffect -> Attr c msg
vectorEffect value_ =
    Ir.attribute "vector-effect" (HtmlIr.Value.toString value_)


{-| The global `visibility` attribute.
-}
visibility : Value TypedSvg.Values.Visibility -> Attr c msg
visibility value_ =
    Ir.attribute "visibility" (HtmlIr.Value.toString value_)


{-| The global `white-space` attribute.
-}
whiteSpace : Value TypedSvg.Values.WhiteSpace -> Attr c msg
whiteSpace value_ =
    Ir.attribute "white-space" (HtmlIr.Value.toString value_)


{-| The global `word-spacing` attribute.
-}
wordSpacing : String -> Attr c msg
wordSpacing =
    Ir.attribute "word-spacing"


{-| The global `writing-mode` attribute.
-}
writingMode : Value TypedSvg.Values.WritingMode -> Attr c msg
writingMode value_ =
    Ir.attribute "writing-mode" (HtmlIr.Value.toString value_)


{-| The global `xml:space` attribute.
-}
xmlSpace : Value TypedSvg.Values.XmlSpace -> Attr c msg
xmlSpace value_ =
    Ir.attribute "xml:space" (HtmlIr.Value.toString value_)


{-| Coordinate system for the clip path contents.
-}
clipPathUnits : String -> Attr { c | clipPathUnits : Supported } msg
clipPathUnits =
    Ir.attribute "clipPathUnits"


{-| X coordinate of the centre.
-}
cx : String -> Attr { c | cx : Supported } msg
cx =
    Ir.attribute "cx"


{-| Y coordinate of the centre.
-}
cy : String -> Attr { c | cy : Supported } msg
cy =
    Ir.attribute "cy"


{-| The path-data command string.
-}
d : String -> Attr { c | d : Supported } msg
d =
    Ir.attribute "d"


{-| Horizontal shift from the current text position.
-}
dx : String -> Attr { c | dx : Supported } msg
dx =
    Ir.attribute "dx"


{-| Vertical shift from the current text position.
-}
dy : String -> Attr { c | dy : Supported } msg
dy =
    Ir.attribute "dy"


{-| Radius of the focal circle.
-}
fr : String -> Attr { c | fr : Supported } msg
fr =
    Ir.attribute "fr"


{-| X coordinate of the focal point.
-}
fx : String -> Attr { c | fx : Supported } msg
fx =
    Ir.attribute "fx"


{-| Y coordinate of the focal point.
-}
fy : String -> Attr { c | fy : Supported } msg
fy =
    Ir.attribute "fy"


{-| An additional transform applied to the gradient.
-}
gradientTransform : String -> Attr { c | gradientTransform : Supported } msg
gradientTransform =
    Ir.attribute "gradientTransform"


{-| Coordinate system for the gradient (`userSpaceOnUse` or `objectBoundingBox`).
-}
gradientUnits : String -> Attr { c | gradientUnits : Supported } msg
gradientUnits =
    Ir.attribute "gradientUnits"


{-| Height of the foreignObject's viewport.
-}
height : String -> Attr { c | height : Supported } msg
height =
    Ir.attribute "height"


{-| The URL the hyperlink points to.
-}
href : String -> Attr { c | href : Supported } msg
href =
    Ir.attribute "href"


{-| How to fit the text to textLength (`spacing` or `spacingAndGlyphs`).
-}
lengthAdjust : String -> Attr { c | lengthAdjust : Supported } msg
lengthAdjust =
    Ir.attribute "lengthAdjust"


{-| Height of the marker viewport.
-}
markerHeight : String -> Attr { c | markerHeight : Supported } msg
markerHeight =
    Ir.attribute "markerHeight"


{-| Coordinate system for markerWidth/markerHeight (`strokeWidth` or `userSpaceOnUse`).
-}
markerUnits : String -> Attr { c | markerUnits : Supported } msg
markerUnits =
    Ir.attribute "markerUnits"


{-| Width of the marker viewport.
-}
markerWidth : String -> Attr { c | markerWidth : Supported } msg
markerWidth =
    Ir.attribute "markerWidth"


{-| Coordinate system for the mask's contents.
-}
maskContentUnits : String -> Attr { c | maskContentUnits : Supported } msg
maskContentUnits =
    Ir.attribute "maskContentUnits"


{-| Coordinate system for the mask region geometry.
-}
maskUnits : String -> Attr { c | maskUnits : Supported } msg
maskUnits =
    Ir.attribute "maskUnits"


{-| How glyphs are rendered along the path (`align` or `stretch`).
-}
method : String -> Attr { c | method : Supported } msg
method =
    Ir.attribute "method"


{-| Position of the stop along the gradient (0 to 1, or a percentage).
-}
offset : String -> Attr { c | offset : Supported } msg
offset =
    Ir.attribute "offset"


{-| Marker orientation (`auto`, `auto-start-reverse`, or an angle).
-}
orient : String -> Attr { c | orient : Supported } msg
orient =
    Ir.attribute "orient"


{-| The author's computed total length of the path.
-}
pathLength : String -> Attr { c | pathLength : Supported } msg
pathLength =
    Ir.attribute "pathLength"


{-| Coordinate system for the tile's contents.
-}
patternContentUnits : String -> Attr { c | patternContentUnits : Supported } msg
patternContentUnits =
    Ir.attribute "patternContentUnits"


{-| An additional transform applied to the pattern.
-}
patternTransform : String -> Attr { c | patternTransform : Supported } msg
patternTransform =
    Ir.attribute "patternTransform"


{-| Coordinate system for the tile geometry.
-}
patternUnits : String -> Attr { c | patternUnits : Supported } msg
patternUnits =
    Ir.attribute "patternUnits"


{-| The list of points, `x1,y1 x2,y2 ...`.
-}
points : String -> Attr { c | points : Supported } msg
points =
    Ir.attribute "points"


{-| How to scale the image to fit its rectangle.
-}
preserveAspectRatio : String -> Attr { c | preserveAspectRatio : Supported } msg
preserveAspectRatio =
    Ir.attribute "preserveAspectRatio"


{-| Radius.
-}
r : String -> Attr { c | r : Supported } msg
r =
    Ir.attribute "r"


{-| X coordinate of the marker's reference point (aligned to the vertex).
-}
refX : String -> Attr { c | refX : Supported } msg
refX =
    Ir.attribute "refX"


{-| Y coordinate of the marker's reference point.
-}
refY : String -> Attr { c | refY : Supported } msg
refY =
    Ir.attribute "refY"


{-| A list of extension-namespace IRIs a child requires; a `switch` selects the first child whose required extensions are all supported.
-}
requiredExtensions : String -> Attr { c | requiredExtensions : Supported } msg
requiredExtensions =
    Ir.attribute "requiredExtensions"


{-| Per-glyph rotation, in degrees.
-}
rotate : String -> Attr { c | rotate : Supported } msg
rotate =
    Ir.attribute "rotate"


{-| Horizontal radius.
-}
rx : String -> Attr { c | rx : Supported } msg
rx =
    Ir.attribute "rx"


{-| Vertical radius.
-}
ry : String -> Attr { c | ry : Supported } msg
ry =
    Ir.attribute "ry"


{-| Which side of the path the text is placed on (`left` or `right`).
-}
side : String -> Attr { c | side : Supported } msg
side =
    Ir.attribute "side"


{-| How space between glyphs is handled along the path (`auto` or `exact`).
-}
spacing : String -> Attr { c | spacing : Supported } msg
spacing =
    Ir.attribute "spacing"


{-| How the gradient repeats beyond its bounds (`pad`, `reflect`, `repeat`).
-}
spreadMethod : String -> Attr { c | spreadMethod : Supported } msg
spreadMethod =
    Ir.attribute "spreadMethod"


{-| Offset from the start of the path where the text begins.
-}
startOffset : String -> Attr { c | startOffset : Supported } msg
startOffset =
    Ir.attribute "startOffset"


{-| The colour of this stop.
-}
stopColor : String -> Attr { c | stopColor : Supported } msg
stopColor =
    Ir.attribute "stop-color"


{-| The opacity of this stop.
-}
stopOpacity : String -> Attr { c | stopOpacity : Supported } msg
stopOpacity =
    Ir.attribute "stop-opacity"


{-| A comma-separated list of BCP-47 language tags; a `switch` selects the first child whose systemLanguage matches the user's preferences.
-}
systemLanguage : String -> Attr { c | systemLanguage : Supported } msg
systemLanguage =
    Ir.attribute "systemLanguage"


{-| Where to display the linked resource.
-}
target : String -> Attr { c | target : Supported } msg
target =
    Ir.attribute "target"


{-| Target rendered length of the text.
-}
textLength : String -> Attr { c | textLength : Supported } msg
textLength =
    Ir.attribute "textLength"


{-| A viewBox for the marker's contents.
-}
viewBox : String -> Attr { c | viewBox : Supported } msg
viewBox =
    Ir.attribute "viewBox"


{-| Width of the foreignObject's viewport.
-}
width : String -> Attr { c | width : Supported } msg
width =
    Ir.attribute "width"


{-| X coordinate of the foreignObject's viewport.
-}
x : String -> Attr { c | x : Supported } msg
x =
    Ir.attribute "x"


{-| X coordinate of the start point.
-}
x1 : String -> Attr { c | x1 : Supported } msg
x1 =
    Ir.attribute "x1"


{-| X coordinate of the end point.
-}
x2 : String -> Attr { c | x2 : Supported } msg
x2 =
    Ir.attribute "x2"


{-| The SVG XML namespace declaration (`http://www.w3.org/2000/svg`).
-}
xmlns : String -> Attr { c | xmlns : Supported } msg
xmlns =
    Ir.attribute "xmlns"


{-| Y coordinate of the foreignObject's viewport.
-}
y : String -> Attr { c | y : Supported } msg
y =
    Ir.attribute "y"


{-| Y coordinate of the start point.
-}
y1 : String -> Attr { c | y1 : Supported } msg
y1 =
    Ir.attribute "y1"


{-| Y coordinate of the end point.
-}
y2 : String -> Attr { c | y2 : Supported } msg
y2 =
    Ir.attribute "y2"
