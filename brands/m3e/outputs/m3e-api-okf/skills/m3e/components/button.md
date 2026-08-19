# button

**Family:** [Actions & buttons](../concepts/choosing-components.md#actions) · See also: [icon-button](icon-button.md), [fab](fab.md), [fab-menu](fab-menu.md), [split-button](split-button.md), [button-group](button-group.md), [segmented-button](segmented-button.md)

The `m3e-button` component is a semantic, expressive UI primitive users interact with to perform an action. Designed according to Material Design 3 guidelines, it supports five visual variants, specified using the `variant` attribute—`filled`, `tonal`, `elevated`, `outlined`, and `text`—each with dynamic elevation, shape morphing, and adaptive color theming. The component responds to interaction states (hover, focus, press, disabled) with smooth motion transitions, ensuring emotional clarity and visual hierarchy. The component is accessible by default, with ARIA roles, contrast-safe color tokens, and strong focus indicators. It supports optional icons and states for binary actions. When using `m3e-icon` for icons, `filled` is automatically set based on the selected state of a toggle button. It can also function as a link or be used to submit form data. Native disabled `<button>` elements cannot receive focus. This can be problematic in some cases because it can prevent you from telling the user why the button is disabled. You can use the `disabled-interactive` attribute to style a `m3e-button` as disabled but allow for it to receive focus. The button will have `aria-disabled="true"` for assistive technology.

> **Note:** yes, really — the CEM default is `size="small"`. This is verified against the manifest (machine truth); don't "correct" it to `medium` from generic Material intuition.

```ts
import "@m3e/web/button";
```

## Examples

```html
<m3e-button variant="tonal">Tonal Button</m3e-button>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Five button variants in an action row**

```html
<m3e-button variant="filled">
  <m3e-icon slot="icon" name="add"></m3e-icon>
  New
</m3e-button>
<m3e-button variant="tonal">Tonal</m3e-button>
<m3e-button variant="elevated">Elevated</m3e-button>
<m3e-button variant="outlined">Outlined</m3e-button>
<m3e-button variant="text">Text</m3e-button>
```

**Toggle button and link button with icons**

```html
<m3e-button variant="outlined" toggle>
  <m3e-icon slot="icon" name="favorite_border"></m3e-icon>
  <m3e-icon slot="selected-icon" name="favorite" filled></m3e-icon>
  <span slot="selected">Saved</span>
  Save
</m3e-button>
<m3e-button variant="filled" href="/download" download size="large">
  <m3e-icon slot="icon" name="download"></m3e-icon>
  Download
</m3e-button>
```

## API

### `<m3e-button>`

A button users interact with to perform an action.

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
| `variant` | `"elevated" \| "filled" \| "tonal" \| "outlined" \| "text"` | "text" | The appearance variant of the button. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `grouped` _(readonly)_ |  | Whether the button is contained by a button group. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the button. |
| `icon` | Renders an icon before the button's label. |
| `selected` | Renders the label of the button, when selected. |
| `selected-icon` | Renders an icon before the button's label, when selected. |
| `trailing-icon` | Renders an icon after the button's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before a toggle button's selected state changes. |
| `input` | `Event` | Dispatched when a toggle button's selected state changes. |
| `change` | `Event` | Dispatched when a toggle button's selected state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 385 total across 182 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-button-container-height` | Height of the button container, for all size variants. |
| `--m3e-button-outline-thickness` | Thickness of the button outline, for all size variants. |
| `--m3e-button-label-text-font-size` | Font size for the label text, for all size variants. |
| `--m3e-button-label-text-font-weight` | Font weight for the label text, for all size variants. |
| `--m3e-button-label-text-line-height` | Line height for the label text, for all size variants. |
| `--m3e-button-label-text-tracking` | Letter tracking for the label text, for all size variants. |
| `--m3e-button-icon-size` | Size of the icon, for all size variants. |
| `--m3e-button-shape-round` | Corner radius for round shape, for all size variants. |
| `--m3e-button-shape-square` | Corner radius for square shape, for all size variants. |
| `--m3e-button-selected-shape-round` | Corner radius when selected (round), for all size variants. |
| `--m3e-button-selected-shape-square` | Corner radius when selected (square), for all size variants. |
| `--m3e-button-shape-pressed-morph` | Corner radius when pressed, for all size variants. |

_…170 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/button/README.md) (MIT). · Material spec: <https://m3.material.io/components/buttons/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/button/ButtonElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/button/ButtonElement.ts)

**README drift corrected** (3 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
