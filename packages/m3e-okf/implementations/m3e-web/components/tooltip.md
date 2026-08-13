# tooltip

**Family:** [Feedback & status](../concepts/choosing-components.md#feedback) · See also: [badge](badge.md), [snackbar](snackbar.md), [loading-indicator](loading-indicator.md), [progress-indicator](progress-indicator.md), [skeleton](skeleton.md)

The `@m3e/web/tooltip` module provides tooltip and rich‑tooltip components for delivering contextual guidance, from simple hover descriptions to multi‑line, expressive content anchored to a control.

```ts
import "@m3e/web/tooltip";
```

**Elements:** `<m3e-rich-tooltip>`, `<m3e-rich-tooltip-action>`, `<m3e-tooltip>`

## Examples

```html
<m3e-icon-button id="button" aria-label="Back">
  <m3e-icon name="arrow_back"></m3e-icon>
</m3e-icon-button>
<m3e-tooltip for="button">Go Back</m3e-tooltip>
```

```html
<m3e-icon-button id="btnSettings">
  <m3e-icon name="settings"></m3e-icon>
</m3e-icon-button>
<m3e-rich-tooltip for="btnSettings">
  <span slot="subhead">New settings available</span>
  Now you can adjust the uploaded image quality, and upgrade your available storage space.
  <div slot="actions">
    <m3e-button>
      <m3e-rich-tooltip-action>Learn more</m3e-rich-tooltip-action>
    </m3e-button>
  </div>
</m3e-rich-tooltip>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Simple tooltip on an icon button**

```html
<m3e-button id="refreshBtn" variant="tonal">
  <m3e-icon slot="icon" name="refresh"></m3e-icon>
</m3e-button>
<m3e-tooltip for="refreshBtn" position="above">Refresh data</m3e-tooltip>
```

**Rich tooltip with subhead and actions**

```html
<m3e-button id="infoBtn" variant="outlined">
  <m3e-icon slot="icon" name="info"></m3e-icon>
  Details
</m3e-button>
<m3e-rich-tooltip for="infoBtn" position="below-after" show-delay="100">
  <span slot="subhead">New settings available</span>
  Now you can adjust uploaded image quality and upgrade your available storage space.
  <div slot="actions">
    <m3e-button variant="text">
      <m3e-rich-tooltip-action>Learn more</m3e-rich-tooltip-action>
    </m3e-button>
  </div>
</m3e-rich-tooltip>
```

**Tooltip with touch gestures disabled**

```html
<m3e-button id="deleteBtn" variant="text">
  <m3e-icon slot="icon" name="delete"></m3e-icon>
</m3e-button>
<m3e-tooltip for="deleteBtn" position="after" touch-gestures="off" hide-delay="400">Delete item</m3e-tooltip>
```

## API

### `<m3e-rich-tooltip>`

Provides contextual details for a control, such as explaining the value or purpose of a feature.

**Display:** `contents`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |
| `hide-delay` | `number` | 200 | The amount of time, in milliseconds, before hiding the tooltip. |
| `position` | `"above-after" \| "above-before" \| "below-before" \| "below-after" \| "before" \| "after" \| "above" \| "below"` | "below-after" | The position of the tooltip. |
| `show-delay` | `number` | 0 | The amount of time, in milliseconds, before showing the tooltip. |
| `touch-gestures` | `"auto" \| "on" \| "off"` | "auto" | The mode in which to handle touch gestures. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `isOpen` _(readonly)_ | `boolean` | Whether the tooltip is currently open. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | The main supporting text of the tooltip. |
| `subhead` | Optional subhead text displayed above the supporting content. |
| `actions` | Optional action elements displayed at the bottom of the tooltip. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforetoggle` | `ToggleEvent` | Dispatched before the toggle state changes. |
| `toggle` | `ToggleEvent` | Dispatched after the toggle state has changed. |

**CSS custom properties** — 20 total across 20 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-rich-tooltip-padding-top` | Top padding of the tooltip container. |
| `--m3e-rich-tooltip-padding-bottom` | Bottom padding of the tooltip container (when no actions are present). |
| `--m3e-rich-tooltip-padding-inline` | Horizontal padding of the tooltip container. |
| `--m3e-rich-tooltip-max-width` | Maximum width of the tooltip surface. |
| `--m3e-rich-tooltip-shape` | Border‑radius of the tooltip container. |
| `--m3e-rich-tooltip-container-color` | Background color of the tooltip surface. |
| `--m3e-rich-tooltip-subhead-color` | Color of the subhead text. |
| `--m3e-rich-tooltip-subhead-font-size` | Font size of the subhead text. |
| `--m3e-rich-tooltip-subhead-font-weight` | Font weight of the subhead text. |
| `--m3e-rich-tooltip-subhead-line-height` | Line height of the subhead text. |
| `--m3e-rich-tooltip-subhead-tracking` | Letter‑spacing of the subhead text. |
| `--m3e-rich-tooltip-subhead-bottom-space` | Space below the subhead before the supporting text. |

_…8 more families. See source for the full list._

### `<m3e-rich-tooltip-action>`

An element, nested within a clickable element, used to dismiss a parenting rich tooltip.

**Display:** `contents`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disable-restore-focus` | `boolean` | false | Whether to focus should not be restored to the trigger when activated. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the action. |

### `<m3e-tooltip>`

Adds additional context to a button or other UI element.

**Display:** `contents`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |
| `hide-delay` | `number` | 200 | The amount of time, in milliseconds, before hiding the tooltip. |
| `position` | `"above" \| "below" \| "before" \| "after"` | "below" | The position of the tooltip. |
| `show-delay` | `number` | 0 | The amount of time, in milliseconds, before showing the tooltip. |
| `touch-gestures` | `"auto" \| "on" \| "off"` | "auto" | The mode in which to handle touch gestures. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `isOpen` _(readonly)_ | `boolean` | Whether the tooltip is currently open. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the tooltip. |

**CSS custom properties** — 12 total across 12 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-tooltip-padding` | Internal spacing of the tooltip container. |
| `--m3e-tooltip-min-width` | Minimum width of the tooltip. |
| `--m3e-tooltip-max-width` | Maximum width of the tooltip. |
| `--m3e-tooltip-min-height` | Minimum height of the tooltip container. |
| `--m3e-tooltip-max-height` | Maximum height of the tooltip. |
| `--m3e-tooltip-shape` | Border radius of the tooltip container. |
| `--m3e-tooltip-container-color` | Background color of the tooltip. |
| `--m3e-tooltip-supporting-text-color` | Text color of supporting text. |
| `--m3e-tooltip-supporting-text-font-size` | Font size of supporting text. |
| `--m3e-tooltip-supporting-text-font-weight` | Font weight of supporting text. |
| `--m3e-tooltip-supporting-text-line-height` | Line height of supporting text. |
| `--m3e-tooltip-supporting-text-tracking` | Letter spacing of supporting text. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/tooltip/README.md) (MIT). · Material spec: <https://m3.material.io/components/tooltips/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/tooltip/RichTooltipElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/tooltip/RichTooltipElement.ts)
- [`packages/web/src/tooltip/RichTooltipActionElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/tooltip/RichTooltipActionElement.ts)
- [`packages/web/src/tooltip/TooltipElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/tooltip/TooltipElement.ts)

**README drift corrected** (3 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
