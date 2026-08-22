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
      , slotKinds = []
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
      , slotKinds = []
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
      , slotKinds = []
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
    , { component = "feBlend"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "mode", [ "color", "colorBurn", "colorDodge", "darken", "difference", "exclusion", "hardLight", "hue", "lighten", "luminosity", "multiply", "normal", "overlay", "saturation", "screen", "softLight" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "in2", "in2" ), ( "in_", "in_" ), ( "mode", "mode" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feColorMatrix"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "type_", [ "huerotate", "luminancetoalpha", "matrix", "saturate" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "in_", "in_" ), ( "result", "result" ), ( "type_", "type_" ), ( "values", "values" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feComponentTransfer"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "in_", "in_" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "feFuncA", "feFuncB", "feFuncG", "feFuncR" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feComposite"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "operator", [ "arithmetic", "atop", "in_", "out", "over", "xor" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "in2", "in2" ), ( "in_", "in_" ), ( "k1", "k1" ), ( "k2", "k2" ), ( "k3", "k3" ), ( "k4", "k4" ), ( "operator", "operator" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feConvolveMatrix"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "edgeMode", [ "duplicate", "none", "wrap" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "bias", "bias" ), ( "divisor", "divisor" ), ( "edgeMode", "edgeMode" ), ( "height", "height" ), ( "in_", "in_" ), ( "kernelMatrix", "kernelMatrix" ), ( "kernelUnitLength", "kernelUnitLength" ), ( "order", "order" ), ( "preserveAlpha", "preserveAlpha" ), ( "result", "result" ), ( "targetX", "targetX" ), ( "targetY", "targetY" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feDiffuseLighting"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "diffuseConstant", "diffuseConstant" ), ( "height", "height" ), ( "in_", "in_" ), ( "kernelUnitLength", "kernelUnitLength" ), ( "result", "result" ), ( "surfaceScale", "surfaceScale" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "feDistantLight", "fePointLight", "feSpotLight" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feDisplacementMap"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "xChannelSelector", [ "a", "b", "g", "r" ] ), ( "yChannelSelector", [ "a", "b", "g", "r" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "in2", "in2" ), ( "in_", "in_" ), ( "result", "result" ), ( "scale", "scale" ), ( "width", "width" ), ( "x", "x" ), ( "xChannelSelector", "xChannelSelector" ), ( "y", "y" ), ( "yChannelSelector", "yChannelSelector" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feDistantLight"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "azimuth", "azimuth" ), ( "elevation", "elevation" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feDropShadow"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "dx", "dx" ), ( "dy", "dy" ), ( "height", "height" ), ( "in_", "in_" ), ( "result", "result" ), ( "stdDeviation", "stdDeviation" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feFlood"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feFuncA"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "type_", [ "discrete", "gamma", "identity", "linear", "table" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "amplitude", "amplitude" ), ( "exponent", "exponent" ), ( "intercept", "intercept" ), ( "offset", "offset" ), ( "slope", "slope" ), ( "tableValues", "tableValues" ), ( "type_", "type_" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feFuncB"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "type_", [ "discrete", "gamma", "identity", "linear", "table" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "amplitude", "amplitude" ), ( "exponent", "exponent" ), ( "intercept", "intercept" ), ( "offset", "offset" ), ( "slope", "slope" ), ( "tableValues", "tableValues" ), ( "type_", "type_" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feFuncG"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "type_", [ "discrete", "gamma", "identity", "linear", "table" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "amplitude", "amplitude" ), ( "exponent", "exponent" ), ( "intercept", "intercept" ), ( "offset", "offset" ), ( "slope", "slope" ), ( "tableValues", "tableValues" ), ( "type_", "type_" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feFuncR"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "type_", [ "discrete", "gamma", "identity", "linear", "table" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "amplitude", "amplitude" ), ( "exponent", "exponent" ), ( "intercept", "intercept" ), ( "offset", "offset" ), ( "slope", "slope" ), ( "tableValues", "tableValues" ), ( "type_", "type_" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feGaussianBlur"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "edgeMode", [ "duplicate", "none", "wrap" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "edgeMode", "edgeMode" ), ( "height", "height" ), ( "in_", "in_" ), ( "result", "result" ), ( "stdDeviation", "stdDeviation" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feImage"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "href", "href" ), ( "preserveAspectRatio", "preserveAspectRatio" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feMerge"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "feMergeNode" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feMergeNode"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "in_", "in_" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feMorphology"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "operator", [ "dilate", "erode" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "in_", "in_" ), ( "operator", "operator" ), ( "radius", "radius" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feOffset"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "dx", "dx" ), ( "dy", "dy" ), ( "height", "height" ), ( "in_", "in_" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "fePointLight"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "x", "x" ), ( "y", "y" ), ( "z", "z" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feSpecularLighting"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "in_", "in_" ), ( "kernelUnitLength", "kernelUnitLength" ), ( "result", "result" ), ( "specularConstant", "specularConstant" ), ( "specularExponent", "specularExponent" ), ( "surfaceScale", "surfaceScale" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "feDistantLight", "fePointLight", "feSpotLight" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feSpotLight"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "limitingConeAngle", "limitingConeAngle" ), ( "pointsAtX", "pointsAtX" ), ( "pointsAtY", "pointsAtY" ), ( "pointsAtZ", "pointsAtZ" ), ( "specularExponent", "specularExponent" ), ( "x", "x" ), ( "y", "y" ), ( "z", "z" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feTile"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "height", "height" ), ( "in_", "in_" ), ( "result", "result" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "feTurbulence"
      , module_ = "TypedSvg.Element.Filter"
      , enums = [ ( "stitchTiles", [ "nostitch", "stitch" ] ), ( "type_", [ "fractalnoise", "turbulence" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "baseFrequency", "baseFrequency" ), ( "height", "height" ), ( "numOctaves", "numOctaves" ), ( "result", "result" ), ( "seed", "seed" ), ( "stitchTiles", "stitchTiles" ), ( "type_", "type_" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "filter"
      , module_ = "TypedSvg.Element.Filter"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "filterUnits", "filterUnits" ), ( "height", "height" ), ( "href", "href" ), ( "primitiveUnits", "primitiveUnits" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "foreignObject"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "height", "height" ), ( "width", "width" ), ( "x", "x" ), ( "y", "y" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "shared:flow", "shared:phrasing" ] ) ]
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
      , slotKinds = []
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
      , slotKinds = []
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
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "metadata"
      , module_ = "TypedSvg.Element.Descriptive"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
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
      , slotKinds = []
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
      , slotKinds = []
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
      , attrRewrites = [ ( "requiredExtensions", "requiredExtensions" ), ( "systemLanguage", "systemLanguage" ) ]
      , slotRewrites = []
      , slotKinds = []
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
      , slotKinds = []
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
      , attrRewrites = [ ( "href", "href" ), ( "method", "method" ), ( "side", "side" ), ( "spacing", "spacing" ), ( "startOffset", "startOffset" ) ]
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
    , { component = "view"
      , module_ = "TypedSvg.Element.Structure"
      , enums = []
      , requiredSlots = []
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "preserveAspectRatio", "preserveAspectRatio" ), ( "viewBox", "viewBox" ) ]
      , slotRewrites = []
      , slotKinds = []
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
    [ "alignment-baseline", "baseline-shift", "class", "clip-path", "clip-rule", "color", "color-interpolation", "color-interpolation-filters", "color-rendering", "cursor", "direction", "display", "dominant-baseline", "fill", "fill-opacity", "fill-rule", "filter", "flood-color", "flood-opacity", "font-family", "font-size", "font-style", "font-variant", "font-weight", "glyph-orientation-vertical", "id", "image-rendering", "lang", "letter-spacing", "lighting-color", "line-height", "marker-end", "marker-mid", "marker-start", "mask", "opacity", "overflow", "paint-order", "pointer-events", "role", "shape-rendering", "stroke", "stroke-dasharray", "stroke-dashoffset", "stroke-linecap", "stroke-linejoin", "stroke-miterlimit", "stroke-opacity", "stroke-width", "style", "tabindex", "text-anchor", "text-decoration", "text-rendering", "transform", "transform-origin", "vector-effect", "visibility", "white-space", "word-spacing", "writing-mode", "xml:space" ]


{-| Kept for the PreferBarrel flatten class; inert on the phantom surface.
-}
reExposedValueTokens : List String
reExposedValueTokens =
    []
