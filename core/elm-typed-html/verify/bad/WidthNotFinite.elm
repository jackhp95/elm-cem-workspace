module WidthNotFinite exposing (broken)

{-| The other half of the same bug: the NON-FINITE floats. MUST FAIL.

`String.fromFloat` has three outputs no HTML integer parser accepts, and a fractional
literal (bad/ColspanFloat) is only the one an author writes on purpose:

    String.fromFloat (1 / 0) == "Infinity"

    String.fromFloat (0 / 0) == "NaN"

    String.fromFloat 1.0e21 == "1e+21"

These are the ones a COMPUTED width reaches by accident — `1 / 0` from a zero
denominator in a layout calculation, `0 / 0` from `0 * (1 / 0)`, `1e21` from an
overflowing product. `<img width="Infinity">` is `width` absent: the image falls back
to its intrinsic size and the layout silently differs from the one that was asked for.

`Int` removes them by construction, and unlike the fractional case it does so where the
mistake is not visible in the source. Nothing in integer arithmetic can reach `NaN` or
`Infinity` either: Elm's `//` and `remainderBy` are defined to return `0` for a zero
divisor rather than a non-finite value.

One honest residue, since an Elm `Int` is a JS double at runtime: an OVERFLOWING integer
expression (`2 ^ 70`) exceeds 2^53, and `String.fromInt` — which is `n + ""` — then
prints exponent notation, so exactly one of the three shapes above survives via a route
no realistic `width` calculation takes. It is a degenerate case, not a reason to prefer
`Float`, which reaches all three from ordinary arithmetic.

What `Int` does NOT buy is RANGE. `At.width -5` still compiles, and so does
`At.colspan 0` on a "greater than zero" attribute. That is deliberate and it is the
end of the road, not a staged fix:

  - Elm has no refinement, literal or dependent types. There is no type whose
    inhabitants are the integers >= 1 while `colspan 2` remains a bare literal.
  - An opaque `Positive` with `fromInt : Int -> Maybe Positive` moves the check to
    RUNTIME and makes every call site discharge a `Maybe`, which callers do with
    `withDefault` — the guard evaporates and the ergonomics get worse.
  - A `one` / `succ` constructor encoding IS compile-time and is unusable past about
    three.
  - The capability-row divergence that gave `<progress>`/`<meter>` their own
    `valueNumeric` row does not apply: it partitions by ELEMENT, and every element
    sharing `colspan` shares its value space exactly. There is nothing to diverge.

And the residue is the strictly milder failure. HTML's integer parsers ACCEPT an
out-of-range integer and clamp it to the spec's stated default; they DISCARD a
malformed one. Ill-formed was the bug; out-of-range is a documented fallback.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.img [ At.src "a.png", At.alt "a", At.width (1 / 0) ] []
