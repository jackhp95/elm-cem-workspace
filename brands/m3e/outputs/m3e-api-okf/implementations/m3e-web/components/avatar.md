# avatar

**Family:** [Content & media](../concepts/choosing-components.md#content-media) · See also: [icon](icon.md), [heading](heading.md), [shape](shape.md)

The `m3e-avatar` component is a reusable identity primitive that displays visual or textual representation with consistent sizing, shape, and typography.

```ts
import "@m3e/web/avatar";
```

## Examples

```html
<m3e-avatar>AB</m3e-avatar>
```

```html
<m3e-avatar>
  <m3e-icon name="person"></m3e-icon>
</m3e-avatar>
```

```html
<m3e-avatar>
  <img src="https://avatars.githubusercontent.com/u/224686995?s=48&v=4" />
</m3e-avatar>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Avatar with image and icon fallback**

```html
<m3e-avatar>
  <img src="face.jpg" />
</m3e-avatar>
<m3e-avatar>
  <m3e-icon name="person"></m3e-icon>
</m3e-avatar>
```

_Source: kinfolk: src/pages/entities/[id].astro_

## API

### `<m3e-avatar>`

An image, icon or textual initials representing a user or other identity.

**Display:** `inline-block`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the avatar. |

**CSS custom properties** — 8 total across 8 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-avatar-size` | Size of the avatar. |
| `--m3e-avatar-shape` | Border radius of the avatar. |
| `--m3e-avatar-font-size` | Font size for the avatar. |
| `--m3e-avatar-font-weight` | Font weight for the avatar. |
| `--m3e-avatar-line-height` | Line height for the avatar. |
| `--m3e-avatar-tracking` | Letter spacing for the avatar. |
| `--m3e-avatar-color` | Background color of the avatar. |
| `--m3e-avatar-label-color` | Text color of the avatar. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/avatar/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/avatar/AvatarElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/avatar/AvatarElement.ts)
