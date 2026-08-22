module TypedSvg.Element.Filter exposing
    ( feBlend, feColorMatrix, feComponentTransfer, feComposite, feConvolveMatrix, feDiffuseLighting, feDisplacementMap, feDistantLight, feDropShadow, feFlood, feFuncA, feFuncB, feFuncG, feFuncR, feGaussianBlur, feImage, feMerge, feMergeNode, feMorphology, feOffset, fePointLight, feSpecularLighting, feSpotLight, feTile, feTurbulence, filter
    , FeBlendIs, FeBlendAttrs, FeBlendChildAdmittedBy, FeColorMatrixIs, FeColorMatrixAttrs, FeColorMatrixChildAdmittedBy, FeComponentTransferIs, FeComponentTransferAttrs, FeComponentTransferContent, FeComponentTransferChildAdmittedBy, FeCompositeIs, FeCompositeAttrs, FeCompositeChildAdmittedBy, FeConvolveMatrixIs, FeConvolveMatrixAttrs, FeConvolveMatrixChildAdmittedBy, FeDiffuseLightingIs, FeDiffuseLightingAttrs, FeDiffuseLightingContent, FeDiffuseLightingChildAdmittedBy, FeDisplacementMapIs, FeDisplacementMapAttrs, FeDisplacementMapChildAdmittedBy, FeDistantLightIs, FeDistantLightAttrs, FeDistantLightChildAdmittedBy, FeDropShadowIs, FeDropShadowAttrs, FeDropShadowChildAdmittedBy, FeFloodIs, FeFloodAttrs, FeFloodChildAdmittedBy, FeFuncAIs, FeFuncAAttrs, FeFuncAChildAdmittedBy, FeFuncBIs, FeFuncBAttrs, FeFuncBChildAdmittedBy, FeFuncGIs, FeFuncGAttrs, FeFuncGChildAdmittedBy, FeFuncRIs, FeFuncRAttrs, FeFuncRChildAdmittedBy, FeGaussianBlurIs, FeGaussianBlurAttrs, FeGaussianBlurChildAdmittedBy, FeImageIs, FeImageAttrs, FeImageChildAdmittedBy, FeMergeIs, FeMergeAttrs, FeMergeContent, FeMergeChildAdmittedBy, FeMergeNodeIs, FeMergeNodeAttrs, FeMergeNodeChildAdmittedBy, FeMorphologyIs, FeMorphologyAttrs, FeMorphologyChildAdmittedBy, FeOffsetIs, FeOffsetAttrs, FeOffsetChildAdmittedBy, FePointLightIs, FePointLightAttrs, FePointLightChildAdmittedBy, FeSpecularLightingIs, FeSpecularLightingAttrs, FeSpecularLightingContent, FeSpecularLightingChildAdmittedBy, FeSpotLightIs, FeSpotLightAttrs, FeSpotLightChildAdmittedBy, FeTileIs, FeTileAttrs, FeTileChildAdmittedBy, FeTurbulenceIs, FeTurbulenceAttrs, FeTurbulenceChildAdmittedBy, FilterIs, FilterAttrs, FilterChildAdmittedBy
    , amplitude, azimuth, baseFrequency, bias, diffuseConstant, divisor, dx, dy, edgeMode, elevation, exponent, filterUnits, height, href, in2, in_, intercept, k1, k2, k3, k4, kernelMatrix, kernelUnitLength, limitingConeAngle, mode, numOctaves, offset, operator, order, pointsAtX, pointsAtY, pointsAtZ, preserveAlpha, preserveAspectRatio, primitiveUnits, radius, result, scale, seed, slope, specularConstant, specularExponent, stdDeviation, stitchTiles, surfaceScale, tableValues, targetX, targetY, type_, values, width, x, xChannelSelector, y, yChannelSelector, z
    )

{-| The `Filter` element home: constructors, per-element rows, and
co-located re-exports of the shared attributes its elements admit.

@docs feBlend, feColorMatrix, feComponentTransfer, feComposite, feConvolveMatrix, feDiffuseLighting, feDisplacementMap, feDistantLight, feDropShadow, feFlood, feFuncA, feFuncB, feFuncG, feFuncR, feGaussianBlur, feImage, feMerge, feMergeNode, feMorphology, feOffset, fePointLight, feSpecularLighting, feSpotLight, feTile, feTurbulence, filter
@docs FeBlendIs, FeBlendAttrs, FeBlendChildAdmittedBy, FeColorMatrixIs, FeColorMatrixAttrs, FeColorMatrixChildAdmittedBy, FeComponentTransferIs, FeComponentTransferAttrs, FeComponentTransferContent, FeComponentTransferChildAdmittedBy, FeCompositeIs, FeCompositeAttrs, FeCompositeChildAdmittedBy, FeConvolveMatrixIs, FeConvolveMatrixAttrs, FeConvolveMatrixChildAdmittedBy, FeDiffuseLightingIs, FeDiffuseLightingAttrs, FeDiffuseLightingContent, FeDiffuseLightingChildAdmittedBy, FeDisplacementMapIs, FeDisplacementMapAttrs, FeDisplacementMapChildAdmittedBy, FeDistantLightIs, FeDistantLightAttrs, FeDistantLightChildAdmittedBy, FeDropShadowIs, FeDropShadowAttrs, FeDropShadowChildAdmittedBy, FeFloodIs, FeFloodAttrs, FeFloodChildAdmittedBy, FeFuncAIs, FeFuncAAttrs, FeFuncAChildAdmittedBy, FeFuncBIs, FeFuncBAttrs, FeFuncBChildAdmittedBy, FeFuncGIs, FeFuncGAttrs, FeFuncGChildAdmittedBy, FeFuncRIs, FeFuncRAttrs, FeFuncRChildAdmittedBy, FeGaussianBlurIs, FeGaussianBlurAttrs, FeGaussianBlurChildAdmittedBy, FeImageIs, FeImageAttrs, FeImageChildAdmittedBy, FeMergeIs, FeMergeAttrs, FeMergeContent, FeMergeChildAdmittedBy, FeMergeNodeIs, FeMergeNodeAttrs, FeMergeNodeChildAdmittedBy, FeMorphologyIs, FeMorphologyAttrs, FeMorphologyChildAdmittedBy, FeOffsetIs, FeOffsetAttrs, FeOffsetChildAdmittedBy, FePointLightIs, FePointLightAttrs, FePointLightChildAdmittedBy, FeSpecularLightingIs, FeSpecularLightingAttrs, FeSpecularLightingContent, FeSpecularLightingChildAdmittedBy, FeSpotLightIs, FeSpotLightAttrs, FeSpotLightChildAdmittedBy, FeTileIs, FeTileAttrs, FeTileChildAdmittedBy, FeTurbulenceIs, FeTurbulenceAttrs, FeTurbulenceChildAdmittedBy, FilterIs, FilterAttrs, FilterChildAdmittedBy
@docs amplitude, azimuth, baseFrequency, bias, diffuseConstant, divisor, dx, dy, edgeMode, elevation, exponent, filterUnits, height, href, in2, in_, intercept, k1, k2, k3, k4, kernelMatrix, kernelUnitLength, limitingConeAngle, mode, numOctaves, offset, operator, order, pointsAtX, pointsAtY, pointsAtZ, preserveAlpha, preserveAspectRatio, primitiveUnits, radius, result, scale, seed, slope, specularConstant, specularExponent, stdDeviation, stitchTiles, surfaceScale, tableValues, targetX, targetY, type_, values, width, x, xChannelSelector, y, yChannelSelector, z

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import TypedSvg.Attributes
import TypedSvg.Kind exposing (Brand, Ctx)


{-| The kind row `feBlend` produces.
-}
type alias FeBlendIs s =
    { s | feBlend : Brand }


{-| `feBlend`'s closed attribute-capability row.
-}
type alias FeBlendAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , in2 : Supported
    , in_ : Supported
    , mode : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feBlend` injects into its children.
-}
type alias FeBlendChildAdmittedBy childAdm =
    { childAdm | feBlend : Ctx }


{-| The `feBlend` element.
-}
feBlend :
    List (Attr FeBlendAttrs msg)
    -> List (Element childAccepts (FeBlendChildAdmittedBy childAdm) msg)
    -> Element (FeBlendIs s) admittedBy msg
feBlend attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feBlend" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feColorMatrix` produces.
-}
type alias FeColorMatrixIs s =
    { s | feColorMatrix : Brand }


{-| `feColorMatrix`'s closed attribute-capability row.
-}
type alias FeColorMatrixAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , result : Supported
    , style : Supported
    , type_ : Supported
    , values : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feColorMatrix` injects into its children.
-}
type alias FeColorMatrixChildAdmittedBy childAdm =
    { childAdm | feColorMatrix : Ctx }


{-| The `feColorMatrix` element.
-}
feColorMatrix :
    List (Attr FeColorMatrixAttrs msg)
    -> List (Element childAccepts (FeColorMatrixChildAdmittedBy childAdm) msg)
    -> Element (FeColorMatrixIs s) admittedBy msg
feColorMatrix attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feColorMatrix" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feComponentTransfer` produces.
-}
type alias FeComponentTransferIs s =
    { s | feComponentTransfer : Brand }


{-| `feComponentTransfer`'s closed attribute-capability row.
-}
type alias FeComponentTransferAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `feComponentTransfer` admits.
-}
type alias FeComponentTransferContent =
    { feFuncA : Brand
    , feFuncB : Brand
    , feFuncG : Brand
    , feFuncR : Brand
    }


{-| The context demand `feComponentTransfer` injects into its children.
-}
type alias FeComponentTransferChildAdmittedBy childAdm =
    { childAdm | feComponentTransfer : Ctx }


{-| The `feComponentTransfer` element.
-}
feComponentTransfer :
    List (Attr FeComponentTransferAttrs msg)
    -> List (Element FeComponentTransferContent (FeComponentTransferChildAdmittedBy childAdm) msg)
    -> Element (FeComponentTransferIs s) admittedBy msg
feComponentTransfer attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feComponentTransfer" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feComposite` produces.
-}
type alias FeCompositeIs s =
    { s | feComposite : Brand }


{-| `feComposite`'s closed attribute-capability row.
-}
type alias FeCompositeAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , in2 : Supported
    , in_ : Supported
    , k1 : Supported
    , k2 : Supported
    , k3 : Supported
    , k4 : Supported
    , operator : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feComposite` injects into its children.
-}
type alias FeCompositeChildAdmittedBy childAdm =
    { childAdm | feComposite : Ctx }


{-| The `feComposite` element.
-}
feComposite :
    List (Attr FeCompositeAttrs msg)
    -> List (Element childAccepts (FeCompositeChildAdmittedBy childAdm) msg)
    -> Element (FeCompositeIs s) admittedBy msg
feComposite attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feComposite" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feConvolveMatrix` produces.
-}
type alias FeConvolveMatrixIs s =
    { s | feConvolveMatrix : Brand }


{-| `feConvolveMatrix`'s closed attribute-capability row.
-}
type alias FeConvolveMatrixAttrs =
    { bias : Supported
    , class : Supported
    , divisor : Supported
    , edgeMode : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , kernelMatrix : Supported
    , kernelUnitLength : Supported
    , order : Supported
    , preserveAlpha : Supported
    , result : Supported
    , style : Supported
    , targetX : Supported
    , targetY : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feConvolveMatrix` injects into its children.
-}
type alias FeConvolveMatrixChildAdmittedBy childAdm =
    { childAdm | feConvolveMatrix : Ctx }


{-| The `feConvolveMatrix` element.
-}
feConvolveMatrix :
    List (Attr FeConvolveMatrixAttrs msg)
    -> List (Element childAccepts (FeConvolveMatrixChildAdmittedBy childAdm) msg)
    -> Element (FeConvolveMatrixIs s) admittedBy msg
feConvolveMatrix attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feConvolveMatrix" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feDiffuseLighting` produces.
-}
type alias FeDiffuseLightingIs s =
    { s | feDiffuseLighting : Brand }


{-| `feDiffuseLighting`'s closed attribute-capability row.
-}
type alias FeDiffuseLightingAttrs =
    { class : Supported
    , diffuseConstant : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , kernelUnitLength : Supported
    , result : Supported
    , style : Supported
    , surfaceScale : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `feDiffuseLighting` admits.
-}
type alias FeDiffuseLightingContent =
    { feDistantLight : Brand
    , fePointLight : Brand
    , feSpotLight : Brand
    }


{-| The context demand `feDiffuseLighting` injects into its children.
-}
type alias FeDiffuseLightingChildAdmittedBy childAdm =
    { childAdm | feDiffuseLighting : Ctx }


{-| The `feDiffuseLighting` element.
-}
feDiffuseLighting :
    List (Attr FeDiffuseLightingAttrs msg)
    -> List (Element FeDiffuseLightingContent (FeDiffuseLightingChildAdmittedBy childAdm) msg)
    -> Element (FeDiffuseLightingIs s) admittedBy msg
feDiffuseLighting attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feDiffuseLighting" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feDisplacementMap` produces.
-}
type alias FeDisplacementMapIs s =
    { s | feDisplacementMap : Brand }


{-| `feDisplacementMap`'s closed attribute-capability row.
-}
type alias FeDisplacementMapAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , in2 : Supported
    , in_ : Supported
    , result : Supported
    , scale : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , xChannelSelector : Supported
    , y : Supported
    , yChannelSelector : Supported
    }


{-| The context demand `feDisplacementMap` injects into its children.
-}
type alias FeDisplacementMapChildAdmittedBy childAdm =
    { childAdm | feDisplacementMap : Ctx }


{-| The `feDisplacementMap` element.
-}
feDisplacementMap :
    List (Attr FeDisplacementMapAttrs msg)
    -> List (Element childAccepts (FeDisplacementMapChildAdmittedBy childAdm) msg)
    -> Element (FeDisplacementMapIs s) admittedBy msg
feDisplacementMap attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feDisplacementMap" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feDistantLight` produces.
-}
type alias FeDistantLightIs s =
    { s | feDistantLight : Brand }


{-| `feDistantLight`'s closed attribute-capability row.
-}
type alias FeDistantLightAttrs =
    { azimuth : Supported
    , class : Supported
    , elevation : Supported
    , id : Supported
    , style : Supported
    }


{-| The context demand `feDistantLight` injects into its children.
-}
type alias FeDistantLightChildAdmittedBy childAdm =
    { childAdm | feDistantLight : Ctx }


{-| The `feDistantLight` element.
-}
feDistantLight :
    List (Attr FeDistantLightAttrs msg)
    -> List (Element childAccepts (FeDistantLightChildAdmittedBy childAdm) msg)
    -> Element (FeDistantLightIs s) admittedBy msg
feDistantLight attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feDistantLight" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feDropShadow` produces.
-}
type alias FeDropShadowIs s =
    { s | feDropShadow : Brand }


{-| `feDropShadow`'s closed attribute-capability row.
-}
type alias FeDropShadowAttrs =
    { class : Supported
    , dx : Supported
    , dy : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , result : Supported
    , stdDeviation : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feDropShadow` injects into its children.
-}
type alias FeDropShadowChildAdmittedBy childAdm =
    { childAdm | feDropShadow : Ctx }


{-| The `feDropShadow` element.
-}
feDropShadow :
    List (Attr FeDropShadowAttrs msg)
    -> List (Element childAccepts (FeDropShadowChildAdmittedBy childAdm) msg)
    -> Element (FeDropShadowIs s) admittedBy msg
feDropShadow attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feDropShadow" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feFlood` produces.
-}
type alias FeFloodIs s =
    { s | feFlood : Brand }


{-| `feFlood`'s closed attribute-capability row.
-}
type alias FeFloodAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feFlood` injects into its children.
-}
type alias FeFloodChildAdmittedBy childAdm =
    { childAdm | feFlood : Ctx }


{-| The `feFlood` element.
-}
feFlood :
    List (Attr FeFloodAttrs msg)
    -> List (Element childAccepts (FeFloodChildAdmittedBy childAdm) msg)
    -> Element (FeFloodIs s) admittedBy msg
feFlood attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feFlood" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feFuncA` produces.
-}
type alias FeFuncAIs s =
    { s | feFuncA : Brand }


{-| `feFuncA`'s closed attribute-capability row.
-}
type alias FeFuncAAttrs =
    { amplitude : Supported
    , class : Supported
    , exponent : Supported
    , id : Supported
    , intercept : Supported
    , offset : Supported
    , slope : Supported
    , style : Supported
    , tableValues : Supported
    , type_ : Supported
    }


{-| The context demand `feFuncA` injects into its children.
-}
type alias FeFuncAChildAdmittedBy childAdm =
    { childAdm | feFuncA : Ctx }


{-| The `feFuncA` element.
-}
feFuncA :
    List (Attr FeFuncAAttrs msg)
    -> List (Element childAccepts (FeFuncAChildAdmittedBy childAdm) msg)
    -> Element (FeFuncAIs s) admittedBy msg
feFuncA attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feFuncA" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feFuncB` produces.
-}
type alias FeFuncBIs s =
    { s | feFuncB : Brand }


{-| `feFuncB`'s closed attribute-capability row.
-}
type alias FeFuncBAttrs =
    { amplitude : Supported
    , class : Supported
    , exponent : Supported
    , id : Supported
    , intercept : Supported
    , offset : Supported
    , slope : Supported
    , style : Supported
    , tableValues : Supported
    , type_ : Supported
    }


{-| The context demand `feFuncB` injects into its children.
-}
type alias FeFuncBChildAdmittedBy childAdm =
    { childAdm | feFuncB : Ctx }


{-| The `feFuncB` element.
-}
feFuncB :
    List (Attr FeFuncBAttrs msg)
    -> List (Element childAccepts (FeFuncBChildAdmittedBy childAdm) msg)
    -> Element (FeFuncBIs s) admittedBy msg
feFuncB attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feFuncB" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feFuncG` produces.
-}
type alias FeFuncGIs s =
    { s | feFuncG : Brand }


{-| `feFuncG`'s closed attribute-capability row.
-}
type alias FeFuncGAttrs =
    { amplitude : Supported
    , class : Supported
    , exponent : Supported
    , id : Supported
    , intercept : Supported
    , offset : Supported
    , slope : Supported
    , style : Supported
    , tableValues : Supported
    , type_ : Supported
    }


{-| The context demand `feFuncG` injects into its children.
-}
type alias FeFuncGChildAdmittedBy childAdm =
    { childAdm | feFuncG : Ctx }


{-| The `feFuncG` element.
-}
feFuncG :
    List (Attr FeFuncGAttrs msg)
    -> List (Element childAccepts (FeFuncGChildAdmittedBy childAdm) msg)
    -> Element (FeFuncGIs s) admittedBy msg
feFuncG attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feFuncG" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feFuncR` produces.
-}
type alias FeFuncRIs s =
    { s | feFuncR : Brand }


{-| `feFuncR`'s closed attribute-capability row.
-}
type alias FeFuncRAttrs =
    { amplitude : Supported
    , class : Supported
    , exponent : Supported
    , id : Supported
    , intercept : Supported
    , offset : Supported
    , slope : Supported
    , style : Supported
    , tableValues : Supported
    , type_ : Supported
    }


{-| The context demand `feFuncR` injects into its children.
-}
type alias FeFuncRChildAdmittedBy childAdm =
    { childAdm | feFuncR : Ctx }


{-| The `feFuncR` element.
-}
feFuncR :
    List (Attr FeFuncRAttrs msg)
    -> List (Element childAccepts (FeFuncRChildAdmittedBy childAdm) msg)
    -> Element (FeFuncRIs s) admittedBy msg
feFuncR attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feFuncR" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feGaussianBlur` produces.
-}
type alias FeGaussianBlurIs s =
    { s | feGaussianBlur : Brand }


{-| `feGaussianBlur`'s closed attribute-capability row.
-}
type alias FeGaussianBlurAttrs =
    { class : Supported
    , edgeMode : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , result : Supported
    , stdDeviation : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feGaussianBlur` injects into its children.
-}
type alias FeGaussianBlurChildAdmittedBy childAdm =
    { childAdm | feGaussianBlur : Ctx }


{-| The `feGaussianBlur` element.
-}
feGaussianBlur :
    List (Attr FeGaussianBlurAttrs msg)
    -> List (Element childAccepts (FeGaussianBlurChildAdmittedBy childAdm) msg)
    -> Element (FeGaussianBlurIs s) admittedBy msg
feGaussianBlur attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feGaussianBlur" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feImage` produces.
-}
type alias FeImageIs s =
    { s | feImage : Brand }


{-| `feImage`'s closed attribute-capability row.
-}
type alias FeImageAttrs =
    { class : Supported
    , height : Supported
    , href : Supported
    , id : Supported
    , preserveAspectRatio : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feImage` injects into its children.
-}
type alias FeImageChildAdmittedBy childAdm =
    { childAdm | feImage : Ctx }


{-| The `feImage` element.
-}
feImage :
    List (Attr FeImageAttrs msg)
    -> List (Element childAccepts (FeImageChildAdmittedBy childAdm) msg)
    -> Element (FeImageIs s) admittedBy msg
feImage attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feImage" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feMerge` produces.
-}
type alias FeMergeIs s =
    { s | feMerge : Brand }


{-| `feMerge`'s closed attribute-capability row.
-}
type alias FeMergeAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `feMerge` admits.
-}
type alias FeMergeContent =
    { feMergeNode : Brand }


{-| The context demand `feMerge` injects into its children.
-}
type alias FeMergeChildAdmittedBy childAdm =
    { childAdm | feMerge : Ctx }


{-| The `feMerge` element.
-}
feMerge :
    List (Attr FeMergeAttrs msg)
    -> List (Element FeMergeContent (FeMergeChildAdmittedBy childAdm) msg)
    -> Element (FeMergeIs s) admittedBy msg
feMerge attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feMerge" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feMergeNode` produces.
-}
type alias FeMergeNodeIs s =
    { s | feMergeNode : Brand }


{-| `feMergeNode`'s closed attribute-capability row.
-}
type alias FeMergeNodeAttrs =
    { class : Supported
    , id : Supported
    , in_ : Supported
    , style : Supported
    }


{-| The context demand `feMergeNode` injects into its children.
-}
type alias FeMergeNodeChildAdmittedBy childAdm =
    { childAdm | feMergeNode : Ctx }


{-| The `feMergeNode` element.
-}
feMergeNode :
    List (Attr FeMergeNodeAttrs msg)
    -> List (Element childAccepts (FeMergeNodeChildAdmittedBy childAdm) msg)
    -> Element (FeMergeNodeIs s) admittedBy msg
feMergeNode attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feMergeNode" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feMorphology` produces.
-}
type alias FeMorphologyIs s =
    { s | feMorphology : Brand }


{-| `feMorphology`'s closed attribute-capability row.
-}
type alias FeMorphologyAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , operator : Supported
    , radius : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feMorphology` injects into its children.
-}
type alias FeMorphologyChildAdmittedBy childAdm =
    { childAdm | feMorphology : Ctx }


{-| The `feMorphology` element.
-}
feMorphology :
    List (Attr FeMorphologyAttrs msg)
    -> List (Element childAccepts (FeMorphologyChildAdmittedBy childAdm) msg)
    -> Element (FeMorphologyIs s) admittedBy msg
feMorphology attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feMorphology" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feOffset` produces.
-}
type alias FeOffsetIs s =
    { s | feOffset : Brand }


{-| `feOffset`'s closed attribute-capability row.
-}
type alias FeOffsetAttrs =
    { class : Supported
    , dx : Supported
    , dy : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feOffset` injects into its children.
-}
type alias FeOffsetChildAdmittedBy childAdm =
    { childAdm | feOffset : Ctx }


{-| The `feOffset` element.
-}
feOffset :
    List (Attr FeOffsetAttrs msg)
    -> List (Element childAccepts (FeOffsetChildAdmittedBy childAdm) msg)
    -> Element (FeOffsetIs s) admittedBy msg
feOffset attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feOffset" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `fePointLight` produces.
-}
type alias FePointLightIs s =
    { s | fePointLight : Brand }


{-| `fePointLight`'s closed attribute-capability row.
-}
type alias FePointLightAttrs =
    { class : Supported
    , id : Supported
    , style : Supported
    , x : Supported
    , y : Supported
    , z : Supported
    }


{-| The context demand `fePointLight` injects into its children.
-}
type alias FePointLightChildAdmittedBy childAdm =
    { childAdm | fePointLight : Ctx }


{-| The `fePointLight` element.
-}
fePointLight :
    List (Attr FePointLightAttrs msg)
    -> List (Element childAccepts (FePointLightChildAdmittedBy childAdm) msg)
    -> Element (FePointLightIs s) admittedBy msg
fePointLight attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "fePointLight" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feSpecularLighting` produces.
-}
type alias FeSpecularLightingIs s =
    { s | feSpecularLighting : Brand }


{-| `feSpecularLighting`'s closed attribute-capability row.
-}
type alias FeSpecularLightingAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , kernelUnitLength : Supported
    , result : Supported
    , specularConstant : Supported
    , specularExponent : Supported
    , style : Supported
    , surfaceScale : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The kinds `feSpecularLighting` admits.
-}
type alias FeSpecularLightingContent =
    { feDistantLight : Brand
    , fePointLight : Brand
    , feSpotLight : Brand
    }


{-| The context demand `feSpecularLighting` injects into its children.
-}
type alias FeSpecularLightingChildAdmittedBy childAdm =
    { childAdm | feSpecularLighting : Ctx }


{-| The `feSpecularLighting` element.
-}
feSpecularLighting :
    List (Attr FeSpecularLightingAttrs msg)
    -> List (Element FeSpecularLightingContent (FeSpecularLightingChildAdmittedBy childAdm) msg)
    -> Element (FeSpecularLightingIs s) admittedBy msg
feSpecularLighting attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feSpecularLighting" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feSpotLight` produces.
-}
type alias FeSpotLightIs s =
    { s | feSpotLight : Brand }


{-| `feSpotLight`'s closed attribute-capability row.
-}
type alias FeSpotLightAttrs =
    { class : Supported
    , id : Supported
    , limitingConeAngle : Supported
    , pointsAtX : Supported
    , pointsAtY : Supported
    , pointsAtZ : Supported
    , specularExponent : Supported
    , style : Supported
    , x : Supported
    , y : Supported
    , z : Supported
    }


{-| The context demand `feSpotLight` injects into its children.
-}
type alias FeSpotLightChildAdmittedBy childAdm =
    { childAdm | feSpotLight : Ctx }


{-| The `feSpotLight` element.
-}
feSpotLight :
    List (Attr FeSpotLightAttrs msg)
    -> List (Element childAccepts (FeSpotLightChildAdmittedBy childAdm) msg)
    -> Element (FeSpotLightIs s) admittedBy msg
feSpotLight attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feSpotLight" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feTile` produces.
-}
type alias FeTileIs s =
    { s | feTile : Brand }


{-| `feTile`'s closed attribute-capability row.
-}
type alias FeTileAttrs =
    { class : Supported
    , height : Supported
    , id : Supported
    , in_ : Supported
    , result : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feTile` injects into its children.
-}
type alias FeTileChildAdmittedBy childAdm =
    { childAdm | feTile : Ctx }


{-| The `feTile` element.
-}
feTile :
    List (Attr FeTileAttrs msg)
    -> List (Element childAccepts (FeTileChildAdmittedBy childAdm) msg)
    -> Element (FeTileIs s) admittedBy msg
feTile attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feTile" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `feTurbulence` produces.
-}
type alias FeTurbulenceIs s =
    { s | feTurbulence : Brand }


{-| `feTurbulence`'s closed attribute-capability row.
-}
type alias FeTurbulenceAttrs =
    { baseFrequency : Supported
    , class : Supported
    , height : Supported
    , id : Supported
    , numOctaves : Supported
    , result : Supported
    , seed : Supported
    , stitchTiles : Supported
    , style : Supported
    , type_ : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `feTurbulence` injects into its children.
-}
type alias FeTurbulenceChildAdmittedBy childAdm =
    { childAdm | feTurbulence : Ctx }


{-| The `feTurbulence` element.
-}
feTurbulence :
    List (Attr FeTurbulenceAttrs msg)
    -> List (Element childAccepts (FeTurbulenceChildAdmittedBy childAdm) msg)
    -> Element (FeTurbulenceIs s) admittedBy msg
feTurbulence attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "feTurbulence" attrs (List.map HtmlIr.Element.toNode children))


{-| The kind row `filter` produces.
-}
type alias FilterIs s =
    { s | filter : Brand }


{-| `filter`'s closed attribute-capability row.
-}
type alias FilterAttrs =
    { class : Supported
    , filterUnits : Supported
    , height : Supported
    , href : Supported
    , id : Supported
    , primitiveUnits : Supported
    , style : Supported
    , width : Supported
    , x : Supported
    , y : Supported
    }


{-| The context demand `filter` injects into its children.
-}
type alias FilterChildAdmittedBy childAdm =
    { childAdm | filter : Ctx }


{-| The `filter` element.
-}
filter :
    List (Attr FilterAttrs msg)
    -> List (Element childAccepts (FilterChildAdmittedBy childAdm) msg)
    -> Element (FilterIs s) admittedBy msg
filter attrs children =
    Ir.fromNode (Ir.nodeNS "http://www.w3.org/2000/svg" "filter" attrs (List.map HtmlIr.Element.toNode children))


{-| See `TypedSvg.Attributes.amplitude`.
-}
amplitude : String -> Attr { c | amplitude : Supported } msg
amplitude =
    TypedSvg.Attributes.amplitude


{-| See `TypedSvg.Attributes.azimuth`.
-}
azimuth : String -> Attr { c | azimuth : Supported } msg
azimuth =
    TypedSvg.Attributes.azimuth


{-| See `TypedSvg.Attributes.baseFrequency`.
-}
baseFrequency : String -> Attr { c | baseFrequency : Supported } msg
baseFrequency =
    TypedSvg.Attributes.baseFrequency


{-| See `TypedSvg.Attributes.bias`.
-}
bias : String -> Attr { c | bias : Supported } msg
bias =
    TypedSvg.Attributes.bias


{-| See `TypedSvg.Attributes.diffuseConstant`.
-}
diffuseConstant : String -> Attr { c | diffuseConstant : Supported } msg
diffuseConstant =
    TypedSvg.Attributes.diffuseConstant


{-| See `TypedSvg.Attributes.divisor`.
-}
divisor : String -> Attr { c | divisor : Supported } msg
divisor =
    TypedSvg.Attributes.divisor


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


{-| How the kernel behaves at the input edges.
-}
edgeMode : String -> Attr { c | edgeMode : Supported } msg
edgeMode value_ =
    Ir.attribute "edgeMode" value_


{-| See `TypedSvg.Attributes.elevation`.
-}
elevation : String -> Attr { c | elevation : Supported } msg
elevation =
    TypedSvg.Attributes.elevation


{-| See `TypedSvg.Attributes.exponent`.
-}
exponent : String -> Attr { c | exponent : Supported } msg
exponent =
    TypedSvg.Attributes.exponent


{-| See `TypedSvg.Attributes.filterUnits`.
-}
filterUnits : String -> Attr { c | filterUnits : Supported } msg
filterUnits =
    TypedSvg.Attributes.filterUnits


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


{-| See `TypedSvg.Attributes.in2`.
-}
in2 : String -> Attr { c | in2 : Supported } msg
in2 =
    TypedSvg.Attributes.in2


{-| See `TypedSvg.Attributes.in_`.
-}
in_ : String -> Attr { c | in_ : Supported } msg
in_ =
    TypedSvg.Attributes.in_


{-| See `TypedSvg.Attributes.intercept`.
-}
intercept : String -> Attr { c | intercept : Supported } msg
intercept =
    TypedSvg.Attributes.intercept


{-| See `TypedSvg.Attributes.k1`.
-}
k1 : String -> Attr { c | k1 : Supported } msg
k1 =
    TypedSvg.Attributes.k1


{-| See `TypedSvg.Attributes.k2`.
-}
k2 : String -> Attr { c | k2 : Supported } msg
k2 =
    TypedSvg.Attributes.k2


{-| See `TypedSvg.Attributes.k3`.
-}
k3 : String -> Attr { c | k3 : Supported } msg
k3 =
    TypedSvg.Attributes.k3


{-| See `TypedSvg.Attributes.k4`.
-}
k4 : String -> Attr { c | k4 : Supported } msg
k4 =
    TypedSvg.Attributes.k4


{-| See `TypedSvg.Attributes.kernelMatrix`.
-}
kernelMatrix : String -> Attr { c | kernelMatrix : Supported } msg
kernelMatrix =
    TypedSvg.Attributes.kernelMatrix


{-| See `TypedSvg.Attributes.kernelUnitLength`.
-}
kernelUnitLength : String -> Attr { c | kernelUnitLength : Supported } msg
kernelUnitLength =
    TypedSvg.Attributes.kernelUnitLength


{-| See `TypedSvg.Attributes.limitingConeAngle`.
-}
limitingConeAngle : String -> Attr { c | limitingConeAngle : Supported } msg
limitingConeAngle =
    TypedSvg.Attributes.limitingConeAngle


{-| The blend mode.
-}
mode : String -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" value_


{-| See `TypedSvg.Attributes.numOctaves`.
-}
numOctaves : String -> Attr { c | numOctaves : Supported } msg
numOctaves =
    TypedSvg.Attributes.numOctaves


{-| See `TypedSvg.Attributes.offset`.
-}
offset : String -> Attr { c | offset : Supported } msg
offset =
    TypedSvg.Attributes.offset


{-| The compositing operator.
-}
operator : String -> Attr { c | operator : Supported } msg
operator value_ =
    Ir.attribute "operator" value_


{-| See `TypedSvg.Attributes.order`.
-}
order : String -> Attr { c | order : Supported } msg
order =
    TypedSvg.Attributes.order


{-| See `TypedSvg.Attributes.pointsAtX`.
-}
pointsAtX : String -> Attr { c | pointsAtX : Supported } msg
pointsAtX =
    TypedSvg.Attributes.pointsAtX


{-| See `TypedSvg.Attributes.pointsAtY`.
-}
pointsAtY : String -> Attr { c | pointsAtY : Supported } msg
pointsAtY =
    TypedSvg.Attributes.pointsAtY


{-| See `TypedSvg.Attributes.pointsAtZ`.
-}
pointsAtZ : String -> Attr { c | pointsAtZ : Supported } msg
pointsAtZ =
    TypedSvg.Attributes.pointsAtZ


{-| See `TypedSvg.Attributes.preserveAlpha`.
-}
preserveAlpha : String -> Attr { c | preserveAlpha : Supported } msg
preserveAlpha =
    TypedSvg.Attributes.preserveAlpha


{-| See `TypedSvg.Attributes.preserveAspectRatio`.
-}
preserveAspectRatio : String -> Attr { c | preserveAspectRatio : Supported } msg
preserveAspectRatio =
    TypedSvg.Attributes.preserveAspectRatio


{-| See `TypedSvg.Attributes.primitiveUnits`.
-}
primitiveUnits : String -> Attr { c | primitiveUnits : Supported } msg
primitiveUnits =
    TypedSvg.Attributes.primitiveUnits


{-| See `TypedSvg.Attributes.radius`.
-}
radius : String -> Attr { c | radius : Supported } msg
radius =
    TypedSvg.Attributes.radius


{-| See `TypedSvg.Attributes.result`.
-}
result : String -> Attr { c | result : Supported } msg
result =
    TypedSvg.Attributes.result


{-| See `TypedSvg.Attributes.scale`.
-}
scale : String -> Attr { c | scale : Supported } msg
scale =
    TypedSvg.Attributes.scale


{-| See `TypedSvg.Attributes.seed`.
-}
seed : String -> Attr { c | seed : Supported } msg
seed =
    TypedSvg.Attributes.seed


{-| See `TypedSvg.Attributes.slope`.
-}
slope : String -> Attr { c | slope : Supported } msg
slope =
    TypedSvg.Attributes.slope


{-| See `TypedSvg.Attributes.specularConstant`.
-}
specularConstant : String -> Attr { c | specularConstant : Supported } msg
specularConstant =
    TypedSvg.Attributes.specularConstant


{-| See `TypedSvg.Attributes.specularExponent`.
-}
specularExponent : String -> Attr { c | specularExponent : Supported } msg
specularExponent =
    TypedSvg.Attributes.specularExponent


{-| See `TypedSvg.Attributes.stdDeviation`.
-}
stdDeviation : String -> Attr { c | stdDeviation : Supported } msg
stdDeviation =
    TypedSvg.Attributes.stdDeviation


{-| Whether tile edges are stitched to avoid seams.
-}
stitchTiles : String -> Attr { c | stitchTiles : Supported } msg
stitchTiles value_ =
    Ir.attribute "stitchTiles" value_


{-| See `TypedSvg.Attributes.surfaceScale`.
-}
surfaceScale : String -> Attr { c | surfaceScale : Supported } msg
surfaceScale =
    TypedSvg.Attributes.surfaceScale


{-| See `TypedSvg.Attributes.tableValues`.
-}
tableValues : String -> Attr { c | tableValues : Supported } msg
tableValues =
    TypedSvg.Attributes.tableValues


{-| See `TypedSvg.Attributes.targetX`.
-}
targetX : String -> Attr { c | targetX : Supported } msg
targetX =
    TypedSvg.Attributes.targetX


{-| See `TypedSvg.Attributes.targetY`.
-}
targetY : String -> Attr { c | targetY : Supported } msg
targetY =
    TypedSvg.Attributes.targetY


{-| The kind of matrix operation.
-}
type_ : String -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" value_


{-| See `TypedSvg.Attributes.values`.
-}
values : String -> Attr { c | values : Supported } msg
values =
    TypedSvg.Attributes.values


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


{-| Which channel of in2 drives X displacement.
-}
xChannelSelector : String -> Attr { c | xChannelSelector : Supported } msg
xChannelSelector value_ =
    Ir.attribute "xChannelSelector" value_


{-| See `TypedSvg.Attributes.y`.
-}
y : String -> Attr { c | y : Supported } msg
y =
    TypedSvg.Attributes.y


{-| Which channel of in2 drives Y displacement.
-}
yChannelSelector : String -> Attr { c | yChannelSelector : Supported } msg
yChannelSelector value_ =
    Ir.attribute "yChannelSelector" value_


{-| See `TypedSvg.Attributes.z`.
-}
z : String -> Attr { c | z : Supported } msg
z =
    TypedSvg.Attributes.z
