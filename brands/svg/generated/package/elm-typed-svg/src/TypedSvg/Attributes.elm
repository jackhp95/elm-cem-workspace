module TypedSvg.Attributes exposing
    ( class, id, style, alignmentBaseline, ariaRoledescription, baselineShift, clipPath, clipRule, color, colorInterpolation, colorInterpolationFilters, colorRendering, cursor, direction, display, dominantBaseline, fill, fillOpacity, fillRule, filter, floodColor, floodOpacity, fontFamily, fontSize, fontStyle, fontVariant, fontWeight, glyphOrientationVertical, imageRendering, lang, letterSpacing, lightingColor, lineHeight, markerEnd, markerMid, markerStart, mask, opacity, overflow, paintOrder, pointerEvents, role, shapeRendering, stroke, strokeDasharray, strokeDashoffset, strokeLinecap, strokeLinejoin, strokeMiterlimit, strokeOpacity, strokeWidth, tabindex, textAnchor, textDecoration, textRendering, transform, transformOrigin, vectorEffect, visibility, whiteSpace, wordSpacing, writingMode, xmlSpace, classList, styleList
    , amplitude, azimuth, baseFrequency, bias, clipPathUnits, cx, cy, d, diffuseConstant, divisor, dx, dy, elevation, exponent, filterUnits, fr, fx, fy, gradientTransform, gradientUnits, height, href, in2, in_, intercept, k1, k2, k3, k4, kernelMatrix, kernelUnitLength, lengthAdjust, limitingConeAngle, markerHeight, markerUnits, markerWidth, maskContentUnits, maskUnits, method, numOctaves, offset, order, orient, pathLength, patternContentUnits, patternTransform, patternUnits, points, pointsAtX, pointsAtY, pointsAtZ, preserveAlpha, preserveAspectRatio, primitiveUnits, r, radius, refX, refY, requiredExtensions, result, rotate, rx, ry, scale, seed, side, slope, spacing, specularConstant, specularExponent, spreadMethod, startOffset, stdDeviation, stopColor, stopOpacity, surfaceScale, systemLanguage, tableValues, target, targetX, targetY, textLength, values, viewBox, width, x, x1, x2, xmlns, y, y1, y2, z
    , edgeMode, mode, operator, stitchTiles, type_, xChannelSelector, yChannelSelector
    , edgeModeDuplicate, edgeModeNone, edgeModeWrap, modeColor, modeColorBurn, modeColorDodge, modeDarken, modeDifference, modeExclusion, modeHardLight, modeHue, modeLighten, modeLuminosity, modeMultiply, modeNormal, modeOverlay, modeSaturation, modeScreen, modeSoftLight, operatorArithmetic, operatorAtop, operatorDilate, operatorErode, operatorIn_, operatorOut, operatorOver, operatorXor, stitchTilesNostitch, stitchTilesStitch, type_Discrete, type_Fractalnoise, type_Gamma, type_Huerotate, type_Identity, type_Linear, type_Luminancetoalpha, type_Matrix, type_Saturate, type_Table, type_Turbulence, xChannelSelectorA, xChannelSelectorB, xChannelSelectorG, xChannelSelectorR, yChannelSelectorA, yChannelSelectorB, yChannelSelectorG, yChannelSelectorR
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

@docs class, id, style, alignmentBaseline, ariaRoledescription, baselineShift, clipPath, clipRule, color, colorInterpolation, colorInterpolationFilters, colorRendering, cursor, direction, display, dominantBaseline, fill, fillOpacity, fillRule, filter, floodColor, floodOpacity, fontFamily, fontSize, fontStyle, fontVariant, fontWeight, glyphOrientationVertical, imageRendering, lang, letterSpacing, lightingColor, lineHeight, markerEnd, markerMid, markerStart, mask, opacity, overflow, paintOrder, pointerEvents, role, shapeRendering, stroke, strokeDasharray, strokeDashoffset, strokeLinecap, strokeLinejoin, strokeMiterlimit, strokeOpacity, strokeWidth, tabindex, textAnchor, textDecoration, textRendering, transform, transformOrigin, vectorEffect, visibility, whiteSpace, wordSpacing, writingMode, xmlSpace, classList, styleList
@docs amplitude, azimuth, baseFrequency, bias, clipPathUnits, cx, cy, d, diffuseConstant, divisor, dx, dy, elevation, exponent, filterUnits, fr, fx, fy, gradientTransform, gradientUnits, height, href, in2, in_, intercept, k1, k2, k3, k4, kernelMatrix, kernelUnitLength, lengthAdjust, limitingConeAngle, markerHeight, markerUnits, markerWidth, maskContentUnits, maskUnits, method, numOctaves, offset, order, orient, pathLength, patternContentUnits, patternTransform, patternUnits, points, pointsAtX, pointsAtY, pointsAtZ, preserveAlpha, preserveAspectRatio, primitiveUnits, r, radius, refX, refY, requiredExtensions, result, rotate, rx, ry, scale, seed, side, slope, spacing, specularConstant, specularExponent, spreadMethod, startOffset, stdDeviation, stopColor, stopOpacity, surfaceScale, systemLanguage, tableValues, target, targetX, targetY, textLength, values, viewBox, width, x, x1, x2, xmlns, y, y1, y2, z
@docs edgeMode, mode, operator, stitchTiles, type_, xChannelSelector, yChannelSelector
@docs edgeModeDuplicate, edgeModeNone, edgeModeWrap, modeColor, modeColorBurn, modeColorDodge, modeDarken, modeDifference, modeExclusion, modeHardLight, modeHue, modeLighten, modeLuminosity, modeMultiply, modeNormal, modeOverlay, modeSaturation, modeScreen, modeSoftLight, operatorArithmetic, operatorAtop, operatorDilate, operatorErode, operatorIn_, operatorOut, operatorOver, operatorXor, stitchTilesNostitch, stitchTilesStitch, type_Discrete, type_Fractalnoise, type_Gamma, type_Huerotate, type_Identity, type_Linear, type_Luminancetoalpha, type_Matrix, type_Saturate, type_Table, type_Turbulence, xChannelSelectorA, xChannelSelectorB, xChannelSelectorG, xChannelSelectorR, yChannelSelectorA, yChannelSelectorB, yChannelSelectorG, yChannelSelectorR

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


{-| The global `aria-roledescription` attribute.
-}
ariaRoledescription : String -> Attr c msg
ariaRoledescription =
    Ir.attribute "aria-roledescription"


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


{-| The global `color-interpolation-filters` attribute.
-}
colorInterpolationFilters : Value TypedSvg.Values.ColorInterpolationFilters -> Attr c msg
colorInterpolationFilters value_ =
    Ir.attribute "color-interpolation-filters" (HtmlIr.Value.toString value_)


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


{-| The global `flood-color` attribute.
-}
floodColor : String -> Attr c msg
floodColor =
    Ir.attribute "flood-color"


{-| The global `flood-opacity` attribute.
-}
floodOpacity : String -> Attr c msg
floodOpacity =
    Ir.attribute "flood-opacity"


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


{-| The global `lighting-color` attribute.
-}
lightingColor : String -> Attr c msg
lightingColor =
    Ir.attribute "lighting-color"


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


{-| Amplitude of the gamma function.
-}
amplitude : String -> Attr { c | amplitude : Supported } msg
amplitude =
    Ir.attribute "amplitude"


{-| Direction angle in the XY plane, in degrees.
-}
azimuth : String -> Attr { c | azimuth : Supported } msg
azimuth =
    Ir.attribute "azimuth"


{-| Base frequency of the noise (`fX` or `fX fY`).
-}
baseFrequency : String -> Attr { c | baseFrequency : Supported } msg
baseFrequency =
    Ir.attribute "baseFrequency"


{-| Value added to each convolved pixel.
-}
bias : String -> Attr { c | bias : Supported } msg
bias =
    Ir.attribute "bias"


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


{-| The diffuse reflection constant kd.
-}
diffuseConstant : String -> Attr { c | diffuseConstant : Supported } msg
diffuseConstant =
    Ir.attribute "diffuseConstant"


{-| Value each convolved pixel is divided by.
-}
divisor : String -> Attr { c | divisor : Supported } msg
divisor =
    Ir.attribute "divisor"


{-| X offset of the shadow.
-}
dx : String -> Attr { c | dx : Supported } msg
dx =
    Ir.attribute "dx"


{-| Y offset of the shadow.
-}
dy : String -> Attr { c | dy : Supported } msg
dy =
    Ir.attribute "dy"


{-| Direction angle out of the XY plane, in degrees.
-}
elevation : String -> Attr { c | elevation : Supported } msg
elevation =
    Ir.attribute "elevation"


{-| Exponent of the gamma function.
-}
exponent : String -> Attr { c | exponent : Supported } msg
exponent =
    Ir.attribute "exponent"


{-| Coordinate system for the filter region (`userSpaceOnUse` or `objectBoundingBox`).
-}
filterUnits : String -> Attr { c | filterUnits : Supported } msg
filterUnits =
    Ir.attribute "filterUnits"


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


{-| Height of the primitive subregion.
-}
height : String -> Attr { c | height : Supported } msg
height =
    Ir.attribute "height"


{-| The URL the hyperlink points to.
-}
href : String -> Attr { c | href : Supported } msg
href =
    Ir.attribute "href"


{-| Second input for the primitive.
-}
in2 : String -> Attr { c | in2 : Supported } msg
in2 =
    Ir.attribute "in2"


{-| First input for the primitive (a result name or a source keyword like `SourceGraphic`).
-}
in_ : String -> Attr { c | in_ : Supported } msg
in_ =
    Ir.attribute "in"


{-| Intercept of the linear function.
-}
intercept : String -> Attr { c | intercept : Supported } msg
intercept =
    Ir.attribute "intercept"


{-| Arithmetic coefficient k1 (used when operator is `arithmetic`).
-}
k1 : String -> Attr { c | k1 : Supported } msg
k1 =
    Ir.attribute "k1"


{-| Arithmetic coefficient k2.
-}
k2 : String -> Attr { c | k2 : Supported } msg
k2 =
    Ir.attribute "k2"


{-| Arithmetic coefficient k3.
-}
k3 : String -> Attr { c | k3 : Supported } msg
k3 =
    Ir.attribute "k3"


{-| Arithmetic coefficient k4.
-}
k4 : String -> Attr { c | k4 : Supported } msg
k4 =
    Ir.attribute "k4"


{-| The list of kernel values, row-major.
-}
kernelMatrix : String -> Attr { c | kernelMatrix : Supported } msg
kernelMatrix =
    Ir.attribute "kernelMatrix"


{-| Intended distance between kernel cells.
-}
kernelUnitLength : String -> Attr { c | kernelUnitLength : Supported } msg
kernelUnitLength =
    Ir.attribute "kernelUnitLength"


{-| How to fit the text to textLength (`spacing` or `spacingAndGlyphs`).
-}
lengthAdjust : String -> Attr { c | lengthAdjust : Supported } msg
lengthAdjust =
    Ir.attribute "lengthAdjust"


{-| Half-angle of the light cone, in degrees.
-}
limitingConeAngle : String -> Attr { c | limitingConeAngle : Supported } msg
limitingConeAngle =
    Ir.attribute "limitingConeAngle"


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


{-| Number of octaves of noise.
-}
numOctaves : String -> Attr { c | numOctaves : Supported } msg
numOctaves =
    Ir.attribute "numOctaves"


{-| Offset of the gamma function.
-}
offset : String -> Attr { c | offset : Supported } msg
offset =
    Ir.attribute "offset"


{-| The size of the kernel matrix (`orderX orderY`).
-}
order : String -> Attr { c | order : Supported } msg
order =
    Ir.attribute "order"


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


{-| X of the point the light points at.
-}
pointsAtX : String -> Attr { c | pointsAtX : Supported } msg
pointsAtX =
    Ir.attribute "pointsAtX"


{-| Y of the point the light points at.
-}
pointsAtY : String -> Attr { c | pointsAtY : Supported } msg
pointsAtY =
    Ir.attribute "pointsAtY"


{-| Z of the point the light points at.
-}
pointsAtZ : String -> Attr { c | pointsAtZ : Supported } msg
pointsAtZ =
    Ir.attribute "pointsAtZ"


{-| Whether the alpha channel is convolved (`false`) or preserved (`true`).
-}
preserveAlpha : String -> Attr { c | preserveAlpha : Supported } msg
preserveAlpha =
    Ir.attribute "preserveAlpha"


{-| How to scale the referenced image into the subregion.
-}
preserveAspectRatio : String -> Attr { c | preserveAspectRatio : Supported } msg
preserveAspectRatio =
    Ir.attribute "preserveAspectRatio"


{-| Coordinate system for the filter primitives' subregions and length values.
-}
primitiveUnits : String -> Attr { c | primitiveUnits : Supported } msg
primitiveUnits =
    Ir.attribute "primitiveUnits"


{-| Radius.
-}
r : String -> Attr { c | r : Supported } msg
r =
    Ir.attribute "r"


{-| The morphology radius (`radiusX` or `radiusX radiusY`).
-}
radius : String -> Attr { c | radius : Supported } msg
radius =
    Ir.attribute "radius"


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


{-| Name assigned to this primitive's output for use as another primitive's `in`.
-}
result : String -> Attr { c | result : Supported } msg
result =
    Ir.attribute "result"


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


{-| Displacement scale factor.
-}
scale : String -> Attr { c | scale : Supported } msg
scale =
    Ir.attribute "scale"


{-| Starting seed for the pseudo-random generator.
-}
seed : String -> Attr { c | seed : Supported } msg
seed =
    Ir.attribute "seed"


{-| Which side of the path the text is placed on (`left` or `right`).
-}
side : String -> Attr { c | side : Supported } msg
side =
    Ir.attribute "side"


{-| Slope of the linear function.
-}
slope : String -> Attr { c | slope : Supported } msg
slope =
    Ir.attribute "slope"


{-| How space between glyphs is handled along the path (`auto` or `exact`).
-}
spacing : String -> Attr { c | spacing : Supported } msg
spacing =
    Ir.attribute "spacing"


{-| The specular reflection constant ks.
-}
specularConstant : String -> Attr { c | specularConstant : Supported } msg
specularConstant =
    Ir.attribute "specularConstant"


{-| The specular exponent (shininess).
-}
specularExponent : String -> Attr { c | specularExponent : Supported } msg
specularExponent =
    Ir.attribute "specularExponent"


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


{-| Standard deviation of the shadow's Gaussian blur.
-}
stdDeviation : String -> Attr { c | stdDeviation : Supported } msg
stdDeviation =
    Ir.attribute "stdDeviation"


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


{-| Height of the surface for the alpha bump map.
-}
surfaceScale : String -> Attr { c | surfaceScale : Supported } msg
surfaceScale =
    Ir.attribute "surfaceScale"


{-| A comma-separated list of BCP-47 language tags; a `switch` selects the first child whose systemLanguage matches the user's preferences.
-}
systemLanguage : String -> Attr { c | systemLanguage : Supported } msg
systemLanguage =
    Ir.attribute "systemLanguage"


{-| The lookup-table values (for `table`/`discrete`).
-}
tableValues : String -> Attr { c | tableValues : Supported } msg
tableValues =
    Ir.attribute "tableValues"


{-| Where to display the linked resource.
-}
target : String -> Attr { c | target : Supported } msg
target =
    Ir.attribute "target"


{-| X position of the kernel target cell.
-}
targetX : String -> Attr { c | targetX : Supported } msg
targetX =
    Ir.attribute "targetX"


{-| Y position of the kernel target cell.
-}
targetY : String -> Attr { c | targetY : Supported } msg
targetY =
    Ir.attribute "targetY"


{-| Target rendered length of the text.
-}
textLength : String -> Attr { c | textLength : Supported } msg
textLength =
    Ir.attribute "textLength"


{-| The matrix values (meaning depends on `type`).
-}
values : String -> Attr { c | values : Supported } msg
values =
    Ir.attribute "values"


{-| A viewBox for the marker's contents.
-}
viewBox : String -> Attr { c | viewBox : Supported } msg
viewBox =
    Ir.attribute "viewBox"


{-| Width of the primitive subregion.
-}
width : String -> Attr { c | width : Supported } msg
width =
    Ir.attribute "width"


{-| X coordinate of the primitive subregion.
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


{-| Y coordinate of the primitive subregion.
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


{-| Z location of the light source.
-}
z : String -> Attr { c | z : Supported } msg
z =
    Ir.attribute "z"


{-| How the kernel behaves at the input edges.
-}
edgeMode : Value TypedSvg.Values.EdgeMode -> Attr { c | edgeMode : Supported } msg
edgeMode value_ =
    Ir.attribute "edgeMode" (HtmlIr.Value.toString value_)


{-| The blend mode.
-}
mode : Value TypedSvg.Values.Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (HtmlIr.Value.toString value_)


{-| The compositing operator.
-}
operator : Value TypedSvg.Values.Operator -> Attr { c | operator : Supported } msg
operator value_ =
    Ir.attribute "operator" (HtmlIr.Value.toString value_)


{-| Whether tile edges are stitched to avoid seams.
-}
stitchTiles : Value TypedSvg.Values.StitchTiles -> Attr { c | stitchTiles : Supported } msg
stitchTiles value_ =
    Ir.attribute "stitchTiles" (HtmlIr.Value.toString value_)


{-| The kind of matrix operation.
-}
type_ : Value TypedSvg.Values.Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (HtmlIr.Value.toString value_)


{-| Which channel of in2 drives X displacement.
-}
xChannelSelector : Value TypedSvg.Values.XChannelSelector -> Attr { c | xChannelSelector : Supported } msg
xChannelSelector value_ =
    Ir.attribute "xChannelSelector" (HtmlIr.Value.toString value_)


{-| Which channel of in2 drives Y displacement.
-}
yChannelSelector : Value TypedSvg.Values.YChannelSelector -> Attr { c | yChannelSelector : Supported } msg
yChannelSelector value_ =
    Ir.attribute "yChannelSelector" (HtmlIr.Value.toString value_)


{-| Set the `edgeMode` attribute to `"duplicate"`. Portmanteau of `edgeMode` + `duplicate` — for IDE discovery and single-import ergonomics.
-}
edgeModeDuplicate : Attr { c | edgeMode : Supported } msg
edgeModeDuplicate =
    Ir.attribute "edgeMode" "duplicate"


{-| Set the `edgeMode` attribute to `"none"`. Portmanteau of `edgeMode` + `none` — for IDE discovery and single-import ergonomics.
-}
edgeModeNone : Attr { c | edgeMode : Supported } msg
edgeModeNone =
    Ir.attribute "edgeMode" "none"


{-| Set the `edgeMode` attribute to `"wrap"`. Portmanteau of `edgeMode` + `wrap` — for IDE discovery and single-import ergonomics.
-}
edgeModeWrap : Attr { c | edgeMode : Supported } msg
edgeModeWrap =
    Ir.attribute "edgeMode" "wrap"


{-| Set the `mode` attribute to `"color"`. Portmanteau of `mode` + `color` — for IDE discovery and single-import ergonomics.
-}
modeColor : Attr { c | mode : Supported } msg
modeColor =
    Ir.attribute "mode" "color"


{-| Set the `mode` attribute to `"color-burn"`. Portmanteau of `mode` + `color-burn` — for IDE discovery and single-import ergonomics.
-}
modeColorBurn : Attr { c | mode : Supported } msg
modeColorBurn =
    Ir.attribute "mode" "color-burn"


{-| Set the `mode` attribute to `"color-dodge"`. Portmanteau of `mode` + `color-dodge` — for IDE discovery and single-import ergonomics.
-}
modeColorDodge : Attr { c | mode : Supported } msg
modeColorDodge =
    Ir.attribute "mode" "color-dodge"


{-| Set the `mode` attribute to `"darken"`. Portmanteau of `mode` + `darken` — for IDE discovery and single-import ergonomics.
-}
modeDarken : Attr { c | mode : Supported } msg
modeDarken =
    Ir.attribute "mode" "darken"


{-| Set the `mode` attribute to `"difference"`. Portmanteau of `mode` + `difference` — for IDE discovery and single-import ergonomics.
-}
modeDifference : Attr { c | mode : Supported } msg
modeDifference =
    Ir.attribute "mode" "difference"


{-| Set the `mode` attribute to `"exclusion"`. Portmanteau of `mode` + `exclusion` — for IDE discovery and single-import ergonomics.
-}
modeExclusion : Attr { c | mode : Supported } msg
modeExclusion =
    Ir.attribute "mode" "exclusion"


{-| Set the `mode` attribute to `"hard-light"`. Portmanteau of `mode` + `hard-light` — for IDE discovery and single-import ergonomics.
-}
modeHardLight : Attr { c | mode : Supported } msg
modeHardLight =
    Ir.attribute "mode" "hard-light"


{-| Set the `mode` attribute to `"hue"`. Portmanteau of `mode` + `hue` — for IDE discovery and single-import ergonomics.
-}
modeHue : Attr { c | mode : Supported } msg
modeHue =
    Ir.attribute "mode" "hue"


{-| Set the `mode` attribute to `"lighten"`. Portmanteau of `mode` + `lighten` — for IDE discovery and single-import ergonomics.
-}
modeLighten : Attr { c | mode : Supported } msg
modeLighten =
    Ir.attribute "mode" "lighten"


{-| Set the `mode` attribute to `"luminosity"`. Portmanteau of `mode` + `luminosity` — for IDE discovery and single-import ergonomics.
-}
modeLuminosity : Attr { c | mode : Supported } msg
modeLuminosity =
    Ir.attribute "mode" "luminosity"


{-| Set the `mode` attribute to `"multiply"`. Portmanteau of `mode` + `multiply` — for IDE discovery and single-import ergonomics.
-}
modeMultiply : Attr { c | mode : Supported } msg
modeMultiply =
    Ir.attribute "mode" "multiply"


{-| Set the `mode` attribute to `"normal"`. Portmanteau of `mode` + `normal` — for IDE discovery and single-import ergonomics.
-}
modeNormal : Attr { c | mode : Supported } msg
modeNormal =
    Ir.attribute "mode" "normal"


{-| Set the `mode` attribute to `"overlay"`. Portmanteau of `mode` + `overlay` — for IDE discovery and single-import ergonomics.
-}
modeOverlay : Attr { c | mode : Supported } msg
modeOverlay =
    Ir.attribute "mode" "overlay"


{-| Set the `mode` attribute to `"saturation"`. Portmanteau of `mode` + `saturation` — for IDE discovery and single-import ergonomics.
-}
modeSaturation : Attr { c | mode : Supported } msg
modeSaturation =
    Ir.attribute "mode" "saturation"


{-| Set the `mode` attribute to `"screen"`. Portmanteau of `mode` + `screen` — for IDE discovery and single-import ergonomics.
-}
modeScreen : Attr { c | mode : Supported } msg
modeScreen =
    Ir.attribute "mode" "screen"


{-| Set the `mode` attribute to `"soft-light"`. Portmanteau of `mode` + `soft-light` — for IDE discovery and single-import ergonomics.
-}
modeSoftLight : Attr { c | mode : Supported } msg
modeSoftLight =
    Ir.attribute "mode" "soft-light"


{-| Set the `operator` attribute to `"arithmetic"`. Portmanteau of `operator` + `arithmetic` — for IDE discovery and single-import ergonomics.
-}
operatorArithmetic : Attr { c | operator : Supported } msg
operatorArithmetic =
    Ir.attribute "operator" "arithmetic"


{-| Set the `operator` attribute to `"atop"`. Portmanteau of `operator` + `atop` — for IDE discovery and single-import ergonomics.
-}
operatorAtop : Attr { c | operator : Supported } msg
operatorAtop =
    Ir.attribute "operator" "atop"


{-| Set the `operator` attribute to `"dilate"`. Portmanteau of `operator` + `dilate` — for IDE discovery and single-import ergonomics.
-}
operatorDilate : Attr { c | operator : Supported } msg
operatorDilate =
    Ir.attribute "operator" "dilate"


{-| Set the `operator` attribute to `"erode"`. Portmanteau of `operator` + `erode` — for IDE discovery and single-import ergonomics.
-}
operatorErode : Attr { c | operator : Supported } msg
operatorErode =
    Ir.attribute "operator" "erode"


{-| Set the `operator` attribute to `"in"`. Portmanteau of `operator` + `in` — for IDE discovery and single-import ergonomics.
-}
operatorIn_ : Attr { c | operator : Supported } msg
operatorIn_ =
    Ir.attribute "operator" "in"


{-| Set the `operator` attribute to `"out"`. Portmanteau of `operator` + `out` — for IDE discovery and single-import ergonomics.
-}
operatorOut : Attr { c | operator : Supported } msg
operatorOut =
    Ir.attribute "operator" "out"


{-| Set the `operator` attribute to `"over"`. Portmanteau of `operator` + `over` — for IDE discovery and single-import ergonomics.
-}
operatorOver : Attr { c | operator : Supported } msg
operatorOver =
    Ir.attribute "operator" "over"


{-| Set the `operator` attribute to `"xor"`. Portmanteau of `operator` + `xor` — for IDE discovery and single-import ergonomics.
-}
operatorXor : Attr { c | operator : Supported } msg
operatorXor =
    Ir.attribute "operator" "xor"


{-| Set the `stitchTiles` attribute to `"noStitch"`. Portmanteau of `stitchTiles` + `noStitch` — for IDE discovery and single-import ergonomics.
-}
stitchTilesNostitch : Attr { c | stitchTiles : Supported } msg
stitchTilesNostitch =
    Ir.attribute "stitchTiles" "noStitch"


{-| Set the `stitchTiles` attribute to `"stitch"`. Portmanteau of `stitchTiles` + `stitch` — for IDE discovery and single-import ergonomics.
-}
stitchTilesStitch : Attr { c | stitchTiles : Supported } msg
stitchTilesStitch =
    Ir.attribute "stitchTiles" "stitch"


{-| Set the `type` attribute to `"discrete"`. Portmanteau of `type_` + `discrete` — for IDE discovery and single-import ergonomics.
-}
type_Discrete : Attr { c | type_ : Supported } msg
type_Discrete =
    Ir.attribute "type" "discrete"


{-| Set the `type` attribute to `"fractalNoise"`. Portmanteau of `type_` + `fractalNoise` — for IDE discovery and single-import ergonomics.
-}
type_Fractalnoise : Attr { c | type_ : Supported } msg
type_Fractalnoise =
    Ir.attribute "type" "fractalNoise"


{-| Set the `type` attribute to `"gamma"`. Portmanteau of `type_` + `gamma` — for IDE discovery and single-import ergonomics.
-}
type_Gamma : Attr { c | type_ : Supported } msg
type_Gamma =
    Ir.attribute "type" "gamma"


{-| Set the `type` attribute to `"hueRotate"`. Portmanteau of `type_` + `hueRotate` — for IDE discovery and single-import ergonomics.
-}
type_Huerotate : Attr { c | type_ : Supported } msg
type_Huerotate =
    Ir.attribute "type" "hueRotate"


{-| Set the `type` attribute to `"identity"`. Portmanteau of `type_` + `identity` — for IDE discovery and single-import ergonomics.
-}
type_Identity : Attr { c | type_ : Supported } msg
type_Identity =
    Ir.attribute "type" "identity"


{-| Set the `type` attribute to `"linear"`. Portmanteau of `type_` + `linear` — for IDE discovery and single-import ergonomics.
-}
type_Linear : Attr { c | type_ : Supported } msg
type_Linear =
    Ir.attribute "type" "linear"


{-| Set the `type` attribute to `"luminanceToAlpha"`. Portmanteau of `type_` + `luminanceToAlpha` — for IDE discovery and single-import ergonomics.
-}
type_Luminancetoalpha : Attr { c | type_ : Supported } msg
type_Luminancetoalpha =
    Ir.attribute "type" "luminanceToAlpha"


{-| Set the `type` attribute to `"matrix"`. Portmanteau of `type_` + `matrix` — for IDE discovery and single-import ergonomics.
-}
type_Matrix : Attr { c | type_ : Supported } msg
type_Matrix =
    Ir.attribute "type" "matrix"


{-| Set the `type` attribute to `"saturate"`. Portmanteau of `type_` + `saturate` — for IDE discovery and single-import ergonomics.
-}
type_Saturate : Attr { c | type_ : Supported } msg
type_Saturate =
    Ir.attribute "type" "saturate"


{-| Set the `type` attribute to `"table"`. Portmanteau of `type_` + `table` — for IDE discovery and single-import ergonomics.
-}
type_Table : Attr { c | type_ : Supported } msg
type_Table =
    Ir.attribute "type" "table"


{-| Set the `type` attribute to `"turbulence"`. Portmanteau of `type_` + `turbulence` — for IDE discovery and single-import ergonomics.
-}
type_Turbulence : Attr { c | type_ : Supported } msg
type_Turbulence =
    Ir.attribute "type" "turbulence"


{-| Set the `xChannelSelector` attribute to `"A"`. Portmanteau of `xChannelSelector` + `A` — for IDE discovery and single-import ergonomics.
-}
xChannelSelectorA : Attr { c | xChannelSelector : Supported } msg
xChannelSelectorA =
    Ir.attribute "xChannelSelector" "A"


{-| Set the `xChannelSelector` attribute to `"B"`. Portmanteau of `xChannelSelector` + `B` — for IDE discovery and single-import ergonomics.
-}
xChannelSelectorB : Attr { c | xChannelSelector : Supported } msg
xChannelSelectorB =
    Ir.attribute "xChannelSelector" "B"


{-| Set the `xChannelSelector` attribute to `"G"`. Portmanteau of `xChannelSelector` + `G` — for IDE discovery and single-import ergonomics.
-}
xChannelSelectorG : Attr { c | xChannelSelector : Supported } msg
xChannelSelectorG =
    Ir.attribute "xChannelSelector" "G"


{-| Set the `xChannelSelector` attribute to `"R"`. Portmanteau of `xChannelSelector` + `R` — for IDE discovery and single-import ergonomics.
-}
xChannelSelectorR : Attr { c | xChannelSelector : Supported } msg
xChannelSelectorR =
    Ir.attribute "xChannelSelector" "R"


{-| Set the `yChannelSelector` attribute to `"A"`. Portmanteau of `yChannelSelector` + `A` — for IDE discovery and single-import ergonomics.
-}
yChannelSelectorA : Attr { c | yChannelSelector : Supported } msg
yChannelSelectorA =
    Ir.attribute "yChannelSelector" "A"


{-| Set the `yChannelSelector` attribute to `"B"`. Portmanteau of `yChannelSelector` + `B` — for IDE discovery and single-import ergonomics.
-}
yChannelSelectorB : Attr { c | yChannelSelector : Supported } msg
yChannelSelectorB =
    Ir.attribute "yChannelSelector" "B"


{-| Set the `yChannelSelector` attribute to `"G"`. Portmanteau of `yChannelSelector` + `G` — for IDE discovery and single-import ergonomics.
-}
yChannelSelectorG : Attr { c | yChannelSelector : Supported } msg
yChannelSelectorG =
    Ir.attribute "yChannelSelector" "G"


{-| Set the `yChannelSelector` attribute to `"R"`. Portmanteau of `yChannelSelector` + `R` — for IDE discovery and single-import ergonomics.
-}
yChannelSelectorR : Attr { c | yChannelSelector : Supported } msg
yChannelSelectorR =
    Ir.attribute "yChannelSelector" "R"
