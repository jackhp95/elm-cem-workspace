module ValueAsNumberOnProgress exposing (broken)

{-| A `_variants` setter follows its BASE off the element too. MUST FAIL.

`valueAsNumber` claims the `value` capability row (that is the whole point of a variant —
no element's `Attrs` record grows a field to hold one; see bad/ValueAsNumberOnDiv). So
when `<progress>` left the `value` row, it left `valueAsNumber` behind with it, and that
is correct rather than collateral damage: `valueAsNumber` would be a SECOND Float setter
beside the already-Float `valueNumeric`, claiming a row `<progress>` does not own.

The mechanism is that `_variants`' `base` names a SETTER, not a DOM attribute. `<progress>`
still declares the `value` HTML attribute — it just no longer calls its setter `value`, so
it is no longer part of that vocabulary. Keying on the DOM name instead put the variant on
every element declaring `value` and then let a `List.head` pick which of the several
capability rows it claimed; see `Emit.variantsFor` in elm-cem.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.progress [ At.valueAsNumber 0.6 ] []
