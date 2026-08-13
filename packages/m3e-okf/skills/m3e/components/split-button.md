# split-button

**Family:** [Actions & buttons](../concepts/choosing-components.md#actions) · See also: [button](button.md), [icon-button](icon-button.md), [fab](fab.md), [fab-menu](fab-menu.md), [button-group](button-group.md), [segmented-button](segmented-button.md)

The `m3e-split-button` component presents a primary action alongside a menu of related actions, uniting two buttons in a single expressive surface. Designed for Material 3, it supports `elevated`, `filled`, `tonal`, and `outlined` variants, and adapts to all button sizes. The leading button triggers the main action, while the trailing icon button reveals additional options, enabling efficient workflows and clear visual hierarchy. The split button ensures accessible, adaptive, and visually harmonious interactions, reflecting Material 3's principles of clarity, flexibility, and expressive design.

```ts
import "@m3e/web/split-button";
```

## Examples

```html
<m3e-split-button>
  <m3e-button slot="leading-button"> <m3e-icon slot="icon" name="edit"></m3e-icon>Edit </m3e-button>
  <m3e-icon-button slot="trailing-button">
    <m3e-icon name="keyboard_arrow_down"></m3e-icon>
    <m3e-menu-trigger for="menu1"></m3e-menu-trigger>
  </m3e-icon-button>
</m3e-split-button>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Filled split button with primary action and menu toggle**

```html
<m3e-split-button variant="filled" size="medium">
  <m3e-button slot="leading-button">
    <m3e-icon slot="icon" name="edit"></m3e-icon>
    Edit
  </m3e-button>
  <m3e-button slot="trailing-button">
    <m3e-icon name="keyboard_arrow_down"></m3e-icon>
  </m3e-button>
</m3e-split-button>
```

**Tonal split button**

```html
<m3e-split-button variant="tonal" size="large">
  <m3e-button slot="leading-button">
    <m3e-icon slot="icon" name="save"></m3e-icon>
    Save
  </m3e-button>
  <m3e-button slot="trailing-button">
    <m3e-icon name="arrow_drop_down"></m3e-icon>
  </m3e-button>
</m3e-split-button>
```

## API

### `<m3e-split-button>`

A button used to show an action with a menu of related actions.

**Display:** `inline-flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `variant` | `"elevated" \| "filled" \| "tonal" \| "outlined"` | "filled" | The appearance variant of the button. |
| `size` | `"extra-small" \| "small" \| "medium" \| "large" \| "extra-large"` | "small" | The size of the button. |

**Slots**

| Slot | Description |
| --- | --- |
| `leading-button` | The leading button used to perform the primary action. |
| `trailing-button` | The trailing icon button used to open a menu of related actions. |

**CSS custom properties** — 40 total across 8 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-split-button-[size]-trailing-button-unselected-leading-space` | Leading space for the trailing button (extra-small, unselected). |
| `--m3e-split-button-[size]-trailing-button-unselected-trailing-space` | Trailing space for the trailing button (extra-small, unselected). |
| `--m3e-split-button-[size]-trailing-button-selected-leading-space` | Leading space for the trailing button (extra-small, selected). |
| `--m3e-split-button-[size]-trailing-button-selected-trailing-space` | Trailing space for the trailing button (extra-small, selected). |
| `--m3e-split-button-[size]-inner-corner-size` | Inner corner size for the leading/trailing button (extra-small). |
| `--m3e-split-button-[size]-inner-corner-hover-size` | Inner corner size on hover (extra-small). |
| `--m3e-split-button-[size]-inner-corner-pressed-size` | Inner corner size on press (extra-small). |
| `--m3e-split-button-[size]-between-spacing` | Spacing between leading and trailing buttons (extra-small). |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/split-button/README.md) (MIT). · Material spec: <https://m3.material.io/components/split-button/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/split-button/SplitButtonElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/split-button/SplitButtonElement.ts)
