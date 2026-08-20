module ValueOrdinalOnProgress exposing (broken)

{-| The two diverged rows are distinct from EACH OTHER as well. MUST FAIL.

`<li>`'s `value` is `attribute long value` (an ordinal) and `<progress>`'s is
`attribute double value` (a measurement). Both are numeric, so the tempting move is one
shared numeric row. It is wrong twice over:

  - The types differ. `<li>` wants `Int` and `<progress>` wants `Float`, and a shared
    name at one type would make the other element's setter a local, differently-typed
    one — with elm-cem publishing whichever type won on `TypedHtml.Attributes` and
    saying nothing. That is the `datetime` regression's exact shape (`<time>`'s `Float`
    outranked `<ins>`/`<del>`'s `String`, and the `String` side vanished silently), just
    below the threshold where `guardHomeAttrTypes` would refuse the run.
  - The homes differ. `<li>` is in `TypedHtml.Grouping` and `<meter>`/`<progress>` are
    in `TypedHtml.Text`, so nothing would even flag the collision at the module level.

Two names, two rows, and no choice left to get wrong. `At.valueOrdinal` is admitted by
`<li>` alone and `At.valueNumeric` by `<meter>` and `<progress>`; see
verify/src/Good.elm.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.progress [ At.valueOrdinal 3 ] []
