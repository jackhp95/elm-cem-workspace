module Theme.Sections.Shape exposing (view)

{-| The Shape accordion section: a Linear/Modular/Bump/Power scale-mode
segmented control, per-mode numeric steppers (shared with Typography via
`Theme.Sections.Shared`), and a static preview of the six named corner
sizes (`Theme.Tokens.shapeTokens` drives the live token surface via
`Theme.Ports`; this preview is intentionally fixed-class, matching the
reference site, rather than live-computed like Typography's).
-}

import M3e exposing (Element)
import Theme exposing (Msg(..))
import Theme.Sections.Shared as Shared
import TypedHtml
import TypedHtml.Attributes
import TypedHtml.Component.Grouping


view : Theme.Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
view model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-3" ]
        [ Shared.modeSegmented SetShapeScaleMode model.shapeScale.mode
        , Shared.stepperControls SetShapeScaleParam model.shapeScale
        , staticPreview
        ]


{-| Static preview — six swatches labeled None/XS/S/M/L/XL/Full-ish, matching
the reference site. Uses the real `rounded-md-corner-*` Tailwind utilities
generated from `tailwind-m3e-web/src/theme.css`'s `--radius-md-corner-*`
vars (NOT computed from `Theme.Scale`), per the spec's explicit "static
preview swatches ... no live-updating boxes" requirement — Shape's preview
is intentionally different from Typography's live-computed preview.
-}
staticPreview : Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
staticPreview =
    TypedHtml.div [ TypedHtml.Attributes.class "flex gap-2" ]
        [ swatchBox "rounded-md-corner-extra-small" "XS"
        , swatchBox "rounded-md-corner-small" "S"
        , swatchBox "rounded-md-corner-medium" "M"
        , swatchBox "rounded-md-corner-large" "L"
        , swatchBox "rounded-md-corner-extra-large" "XL"
        , swatchBox "rounded-md-corner-full" "Full"
        ]


swatchBox : String -> String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
swatchBox roundedClass labelText =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col items-center gap-1" ]
        [ TypedHtml.div [ TypedHtml.Attributes.class ("size-10 bg-primary " ++ roundedClass) ] []
        , M3e.text labelText
        ]
