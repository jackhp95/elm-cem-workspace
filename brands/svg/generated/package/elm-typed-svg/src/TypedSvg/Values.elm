module TypedSvg.Values exposing
    ( Value
    , toString
    , AlignmentBaseline, ClipRule, ColorInterpolation, ColorRendering, Direction, Display, DominantBaseline, FillRule, FontVariant, ImageRendering, Overflow, PointerEvents, ShapeRendering, StrokeLinecap, StrokeLinejoin, TextAnchor, TextRendering, VectorEffect, Visibility, WhiteSpace, WritingMode, XmlSpace
    , alignmentBaselineFromString, alignmentBaselineValues, clipRuleFromString, clipRuleValues, colorInterpolationFromString, colorInterpolationValues, colorRenderingFromString, colorRenderingValues, directionFromString, directionValues, displayFromString, displayValues, dominantBaselineFromString, dominantBaselineValues, fillRuleFromString, fillRuleValues, fontVariantFromString, fontVariantValues, imageRenderingFromString, imageRenderingValues, overflowFromString, overflowValues, pointerEventsFromString, pointerEventsValues, shapeRenderingFromString, shapeRenderingValues, strokeLinecapFromString, strokeLinecapValues, strokeLinejoinFromString, strokeLinejoinValues, textAnchorFromString, textAnchorValues, textRenderingFromString, textRenderingValues, vectorEffectFromString, vectorEffectValues, visibilityFromString, visibilityValues, whiteSpaceFromString, whiteSpaceValues, writingModeFromString, writingModeValues, xmlSpaceFromString, xmlSpaceValues
    , afterEdge, all, alphabetic, auto, baseline, beforeEdge, bevel, block, boundingBox, butt, central, collapse, compact, crispedges, default, end, evenodd, fill, geometricprecision, hanging, hidden, ideographic, inline, inlineTable, linearrgb, listItem, lr, lrTb, ltr, marker, mathematical, middle, miter, noChange, nonScalingStroke, none, nonzero, normal, nowrap, optimizelegibility, optimizequality, optimizespeed, painted, pre, preLine, preWrap, preserve, resetSize, rl, rlTb, round, rtl, runIn, srgb, scroll, smallCaps, square, start, stroke, table, tableCaption, tableCell, tableColumn, tableColumnGroup, tableFooterGroup, tableHeaderGroup, tableRow, tableRowGroup, tb, tbRl, textAfterEdge, textBeforeEdge, useScript, visible, visiblefill, visiblepainted, visiblestroke
    , alignmentBaselineAfterEdge, alignmentBaselineAlphabetic, alignmentBaselineAuto, alignmentBaselineBaseline, alignmentBaselineBeforeEdge, alignmentBaselineCentral, alignmentBaselineHanging, alignmentBaselineIdeographic, alignmentBaselineMathematical, alignmentBaselineMiddle, alignmentBaselineTextAfterEdge, alignmentBaselineTextBeforeEdge, clipRuleEvenodd, clipRuleNonzero, colorInterpolationAuto, colorInterpolationLinearrgb, colorInterpolationSrgb, colorRenderingAuto, colorRenderingOptimizequality, colorRenderingOptimizespeed, directionLtr, directionRtl, displayBlock, displayCompact, displayInline, displayInlineTable, displayListItem, displayMarker, displayNone, displayRunIn, displayTable, displayTableCaption, displayTableCell, displayTableColumn, displayTableColumnGroup, displayTableFooterGroup, displayTableHeaderGroup, displayTableRow, displayTableRowGroup, dominantBaselineAlphabetic, dominantBaselineAuto, dominantBaselineCentral, dominantBaselineHanging, dominantBaselineIdeographic, dominantBaselineMathematical, dominantBaselineMiddle, dominantBaselineNoChange, dominantBaselineResetSize, dominantBaselineTextAfterEdge, dominantBaselineTextBeforeEdge, dominantBaselineUseScript, fillRuleEvenodd, fillRuleNonzero, fontVariantNormal, fontVariantSmallCaps, imageRenderingAuto, imageRenderingOptimizequality, imageRenderingOptimizespeed, overflowAuto, overflowHidden, overflowScroll, overflowVisible, pointerEventsAll, pointerEventsBoundingBox, pointerEventsFill, pointerEventsNone, pointerEventsPainted, pointerEventsStroke, pointerEventsVisible, pointerEventsVisiblefill, pointerEventsVisiblepainted, pointerEventsVisiblestroke, shapeRenderingAuto, shapeRenderingCrispedges, shapeRenderingGeometricprecision, shapeRenderingOptimizespeed, strokeLinecapButt, strokeLinecapRound, strokeLinecapSquare, strokeLinejoinBevel, strokeLinejoinMiter, strokeLinejoinRound, textAnchorEnd, textAnchorMiddle, textAnchorStart, textRenderingAuto, textRenderingGeometricprecision, textRenderingOptimizelegibility, textRenderingOptimizespeed, vectorEffectNonScalingStroke, vectorEffectNone, visibilityCollapse, visibilityHidden, visibilityVisible, whiteSpaceNormal, whiteSpaceNowrap, whiteSpacePre, whiteSpacePreLine, whiteSpacePreWrap, writingModeLr, writingModeLrTb, writingModeRl, writingModeRlTb, writingModeTb, writingModeTbRl, xmlSpaceDefault, xmlSpacePreserve
    )

{-| The enum-value vocabulary: every token minted once (open row), plus the
library-wide union row per enum attribute, plus attribute-prefixed
portmanteaus (`variantFilled`, `shapeRounded`, …) for IDE discovery.
General setters close over the union; per-component setters narrow — both
are fed by these same tokens.

`Value` is re-exported here so annotating a token never requires an
`HtmlIr.Value` import.

@docs Value
@docs toString
@docs AlignmentBaseline, ClipRule, ColorInterpolation, ColorRendering, Direction, Display, DominantBaseline, FillRule, FontVariant, ImageRendering, Overflow, PointerEvents, ShapeRendering, StrokeLinecap, StrokeLinejoin, TextAnchor, TextRendering, VectorEffect, Visibility, WhiteSpace, WritingMode, XmlSpace
@docs alignmentBaselineFromString, alignmentBaselineValues, clipRuleFromString, clipRuleValues, colorInterpolationFromString, colorInterpolationValues, colorRenderingFromString, colorRenderingValues, directionFromString, directionValues, displayFromString, displayValues, dominantBaselineFromString, dominantBaselineValues, fillRuleFromString, fillRuleValues, fontVariantFromString, fontVariantValues, imageRenderingFromString, imageRenderingValues, overflowFromString, overflowValues, pointerEventsFromString, pointerEventsValues, shapeRenderingFromString, shapeRenderingValues, strokeLinecapFromString, strokeLinecapValues, strokeLinejoinFromString, strokeLinejoinValues, textAnchorFromString, textAnchorValues, textRenderingFromString, textRenderingValues, vectorEffectFromString, vectorEffectValues, visibilityFromString, visibilityValues, whiteSpaceFromString, whiteSpaceValues, writingModeFromString, writingModeValues, xmlSpaceFromString, xmlSpaceValues
@docs afterEdge, all, alphabetic, auto, baseline, beforeEdge, bevel, block, boundingBox, butt, central, collapse, compact, crispedges, default, end, evenodd, fill, geometricprecision, hanging, hidden, ideographic, inline, inlineTable, linearrgb, listItem, lr, lrTb, ltr, marker, mathematical, middle, miter, noChange, nonScalingStroke, none, nonzero, normal, nowrap, optimizelegibility, optimizequality, optimizespeed, painted, pre, preLine, preWrap, preserve, resetSize, rl, rlTb, round, rtl, runIn, srgb, scroll, smallCaps, square, start, stroke, table, tableCaption, tableCell, tableColumn, tableColumnGroup, tableFooterGroup, tableHeaderGroup, tableRow, tableRowGroup, tb, tbRl, textAfterEdge, textBeforeEdge, useScript, visible, visiblefill, visiblepainted, visiblestroke
@docs alignmentBaselineAfterEdge, alignmentBaselineAlphabetic, alignmentBaselineAuto, alignmentBaselineBaseline, alignmentBaselineBeforeEdge, alignmentBaselineCentral, alignmentBaselineHanging, alignmentBaselineIdeographic, alignmentBaselineMathematical, alignmentBaselineMiddle, alignmentBaselineTextAfterEdge, alignmentBaselineTextBeforeEdge, clipRuleEvenodd, clipRuleNonzero, colorInterpolationAuto, colorInterpolationLinearrgb, colorInterpolationSrgb, colorRenderingAuto, colorRenderingOptimizequality, colorRenderingOptimizespeed, directionLtr, directionRtl, displayBlock, displayCompact, displayInline, displayInlineTable, displayListItem, displayMarker, displayNone, displayRunIn, displayTable, displayTableCaption, displayTableCell, displayTableColumn, displayTableColumnGroup, displayTableFooterGroup, displayTableHeaderGroup, displayTableRow, displayTableRowGroup, dominantBaselineAlphabetic, dominantBaselineAuto, dominantBaselineCentral, dominantBaselineHanging, dominantBaselineIdeographic, dominantBaselineMathematical, dominantBaselineMiddle, dominantBaselineNoChange, dominantBaselineResetSize, dominantBaselineTextAfterEdge, dominantBaselineTextBeforeEdge, dominantBaselineUseScript, fillRuleEvenodd, fillRuleNonzero, fontVariantNormal, fontVariantSmallCaps, imageRenderingAuto, imageRenderingOptimizequality, imageRenderingOptimizespeed, overflowAuto, overflowHidden, overflowScroll, overflowVisible, pointerEventsAll, pointerEventsBoundingBox, pointerEventsFill, pointerEventsNone, pointerEventsPainted, pointerEventsStroke, pointerEventsVisible, pointerEventsVisiblefill, pointerEventsVisiblepainted, pointerEventsVisiblestroke, shapeRenderingAuto, shapeRenderingCrispedges, shapeRenderingGeometricprecision, shapeRenderingOptimizespeed, strokeLinecapButt, strokeLinecapRound, strokeLinecapSquare, strokeLinejoinBevel, strokeLinejoinMiter, strokeLinejoinRound, textAnchorEnd, textAnchorMiddle, textAnchorStart, textRenderingAuto, textRenderingGeometricprecision, textRenderingOptimizelegibility, textRenderingOptimizespeed, vectorEffectNonScalingStroke, vectorEffectNone, visibilityCollapse, visibilityHidden, visibilityVisible, whiteSpaceNormal, whiteSpaceNowrap, whiteSpacePre, whiteSpacePreLine, whiteSpacePreWrap, writingModeLr, writingModeLrTb, writingModeRl, writingModeRlTb, writingModeTb, writingModeTbRl, xmlSpaceDefault, xmlSpacePreserve

-}

import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value


{-| The phantom-tagged enum token. Re-exported so callers never import `HtmlIr.Value` directly.
-}
type alias Value tags =
    HtmlIr.Value.Value tags


{-| The token's underlying string — the safe out-bound direction. Re-exported so callers never import `HtmlIr.Value` directly.
-}
toString : Value tags -> String
toString =
    HtmlIr.Value.toString


{-| The union row for `alignmentBaseline`.
-}
type alias AlignmentBaseline =
    { afterEdge : Supported
    , alphabetic : Supported
    , auto : Supported
    , baseline : Supported
    , beforeEdge : Supported
    , central : Supported
    , hanging : Supported
    , ideographic : Supported
    , mathematical : Supported
    , middle : Supported
    , textAfterEdge : Supported
    , textBeforeEdge : Supported
    }


{-| The union row for `clipRule`.
-}
type alias ClipRule =
    { evenodd : Supported
    , nonzero : Supported
    }


{-| The union row for `colorInterpolation`.
-}
type alias ColorInterpolation =
    { auto : Supported
    , linearrgb : Supported
    , srgb : Supported
    }


{-| The union row for `colorRendering`.
-}
type alias ColorRendering =
    { auto : Supported
    , optimizequality : Supported
    , optimizespeed : Supported
    }


{-| The union row for `direction`.
-}
type alias Direction =
    { ltr : Supported
    , rtl : Supported
    }


{-| The union row for `display`.
-}
type alias Display =
    { block : Supported
    , compact : Supported
    , inline : Supported
    , inlineTable : Supported
    , listItem : Supported
    , marker : Supported
    , none : Supported
    , runIn : Supported
    , table : Supported
    , tableCaption : Supported
    , tableCell : Supported
    , tableColumn : Supported
    , tableColumnGroup : Supported
    , tableFooterGroup : Supported
    , tableHeaderGroup : Supported
    , tableRow : Supported
    , tableRowGroup : Supported
    }


{-| The union row for `dominantBaseline`.
-}
type alias DominantBaseline =
    { alphabetic : Supported
    , auto : Supported
    , central : Supported
    , hanging : Supported
    , ideographic : Supported
    , mathematical : Supported
    , middle : Supported
    , noChange : Supported
    , resetSize : Supported
    , textAfterEdge : Supported
    , textBeforeEdge : Supported
    , useScript : Supported
    }


{-| The union row for `fillRule`.
-}
type alias FillRule =
    { evenodd : Supported
    , nonzero : Supported
    }


{-| The union row for `fontVariant`.
-}
type alias FontVariant =
    { normal : Supported
    , smallCaps : Supported
    }


{-| The union row for `imageRendering`.
-}
type alias ImageRendering =
    { auto : Supported
    , optimizequality : Supported
    , optimizespeed : Supported
    }


{-| The union row for `overflow`.
-}
type alias Overflow =
    { auto : Supported
    , hidden : Supported
    , scroll : Supported
    , visible : Supported
    }


{-| The union row for `pointerEvents`.
-}
type alias PointerEvents =
    { all : Supported
    , boundingBox : Supported
    , fill : Supported
    , none : Supported
    , painted : Supported
    , stroke : Supported
    , visible : Supported
    , visiblefill : Supported
    , visiblepainted : Supported
    , visiblestroke : Supported
    }


{-| The union row for `shapeRendering`.
-}
type alias ShapeRendering =
    { auto : Supported
    , crispedges : Supported
    , geometricprecision : Supported
    , optimizespeed : Supported
    }


{-| The union row for `strokeLinecap`.
-}
type alias StrokeLinecap =
    { butt : Supported
    , round : Supported
    , square : Supported
    }


{-| The union row for `strokeLinejoin`.
-}
type alias StrokeLinejoin =
    { bevel : Supported
    , miter : Supported
    , round : Supported
    }


{-| The union row for `textAnchor`.
-}
type alias TextAnchor =
    { end : Supported
    , middle : Supported
    , start : Supported
    }


{-| The union row for `textRendering`.
-}
type alias TextRendering =
    { auto : Supported
    , geometricprecision : Supported
    , optimizelegibility : Supported
    , optimizespeed : Supported
    }


{-| The union row for `vectorEffect`.
-}
type alias VectorEffect =
    { nonScalingStroke : Supported
    , none : Supported
    }


{-| The union row for `visibility`.
-}
type alias Visibility =
    { collapse : Supported
    , hidden : Supported
    , visible : Supported
    }


{-| The union row for `whiteSpace`.
-}
type alias WhiteSpace =
    { normal : Supported
    , nowrap : Supported
    , pre : Supported
    , preLine : Supported
    , preWrap : Supported
    }


{-| The union row for `writingMode`.
-}
type alias WritingMode =
    { lr : Supported
    , lrTb : Supported
    , rl : Supported
    , rlTb : Supported
    , tb : Supported
    , tbRl : Supported
    }


{-| The union row for `xmlSpace`.
-}
type alias XmlSpace =
    { default : Supported
    , preserve : Supported
    }


{-| Parse a `alignmentBaseline` value from the string it writes to the DOM. The inverse of `toString`.
-}
alignmentBaselineFromString : String -> Maybe (Value AlignmentBaseline)
alignmentBaselineFromString s =
    case s of
        "after-edge" ->
            Just afterEdge

        "alphabetic" ->
            Just alphabetic

        "auto" ->
            Just auto

        "baseline" ->
            Just baseline

        "before-edge" ->
            Just beforeEdge

        "central" ->
            Just central

        "hanging" ->
            Just hanging

        "ideographic" ->
            Just ideographic

        "mathematical" ->
            Just mathematical

        "middle" ->
            Just middle

        "text-after-edge" ->
            Just textAfterEdge

        "text-before-edge" ->
            Just textBeforeEdge

        _ ->
            Nothing


{-| Parse a `clipRule` value from the string it writes to the DOM. The inverse of `toString`.
-}
clipRuleFromString : String -> Maybe (Value ClipRule)
clipRuleFromString s =
    case s of
        "evenodd" ->
            Just evenodd

        "nonzero" ->
            Just nonzero

        _ ->
            Nothing


{-| Parse a `colorInterpolation` value from the string it writes to the DOM. The inverse of `toString`.
-}
colorInterpolationFromString : String -> Maybe (Value ColorInterpolation)
colorInterpolationFromString s =
    case s of
        "auto" ->
            Just auto

        "linearRGB" ->
            Just linearrgb

        "sRGB" ->
            Just srgb

        _ ->
            Nothing


{-| Parse a `colorRendering` value from the string it writes to the DOM. The inverse of `toString`.
-}
colorRenderingFromString : String -> Maybe (Value ColorRendering)
colorRenderingFromString s =
    case s of
        "auto" ->
            Just auto

        "optimizeQuality" ->
            Just optimizequality

        "optimizeSpeed" ->
            Just optimizespeed

        _ ->
            Nothing


{-| Parse a `direction` value from the string it writes to the DOM. The inverse of `toString`.
-}
directionFromString : String -> Maybe (Value Direction)
directionFromString s =
    case s of
        "ltr" ->
            Just ltr

        "rtl" ->
            Just rtl

        _ ->
            Nothing


{-| Parse a `display` value from the string it writes to the DOM. The inverse of `toString`.
-}
displayFromString : String -> Maybe (Value Display)
displayFromString s =
    case s of
        "block" ->
            Just block

        "compact" ->
            Just compact

        "inline" ->
            Just inline

        "inline-table" ->
            Just inlineTable

        "list-item" ->
            Just listItem

        "marker" ->
            Just marker

        "none" ->
            Just none

        "run-in" ->
            Just runIn

        "table" ->
            Just table

        "table-caption" ->
            Just tableCaption

        "table-cell" ->
            Just tableCell

        "table-column" ->
            Just tableColumn

        "table-column-group" ->
            Just tableColumnGroup

        "table-footer-group" ->
            Just tableFooterGroup

        "table-header-group" ->
            Just tableHeaderGroup

        "table-row" ->
            Just tableRow

        "table-row-group" ->
            Just tableRowGroup

        _ ->
            Nothing


{-| Parse a `dominantBaseline` value from the string it writes to the DOM. The inverse of `toString`.
-}
dominantBaselineFromString : String -> Maybe (Value DominantBaseline)
dominantBaselineFromString s =
    case s of
        "alphabetic" ->
            Just alphabetic

        "auto" ->
            Just auto

        "central" ->
            Just central

        "hanging" ->
            Just hanging

        "ideographic" ->
            Just ideographic

        "mathematical" ->
            Just mathematical

        "middle" ->
            Just middle

        "no-change" ->
            Just noChange

        "reset-size" ->
            Just resetSize

        "text-after-edge" ->
            Just textAfterEdge

        "text-before-edge" ->
            Just textBeforeEdge

        "use-script" ->
            Just useScript

        _ ->
            Nothing


{-| Parse a `fillRule` value from the string it writes to the DOM. The inverse of `toString`.
-}
fillRuleFromString : String -> Maybe (Value FillRule)
fillRuleFromString s =
    case s of
        "evenodd" ->
            Just evenodd

        "nonzero" ->
            Just nonzero

        _ ->
            Nothing


{-| Parse a `fontVariant` value from the string it writes to the DOM. The inverse of `toString`.
-}
fontVariantFromString : String -> Maybe (Value FontVariant)
fontVariantFromString s =
    case s of
        "normal" ->
            Just normal

        "small-caps" ->
            Just smallCaps

        _ ->
            Nothing


{-| Parse a `imageRendering` value from the string it writes to the DOM. The inverse of `toString`.
-}
imageRenderingFromString : String -> Maybe (Value ImageRendering)
imageRenderingFromString s =
    case s of
        "auto" ->
            Just auto

        "optimizeQuality" ->
            Just optimizequality

        "optimizeSpeed" ->
            Just optimizespeed

        _ ->
            Nothing


{-| Parse a `overflow` value from the string it writes to the DOM. The inverse of `toString`.
-}
overflowFromString : String -> Maybe (Value Overflow)
overflowFromString s =
    case s of
        "auto" ->
            Just auto

        "hidden" ->
            Just hidden

        "scroll" ->
            Just scroll

        "visible" ->
            Just visible

        _ ->
            Nothing


{-| Parse a `pointerEvents` value from the string it writes to the DOM. The inverse of `toString`.
-}
pointerEventsFromString : String -> Maybe (Value PointerEvents)
pointerEventsFromString s =
    case s of
        "all" ->
            Just all

        "bounding-box" ->
            Just boundingBox

        "fill" ->
            Just fill

        "none" ->
            Just none

        "painted" ->
            Just painted

        "stroke" ->
            Just stroke

        "visible" ->
            Just visible

        "visibleFill" ->
            Just visiblefill

        "visiblePainted" ->
            Just visiblepainted

        "visibleStroke" ->
            Just visiblestroke

        _ ->
            Nothing


{-| Parse a `shapeRendering` value from the string it writes to the DOM. The inverse of `toString`.
-}
shapeRenderingFromString : String -> Maybe (Value ShapeRendering)
shapeRenderingFromString s =
    case s of
        "auto" ->
            Just auto

        "crispEdges" ->
            Just crispedges

        "geometricPrecision" ->
            Just geometricprecision

        "optimizeSpeed" ->
            Just optimizespeed

        _ ->
            Nothing


{-| Parse a `strokeLinecap` value from the string it writes to the DOM. The inverse of `toString`.
-}
strokeLinecapFromString : String -> Maybe (Value StrokeLinecap)
strokeLinecapFromString s =
    case s of
        "butt" ->
            Just butt

        "round" ->
            Just round

        "square" ->
            Just square

        _ ->
            Nothing


{-| Parse a `strokeLinejoin` value from the string it writes to the DOM. The inverse of `toString`.
-}
strokeLinejoinFromString : String -> Maybe (Value StrokeLinejoin)
strokeLinejoinFromString s =
    case s of
        "bevel" ->
            Just bevel

        "miter" ->
            Just miter

        "round" ->
            Just round

        _ ->
            Nothing


{-| Parse a `textAnchor` value from the string it writes to the DOM. The inverse of `toString`.
-}
textAnchorFromString : String -> Maybe (Value TextAnchor)
textAnchorFromString s =
    case s of
        "end" ->
            Just end

        "middle" ->
            Just middle

        "start" ->
            Just start

        _ ->
            Nothing


{-| Parse a `textRendering` value from the string it writes to the DOM. The inverse of `toString`.
-}
textRenderingFromString : String -> Maybe (Value TextRendering)
textRenderingFromString s =
    case s of
        "auto" ->
            Just auto

        "geometricPrecision" ->
            Just geometricprecision

        "optimizeLegibility" ->
            Just optimizelegibility

        "optimizeSpeed" ->
            Just optimizespeed

        _ ->
            Nothing


{-| Parse a `vectorEffect` value from the string it writes to the DOM. The inverse of `toString`.
-}
vectorEffectFromString : String -> Maybe (Value VectorEffect)
vectorEffectFromString s =
    case s of
        "non-scaling-stroke" ->
            Just nonScalingStroke

        "none" ->
            Just none

        _ ->
            Nothing


{-| Parse a `visibility` value from the string it writes to the DOM. The inverse of `toString`.
-}
visibilityFromString : String -> Maybe (Value Visibility)
visibilityFromString s =
    case s of
        "collapse" ->
            Just collapse

        "hidden" ->
            Just hidden

        "visible" ->
            Just visible

        _ ->
            Nothing


{-| Parse a `whiteSpace` value from the string it writes to the DOM. The inverse of `toString`.
-}
whiteSpaceFromString : String -> Maybe (Value WhiteSpace)
whiteSpaceFromString s =
    case s of
        "normal" ->
            Just normal

        "nowrap" ->
            Just nowrap

        "pre" ->
            Just pre

        "pre-line" ->
            Just preLine

        "pre-wrap" ->
            Just preWrap

        _ ->
            Nothing


{-| Parse a `writingMode` value from the string it writes to the DOM. The inverse of `toString`.
-}
writingModeFromString : String -> Maybe (Value WritingMode)
writingModeFromString s =
    case s of
        "lr" ->
            Just lr

        "lr-tb" ->
            Just lrTb

        "rl" ->
            Just rl

        "rl-tb" ->
            Just rlTb

        "tb" ->
            Just tb

        "tb-rl" ->
            Just tbRl

        _ ->
            Nothing


{-| Parse a `xmlSpace` value from the string it writes to the DOM. The inverse of `toString`.
-}
xmlSpaceFromString : String -> Maybe (Value XmlSpace)
xmlSpaceFromString s =
    case s of
        "default" ->
            Just default

        "preserve" ->
            Just preserve

        _ ->
            Nothing


{-| Every `alignmentBaseline` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
alignmentBaselineValues : List (Value AlignmentBaseline)
alignmentBaselineValues =
    [ afterEdge, alphabetic, auto, baseline, beforeEdge, central, hanging, ideographic, mathematical, middle, textAfterEdge, textBeforeEdge ]


{-| Every `clipRule` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
clipRuleValues : List (Value ClipRule)
clipRuleValues =
    [ evenodd, nonzero ]


{-| Every `colorInterpolation` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
colorInterpolationValues : List (Value ColorInterpolation)
colorInterpolationValues =
    [ auto, linearrgb, srgb ]


{-| Every `colorRendering` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
colorRenderingValues : List (Value ColorRendering)
colorRenderingValues =
    [ auto, optimizequality, optimizespeed ]


{-| Every `direction` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
directionValues : List (Value Direction)
directionValues =
    [ ltr, rtl ]


{-| Every `display` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
displayValues : List (Value Display)
displayValues =
    [ block, compact, inline, inlineTable, listItem, marker, none, runIn, table, tableCaption, tableCell, tableColumn, tableColumnGroup, tableFooterGroup, tableHeaderGroup, tableRow, tableRowGroup ]


{-| Every `dominantBaseline` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
dominantBaselineValues : List (Value DominantBaseline)
dominantBaselineValues =
    [ alphabetic, auto, central, hanging, ideographic, mathematical, middle, noChange, resetSize, textAfterEdge, textBeforeEdge, useScript ]


{-| Every `fillRule` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
fillRuleValues : List (Value FillRule)
fillRuleValues =
    [ evenodd, nonzero ]


{-| Every `fontVariant` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
fontVariantValues : List (Value FontVariant)
fontVariantValues =
    [ normal, smallCaps ]


{-| Every `imageRendering` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
imageRenderingValues : List (Value ImageRendering)
imageRenderingValues =
    [ auto, optimizequality, optimizespeed ]


{-| Every `overflow` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
overflowValues : List (Value Overflow)
overflowValues =
    [ auto, hidden, scroll, visible ]


{-| Every `pointerEvents` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
pointerEventsValues : List (Value PointerEvents)
pointerEventsValues =
    [ all, boundingBox, fill, none, painted, stroke, visible, visiblefill, visiblepainted, visiblestroke ]


{-| Every `shapeRendering` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
shapeRenderingValues : List (Value ShapeRendering)
shapeRenderingValues =
    [ auto, crispedges, geometricprecision, optimizespeed ]


{-| Every `strokeLinecap` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
strokeLinecapValues : List (Value StrokeLinecap)
strokeLinecapValues =
    [ butt, round, square ]


{-| Every `strokeLinejoin` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
strokeLinejoinValues : List (Value StrokeLinejoin)
strokeLinejoinValues =
    [ bevel, miter, round ]


{-| Every `textAnchor` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
textAnchorValues : List (Value TextAnchor)
textAnchorValues =
    [ end, middle, start ]


{-| Every `textRendering` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
textRenderingValues : List (Value TextRendering)
textRenderingValues =
    [ auto, geometricprecision, optimizelegibility, optimizespeed ]


{-| Every `vectorEffect` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
vectorEffectValues : List (Value VectorEffect)
vectorEffectValues =
    [ nonScalingStroke, none ]


{-| Every `visibility` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
visibilityValues : List (Value Visibility)
visibilityValues =
    [ collapse, hidden, visible ]


{-| Every `whiteSpace` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
whiteSpaceValues : List (Value WhiteSpace)
whiteSpaceValues =
    [ normal, nowrap, pre, preLine, preWrap ]


{-| Every `writingMode` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
writingModeValues : List (Value WritingMode)
writingModeValues =
    [ lr, lrTb, rl, rlTb, tb, tbRl ]


{-| Every `xmlSpace` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
xmlSpaceValues : List (Value XmlSpace)
xmlSpaceValues =
    [ default, preserve ]


{-| The `after-edge` token.
-}
afterEdge : Value { v | afterEdge : Supported }
afterEdge =
    Ir.token "after-edge"


{-| The `all` token.
-}
all : Value { v | all : Supported }
all =
    Ir.token "all"


{-| The `alphabetic` token.
-}
alphabetic : Value { v | alphabetic : Supported }
alphabetic =
    Ir.token "alphabetic"


{-| The `auto` token.
-}
auto : Value { v | auto : Supported }
auto =
    Ir.token "auto"


{-| The `baseline` token.
-}
baseline : Value { v | baseline : Supported }
baseline =
    Ir.token "baseline"


{-| The `before-edge` token.
-}
beforeEdge : Value { v | beforeEdge : Supported }
beforeEdge =
    Ir.token "before-edge"


{-| The `bevel` token.
-}
bevel : Value { v | bevel : Supported }
bevel =
    Ir.token "bevel"


{-| The `block` token.
-}
block : Value { v | block : Supported }
block =
    Ir.token "block"


{-| The `bounding-box` token.
-}
boundingBox : Value { v | boundingBox : Supported }
boundingBox =
    Ir.token "bounding-box"


{-| The `butt` token.
-}
butt : Value { v | butt : Supported }
butt =
    Ir.token "butt"


{-| The `central` token.
-}
central : Value { v | central : Supported }
central =
    Ir.token "central"


{-| The `collapse` token.
-}
collapse : Value { v | collapse : Supported }
collapse =
    Ir.token "collapse"


{-| The `compact` token.
-}
compact : Value { v | compact : Supported }
compact =
    Ir.token "compact"


{-| The `crispEdges` token.
-}
crispedges : Value { v | crispedges : Supported }
crispedges =
    Ir.token "crispEdges"


{-| The `default` token.
-}
default : Value { v | default : Supported }
default =
    Ir.token "default"


{-| The `end` token.
-}
end : Value { v | end : Supported }
end =
    Ir.token "end"


{-| The `evenodd` token.
-}
evenodd : Value { v | evenodd : Supported }
evenodd =
    Ir.token "evenodd"


{-| The `fill` token.
-}
fill : Value { v | fill : Supported }
fill =
    Ir.token "fill"


{-| The `geometricPrecision` token.
-}
geometricprecision : Value { v | geometricprecision : Supported }
geometricprecision =
    Ir.token "geometricPrecision"


{-| The `hanging` token.
-}
hanging : Value { v | hanging : Supported }
hanging =
    Ir.token "hanging"


{-| The `hidden` token.
-}
hidden : Value { v | hidden : Supported }
hidden =
    Ir.token "hidden"


{-| The `ideographic` token.
-}
ideographic : Value { v | ideographic : Supported }
ideographic =
    Ir.token "ideographic"


{-| The `inline` token.
-}
inline : Value { v | inline : Supported }
inline =
    Ir.token "inline"


{-| The `inline-table` token.
-}
inlineTable : Value { v | inlineTable : Supported }
inlineTable =
    Ir.token "inline-table"


{-| The `linearRGB` token.
-}
linearrgb : Value { v | linearrgb : Supported }
linearrgb =
    Ir.token "linearRGB"


{-| The `list-item` token.
-}
listItem : Value { v | listItem : Supported }
listItem =
    Ir.token "list-item"


{-| The `lr` token.
-}
lr : Value { v | lr : Supported }
lr =
    Ir.token "lr"


{-| The `lr-tb` token.
-}
lrTb : Value { v | lrTb : Supported }
lrTb =
    Ir.token "lr-tb"


{-| The `ltr` token.
-}
ltr : Value { v | ltr : Supported }
ltr =
    Ir.token "ltr"


{-| The `marker` token.
-}
marker : Value { v | marker : Supported }
marker =
    Ir.token "marker"


{-| The `mathematical` token.
-}
mathematical : Value { v | mathematical : Supported }
mathematical =
    Ir.token "mathematical"


{-| The `middle` token.
-}
middle : Value { v | middle : Supported }
middle =
    Ir.token "middle"


{-| The `miter` token.
-}
miter : Value { v | miter : Supported }
miter =
    Ir.token "miter"


{-| The `no-change` token.
-}
noChange : Value { v | noChange : Supported }
noChange =
    Ir.token "no-change"


{-| The `non-scaling-stroke` token.
-}
nonScalingStroke : Value { v | nonScalingStroke : Supported }
nonScalingStroke =
    Ir.token "non-scaling-stroke"


{-| The `none` token.
-}
none : Value { v | none : Supported }
none =
    Ir.token "none"


{-| The `nonzero` token.
-}
nonzero : Value { v | nonzero : Supported }
nonzero =
    Ir.token "nonzero"


{-| The `normal` token.
-}
normal : Value { v | normal : Supported }
normal =
    Ir.token "normal"


{-| The `nowrap` token.
-}
nowrap : Value { v | nowrap : Supported }
nowrap =
    Ir.token "nowrap"


{-| The `optimizeLegibility` token.
-}
optimizelegibility : Value { v | optimizelegibility : Supported }
optimizelegibility =
    Ir.token "optimizeLegibility"


{-| The `optimizeQuality` token.
-}
optimizequality : Value { v | optimizequality : Supported }
optimizequality =
    Ir.token "optimizeQuality"


{-| The `optimizeSpeed` token.
-}
optimizespeed : Value { v | optimizespeed : Supported }
optimizespeed =
    Ir.token "optimizeSpeed"


{-| The `painted` token.
-}
painted : Value { v | painted : Supported }
painted =
    Ir.token "painted"


{-| The `pre` token.
-}
pre : Value { v | pre : Supported }
pre =
    Ir.token "pre"


{-| The `pre-line` token.
-}
preLine : Value { v | preLine : Supported }
preLine =
    Ir.token "pre-line"


{-| The `pre-wrap` token.
-}
preWrap : Value { v | preWrap : Supported }
preWrap =
    Ir.token "pre-wrap"


{-| The `preserve` token.
-}
preserve : Value { v | preserve : Supported }
preserve =
    Ir.token "preserve"


{-| The `reset-size` token.
-}
resetSize : Value { v | resetSize : Supported }
resetSize =
    Ir.token "reset-size"


{-| The `rl` token.
-}
rl : Value { v | rl : Supported }
rl =
    Ir.token "rl"


{-| The `rl-tb` token.
-}
rlTb : Value { v | rlTb : Supported }
rlTb =
    Ir.token "rl-tb"


{-| The `round` token.
-}
round : Value { v | round : Supported }
round =
    Ir.token "round"


{-| The `rtl` token.
-}
rtl : Value { v | rtl : Supported }
rtl =
    Ir.token "rtl"


{-| The `run-in` token.
-}
runIn : Value { v | runIn : Supported }
runIn =
    Ir.token "run-in"


{-| The `sRGB` token.
-}
srgb : Value { v | srgb : Supported }
srgb =
    Ir.token "sRGB"


{-| The `scroll` token.
-}
scroll : Value { v | scroll : Supported }
scroll =
    Ir.token "scroll"


{-| The `small-caps` token.
-}
smallCaps : Value { v | smallCaps : Supported }
smallCaps =
    Ir.token "small-caps"


{-| The `square` token.
-}
square : Value { v | square : Supported }
square =
    Ir.token "square"


{-| The `start` token.
-}
start : Value { v | start : Supported }
start =
    Ir.token "start"


{-| The `stroke` token.
-}
stroke : Value { v | stroke : Supported }
stroke =
    Ir.token "stroke"


{-| The `table` token.
-}
table : Value { v | table : Supported }
table =
    Ir.token "table"


{-| The `table-caption` token.
-}
tableCaption : Value { v | tableCaption : Supported }
tableCaption =
    Ir.token "table-caption"


{-| The `table-cell` token.
-}
tableCell : Value { v | tableCell : Supported }
tableCell =
    Ir.token "table-cell"


{-| The `table-column` token.
-}
tableColumn : Value { v | tableColumn : Supported }
tableColumn =
    Ir.token "table-column"


{-| The `table-column-group` token.
-}
tableColumnGroup : Value { v | tableColumnGroup : Supported }
tableColumnGroup =
    Ir.token "table-column-group"


{-| The `table-footer-group` token.
-}
tableFooterGroup : Value { v | tableFooterGroup : Supported }
tableFooterGroup =
    Ir.token "table-footer-group"


{-| The `table-header-group` token.
-}
tableHeaderGroup : Value { v | tableHeaderGroup : Supported }
tableHeaderGroup =
    Ir.token "table-header-group"


{-| The `table-row` token.
-}
tableRow : Value { v | tableRow : Supported }
tableRow =
    Ir.token "table-row"


{-| The `table-row-group` token.
-}
tableRowGroup : Value { v | tableRowGroup : Supported }
tableRowGroup =
    Ir.token "table-row-group"


{-| The `tb` token.
-}
tb : Value { v | tb : Supported }
tb =
    Ir.token "tb"


{-| The `tb-rl` token.
-}
tbRl : Value { v | tbRl : Supported }
tbRl =
    Ir.token "tb-rl"


{-| The `text-after-edge` token.
-}
textAfterEdge : Value { v | textAfterEdge : Supported }
textAfterEdge =
    Ir.token "text-after-edge"


{-| The `text-before-edge` token.
-}
textBeforeEdge : Value { v | textBeforeEdge : Supported }
textBeforeEdge =
    Ir.token "text-before-edge"


{-| The `use-script` token.
-}
useScript : Value { v | useScript : Supported }
useScript =
    Ir.token "use-script"


{-| The `visible` token.
-}
visible : Value { v | visible : Supported }
visible =
    Ir.token "visible"


{-| The `visibleFill` token.
-}
visiblefill : Value { v | visiblefill : Supported }
visiblefill =
    Ir.token "visibleFill"


{-| The `visiblePainted` token.
-}
visiblepainted : Value { v | visiblepainted : Supported }
visiblepainted =
    Ir.token "visiblePainted"


{-| The `visibleStroke` token.
-}
visiblestroke : Value { v | visiblestroke : Supported }
visiblestroke =
    Ir.token "visibleStroke"


{-| The `after-edge` value of the `alignmentBaseline` enum — same open row as `afterEdge`, prefixed for discovery.
-}
alignmentBaselineAfterEdge : Value { v | afterEdge : Supported }
alignmentBaselineAfterEdge =
    Ir.token "after-edge"


{-| The `alphabetic` value of the `alignmentBaseline` enum — same open row as `alphabetic`, prefixed for discovery.
-}
alignmentBaselineAlphabetic : Value { v | alphabetic : Supported }
alignmentBaselineAlphabetic =
    Ir.token "alphabetic"


{-| The `auto` value of the `alignmentBaseline` enum — same open row as `auto`, prefixed for discovery.
-}
alignmentBaselineAuto : Value { v | auto : Supported }
alignmentBaselineAuto =
    Ir.token "auto"


{-| The `baseline` value of the `alignmentBaseline` enum — same open row as `baseline`, prefixed for discovery.
-}
alignmentBaselineBaseline : Value { v | baseline : Supported }
alignmentBaselineBaseline =
    Ir.token "baseline"


{-| The `before-edge` value of the `alignmentBaseline` enum — same open row as `beforeEdge`, prefixed for discovery.
-}
alignmentBaselineBeforeEdge : Value { v | beforeEdge : Supported }
alignmentBaselineBeforeEdge =
    Ir.token "before-edge"


{-| The `central` value of the `alignmentBaseline` enum — same open row as `central`, prefixed for discovery.
-}
alignmentBaselineCentral : Value { v | central : Supported }
alignmentBaselineCentral =
    Ir.token "central"


{-| The `hanging` value of the `alignmentBaseline` enum — same open row as `hanging`, prefixed for discovery.
-}
alignmentBaselineHanging : Value { v | hanging : Supported }
alignmentBaselineHanging =
    Ir.token "hanging"


{-| The `ideographic` value of the `alignmentBaseline` enum — same open row as `ideographic`, prefixed for discovery.
-}
alignmentBaselineIdeographic : Value { v | ideographic : Supported }
alignmentBaselineIdeographic =
    Ir.token "ideographic"


{-| The `mathematical` value of the `alignmentBaseline` enum — same open row as `mathematical`, prefixed for discovery.
-}
alignmentBaselineMathematical : Value { v | mathematical : Supported }
alignmentBaselineMathematical =
    Ir.token "mathematical"


{-| The `middle` value of the `alignmentBaseline` enum — same open row as `middle`, prefixed for discovery.
-}
alignmentBaselineMiddle : Value { v | middle : Supported }
alignmentBaselineMiddle =
    Ir.token "middle"


{-| The `text-after-edge` value of the `alignmentBaseline` enum — same open row as `textAfterEdge`, prefixed for discovery.
-}
alignmentBaselineTextAfterEdge : Value { v | textAfterEdge : Supported }
alignmentBaselineTextAfterEdge =
    Ir.token "text-after-edge"


{-| The `text-before-edge` value of the `alignmentBaseline` enum — same open row as `textBeforeEdge`, prefixed for discovery.
-}
alignmentBaselineTextBeforeEdge : Value { v | textBeforeEdge : Supported }
alignmentBaselineTextBeforeEdge =
    Ir.token "text-before-edge"


{-| The `evenodd` value of the `clipRule` enum — same open row as `evenodd`, prefixed for discovery.
-}
clipRuleEvenodd : Value { v | evenodd : Supported }
clipRuleEvenodd =
    Ir.token "evenodd"


{-| The `nonzero` value of the `clipRule` enum — same open row as `nonzero`, prefixed for discovery.
-}
clipRuleNonzero : Value { v | nonzero : Supported }
clipRuleNonzero =
    Ir.token "nonzero"


{-| The `auto` value of the `colorInterpolation` enum — same open row as `auto`, prefixed for discovery.
-}
colorInterpolationAuto : Value { v | auto : Supported }
colorInterpolationAuto =
    Ir.token "auto"


{-| The `linearRGB` value of the `colorInterpolation` enum — same open row as `linearrgb`, prefixed for discovery.
-}
colorInterpolationLinearrgb : Value { v | linearrgb : Supported }
colorInterpolationLinearrgb =
    Ir.token "linearRGB"


{-| The `sRGB` value of the `colorInterpolation` enum — same open row as `srgb`, prefixed for discovery.
-}
colorInterpolationSrgb : Value { v | srgb : Supported }
colorInterpolationSrgb =
    Ir.token "sRGB"


{-| The `auto` value of the `colorRendering` enum — same open row as `auto`, prefixed for discovery.
-}
colorRenderingAuto : Value { v | auto : Supported }
colorRenderingAuto =
    Ir.token "auto"


{-| The `optimizeQuality` value of the `colorRendering` enum — same open row as `optimizequality`, prefixed for discovery.
-}
colorRenderingOptimizequality : Value { v | optimizequality : Supported }
colorRenderingOptimizequality =
    Ir.token "optimizeQuality"


{-| The `optimizeSpeed` value of the `colorRendering` enum — same open row as `optimizespeed`, prefixed for discovery.
-}
colorRenderingOptimizespeed : Value { v | optimizespeed : Supported }
colorRenderingOptimizespeed =
    Ir.token "optimizeSpeed"


{-| The `ltr` value of the `direction` enum — same open row as `ltr`, prefixed for discovery.
-}
directionLtr : Value { v | ltr : Supported }
directionLtr =
    Ir.token "ltr"


{-| The `rtl` value of the `direction` enum — same open row as `rtl`, prefixed for discovery.
-}
directionRtl : Value { v | rtl : Supported }
directionRtl =
    Ir.token "rtl"


{-| The `block` value of the `display` enum — same open row as `block`, prefixed for discovery.
-}
displayBlock : Value { v | block : Supported }
displayBlock =
    Ir.token "block"


{-| The `compact` value of the `display` enum — same open row as `compact`, prefixed for discovery.
-}
displayCompact : Value { v | compact : Supported }
displayCompact =
    Ir.token "compact"


{-| The `inline` value of the `display` enum — same open row as `inline`, prefixed for discovery.
-}
displayInline : Value { v | inline : Supported }
displayInline =
    Ir.token "inline"


{-| The `inline-table` value of the `display` enum — same open row as `inlineTable`, prefixed for discovery.
-}
displayInlineTable : Value { v | inlineTable : Supported }
displayInlineTable =
    Ir.token "inline-table"


{-| The `list-item` value of the `display` enum — same open row as `listItem`, prefixed for discovery.
-}
displayListItem : Value { v | listItem : Supported }
displayListItem =
    Ir.token "list-item"


{-| The `marker` value of the `display` enum — same open row as `marker`, prefixed for discovery.
-}
displayMarker : Value { v | marker : Supported }
displayMarker =
    Ir.token "marker"


{-| The `none` value of the `display` enum — same open row as `none`, prefixed for discovery.
-}
displayNone : Value { v | none : Supported }
displayNone =
    Ir.token "none"


{-| The `run-in` value of the `display` enum — same open row as `runIn`, prefixed for discovery.
-}
displayRunIn : Value { v | runIn : Supported }
displayRunIn =
    Ir.token "run-in"


{-| The `table` value of the `display` enum — same open row as `table`, prefixed for discovery.
-}
displayTable : Value { v | table : Supported }
displayTable =
    Ir.token "table"


{-| The `table-caption` value of the `display` enum — same open row as `tableCaption`, prefixed for discovery.
-}
displayTableCaption : Value { v | tableCaption : Supported }
displayTableCaption =
    Ir.token "table-caption"


{-| The `table-cell` value of the `display` enum — same open row as `tableCell`, prefixed for discovery.
-}
displayTableCell : Value { v | tableCell : Supported }
displayTableCell =
    Ir.token "table-cell"


{-| The `table-column` value of the `display` enum — same open row as `tableColumn`, prefixed for discovery.
-}
displayTableColumn : Value { v | tableColumn : Supported }
displayTableColumn =
    Ir.token "table-column"


{-| The `table-column-group` value of the `display` enum — same open row as `tableColumnGroup`, prefixed for discovery.
-}
displayTableColumnGroup : Value { v | tableColumnGroup : Supported }
displayTableColumnGroup =
    Ir.token "table-column-group"


{-| The `table-footer-group` value of the `display` enum — same open row as `tableFooterGroup`, prefixed for discovery.
-}
displayTableFooterGroup : Value { v | tableFooterGroup : Supported }
displayTableFooterGroup =
    Ir.token "table-footer-group"


{-| The `table-header-group` value of the `display` enum — same open row as `tableHeaderGroup`, prefixed for discovery.
-}
displayTableHeaderGroup : Value { v | tableHeaderGroup : Supported }
displayTableHeaderGroup =
    Ir.token "table-header-group"


{-| The `table-row` value of the `display` enum — same open row as `tableRow`, prefixed for discovery.
-}
displayTableRow : Value { v | tableRow : Supported }
displayTableRow =
    Ir.token "table-row"


{-| The `table-row-group` value of the `display` enum — same open row as `tableRowGroup`, prefixed for discovery.
-}
displayTableRowGroup : Value { v | tableRowGroup : Supported }
displayTableRowGroup =
    Ir.token "table-row-group"


{-| The `alphabetic` value of the `dominantBaseline` enum — same open row as `alphabetic`, prefixed for discovery.
-}
dominantBaselineAlphabetic : Value { v | alphabetic : Supported }
dominantBaselineAlphabetic =
    Ir.token "alphabetic"


{-| The `auto` value of the `dominantBaseline` enum — same open row as `auto`, prefixed for discovery.
-}
dominantBaselineAuto : Value { v | auto : Supported }
dominantBaselineAuto =
    Ir.token "auto"


{-| The `central` value of the `dominantBaseline` enum — same open row as `central`, prefixed for discovery.
-}
dominantBaselineCentral : Value { v | central : Supported }
dominantBaselineCentral =
    Ir.token "central"


{-| The `hanging` value of the `dominantBaseline` enum — same open row as `hanging`, prefixed for discovery.
-}
dominantBaselineHanging : Value { v | hanging : Supported }
dominantBaselineHanging =
    Ir.token "hanging"


{-| The `ideographic` value of the `dominantBaseline` enum — same open row as `ideographic`, prefixed for discovery.
-}
dominantBaselineIdeographic : Value { v | ideographic : Supported }
dominantBaselineIdeographic =
    Ir.token "ideographic"


{-| The `mathematical` value of the `dominantBaseline` enum — same open row as `mathematical`, prefixed for discovery.
-}
dominantBaselineMathematical : Value { v | mathematical : Supported }
dominantBaselineMathematical =
    Ir.token "mathematical"


{-| The `middle` value of the `dominantBaseline` enum — same open row as `middle`, prefixed for discovery.
-}
dominantBaselineMiddle : Value { v | middle : Supported }
dominantBaselineMiddle =
    Ir.token "middle"


{-| The `no-change` value of the `dominantBaseline` enum — same open row as `noChange`, prefixed for discovery.
-}
dominantBaselineNoChange : Value { v | noChange : Supported }
dominantBaselineNoChange =
    Ir.token "no-change"


{-| The `reset-size` value of the `dominantBaseline` enum — same open row as `resetSize`, prefixed for discovery.
-}
dominantBaselineResetSize : Value { v | resetSize : Supported }
dominantBaselineResetSize =
    Ir.token "reset-size"


{-| The `text-after-edge` value of the `dominantBaseline` enum — same open row as `textAfterEdge`, prefixed for discovery.
-}
dominantBaselineTextAfterEdge : Value { v | textAfterEdge : Supported }
dominantBaselineTextAfterEdge =
    Ir.token "text-after-edge"


{-| The `text-before-edge` value of the `dominantBaseline` enum — same open row as `textBeforeEdge`, prefixed for discovery.
-}
dominantBaselineTextBeforeEdge : Value { v | textBeforeEdge : Supported }
dominantBaselineTextBeforeEdge =
    Ir.token "text-before-edge"


{-| The `use-script` value of the `dominantBaseline` enum — same open row as `useScript`, prefixed for discovery.
-}
dominantBaselineUseScript : Value { v | useScript : Supported }
dominantBaselineUseScript =
    Ir.token "use-script"


{-| The `evenodd` value of the `fillRule` enum — same open row as `evenodd`, prefixed for discovery.
-}
fillRuleEvenodd : Value { v | evenodd : Supported }
fillRuleEvenodd =
    Ir.token "evenodd"


{-| The `nonzero` value of the `fillRule` enum — same open row as `nonzero`, prefixed for discovery.
-}
fillRuleNonzero : Value { v | nonzero : Supported }
fillRuleNonzero =
    Ir.token "nonzero"


{-| The `normal` value of the `fontVariant` enum — same open row as `normal`, prefixed for discovery.
-}
fontVariantNormal : Value { v | normal : Supported }
fontVariantNormal =
    Ir.token "normal"


{-| The `small-caps` value of the `fontVariant` enum — same open row as `smallCaps`, prefixed for discovery.
-}
fontVariantSmallCaps : Value { v | smallCaps : Supported }
fontVariantSmallCaps =
    Ir.token "small-caps"


{-| The `auto` value of the `imageRendering` enum — same open row as `auto`, prefixed for discovery.
-}
imageRenderingAuto : Value { v | auto : Supported }
imageRenderingAuto =
    Ir.token "auto"


{-| The `optimizeQuality` value of the `imageRendering` enum — same open row as `optimizequality`, prefixed for discovery.
-}
imageRenderingOptimizequality : Value { v | optimizequality : Supported }
imageRenderingOptimizequality =
    Ir.token "optimizeQuality"


{-| The `optimizeSpeed` value of the `imageRendering` enum — same open row as `optimizespeed`, prefixed for discovery.
-}
imageRenderingOptimizespeed : Value { v | optimizespeed : Supported }
imageRenderingOptimizespeed =
    Ir.token "optimizeSpeed"


{-| The `auto` value of the `overflow` enum — same open row as `auto`, prefixed for discovery.
-}
overflowAuto : Value { v | auto : Supported }
overflowAuto =
    Ir.token "auto"


{-| The `hidden` value of the `overflow` enum — same open row as `hidden`, prefixed for discovery.
-}
overflowHidden : Value { v | hidden : Supported }
overflowHidden =
    Ir.token "hidden"


{-| The `scroll` value of the `overflow` enum — same open row as `scroll`, prefixed for discovery.
-}
overflowScroll : Value { v | scroll : Supported }
overflowScroll =
    Ir.token "scroll"


{-| The `visible` value of the `overflow` enum — same open row as `visible`, prefixed for discovery.
-}
overflowVisible : Value { v | visible : Supported }
overflowVisible =
    Ir.token "visible"


{-| The `all` value of the `pointerEvents` enum — same open row as `all`, prefixed for discovery.
-}
pointerEventsAll : Value { v | all : Supported }
pointerEventsAll =
    Ir.token "all"


{-| The `bounding-box` value of the `pointerEvents` enum — same open row as `boundingBox`, prefixed for discovery.
-}
pointerEventsBoundingBox : Value { v | boundingBox : Supported }
pointerEventsBoundingBox =
    Ir.token "bounding-box"


{-| The `fill` value of the `pointerEvents` enum — same open row as `fill`, prefixed for discovery.
-}
pointerEventsFill : Value { v | fill : Supported }
pointerEventsFill =
    Ir.token "fill"


{-| The `none` value of the `pointerEvents` enum — same open row as `none`, prefixed for discovery.
-}
pointerEventsNone : Value { v | none : Supported }
pointerEventsNone =
    Ir.token "none"


{-| The `painted` value of the `pointerEvents` enum — same open row as `painted`, prefixed for discovery.
-}
pointerEventsPainted : Value { v | painted : Supported }
pointerEventsPainted =
    Ir.token "painted"


{-| The `stroke` value of the `pointerEvents` enum — same open row as `stroke`, prefixed for discovery.
-}
pointerEventsStroke : Value { v | stroke : Supported }
pointerEventsStroke =
    Ir.token "stroke"


{-| The `visible` value of the `pointerEvents` enum — same open row as `visible`, prefixed for discovery.
-}
pointerEventsVisible : Value { v | visible : Supported }
pointerEventsVisible =
    Ir.token "visible"


{-| The `visibleFill` value of the `pointerEvents` enum — same open row as `visiblefill`, prefixed for discovery.
-}
pointerEventsVisiblefill : Value { v | visiblefill : Supported }
pointerEventsVisiblefill =
    Ir.token "visibleFill"


{-| The `visiblePainted` value of the `pointerEvents` enum — same open row as `visiblepainted`, prefixed for discovery.
-}
pointerEventsVisiblepainted : Value { v | visiblepainted : Supported }
pointerEventsVisiblepainted =
    Ir.token "visiblePainted"


{-| The `visibleStroke` value of the `pointerEvents` enum — same open row as `visiblestroke`, prefixed for discovery.
-}
pointerEventsVisiblestroke : Value { v | visiblestroke : Supported }
pointerEventsVisiblestroke =
    Ir.token "visibleStroke"


{-| The `auto` value of the `shapeRendering` enum — same open row as `auto`, prefixed for discovery.
-}
shapeRenderingAuto : Value { v | auto : Supported }
shapeRenderingAuto =
    Ir.token "auto"


{-| The `crispEdges` value of the `shapeRendering` enum — same open row as `crispedges`, prefixed for discovery.
-}
shapeRenderingCrispedges : Value { v | crispedges : Supported }
shapeRenderingCrispedges =
    Ir.token "crispEdges"


{-| The `geometricPrecision` value of the `shapeRendering` enum — same open row as `geometricprecision`, prefixed for discovery.
-}
shapeRenderingGeometricprecision : Value { v | geometricprecision : Supported }
shapeRenderingGeometricprecision =
    Ir.token "geometricPrecision"


{-| The `optimizeSpeed` value of the `shapeRendering` enum — same open row as `optimizespeed`, prefixed for discovery.
-}
shapeRenderingOptimizespeed : Value { v | optimizespeed : Supported }
shapeRenderingOptimizespeed =
    Ir.token "optimizeSpeed"


{-| The `butt` value of the `strokeLinecap` enum — same open row as `butt`, prefixed for discovery.
-}
strokeLinecapButt : Value { v | butt : Supported }
strokeLinecapButt =
    Ir.token "butt"


{-| The `round` value of the `strokeLinecap` enum — same open row as `round`, prefixed for discovery.
-}
strokeLinecapRound : Value { v | round : Supported }
strokeLinecapRound =
    Ir.token "round"


{-| The `square` value of the `strokeLinecap` enum — same open row as `square`, prefixed for discovery.
-}
strokeLinecapSquare : Value { v | square : Supported }
strokeLinecapSquare =
    Ir.token "square"


{-| The `bevel` value of the `strokeLinejoin` enum — same open row as `bevel`, prefixed for discovery.
-}
strokeLinejoinBevel : Value { v | bevel : Supported }
strokeLinejoinBevel =
    Ir.token "bevel"


{-| The `miter` value of the `strokeLinejoin` enum — same open row as `miter`, prefixed for discovery.
-}
strokeLinejoinMiter : Value { v | miter : Supported }
strokeLinejoinMiter =
    Ir.token "miter"


{-| The `round` value of the `strokeLinejoin` enum — same open row as `round`, prefixed for discovery.
-}
strokeLinejoinRound : Value { v | round : Supported }
strokeLinejoinRound =
    Ir.token "round"


{-| The `end` value of the `textAnchor` enum — same open row as `end`, prefixed for discovery.
-}
textAnchorEnd : Value { v | end : Supported }
textAnchorEnd =
    Ir.token "end"


{-| The `middle` value of the `textAnchor` enum — same open row as `middle`, prefixed for discovery.
-}
textAnchorMiddle : Value { v | middle : Supported }
textAnchorMiddle =
    Ir.token "middle"


{-| The `start` value of the `textAnchor` enum — same open row as `start`, prefixed for discovery.
-}
textAnchorStart : Value { v | start : Supported }
textAnchorStart =
    Ir.token "start"


{-| The `auto` value of the `textRendering` enum — same open row as `auto`, prefixed for discovery.
-}
textRenderingAuto : Value { v | auto : Supported }
textRenderingAuto =
    Ir.token "auto"


{-| The `geometricPrecision` value of the `textRendering` enum — same open row as `geometricprecision`, prefixed for discovery.
-}
textRenderingGeometricprecision : Value { v | geometricprecision : Supported }
textRenderingGeometricprecision =
    Ir.token "geometricPrecision"


{-| The `optimizeLegibility` value of the `textRendering` enum — same open row as `optimizelegibility`, prefixed for discovery.
-}
textRenderingOptimizelegibility : Value { v | optimizelegibility : Supported }
textRenderingOptimizelegibility =
    Ir.token "optimizeLegibility"


{-| The `optimizeSpeed` value of the `textRendering` enum — same open row as `optimizespeed`, prefixed for discovery.
-}
textRenderingOptimizespeed : Value { v | optimizespeed : Supported }
textRenderingOptimizespeed =
    Ir.token "optimizeSpeed"


{-| The `non-scaling-stroke` value of the `vectorEffect` enum — same open row as `nonScalingStroke`, prefixed for discovery.
-}
vectorEffectNonScalingStroke : Value { v | nonScalingStroke : Supported }
vectorEffectNonScalingStroke =
    Ir.token "non-scaling-stroke"


{-| The `none` value of the `vectorEffect` enum — same open row as `none`, prefixed for discovery.
-}
vectorEffectNone : Value { v | none : Supported }
vectorEffectNone =
    Ir.token "none"


{-| The `collapse` value of the `visibility` enum — same open row as `collapse`, prefixed for discovery.
-}
visibilityCollapse : Value { v | collapse : Supported }
visibilityCollapse =
    Ir.token "collapse"


{-| The `hidden` value of the `visibility` enum — same open row as `hidden`, prefixed for discovery.
-}
visibilityHidden : Value { v | hidden : Supported }
visibilityHidden =
    Ir.token "hidden"


{-| The `visible` value of the `visibility` enum — same open row as `visible`, prefixed for discovery.
-}
visibilityVisible : Value { v | visible : Supported }
visibilityVisible =
    Ir.token "visible"


{-| The `normal` value of the `whiteSpace` enum — same open row as `normal`, prefixed for discovery.
-}
whiteSpaceNormal : Value { v | normal : Supported }
whiteSpaceNormal =
    Ir.token "normal"


{-| The `nowrap` value of the `whiteSpace` enum — same open row as `nowrap`, prefixed for discovery.
-}
whiteSpaceNowrap : Value { v | nowrap : Supported }
whiteSpaceNowrap =
    Ir.token "nowrap"


{-| The `pre` value of the `whiteSpace` enum — same open row as `pre`, prefixed for discovery.
-}
whiteSpacePre : Value { v | pre : Supported }
whiteSpacePre =
    Ir.token "pre"


{-| The `pre-line` value of the `whiteSpace` enum — same open row as `preLine`, prefixed for discovery.
-}
whiteSpacePreLine : Value { v | preLine : Supported }
whiteSpacePreLine =
    Ir.token "pre-line"


{-| The `pre-wrap` value of the `whiteSpace` enum — same open row as `preWrap`, prefixed for discovery.
-}
whiteSpacePreWrap : Value { v | preWrap : Supported }
whiteSpacePreWrap =
    Ir.token "pre-wrap"


{-| The `lr` value of the `writingMode` enum — same open row as `lr`, prefixed for discovery.
-}
writingModeLr : Value { v | lr : Supported }
writingModeLr =
    Ir.token "lr"


{-| The `lr-tb` value of the `writingMode` enum — same open row as `lrTb`, prefixed for discovery.
-}
writingModeLrTb : Value { v | lrTb : Supported }
writingModeLrTb =
    Ir.token "lr-tb"


{-| The `rl` value of the `writingMode` enum — same open row as `rl`, prefixed for discovery.
-}
writingModeRl : Value { v | rl : Supported }
writingModeRl =
    Ir.token "rl"


{-| The `rl-tb` value of the `writingMode` enum — same open row as `rlTb`, prefixed for discovery.
-}
writingModeRlTb : Value { v | rlTb : Supported }
writingModeRlTb =
    Ir.token "rl-tb"


{-| The `tb` value of the `writingMode` enum — same open row as `tb`, prefixed for discovery.
-}
writingModeTb : Value { v | tb : Supported }
writingModeTb =
    Ir.token "tb"


{-| The `tb-rl` value of the `writingMode` enum — same open row as `tbRl`, prefixed for discovery.
-}
writingModeTbRl : Value { v | tbRl : Supported }
writingModeTbRl =
    Ir.token "tb-rl"


{-| The `default` value of the `xmlSpace` enum — same open row as `default`, prefixed for discovery.
-}
xmlSpaceDefault : Value { v | default : Supported }
xmlSpaceDefault =
    Ir.token "default"


{-| The `preserve` value of the `xmlSpace` enum — same open row as `preserve`, prefixed for discovery.
-}
xmlSpacePreserve : Value { v | preserve : Supported }
xmlSpacePreserve =
    Ir.token "preserve"
