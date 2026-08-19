module TrackInPicture exposing (broken)

{-| The R2 payoff: picture admits only pictureSource; track stays video-only.
MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Attributes as At


broken =
    H.picture [] [ H.track [ At.src "x.vtt" ] [] ]
