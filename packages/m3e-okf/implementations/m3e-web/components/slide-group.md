# slide-group

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md)

The `m3e-slide-group` component presents directional pagination controls for navigating overflowing content. It orchestrates scrollable layouts with expressive slot-based icons and adaptive orientation, revealing navigation affordances only when content exceeds a defined threshold. It supports both horizontal and vertical flows, and encodes accessibility through customizable labels and interaction states.

```ts
import "@m3e/web/slide-group";
```

## Examples

```html
<m3e-slide-group threshold="48">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
  <div>Item 4</div>
  <div>Item 5</div>
</m3e-slide-group>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Horizontal scrollable button row**

```html
<m3e-slide-group threshold="48" previous-page-label="Scroll left" next-page-label="Scroll right">
  <m3e-icon slot="prev-icon" name="chevron_left"></m3e-icon>
  <m3e-icon slot="next-icon" name="chevron_right"></m3e-icon>
  <m3e-button variant="tonal">All</m3e-button>
  <m3e-button variant="outlined">Photos</m3e-button>
  <m3e-button variant="outlined">Videos</m3e-button>
  <m3e-button variant="outlined">Documents</m3e-button>
  <m3e-button variant="outlined">Music</m3e-button>
  <m3e-button variant="outlined">Archives</m3e-button>
</m3e-slide-group>
```

**Vertical slide group of cards**

```html
<m3e-slide-group vertical threshold="32">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
  <div>Item 4</div>
  <div>Item 5</div>
</m3e-slide-group>
```

## API

### `<m3e-slide-group>`

Presents pagination controls used to scroll overflowing content.

**Display:** `flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `disabled` | `boolean` | false | Whether scroll buttons are disabled. |
| `next-page-label` | `string` | "Next page" | The accessible label given to the button used to move to the next page. |
| `previous-page-label` | `string` | "Previous page" | The accessible label given to the button used to move to the previous page. |
| `threshold` | `number` | 0 | A value, in pixels, indicating the scroll threshold at which to begin showing pagination controls. |
| `vertical` | `boolean` | false | Whether content is oriented vertically. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content to paginate. |
| `next-icon` | Renders the icon to present for the next button. |
| `prev-icon` | Renders the icon to present for the previous button. |

**CSS custom properties** — 4 total across 4 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-slide-group-button-icon-size` | Sets icon size for scroll buttons; overrides default small icon size. |
| `--m3e-slide-group-button-size` | Defines scroll button size; used for width (horizontal) or height (vertical). |
| `--m3e-slide-group-divider-top` | Adds top border to content container for visual separation. |
| `--m3e-slide-group-divider-bottom` | Adds bottom border to content container for visual separation. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/slide-group/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/slide-group/SlideGroupElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/slide-group/SlideGroupElement.ts)
