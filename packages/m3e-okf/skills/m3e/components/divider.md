# divider

**Family:** [Containers & surfaces](../concepts/choosing-components.md#containers) · See also: [card](card.md), [content-pane](content-pane.md), [dialog](dialog.md), [bottom-sheet](bottom-sheet.md), [split-pane](split-pane.md), [expansion-panel](expansion-panel.md), [menu](menu.md)

The `m3e-divider` component visually separates content within layouts, lists, or containers using a thin, unobtrusive line. It supports horizontal and vertical orientation, with optional inset variants to align with layout padding and visual hierarchy. The divider thickness, color, and inset behavior are customizable via CSS properties to maintain consistency across surfaces. It is designed to reinforce spatial relationships without drawing attention, preserving focus on primary content.

```ts
import "@m3e/web/divider";
```

## Examples

```html
<m3e-divider></m3e-divider>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Dividers separating a settings list**

```html
<ul>
  <li>
    <span>Profile</span>
  </li>
  <m3e-divider inset-start></m3e-divider>
  <li>
    <span>Privacy</span>
  </li>
  <m3e-divider inset-start></m3e-divider>
  <li>
    <span>Notifications</span>
  </li>
</ul>
```

**Vertical divider between toolbar actions**

```html
<nav>
  <m3e-button variant="text">
    <m3e-icon slot="icon" name="format_bold"></m3e-icon>
    Bold
  </m3e-button>
  <m3e-divider vertical></m3e-divider>
  <m3e-button variant="text">
    <m3e-icon slot="icon" name="link"></m3e-icon>
    Link
  </m3e-button>
</nav>
```

## API

### `<m3e-divider>`

A thin line that separates content in lists or other containers.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `inset` | `boolean` | false | Whether the divider is indented with equal padding on both sides. |
| `inset-start` | `boolean` | false | Whether the divider is indented with padding on the leading side. |
| `inset-end` | `boolean` | false | Whether the divider is indented with padding on the trailing side. |
| `vertical` | `boolean` | false | Whether the divider is vertically aligned with adjacent content. |

**CSS custom properties** — 5 total across 5 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-divider-thickness` | Thickness of the divider line. |
| `--m3e-divider-color` | Color of the divider line. |
| `--m3e-divider-inset-size` | When inset, fallback inset size used when no specific start or end inset is provided. |
| `--m3e-divider-inset-start-size` | When inset, leading inset size. |
| `--m3e-divider-inset-end-size` | When inset, trailing inset size. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/divider/README.md) (MIT). · Material spec: <https://m3.material.io/components/divider/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/divider/DividerElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/divider/DividerElement.ts)
