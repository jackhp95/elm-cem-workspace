module ColspanFloat exposing (broken)

{-| The headline case of the Float-for-integer bug, pinned. MUST FAIL.

`colspan` is "Valid non-negative integer greater than zero" per WHATWG. The manifest
typed it `number`, so elm-cem emitted `colspan : Float -> Attr …` and serialized it
with `String.fromFloat` — and `String.fromFloat 2.5 == "2.5"`, which HTML's "rules for
parsing non-negative integers" reject on the `.`.

A rejected attribute value is not an IGNORED one. The parse fails, so the attribute is
treated as absent and the element takes `colspan`'s default of 1: this cell spans ONE
column, the header row and the body rows disagree about their column count, and
nothing anywhere says so. The author asked for two-and-a-half columns — nonsense — and
got one, not an error.

Eleven attributes shipped that way (`colspan`, `rowspan`, `rows`, `cols`, `size`,
`span`, `start`, `maxlength`, `minlength`, `width`, `height`), over 31
element/attribute pairs. `elm/html` types every one of them `Int`.

The fix is a CEM type spelling, not 31 config overrides: `Attr.classifyText` learned
`"integer"` → `AInt`, and the manifest says `integer` where the WHATWG value column
says integer. `native-manifest-gen` already derived that distinction from the spec
index and its `typeText` was throwing it away.

The correct call is in verify/src/Good.elm: `At.colspan 3`, and `At.rowspan 0` — which
is legal, and is why `rowspan` is "non-negative integer" while `colspan` is "greater
than zero". Do not unify them.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.table [] [ H.tbody [] [ H.tr [] [ H.td [ At.colspan 2.5 ] [ H.text "wide" ] ] ] ]
