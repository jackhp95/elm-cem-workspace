# badge

**Family:** [Feedback & status](../concepts/choosing-components.md#feedback) · See also: [snackbar](snackbar.md), [tooltip](tooltip.md), [loading-indicator](loading-indicator.md), [progress-indicator](progress-indicator.md), [skeleton](skeleton.md)

The `m3e-badge` component is a compact visual indicator used to label content. Designed according to Material Design 3 guidelines, it can display counts, presence, or semantic emphasis, and is attachable to icons, buttons, or other components. Badges support dynamic sizing, color, and shape, ensuring clarity and accessibility while maintaining a consistent, expressive appearance across surfaces.

```ts
import "@m3e/web/badge";
```

## Examples

```html
<m3e-button id="button">Button</m3e-button><m3e-badge for="button">10</m3e-badge>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Notification count badge on a button**

```html
<m3e-button id="notifications" variant="tonal">
  <m3e-icon slot="icon" name="notifications"></m3e-icon>
  Alerts
</m3e-button>
<m3e-badge for="notifications">10</m3e-badge>
```

**Small dot badge and large count badge on icons**

```html
<m3e-icon id="mail-icon" name="mail"></m3e-icon>
<m3e-badge for="mail-icon" size="small" position="above-after"></m3e-badge>
<m3e-icon id="cart-icon" name="shopping_cart"></m3e-icon>
<m3e-badge for="cart-icon" size="large" position="above-after">99+</m3e-badge>
```

## Common mistakes

**Do not wrap the badge and its target in a positioning container.** The badge positions itself relative to the element referenced by `for` — no `relative`/`absolute` wrapper needed. See [wrapping self-positioning components](/anti-patterns/wrapping-self-positioning-components).

```html
<!-- ✅ Correct -->
<m3e-icon-button id="notifications">…</m3e-icon-button>
<m3e-badge for="notifications">5</m3e-badge>

<!-- ❌ Wrong — fights the component's positioning -->
<span style="position: relative">
  <m3e-icon-button>…</m3e-icon-button>
  <m3e-badge style="position: absolute; top: 0; right: 0">5</m3e-badge>
</span>
```

## API

### `<m3e-badge>`

A visual indicator used to label content.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `size` | `"small" \| "medium" \| "large"` | "medium" | The size of the badge. |
| `position` | `"above-after" \| "above-before" \| "below-before" \| "below-after" \| "before" \| "after" \| "above" \| "below"` | "above-after" | The position of the badge, when attached to another element. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the badge. |

**CSS custom properties** — 14 total across 8 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-badge-shape` | Corner radius of the badge. |
| `--m3e-badge-color` | Foreground color of badge content. |
| `--m3e-badge-container-color` | Background color of the badge. |
| `--m3e-badge-[size]-size` | Fixed dimensions for small badge. Used for minimal indicators (e.g. dot). |
| `--m3e-badge-[size]-font-size` | Font size for medium badge label. |
| `--m3e-badge-[size]-font-weight` | Font weight for medium badge label. |
| `--m3e-badge-[size]-line-height` | Line height for medium badge label. |
| `--m3e-badge-[size]-tracking` | Letter spacing for medium badge label. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/badge/README.md) (MIT). · Material spec: <https://m3.material.io/components/badges/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/badge/BadgeElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/badge/BadgeElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
