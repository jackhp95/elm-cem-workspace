module ValueOnLi exposing (broken)

{-| The SILENT half of the same bug, also made a compile error. MUST FAIL.

`HTMLLIElement.value` is `attribute long value` — the item's ordinal position. A `long`
runs Web IDL's default `unsigned`/ToInt32 conversion rather than the restricted-double
one, so it does not throw:

    li.value = "abc"  -->  OK, and li.value is now 0

That is worse in one respect and better in another. Better: it cannot spin the render
loop the way `<progress>` does (see bad/ValueOnProgress). Worse: nothing anywhere reports
it. The list silently renumbers from 0 and the only symptom is wrong output.

`<li>` therefore leaves the `value` capability row too, and takes the type its value
space actually has: `LiAttrs` carries `valueOrdinal : Supported`, and
`TypedHtml.Attributes.valueOrdinal` is `Int -> Attr …`. `Int` rather than `Float`
because "list item 3.5" is not a thing, and `String.fromInt` makes a non-integer
ordinal unconstructible.

The correct call is in verify/src/Good.elm: `At.valueOrdinal 3`.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.ul [] [ H.li [ At.value "abc" ] [] ]
