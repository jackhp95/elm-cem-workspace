module PhrasingInPicture exposing (broken)

{-| RC5: `img` and `area` deliberately KEEP their per-tag `Brand` kind rather
than becoming category producers, precisely so `<picture>` and `<map>` stay
exact. `PictureContent` is still `{ img, pictureSource }`.

If `img` had been folded into `shared:phrasing`, `PictureContent` would have had
to name the category, and every phrasing element — this button included — would
have become a legal child of `<picture>`. MUST FAIL.

-}

import TypedHtml as H


broken =
    H.picture [] [ H.button [] [ H.text "not a source" ] ]
