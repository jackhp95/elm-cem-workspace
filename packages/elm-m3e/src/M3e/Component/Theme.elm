module M3e.Component.Theme exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Contrast, contrast, Motion, motion, Scheme, scheme, Variant, variant
    , color, density, strongFocus, onChange
    , child
    )

{-| The `m3e-theme` component — strict per-component surface.

A non-visual element responsible for application-level theming.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Contrast, contrast, Motion, motion, Scheme, scheme, Variant, variant
@docs color, density, strongFocus, onChange
@docs child


## Examples


### Examples

<!-- elm-cem:example title="Color" -->
```elm
M3e.Component.Theme.component [ M3e.Component.Theme.color "#4285F4" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-grid" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch primary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Primary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-primary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Primary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch primary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Primary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-primary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Primary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch secondary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Secondary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-secondary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Secondary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch secondary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Secondary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-secondary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Secondary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch tertiary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Tertiary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-tertiary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Tertiary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch tertiary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Tertiary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-tertiary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Tertiary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch error" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Error" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-error" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Error" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch error-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Error Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-error-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Error Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch background" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Background" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-background" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Background" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-surface-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Surface Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch inverse-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Inverse Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch inverse-on-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Inverse On Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch outline" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Outline" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch outline-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Outline Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch shadow" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Shadow" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch scrim" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Scrim" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface-tint" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface Tint" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ] ] ]
```

<!-- elm-cem:example title="Schemes" -->
```elm
M3e.Component.Theme.component [ M3e.Component.Theme.color "#4285F4", M3e.Component.Theme.scheme M3e.Values.dark ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "dark-example" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-grid" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch primary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Primary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-primary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Primary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch primary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Primary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-primary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Primary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch secondary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Secondary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-secondary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Secondary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch secondary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Secondary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-secondary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Secondary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch tertiary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Tertiary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-tertiary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Tertiary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch tertiary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Tertiary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-tertiary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Tertiary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch error" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Error" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-error" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Error" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch error-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Error Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-error-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Error Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch background" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Background" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-background" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Background" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-surface-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Surface Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch inverse-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Inverse Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch inverse-on-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Inverse On Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch outline" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Outline" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch outline-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Outline Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch shadow" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Shadow" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch scrim" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Scrim" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface-tint" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface Tint" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ] ] ] ]
```

<!-- elm-cem:example title="Contrast" -->
```elm
M3e.Component.Theme.component [ M3e.Component.Theme.color "#4285F4", M3e.Component.Theme.contrast M3e.Values.high ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-grid" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch primary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Primary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-primary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Primary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch primary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Primary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-primary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Primary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch secondary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Secondary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-secondary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Secondary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch secondary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Secondary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-secondary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Secondary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch tertiary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Tertiary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-tertiary" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Tertiary" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch tertiary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Tertiary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-tertiary-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Tertiary Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch error" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Error" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-error" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Error" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch error-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Error Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-error-container" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Error Container" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch background" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Background" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-background" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Background" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch on-surface-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "On Surface Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch inverse-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Inverse Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch inverse-on-surface" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Inverse On Surface" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch outline" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Outline" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch outline-variant" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Outline Variant" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch shadow" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Shadow" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch scrim" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Scrim" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch surface-tint" ] [ TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-label" ] [ M3e.text "Surface Tint" ], TypedHtml.div [ TypedHtml.Unsafe.Attributes.customAttribute "class" "swatch-box" ] [] ] ] ]
```

<!-- elm-cem:example title="Density" -->
```elm
[ M3e.Component.Theme.component [ M3e.Component.Theme.strongFocus True, M3e.Component.Theme.density -3 ] [ M3e.Component.Button.component { content = M3e.text "-3 density", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled, M3e.Component.Button.size M3e.Values.medium ] [] ]
    , M3e.Component.Theme.component [ M3e.Component.Theme.strongFocus True, M3e.Component.Theme.density -2 ] [ M3e.Component.Button.component { content = M3e.text "-2 density", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled, M3e.Component.Button.size M3e.Values.medium ] [] ]
    , M3e.Component.Theme.component [ M3e.Component.Theme.strongFocus True, M3e.Component.Theme.density -1 ] [ M3e.Component.Button.component { content = M3e.text "-1 density", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled, M3e.Component.Button.size M3e.Values.medium ] [] ]
    , M3e.Component.Theme.component [ M3e.Component.Theme.strongFocus True, M3e.Component.Theme.density 0 ] [ M3e.Component.Button.component { content = M3e.text "0 (default) density", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled, M3e.Component.Button.size M3e.Values.medium ] [] ]
    , M3e.Component.Theme.component [ M3e.Component.Theme.strongFocus True, M3e.Component.Theme.density 1 ] [ M3e.Component.Button.component { content = M3e.text "1 density", action = M3e.Action.none } [ M3e.Component.Button.variant M3e.Values.filled, M3e.Component.Button.size M3e.Values.medium ] [] ]
    ]
```


### Motion

<!-- elm-cem:example title="Motion" -->
```elm
[ M3e.Component.Theme.component [ M3e.Component.Theme.strongFocus True, M3e.Component.Theme.motion M3e.Values.standard ] [ M3e.Unsafe.customElement "label" [] [ M3e.text "Standard", M3e.Component.Switch.component [] [] ] ]
    , M3e.Component.Theme.component [ M3e.Component.Theme.strongFocus True, M3e.Component.Theme.motion M3e.Values.expressive ] [ M3e.Unsafe.customElement "label" [] [ M3e.text "Expressive", M3e.Component.Switch.component [] [] ] ]
    ]
```

<!-- elm-cem:docmeta category=Layout & style -->

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Theme
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-theme` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Theme.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Theme.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Theme.ChildAdmittedBy childAdm


{-| The `contrast` values valid on this component (compile-tight narrowing).
-}
type alias Contrast =
    M3e.Internal.Types.Theme.Contrast


{-| The `motion` values valid on this component (compile-tight narrowing).
-}
type alias Motion =
    M3e.Internal.Types.Theme.Motion


{-| The `scheme` values valid on this component (compile-tight narrowing).
-}
type alias Scheme =
    M3e.Internal.Types.Theme.Scheme


{-| The `variant` values valid on this component (compile-tight narrowing).
-}
type alias Variant =
    M3e.Internal.Types.Theme.Variant


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.Theme.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.Theme.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`. The default slot is
kind-permissive (`any`): children of any kind compose, but each child's OWN
admittedBy must still admit this context — a restricted-parent element is
rejected here at compile time.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.theme


{-| The contrast level of the theme. (default: `"standard"`)
-}
contrast : Value Contrast -> Attr { c | contrast : Supported } msg
contrast value_ =
    Ir.attribute "contrast" (Val.toString value_)


{-| The motion scheme. (default: `"standard"`)
-}
motion : Value Motion -> Attr { c | motion : Supported } msg
motion value_ =
    Ir.attribute "motion" (Val.toString value_)


{-| The color scheme of the theme. (default: `"auto"`)
-}
scheme : Value Scheme -> Attr { c | scheme : Supported } msg
scheme value_ =
    Ir.attribute "scheme" (Val.toString value_)


{-| The color variant of the theme. (default: `"neutral"`)
-}
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (Val.toString value_)


{-| See `M3e.Attributes.color`.
-}
color : String -> Attr { c | color : Supported } msg
color =
    A.color


{-| See `M3e.Attributes.density`.
-}
density : Float -> Attr { c | density : Supported } msg
density =
    A.density


{-| See `M3e.Attributes.strongFocus`.
-}
strongFocus : Bool -> Attr { c | strongFocus : Supported } msg
strongFocus =
    A.strongFocus


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| Place a pre-built element into the default (unnamed) slot (input
constrained to the slot's kinds; output row free so it composes into the
child list). The list-form sibling of the builder's `withChild`.
-}
child : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
child element =
    Ir.fromNode (El.toNode element)
