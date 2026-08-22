module TypedSvg.Review.Facts exposing (facts, globalAttributes, reExposedValueTokens)

{-| GENERATED review facts for the elm-review-cem rules (phantom pipeline).

@docs facts, globalAttributes, reExposedValueTokens

-}

import Cem.Facts exposing (Facet(..), Fact)


{-| Per-component facts.
-}
facts : List Fact
facts =
    [ { component = "a"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "href", "href" ), ( "target", "target" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "clipPath", "defs", "desc", "ellipse", "g", "image", "line", "linearGradient", "marker", "mask", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "svg", "switch", "symbol", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "circle"
      , module_ = "TypedSvg.Element.Shape"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "cx", "cx" ), ( "cy", "cy" ), ( "r", "r" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "clipPath"
      , module_ = "TypedSvg.Element.Clip"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "clipPathUnits", "clipPathUnits" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "circle", "desc", "ellipse", "line", "path", "polygon", "polyline", "rect", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "defs"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "clipPath", "defs", "desc", "ellipse", "g", "image", "line", "linearGradient", "marker", "mask", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "svg", "switch", "symbol", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "desc"
      , module_ = "TypedSvg.Element.Descriptive"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "ellipse"
      , module_ = "TypedSvg.Element.Shape"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "cx", "cx" ), ( "cy", "cy" ), ( "rx", "rx" ), ( "ry", "ry" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "g"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "clipPath", "defs", "desc", "ellipse", "g", "image", "line", "linearGradient", "marker", "mask", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "svg", "switch", "symbol", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "image"
      , module_ = "TypedSvg.Element.Image"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "href", "href" ), ( "preserveAspectRatio", "preserveAspectRatio" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "line"
      , module_ = "TypedSvg.Element.Shape"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "x1", "x1" ), ( "x2", "x2" ), ( "y1", "y1" ), ( "y2", "y2" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "linearGradient"
      , module_ = "TypedSvg.Element.Paint"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "gradientTransform", "gradientTransform" ), ( "gradientUnits", "gradientUnits" ), ( "href", "href" ), ( "spreadMethod", "spreadMethod" ), ( "x1", "x1" ), ( "x2", "x2" ), ( "y1", "y1" ), ( "y2", "y2" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "stop", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "marker"
      , module_ = "TypedSvg.Element.Clip"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "markerHeight", "markerHeight" ), ( "markerUnits", "markerUnits" ), ( "markerWidth", "markerWidth" ), ( "orient", "orient" ), ( "preserveAspectRatio", "preserveAspectRatio" ), ( "refX", "refX" ), ( "refY", "refY" ), ( "viewBox", "viewBox" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "clipPath", "defs", "desc", "ellipse", "g", "image", "line", "linearGradient", "marker", "mask", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "svg", "switch", "symbol", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "mask"
      , module_ = "TypedSvg.Element.Clip"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "maskContentUnits", "maskContentUnits" ), ( "maskUnits", "maskUnits" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "clipPath", "defs", "desc", "ellipse", "g", "image", "line", "linearGradient", "marker", "mask", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "svg", "switch", "symbol", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "path"
      , module_ = "TypedSvg.Element.Shape"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "d", "d" ), ( "pathLength", "pathLength" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "pattern"
      , module_ = "TypedSvg.Element.Paint"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "href", "href" ), ( "patternContentUnits", "patternContentUnits" ), ( "patternTransform", "patternTransform" ), ( "patternUnits", "patternUnits" ), ( "preserveAspectRatio", "preserveAspectRatio" ), ( "viewBox", "viewBox" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "clipPath", "defs", "desc", "ellipse", "g", "image", "line", "linearGradient", "marker", "mask", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "svg", "switch", "symbol", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "polygon"
      , module_ = "TypedSvg.Element.Shape"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "points", "points" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "polyline"
      , module_ = "TypedSvg.Element.Shape"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "points", "points" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "radialGradient"
      , module_ = "TypedSvg.Element.Paint"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "cx", "cx" ), ( "cy", "cy" ), ( "fr", "fr" ), ( "fx", "fx" ), ( "fy", "fy" ), ( "gradientTransform", "gradientTransform" ), ( "gradientUnits", "gradientUnits" ), ( "href", "href" ), ( "r", "r" ), ( "spreadMethod", "spreadMethod" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "stop", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "rect"
      , module_ = "TypedSvg.Element.Shape"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "rx", "rx" ), ( "ry", "ry" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "stop"
      , module_ = "TypedSvg.Element.Paint"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "offset", "offset" ), ( "stopColor", "stopColor" ), ( "stopOpacity", "stopOpacity" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "svg"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "preserveAspectRatio", "preserveAspectRatio" ), ( "viewBox", "viewBox" ), ( "width", "width" ), ( "x", "x" ), ( "xmlns", "xmlns" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "clipPath", "defs", "desc", "ellipse", "g", "image", "line", "linearGradient", "marker", "mask", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "svg", "switch", "symbol", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "switch"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "desc", "ellipse", "g", "image", "line", "path", "polygon", "polyline", "rect", "svg", "switch", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "symbol"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "preserveAspectRatio", "preserveAspectRatio" ), ( "viewBox", "viewBox" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "a", "circle", "clipPath", "defs", "desc", "ellipse", "g", "image", "line", "linearGradient", "marker", "mask", "path", "pattern", "polygon", "polyline", "radialGradient", "rect", "svg", "switch", "symbol", "text", "title", "use" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "text"
      , module_ = "TypedSvg.Element.Text"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "dx", "dx" ), ( "dy", "dy" ), ( "lengthAdjust", "lengthAdjust" ), ( "rotate", "rotate" ), ( "textLength", "textLength" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text", "textPath", "tspan" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "textPath"
      , module_ = "TypedSvg.Element.Text"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "href", "href" ), ( "startOffset", "startOffset" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text", "tspan" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "title"
      , module_ = "TypedSvg.Element.Descriptive"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tspan"
      , module_ = "TypedSvg.Element.Text"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "dx", "dx" ), ( "dy", "dy" ), ( "rotate", "rotate" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:text", "tspan" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "use"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "href", "href" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "desc", "title" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


{-| The document-wide attributes EVERY element of this brand admits — the
`_globals` roster.

Emitted for the escape-discipline rules, which may only suggest a typed
setter when the attribute's meaning is **element-independent**. A global
qualifies by definition; an element-specific attribute does not, because from
an escape call site `content` on a `<meta>` is indistinguishable from
`content` on a custom element that gives the name its own meaning.

-}
globalAttributes : List String
globalAttributes =
    [ "class", "clip-path", "clip-rule", "color", "cursor", "display", "dominant-baseline", "fill", "fill-opacity", "fill-rule", "filter", "font-family", "font-size", "font-style", "font-weight", "id", "letter-spacing", "mask", "opacity", "paint-order", "pointer-events", "shape-rendering", "stroke", "stroke-dasharray", "stroke-dashoffset", "stroke-linecap", "stroke-linejoin", "stroke-miterlimit", "stroke-opacity", "stroke-width", "style", "text-anchor", "text-decoration", "transform", "transform-origin", "vector-effect", "visibility", "word-spacing" ]


{-| Kept for the PreferBarrel flatten class; inert on the phantom surface.
-}
reExposedValueTokens : List String
reExposedValueTokens =
    []
