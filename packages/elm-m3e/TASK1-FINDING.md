# Task 1 finding: contrast/seed reactivity bug

## Root cause confirmed: Root Cause B

`@m3e/web`'s `<m3e-theme>` custom element declares `contrast` and `color` in
`observedAttributes` (so `attributeChangedCallback` does fire), but changing
those attributes post-mount does not cause the element to recompute/re-publish
its derived `--md-sys-color-*` CSS custom properties. The break is entirely
inside `@m3e/web`, independent of Elm/HtmlIr.

## Evidence

Reproduced live against `docs` dev server (`pnpm dev`, elm-pages, localhost:1234,
page `/guide/theming`) via a Paseo browser session.

1. `document.querySelector('m3e-theme').constructor.observedAttributes` →
   `["color","variant","scheme","contrast","strong-focus","density","motion"]`.
   Both `contrast` and `color` are present, so the element *is* declared reactive
   (this is what made Root Cause A — an Elm-side keying/patch issue — worth
   ruling out first).

2. UI reproduction — Contrast segmented buttons: clicking the "Medium" segment
   in the `#settings-sheet` drawer updates the live DOM attribute
   (`m3e-theme.getAttribute('contrast')` → `"medium"`), but
   `getComputedStyle(el).getPropertyValue('--md-sys-color-primary')` is
   byte-identical before and after
   (`light-dark(oklch(from #6750a4 48.42% c h), oklch(from #6750a4 82.82% c h))`
   in both cases). No visible color/border change on the page.

3. UI reproduction — seed color: dispatching `input`/`change` on the native
   `<input type="color">` sets `m3e-theme[color]` to the new hex
   (`#00ff00`), but again `--md-sys-color-primary` is unchanged from the
   original `#6750a4`-derived value. No visible palette change.

4. Root-cause isolation (step 6, pure JS, zero Elm involvement): in the
   console, `document.querySelector('m3e-theme').setAttribute('contrast',
   'high')` and separately `.setAttribute('color', '#FF0000')` were run
   directly against the live element. Both update the DOM attribute
   immediately (confirmed via `getAttribute`), but neither produces any change
   in the computed `--md-sys-color-primary` CSS variable. This reproduces the
   bug with Elm/HtmlIr completely out of the loop, which rules out Root Cause A
   (an Elm-side patch/keying issue causing `setAttribute` to be skipped or a
   node-replace to be triggered) — the attribute write itself is fine and
   reaches the DOM either way; `@m3e/web`'s `attributeChangedCallback` for
   these two attributes just doesn't trigger a recompute/`requestUpdate()`
   of the derived token CSS variables.

   By contrast, `scheme` and `density` (also in `observedAttributes`) *do*
   work correctly via the same settings sheet — confirming this is specific
   to `contrast` and `color`'s attributeChangedCallback wiring inside
   `@m3e/web`, not a wholesale reactivity failure on the element.

## Recommendation

Implement **Branch B**: a `@m3e/web` reactivity shim in `docs/index.ts` — a
`MutationObserver` on `<m3e-theme>` watching `attributes` for `contrast` and
`color` that calls `.requestUpdate()` (or equivalent) on the element when they
change, until upstream `@m3e/web` fixes its own `attributeChangedCallback` for
these two attributes. Branch A (Elm-side keying fix) is not indicated — the
bug reproduces identically via raw `setAttribute()` calls with no Elm/HtmlIr
in the loop at all.
