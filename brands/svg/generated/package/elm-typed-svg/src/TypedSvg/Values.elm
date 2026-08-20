module TypedSvg.Values exposing
    ( Value
    , toString
    , ClipRule, FillRule, StrokeLinecap, StrokeLinejoin, TextAnchor, Visibility
    , clipRuleFromString, clipRuleValues, fillRuleFromString, fillRuleValues, strokeLinecapFromString, strokeLinecapValues, strokeLinejoinFromString, strokeLinejoinValues, textAnchorFromString, textAnchorValues, visibilityFromString, visibilityValues
    , bevel, butt, collapse, end, evenodd, hidden, middle, miter, nonzero, round, square, start, visible
    , clipRuleEvenodd, clipRuleNonzero, fillRuleEvenodd, fillRuleNonzero, strokeLinecapButt, strokeLinecapRound, strokeLinecapSquare, strokeLinejoinBevel, strokeLinejoinMiter, strokeLinejoinRound, textAnchorEnd, textAnchorMiddle, textAnchorStart, visibilityCollapse, visibilityHidden, visibilityVisible
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
@docs ClipRule, FillRule, StrokeLinecap, StrokeLinejoin, TextAnchor, Visibility
@docs clipRuleFromString, clipRuleValues, fillRuleFromString, fillRuleValues, strokeLinecapFromString, strokeLinecapValues, strokeLinejoinFromString, strokeLinejoinValues, textAnchorFromString, textAnchorValues, visibilityFromString, visibilityValues
@docs bevel, butt, collapse, end, evenodd, hidden, middle, miter, nonzero, round, square, start, visible
@docs clipRuleEvenodd, clipRuleNonzero, fillRuleEvenodd, fillRuleNonzero, strokeLinecapButt, strokeLinecapRound, strokeLinecapSquare, strokeLinejoinBevel, strokeLinejoinMiter, strokeLinejoinRound, textAnchorEnd, textAnchorMiddle, textAnchorStart, visibilityCollapse, visibilityHidden, visibilityVisible

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


{-| The union row for `clipRule`.
-}
type alias ClipRule =
    { evenodd : Supported
    , nonzero : Supported
    }


{-| The union row for `fillRule`.
-}
type alias FillRule =
    { evenodd : Supported
    , nonzero : Supported
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


{-| The union row for `visibility`.
-}
type alias Visibility =
    { collapse : Supported
    , hidden : Supported
    , visible : Supported
    }


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


{-| Every `clipRule` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
clipRuleValues : List (Value ClipRule)
clipRuleValues =
    [ evenodd, nonzero ]


{-| Every `fillRule` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
fillRuleValues : List (Value FillRule)
fillRuleValues =
    [ evenodd, nonzero ]


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


{-| Every `visibility` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
visibilityValues : List (Value Visibility)
visibilityValues =
    [ collapse, hidden, visible ]


{-| The `bevel` token.
-}
bevel : Value { v | bevel : Supported }
bevel =
    Ir.token "bevel"


{-| The `butt` token.
-}
butt : Value { v | butt : Supported }
butt =
    Ir.token "butt"


{-| The `collapse` token.
-}
collapse : Value { v | collapse : Supported }
collapse =
    Ir.token "collapse"


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


{-| The `hidden` token.
-}
hidden : Value { v | hidden : Supported }
hidden =
    Ir.token "hidden"


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


{-| The `nonzero` token.
-}
nonzero : Value { v | nonzero : Supported }
nonzero =
    Ir.token "nonzero"


{-| The `round` token.
-}
round : Value { v | round : Supported }
round =
    Ir.token "round"


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


{-| The `visible` token.
-}
visible : Value { v | visible : Supported }
visible =
    Ir.token "visible"


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
