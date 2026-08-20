module HtmlIr.Value exposing
    ( Value
    , toString
    )

{-| The phantom-tagged enum token shared by every library on this substrate. A
`Value tags` is a string carrying a phantom row of the enum tags it represents;
token producers keep the row open (`{ v | filled : Supported }`) and each typed
setter closes it to the values its attribute admits, so the compiler rejects an
invalid enum value. General setters may close over the **union** of a brand's
values (narrowed per-component setters close tighter — same token, both ways).

Minting a `Value` — which asserts its row — happens only in brand token
definitions or the fenced forge in [`HtmlIr.Internal`](HtmlIr-Internal).

@docs Value
@docs toString

-}

import HtmlIr.Internal as I


{-| The opaque phantom-tagged string token.
-}
type alias Value tags =
    I.Value tags


{-| The token's underlying string — the safe out-bound direction.
-}
toString : Value tags -> String
toString =
    I.toString
