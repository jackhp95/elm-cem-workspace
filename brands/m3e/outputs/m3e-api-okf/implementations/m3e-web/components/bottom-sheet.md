# bottom-sheet

**Family:** [Containers & surfaces](../concepts/choosing-components.md#containers) · See also: [card](card.md), [content-pane](content-pane.md), [dialog](dialog.md), [split-pane](split-pane.md), [expansion-panel](expansion-panel.md), [divider](divider.md), [menu](menu.md)

The `m3e-bottom-sheet` component implements a Material 3 bottom sheet with gesture‑driven resizing, detent snapping, and adaptive motion. It behaves as a heavy surface: transitions use non‑bouncy, decelerating motion. The sheet supports direct manipulation through vertical drag gestures. Movement below an 8px threshold is ignored to ensure reliable tap‑to‑cycle behavior on the handle. Once activated, dragging updates the sheet height with friction near the minimum height to prevent abrupt collapse. When detents are defined, the sheet snaps to the nearest detent on release. If hideable, downward gestures may dismiss the sheet using either velocity or a small distance threshold below the collapsed detent. When no detents are present, the sheet behaves as a simple open/hidden surface with a bottom‑measured hide threshold.

```ts
import "@m3e/web/bottom-sheet";
```

**Elements:** `<m3e-bottom-sheet>`, `<m3e-bottom-sheet-action>`, `<m3e-bottom-sheet-trigger>`

## Examples

```html
<m3e-button>
  <m3e-bottom-sheet-trigger for="bottomSheet"> Open Bottom Sheet </m3e-bottom-sheet-trigger>
</m3e-button>

<m3e-bottom-sheet id="bottomSheet" modal handle hideable detents="fit half full">
  <m3e-action-list>
    <m3e-list-action autofocus>
      <m3e-bottom-sheet-action>Google Keep</m3e-bottom-sheet-action>
      <span slot="supporting-text">Add to a note</span>
    </m3e-list-action>
    <m3e-list-action>
      <m3e-bottom-sheet-action>Google Docs</m3e-bottom-sheet-action>
      <span slot="supporting-text">Embed in a document</span>
    </m3e-list-action>
  </m3e-action-list>
</m3e-bottom-sheet>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Modal share sheet with action list**

```html
<m3e-button variant="tonal">
  <m3e-bottom-sheet-trigger for="share-sheet">Share</m3e-bottom-sheet-trigger>
</m3e-button>
<m3e-bottom-sheet id="share-sheet" modal handle hideable detents="fit half full">
  <span slot="header">Share to</span>
  <m3e-action-list>
    <m3e-list-action>
      <m3e-icon slot="leading" name="link"></m3e-icon>
      <m3e-bottom-sheet-action>Copy link</m3e-bottom-sheet-action>
    </m3e-list-action>
    <m3e-list-action>
      <m3e-icon slot="leading" name="mail"></m3e-icon>
      <m3e-bottom-sheet-action>Email</m3e-bottom-sheet-action>
    </m3e-list-action>
  </m3e-action-list>
</m3e-bottom-sheet>
```

**Non-modal filter sheet opening to a detent**

```html
<m3e-button variant="outlined">
  <m3e-bottom-sheet-trigger for="filters-sheet" detent="1">Filters</m3e-bottom-sheet-trigger>
</m3e-button>
<m3e-bottom-sheet id="filters-sheet" handle detents="half full">
  <span slot="header">Filters</span>
  <label>
    <m3e-checkbox checked></m3e-checkbox>
    In stock only
  </label>
  <label>
    <m3e-checkbox></m3e-checkbox>
    On sale
  </label>
  <m3e-button variant="filled">
    <m3e-bottom-sheet-action>Apply</m3e-bottom-sheet-action>
  </m3e-button>
</m3e-bottom-sheet>
```

## API

### `<m3e-bottom-sheet>`

A sheet used to show secondary content anchored to the bottom of the screen.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `detent` | `number` | 0 | The zero‑based index of the detent the sheet should open to. |
| `detents` | `string[]` | [] | Detents (discrete height states) the sheet can snap to. |
| `handle` | `boolean` | false | Whether to display a drag handle and enable the top region of the sheet as a gesture surface for dragging between detents. |
| `handle-label` | `string` | "Drag handle" | The accessible label given to the drag handle. |
| `hideable` | `boolean` | false | Whether the bottom sheet can hide when its swiped down. |
| `hide-friction` | `number` | 0.5 | The friction coefficient to hide the sheet. |
| `modal` | `boolean` | false | Whether the bottom sheet behaves as modal. |
| `open` | `boolean` | false | Whether the bottom sheet is open. |
| `overshoot-limit` | `number` | 4 | A fractional value, between 0 and 100, indicating the maximum visual overshoot allowed when dragging past the minimum or maximum size. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the sheet. |
| `header` | Renders the header of the sheet. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `opening` | `Event` | Dispatched when the sheet begins to open. |
| `closing` | `Event` | Dispatched when the sheet begins to close. |
| `cancel` | `Event` | Dispatched when the sheet is cancelled. |
| `opened` |  | Dispatched when the sheet has opened. |
| `closed` |  | Dispatched when the sheet has closed. |

**CSS custom properties** — 32 total across 32 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-bottom-sheet-width` | The width of the sheet. |
| `--m3e-bottom-sheet-max-width` | The maximum width of the sheet. |
| `--m3e-bottom-sheet-container-color` | The background color of the sheet container. |
| `--m3e-bottom-sheet-elevation` | The elevation level when not modal. |
| `--m3e-bottom-sheet-modal-elevation` | The elevation level when modal. |
| `--m3e-bottom-sheet-full-elevation` | The elevation level when full height. |
| `--m3e-bottom-sheet-z-index` | The z-index of the non-modal sheet. |
| `--m3e-bottom-sheet-minimized-container-shape` | The border radius when minimized. |
| `--m3e-bottom-sheet-container-shape` | The border radius of the sheet container. |
| `--m3e-bottom-sheet-full-container-shape` | The border radius when full height. |
| `--m3e-bottom-sheet-scrim-color` | The color of the scrim overlay. |
| `--m3e-bottom-sheet-scrim-opacity` | The opacity of the scrim overlay. |

_…20 more families. See source for the full list._

### `<m3e-bottom-sheet-action>`

An element, nested within a clickable element, used to close a parenting bottom sheet.

**Display:** `contents`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the action. |

### `<m3e-bottom-sheet-trigger>`

An element, nested within a clickable element, used to trigger a bottom sheet.

**Display:** `block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `detent` | `number \| undefined` | undefined | The zero‑based index of the detent the sheet should open to. |
| `secondary` | `boolean` | false | Marks this trigger as a secondary trigger for accessibility. Secondary triggers do not receive ARIA ownership. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the trigger. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/bottom-sheet/README.md) (MIT). · Material spec: <https://m3.material.io/components/bottom-sheets/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/bottom-sheet/BottomSheetElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/bottom-sheet/BottomSheetElement.ts)
- [`packages/web/src/bottom-sheet/BottomSheetActionElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/bottom-sheet/BottomSheetActionElement.ts)
- [`packages/web/src/bottom-sheet/BottomSheetTriggerElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/bottom-sheet/BottomSheetTriggerElement.ts)

**README drift corrected** (4 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
