# chips

**Family:** [Selection controls](../concepts/choosing-components.md#selection-inputs) · See also: [checkbox](checkbox.md), [radio-group](radio-group.md), [switch](switch.md), [slider](slider.md)

The `@m3e/web/chips` module provides expressive, accessible chip components for actions, input, filtering, and suggestions, each supporting two appearance variants—`outlined` and `elevated`. Use `outlined` for lightweight, unobtrusive chips such as tags or filters, and `elevated` for chips that require stronger visual affordance, like assist actions or selected states. These variants help convey interaction weight, visual hierarchy, and contextual emphasis across static and interactive use cases.

```ts
import "@m3e/web/chips";
```

**Elements:** `<m3e-assist-chip>`, `<m3e-chip>`, `<m3e-chip-set>`, `<m3e-filter-chip>`, `<m3e-filter-chip-set>`, `<m3e-input-chip>`, `<m3e-input-chip-set>`, `<m3e-suggestion-chip>`

## Examples

```html
<m3e-chip-set>
  <m3e-chip><m3e-icon slot="icon" name="palette"></m3e-icon>Design</m3e-chip>
  <m3e-chip><m3e-icon slot="icon" name="accessibility_new"></m3e-icon>Accessibility</m3e-chip>
  <m3e-chip><m3e-icon slot="icon" name="motion_photos_on"></m3e-icon>Motion</m3e-chip>
  <m3e-chip><m3e-icon slot="icon" name="description"></m3e-icon>Documentation</m3e-chip>
</m3e-chip-set>
```

```html
<m3e-chip-set role="group" aria-label="Quick actions">
  <m3e-assist-chip><m3e-icon slot="icon" name="edit"></m3e-icon>Edit</m3e-assist-chip>
  <m3e-assist-chip><m3e-icon slot="icon" name="delete"></m3e-icon>Delete</m3e-assist-chip>
  <m3e-assist-chip><m3e-icon slot="icon" name="content_copy"></m3e-icon>Copy</m3e-assist-chip>
  <m3e-assist-chip><m3e-icon slot="icon" name="share"></m3e-icon>Share</m3e-assist-chip>
</m3e-chip-set>
```

```html
<m3e-form-field>
  <label slot="label" for="keywords">Keywords</label>
  <m3e-input-chip-set aria-label="Enter keywords">
    <input id="keywords" slot="input" placeholder="New keyword..." />
  </m3e-input-chip-set>
</m3e-form-field>
```

```html
<m3e-filter-chip-set aria-label="Filter by topic">
  <m3e-filter-chip><m3e-icon slot="icon" name="palette"></m3e-icon>Design</m3e-filter-chip>
  <m3e-filter-chip><m3e-icon slot="icon" name="accessibility_new"></m3e-icon>Accessibility</m3e-filter-chip>
  <m3e-filter-chip><m3e-icon slot="icon" name="motion_photos_on"></m3e-icon>Motion</m3e-filter-chip>
  <m3e-filter-chip><m3e-icon slot="icon" name="description"></m3e-icon>Documentation</m3e-filter-chip>
</m3e-filter-chip-set>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Chip with leading icon and label**

```html
<m3e-chip>
  <m3e-icon slot="icon" name="menu_book"></m3e-icon>
  Library
</m3e-chip>
```

_Source: 2026: src/pages/speed-reader.astro_

## API

### `<m3e-assist-chip>`

A chip users interact with to perform a smart or automated action that can span multiple applications.

**Display:** `inline-block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | A value indicating whether the element is disabled. |
| `disabled-interactive` | `boolean` | false | A value indicating whether the element is disabled and interactive. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `href` | `string` | "" | The URL to which the link button points. |
| `name` |  |  | The name of the element, submitted as a pair with the element's `value` as part of form data, when the element is used to submit a form. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |
| `type` | `"button" \| "submit" \| "reset"` | "button" | The type of the element. |
| `value` |  |  | A string representing the value of the chip. |
| `variant` | `"outlined" \| "elevated"` | "outlined" | The appearance variant of the chip. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `label` _(readonly)_ |  | The textual label of the chip. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the chip. |
| `icon` | Renders an icon before the chip's label. |
| `trailing-icon` | Renders an icon after the chip's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 28 total across 28 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-chip-container-shape` | Border radius of the chip container. |
| `--m3e-chip-container-height` | Base height of the chip container before density adjustment. |
| `--m3e-chip-label-text-font-size` | Font size of the chip label text. |
| `--m3e-chip-label-text-font-weight` | Font weight of the chip label text. |
| `--m3e-chip-label-text-line-height` | Line height of the chip label text. |
| `--m3e-chip-label-text-tracking` | Letter spacing of the chip label text. |
| `--m3e-chip-label-text-color` | Label text color in default state. |
| `--m3e-chip-icon-color` | Icon color in default state. |
| `--m3e-chip-icon-size` | Font size of leading/trailing icons. |
| `--m3e-chip-spacing` | Horizontal gap between chip content elements. |
| `--m3e-chip-padding-start` | Default start padding when no icon is present. |
| `--m3e-chip-padding-end` | Default end padding when no trailing icon is present. |

_…16 more families. See source for the full list._

### `<m3e-chip>`

A non-interactive chip used to convey small pieces of information.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `value` |  |  | A string representing the value of the chip. |
| `variant` | `"outlined" \| "elevated"` | "outlined" | The appearance variant of the chip. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `label` _(readonly)_ |  | The textual label of the chip. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the chip. |
| `icon` | Renders an icon before the chip's label. |
| `trailing-icon` | Renders an icon after the chip's label. |

**CSS custom properties** — 19 total across 19 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-chip-container-shape` | Border radius of the chip container. |
| `--m3e-chip-container-height` | Base height of the chip container before density adjustment. |
| `--m3e-chip-label-text-font-size` | Font size of the chip label text. |
| `--m3e-chip-label-text-font-weight` | Font weight of the chip label text. |
| `--m3e-chip-label-text-line-height` | Line height of the chip label text. |
| `--m3e-chip-label-text-tracking` | Letter spacing of the chip label text. |
| `--m3e-chip-label-text-color` | Label text color in default state. |
| `--m3e-chip-icon-color` | Icon color in default state. |
| `--m3e-chip-icon-size` | Font size of leading/trailing icons. |
| `--m3e-chip-spacing` | Horizontal gap between chip content elements. |
| `--m3e-chip-padding-start` | Default start padding when no icon is present. |
| `--m3e-chip-padding-end` | Default end padding when no trailing icon is present. |

_…7 more families. See source for the full list._

### `<m3e-chip-set>`

A container used to organize chips into a cohesive unit.

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `vertical` | `boolean` | false | Whether the element is oriented vertically. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the chips of the set. |

**CSS custom properties** — 1 total across 1 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-chip-set-spacing` | The spacing (gap) between chips in the set. |

### `<m3e-filter-chip>`

A chip users interact with to select/deselect options.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | A value indicating whether the element is disabled. |
| `disabled-interactive` | `boolean` | false | A value indicating whether the element is disabled and interactive. |
| `selected` | `boolean` | false | A value indicating whether the element is selected. |
| `value` |  |  | A string representing the value of the chip. |
| `variant` | `"outlined" \| "elevated"` | "outlined" | The appearance variant of the chip. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `label` _(readonly)_ |  | The textual label of the chip. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the chip. |
| `icon` | Renders an icon before the chip's label. |
| `trailing-icon` | Renders an icon after the chip's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the selected state changes. |
| `input` | `Event` | Dispatched when the selected state changes. |
| `change` | `Event` | Dispatched when the selected state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 45 total across 45 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-chip-container-shape` | Border radius of the chip container. |
| `--m3e-chip-container-height` | Base height of the chip container before density adjustment. |
| `--m3e-chip-label-text-font-size` | Font size of the chip label text. |
| `--m3e-chip-label-text-font-weight` | Font weight of the chip label text. |
| `--m3e-chip-label-text-line-height` | Line height of the chip label text. |
| `--m3e-chip-label-text-tracking` | Letter spacing of the chip label text. |
| `--m3e-chip-icon-size` | Font size of leading/trailing icons. |
| `--m3e-chip-spacing` | Horizontal gap between chip content elements. |
| `--m3e-chip-padding-start` | Default start padding when no icon is present. |
| `--m3e-chip-padding-end` | Default end padding when no trailing icon is present. |
| `--m3e-chip-with-icon-padding-start` | Start padding when leading icon is present. |
| `--m3e-chip-with-icon-padding-end` | End padding when trailing icon is present. |

_…33 more families. See source for the full list._

### `<m3e-filter-chip-set>`

A container that organizes filter chips into a cohesive group, enabling selection and

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `hide-selection-indicator` | `boolean` | false | Whether to hide the selection indicator. |
| `multi` | `boolean` | false | Whether multiple chips can be selected. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `vertical` | `boolean` | false | Whether the element is oriented vertically. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `chips` _(readonly)_ | `readonly M3eFilterChipElement[]` | The chips of the set. |
| `selected` _(readonly)_ | `readonly M3eFilterChipElement[]` | The selected chip(s) of the set. |
| `value` _(readonly)_ | `string \| readonly string[] \| null` | The selected (enabled) value(s) of the set. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `labels` _(readonly)_ | `NodeListOf<HTMLLabelElement>` | The label elements that the element is associated with. |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the chips of the set. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected state of a chip changes. |
| `beforeinput` |  | Dispatched before the selected state of a chip changes. |
| `input` |  | Dispatched when the selected state of a chip changes. |

**CSS custom properties** — 1 total across 1 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-chip-set-spacing` | The spacing (gap) between chips in the set. |

### `<m3e-input-chip>`

A chip which represents a discrete piece of information entered by a user.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `disabled-interactive` | `boolean` | false | Whether the element is disabled and interactive. |
| `removable` | `boolean` | false | Whether the chip is removable. |
| `remove-label` | `string` | "Remove" | The accessible label given to the button used to remove the chip. |
| `value` |  |  | A string representing the value of the chip. |
| `variant` | `"outlined" \| "elevated"` | "outlined" | The appearance variant of the chip. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `cell` _(readonly)_ | `HTMLSpanElement` | A reference to the grid cell of the chip. |
| `removeButton` _(readonly)_ | `M3eIconButtonElement \| null` | A reference to the button used to remove the chip. |
| `label` _(readonly)_ |  | The textual label of the chip. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the chip. |
| `avatar` | Renders an avatar before the chip's label. |
| `icon` | Renders an icon before the chip's label. |
| `remove-icon` | Renders the icon for the button used to remove the chip. |
| `trailing-icon` | Renders an icon after the chip's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `remove` | `Event` | Dispatched when the remove button is clicked or DELETE or BACKSPACE key is pressed. |
| `click` |  | Dispatched when the element is clicked. |

**CSS custom properties** — 36 total across 36 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-chip-container-shape` | Border radius of the chip container. |
| `--m3e-chip-container-height` | Base height of the chip container before density adjustment. |
| `--m3e-chip-label-text-font-size` | Font size of the chip label text. |
| `--m3e-chip-label-text-font-weight` | Font weight of the chip label text. |
| `--m3e-chip-label-text-line-height` | Line height of the chip label text. |
| `--m3e-chip-label-text-tracking` | Letter spacing of the chip label text. |
| `--m3e-chip-label-text-color` | Label text color in default state. |
| `--m3e-chip-icon-color` | Icon color in default state. |
| `--m3e-chip-icon-size` | Font size of leading/trailing icons. |
| `--m3e-chip-spacing` | Horizontal gap between chip content elements. |
| `--m3e-chip-padding-start` | Default start padding when no icon is present. |
| `--m3e-chip-padding-end` | Default end padding when no trailing icon is present. |

_…24 more families. See source for the full list._

### `<m3e-input-chip-set>`

A container that transforms user input into a cohesive set of interactive chips, supporting entry, editing, and removal of discrete values.

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `required` | `boolean` | false | Whether a value is required for the element. |
| `vertical` | `boolean` | false | Whether the element is oriented vertically. |
| `validationMessages` | `ValidationMessages` |  | Validation messages mapped to individual error types. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `chips` _(readonly)_ | `readonly M3eInputChipElement[]` | The chips of the set. |
| `value` _(readonly)_ | `readonly string[] \| null` | The values of the set. |
| `optional` _(readonly)_ |  | Whether a value is not required for the element. |
| `willValidate` _(readonly)_ | `boolean` | Whether the element is a submittable element that is a candidate for constraint validation. |
| `validity` _(readonly)_ | `ValidityState` | The validity state of the element. |
| `validationMessage` _(readonly)_ | `string` | The error message that would be displayed if the user submits the form, or an empty string if no error message. |
| `[defaultValidationMessages]` _(readonly)_ | `Readonly<ValidationMessages>` | Default validation messages mapped to individual error types. |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the chips of the set. |
| `input` | Renders the input element used to add new chips to the set. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `CustomEvent` | Dispatched when a chip is added to, or removed from, the set. |

**CSS custom properties** — 1 total across 1 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-chip-set-spacing` | The spacing (gap) between chips in the set. |

### `<m3e-suggestion-chip>`

A chip used to help narrow a user's intent by presenting dynamically generated suggestions, such as

**Display:** `inline-block` · **Navigable:** carries a native `href` — do not wrap it in an `<a>`.

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | A value indicating whether the element is disabled. |
| `disabled-interactive` | `boolean` | false | A value indicating whether the element is disabled and interactive. |
| `download` | `string \| null` | null | A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file. |
| `href` | `string` | "" | The URL to which the link button points. |
| `name` |  |  | The name of the element, submitted as a pair with the element's `value` as part of form data, when the element is used to submit a form. |
| `rel` | `string` | "" | The relationship between the `target` of the link button and the document. |
| `target` | `"_self" \| "_blank" \| "_parent" \| "_top" \| string` | "" | The target of the link button. |
| `type` | `"button" \| "submit" \| "reset"` | "button" | The type of the element. |
| `value` |  |  | A string representing the value of the chip. |
| `variant` | `"outlined" \| "elevated"` | "outlined" | The appearance variant of the chip. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `label` _(readonly)_ |  | The textual label of the chip. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the chip. |
| `icon` | Renders an icon before the chip's label. |
| `trailing-icon` | Renders an icon after the chip's label. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 28 total across 28 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-chip-container-shape` | Border radius of the chip container. |
| `--m3e-chip-container-height` | Base height of the chip container before density adjustment. |
| `--m3e-chip-label-text-font-size` | Font size of the chip label text. |
| `--m3e-chip-label-text-font-weight` | Font weight of the chip label text. |
| `--m3e-chip-label-text-line-height` | Line height of the chip label text. |
| `--m3e-chip-label-text-tracking` | Letter spacing of the chip label text. |
| `--m3e-chip-label-text-color` | Label text color in default state. |
| `--m3e-chip-icon-color` | Icon color in default state. |
| `--m3e-chip-icon-size` | Font size of leading/trailing icons. |
| `--m3e-chip-spacing` | Horizontal gap between chip content elements. |
| `--m3e-chip-padding-start` | Default start padding when no icon is present. |
| `--m3e-chip-padding-end` | Default end padding when no trailing icon is present. |

_…16 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/README.md) (MIT). · Material spec: <https://m3.material.io/components/chips/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/chips/AssistChipElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/AssistChipElement.ts)
- [`packages/web/src/chips/ChipElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/ChipElement.ts)
- [`packages/web/src/chips/ChipSetElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/ChipSetElement.ts)
- [`packages/web/src/chips/FilterChipElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/FilterChipElement.ts)
- [`packages/web/src/chips/FilterChipSetElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/FilterChipSetElement.ts)
- [`packages/web/src/chips/InputChipElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/InputChipElement.ts)
- [`packages/web/src/chips/InputChipSetElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/InputChipSetElement.ts)
- [`packages/web/src/chips/SuggestionChipElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/chips/SuggestionChipElement.ts)

**README drift corrected** (9 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
