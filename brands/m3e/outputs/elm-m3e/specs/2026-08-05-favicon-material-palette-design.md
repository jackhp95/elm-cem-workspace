# Spec D — Favicon from the real Material `palette` glyph

Date: 2026-08-05
Repo: `elm-m3e`
Status: approved design, not yet planned
Depends on: Spec C (`specs/2026-08-05-icon-registry-seam-design.md`) for the icon pipeline

## Problem

`docs/public/favicon.svg` claims to be the Material palette glyph:

```html
<!-- Material "palette" glyph, white, centered -->
<g transform="translate(11 11) scale(1.08)">
  <path fill="#FFFFFF" d="M12 3c-4.97 0-9 4.03-9 9s4.03 9 9 9c.83 0…"/>
</g>
```

It is a hand-copied path on a `0 0 24 24` grid — the legacy *Material Icons* palette, not
the *Material Symbols* glyph the app bar actually renders. The app bar uses
`M3e.Icon.name "palette"` (`docs/app/Shared.elm:396`), which resolves through Material
Symbols. So the tab icon and the in-app icon are two different drawings of the same idea,
and neither is derived from a source that can be re-checked.

## Design

Generate the glyph from `material-symbols:palette` through Spec C's pipeline rather than
hand-copying it. Add the id to `config/icons.json`, and have the icons build step emit
`docs/public/favicon.svg` as a second output alongside the `registerIcon` module — one
source of truth for "the palette glyph", consumed both by the app bar and by the tab icon.

Keep the existing brand plate: the 46×46 rounded rect with the `#8A6FE0 → #5B3F9E`
gradient, `viewBox="0 0 48 48"`, `role="img"`, `aria-label="elm-m3e"`. Only the glyph path
and its transform change.

### The transform must be computed from the declared viewBox

**Do not assume a grid.** The two plausible sources disagree:

| Source | viewBox | origin |
|---|---|---|
| Raw Google / `@m3e/icons` | `0 -960 960 960` | baseline, negative Y |
| Iconify `material-symbols:palette` | `0 0 24 24` | top-left (**normalised**) |

Verified by probe during implementation: Iconify serves `material-symbols:palette` on
`0 0 24 24`, path length 599, single path. So with the Iconify pipeline the correct wrapper
is `translate(11 11) scale(1.0833333)` — which coincidentally matches the *old* hand-written
file's `translate(11 11)`, because that file also assumed a 24 grid. The glyph still changes
(legacy Material Icons → Material Symbols); only the transform happens to agree.

The general formula, for a square glyph viewBox `minX minY w h` into a `plate`-unit canvas
with a `glyph`-unit box:

```
scale = glyph / w
inset = (plate - glyph) / 2
tx    = inset - minX * scale
ty    = inset - minY * scale
```

giving `transform="translate(tx ty) scale(scale)"`. SVG applies the rightmost transform
first, so `(x, y) → (x*scale + tx, y*scale + ty)`.

Sanity-checking both grids with `plate = 48`, `glyph = 26`:

- `0 0 24 24` → `scale = 1.0833333`, `tx = ty = 11` → `translate(11 11) scale(1.0833333)`
- `0 -960 960 960` → `scale = 0.0270833`, `tx = 11`, `ty = 11 + 26 = 37` → `translate(11 37) scale(0.0270833)`

The generator must compute this, never hard-code it — otherwise switching icon source
silently places the glyph off-canvas. Verify visually at 16px; a wrong transform still
produces valid SVG.

## Also in scope: generating `favicon.ico`

The `.ico` is generated from the same SVG, as a multi-image ICO at **16, 32 and 48px**.

### Tooling — pinned Node packages, not a system binary

ImageMagick is **not installed** on this machine (`magick` and `convert` both absent), so it
would be a new system dependency. Two things are already available — `rsvg-convert` 2.62.3,
and macOS `sips`, which does list `com.microsoft.ico` as writable — but neither is the right
choice, and neither is ImageMagick:

- This repo **drift-gates generated output**. Rasterisation is not byte-reproducible across
  tool versions or platforms: a different ImageMagick, librsvg or CoreGraphics build produces
  different bytes for identical input, so a system-binary pipeline makes `check:drift` fail
  spuriously on another machine or in CI.
- `sips` is macOS-only, so it cannot run in CI at all.

Use pinned `devDependencies` in `docs/` instead — `@resvg/resvg-js` (or `sharp`) to
rasterise the SVG, and `png-to-ico` to build the ICO container. Pinned versions in
`pnpm-lock.yaml` give a fixed toolchain, and no contributor needs a `brew install` to run
`npm run gen`.

Even so, **do not drift-gate the rasters.** Prebuilt native binaries still differ per
platform, so byte-equality across machines is not achievable. Gate the **SVG** — which is
text and fully deterministic — and treat `favicon.ico` (and the OG PNG below) as committed
build artifacts explicitly excluded from `check:drift`, regenerated when the SVG changes.

### Why the ICO alone fixes nothing currently broken

Worth being plain about, because it changes what this work is for: **the ICO has no consumer
that benefits from being better.** `Site.elm:30` registers only `favicon.svg`, and every
browser that matters supports SVG favicons. The `.ico`'s *only* referents are 14 route
modules in `docs/app/` that pass it as their Open Graph `image`:

```elm
image = { url = [ "favicon.ico" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", … }
```

That file is a **32×32 PNG** wearing an `.ico` extension, 450 bytes. As a social card it
fails twice: it is far below the ~1200×630 scrapers expect, and most scrapers will not render
an `.ico` at all. So every shared link across the docs site has a broken or blank card, and a
crisper multi-size ICO does not change that — scrapers still will not render it.

Generating the ICO is therefore **legacy hygiene with no active consumer**. The thing that
actually fixes the 14 broken cards is a real Open Graph raster — a **1200×630 PNG** — which
comes off the same plate and the same pipeline nearly free, plus repointing those 14 `image`
fields at it.

Both are specified here. The ICO because it was asked for; the OG PNG because it is the
defect the ICO investigation uncovered and it is cheaper to do now than to re-derive later.
The OG card's *visual design* beyond "the brand plate, scaled, on the gradient" is the one
open question — a wordmark or tagline is an editorial call, not a codegen one.

Do **not** delete `favicon.ico` before the 14 refs are repointed; a broken card beats a 404.

## Verification

- `docs/public/favicon.svg` is generated, not hand-edited; drift check green.
- `docs/public/favicon.ico` is a valid multi-image ICO containing 16, 32 and 48px images —
  assert on the ICO header (image count) rather than on file size, and confirm `file` reports
  `MS Windows icon resource` rather than `PNG image data`, which is what the old one was.
- The rasters are excluded from `check:drift`; deliberately dirtying one and re-running the
  gate must still pass, while dirtying `favicon.svg` must fail.
- If the OG PNG lands: it is 1200×630, and all 14 route modules point at it —
  `rg -c "favicon.ico" docs/app` returns nothing.
- The generated path is byte-identical to `material-symbols:palette`'s path data, asserted
  in the generator test.
- Rendered at 16×16 and 32×32 the glyph is centred within the plate with no clipping and no
  off-canvas placement — checked as an image, since a wrong transform still produces valid
  SVG.
- Tab icon and app-bar icon are visibly the same drawing.
- `npm run build:site` green; `favicon.svg` present in `docs/dist`.
