# Typography

M3E applies the [Material Design 3 typography system](https://m3.material.io/styles/typography/overview) to encode visual hierarchy, editorial tone, and spatial rhythm across components. The system defines the 15 baseline type roles; m3e also surfaces the **emphasized** tier introduced in Material 3 Expressive, for a 30-style scale (15 baseline + 15 emphasized). The emphasized styles and their `--md-sys-typescale-emphasized-*` tokens are an M3 Expressive / m3e convention, not part of the classic baseline type scale. (m3e behavior)

Typography tokens follow the prefix `--md-sys-typescale-*` for the **standard** typescale and `--md-sys-typescale-emphasized-*` for **emphasized**. Each typescale variant encodes font size, line height, weight, and tracking (or letter spacing).

For example, `body-large` is encoded using `--md-sys-typescale-body-large-font-size`, `--md-sys-typescale-body-large-font-weight`, `--md-sys-typescale-body-large-line-height`, and `--md-sys-typescale-body-large-tracking`.

M3E components support the full semantic range of the Material 3 type system, including **standard** and **emphasized** variants of: `display-large`, `display-medium`, `display-small`, `headline-large`, `headline-medium`, `headline-small`, `title-large`, `title-medium`, `title-small`, `body-large`, `body-medium`, `body-small`, `label-large`, `label-medium`, and `label-small`.

Each role is mapped to a tokenized style and applied contextually—for example, `label-large` for buttons, `body-large` for list items, and `body-small` for form-field hints.

---
_Source: [`docs/styles/typography.html`](https://github.com/matraic/m3e/blob/v2.7.3/docs/styles/typography.html) · `matraic/m3e` @ `v2.7.3`._
