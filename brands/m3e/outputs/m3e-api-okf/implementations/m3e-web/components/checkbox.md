# checkbox

**Family:** [Selection controls](../concepts/choosing-components.md#selection-inputs) · See also: [radio-group](radio-group.md), [switch](switch.md), [slider](slider.md), [chips](chips.md)

The `m3e-checkbox` component enables users to select one or more options from a set. It supports selected, unselected, and indeterminate states, and communicates selection through visual cues and accessible semantics. This component reflects user intent, form participation, and validation feedback, adapting to disabled and required contexts. It emits `input` and `change` events to signal state transitions and integrates with form submission via `name` and `value`.

```ts
import "@m3e/web/checkbox";
```

## Examples

```html
<label>
  <m3e-checkbox></m3e-checkbox>
  Checkbox label
</label>
```

```html
<m3e-checkbox id="chk"></m3e-checkbox><label for="chk">Checkbox label </label>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Notification preferences with required terms**

```html
<section>
  <p>Email notifications</p>
  <label>
    <m3e-checkbox checked name="news" value="newsletter"></m3e-checkbox>
    Product newsletter
  </label>
  <label>
    <m3e-checkbox name="offers" value="offers"></m3e-checkbox>
    Special offers
  </label>
  <label>
    <m3e-checkbox indeterminate name="digest" value="digest"></m3e-checkbox>
    Weekly digest
  </label>
  <m3e-divider></m3e-divider>
  <label>
    <m3e-checkbox required name="terms" value="accepted"></m3e-checkbox>
    I accept the terms of service
  </label>
</section>
```

**Single checkbox with external label**

```html
<div>
  <m3e-checkbox id="remember" checked name="remember" value="yes"></m3e-checkbox>
  <label for="remember">Remember me on this device</label>
</div>
```

## API

### `<m3e-checkbox>`

A checkbox that allows a user to select one or more options from a limited number of choices.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `checked` | `boolean` | false | Whether the element is checked. |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `indeterminate` | `boolean` | false | Whether the element's checked state is indeterminate. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `required` | `boolean` | false | Whether the element is required. |
| `value` | `string` | "on" | A string representing the value of the checkbox. |
| `validationMessages` | `ValidationMessages` |  | Validation messages mapped to individual error types. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
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

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the checked state changes. |
| `input` | `Event` | Dispatched when the checked state changes. |
| `change` | `Event` | Dispatched when the checked state changes. |
| `invalid` |  | Dispatched when a form is submitted and the element fails constraint validation. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 27 total across 27 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-checkbox-icon-size` | Size of the checkbox icon inside the container. |
| `--m3e-checkbox-container-size` | Base size of the checkbox container. |
| `--m3e-checkbox-container-shape` | Border radius of the icon container. |
| `--m3e-checkbox-unselected-outline-thickness` | Border thickness for unselected state. |
| `--m3e-checkbox-unselected-outline-color` | Border color for unselected state. |
| `--m3e-checkbox-unselected-hover-outline-color` | Border color on hover when unselected. |
| `--m3e-checkbox-unselected-disabled-outline-color` | Base color for disabled unselected outline. |
| `--m3e-checkbox-unselected-disabled-outline-opacity` | Opacity for disabled unselected outline. |
| `--m3e-checkbox-unselected-error-outline-color` | Border color for invalid unselected state. |
| `--m3e-checkbox-selected-container-color` | Background color for selected container. |
| `--m3e-checkbox-selected-icon-color` | Icon color for selected state. |
| `--m3e-checkbox-selected-disabled-container-color` | Base color for disabled selected container. |

_…15 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/checkbox/README.md) (MIT). · Material spec: <https://m3.material.io/components/checkbox/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/checkbox/CheckboxElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/checkbox/CheckboxElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
