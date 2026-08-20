module AttackForge exposing (smuggled)

{-| HONEST-DANGER CASE — this MUST COMPILE, and that is the point: the fence is
lint-only. Userland that imports `HtmlIr.Internal` can smuggle a raw `<script>`
into a slot typed to admit only shared text and m3e icons. The
`NoInternalImportOutsideAllowed` elm-review rule is what forbids this import;
the compiler cannot.
-}

import Html
import HtmlIr.Internal as I
import MiniM3e as M


smuggled =
    M.button []
        [ I.fromNode (I.fromHtml (Html.node "script" [] [ Html.text "alert('pwn')" ])) ]
