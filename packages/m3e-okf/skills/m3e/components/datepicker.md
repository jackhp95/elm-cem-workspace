# datepicker

**Family:** [Data & collections](../concepts/choosing-components.md#data-display) · See also: [list](list.md), [tree](tree.md), [calendar](calendar.md), [date-input](date-input.md), [timepicker](timepicker.md)

The `m3e-datepicker` component presents a temporary, structured surface for selecting dates across month, year, and multi-year views. It supports single-date and range selection, enforces minimum, maximum, and blackout constraints, and exposes styling hooks for highlighting special date states.

```ts
import "@m3e/web/datepicker";
```

**Elements:** `<m3e-datepicker>`, `<m3e-datepicker-toggle>`

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Booking range picker with constraints**

```html
<form>
  <label for="stay">Choose your stay</label>
  <m3e-datepicker id="stay" range variant="docked" clearable label="Select dates" start-view="month">
    <m3e-datepicker-toggle for="stay">
      <m3e-icon name="calendar_month"></m3e-icon>
    </m3e-datepicker-toggle>
  </m3e-datepicker>
</form>
```

**Modal single-date picker**

```html
<div>
  <label for="due">Due date</label>
  <m3e-datepicker id="due" variant="modal" clearable label="Select date">
    <m3e-datepicker-toggle for="due">
      <m3e-icon name="event"></m3e-icon>
    </m3e-datepicker-toggle>
  </m3e-datepicker>
</div>
```

## API

### `<m3e-datepicker>`

Presents a date picker on a temporary surface.

**Display:** `none`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `"docked" \| "modal" \| "auto"` | "docked" | The appearance variant of the picker. |
| `clearable` | `boolean` | false | Whether the user can clear the selected date and close the picker. |
| `date` | `Date \| null` | null | The selected date. |
| `max-date` | `Date \| null` | null | The maximum date that can be selected. |
| `min-date` | `Date \| null` | null | The minimum date that can be selected. |
| `range` | `boolean` | false | Whether a range of dates can be selected. |
| `range-end` | `Date \| null` | null | End of a date range. |
| `range-start` | `Date \| null` | null | Start of a date range. |
| `start-at` | `Date \| null` | null | A date specifying the period (month or year) to start the calendar in. |
| `start-view` | `"month" \| "year" \| "multi-year"` | "month" | The initial view used to select a date. |
| `previous-month-label` | `string` | "Previous month" | The accessible label given to the button used to move to the previous month. |
| `next-month-label` | `string` | "Next month" | The accessible label given to the button used to move to the next month. |
| `previous-year-label` | `string` | "Previous year" | The accessible label given to the button used to move to the previous year. |
| `next-year-label` | `string` | "Next year" | The accessible label given to the button used to move to the next year. |
| `previous-multi-year-label` | `string` | "Previous 24 years" | The accessible label given to the button used to move to the previous 24 years. |
| `next-multi-year-label` | `string` | "Next 24 years" | The accessible label given to the button used to move to the next 24 years. |
| `clear-label` | `string` | "Clear" | The label given to the button used clear the selected date and close the picker. |
| `confirm-label` | `string` | "OK" | The label given to the button used apply the selected date and close the picker. |
| `dismiss-label` | `string` | "Cancel" | The label given to the button used discard the selected date and close the picker. |
| `label` | `string` | "Select date" | The label given to the the picker. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `blackoutDates` | `((date: Date) => boolean) \| null` | A function used to determine whether a date cannot be selected. |
| `specialDates` | `((date: Date) => boolean) \| null` | A function used to determine whether a date is special. |
| `isOpen` _(readonly)_ |  | Whether the picker is open. |
| `currentVariant` _(readonly)_ | `Exclude<DatepickerVariant, "auto">` | The current variant applied to the picker. |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected date changes. |
| `beforetoggle` |  | Dispatched before the toggle state changes. |
| `toggle` |  | Dispatched after the toggle state has changed. |

**CSS custom properties** — 23 total across 23 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-datepicker-container-padding-block` | Block‑axis padding of the date picker container. |
| `--m3e-datepicker-container-padding-inline` | Inline‑axis padding of the date picker container. |
| `--m3e-datepicker-container-color` | Background color of the standard container surface. |
| `--m3e-datepicker-container-elevation` | Elevation shadow applied to the container surface. |
| `--m3e-datepicker-modal-headline-color` | Color used for the modal headline text. |
| `--m3e-datepicker-modal-headline-font-size` | Font size used for the modal headline text. |
| `--m3e-datepicker-modal-headline-font-weight` | Font weight used for the modal headline text. |
| `--m3e-datepicker-modal-headline-line-height` | Line height used for the modal headline text. |
| `--m3e-datepicker-modal-headline-tracking` | Letter spacing used for the modal headline text. |
| `--m3e-datepicker-modal-supporting-text-color` | Color used for supporting text in modal mode. |
| `--m3e-datepicker-modal-supporting-text-font-size` | Font size used for supporting text in modal mode. |
| `--m3e-datepicker-modal-supporting-text-font-weight` | Font weight used for supporting text in modal mode. |

_…11 more families. See source for the full list._

### `<m3e-datepicker-toggle>`

An element, nested within a clickable element, used to toggle a datepicker.

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

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/datepicker/README.md) (MIT). · Material spec: <https://m3.material.io/components/date-pickers/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/datepicker/DatepickerElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/datepicker/DatepickerElement.ts)
- [`packages/web/src/datepicker/DatepickerToggleElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/datepicker/DatepickerToggleElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
