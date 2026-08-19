module ValueNumericOnInput exposing (broken)

{-| The divergence is SYMMETRIC, not a one-way escape hatch. MUST FAIL.

`valueNumeric` is not "a numeric spelling of `value` that happens to live next to it" —
it is a different capability, claimed by the two elements whose `value` is an IDL
`double` (`<meter>`, `<progress>`) and by nothing else. `<input>` has a `value` field in
its `Attrs` row and no `valueNumeric` field, so this does not compile.

That matters because the alternative — one row, two setters — is exactly what would let
the crash back in. If `valueNumeric` shared the `value` row to be "convenient", then
`<progress>` would still admit `value` and bad/ValueOnProgress would compile again. The
row is the guarantee; a setter that widened it would dissolve the guarantee.

The numeric spelling `<input>` DOES have is `valueAsNumber`, which is a `_variants`
entry and therefore deliberately DOES share the `value` row — it writes the same fact
through the same property, mirroring `HTMLInputElement.valueAsNumber`. See
verify/src/Good.elm.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.input [ At.type_ "number", At.valueNumeric 2.5 ] []
