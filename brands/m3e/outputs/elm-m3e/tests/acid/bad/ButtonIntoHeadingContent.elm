module ButtonIntoHeadingContent exposing (broken)

{-| NEGATIVE probe — a restrictive DEFAULT slot rejects a foreign brand kind.

The `AppBarTrailing` probes narrow through a named-slot function. This one
narrows through the DEFAULT child list, which is a separate code path in the
generator: `M3e.heading` is typed

    List (Attr Attrs msg)
    -> List (Element M3e.Component.Heading.Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg

and `Content` is the closed row `{ heading : Brand, sharedText : Shared }`.
`M3e.button` produces `{ s | button : Brand }`, so this MUST FAIL.

`docs/composition.md` §1 shows exactly this pair — `M3e.heading [] [ M3e.text
"Just text" ]` compiles, `M3e.heading [] [ M3e.button ... ]` does not — as the
proof that permissive slots being permissive is a feature rather than a hole.
The claim needs a probe behind it.

-}

import M3e
import M3e.Component.Heading


broken : M3e.Element (M3e.Component.Heading.Is s) admittedBy msg
broken =
    M3e.heading [] [ M3e.button [] [ M3e.text "no" ] ]
