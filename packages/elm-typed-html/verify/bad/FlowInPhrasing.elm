module FlowInPhrasing exposing (broken)

{-| RC5: collapsing the enumerated `*Content` rows to shared content CATEGORIES
must not collapse the flow/phrasing distinction with them.

`p` is a `shared:flow` producer; `span`'s content row names `sharedPhrasing`
(plus `sharedText`/`sharedIcon` and the seven tags that keep per-tag identity)
but NOT `sharedFlow`. So a paragraph inside a span is still rejected — the row
is 10 fields instead of 55, and says the same thing. MUST FAIL.

-}

import TypedHtml as H


broken =
    H.span [] [ H.p [] [ H.text "block inside inline" ] ]
