M3E renders icons with **Material Symbols** through the `m3e-icon` element. Material
Symbols are variable-font icons controlled by four axes; the axes are Material's, and
`m3e-icon` maps each to an attribute.

## The four axes

Material Symbols vary along fill, weight, grade, and optical size
([icons](https://m3.material.io/styles/icons/overview)). `m3e-icon` maps them:

| Axis | Attribute | Values |
| --- | --- | --- |
| Fill | `filled` | boolean (present = filled) |
| Weight | `weight` | `100`–`700` |
| Grade | `grade` | `low` \| `medium` \| `high` |
| Optical size | `optical-size` | number (dp) |
| Style | `variant` | `outlined` \| `rounded` \| `sharp` |

```html
<m3e-icon name="favorite"></m3e-icon>
<m3e-icon name="favorite" filled weight="600"></m3e-icon>
<m3e-icon name="settings" variant="rounded" optical-size="24"></m3e-icon>
```

## Choosing values

You should keep one icon **style** (`variant`) across a screen so the set reads as one
family ([applying icons](https://m3.material.io/styles/icons/applying-icons)). Prefer the
**filled** state to signal a selected/active toggle and the outlined state for its rest
state ([applying icons](https://m3.material.io/styles/icons/applying-icons)). (m3e behavior)

Match `optical-size` to the rendered size and let `weight` track the surrounding text
weight for optical balance ([applying icons](https://m3.material.io/styles/icons/applying-icons)). (m3e behavior)

## Icons inside controls

Most controls take their icon in a named slot rather than as content — an
`m3e-icon-button` holds it in the default slot, a `m3e-button` in its `icon` slot
([designing icons](https://m3.material.io/styles/icons/designing-icons)). (m3e behavior)

```html
<m3e-button variant="filled">
  <m3e-icon slot="icon" name="download"></m3e-icon>
  Download
</m3e-button>
```

An icon-only control still needs an accessible name — see [Accessibility](accessibility.md).

---
_See also: [Accessibility](accessibility.md) · [icon component card](../components/icon.md) · [Shape](shape.md)._
