# expansion-panel

**Family:** [Containers & surfaces](../concepts/choosing-components.md#containers) · See also: [card](card.md), [content-pane](content-pane.md), [dialog](dialog.md), [bottom-sheet](bottom-sheet.md), [split-pane](split-pane.md), [divider](divider.md), [menu](menu.md)

The `@m3e/web/expansion-panel` module provides expressive, accessible components for organizing content in collapsible sections and coordinated groups. It includes: - **`m3e-expansion-panel`** — An accessible, animated details-summary view for organizing content in collapsible sections. Supports custom header, content, actions, and toggle icon slots, configurable toggle position and direction, open/close states, lifecycle events, and rich theming via CSS custom properties for elevation, shape, spacing, and color. - **`m3e-accordion`** — Organizes multiple expansion panels into a coordinated, accessible group. Supports single or multiple open panels via the `multi` attribute, expressive theming and shape control for grouped layouts, and manages open/close state across child panels for interactive disclosure patterns.

```ts
import "@m3e/web/expansion-panel";
```

**Elements:** `<m3e-accordion>`, `<m3e-expansion-header>`, `<m3e-expansion-panel>`

## Examples

```html
<m3e-accordion>
  <m3e-expansion-panel>
    <span slot="header">Panel 1</span>
    I am content for the first expansion panel
  </m3e-expansion-panel>
  <m3e-expansion-panel>
    <span slot="header">Panel 2</span>
    I am content for the second expansion panel
  </m3e-expansion-panel>
</m3e-accordion>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**FAQ accordion with single-open behavior**

```html
<m3e-accordion>
  <m3e-expansion-panel open>
    <span slot="header">How do I reset my password?</span>
    <m3e-icon slot="toggle-icon" name="expand_more"></m3e-icon>
    <p>Open Settings, choose Security, then select Reset password. A link will be sent to your email.</p>
  </m3e-expansion-panel>
  <m3e-expansion-panel>
    <span slot="header">Can I change my plan later?</span>
    <p>Yes. Plans can be upgraded or downgraded at any time from the Billing page.</p>
  </m3e-expansion-panel>
  <m3e-expansion-panel>
    <span slot="header">Where can I download invoices?</span>
    <p>All invoices are available under Billing, in the Invoice history section.</p>
  </m3e-expansion-panel>
</m3e-accordion>
```

**Settings panel with custom header and actions**

```html
<m3e-expansion-panel toggle-position="before">
  <div slot="header">
    <m3e-icon name="notifications"></m3e-icon>
    <span>Notification preferences</span>
  </div>
  <p>Choose how and when we contact you about account activity and product updates.</p>
  <div slot="actions">
    <m3e-button variant="text">Cancel</m3e-button>
    <m3e-button variant="filled">Save</m3e-button>
  </div>
</m3e-expansion-panel>
```

**Multi-open accordion with horizontal toggle**

```html
<m3e-accordion multi>
  <m3e-expansion-panel toggle-direction="horizontal">
    <span slot="header">Shipping</span>
    <p>Standard delivery arrives in 3 to 5 business days.</p>
  </m3e-expansion-panel>
  <m3e-expansion-panel toggle-direction="horizontal">
    <span slot="header">Returns</span>
    <p>Items can be returned within 30 days of receipt.</p>
  </m3e-expansion-panel>
</m3e-accordion>
```

## API

### `<m3e-accordion>`

Combines multiple expansion panels in to an accordion.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `multi` | `boolean` | false | Whether multiple expansion panels can be open at the same time. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `panels` _(readonly)_ |  | The panels of the accordion. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the panels of the accordion. |

### `<m3e-expansion-header>`

A button used to toggle the expanded state of an expansion panel.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `hide-toggle` | `boolean` | false | Whether to hide the expansion toggle. |
| `toggle-direction` | `"vertical" \| "horizontal"` | "vertical" | The direction of the expansion toggle. |
| `toggle-position` | `"before" \| "after"` | "after" | The position of the expansion toggle. |
| `disabled` | `boolean` | false | Whether the element is disabled. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the header. |
| `toggle-icon` | Renders the icon of the expansion toggle. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 10 total across 10 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-expansion-header-collapsed-height` | Height of the header when the panel is collapsed. |
| `--m3e-expansion-header-expanded-height` | Height of the header when the panel is expanded. |
| `--m3e-expansion-header-padding-left` | Left padding inside the header. |
| `--m3e-expansion-header-padding-right` | Right padding inside the header. |
| `--m3e-expansion-header-spacing` | Spacing between header elements. |
| `--m3e-expansion-header-toggle-icon-size` | Size of the toggle icon (e.g. chevron). |
| `--m3e-expansion-header-font-size` | The font size of the header text. |
| `--m3e-expansion-header-font-weight` | The font weight of the header text. |
| `--m3e-expansion-header-line-height` | The line height of the header text. |
| `--m3e-expansion-header-tracking` | Letter spacing (tracking) of the header text. |

### `<m3e-expansion-panel>`

An expandable details-summary view.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `hide-toggle` | `boolean` | false | Whether to hide the expansion toggle. |
| `open` | `boolean` | false | Whether the panel is expanded. |
| `toggle-direction` | `"vertical" \| "horizontal"` | "vertical" | The direction of the expansion toggle. |
| `toggle-position` | `"before" \| "after"` | "after" | The position of the expansion toggle. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the detail of the panel. |
| `actions` | Renders the actions bar of the panel. |
| `header` | Renders the header content. |
| `toggle-icon` | Renders the expansion toggle icon. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `opening` |  | Dispatched when the expansion panel begins to open. |
| `opened` |  | Dispatched when the expansion panel has opened. |
| `closing` |  | Dispatched when the expansion panel begins to close. |
| `closed` |  | Dispatched when the expansion panel has closed. |

**CSS custom properties** — 23 total across 23 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-expansion-header-collapsed-height` | Height of the header when the panel is collapsed. |
| `--m3e-expansion-header-expanded-height` | Height of the header when the panel is expanded. |
| `--m3e-expansion-header-padding-left` | Left padding inside the header. |
| `--m3e-expansion-header-padding-right` | Right padding inside the header. |
| `--m3e-expansion-header-spacing` | Spacing between header elements. |
| `--m3e-expansion-header-toggle-icon-size` | Size of the toggle icon (e.g. chevron). |
| `--m3e-expansion-header-font-size` | The font size of the header text. |
| `--m3e-expansion-header-font-weight` | The font weight of the header text. |
| `--m3e-expansion-header-line-height` | The line height of the header text. |
| `--m3e-expansion-header-tracking` | Letter spacing (tracking) of the header text. |
| `--m3e-expansion-panel-text-color` | Color of the panel's text content. |
| `--m3e-expansion-panel-disabled-text-color` | Color of the panel's text content, when disabled. |

_…11 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/expansion-panel/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/expansion-panel/AccordionElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/expansion-panel/AccordionElement.ts)
- [`packages/web/src/expansion-panel/ExpansionHeaderElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/expansion-panel/ExpansionHeaderElement.ts)
- [`packages/web/src/expansion-panel/ExpansionPanelElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/expansion-panel/ExpansionPanelElement.ts)

**README drift corrected** (2 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
