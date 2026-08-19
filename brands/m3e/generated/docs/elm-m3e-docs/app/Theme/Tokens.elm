module Theme.Tokens exposing
    ( ColorToken
    , MotionDurationToken
    , ShapeToken
    , StateOpacityToken
    , TypescaleToken
    , colorGroups
    , motionDurationTokens
    , shapeTokens
    , stateOpacityTokens
    , typescaleTokens
    )

{-| The `--md-sys-*` custom-property surface this editor exposes, read
directly off `tailwind-m3e-web/src/sys/*.css` (the actual `@m3e/web` token
source — NOT the reference site's smaller set).
-}


{-| A single color-role override row: `role` is the human label, `cssVar` is
the property name WITHOUT the `--` prefix (Theme.Ports adds it).
-}
type alias ColorToken =
    { role : String, cssVar : String }


colorGroups : List ( String, List ColorToken )
colorGroups =
    [ ( "Primary"
      , [ ColorToken "Primary" "md-sys-color-primary"
        , ColorToken "On Primary" "md-sys-color-on-primary"
        , ColorToken "Primary Container" "md-sys-color-primary-container"
        , ColorToken "On Primary Container" "md-sys-color-on-primary-container"
        ]
      )
    , ( "Secondary"
      , [ ColorToken "Secondary" "md-sys-color-secondary"
        , ColorToken "On Secondary" "md-sys-color-on-secondary"
        , ColorToken "Secondary Container" "md-sys-color-secondary-container"
        , ColorToken "On Secondary Container" "md-sys-color-on-secondary-container"
        ]
      )
    , ( "Tertiary"
      , [ ColorToken "Tertiary" "md-sys-color-tertiary"
        , ColorToken "On Tertiary" "md-sys-color-on-tertiary"
        , ColorToken "Tertiary Container" "md-sys-color-tertiary-container"
        , ColorToken "On Tertiary Container" "md-sys-color-on-tertiary-container"
        ]
      )
    , ( "Error"
      , [ ColorToken "Error" "md-sys-color-error"
        , ColorToken "On Error" "md-sys-color-on-error"
        , ColorToken "Error Container" "md-sys-color-error-container"
        , ColorToken "On Error Container" "md-sys-color-on-error-container"
        ]
      )
    , ( "Surface"
      , [ ColorToken "Surface" "md-sys-color-surface"
        , ColorToken "On Surface" "md-sys-color-on-surface"
        , ColorToken "Surface Variant" "md-sys-color-surface-variant"
        , ColorToken "On Surface Variant" "md-sys-color-on-surface-variant"
        , ColorToken "Surface Dim" "md-sys-color-surface-dim"
        , ColorToken "Surface Bright" "md-sys-color-surface-bright"
        , ColorToken "Surface Tint" "md-sys-color-surface-tint"
        , ColorToken "Surface Container Lowest" "md-sys-color-surface-container-lowest"
        , ColorToken "Surface Container Low" "md-sys-color-surface-container-low"
        , ColorToken "Surface Container" "md-sys-color-surface-container"
        , ColorToken "Surface Container High" "md-sys-color-surface-container-high"
        , ColorToken "Surface Container Highest" "md-sys-color-surface-container-highest"
        ]
      )
    , ( "Outline"
      , [ ColorToken "Outline" "md-sys-color-outline"
        , ColorToken "Outline Variant" "md-sys-color-outline-variant"
        ]
      )
    , ( "Inverse"
      , [ ColorToken "Inverse Surface" "md-sys-color-inverse-surface"
        , ColorToken "Inverse On Surface" "md-sys-color-inverse-on-surface"
        , ColorToken "Inverse Primary" "md-sys-color-inverse-primary"
        ]
      )
    , ( "Background"
      , [ ColorToken "Background" "md-sys-color-background"
        , ColorToken "On Background" "md-sys-color-on-background"
        ]
      )
    , ( "Shadow / Scrim"
      , [ ColorToken "Shadow" "md-sys-color-shadow"
        , ColorToken "Scrim" "md-sys-color-scrim"
        ]
      )
    ]


{-| Canonical shape corner-value tokens (9). Directional/role aliases in
`shape.css` (`--md-sys-shape-corner-large-top`, etc.) reference these via
`var(...)`, so overriding just these 9 cascades correctly — no need to
override the aliases too. `step` is this token's position on the modular
scale used by `Theme.Scale` (a later task) — assign steps -4..4 across the 9
tokens in ascending `defaultRem` order (None=-4, Extra Small=-3, Small=-2,
Medium=-1, Large=0, Large Increased=1, Extra Large=2, Extra Large Increased=3,
Extra Extra Large=4).
-}
type alias ShapeToken =
    { label : String, cssVar : String, defaultRem : Float, step : Int }


shapeTokens : List ShapeToken
shapeTokens =
    [ ShapeToken "None" "md-sys-shape-corner-value-none" 0 -4
    , ShapeToken "Extra Small" "md-sys-shape-corner-value-extra-small" 0.25 -3
    , ShapeToken "Small" "md-sys-shape-corner-value-small" 0.5 -2
    , ShapeToken "Medium" "md-sys-shape-corner-value-medium" 0.75 -1
    , ShapeToken "Large" "md-sys-shape-corner-value-large" 1 0
    , ShapeToken "Large Increased" "md-sys-shape-corner-value-large-increased" 1.25 1
    , ShapeToken "Extra Large" "md-sys-shape-corner-value-extra-large" 1.75 2
    , ShapeToken "Extra Large Increased" "md-sys-shape-corner-value-extra-large-increased" 2 3
    , ShapeToken "Extra Extra Large" "md-sys-shape-corner-value-extra-extra-large" 3 4
    ]


{-| The 15 STANDARD-variant `font-size` tokens (deliberately scope-narrowed
from this repo's real 120-token typescale surface — 2 variants [standard,
emphasized] x 5 roles x 3 sizes x 4 axes [font-size, font-weight,
line-height, tracking] — matching the reference editor's 15-token scope,
which only ever manipulates font-size). `step` is this token's position on
the modular scale, NOT a uniform +1 per row — it is assigned by rank-ordering
the _unique_ `defaultRem` values across all 15 tokens in ascending order and
giving each successive unique rem value the next integer step (anchored so
`Body Large`, 1rem, the M3 baseline body-text size, lands on step 0). Several
tokens share the same `defaultRem` (e.g. `Label Medium`/`Body Small` are both
0.75rem; `Body Medium`/`Title Small`/`Label Large` are all 0.875rem;
`Body Large`/`Title Medium` are both 1rem), and same-rem tokens share the
same step — that's why the step sequence repeats values and skips others
rather than incrementing by 1 every row (e.g. `Title Small` is step -4 while
the very next row, `Body Large`, is step 0; `Display Medium` is step 6 while
`Display Large` is step 8, skipping 7). Full label -> step mapping, in
ascending `defaultRem` order: Label Small=-6, Label Medium=-5, Body Small=-5,
Label Large=-4, Body Medium=-4, Title Small=-4, Body Large=0, Title Medium=0,
Title Large=1, Headline Small=2, Headline Medium=3, Headline Large=4,
Display Small=5, Display Medium=6, Display Large=8.
-}
type alias TypescaleToken =
    { label : String, cssVar : String, defaultRem : Float, step : Int }


typescaleTokens : List TypescaleToken
typescaleTokens =
    [ TypescaleToken "Label Small" "md-sys-typescale-label-small-font-size" 0.6875 -6
    , TypescaleToken "Label Medium" "md-sys-typescale-label-medium-font-size" 0.75 -5
    , TypescaleToken "Body Small" "md-sys-typescale-body-small-font-size" 0.75 -5
    , TypescaleToken "Label Large" "md-sys-typescale-label-large-font-size" 0.875 -4
    , TypescaleToken "Body Medium" "md-sys-typescale-body-medium-font-size" 0.875 -4
    , TypescaleToken "Title Small" "md-sys-typescale-title-small-font-size" 0.875 -4
    , TypescaleToken "Body Large" "md-sys-typescale-body-large-font-size" 1 0
    , TypescaleToken "Title Medium" "md-sys-typescale-title-medium-font-size" 1 0
    , TypescaleToken "Title Large" "md-sys-typescale-title-large-font-size" 1.375 1
    , TypescaleToken "Headline Small" "md-sys-typescale-headline-small-font-size" 1.5 2
    , TypescaleToken "Headline Medium" "md-sys-typescale-headline-medium-font-size" 1.75 3
    , TypescaleToken "Headline Large" "md-sys-typescale-headline-large-font-size" 2 4
    , TypescaleToken "Display Small" "md-sys-typescale-display-small-font-size" 2.25 5
    , TypescaleToken "Display Medium" "md-sys-typescale-display-medium-font-size" 2.8125 6
    , TypescaleToken "Display Large" "md-sys-typescale-display-large-font-size" 3.5625 8
    ]


type alias MotionDurationToken =
    { label : String, cssVar : String, defaultMs : Int }


motionDurationTokens : List MotionDurationToken
motionDurationTokens =
    [ MotionDurationToken "Short 1" "md-sys-motion-duration-short-1" 50
    , MotionDurationToken "Short 2" "md-sys-motion-duration-short-2" 100
    , MotionDurationToken "Short 3" "md-sys-motion-duration-short-3" 150
    , MotionDurationToken "Short 4" "md-sys-motion-duration-short-4" 200
    , MotionDurationToken "Medium 1" "md-sys-motion-duration-medium-1" 250
    , MotionDurationToken "Medium 2" "md-sys-motion-duration-medium-2" 300
    , MotionDurationToken "Medium 3" "md-sys-motion-duration-medium-3" 350
    , MotionDurationToken "Medium 4" "md-sys-motion-duration-medium-4" 400
    , MotionDurationToken "Long 1" "md-sys-motion-duration-long-1" 450
    , MotionDurationToken "Long 2" "md-sys-motion-duration-long-2" 500
    , MotionDurationToken "Long 3" "md-sys-motion-duration-long-3" 550
    , MotionDurationToken "Long 4" "md-sys-motion-duration-long-4" 600
    , MotionDurationToken "Extra Long 1" "md-sys-motion-duration-extra-long-1" 700
    , MotionDurationToken "Extra Long 2" "md-sys-motion-duration-extra-long-2" 800
    , MotionDurationToken "Extra Long 3" "md-sys-motion-duration-extra-long-3" 900
    , MotionDurationToken "Extra Long 4" "md-sys-motion-duration-extra-long-4" 1000
    ]


type alias StateOpacityToken =
    { label : String, cssVar : String, defaultPercent : Int }


stateOpacityTokens : List StateOpacityToken
stateOpacityTokens =
    [ StateOpacityToken "Focus" "md-sys-state-focus-state-layer-opacity" 10
    , StateOpacityToken "Hover" "md-sys-state-hover-state-layer-opacity" 8
    , StateOpacityToken "Pressed" "md-sys-state-pressed-state-layer-opacity" 10
    ]
