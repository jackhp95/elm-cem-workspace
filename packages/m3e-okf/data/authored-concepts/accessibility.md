Accessibility is a construction concern, not a finishing pass. M3E components ship
accessible roles, keyboard handling, and focus indicators, but the markup you write
still has to supply **names**, respect **target sizes**, and pair **colors** by role.
The rules below follow Material's accessibility guidance; the token specifics are m3e.

## Accessible names on icon-only controls

An icon-only control has no visible text, so it needs an explicit accessible name.
You should give every icon-only `m3e-icon-button` / `m3e-fab` an `aria-label`
([assistive technology guidance](https://m3.material.io/foundations/overview/assistive-technology)) —
the icon glyph is decorative and is not announced.

```html
<m3e-icon-button aria-label="Delete item" variant="standard">
  <m3e-icon name="delete"></m3e-icon>
</m3e-icon-button>

<m3e-fab aria-label="Compose message" variant="primary">
  <m3e-icon name="edit"></m3e-icon>
</m3e-fab>
```

A control that already shows a text label (a standard `m3e-button`, an extended FAB)
does not need `aria-label` — prefer the visible text as the name
([assistive technology guidance](https://m3.material.io/foundations/overview/assistive-technology)).

## Touch targets

Interactive targets should be at least **48×48dp** even when the visible glyph is
smaller ([usability guidance](https://m3.material.io/foundations/usability/overview)).
m3e controls reserve this minimum through their container tokens, so avoid shrinking
a control's height below it with custom CSS
([usability guidance](https://m3.material.io/foundations/usability/overview)). (m3e behavior)

## Focus indicators

A visible focus indicator must never be removed
([usability guidance](https://m3.material.io/foundations/usability/overview)). M3E draws
a focus ring on every focusable control; the `m3e-theme` component's `strong-focus`
attribute makes it heavier for high-visibility contexts. (m3e behavior)

```html
<m3e-theme scheme="auto" strong-focus>
  <m3e-icon-button aria-label="Settings" variant="tonal">
    <m3e-icon name="settings"></m3e-icon>
  </m3e-icon-button>
</m3e-theme>
```

## Color & contrast pairing

Text and its background must meet contrast minimums
([color-contrast guidance](https://m3.material.io/foundations/designing/color-contrast)).
Always pair a container color token with its matching `on-*` token — put
`--md-sys-color-on-primary` text on a `--md-sys-color-primary` surface, never a raw
hex ([color-contrast guidance](https://m3.material.io/foundations/designing/color-contrast)).
The role pairs are contrast-tuned by construction, so prefer them over hand-picked
colors ([color-contrast guidance](https://m3.material.io/foundations/designing/color-contrast)). (m3e behavior)

## Checklist

- Every icon-only control has an `aria-label`.
- Nothing removes the focus ring; `strong-focus` where visibility matters.
- Text uses `on-*` tokens paired to their container role.
- Interactive targets stay ≥48dp — no CSS that shrinks control height below it.

---
_See also: [Interaction states](interaction-states.md) · [Color & theming](color.md) · [Design tokens](design-tokens.md)._
