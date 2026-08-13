# date-input

**Family:** [Data & collections](../concepts/choosing-components.md#data-display) · See also: [list](list.md), [tree](tree.md), [calendar](calendar.md), [datepicker](datepicker.md), [timepicker](timepicker.md)

# @m3e/web/date-input The `m3e-date-input` component provides a segmented input for editing date and/or time values. It supports date-only, time-only, and combined date/time entry, and integrates with `m3e-form-field`, `m3e-datepicker`, and `m3e-timepicker`. Each segment is independently editable for precise, accessible, form-friendly interaction.

```ts
import "@m3e/web/date-input";
```

## Examples

```html
<m3e-form-field>
  <label slot="label" for="fld1">Date Field</label>
  <m3e-date-input id="fld1"></m3e-date-input>
  <m3e-icon-button slot="suffix">
    <m3e-icon name="calendar_today"></m3e-icon>
    <m3e-datepicker-toggle for="picker"></m3e-datepicker-toggle>
  </m3e-icon-button>
  <span slot="hint">MM/DD/YYYY</span>
</m3e-form-field>
<m3e-datepicker id="picker" for="fld1"></m3e-datepicker>
```

## API

### `<m3e-date-input>`

A segmented input for entering date and/or time values using a keyboard.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `Date \| null` | null | The value of the input. |
| `type` | `"date" \| "datetime" \| "time"` | "date" | The interaction mode for editing date and/or time values. |
| `show-seconds` | `boolean` | false | Whether to show seconds. |
| `time-format` | `"12" \| "24" \| "auto"` | "12" | Format used when editing time values. |
| `min-date` | `Date \| null` | null | The minimum date that can be selected. |
| `max-date` | `Date \| null` | null | The maximum date that can be selected. |
| `min-time` | `TimeParts \| null` | null | The minimum time that can be selected. |
| `max-time` | `TimeParts \| null` | null | The maximum time that can be selected. |
| `month-label` | `string` | "Month" | The accessible label given to the month segment. |
| `day-label` | `string` | "Day" | The accessible label given to the day segment. |
| `year-label` | `string` | "Year" | The accessible label given to the year segment. |
| `hour-label` | `string` | "Hour" | The accessible label given to the hour segment. |
| `minute-label` | `string` | "Minute" | The accessible label given to the minute segment. |
| `second-label` | `string` | "Second" | The accessible label given to the second segment. |
| `period-label` | `string` | "Period" | The accessible label given to the period segment (AM/PM). |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `readonly` | `boolean` | false | A value indicating whether the element is read-only. |
| `required` | `boolean` | false | Whether a value is required for the element. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `validationMessages` | `ValidationMessages` |  | Validation messages mapped to individual error types. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `blackoutDates` | `((date: Date) => boolean) \| null` | A function used to determine whether a date cannot be selected. |
| `blackoutTimes` | `(time: TimeParts) => boolean \| undefined` | A function used to determine whether a time cannot be selected. |
| `[defaultValidationMessages]` _(readonly)_ | `Readonly<ValidationMessages>` | Default validation messages mapped to individual error types. |
| `dirty` _(readonly)_ | `boolean` | Whether the user has modified the value of the element. |
| `pristine` _(readonly)_ | `boolean` | Whether the user has not modified the value of the element. |
| `touched` _(readonly)_ | `boolean` | Whether the user has interacted when the element. |
| `untouched` _(readonly)_ | `boolean` | Whether the user has not interacted when the element. |
| `optional` _(readonly)_ |  | Whether a value is not required for the element. |
| `willValidate` _(readonly)_ | `boolean` | Whether the element is a submittable element that is a candidate for constraint validation. |
| `validity` _(readonly)_ | `ValidityState` | The validity state of the element. |
| `validationMessage` _(readonly)_ | `string` | The error message that would be displayed if the user submits the form, or an empty string if no error message. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the value changes. |
| `beforeinput` | `Event` | Dispatched before the value changes. |
| `input` | `Event` | Dispatched when the value changes. |
| `invalid` |  | Dispatched when a form is submitted and the element fails constraint validation. |

**CSS custom properties** — 5 total across 5 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-date-input-color` | Color of the date input text when enabled. |
| `--m3e-date-input-disabled-color` | Color of the date input text when disabled. |
| `--m3e-date-input-disabled-opacity` | Opacity applied to the disabled date input text. |
| `--m3e-date-input-focused-container-color` | Background color of the selected date input segment when focused. |
| `--m3e-date-input-focused-color` | Text color of the selected date input segment when focused. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/date-input/README.md) (MIT). · Material spec: <https://m3.material.io/components/date-pickers/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/date-input/DateInputElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/date-input/DateInputElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
