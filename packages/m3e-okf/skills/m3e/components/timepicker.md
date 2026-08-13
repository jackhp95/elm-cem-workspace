# timepicker

**Family:** [Data & collections](../concepts/choosing-components.md#data-display) · See also: [list](list.md), [tree](tree.md), [calendar](calendar.md), [datepicker](datepicker.md), [date-input](date-input.md)

The `m3e-timepicker` component presents a temporary surface for selecting time using dial and keyboard modes. It supports hour and minute selection across 12-hour and 24-hour formats, enforces minimum and maximum constraints, and adapts between docked and modal layouts based on available space.

```ts
import "@m3e/web/timepicker";
```

**Elements:** `<m3e-timepicker>`, `<m3e-timepicker-dial>`, `<m3e-timepicker-input>`, `<m3e-timepicker-input-period-toggle>`, `<m3e-timepicker-toggle>`

## API

### `<m3e-timepicker>`

Presents a time picker on a temporary surface.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `"docked" \| "modal" \| "auto"` | "docked" | The appearance variant of the picker. |
| `mode` | `"dial" \| "input"` | "dial" | The mode in which to select time. |
| `orientation` | `"horizontal" \| "vertical" \| "auto"` | "vertical" | The orientation of the picker. |
| `date` | `Date \| null` | null | The selected date. |
| `format` | `"12" \| "24" \| "auto"` | "12" | Whether to use a 12‑hour or 24‑hour clock. |
| `max-time` | `TimeParts \| null` | null | The maximum time that can be selected. |
| `min-time` | `TimeParts \| null` | null | The minimum time that can be selected. |
| `show-seconds` | `boolean` | false | Whether to show seconds. |
| `confirm-label` | `string` | "OK" | Label given to the button used apply the selected date and close the picker. |
| `dismiss-label` | `string` | "Cancel" | Label given to the button used discard the selected date and close the picker. |
| `dial-label` | `string` | "Select time" | Label given to the the picker when in dial mode. |
| `input-label` | `string` | "Edit time" | Label given to the the picker when in input mode. |
| `hour-label` | `string` | "Hour" | Label for the hour field. |
| `minute-label` | `string` | "Minute" | Label for the minute field. |
| `second-label` | `string` | "Second" | The label for the second field. |
| `mode-toggle-label` | `string` | "Toggle input picker" | The accessible label given to the mode toggle button. |
| `hide-mode-toggle` | `boolean` | false | Whether to hide the mode toggle button. |
| `period-toggle-label` | `string` | "AM or PM" | The accessible label given to the period toggle. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `blackoutTimes` | `(time: TimeParts) => boolean \| undefined` | A function used to determine whether a time cannot be selected. |
| `isOpen` _(readonly)_ |  | Whether the picker is open. |
| `currentVariant` _(readonly)_ | `Exclude<TimepickerVariant, "auto">` | The current variant applied to the picker. |
| `currentOrientation` _(readonly)_ | `Exclude<TimepickerOrientation, "auto">` | The current orientation applied to the picker. |
| `currentMode` _(readonly)_ | `Exclude<TimepickerMode, "auto">` | The current input mode applied to the picker. |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected time is confirmed. |
| `beforetoggle` |  | Dispatched before the picker toggles. |
| `toggle` |  | Dispatched when the picker toggles. |

**CSS custom properties** — 77 total across 77 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-timepicker-container-padding-block` | Block padding inside the picker container. |
| `--m3e-timepicker-container-padding-inline` | Inline padding inside the picker container. |
| `--m3e-timepicker-container-color` | Background color of the picker container. |
| `--m3e-timepicker-container-elevation` | Box shadow / elevation of the picker container. |
| `--m3e-timepicker-docked-container-color` | Background color of the docked picker container. |
| `--m3e-timepicker-docked-container-shape` | Border radius of the docked picker container. |
| `--m3e-timepicker-modal-container-color` | Background color of the modal picker container. |
| `--m3e-timepicker-modal-container-shape` | Border radius of the modal picker container. |
| `--m3e-timepicker-headline-color` | Color of the headline. |
| `--m3e-timepicker-headline-font-size` | Font size of the headline. |
| `--m3e-timepicker-headline-font-weight` | Font weight of the headline. |
| `--m3e-timepicker-headline-line-height` | Line height of the headline. |

_…65 more families. See source for the full list._

### `<m3e-timepicker-dial>`

A clock‑face surface for selecting hours and minutes using a movable hand.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `format` | `"12" \| "24" \| "auto"` | "12" | Whether to use a 12‑hour or 24‑hour clock. |
| `hour` | `number \| null` | null | The hour, in 24-hour time, from 0..23. |
| `max-time` | `TimeParts \| null` | null | The maximum time that can be selected. |
| `min-time` | `TimeParts \| null` | null | The minimum time that can be selected. |
| `minute` | `number \| null` | null | The minute, from 0..59. |
| `second` | `number \| null` | null | The second, from 0..59. |
| `show-seconds` | `boolean` | false | Whether to show seconds. |
| `period` | `"am" \| "pm"` | "am" | The 12-hour time period. |
| `view` | `"hour" \| "minute" \| "second"` | "hour" | The view used to input time. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `blackoutTimes` | `(time: TimeParts) => boolean \| undefined` | A function used to determine whether a time cannot be selected. |
| `hourOfPeriod` | `number \| null` | The hour in 12‑hour time from 1..12. |
| `currentFormat` _(readonly)_ | `Exclude<TimepickerFormat, "auto">` | The current time format. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `input` | `Event` | Dispatched when the selected time changes. |
| `change` | `Event` | Dispatched when the selected time changes. |
| `view-change` | `CustomEvent` | Dispatched when the view changes. |

**CSS custom properties** — 25 total across 25 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-timepicker-dial-container-size` | Size of the dial container. |
| `--m3e-timepicker-dial-container-shape` | Corner radius of the dial container. |
| `--m3e-timepicker-dial-container-color` | Background color of the dial container. |
| `--m3e-timepicker-dial-inset` | Inset offset applied to the dial surface. |
| `--m3e-timepicker-dial-center-size` | Size of the dial center. |
| `--m3e-timepicker-dial-handle-color` | Color of the active handle. |
| `--m3e-timepicker-dial-handle-size` | Size of the handle. |
| `--m3e-timepicker-dial-handle-disabled-color` | Color of a disabled handle. |
| `--m3e-timepicker-dial-handle-disabled-opacity` | Opacity of a disabled handle. |
| `--m3e-timepicker-dial-dial-inset` | Inset applied to the handle area. |
| `--m3e-timepicker-dial-numeral-size` | Size of the dial numerals. |
| `--m3e-timepicker-dial-numeral-color` | Text color of inactive numerals. |

_…13 more families. See source for the full list._

### `<m3e-timepicker-input>`

A keyboard‑based time surface for choosing hours and minutes.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `format` | `"12" \| "24" \| "auto"` | "12" | Whether to use a 12‑hour or 24‑hour clock. |
| `hide-labels` | `boolean` | false | Whether to hide field labels. |
| `hour` | `number \| null` | null | The hour, in 24-hour time, from 0..23. |
| `max-time` | `TimeParts \| null` | null | The maximum time that can be selected. |
| `min-time` | `TimeParts \| null` | null | The minimum time that can be selected. |
| `minute` | `number \| null` | null | The minute, from 0..59. |
| `second` | `number \| null` | null | The second, from 0..59. |
| `show-seconds` | `boolean` | false | Whether to show seconds. |
| `orientation` | `Exclude<TimepickerOrientation, "auto">` | "horizontal" | The orientation of the input. |
| `period` | `"am" \| "pm"` | "am" | The 12-hour time period. |
| `view` | `"hour" \| "minute" \| "second"` | "hour" | The view used to input time. |
| `hour-label` | `string` | "Hour" | The label for the hour field. |
| `minute-label` | `string` | "Minute" | The label for the minute field. |
| `second-label` | `string` | "Second" | The label for the second field. |
| `period-toggle-label` | `string` | "AM or PM" | The accessible label given to the period toggle. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |
| `blackoutTimes` | `(time: TimeParts) => boolean \| undefined` | A function used to determine whether a time cannot be selected. |
| `hourOfPeriod` | `number \| null` | The hour in 12‑hour time from 1..12. |
| `currentFormat` _(readonly)_ | `Exclude<TimepickerFormat, "auto">` | The current time format. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `view-change` | `CustomEvent` | Dispatched when the view changes. |
| `change` | `Event` | Dispatched when the selected time changes. |

**CSS custom properties** — 34 total across 34 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-timepicker-input-field-container-width` | Width of the input field container. |
| `--m3e-timepicker-input-field-height` | Height of the input fields. |
| `--m3e-timepicker-input-field-container-shape` | Corner radius of the input field container. |
| `--m3e-timepicker-input-field-font-size` | Font size of the input field text. |
| `--m3e-timepicker-input-field-font-weight` | Font weight of the input field text. |
| `--m3e-timepicker-input-field-line-height` | Line height of the input field text. |
| `--m3e-timepicker-input-field-tracking` | Letter spacing of the input field text. |
| `--m3e-timepicker-input-field-label-unselected-color` | Text color of unselected input field labels. |
| `--m3e-timepicker-input-field-unselected-container-color` | Background color of unselected input fields. |
| `--m3e-timepicker-input-field-unselected-hover-state-layer-color` | State layer color on hover for unselected input fields. |
| `--m3e-timepicker-input-field-unselected-focus-state-layer-color` | State layer color on focus for unselected input fields. |
| `--m3e-timepicker-input-field-unselected-pressed-state-layer-color` | State layer color on pressed for unselected input fields. |

_…22 more families. See source for the full list._

### `<m3e-timepicker-input-period-toggle>`

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `period` | `"am" \| "pm"` | "am" | The 12-hour time period. |
| `orientation` | `Exclude<TimepickerOrientation, "auto">` | "vertical" | The orientation of the toggle. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` |  |

### `<m3e-timepicker-toggle>`

An element, nested within a clickable element, used to toggle a timepicker.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/timepicker/README.md) (MIT). · Material spec: <https://m3.material.io/components/time-pickers/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/timepicker/TimepickerElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/timepicker/TimepickerElement.ts)
- [`packages/web/src/timepicker/TimepickerDialElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/timepicker/TimepickerDialElement.ts)
- [`packages/web/src/timepicker/TimepickerInputElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/timepicker/TimepickerInputElement.ts)
- [`packages/web/src/timepicker/TimepickerInputPeriodToggleElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/timepicker/TimepickerInputPeriodToggleElement.ts)
- [`packages/web/src/timepicker/TimepickerToggleElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/timepicker/TimepickerToggleElement.ts)

**README drift corrected** (6 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
