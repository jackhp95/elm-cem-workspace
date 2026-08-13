# Brand Images from the Material `palette` Glyph — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generate three brand rasters from the real `material-symbols:palette` glyph — `favicon.svg`, a multi-size `favicon.ico`, and a 1200×630 Open Graph PNG — and repoint the 14 route modules that currently ship a 32×32 file as their social card.

**Architecture:** One generator module resolves the glyph through the icon pipeline's existing `resolveIcon`, computes its placement transform **from the declared viewBox**, and renders two SVGs (square plate, wide OG card). Pinned Node rasterisers turn those into the PNG and ICO. The glyph is resolved independently of `config/icons.json`, which means "register into `IconRegistry`" — the Material Symbols font stays authoritative for in-app icons.

**Tech Stack:** Node ESM (`docs/scripts/icons-gen/`), `@iconify-json/material-symbols`, `@resvg/resvg-js`, `png-to-ico`, pnpm (in `docs/`), elm-pages `Head`/`Seo`.

**Spec:** `specs/2026-08-05-favicon-material-palette-design.md`

## Global Constraints

- **Depends on the icon-registry work, which has landed.** Reuse `resolveIcon(sets, id)` and `loadSets(prefixes)` from `docs/scripts/icons-gen/icons-to-js.mjs`. Do not duplicate that logic, and do not modify it.
- **Do NOT add `palette` to `config/icons.json`.** That file drives `registerIcon` calls, and registering a Material glyph would override the ligature font for it — silently disabling the `weight`, `grade` and `opticalSize` attributes for that icon. The font stays. The favicon glyph gets its own config.
- **Never assume a glyph grid.** Iconify serves `material-symbols:palette` on **`0 0 24 24`** (verified by probe: single path, 599 chars), while raw Google data and `@m3e/icons` use `0 -960 960 960`. Compute the transform from the declared viewBox using the formula in the spec.
- `docs/` uses **pnpm**. Use `pnpm add -D` there. Run scripts via `npm --prefix docs run …`.
- **Do not drift-gate the rasters.** Prebuilt native rasterisers are not byte-reproducible across platforms. Gate `favicon.svg` (text, deterministic); exclude `favicon.ico` and the OG PNG from `check:drift`.
- **Do not delete `favicon.ico`** — repoint the 14 refs first (Task 3), then it is free of consumers but harmless to keep as a legacy tab-icon fallback.
- Keep the brand plate exactly: `viewBox="0 0 48 48"`, `role="img"`, `aria-label="elm-m3e"`, the 46×46 rect at `x=1 y=1 rx=13`, and the `#8A6FE0 → #5B3F9E` gradient.
- OG card is **glyph only — no wordmark or tagline.**

**Known pre-existing environment breakage — do not fix, do not let it block you:**
- Root is missing `npm-run-all2`: `run-p`/`run-s` are `command not found`, so `npm run check`, `test`, `gen`, `build` fail instantly. Run leaf scripts individually.
- 24 `.elm` files under `docs/node_modules` have corrupted syntax, breaking `build:site` and `check:review`. Compile Elm with `cd docs && ./node_modules/.bin/elm make $(find app -name '*.elm' | tr '\n' ' ') --output=/dev/null` — that is the gate a sibling agent used successfully (`Success! Compiled 35 modules.`).
- `check:drift` fails only on `docs/data/reference.json` (gitignored). Pre-existing.
- `test:browser` cannot run (its `webServer` runs `build:site`).

---

### Task 1: `favicon.svg` from the real glyph

**Files:**
- Create: `config/favicon.json`
- Create: `docs/scripts/icons-gen/brand-images.mjs`
- Create: `docs/scripts/icons-gen/brand-images.test.mjs`
- Modify (generated): `docs/public/favicon.svg`
- Modify: `docs/package.json` (`gen:brand-images`, `test:icons-gen` already globs `*.test.mjs`)

**Interfaces:**
- Consumes: `resolveIcon(sets, id) -> { viewBox, path }`, `loadSets(prefixes)`.
- Produces: `plateTransform(viewBox, { plate, glyph }) -> string`, `renderFavicon({viewBox,path}) -> string`, `renderOgSvg({viewBox,path}) -> string`. Tasks 2 and 3 consume the latter two.

- [ ] **Step 1: Write the glyph config**

`config/favicon.json`:

```json
{
  "glyph": "material-symbols:palette",
  "note": "Resolved for the brand rasters only. Deliberately NOT in config/icons.json: that file drives registerIcon, and registering a Material glyph overrides the ligature font for it, which silently disables the weight/grade/opticalSize attributes. The font stays authoritative for in-app icons."
}
```

- [ ] **Step 2: Write the failing test**

`docs/scripts/icons-gen/brand-images.test.mjs`:

```js
import { test } from "node:test";
import assert from "node:assert/strict";
import { plateTransform, renderFavicon, renderOgSvg } from "./brand-images.mjs";

test("places an Iconify-normalised 0 0 24 24 glyph in the plate", () => {
  // scale = 26/24; y in [0,24] -> [0,26], inset 11 -> translate(11 11).
  assert.equal(plateTransform("0 0 24 24", { plate: 48, glyph: 26 }), "translate(11 11) scale(1.0833333)");
});

test("places a raw 0 -960 960 960 glyph in the same plate", () => {
  // scale = 26/960; y in [-960,0] -> [-26,0], so ty = 11 + 26 = 37.
  assert.equal(plateTransform("0 -960 960 960", { plate: 48, glyph: 26 }), "translate(11 37) scale(0.0270833)");
});

test("rejects a non-square viewBox rather than distorting the glyph", () => {
  assert.throws(() => plateTransform("0 0 24 48", { plate: 48, glyph: 26 }), /square/i);
});

test("renders the favicon plate, gradient and glyph", () => {
  const svg = renderFavicon({ viewBox: "0 0 24 24", path: "M12 3Z" });
  assert.match(svg, /viewBox="0 0 48 48"/);
  assert.match(svg, /aria-label="elm-m3e"/);
  assert.match(svg, /stop-color="#8A6FE0"/);
  assert.match(svg, /stop-color="#5B3F9E"/);
  assert.match(svg, /<rect x="1" y="1" width="46" height="46" rx="13"/);
  assert.match(svg, /transform="translate\(11 11\) scale\(1\.0833333\)"/);
  assert.match(svg, /d="M12 3Z"/);
});

test("renders the OG card at 1200x630 with a centred glyph and no text", () => {
  const svg = renderOgSvg({ viewBox: "0 0 24 24", path: "M12 3Z" });
  assert.match(svg, /viewBox="0 0 1200 630"/);
  assert.match(svg, /d="M12 3Z"/);
  // Glyph-only: no wordmark, no tagline.
  assert.doesNotMatch(svg, /<text/);
  // 252-unit glyph (40% of 630) centred: tx = (1200-252)/2 = 474, ty = (630-252)/2 = 189.
  assert.match(svg, /transform="translate\(474 189\) scale\(10\.5\)"/);
});
```

- [ ] **Step 3: Run it to verify it fails**

Run: `cd docs && node --test scripts/icons-gen/brand-images.test.mjs`
Expected: FAIL — cannot find module `./brand-images.mjs`.

- [ ] **Step 4: Write the generator**

`docs/scripts/icons-gen/brand-images.mjs`:

```js
// Generates the brand rasters from the REAL Material Symbols `palette` glyph —
// the same icon the app bar renders (docs/app/Shared.elm: M3e.Icon.name "palette"):
//
//   docs/public/favicon.svg   48x48 plate + glyph   (deterministic, drift-gated)
//   docs/public/favicon.ico   16/32/48 multi-image  (raster, NOT drift-gated)
//   docs/public/og-card.png   1200x630 social card  (raster, NOT drift-gated)
//
// The file favicon.svg replaces carried a hand-copied path from the LEGACY
// Material Icons set. Two grids are in play and they disagree: Iconify NORMALISES
// material-symbols onto 0 0 24 24, while raw Google data and @m3e/icons use
// 0 -960 960 960 (origin at the baseline, negative Y). So the placement transform
// is COMPUTED from the declared viewBox — hard-coding it means a silent
// off-canvas glyph the day the source changes.

import { writeFileSync, readFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { resolveIcon, loadSets } from "./icons-to-js.mjs";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "..", "..", "..");

const PLATE = 48;
const PLATE_GLYPH = 26;
const OG_W = 1200;
const OG_H = 630;
const OG_GLYPH = Math.round(OG_H * 0.4); // 252

const GRADIENT = `<linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#8A6FE0"/>
      <stop offset="1" stop-color="#5B3F9E"/>
    </linearGradient>`;

/** Round to 7 decimals and strip trailing zeros, so output is stable. */
const num = (n) => String(Number(n.toFixed(7)));

export function plateTransform(viewBox, { plate, glyph, width, height }) {
  const [minX, minY, w, h] = viewBox.split(/\s+/).map(Number);
  if (w !== h) {
    throw new Error(`Glyph viewBox '${viewBox}' is not square; scaling it into the plate would distort it.`);
  }
  const scale = glyph / w;
  const insetX = ((width ?? plate) - glyph) / 2;
  const insetY = ((height ?? plate) - glyph) / 2;
  return `translate(${num(insetX - minX * scale)} ${num(insetY - minY * scale)}) scale(${num(scale)})`;
}

export function renderFavicon({ viewBox, path }) {
  const t = plateTransform(viewBox, { plate: PLATE, glyph: PLATE_GLYPH });
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${PLATE} ${PLATE}" role="img" aria-label="elm-m3e">
  <!-- GENERATED by docs/scripts/icons-gen/brand-images.mjs — do not edit.
       Glyph: material-symbols:palette, the same icon the app bar renders. -->
  <defs>
    ${GRADIENT}
  </defs>
  <rect x="1" y="1" width="46" height="46" rx="13" fill="url(#g)"/>
  <g transform="${t}">
    <path fill="#FFFFFF" d="${path}"/>
  </g>
</svg>
`;
}

export function renderOgSvg({ viewBox, path }) {
  const t = plateTransform(viewBox, { glyph: OG_GLYPH, width: OG_W, height: OG_H });
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${OG_W} ${OG_H}" role="img" aria-label="elm-m3e">
  <!-- GENERATED by docs/scripts/icons-gen/brand-images.mjs — do not edit. -->
  <defs>
    ${GRADIENT}
  </defs>
  <rect x="0" y="0" width="${OG_W}" height="${OG_H}" fill="url(#g)"/>
  <g transform="${t}">
    <path fill="#FFFFFF" d="${path}"/>
  </g>
</svg>
`;
}

export function glyph() {
  const cfg = JSON.parse(readFileSync(resolve(REPO, "config", "favicon.json"), "utf8"));
  if (!cfg.glyph) throw new Error("config/favicon.json has no `glyph` — the brand glyph is unset.");
  return resolveIcon(loadSets([cfg.glyph.split(":")[0]]), cfg.glyph);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const icon = glyph();
  const out = (n) => resolve(REPO, "docs", "public", n);
  writeFileSync(out("favicon.svg"), renderFavicon(icon));
  console.log(`Wrote favicon.svg (viewBox ${icon.viewBox}).`);
}
```

Note `plateTransform` takes optional `width`/`height` so the same formula serves the square plate and the wide card. The OG path uses no `plate`.

- [ ] **Step 5: Run the test to verify it passes**

Run: `cd docs && node --test scripts/icons-gen/brand-images.test.mjs`
Expected: PASS, 5 tests. If the OG transform assertion fails, check `OG_GLYPH` is 252 and that `insetX`/`insetY` use `width`/`height`.

- [ ] **Step 6: Generate and inspect**

```bash
cd docs && node scripts/icons-gen/brand-images.mjs && cat public/favicon.svg
```
Expected: `translate(11 11) scale(1.0833333)` and a 24-grid path (small numbers, no negative Y).

- [ ] **Step 7: Wire into the gen chain**

In `docs/package.json`:

```json
"gen:brand-images": "node scripts/icons-gen/brand-images.mjs",
```

and add `gen:brand-images` to the `gen` chain immediately after `gen:icons`.

- [ ] **Step 8: Look at it as an image**

```bash
open docs/public/favicon.svg
```
Confirm a white palette glyph, centred, fully inside the rounded plate. A blank purple square means the transform is wrong — the text assertions cannot catch that.

- [ ] **Step 9: Commit**

```bash
git add config/favicon.json docs/scripts/icons-gen/brand-images.mjs docs/scripts/icons-gen/brand-images.test.mjs docs/public/favicon.svg docs/package.json
git commit -m "Generate favicon.svg from the real Material Symbols palette glyph"
```

---

### Task 2: multi-size `favicon.ico`

**Files:**
- Modify: `docs/package.json` (add `@resvg/resvg-js`, `png-to-ico` devDeps)
- Modify: `docs/scripts/icons-gen/brand-images.mjs`
- Modify: `docs/scripts/icons-gen/brand-images.test.mjs`
- Modify (generated): `docs/public/favicon.ico`

**Interfaces:**
- Consumes: `renderFavicon` from Task 1.
- Produces: `rasterise(svg, size) -> Buffer` (PNG bytes). Task 3 reuses it.

- [ ] **Step 1: Add the pinned rasterisers**

```bash
cd docs && pnpm add -D @resvg/resvg-js png-to-ico
```

These are pinned in `pnpm-lock.yaml`, so no contributor needs a `brew install` — which is why this is not ImageMagick (absent on this machine) or `sips` (macOS-only, so unusable in CI).

- [ ] **Step 2: Write the failing test**

Append to `brand-images.test.mjs`:

```js
import { rasterise } from "./brand-images.mjs";

test("rasterises the favicon SVG to a real PNG of the requested size", () => {
  const png = rasterise(renderFavicon({ viewBox: "0 0 24 24", path: "M12 3h4v4h-4z" }), 32);
  // PNG magic number.
  assert.deepEqual([...png.subarray(0, 4)], [0x89, 0x50, 0x4e, 0x47]);
  // IHDR width/height are big-endian uint32 at offsets 16 and 20.
  assert.equal(png.readUInt32BE(16), 32);
  assert.equal(png.readUInt32BE(20), 32);
});
```

- [ ] **Step 3: Run it to verify it fails**

Run: `cd docs && node --test scripts/icons-gen/brand-images.test.mjs`
Expected: FAIL — `rasterise` is not exported.

- [ ] **Step 4: Implement `rasterise` and the ICO output**

Add to `brand-images.mjs`:

```js
import { Resvg } from "@resvg/resvg-js";
import pngToIco from "png-to-ico";

const ICO_SIZES = [16, 32, 48];

export function rasterise(svg, size) {
  return new Resvg(svg, { fitTo: { mode: "width", value: size } }).render().asPng();
}
```

and extend the CLI block:

```js
  const favSvg = renderFavicon(icon);
  writeFileSync(out("favicon.svg"), favSvg);
  console.log(`Wrote favicon.svg (viewBox ${icon.viewBox}).`);

  const icoPngs = ICO_SIZES.map((s) => rasterise(favSvg, s));
  writeFileSync(out("favicon.ico"), await pngToIco(icoPngs));
  console.log(`Wrote favicon.ico (${ICO_SIZES.join("/")}px).`);
```

The CLI block must become `async` (top-level `await` is available in ESM, so `await pngToIco(...)` works directly).

- [ ] **Step 5: Run the test, then generate**

```bash
cd docs && node --test scripts/icons-gen/brand-images.test.mjs
cd docs && node scripts/icons-gen/brand-images.mjs
file public/favicon.ico
```
Expected: tests PASS; `file` reports **`MS Windows icon resource - 3 icons`** — not `PNG image data`, which is what the old one was despite its extension.

- [ ] **Step 6: Exclude the rasters from the drift gate**

Open `docs/scripts/check-data-drift.mjs` and add `favicon.ico` (and, after Task 3, `og-card.png`) to whatever ignore mechanism it already uses. If it enumerates generated files explicitly, simply do not list them. Add a comment stating why: prebuilt native rasterisers are not byte-reproducible across platforms, so gating them would fail spuriously on another machine.

- [ ] **Step 7: Prove the exclusion works**

```bash
printf 'x' >> docs/public/favicon.ico && npm --prefix docs run check:drift; git checkout docs/public/favicon.ico
```
Expected: still fails only on `docs/data/reference.json` (the pre-existing failure), NOT on `favicon.ico`. Then confirm the SVG *is* gated:
```bash
printf '\n' >> docs/public/favicon.svg && npm --prefix docs run check:drift; git checkout docs/public/favicon.svg
```
Expected: fails naming `favicon.svg`. If it does not, the SVG is not gated and Task 1's determinism claim is unenforced — report it.

- [ ] **Step 8: Commit**

```bash
git add docs/package.json docs/pnpm-lock.yaml docs/scripts/icons-gen docs/public/favicon.ico docs/scripts/check-data-drift.mjs
git commit -m "Generate a real multi-size favicon.ico from the brand plate"
```

---

### Task 3: the Open Graph card, and repoint the 14 routes

**Files:**
- Modify: `docs/scripts/icons-gen/brand-images.mjs`
- Modify (generated): `docs/public/og-card.png`
- Modify: the 14 route modules under `docs/app/` that reference `favicon.ico`

**Interfaces:**
- Consumes: `renderOgSvg` (Task 1), `rasterise` (Task 2).
- Produces: `docs/public/og-card.png` at 1200×630.

- [ ] **Step 1: Emit the OG PNG**

Extend the CLI block:

```js
  writeFileSync(out("og-card.png"), rasterise(renderOgSvg(icon), OG_W));
  console.log(`Wrote og-card.png (${OG_W}x${OG_H}).`);
```

- [ ] **Step 2: Generate and verify the dimensions**

```bash
cd docs && node scripts/icons-gen/brand-images.mjs && file public/og-card.png
```
Expected: `PNG image data, 1200 x 630`. Then `open public/og-card.png` and confirm a centred white palette glyph on the gradient, nothing clipped, no text.

- [ ] **Step 3: Find every route that ships the wrong card**

```bash
rg -n "favicon.ico" docs/app
```
Expected: 14 files. Read one to see the exact shape before editing:

```elm
image = { url = [ "favicon.ico" ] |> UrlPath.join |> Pages.Url.fromPath, alt = "elm-m3e", dimensions = Nothing, mimeType = Nothing }
```

- [ ] **Step 4: Repoint them**

Replace `"favicon.ico"` with `"og-card.png"` in all 14, and fill in the metadata that was previously `Nothing` — scrapers use it:

```elm
image =
    { url = [ "og-card.png" ] |> UrlPath.join |> Pages.Url.fromPath
    , alt = "elm-m3e"
    , dimensions = Just { width = 1200, height = 630 }
    , mimeType = Just "image/png"
    }
```

Some call sites are one-liners and some are multi-line records (`Route/Roundtrip.elm`, `Route/Index.elm`, `Route/Reference.elm`, `Route/Components/All.elm` use the multi-line form). Match each file's existing layout; `elm-format` will normalise.

- [ ] **Step 5: Compile**

```bash
cd docs && ./node_modules/.bin/elm make $(find app -name '*.elm' | tr '\n' ' ') --output=/dev/null
```
Expected: `Success!`. If `dimensions`' record field names are wrong, the compiler will name them — check `Pages.Url`/`Head.Seo`'s expected shape rather than guessing.

- [ ] **Step 6: Confirm the old reference is gone**

```bash
rg -c "favicon.ico" docs/app || echo "no route references favicon.ico"
npm run check:format
```
Expected: no matches; format clean.

- [ ] **Step 7: Commit**

```bash
git add docs/scripts/icons-gen/brand-images.mjs docs/public/og-card.png docs/app
git commit -m "Generate a 1200x630 Open Graph card and repoint every route at it"
```

---

### Task 4: End-to-end verification

**Files:** none. Verification only — a wrong transform still produces valid SVG that passes every text assertion.

- [ ] **Step 1: Tab icon at real size**

```bash
cd docs && npx elm-pages dev
```
Confirm the tab icon is recognisably a palette at 16×16. Compare to the previous version:
```bash
git show ce8f981e:docs/public/favicon.svg > /tmp/favicon-old.svg && open /tmp/favicon-old.svg
```
The new one should be the Material **Symbols** drawing (rounder, more open) rather than the legacy Material Icons one.

- [ ] **Step 2: App bar unchanged**

The app-bar `palette` icon must look exactly as before — `palette` was deliberately kept out of `config/icons.json`, so it still comes from the ligature font and keeps its variable axes. If it changed, something registered it; find out what.

- [ ] **Step 3: Social card renders**

Confirm the built page emits the right tag:
```bash
rg -n 'og:image' docs/dist/index.html 2>/dev/null || echo "build unavailable — check the dev server's <head> instead"
```
`build:site` is broken by the corrupted `docs/node_modules`, so if `docs/dist` is stale, inspect `<head>` in the dev server and confirm `og:image` points at `/og-card.png` with 1200×630.

- [ ] **Step 4: `favicon.ico` is now consumer-free but present**

```bash
ls -la docs/public/favicon.ico && rg -c "favicon.ico" docs/app docs/src || true
```
Expected: file present, zero references. Leave it — a legacy tab-icon fallback costs nothing.

- [ ] **Step 5: Report honestly what could not be verified**

`test:browser` cannot run. Say so rather than implying the browser suite passed.

---

## Self-Review

**Spec coverage.** `favicon.svg` from `material-symbols:palette` → Task 1. Transform computed from declared viewBox, both grids tested → Task 1 Steps 2/4. Brand plate preserved → Task 1 Step 4, asserted Step 2. Multi-size ICO via pinned Node deps → Task 2. Rasters excluded from drift, SVG still gated → Task 2 Steps 6–7. 1200×630 OG PNG and the 14 repointed refs → Task 3. `favicon.ico` retained → Global Constraints + Task 4 Step 4. Font stays authoritative, `palette` unregistered → Global Constraints + Task 4 Step 2.

**Placeholder scan.** No TBDs. Task 2 Step 6 is the one under-specified step — it says "whatever ignore mechanism it already uses" because `check-data-drift.mjs` has not been read. That is a genuine read-then-edit instruction, and Step 7 proves the result empirically either way.

**Type consistency.** `plateTransform(viewBox, { plate, glyph, width, height })` is used with `{plate, glyph}` for the square case and `{glyph, width, height}` for the card; `insetX`/`insetY` fall back to `plate` via `??`. `rasterise(svg, size) -> Buffer` is consistent across Tasks 2 and 3. `resolveIcon`/`loadSets` match the icon-registry module's real exports.

**Deliberate deviation from the earlier draft of this plan.** That draft added `palette` to `config/icons.json` and registered it. Now that the font is staying, registering it would override the ligature font for that one icon and silently disable `weight`/`grade`/`opticalSize` on it. Hence `config/favicon.json`, and Task 4 Step 2 checks the app bar did not change.
