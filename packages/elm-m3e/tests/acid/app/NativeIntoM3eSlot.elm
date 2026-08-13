module NativeIntoM3eSlot exposing (nativeWrapperInM3eSlot, sharedAtomsInNativePhrasing)

{-| POSITIVE probe — the RC5 content-vocabulary direction. This is the half of
the cross-library seam that USED to be rejected, so it is the probe that catches
a regeneration re-closing the shared rows.

`M3e.Component.AppBar.TrailingSlot` names the two WHATWG content categories
(`sharedFlow`, `sharedPhrasing`) alongside its brand kinds. `TypedHtml.div`
produces `DivIs s = { s | sharedFlow : Shared }`, from the same `HtmlIr.Kind`
substrate — so a native wrapper enters an M3e slot **as itself**, with no
`Unsafe.recast` and no coercion.

The second value pins the direction that has always worked: `M3e.text` and
`M3e.icon` are shared atoms (`sharedText` / `sharedIcon`), and
`TypedHtml.Text.SpanContent` names both, so they sit inside native phrasing
content directly. Compare `bad/M3eHeadingIntoNativeSpan.elm`, which pins that
a BRANDED M3e kind does not.

If either of these stops compiling, `/guide/seams` is claiming something the
types no longer back.

-}

import M3e
import M3e.Component.AppBar
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Text


nativeWrapperInM3eSlot : M3e.Element free freeAdmittedBy msg
nativeWrapperInM3eSlot =
    M3e.Component.AppBar.trailing
        (TypedHtml.div [ TypedHtml.Attributes.class "inline-flex items-center gap-1" ]
            [ M3e.iconButton [] [ M3e.icon [] [] ]
            , M3e.badge [] []
            ]
        )


sharedAtomsInNativePhrasing : M3e.Element (TypedHtml.Text.SpanIs s) admittedBy msg
sharedAtomsInNativePhrasing =
    TypedHtml.span []
        [ M3e.text "shared text atom"
        , M3e.icon [] []
        ]
