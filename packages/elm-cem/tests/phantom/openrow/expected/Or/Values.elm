module Or.Values exposing
    ( Value
    , toString
    , Cdir, Odir
    , cdirFromString, cdirValues, odirFromString, odirValues
    , auto, ltr, rtl
    , cdirAuto, cdirLtr, cdirRtl, odirAuto, odirLtr, odirRtl
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
@docs Cdir, Odir
@docs cdirFromString, cdirValues, odirFromString, odirValues
@docs auto, ltr, rtl
@docs cdirAuto, cdirLtr, cdirRtl, odirAuto, odirLtr, odirRtl

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


{-| The union row for `cdir`.
-}
type alias Cdir =
    { auto : Supported
    , ltr : Supported
    , rtl : Supported
    }


{-| The union row for `odir`.
-}
type alias Odir =
    { auto : Supported
    , ltr : Supported
    , rtl : Supported
    }


{-| Parse a `cdir` value from the string it writes to the DOM. The inverse of `toString`.
-}
cdirFromString : String -> Maybe (Value Cdir)
cdirFromString s =
    case s of
        "auto" ->
            Just auto

        "ltr" ->
            Just ltr

        "rtl" ->
            Just rtl

        _ ->
            Nothing


{-| Parse a `odir` value from the string it writes to the DOM. The inverse of `toString`.
-}
odirFromString : String -> Maybe (Value Odir)
odirFromString s =
    case s of
        "auto" ->
            Just auto

        "ltr" ->
            Just ltr

        "rtl" ->
            Just rtl

        _ ->
            Nothing


{-| Every `cdir` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
cdirValues : List (Value Cdir)
cdirValues =
    [ auto, ltr, rtl ]


{-| Every `odir` value. Map a UI over this and adding a value to the manifest cannot silently miss it.
-}
odirValues : List (Value Odir)
odirValues =
    [ auto, ltr, rtl ]


{-| The `auto` token.
-}
auto : Value { v | auto : Supported }
auto =
    Ir.token "auto"


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


{-| The `auto` value of the `cdir` enum — same open row as `auto`, prefixed for discovery.
-}
cdirAuto : Value { v | auto : Supported }
cdirAuto =
    Ir.token "auto"


{-| The `ltr` value of the `cdir` enum — same open row as `ltr`, prefixed for discovery.
-}
cdirLtr : Value { v | ltr : Supported }
cdirLtr =
    Ir.token "ltr"


{-| The `rtl` value of the `cdir` enum — same open row as `rtl`, prefixed for discovery.
-}
cdirRtl : Value { v | rtl : Supported }
cdirRtl =
    Ir.token "rtl"


{-| The `auto` value of the `odir` enum — same open row as `auto`, prefixed for discovery.
-}
odirAuto : Value { v | auto : Supported }
odirAuto =
    Ir.token "auto"


{-| The `ltr` value of the `odir` enum — same open row as `ltr`, prefixed for discovery.
-}
odirLtr : Value { v | ltr : Supported }
odirLtr =
    Ir.token "ltr"


{-| The `rtl` value of the `odir` enum — same open row as `rtl`, prefixed for discovery.
-}
odirRtl : Value { v | rtl : Supported }
odirRtl =
    Ir.token "rtl"
