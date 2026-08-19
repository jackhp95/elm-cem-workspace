# radio-group

**Family:** [Selection controls](../concepts/choosing-components.md#selection-inputs) · See also: [checkbox](checkbox.md), [switch](switch.md), [slider](slider.md), [chips](chips.md)

The `m3e-radio-group` and `m3e-radio` components enable single-choice selection within a set of mutually exclusive options. They support accessible state transitions, semantic grouping, and expressive styling across interaction states.

```ts
import "@m3e/web/radio-group";
```

**Elements:** `<m3e-radio>`, `<m3e-radio-group>`

## Examples

```html
<label for="rdg1">Radio group</label>
<br />
<m3e-radio-group id="rdg1">
  <label><m3e-radio value="1"></m3e-radio> Value 1</label>
  <label><m3e-radio value="2"></m3e-radio> Value 2</label>
  <label><m3e-radio value="3"></m3e-radio> Value 3</label>
  <label><m3e-radio value="4"></m3e-radio> Value 4</label>
</m3e-radio-group>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Single-choice shipping options**

```html
<label for="ship">Shipping method</label>
<br />
<m3e-radio-group id="ship" name="shipping" required>
  <label><m3e-radio value="standard" checked></m3e-radio> Standard (5-7 days)</label>
  <label><m3e-radio value="express"></m3e-radio> Express (2 days)</label>
  <label><m3e-radio value="overnight"></m3e-radio> Overnight</label>
</m3e-radio-group>
```

**Disabled radio group with one disabled option**

```html
<m3e-radio-group name="plan" disabled>
  <label><m3e-radio value="free" checked></m3e-radio> Free</label>
  <label><m3e-radio value="pro"></m3e-radio> Pro</label>
  <label><m3e-radio value="team" disabled></m3e-radio> Team</label>
</m3e-radio-group>
```

## API

### `<m3e-radio>`

A radio button that allows a user to select one option from a set of options.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `checked` | `boolean` | false | Whether the element is checked. |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `required` |  |  | Whether the element is required. |
| `value` | `string` | "on" | A string representing the value of the radio. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `labels` _(readonly)_ | `NodeListOf<HTMLLabelElement>` | The label elements that the element is associated with. |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the checked state changes. |
| `input` | `Event` | Dispatched when the checked state changes. |
| `change` | `Event` | Dispatched when the checked state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 15 total across 15 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-radio-container-size` | Base size of the radio button container. |
| `--m3e-radio-icon-size` | Size of the radio icon inside the wrapper. |
| `--m3e-radio-unselected-hover-color` | Hover state layer color when radio is not selected. |
| `--m3e-radio-unselected-focus-color` | Focus state layer color when radio is not selected. |
| `--m3e-radio-unselected-ripple-color` | Ripple color when radio is not selected. |
| `--m3e-radio-unselected-icon-color` | Icon color when radio is not selected. |
| `--m3e-radio-selected-hover-color` | Hover state layer color when radio is selected. |
| `--m3e-radio-selected-focus-color` | Focus state layer color when radio is selected. |
| `--m3e-radio-selected-ripple-color` | Ripple color when radio is selected. |
| `--m3e-radio-selected-icon-color` | Icon color when radio is selected. |
| `--m3e-radio-disabled-icon-color` | Icon color when radio is disabled. |
| `--m3e-radio-error-hover-color` | Fallback hover color used when the radio is invalid and touched. |

_…3 more families. See source for the full list._

### `<m3e-radio-group>`

A container for a set of radio buttons.

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `aria-invalid` |  |  |  |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `required` | `boolean` | false | Whether the element is required. |
| `validationMessages` | `ValidationMessages` |  | Validation messages mapped to individual error types. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `radios` _(readonly)_ | `readonly M3eRadioElement[]` | The radios in the group. |
| `selected` _(readonly)_ | `M3eRadioElement \| null` | The selected radio. |
| `value` _(readonly)_ | `string \| null` | The selected value of the radio group. |
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
| `(default)` | Renders the radio buttons of the group. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` |  | Dispatched before the checked state of a radio button changes. |
| `input` |  | Dispatched when the checked state of a radio button changes. |
| `change` |  | Dispatched when the checked state of a radio button changes. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/radio-group/README.md) (MIT). · Material spec: <https://m3.material.io/components/radio-button/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/radio-group/RadioElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/radio-group/RadioElement.ts)
- [`packages/web/src/radio-group/RadioGroupElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/radio-group/RadioGroupElement.ts)

**README drift corrected** (3 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
