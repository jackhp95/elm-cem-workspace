# calendar

**Family:** [Data & collections](../concepts/choosing-components.md#data-display) · See also: [list](list.md), [tree](tree.md), [datepicker](datepicker.md), [date-input](date-input.md), [timepicker](timepicker.md)

The `m3e-calendar` component provides structured navigation and selection across month, year, and multi-year views. It supports single-date and range selection, applies disabled rules including minimum, maximum, and blackout constraints, and provides styling hooks for special date states.

```ts
import "@m3e/web/calendar";
```

**Elements:** `<m3e-calendar>`, `<m3e-month-view>`, `<m3e-multi-year-view>`, `<m3e-year-view>`

## Examples

```html
<m3e-calendar date="2025-12-13"></m3e-calendar>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Date picker calendar with a custom header**

```html
<m3e-calendar date="2025-12-13" min-date="2025-01-01" max-date="2026-12-31">
  <span slot="header">Select a delivery date</span>
</m3e-calendar>
```

**Range calendar starting in the multi-year view**

```html
<m3e-calendar start-view="multi-year" start-at="2026-06-01" range-start="2026-06-10" range-end="2026-06-17" next-month-label="Next month" previous-month-label="Previous month">
  <span slot="header">Choose your stay</span>
</m3e-calendar>
```

## API

### `<m3e-calendar>`

A calendar used to select a date.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `date` | `Date \| null` | null | The selected date. |
| `max-date` | `Date \| null` | null | The maximum date that can be selected. |
| `min-date` | `Date \| null` | null | The minimum date that can be selected. |
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

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `blackoutDates` | `((date: Date) => boolean) \| null` | A function used to determine whether a date cannot be selected. |
| `specialDates` | `((date: Date) => boolean) \| null` | A function used to determine whether a date is special. |
| `periodLabel` _(readonly)_ | `string` | The label to present for the current period. |
| `canMovePreviousPeriod` _(readonly)_ | `boolean` | Whether the calendar can move to the previous period. |
| `canMoveNextPeriod` _(readonly)_ | `boolean` | Whether the calendar can move to the next period. |

**Slots**

| Slot | Description |
| --- | --- |
| `header` | Renders the header of the calendar. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected date changes. |

**CSS custom properties** — 36 total across 36 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-calendar-container-color` | Background color of the container surface. |
| `--m3e-calendar-container-elevation` | Elevation shadow applied to the container surface. |
| `--m3e-calendar-container-shape` | Corner radius of the container surface. |
| `--m3e-calendar-padding` | Padding applied to the calendar header and body. |
| `--m3e-calendar-period-button-text-color` | Text color used for the period‑navigation buttons in the header. |
| `--m3e-calendar-weekday-font-size` | Font size of weekday labels in month view. |
| `--m3e-calendar-weekday-font-weight` | Font weight of weekday labels in month view. |
| `--m3e-calendar-weekday-line-height` | Line height of weekday labels in month view. |
| `--m3e-calendar-weekday-tracking` | Letter spacing of weekday labels in month view. |
| `--m3e-calendar-weekday-color` | Text color for weekday labels in month view. |
| `--m3e-calendar-date-font-size` | Font size of date cells in month view. |
| `--m3e-calendar-date-font-weight` | Font weight of date cells in month view. |

_…24 more families. See source for the full list._

### `<m3e-month-view>`

An internal component used to display a single month in a calendar.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `range-start` | `Date \| null` | null | Start of a date range. |
| `range-end` | `Date \| null` | null | End of a date range. |
| `active` | `boolean` | false | Whether the view is active. |
| `today` | `Date` | new Date() | Today's date. |
| `date` | `Date \| null` | null | The selected date. |
| `active-date` | `Date` | new Date() | The active date. |
| `min-date` | `Date \| null` | null | The minimum date that can be selected. |
| `max-date` | `Date \| null` | null | The maximum date that can be selected. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `blackoutDates` | `((date: Date) => boolean) \| null` | A function used to determine whether a date cannot be selected. |
| `specialDates` | `((date: Date) => boolean) \| null` | A function used to determine whether a date is special. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` |  |
| `active-change` | `Event` |  |

### `<m3e-multi-year-view>`

An internal component used to display a year selector in a calendar.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `boolean` | false | Whether the view is active. |
| `today` | `Date` | new Date() | Today's date. |
| `date` | `Date \| null` | null | The selected date. |
| `active-date` | `Date` | new Date() | The active date. |
| `min-date` | `Date \| null` | null | The minimum date that can be selected. |
| `max-date` | `Date \| null` | null | The maximum date that can be selected. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` |  |
| `active-change` | `Event` |  |

### `<m3e-year-view>`

An internal component used to display a single year in a calendar.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `active` | `boolean` | false | Whether the view is active. |
| `today` | `Date` | new Date() | Today's date. |
| `date` | `Date \| null` | null | The selected date. |
| `active-date` | `Date` | new Date() | The active date. |
| `min-date` | `Date \| null` | null | The minimum date that can be selected. |
| `max-date` | `Date \| null` | null | The maximum date that can be selected. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` |  |
| `active-change` | `Event` |  |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/calendar/README.md) (MIT). · Material spec: <https://m3.material.io/components/date-pickers/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/calendar/CalendarElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/calendar/CalendarElement.ts)
- [`packages/web/src/calendar/MonthViewElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/calendar/MonthViewElement.ts)
- [`packages/web/src/calendar/MultiYearViewElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/calendar/MultiYearViewElement.ts)
- [`packages/web/src/calendar/YearViewElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/calendar/YearViewElement.ts)

**README drift corrected** (3 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
