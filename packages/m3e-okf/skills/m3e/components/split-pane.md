# split-pane

**Family:** [Containers & surfaces](../concepts/choosing-components.md#containers) · See also: [card](card.md), [content-pane](content-pane.md), [dialog](dialog.md), [bottom-sheet](bottom-sheet.md), [expansion-panel](expansion-panel.md), [divider](divider.md), [menu](menu.md)

The `m3e-split-pane` component delivers a Material 3-inspired split view with a movable drag handle, enabling responsive layout composition and precise pane resizing. It supports keyboard interaction, adaptive orientation, and optional detent snapping for consistent, accessible content distribution.

```ts
import "@m3e/web/split-pane";
```

## Examples

```html
<m3e-split-pane>
  <div slot="start">Start content</div>
  <div slot="end">End content</div>
</m3e-split-pane>
```

```html
<m3e-split-pane orientation="vertical" detents="25 50 75">
  <div slot="start">Top content</div>
  <div slot="end">Bottom content</div>
</m3e-split-pane>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Horizontal split pane with min and max constraints**

```html
<m3e-split-pane orientation="horizontal" value="35" min="20" max="60" label="Resize sidebar">
  <nav slot="start">
    <ul>
      <li>Inbox</li>
      <li>Drafts</li>
      <li>Sent</li>
    </ul>
  </nav>
  <main slot="end">
    <p>Select a message to read.</p>
  </main>
</m3e-split-pane>
```

**Vertical split pane with snapping detents**

```html
<m3e-split-pane orientation="vertical" detents="25 50 75" wrap-detents step="5">
  <section slot="start">
    <p>Editor</p>
  </section>
  <section slot="end">
    <p>Preview output</p>
  </section>
</m3e-split-pane>
```

## API

### `<m3e-split-pane>`

A dual-view layout that separates content with a movable drag handle.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `detents` | `string[]` | [] | Detents (discrete sizes) the start pane can snap to. |
| `label` | `string` | "Resize panes" | The accessible label given to the movable drag handle. |
| `max` | `number` | 100 | A fractional value, between 0 and 100, indicating the maximum size of the start pane. |
| `min` | `number` | 0 | A fractional value, between 0 and 100, indicating the minimum size of the start pane. |
| `orientation` | `"horizontal" \| "vertical" \| "auto"` | "horizontal" | The orientation of the split. |
| `overshoot-limit` | `number` | 4 | A fractional value, between 0 and 100, indicating the maximum visual overshoot allowed when dragging past the minimum or maximum size. |
| `step` | `number` | 1 | A fractional value, between 0 and 100, indicating the increment by which to adjust the value when resized via keyboard. |
| `value` | `number` | 50 | A fractional value, between 0 and 100, indicating the size of the start pane. |
| `wrap-detents` | `boolean` | false | Whether cycling through detents will wrap. |
| `name` |  |  | The name that identifies the element when submitting the associated form. |
| `disabled` | `boolean` | false | Whether the element is disabled. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `valueFormatter` | `(     value: number,     orientation: Omit<SplitPaneOrientation, "auto">,     dir: Direction,   ) => string \| undefined \| undefined` | A function used to generates human readable text for the accessible value (`aria-valuetext`) of the drag handle. |
| `currentOrientation` _(readonly)_ | `Exclude<SplitPaneOrientation, "auto">` | The current orientation of the split. |
| `formAssociated` _(readonly)_ | `boolean` | Indicates that this custom element participates in form submission, validation, and form state restoration. |
| `form` _(readonly)_ | `HTMLFormElement \| null` | The `HTMLFormElement` associated with this element. |

**Slots**

| Slot | Description |
| --- | --- |
| `start` | Renders content at the logical start side of the pane. |
| `end` | Renders content at the logical end side of the pane. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the user finishes adjusting the drag handle. |
| `beforeinput` | `Event` | Dispatched continuously before the user adjusts the drag handle. |
| `input` | `Event` | Dispatched continuously while the user adjusts the drag handle. |

**CSS custom properties** — 13 total across 13 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-split-pane-drag-handle-hover-color` | Color used for the drag handle hover state. |
| `--m3e-split-pane-drag-handle-hover-opacity` | Opacity used for the drag handle hover state. |
| `--m3e-split-pane-drag-handle-focus-color` | Color used for the drag handle focus state. |
| `--m3e-split-pane-drag-handle-focus-opacity` | Opacity used for the drag handle focus state. |
| `--m3e-split-pane-drag-handle-color` | Background color of the drag handle when not pressed. |
| `--m3e-split-pane-drag-handle-shape` | Corner shape of the drag handle when not pressed. |
| `--m3e-split-pane-drag-handle-pressed-color` | Background color of the drag handle when pressed. |
| `--m3e-split-pane-drag-handle-pressed-shape` | Corner shape of the drag handle when pressed. |
| `--m3e-split-pane-drag-handle-container-width` | Width of the drag handle container. |
| `--m3e-split-pane-drag-handle-width` | Thickness of the drag handle when not pressed. |
| `--m3e-split-pane-drag-handle-height` | Length of the drag handle when not pressed. |
| `--m3e-split-pane-drag-handle-pressed-width` | Thickness of the drag handle when pressed. |

_…1 more families. See source for the full list._

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/split-pane/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/split-pane/SplitPaneElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/split-pane/SplitPaneElement.ts)

**README drift corrected** (2 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
