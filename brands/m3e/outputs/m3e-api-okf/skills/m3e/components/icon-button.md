# icon-button

**Family:** [Actions & buttons](../concepts/choosing-components.md#actions) · See also: [button](button.md), [fab](fab.md), [fab-menu](fab-menu.md), [split-button](split-button.md), [button-group](button-group.md), [segmented-button](segmented-button.md)

The `m3e-icon-button` component is a semantic, expressive UI primitive for triggering actions with a single icon. Designed according to Material Design 3 guidelines, it supports four visual variants, specified using the `variant` attribute—`filled`, `tonal`, `outlined`, and `standard`—each with dynamic elevation, shape morphing, and adaptive color theming. The component responds to interaction states (hover, focus, press, disabled) with smooth motion transitions, ensuring emotional clarity and visual hierarchy. The component is accessible by default, with ARIA roles, contrast-safe color tokens, and strong focus indicators. It supports optional icons and states for binary actions. When using `m3e-icon` for icons, `filled` is automatically set based on the selected state of a toggle button. It can also function as a link or be used to submit form data. Native disabled `<button>` elements cannot receive focus. This can be problematic in some cases because it can prevent you from telling the user why the button is disabled. You can use the `disabled-interactive` attribute to style a `m3e-icon-button` as disabled but allow for it to receive focus. The button will have `aria-disabled="true"` for assistive technology.

```ts
import "@m3e/web/icon-button";
```

## Examples

```html
<m3e-icon-button variant="filled" size="large" toggle selected>
  <m3e-icon name="favorite"></m3e-icon>
</m3e-icon-button>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Icon button wrapping an icon**

```html
<m3e-icon-button aria-label="Toggle theme">
  <m3e-icon name="dark_mode"></m3e-icon>
</m3e-icon-button>
```

_Source: 2026: src/pages/speed-reader.astro_

**Link icon buttons in a toolbar**

```html
<div>
  <m3e-icon-button href="/rss.xml" aria-label="RSS Feed">
    <m3e-icon name="rss_feed"></m3e-icon>
  </m3e-icon-button>
  <m3e-icon-button href="/feed.json" aria-label="JSON Feed">
    <m3e-icon name="data_object"></m3e-icon>
  </m3e-icon-button>
</div>
```

_Source: 2026: src/components/NavFab.astro_

**Icon buttons grouped in a media control bar**

```html
<m3e-icon-button aria-label="Previous">
  <m3e-icon name="skip_previous"></m3e-icon>
</m3e-icon-button>
<m3e-icon-button aria-label="Play/Pause">
  <m3e-icon name="play_arrow"></m3e-icon>
</m3e-icon-button>
```

_Source: kinfolk: src/pages/slideshow.astro_

## API

### `<m3e-icon-button>`

An icon button users interact with to perform a supplementary action.

**Display:** `inline-block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `disabled-interactive` | `boolean` | false | Whether the element is disabled and interactive. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `href` | `string` | "" | The URL to which the link button points. |
| `name` |  |  | The name of the element, submitted as a pair with the element's `value` as part of form data, when the element is used to submit a form. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `selected` | `boolean` | false | Whether the toggle button is selected. |
| `shape` | `"rounded" \| "square"` | "rounded" | The shape of the button. |
| `size` | `"extra-small" \| "small" \| "medium" \| "large" \| "extra-large"` | "small" | The size of the button. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |
| `toggle` | `boolean` | false | Whether the button will toggle between selected and unselected states. |
| `type` | `"button" \| "submit" \| "reset"` | "button" | The type of the element. |
| `value` |  |  | The value associated with the element's name when it's submitted with form data. |
| `variant` | `"filled" \| "tonal" \| "outlined" \| "standard"` | "standard" | The appearance variant of the button. |
| `width` | `"default" \| "narrow" \| "wide"` | "default" | The width of the button. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `grouped` _(readonly)_ |  | Whether the button is contained by a button group. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the icon of the button. |
| `selected` | Renders an icon, when selected. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before a toggle button's selected state changes. |
| `input` | `Event` | Dispatched when a toggle button's selected state changes. |
| `change` | `Event` | Dispatched when a toggle button's selected state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 250 total across 128 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-icon-button-container-height` | Height of the container for all size variants. |
| `--m3e-icon-button-outline-thickness` | Outline thickness for all size variants. |
| `--m3e-icon-button-icon-size` | Icon size for all size variants. |
| `--m3e-icon-button-shape-round` | Corner radius for all round size variants. |
| `--m3e-icon-button-shape-square` | Corner radius for all square size variants. |
| `--m3e-icon-button-selected-shape-round` | Corner radius for all selected round size variants. |
| `--m3e-icon-button-selected-shape-square` | Corner radius for all selected square size variants. |
| `--m3e-icon-button-shape-pressed-morph` | Corner radius for all pressed size variants. |
| `--m3e-icon-button-narrow-leading-space` | Leading space for all size variants (narrow). |
| `--m3e-icon-button-narrow-trailing-space` | Trailing space for all size variants (narrow). |
| `--m3e-icon-button-default-leading-space` | Leading space for all size variants (default). |
| `--m3e-icon-button-default-trailing-space` | Trailing space for all size variants (default). |

_…116 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/icon-button/README.md) (MIT). · Material spec: <https://m3.material.io/components/icon-buttons/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/icon-button/IconButtonElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/icon-button/IconButtonElement.ts)

**README drift corrected** (3 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
