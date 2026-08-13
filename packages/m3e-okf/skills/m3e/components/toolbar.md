# toolbar

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [stepper](stepper.md), [slide-group](slide-group.md)

The `m3e-toolbar` component presents contextual actions, navigation, and controls. Designed according to Material 3 principles, it supports vertical and horizontal orientation, shape and variant customization, and adaptive layout via CSS custom properties.

```ts
import "@m3e/web/toolbar";
```

## Examples

```html
<m3e-toolbar variant="vibrant" shape="rounded">
  <m3e-icon-button>
    <m3e-icon name="arrow_back"></m3e-icon>
  </m3e-icon-button>
  <m3e-icon-button>
    <m3e-icon name="arrow_forward"></m3e-icon>
  </m3e-icon-button>
  <m3e-icon-button width="wide" variant="filled">
    <m3e-icon name="add"></m3e-icon>
  </m3e-icon-button>
  <m3e-icon-button>
    <m3e-icon name="picture_in_picture"></m3e-icon>
  </m3e-icon-button>
  <m3e-icon-button>
    <m3e-icon name="more_vert"></m3e-icon>
  </m3e-icon-button>
</m3e-toolbar>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Vibrant rounded media controls toolbar**

```html
<m3e-toolbar variant="vibrant" shape="rounded">
  <m3e-button variant="text">
    <m3e-icon slot="icon" name="skip_previous"></m3e-icon>
  </m3e-button>
  <m3e-button variant="filled">
    <m3e-icon slot="icon" name="play_arrow"></m3e-icon>
  </m3e-button>
  <m3e-button variant="text">
    <m3e-icon slot="icon" name="skip_next"></m3e-icon>
  </m3e-button>
</m3e-toolbar>
```

**Elevated vertical editing toolbar**

```html
<m3e-toolbar vertical elevated shape="square">
  <m3e-button variant="text">
    <m3e-icon slot="icon" name="format_bold"></m3e-icon>
  </m3e-button>
  <m3e-button variant="text">
    <m3e-icon slot="icon" name="format_italic"></m3e-icon>
  </m3e-button>
  <m3e-button variant="text">
    <m3e-icon slot="icon" name="format_underlined"></m3e-icon>
  </m3e-button>
</m3e-toolbar>
```

## API

### `<m3e-toolbar>`

Presents frequently used actions relevant to the current page.

**Display:** `inline-block`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `elevated` | `boolean` | false | Whether the toolbar is elevated. |
| `shape` | `"rounded" \| "square"` | "square" | The shape of the toolbar. |
| `variant` | `"standard" \| "vibrant"` | "standard" | The appearance variant of the toolbar. |
| `vertical` | `boolean` | false | Whether the element is oriented vertically. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the toolbar. |

**CSS custom properties** — 9 total across 9 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-toolbar-size` | The size (height or width) of the toolbar. |
| `--m3e-toolbar-spacing` | The gap between toolbar items. |
| `--m3e-toolbar-rounded-shape` | Border radius for rounded shape. |
| `--m3e-toolbar-rounded-padding` | Padding for rounded shape. |
| `--m3e-toolbar-square-padding` | Padding for square shape. |
| `--m3e-toolbar-standard-container-color` | Container color for the standard variant. |
| `--m3e-toolbar-standard-color` | Foreground color for the standard variant. |
| `--m3e-toolbar-vibrant-container-color` | Container color for the vibrant variant. |
| `--m3e-toolbar-vibrant-color` | Foreground color for the vibrant variant. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/toolbar/README.md) (MIT). · Material spec: <https://m3.material.io/components/toolbars/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/toolbar/ToolbarElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/toolbar/ToolbarElement.ts)
