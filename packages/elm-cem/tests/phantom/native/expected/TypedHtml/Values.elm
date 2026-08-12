module TypedHtml.Values exposing
    ( Value
    , toString
    , Dir, Hidden
    , dirFromString, dirValues, hiddenFromString, hiddenValues
    , auto, hidden, ltr, rtl, untilFound
    , dirAuto, dirLtr, dirRtl, hiddenHidden, hiddenUntilFound
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
@docs Dir, Hidden
@docs dirFromString, dirValues, hiddenFromString, hiddenValues
@docs auto, hidden, ltr, rtl, untilFound
@docs dirAuto, dirLtr, dirRtl, hiddenHidden, hiddenUntilFound

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


{-| The union row for `dir`.
-}
type alias Dir =
    { auto : Supported
    , ltr : Supported
    , rtl : Supported
    }


{-| The union row for `hidden`.
-}
type alias Hidden =
    { hidden : Supported
    , untilFound : Supported
    }


{-| Parse a `dir` value from the string it writes to the DOM. The inverse of `toString`.
-}
dirFromString : String -> Maybe (Value Dir)
dirFromString s =
    case s of
        "auto" ->
            Just auto

        "ltr" ->
            Just ltr

        "rtl" ->
            Just rtl

        _ ->
            Nothing


{-| Parse a `hidden` value from the string it writes to the DOM. The inverse of `toString`.
-}
hiddenFromString : String -> Maybe (Value Hidden)
hiddenFromString s =
    case s of
        "hidden" ->
            Just hidden

        "until-found" ->
            Just untilFound

        _ ->
            Nothing


{-| Every `dir` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
dirValues : List (Value Dir)
dirValues =
    [ auto, ltr, rtl ]


{-| Every `hidden` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
hiddenValues : List (Value Hidden)
hiddenValues =
    [ hidden, untilFound ]


{-| The `auto` token.
-}
auto : Value { v | auto : Supported }
auto =
    Ir.token "auto"


{-| The `hidden` token.
-}
hidden : Value { v | hidden : Supported }
hidden =
    Ir.token "hidden"


{-| The `ltr` token.
-}
ltr : Value { v | ltr : Supported }
ltr =
    Ir.token "ltr"


{-| The `rtl` token.
-}
rtl : Value { v | rtl : Supported }
rtl =
    Ir.token "rtl"


{-| The `until-found` token.
-}
untilFound : Value { v | untilFound : Supported }
untilFound =
    Ir.token "until-found"


{-| The `auto` value of the `dir` enum — same open row as `auto`, prefixed for discovery.
-}
dirAuto : Value { v | auto : Supported }
dirAuto =
    Ir.token "auto"


{-| The `ltr` value of the `dir` enum — same open row as `ltr`, prefixed for discovery.
-}
dirLtr : Value { v | ltr : Supported }
dirLtr =
    Ir.token "ltr"


{-| The `rtl` value of the `dir` enum — same open row as `rtl`, prefixed for discovery.
-}
dirRtl : Value { v | rtl : Supported }
dirRtl =
    Ir.token "rtl"


{-| The `hidden` value of the `hidden` enum — same open row as `hidden`, prefixed for discovery.
-}
hiddenHidden : Value { v | hidden : Supported }
hiddenHidden =
    Ir.token "hidden"


{-| The `until-found` value of the `hidden` enum — same open row as `untilFound`, prefixed for discovery.
-}
hiddenUntilFound : Value { v | untilFound : Supported }
hiddenUntilFound =
    Ir.token "until-found"
