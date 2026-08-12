module SizeFloat exposing (broken)

{-| The `integer`-spelling acid case. MUST FAIL.

`<select size>` is "Valid non-negative integer greater than zero" per WHATWG. The
nano fixture declares it `"type": { "text": "integer" }`, which `Attr.classifyText`
resolves to `AInt` and the emitter spells `Int -> Attr`. So this does not compile.

It used to. Before the `integer` spelling existed, `AInt` was reachable ONLY from an
integer-LITERAL union (`1 | 2 | 3`), so an unbounded integer value space had no
spelling and every one of them was declared `number` — `Float -> Attr`, serialized
with `String.fromFloat`. That function's range includes four strings HTML's integer
parsers REJECT:

    String.fromFloat 2.5      == "2.5"
    String.fromFloat (0 / 0)  == "NaN"
    String.fromFloat (1 / 0)  == "Infinity"
    String.fromFloat 1.0e21   == "1e+21"

A rejected value is not an ignored one — the parser substitutes the attribute's
DEFAULT — so the bug is silent and value-changing rather than loud: `colspan="2.5"`
renders as one column and the table loses the other. `elm/html` types all eleven of
these `Int` and always has.

What this does NOT pin is RANGE. `At.size 0` and `At.size -3` still compile, because
Elm cannot spell "the integers ≥ 1": there is no refinement, literal or dependent
type, and the alternatives (an opaque `Positive` with `fromInt : Int -> Maybe
Positive`, or a `one`/`succ` encoding) either move the check to runtime or make a
literal unwritable. That residue is also the milder failure — HTML ACCEPTS an
out-of-range integer and clamps it to the spec's stated default, where it discards a
malformed one. Faking the check with a runtime guard would be strictly worse than
saying so.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.select [ At.size 2.5 ] [ H.option [] [ H.text "x" ] ]
