# Density

Density refers to the spatial compactness of UI elements—how tightly components are arranged, how much padding surrounds them, and how much content fits within a given layout. M3E applies the [Material Design 3 density system](https://m3.material.io/foundations/layout/understanding-layout/density) to adapt component layout, spacing, and touch targets across varied contexts—from spacious, touch-friendly surfaces to compact, information-dense environments.

### Design tokens

The [Material Design 3 design tokens](https://m3.material.io/foundations/design-tokens/overview) are implemented as custom CSS properties. Each token gives one visual decision—a color, type style, spacing step, or elevation level—a stable name, so the same value is defined once and reused consistently across platforms and components.

Density tokens are surfaced using the standardized `--md-sys-density-scale` and `--md-sys-density-size` custom CSS properties. M3E provides the [Theme](../components/theme.md) component which can be used to systematically control `--md-sys-density-scale` using its `density` attribute.

### Density-aware components

The following components support density scaling: `autocomplete`, `breadcrumb`, `button-group`, `button`, `checkbox`, `chips`, `fab`, `form-field`, `icon button`, `list`, `menu`, `nav menu`, `paginator`, `radio-group`, `segmented button`, `select`, `split-button`, `switch`, `tabs`, `toolbar`, and `tree`. Each component adapts its layout, spacing, and touch targets based on the active density scale. Refer to the component's documentation for usage examples.

### Touch surfaces

Touch surfaces maintain a minimum size of `48dp x 48dp`, ensuring accessible, tap-friendly targets across all density settings. This threshold aligns with Material Design 3 guidelines and is enforced even in compact layouts, preserving interaction clarity and usability for both mouse and touch input.

---
_Source: [`docs/styles/density.html`](https://github.com/matraic/m3e/blob/v2.7.3/docs/styles/density.html) · `matraic/m3e` @ `v2.7.3`._
