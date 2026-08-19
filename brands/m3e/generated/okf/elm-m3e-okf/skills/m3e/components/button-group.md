# button-group

**Family:** [Actions & buttons](../concepts/choosing-components.md#actions) · See also: [button](button.md), [icon-button](icon-button.md), [fab](fab.md), [fab-menu](fab-menu.md), [split-button](split-button.md), [segmented-button](segmented-button.md)

The `m3e-button-group` component arranges multiple into a unified, expressive layout, supporting both `standard` and `connected` variants. It enables seamless, accessible grouping of actions, adapts to various sizes, and ensures consistent spacing, shape, and alignment. Designed according to Material 3 principles, it empowers users to interact with related actions in a visually harmonious and intuitive way.

```ts
import "@m3e/web/button-group";
```

## Examples

```html
<m3e-button-group>
  <m3e-icon-button variant="tonal" toggle><m3e-icon name="format_bold"></m3e-icon></m3e-icon-button>
  <m3e-icon-button variant="tonal" toggle><m3e-icon name="format_italic"></m3e-icon></m3e-icon-button>
  <m3e-icon-button variant="tonal" toggle><m3e-icon name="format_underlined"></m3e-icon></m3e-icon-button>
</m3e-button-group>
```

```html
<m3e-button-group variant="connected">
  <m3e-button variant="tonal" shape="square" toggle>Start</m3e-button>
  <m3e-button variant="tonal" shape="square" toggle>Directions</m3e-button>
  <m3e-button variant="tonal" shape="square" toggle>Share</m3e-button>
</m3e-button-group>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Connected toggle group for view selection**

```html
<m3e-button-group variant="connected">
  <m3e-button variant="tonal" shape="square" toggle selected>
    <m3e-icon slot="icon" name="view_list"></m3e-icon>
    List
  </m3e-button>
  <m3e-button variant="tonal" shape="square" toggle>
    <m3e-icon slot="icon" name="grid_view"></m3e-icon>
    Grid
  </m3e-button>
  <m3e-button variant="tonal" shape="square" toggle>
    <m3e-icon slot="icon" name="map"></m3e-icon>
    Map
  </m3e-button>
</m3e-button-group>
```

**Multi-select formatting toolbar**

```html
<m3e-button-group variant="connected" multi size="medium">
  <m3e-button variant="tonal" shape="square" toggle aria-label="Bold">
    <m3e-icon name="format_bold"></m3e-icon>
  </m3e-button>
  <m3e-button variant="tonal" shape="square" toggle aria-label="Italic">
    <m3e-icon name="format_italic"></m3e-icon>
  </m3e-button>
  <m3e-button variant="tonal" shape="square" toggle aria-label="Underline">
    <m3e-icon name="format_underlined"></m3e-icon>
  </m3e-button>
</m3e-button-group>
```

## API

### `<m3e-button-group>`

Organizes buttons and adds interactions between them.

**Display:** `flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `multi` | `boolean` | false | Whether multiple toggle buttons can be selected. |
| `size` | `"extra-small" \| "small" \| "medium" \| "large" \| "extra-large"` | "small" | The size of the group. |
| `variant` | `"standard" \| "connected"` | "standard" | The appearance variant of the group. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `buttons` _(readonly)_ | `ReadonlyArray<M3eButtonElement \| M3eIconButtonElement>` | The buttons contained by the group. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the buttons of the group. |

**CSS custom properties** — 16 total across 4 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-standard-button-group-[size]-spacing` | Spacing between buttons in standard variant, extra-small size. |
| `--m3e-connected-button-group-spacing` | Spacing between buttons in connected variant. |
| `--m3e-connected-button-group-[size]-inner-shape` | Corner shape for connected variant, extra-small size. |
| `--m3e-connected-button-group-[size]-inner-pressed-shape` | Pressed corner shape for connected variant, extra-small size. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/button-group/README.md) (MIT). · Material spec: <https://m3.material.io/components/button-groups/overview> (retrieved 2026-07-10).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/button-group/ButtonGroupElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/button-group/ButtonGroupElement.ts)
