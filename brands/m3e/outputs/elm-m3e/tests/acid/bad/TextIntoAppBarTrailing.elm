module TextIntoAppBarTrailing exposing (broken)

{-| NEGATIVE probe — slot kind admittance, SHARED kind. The RC5 guard.

RC5 taught `"html"`-ish M3e slots to speak the shared content vocabulary. The
invariant it must NOT have cost is that each slot still names its OWN set:
`AppBar.TitleSlot` names `sharedText`, `AppBar.TrailingSlot` does not.

    TitleSlot    = { heading, sharedFlow, sharedPhrasing, sharedText }
    TrailingSlot = { button, iconButton, searchBar, sharedFlow, sharedPhrasing }

`M3e.text` produces `{ s | sharedText : Shared }`, so this MUST FAIL. A
regeneration that reflexively sprinkled every shared kind onto every opted-in
slot — the cheap way to "make html slots work" — would make it compile.

`app/Good.elm` puts the same `M3e.text` straight into `subtitle`, which does
name `sharedText` — as does `title`.

-}

import M3e
import M3e.Component.AppBar


broken : M3e.Element free freeAdmittedBy msg
broken =
    M3e.Component.AppBar.trailing (M3e.text "3")
