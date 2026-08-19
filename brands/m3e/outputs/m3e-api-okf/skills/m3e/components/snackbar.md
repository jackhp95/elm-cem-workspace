# snackbar

**Family:** [Feedback & status](../concepts/choosing-components.md#feedback) · See also: [badge](badge.md), [tooltip](tooltip.md), [loading-indicator](loading-indicator.md), [progress-indicator](progress-indicator.md), [skeleton](skeleton.md)

The `@m3e/snackbar` package provides the `M3eSnackbar` global service on `window` (`globalThis`) used to present short updates about application processes at the bottom of the screen from anywhere in an application.

```ts
import "@m3e/web/snackbar";
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Dismissible snackbar with action**

```html
<m3e-snackbar action="Undo" dismissible duration="5000" close-label="Dismiss">
  Message archived
  <m3e-icon slot="close-icon" name="close"></m3e-icon>
</m3e-snackbar>
```

## API

### `<m3e-snackbar>`

Presents short updates about application processes at the bottom of the screen.

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `action` | `string` | "" | The label of the snackbar's action. |
| `close-label` | `string` | "Close" | The accessible label given to the button used to dismiss the snackbar. |
| `dismissible` | `boolean` | false | Whether a button is presented that can be used to close the snackbar. |
| `duration` | `number` | 3000 | The length of time, in milliseconds, to wait before automatically dismissing the snackbar. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `current` _(readonly)_ | `M3eSnackbarElement \| null` | The currently open snackbar. |
| `isActionTaken` _(readonly)_ | `boolean` | Whether the user clicked the action. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the snackbar. |
| `close-icon` | Renders the icon of the button used to close the snackbar. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforetoggle` |  | Dispatched before the toggle state changes. |
| `toggle` |  | Dispatched after the toggle state has changed. |

**CSS custom properties** — 6 total across 6 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-snackbar-margin` | Vertical offset from the bottom of the viewport. |
| `--m3e-snackbar-container-shape` | Border radius of the snackbar container. |
| `--m3e-snackbar-container-color` | Background color of the snackbar. |
| `--m3e-snackbar-padding` | Internal spacing of the snackbar container. |
| `--m3e-snackbar-min-width` | Minimum width of the snackbar. |
| `--m3e-snackbar-max-width` | Maximum width of the snackbar. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/snackbar/README.md) (MIT). · Material spec: <https://m3.material.io/components/snackbar/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/snackbar/SnackbarElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/snackbar/SnackbarElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
