module M3eHeadingIntoNativeSpan exposing (broken)

{-| NEGATIVE probe — the documented ONE-WAY limit, pinned so nobody "fixes" it.

Native HTML goes INTO an M3e slot (see `app/NativeIntoM3eSlot.elm`). The
reverse does not, when the native container's content model is enumerated.
`TypedHtml.span` takes `List (Element SpanContent ...)` where `SpanContent` is
CLOSED over the HTML kinds only:

    { area, img, link, meta, noscript, script
    , sharedIcon, sharedPhrasing, sharedText, template
    }

`M3e.heading` produces `{ s | heading : Brand }` — the brand field that lets
`AppBar.title` tell a heading from a card. `SpanContent` has no name for it, so
this MUST FAIL.

This is a designed property, not a gap: erasing `heading` from the produced row
to let it into a `<span>` would also let a Card into a Menu. `/guide/seams`
states it and `/guide/troubleshooting` quotes the compiler error; if this probe
ever compiles, both pages became false.

The escape hatch is a flow container — `TypedHtml.div` takes any children —
which is why `app/NativeIntoM3eSlot.elm` uses `div`, not `span`.

-}

import M3e
import TypedHtml
import TypedHtml.Component.Text


broken : M3e.Element (TypedHtml.Component.Text.SpanIs s) admittedBy msg
broken =
    TypedHtml.span [] [ M3e.heading [] [ M3e.text "hi" ] ]
