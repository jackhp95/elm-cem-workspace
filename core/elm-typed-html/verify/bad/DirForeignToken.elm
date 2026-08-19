module DirForeignToken exposing (broken)

{-| An enum GLOBAL's row is CLOSED to its own tokens, exactly like a per-element
enum attribute's: `dir` admits `ltr` / `rtl` / `auto`, so a token minted for a
different attribute is rejected. MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Attributes as At
import TypedHtml.Values as V


broken =
    H.span [ At.dir V.numeric ] [ H.text "x" ]
