module BadgeAttrOnAppBar exposing (broken)

{-| NEGATIVE probe — the ATTRIBUTE capability row, a different mechanism from
the kind rows the other probes exercise.

`M3e.appBar` takes `List (Attr M3e.Element.AppBar.Attrs msg)` where `Attrs` is closed:

    { centered, class, for, id, size, slot, style }

`M3e.Element.Badge.position` produces `Attr { c | position : Supported } msg`. `position`
is not an AppBar attribute, so this MUST FAIL.

Note the near miss that makes this probe worth having: AppBar and Badge SHARE
`size` and `for`, so a generator that widened attribute rows by union rather
than per-component would still pass a laxer test. `position` is Badge-only.

-}

import M3e
import M3e.Element.AppBar
import M3e.Element.Badge
import M3e.Values


broken : M3e.Element (M3e.Element.AppBar.Is s) admittedBy msg
broken =
    M3e.appBar [ M3e.Element.Badge.position M3e.Values.above ] []
