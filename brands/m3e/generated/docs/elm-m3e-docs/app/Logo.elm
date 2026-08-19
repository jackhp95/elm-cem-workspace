module Logo exposing (Colors, defaultColors, invertedColors, view)

{-| The tangram mark — two triangles, theme-aware via `--md-sys-color-*`
custom properties. Used as the docs nav-rail's toggle icon (`Shared.elm`)
and as the source-of-truth SVG geometry the favicon generator
(`docs/scripts/icons-gen/tangram-favicon.mjs`) mirrors — keep the two
`d` attribute path strings below in sync with that script's `PATHS`
constant if this geometry ever changes; they can't literally share code
across the Elm/Node boundary.

Not routed through `M3e.Icon`'s named-icon registry — that registry is
built for single-color icon-font-style glyphs, not two independently
fillable paths. Not a generalized `M3e.Logo` library component — this stays
docs-app-scoped per the spec's non-goal (revisit if a second consumer
wants it).

Returns a plain `Svg.Svg msg`, not a typed `Element` — `M3e.Unsafe` is fenced
to a fixed allow-list of modules (`review/src/CodegenReviewConfig.elm`'s
`NoUnsafeImportOutsideAllowed`), and `Logo` is deliberately not on it. The
`M3e.Unsafe.fromHtml` wrap happens at the call site in `Shared.elm`, which is
allow-listed as the app-shell root.

-}

import Svg exposing (Svg)
import Svg.Attributes as SvgAttr


{-| The two triangles' fill colors — `small` is the smaller triangle (the
second `<path>`, which draws the notch), `big` is the larger one (the first
`<path>`, the full corner-to-corner triangle).
-}
type alias Colors =
    { small : String, big : String }


{-| Collapsed/closed nav-rail state, and the favicon's default: both
triangles the same brand-primary color — the plain mark.
-}
defaultColors : Colors
defaultColors =
    { small = "var(--md-sys-color-primary)", big = "var(--md-sys-color-primary)" }


{-| Expanded/open nav-rail state: the smaller triangle takes the
`on-surface` color while the larger triangle stays brand-primary (same as
`defaultColors`), per the original spec — expanded distinguishes the two
triangles by color, it does not recolor both.
-}
invertedColors : Colors
invertedColors =
    { small = "var(--md-sys-color-on-surface)", big = "var(--md-sys-color-primary)" }


{-| Wrap the result in `M3e.Unsafe.fromHtml` at the call site (`Shared.elm`)
to admit it into a typed `Element` slot — its FREE rows mean that type-checks
into any slot, including `M3e.Icon`'s `sharedIcon` kind, without needing
`M3e.Unsafe.recast` on top.
-}
view : Colors -> Svg msg
view colors =
    Svg.svg
        [ SvgAttr.viewBox "0 0 566 566"
        , SvgAttr.fill "none"
        , SvgAttr.class "tangram-mark"
        ]
        [ Svg.path [ SvgAttr.fill colors.big, SvgAttr.d "m0 0 566 566H0z" ] []
        , Svg.path [ SvgAttr.fill colors.small, SvgAttr.d "M566 0v535L299 267.973z" ] []
        ]
