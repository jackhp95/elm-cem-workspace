module EnumNarrowingOk exposing (narrowingExamples)

{-| Regression fixture: strict per-component enum narrowing COMPILES.

Proves the two-tier enum safety model (spec §3.4, §1.5):

  - Tier 1 (compile-time): `M3e.Component.*` and `M3e.Build.*` setters accept
    ONLY the closed Variant row for THAT component.
  - Tier 2 (elm-review): `M3e.Attributes` setters accept the global open union
    and are backstopped by `Cem.ValidEnumValue`.

Each assertion here MUST compile. The corresponding bad/ fixtures confirm that
the closed-row narrowing actually REJECTS wrong-component tokens.

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Build.Button as Button
import M3e.Component.SplitButton as SplitButton
import M3e.Component.Theme as Theme
import M3e.Kind exposing (Available, Used)
import M3e.Values as V


type Msg
    = NoOp


{-| 1. Theme.variant accepts V.rainbow — rainbow IS in Theme.Variant.
-}
themeVariantRainbow : Attr { c | variant : Supported } Msg
themeVariantRainbow =
    Theme.variant V.rainbow


{-| 2. SplitButton.variant accepts V.filled — filled IS in SplitButton.Variant.
-}
splitButtonVariantFilled : Attr { c | variant : Supported } Msg
splitButtonVariantFilled =
    SplitButton.variant V.filled


{-| 3. Button.withVariant accepts Value.filled — the canonical builder pipeline
narrow value (locks the form from ApiConsolidation.elm:51).

This WILL FAIL if the builder's closed Component.Variant loses `filled`.

-}
builderVariantFilled :
    Button.Builder { a | variant : Available } slotCaps Msg kind
    -> Button.Builder { a | variant : Used } slotCaps Msg kind
builderVariantFilled =
    Button.withVariant V.filled


{-| 4. Loose A.variant accepts V.rainbow — shared open-row, no narrowing.
The elm-review Cem.ValidEnumValue rule is the backstop here, not the type.
-}
looseVariantRainbow : Attr { c | variant : Supported } Msg
looseVariantRainbow =
    A.variant V.rainbow


{-| Aggregate all examples to prevent DCE removing them from type-checking.
-}
narrowingExamples : ()
narrowingExamples =
    let
        _ =
            themeVariantRainbow

        _ =
            splitButtonVariantFilled

        _ =
            looseVariantRainbow
    in
    ()
