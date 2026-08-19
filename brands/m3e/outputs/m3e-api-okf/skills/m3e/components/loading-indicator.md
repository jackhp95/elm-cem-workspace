# loading-indicator

**Family:** [Feedback & status](../concepts/choosing-components.md#feedback) · See also: [badge](badge.md), [snackbar](snackbar.md), [tooltip](tooltip.md), [progress-indicator](progress-indicator.md), [skeleton](skeleton.md)

The `m3e-loading-indicator` component uses animation to grab attention, mitigate perceived latency, and indicate that an activity is in progress. Use the `variant` attribute to switch between `uncontained` (default) and `contained` appearances for contrast and context.

```ts
import "@m3e/web/loading-indicator";
```

## Examples

```html
<m3e-loading-indicator></m3e-loading-indicator>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Inline loading indicator while content loads**

```html
<section>
  <header>
    <h2>Your dashboard</h2>
  </header>
  <div>
    <m3e-loading-indicator></m3e-loading-indicator>
    <p>Loading your latest activity...</p>
  </div>
</section>
```

**Contained loading indicator inside a refresh button**

```html
<div>
  <m3e-button variant="tonal" disabled>
    <m3e-loading-indicator slot="icon" variant="contained"></m3e-loading-indicator>
    Refreshing
  </m3e-button>
</div>
```

## API

### `<m3e-loading-indicator>`

Shows indeterminate progress for a short wait time.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `"uncontained" \| "contained"` | "uncontained" | The appearance variant of the indicator. |

**CSS custom properties** — 6 total across 6 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-loading-indicator-active-indicator-color` | Uncontained active indicator color. |
| `--m3e-loading-indicator-contained-active-indicator-color` | Contained active indicator color. |
| `--m3e-loading-indicator-contained-container-color` | Contained container (background) color. |
| `--m3e-loading-indicator-active-indicator-size` | Size of the active indicator. |
| `--m3e-loading-indicator-container-shape` | Container shape. |
| `--m3e-loading-indicator-container-size` | Container size. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/loading-indicator/README.md) (MIT). · Material spec: <https://m3.material.io/components/loading-indicator/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/loading-indicator/LoadingIndicatorElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/loading-indicator/LoadingIndicatorElement.ts)
