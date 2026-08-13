# Color & theming

## Color

M3E applies the [Material Design 3 color system](https://m3.material.io/styles/color/system/overview) allowing you to create accessible and personalized color schemes that cascade to every component.

### Design tokens

The [Material Design 3 design tokens](https://m3.material.io/foundations/design-tokens/overview) are implemented as custom CSS properties. Each token gives one visual decision—a color, type style, spacing step, or elevation level—a stable name, so the same value is defined once and reused consistently across platforms and components.

Color tokens are surfaced using the standardized prefix `--md-sys-color-*` supporting use of the [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/).

### Static color

Static colors refer to predefined, spec-aligned colors that do not automatically adapt to system settings. The `--md-sys-color-*` custom CSS properties default to the **baseline** values for light mode.

### Dynamic color

Dynamic color refers to runtime-generated color schemes derived from a single source color, allowing personalized theming that adapts to system settings.

M3E provides the [Theme](../components/theme.md) component which applies dynamic color, expressive motion, density, and strong focus indicators to nested, theme-aware elements. This component leverages the `@material/material-color-utilities` library to generate light and dark variants based on the content strategy—mapping perceptually tuned tones to standard Material Design 3 roles like _primary_, _surface_, and _outline_.

### Forced colors

M3E honors `forced-colors` mode by dynamically adapting component styles to ensure legibility, contrast, and semantic clarity in high-contrast environments.

---
_Source: [`docs/styles/color.html`](https://github.com/matraic/m3e/blob/v2.7.3/docs/styles/color.html) · `matraic/m3e` @ `v2.7.3`._
