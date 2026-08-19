# Render harness (task C1)

Deterministic headless rendering of any custom element from a profile's kit
bundle to a PNG — the CODE side of the visual verification gate (Plan C).
Ported and generalized from the 2026-07-10 spike at
`research/evidence/07-render-harness-notes.md` (the spike tree itself was removed in the Phase-0 deep clean), which proved byte-identical PNGs across
3 separate `playwright test` invocations
(`research/evidence/07-render-harness-notes.md`).

## Files

| File | Role |
|---|---|
| `page.html` | Static page: font-faces, transparent background, motion kill-switch, `#stage` mount point. No bundle reference — `capture.mjs` injects the bundle itself. |
| `page.mjs` | Mounts ANY custom element from URL query params (mount contract below) and exposes `window.__ready` once it has settled. |
| `static-server.mjs` | Dep-free `node:http` static server. Required because Chromium blocks `<script type="module">` under `file://` (opaque-origin CORS). |
| `bundle.mjs` | esbuild wrapper: bundles a profile's declared entry (`profiles/<name>/harness.json`) into `render-cache/bundle/<sha256>.js`. Content-hash keyed — a kit version bump changes the output, which changes the hash, which is a new cache entry. No manual invalidation. |
| `capture.mjs` | Playwright **programmatic API** (not the test runner). `createRenderer(profile)` launches chromium once and returns `renderOne(urlParams) -> PNG Buffer`; also a `--out=` CLI mode for one-shot subprocess renders. |
| `selfcheck.mjs` | Renders `m3e-button` filled and `m3e-switch` checked, 3x each in **separate `node capture.mjs` subprocesses**, sha256-compares each trio. |
| `fonts/` | Vendored Roboto 400/500/700 woff2 (from `@fontsource/roboto`) — zero network fetches during render. |

## Mount contract

```
?tag=m3e-button&attr.variant=filled&attr.size=medium&text=Label&slot.icon=m3e-icon:star
```

- `tag=<name>` — required. The custom element to create and mount.
- `attr.<name>=<value>` — repeatable. `el.setAttribute(name, value)`. An empty
  value (`attr.disabled=`) still sets the attribute — that IS "present" for
  boolean attrs.
- `text=<chars>` — sets `el.textContent` (default slot).
- `slot.<slotname>=<tag>:<arg>` — repeatable, named-slot content.
  `m3e-icon:<name>` renders `<m3e-icon slot="<slotname>" name="<name>">`
  (`name` is a Material Symbols snake_case name — evidence #12). Any other
  `<tag>` falls back to a generic `<tag slot="<slotname>"><arg></tag>`.

**Gotcha:** `m3e-switch`'s on/off attribute is `checked` (CheckedMixin), NOT
`selected` as in Material Web's `md-switch` — `selected` is silently ignored.
Per-component attribute names come from `dist/src/<component>/*.d.ts` `@attr`
jsdoc, not guessing.

## Usage

```sh
# One-shot render via CLI (own chromium launch, own process):
node src/visual/harness/capture.mjs --profile=m3-kit --tag=m3e-button \
  --attr.variant=filled --text=Label --out=/tmp/button.png

# Determinism self-check (the task's verify step):
node src/visual/harness/selfcheck.mjs
# -> "button: stable (3/3)", "switch: stable (3/3)", exit 0

# Programmatic (batch) use — reuses one chromium across many renders:
#   import { createRenderer } from "./capture.mjs";
#   const { renderOne, close } = await createRenderer("m3-kit");
#   const png = await renderOne({ tag: "m3e-button", "attr.variant": "filled", text: "Label" });
#   await close();
```

## Determinism knobs (all ported from the spike — do not re-derive)

- **Font**: local Roboto woff2 via `@font-face` with `font-display: block`;
  `font-synthesis: none`; `-webkit-font-smoothing: antialiased`. Kit
  components use `font-family: inherit` — the host page font is what renders.
- **Device scale factor 2**: context `deviceScaleFactor: 2` + screenshot
  `scale: "device"`.
- **Transparent background**: `html, body { background: transparent }` +
  screenshot `omitBackground: true`.
- **Motion**: context `reducedMotion: "reduce"` + screenshot
  `animations: "disabled"` (reaches shadow-DOM transitions) + page-level
  `* { transition: none; animation: none; caret-color: transparent }`.
- **Waits**: `customElements.whenDefined(tag)` -> `document.fonts.ready` ->
  `el.updateComplete` (lit) -> double `requestAnimationFrame`, exposed as
  `window.__ready`.
- **Other context pinning**: fixed viewport 800x600, `colorScheme: "light"`,
  `timezoneId: "UTC"`, `locale: "en-US"`.
- **Element screenshot**, not page screenshot — bounds-tight, no cropping math.

Caveat (from the spike, unchanged): cross-*machine* rendering (macOS vs Linux
CI) will differ in font rasterization/anti-aliasing — pin one render
environment, or diff with a small per-pixel tolerance if captures ever come
from heterogeneous machines.

## Adding a profile

Add `profiles/<name>/harness.json`:

```json
{ "entry": "@some/kit/all" }
```

`entry` is a bare import specifier resolved via esbuild from the repo root's
`node_modules` (`pnpm add` the kit package at the repo root first — its own
`dependencies` and `peerDependencies` must be installed there too, e.g. `lit`/
`tslib` for `@m3e/web`).
