module Acceptance exposing (a, b, c, d)

{-| Acceptance: the brand barrel now re-exports the IR types + msg-map, so this
compiles WITHOUT importing HtmlIr.\* at all — using only `TypedHtml`,
`TypedHtml.Unsafe`, `TypedHtml.Unsafe.Attributes`.
-}

import Html.Attributes
import TypedHtml as H
import TypedHtml.Unsafe as Unsafe
import TypedHtml.Unsafe.Attributes as UnsafeAttr


type Msg
    = Msg


{-| `TypedHtml.Element` alias in an annotation + `TypedHtml.Unsafe.recast`.
-}
a : H.Element {} {} Msg
a =
    Unsafe.recast (H.div [] [ H.text "x" ])


{-| `TypedHtml.mapMsg`.
-}
b : H.Element {} {} Msg
b =
    H.mapMsg identity a


{-| `TypedHtml.Unsafe.recastAll`.
-}
c : List (H.Element {} {} Msg)
c =
    Unsafe.recastAll [ H.span [] [] ]


{-| `TypedHtml.Attr` alias + `Unsafe.Attributes.recastAttr` / `fromHtmlAttribute`.
-}
d : H.Attr {} Msg
d =
    UnsafeAttr.recastAttr (UnsafeAttr.fromHtmlAttribute (Html.Attributes.class "y"))
