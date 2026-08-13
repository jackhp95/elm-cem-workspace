# fab

**Family:** [Actions & buttons](../concepts/choosing-components.md#actions) · See also: [button](button.md), [icon-button](icon-button.md), [fab-menu](fab-menu.md), [split-button](split-button.md), [button-group](button-group.md), [segmented-button](segmented-button.md)

The `m3e-fab` component is a prominent, expressive UI component that represents the primary action on a screen. Designed according to Material Design 3 guidelines, it supports seven visual variants, specified using the `variant` attribute—`primary`, `primary-container`, `secondary`, `secondary-container`, `tertiary`, `tertiary-container` and `surface`—each with dynamic elevation and adaptive color theming. The component is accessible by default, with ARIA roles, contrast-safe color tokens, and strong focus indicators. It can be extended to display a label alongside its icon, and responds to interaction states (hover, focus, press, disabled) with smooth motion transitions, elevation changes, and adaptive color theming. It can also function as a link or be used to submit form data. Native disabled `<button>` elements cannot receive focus. This can be problematic in some cases because it can prevent you from telling the user why the button is disabled. You can use the `disabled-interactive` attribute to style a `m3e-fab` as disabled but allow for it to receive focus. The button will have `aria-disabled="true"` for assistive technology.

```ts
import "@m3e/web/fab";
```

## Examples

```html
<m3e-fab>
  <m3e-icon>add</m3e-icon>
</m3e-fab>
```

```html
<m3e-fab extended>
  <m3e-icon>add</m3e-icon>
  <span slot="label">Add</span>
</m3e-fab>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Small FAB with icon**

```html
<m3e-fab size="small" aria-label="Navigation menu">
  <m3e-icon name="menu"></m3e-icon>
</m3e-fab>
```

_Source: 2026: src/components/NavFab.astro_

## API

### `<m3e-fab>`

A floating action button (FAB) used to present important actions.

**Display:** `inline-block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `disabled-interactive` | `boolean` | false | Whether the element is disabled and interactive. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `extended` | `boolean` | false | Whether the button is extended to show the label. |
| `href` | `string` | "" | The URL to which the link button points. |
| `lowered` | `boolean` | false | Whether to present a lowered elevation. |
| `name` |  |  | The name of the element, submitted as a pair with the element's `value` as part of form data, when the element is used to submit a form. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `size` | `"small" \| "medium" \| "large"` | "medium" | The size of the button. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |
| `type` | `"button" \| "submit" \| "reset"` | "button" | The type of the element. |
| `value` |  |  | The value associated with the element's name when it's submitted with form data. |
| `variant` | `"primary" \| "primary-container" \| "secondary" \| "secondary-container" \| "tertiary" \| "tertiary-container" \| "surface"` | "primary-container" | The appearance variant of the button. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the icon of the button. |
| `label` | Renders the label of an extended button. |
| `close-icon` | Renders the close icon when used to open a FAB menu. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 289 total across 269 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-fab-container-height` | Height of the FAB container for all size variants. |
| `--m3e-fab-label-text-font-size` | Font size for the FAB label text for all size variants. |
| `--m3e-fab-label-text-font-weight` | Font weight for the FAB label text for all size variants. |
| `--m3e-fab-label-text-line-height` | Line height for the FAB label text for all size variants. |
| `--m3e-fab-label-text-tracking` | Letter spacing (tracking) for the FAB label text for all size variants. |
| `--m3e-fab-icon-size` | Icon size for the FAB for all size variants. |
| `--m3e-fab-shape` | Border radius for the FAB for all size variants. |
| `--m3e-fab-leading-space` | Leading space for the FAB for all size variants. |
| `--m3e-fab-trailing-space` | Trailing space for the FAB for all size variants. |
| `--m3e-fab-icon-label-space` | Space between icon and label for the FAB for all size variants. |
| `--m3e-fab-[size]-container-height` | Height of the small FAB container. |
| `--m3e-fab-[size]-label-text-font-size` | Font size for the small FAB label text. |

_…257 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/fab/README.md) (MIT). · Material spec: <https://m3.material.io/components/floating-action-button/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/fab/FabElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/fab/FabElement.ts)

**README drift corrected** (3 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
