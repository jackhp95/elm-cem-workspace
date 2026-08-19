# select

**Family:** [Text input & forms](../concepts/choosing-components.md#text-inputs) · See also: [form-field](form-field.md), [autocomplete](autocomplete.md), [search](search.md), [textarea-autosize](textarea-autosize.md), [option](option.md)

The `m3e-select` component provides a form control for selecting a value from a set of predefined options. Following Material Design 3 principles, it supports both single and multiple selection modes, customizable validation states, accessible keyboard navigation, and extensive theming via CSS custom properties.

> **Host contract:** admits `m3e-option` children in its default slot, and groups them under `m3e-optgroup` (each group takes a `<span slot="label">` group label); a custom dropdown arrow goes in `slot="arrow"`.

```ts
import "@m3e/web/select";
```

## Examples

```html
<m3e-form-field>
  <label slot="label" for="select">Choose your favorite fruit</label>
  <m3e-select id="select">
    <m3e-option>Apples</m3e-option>
    <m3e-option>Oranges</m3e-option>
    <m3e-option>Bananas</m3e-option>
    <m3e-option>Grapes</m3e-option>
  </m3e-select>
</m3e-form-field>
```

```html
<m3e-select multi>
  <m3e-option value="javascript">JavaScript</m3e-option>
  <m3e-option value="typescript">TypeScript</m3e-option>
  <m3e-option value="python">Python</m3e-option>
</m3e-select>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Single select of fruit options**

```html
<label for="fruit">Favorite fruit</label>
<br />
<m3e-select id="fruit" name="fruit" required>
  <m3e-option value="apple">Apples</m3e-option>
  <m3e-option value="orange">Oranges</m3e-option>
  <m3e-option value="banana">Bananas</m3e-option>
  <m3e-option value="grape">Grapes</m3e-option>
</m3e-select>
```

**Multi-select languages with custom arrow**

```html
<m3e-select multi name="languages">
  <m3e-icon slot="arrow" name="expand_more"></m3e-icon>
  <m3e-option value="javascript">JavaScript</m3e-option>
  <m3e-option value="typescript">TypeScript</m3e-option>
  <m3e-option value="python">Python</m3e-option>
  <m3e-option value="rust">Rust</m3e-option>
</m3e-select>
```

**Select with options grouped under optgroups**

```html
<label for="city">Destination</label>
<br />
<m3e-select id="city" name="city" required>
  <m3e-optgroup>
    <span slot="label">Europe</span>
    <m3e-option value="paris">Paris</m3e-option>
    <m3e-option value="berlin">Berlin</m3e-option>
  </m3e-optgroup>
  <m3e-optgroup>
    <span slot="label">Asia</span>
    <m3e-option value="tokyo">Tokyo</m3e-option>
    <m3e-option value="seoul">Seoul</m3e-option>
  </m3e-optgroup>
</m3e-select>
```

## API

### `<m3e-select>`

A form control that allows users to select a value from a set of predefined options.

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `hide-selection-indicator` | `boolean` | false | Whether to hide the selection indicator for single select options. |
| `multi` | `boolean` | false | Whether multiple options can be selected. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `panel-class` | `string` | "" | Class or list of classes to be applied to the select's overlay panel. |
| `required` | `boolean` | false | Whether the element is required. |
| `validationMessages` | `ValidationMessages` |  | Validation messages mapped to individual error types. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `options` _(readonly)_ | `readonly M3eOptionElement[]` | The options that can be selected. |
| `selected` _(readonly)_ | `readonly M3eOptionElement[]` | The selected option(s). |
| `value` _(readonly)_ | `string \| readonly string[] \| null` | The selected (enabled) value(s). |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `labels` _(readonly)_ | `NodeListOf<HTMLLabelElement>` | The label elements that the element is associated with. |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `optional` _(readonly)_ |  | Whether a value is not required for the element. |
| `willValidate` _(readonly)_ | `boolean` | Whether the element is a submittable element that is a candidate for constraint validation. |
| `validity` _(readonly)_ | `ValidityState` | The validity state of the element. |
| `validationMessage` _(readonly)_ | `string` | The error message that would be displayed if the user submits the form, or an empty string if no error message. |
| `[defaultValidationMessages]` _(readonly)_ | `Readonly<ValidationMessages>` | Default validation messages mapped to individual error types. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the options of the select. |
| `arrow` | Renders the dropdown arrow. |
| `value` | Renders the selected value(s). |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected state changes. |
| `toggle` | `ToggleEvent` |  |
| `beforeinput` | `Event` | Dispatched before the selected state changes. |
| `input` | `Event` | Dispatched when the selected state changes. |

**CSS custom properties** — 8 total across 8 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-form-field-font-size` | The font size of the select control. |
| `--m3e-form-field-font-weight` | The font weight of the select control. |
| `--m3e-form-field-line-height` | The line height of the select control. |
| `--m3e-form-field-tracking` | The letter spacing of the select control. |
| `--m3e-select-container-shape` | The corner radius of the select container. |
| `--m3e-select-disabled-color` | The text color when the select is disabled. |
| `--m3e-select-disabled-color-opacity` | The opacity level applied to the disabled text color. |
| `--m3e-select-icon-size` | The size of the dropdown arrow icon. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/select/README.md) (MIT). · Material spec: <https://m3.material.io/components/menus/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/select/SelectElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/select/SelectElement.ts)

**README drift corrected** (2 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
