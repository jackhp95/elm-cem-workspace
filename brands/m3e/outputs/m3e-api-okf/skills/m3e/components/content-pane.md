# content-pane

**Family:** [Containers & surfaces](../concepts/choosing-components.md#containers) · See also: [card](card.md), [dialog](dialog.md), [bottom-sheet](bottom-sheet.md), [split-pane](split-pane.md), [expansion-panel](expansion-panel.md), [divider](divider.md), [menu](menu.md)

The `m3e-content-pane` component renders a shaped surface with padding and vertical scrolling for document‑like content.

```ts
import "@m3e/web/content-pane";
```

## Examples

```html
<m3e-content-pane>
  <p>This is some scrollable content.</p>
  <p>More content here...</p>
</m3e-content-pane>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Scrollable article surface**

```html
<m3e-content-pane>
  <header>
    <h2>Release notes</h2>
  </header>
  <p>This version introduces a redesigned navigation drawer and refined motion.</p>
  <m3e-divider></m3e-divider>
  <p>Performance improvements reduce initial load time across all surfaces.</p>
  <p>Several accessibility fixes were applied to form controls.</p>
</m3e-content-pane>
```

## API

### `<m3e-content-pane>`

A shaped surface for vertically scrollable content.

**Display:** `block`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the pane. |

**CSS custom properties** — 3 total across 3 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-content-pane-container-shape` | Corner radius applied to the pane’s outer surface. |
| `--m3e-content-pane-container-color` | Background color of the pane’s surface. |
| `--m3e-content-pane-container-padding` | Internal padding applied to all sides of the scrollable content. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/content-pane/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/content-pane/ContentPaneElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/content-pane/ContentPaneElement.ts)
