module Mini.Values exposing
    ( Value
    , toString
    , Dir, Size, Variant
    , dirFromString, dirValues, sizeFromString, sizeValues, variantFromString, variantValues
    , auto, big, filled, ltr, rtl, small, tonal
    , dirAuto, dirLtr, dirRtl, sizeBig, sizeSmall, variantFilled, variantTonal
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
@docs Dir, Size, Variant
@docs dirFromString, dirValues, sizeFromString, sizeValues, variantFromString, variantValues
@docs auto, big, filled, ltr, rtl, small, tonal
@docs dirAuto, dirLtr, dirRtl, sizeBig, sizeSmall, variantFilled, variantTonal

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


{-| The union row for `size` (from `ChipSize`).
-}
type alias Size =
    { big : Supported
    , small : Supported
    }


{-| The union row for `variant` (from `ButtonVariant`).
-}
type alias Variant =
    { filled : Supported
    , tonal : Supported
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


{-| Parse a `size` value from the string it writes to the DOM. The inverse of `toString`.
-}
sizeFromString : String -> Maybe (Value Size)
sizeFromString s =
    case s of
        "big" ->
            Just big

        "small" ->
            Just small

        _ ->
            Nothing


{-| Parse a `variant` value from the string it writes to the DOM. The inverse of `toString`.
-}
variantFromString : String -> Maybe (Value Variant)
variantFromString s =
    case s of
        "filled" ->
            Just filled

        "tonal" ->
            Just tonal

        _ ->
            Nothing


{-| Every `dir` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
dirValues : List (Value Dir)
dirValues =
    [ auto, ltr, rtl ]


{-| Every `size` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
sizeValues : List (Value Size)
sizeValues =
    [ big, small ]


{-| Every `variant` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
variantValues : List (Value Variant)
variantValues =
    [ filled, tonal ]


{-| The `auto` token.
-}
auto : Value { v | auto : Supported }
auto =
    Ir.token "auto"


{-| The `big` token.
-}
big : Value { v | big : Supported }
big =
    Ir.token "big"


{-| The `filled` token.
-}
filled : Value { v | filled : Supported }
filled =
    Ir.token "filled"


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


{-| The `small` token.
-}
small : Value { v | small : Supported }
small =
    Ir.token "small"


{-| The `tonal` token.
-}
tonal : Value { v | tonal : Supported }
tonal =
    Ir.token "tonal"


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


{-| The `big` value of the `size` enum — same open row as `big`, prefixed for discovery.
-}
sizeBig : Value { v | big : Supported }
sizeBig =
    Ir.token "big"


{-| The `small` value of the `size` enum — same open row as `small`, prefixed for discovery.
-}
sizeSmall : Value { v | small : Supported }
sizeSmall =
    Ir.token "small"


{-| The `filled` value of the `variant` enum — same open row as `filled`, prefixed for discovery.
-}
variantFilled : Value { v | filled : Supported }
variantFilled =
    Ir.token "filled"


{-| The `tonal` value of the `variant` enum — same open row as `tonal`, prefixed for discovery.
-}
variantTonal : Value { v | tonal : Supported }
variantTonal =
    Ir.token "tonal"
