# theme

**Family:** [System](../concepts/choosing-components.md#system)

The `m3e-theme` component is a non-visual element used to apply dynamic color, expressive motion, density, and strong focus indicators to nested, theme-aware elements. When `m3e-theme` is nested directly beneath the `<body>` of a document, the `<body>`'s `background-color` is set to the computed value of `--md-sys-color-background` and `color` is set to the computed value of `--md-sys-color-on-background`. In addition the document's `scrollbar-color` is set to the computed values of `--m3e-scrollbar-thumb-color` and `--m3e-scrollbar-track-color` which, when supported, cascades to all viewport scrollbars.

```ts
import "@m3e/web/theme";
```

**Elements:** `<m3e-theme>`, `<m3e-theme-icon>`

## Examples

```html
<body>
  <m3e-theme color="#6750A4" scheme="auto" motion="expressive" strong-focus>
    <!-- App content here -->
  </m3e-theme>
</body>
```

```html
<m3e-theme-icon color="#004f4f" scheme="light"></m3e-theme-icon>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Theme with drawer, nav menu, and app bar shell**

```html
<m3e-theme color="#8B6F47" scheme="auto" contrast="standard" motion="expressive" strong-focus>
  <m3e-drawer-container start-mode="over">
    <nav slot="start">
      <m3e-nav-menu>
        <a href="/photos">
          <m3e-nav-menu-item selected>
            <m3e-icon slot="icon" name="photo_library"></m3e-icon>
            <span slot="label">Photos</span>
          </m3e-nav-menu-item>
        </a>
      </m3e-nav-menu>
    </nav>
    <m3e-app-bar>
      <m3e-icon-button slot="leading" aria-label="Back">
        <m3e-icon name="arrow_back"></m3e-icon>
      </m3e-icon-button>
      <span slot="title">Title</span>
    </m3e-app-bar>
  </m3e-drawer-container>
</m3e-theme>
```

_Source: kinfolk: src/layouts/Layout.astro_

## API

### `<m3e-theme>`

A non-visual element responsible for application-level theming.

**Display:** `contents`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `string` | "#6750A4" | The hex color from which to derive dynamic color palettes. |
| `contrast` | `"high" \| "medium" \| "standard"` | "standard" | The contrast level of the theme. |
| `density` | `number` | 0 | The density scale (0, -1, -2). |
| `scheme` | `"light" \| "dark" \| "auto"` | "auto" | The color scheme of the theme. |
| `strong-focus` | `boolean` | false | Whether to enable strong focus indicators. |
| `variant` | `"monochrome" \| "neutral" \| "tonal-spot" \| "vibrant" \| "expressive" \| "fidelity" \| "content" \| "rainbow" \| "fruit-salad"` | "neutral" | The color variant of the theme. |
| `motion` | `"standard" \| "expressive"` | "standard" | The motion scheme. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `isDark` _(readonly)_ | `boolean` | Whether a dark theme is applied. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders content styled by the theme. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the theme changes. |

### `<m3e-theme-icon>`

An icon that visually presents a preview of a theme.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `color` | `string` | "#6750A4" | The hex color of the theme to preview |
| `scheme` | `"light" \| "dark" \| "auto"` | "auto" | The color scheme of the theme. |
| `variant` | `"monochrome" \| "neutral" \| "tonal-spot" \| "vibrant" \| "expressive" \| "fidelity" \| "content" \| "rainbow" \| "fruit-salad"` | "neutral" | The color variant of the theme. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `isDark` _(readonly)_ | `boolean` | Whether a dark theme is applied. |

**CSS custom properties** — 6 total across 6 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-theme-icon-size` | Size of the theme icon. |
| `--m3e-theme-icon-shape` | Border radius of the icon container. |
| `--m3e-theme-icon-outline-color` | Outline stroke color of the icon border. |
| `--m3e-theme-icon-outline-opacity` | Opacity percentage applied to the outline color. |
| `--m3e-theme-icon-container-color` | Fill color for the container layer of the previewed theme. |
| `--m3e-theme-icon-color` | Fill color for the primary layer of the previewed theme. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/theme/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/theme/ThemeElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/theme/ThemeElement.ts)
- [`packages/web/src/theme/ThemeIconElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/theme/ThemeIconElement.ts)

**README drift corrected** (2 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
