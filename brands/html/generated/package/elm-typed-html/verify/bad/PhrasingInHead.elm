module PhrasingInHead exposing (broken)

{-| RC5: `<head>` admits the `@metadata` SET, and five of its members
(`link`, `meta`, `noscript`, `script`, `template`) are also flow AND phrasing
content per WHATWG. Had those five become category producers, `HeadContent`
would have collapsed to `sharedPhrasing` and `<head>` would admit every
phrasing element.

They keep their per-tag `Brand` kind instead, and the flow/phrasing rows name
them explicitly — so `@metadata` still resolves to exactly eight named tags.
MUST FAIL.

-}

import TypedHtml as H


broken =
    H.head [] [ H.button [] [ H.text "not metadata" ] ]
