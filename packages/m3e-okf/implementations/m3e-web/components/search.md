# search

**Family:** [Text input & forms](../concepts/choosing-components.md#text-inputs) · See also: [form-field](form-field.md), [select](select.md), [autocomplete](autocomplete.md), [textarea-autosize](textarea-autosize.md), [option](option.md)

The `m3e-search-bar` and `m3e-search-view` components provide a Material 3 expressive search experience. The search bar offers a prominent entry point for text input, while the search view presents suggestions, history, and results in contained, docked, or full screen configurations. Both components support ARIA accessibility, keyboard interaction, and theming via CSS custom properties.

```ts
import "@m3e/web/search";
```

**Elements:** `<m3e-search-bar>`, `<m3e-search-view>`

## Examples

```html
<m3e-search-bar clearable>
  <m3e-icon name="search" slot="leading"></m3e-icon>
  <input slot="input" placeholder="Search..." />
</m3e-search-bar>
```

```html
<m3e-search-view mode="docked" contained>
  <input slot="input" placeholder="Search..." />
  <m3e-list>
    <m3e-list-item>Result One</m3e-list-item>
    <m3e-list-item>Result Two</m3e-list-item>
    <m3e-list-item>Result Three</m3e-list-item>
  </m3e-list>
</m3e-search-view>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Search bar with leading icon and input**

```html
<m3e-search-bar>
  <m3e-icon slot="leading" name="search"></m3e-icon>
  <input slot="input" type="search" placeholder="Search posts…" autocomplete="off" />
</m3e-search-bar>
```

_Source: 2026: src/pages/work/index.astro_

## API

### `<m3e-search-bar>`

A bar that provides a prominent entry point for search.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `clearable` | `boolean` | false | Whether the bar presents a button used to clear the search term. |
| `clear-label` | `string` | "Clear" | The accessible label given to the button used to clear the search term. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `leading` | Renders content before the input of the bar. |
| `input` | Renders the input of the bar. |
| `trailing` | Renders content after the input of the bar. |
| `clear-icon` | Overrides the default clear icon of the bar. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `clear` | `Event` | Dispatched when the search term is cleared. |

**CSS custom properties** — 23 total across 23 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-search-bar-container-color` | Background color of the search bar container. |
| `--m3e-search-bar-leading-icon-color` | Color of the leading icon. |
| `--m3e-search-bar-trailing-icon-color` | Color of the trailing icon. |
| `--m3e-search-bar-container-height` | Height of the search bar container. |
| `--m3e-search-bar-container-shape` | Shape (border radius) of the search bar container. |
| `--m3e-search-bar-icon-size` | Size of icons inside the search bar. |
| `--m3e-search-bar-supporting-text-color` | Color of the supporting text. |
| `--m3e-search-bar-supporting-text-font-size` | Font size of the supporting text. |
| `--m3e-search-bar-supporting-text-font-weight` | Font weight of the supporting text. |
| `--m3e-search-bar-supporting-text-line-height` | Line height of the supporting text. |
| `--m3e-search-bar-supporting-text-tracking` | Letter spacing of the supporting text. |
| `--m3e-search-bar-input-color` | Color of the input text. |

_…11 more families. See source for the full list._

### `<m3e-search-view>`

A surface that presents suggestions and results for a search.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `contained` | `boolean` | false | Whether the view features a persistent, filled search container. |
| `mode` | `"fullscreen" \| "docked" \| "auto"` | "docked" | The behavior mode of the view. |
| `open` | `boolean` | false | Whether the view is expanded to show results. |
| `clear-label` | `string` | "Clear" | The accessible label given to the button used to clear the search term. |
| `close-label` | `string` | "Close" | The accessible label given to the button used to collapse the view. |
| `hide-search-icon` | `boolean` | false | Whether to hide the search icon. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `currentMode` | `Exclude<SearchViewMode, "auto">` | The current mode applied to the view. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | When open, renders the results content of the view. |
| `input` | Renders the input of the view. |
| `open-leading` | When open, renders content before the input of the view. |
| `open-trailing` | When open, renders content after the input of the view. |
| `closed-leading` | When closed, renders content before the input of the view. |
| `closed-trailing` | When closed, renders content after the input of the view. |
| `search-icon` | Overrides the default search icon of the view. |
| `close-icon` | Overrides the default close icon shown while the view is open. |
| `clear-icon` | Overrides the default clear icon of the view. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `query` | `CustomEvent` | Dispatched when the view is opened or when the user modifies the search term. |
| `clear` | `Event` | Dispatched when the search term is cleared. |
| `beforetoggle` | `ToggleEvent` | Dispatched before the toggle state changes. |
| `toggle` | `ToggleEvent` | Dispatched after the toggle state has changed. |

**CSS custom properties** — 22 total across 22 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-search-view-container-color` | Background color of the view container. |
| `--m3e-search-view-contained-container-color` | Background color of the contained view container. |
| `--m3e-search-view-divider-color` | Color of the divider separating header and results. |
| `--m3e-search-view-divider-thickness` | Thickness of the divider separating header and results. |
| `--m3e-search-view-full-screen-container-shape` | Shape of the fullscreen view container. |
| `--m3e-search-view-full-screen-header-container-height` | Height of the header container in fullscreen mode. |
| `--m3e-search-view-docked-container-shape` | Shape of the docked view container. |
| `--m3e-search-view-docked-header-container-height` | Height of the header container in docked mode. |
| `--m3e-search-view-contained-leading-margin` | Leading margin for the contained view. |
| `--m3e-search-view-contained-trailing-margin` | Trailing margin for the contained view. |
| `--m3e-search-view-contained-focused-leading-margin` | Leading margin when the contained view is focused. |
| `--m3e-search-view-contained-focused-trailing-margin` | Trailing margin when the contained view is focused. |

_…10 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/search/README.md) (MIT). · Material spec: <https://m3.material.io/components/search/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/search/SearchBarElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/search/SearchBarElement.ts)
- [`packages/web/src/search/SearchViewElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/search/SearchViewElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
