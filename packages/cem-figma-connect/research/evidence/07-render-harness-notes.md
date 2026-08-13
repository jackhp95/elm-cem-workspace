# 07-render-harness — headless @m3e/web render spike

**Verdict: PASS.** `@m3e/web@2.5.14` components render headless in Playwright
Chromium and produce **byte-identical PNGs across separate test runs** (3 runs,
sha256-equal, both components).

## What's here

| File | Purpose |
|---|---|
| `harness.html` | Static page; mounts any element from query params: `?tag=m3e-button&attrs=variant:filled&text=Label` (`attrs` = comma-separated `name:value`, bare name = boolean attr, values URI-decodable) |
| `entry.js` → `assets/m3e-all.bundle.js` | esbuild bundle of `@m3e/web/all` (1.9 MB, self-contained ESM) |
| `assets/roboto-latin-{400,500,700}-normal.woff2` | Local Roboto from `@fontsource/roboto` — zero network fetches |
| `tests/render.spec.js` | Waits for readiness, element-screenshots the component |
| `tests/static-server.js` | Dep-free `node:http` static server (see gotcha #1) |
| `shots/*-run{1,2,3}.png` | Captures from three independent `playwright test` invocations |

Repro: `pnpm install && npx playwright install chromium`, then
`RUN_TAG=run1 npx playwright test && RUN_TAG=run2 npx playwright test && shasum -a 256 shots/*.png`.
Rebuild bundle after upgrading @m3e/web:
`node_modules/.bin/esbuild entry.js --bundle --format=esm --outfile=assets/m3e-all.bundle.js`.

## Normalization knobs used

- **Font**: local Roboto woff2 via `@font-face` with `font-display: block`;
  `body { font-family: "Roboto", sans-serif; font-synthesis: none; -webkit-font-smoothing: antialiased }`.
  M3e components declare `font-family: inherit` — the **host page font is what
  renders**; the package ships no font and never names Roboto (only the three
  Material Symbols families, for `m3e-icon`). So Roboto (not Roboto Flex) at
  weights 400/500/700 covers the M3 typescale; label-large (buttons) uses
  weight 500.
- **Device scale factor 2**: Playwright context `deviceScaleFactor: 2` +
  `screenshot({ scale: "device" })`. Verified: button PNG is 134×80 px for a
  67×40 CSS-px element.
- **Transparent background**: `html, body { background: transparent }` +
  `screenshot({ omitBackground: true })`. Verified via alpha in corners.
- **Motion**: context `reducedMotion: "reduce"` (m3e reads
  `prefersReducedMotion` internally) + `screenshot({ animations: "disabled" })`
  (reaches shadow-DOM transitions, which page CSS can't) + page-level
  `* { transition: none; animation: none; caret-color: transparent }` as
  belt-and-braces for light DOM.
- **Waits**: `customElements.whenDefined(tag)` → `document.fonts.ready` →
  `el.updateComplete` (lit) → double `requestAnimationFrame`, exposed to the
  test as `window.__ready`.
- **Other context pinning**: fixed viewport 800×600, `colorScheme: "light"`,
  `timezoneId: "UTC"`, `locale: "en-US"`, workers: 1.
- **Element screenshot**, not page: `page.locator(tag).screenshot(...)`; the
  `#stage` wrapper has 8px padding so shadows/focus rings would not clip (the
  element screenshot itself is bounds-tight).

## @m3e/web loading gotchas

1. **`file://` does NOT work.** Chromium blocks `<script type="module">` from
   `file://` pages ("origin 'null' … blocked by CORS policy"). A real HTTP
   server is required — the spec spins up a dep-free `node:http` static server
   on an ephemeral port in `beforeAll`.
2. **No prebuilt browser bundle.** `@m3e/web`'s dist files import bare
   specifiers (`lit`, `tslib`, `@floating-ui/dom`,
   `@material/material-color-utilities`, `composed-offset-position`), and
   `lit`/`tslib` are *peerDependencies* you must install yourself. Either
   pre-bundle (esbuild, done here — trivial, no config) or maintain a large
   import map. No SSR/`isServer` issues; plain client-side lit 3.
3. **Entry point**: `@m3e/web/all` registers every element in one import.
   Per-component entries (`@m3e/web/button`, `@m3e/web/switch`, …) also exist
   if bundle size ever matters.
4. **No theme wrapper needed for baseline**: every design token has a baked-in
   M3 baseline fallback (e.g. `var(--md-sys-color-primary, #6750A4)`), so
   components render the default Material palette with no `<m3e-theme>` /
   token stylesheet. For Avetta-themed diffs, set `--md-sys-color-*` /
   `--md-sys-typescale-*` vars (or mount inside `m3e-theme`) on the harness
   page.
5. **API naming trap**: `m3e-switch` uses `checked` (CheckedMixin), **not**
   `selected` like Material Web's `md-switch`. `selected` is silently ignored
   (renders unselected). Driving attrs generically means per-component attr
   names must come from `dist/src/<component>/*.d.ts` jsdoc (`@attr` lines) —
   good machine-readable source for the future Figma-property→attr mapping.
6. `m3e-icon` text would need the Material Symbols variable font bundled
   locally too (not included in this spike).

## Stability results

Three fully separate `playwright test` invocations (fresh browser each run):

- `button-filled` (m3e-button variant=filled, "Label"): sha256
  `cc5f218e…` identical ×3.
- `switch-checked` (m3e-switch checked): sha256 `a1d832a2…` identical ×3.

Byte-identical, so no pixel-tolerance machinery is needed for the code side on
this machine. Caveat: cross-*machine* (macOS vs Linux CI) rendering will differ
(font rasterization/AA) — pin one environment or diff with a small per-pixel
tolerance if captures ever come from heterogeneous machines.

## Remaining for the Figma-vs-code diff loop (out of scope here)

- **Figma half**: export the matching component PNG at 2x via a live Figma
  bridge session (MCP `get_screenshot` / `download_assets`) — needs a live
  session, not doable in this offline spike.
- **Mapping**: Figma variant properties → `?tag=…&attrs=…` query strings
  (component-by-component table; see gotcha #5 for the attr source of truth).
- **Comparison**: pixelmatch/odiff with alignment (both sides transparent-bg,
  2x, bounds-tight crops make this near-trivial), plus a size-normalization
  step if Figma exports include drop shadows or padding.
- **Theming parity**: harness currently renders M3 *baseline* colors; for real
  diffs, inject the same design tokens the Figma library uses.
