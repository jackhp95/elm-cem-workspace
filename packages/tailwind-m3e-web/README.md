# tailwind-m3e-web

[![CI](https://github.com/jackhp95/tailwind-m3e-web/actions/workflows/ci.yml/badge.svg)](https://github.com/jackhp95/tailwind-m3e-web/actions/workflows/ci.yml)

**`tailwind-m3e-web`** is the Tailwind v4 utility companion for **[@m3e/web](https://github.com/matraic/m3e)** — [matraic](https://github.com/matraic)'s framework-free Material 3 Expressive web components.

It wraps `@m3e/web`'s design tokens AND every public component CSS variable as Tailwind v4 `@theme` keys and `@utility` rules, so you can style `@m3e/web` components with the same Tailwind utility classes you already use everywhere else.

> **Scope:** This plugin targets `@m3e/web` specifically. The token layer (seed/ref/sys/@theme) follows M3 spec naming (`--md-sys-*`) and would technically work alongside any library that consumes those vars — but the component-utility surface (`/utilities` import) is `@m3e/web`-only. We do NOT target Google's `@material/web` (different var conventions, no shipped manifest).

- 🎨 Four-layer override cascade (seed → ref palette → sys role → @theme key) — override at the layer matching your intent.
- 🧮 OKLCH-derived tonal palettes — calibration table baked offline against [Material Color Utilities](https://github.com/material-foundation/material-color-utilities) (build-time only; no runtime dep on MCU). Change one seed colour, watch the whole app retint.
- 🧩 One auto-generated `@utility` rule per public `--m3e-*` CSS variable in `@m3e/web` (2,000+ rules; the exact count tracks the pinned `@m3e/web` version and is recorded in the header of `generated/utilities.css`).
- 🪶 Tailwind v4 only emits the rules you actually use — net bundle cost ≈ 0.

## Install

```bash
pnpm add tailwind-m3e-web
# Optional: install @m3e/web if you want the component-utility surface
pnpm add @m3e/web
```

> `@m3e/web` is an *optional* peer dependency. You only need it installed if you use `tailwind-m3e-web/utilities` (the component-utility surface). The main `tailwind-m3e-web` entry point (M3 design tokens) works without it.

Requires Tailwind v4, and a browser supporting both **`light-dark()`** (scheme-aware roles) and **relative-color `oklch(from …)`** (tonal palettes). The binding minimum per engine is the newer of the two:

| Browser | Minimum | Constraint |
|---|---|---|
| Chrome / Edge | **123+** | `light-dark()` (Chrome 123); `oklch(from …)` is older (119) |
| Safari | **17.5+** | `light-dark()` (Safari 17.5); `oklch(from …)` is older (16.4) |
| Firefox | **128+** | relative-color `oklch(from …)` (Firefox 128); `light-dark()` is older (120) |

`color-mix()` (elevation) is supported earlier than all of the above and is not the constraint.

## Use

```css
/* app.css */
@import "tailwindcss";

@import "tailwind-m3e-web";                  /* M3 tokens (Layers 0–3) */
@import "tailwind-m3e-web/utilities";        /* @m3e/web component setters */
@import "tailwind-m3e-web/roles-extended";   /* optional: success / info / warning */
```

> **Import order matters** — the token layer (`tailwind-m3e-web`) must load before `tailwind-m3e-web/utilities`. The utilities reference the `@theme` keys the token layer defines; reordering the imports silently breaks the cascade.

> **Requires Tailwind v4.** `tailwind-m3e-web/utilities` is built entirely from `@utility` rules, which Tailwind v3 does not recognize — v3 (and prettier) silently ignore the whole file with no error, so the component setters simply never emit. If your `@m3e/web` utilities produce no CSS, check that you're on Tailwind v4.

Tailwind only emits the classes it finds in your source. As usual for Tailwind v4, make sure your content is scanned (automatic content detection, or an explicit `@source`) so classes like `bg-primary` and `m3e-button-container-color-primary` are picked up from your HTML/templates.

Now you can use utilities like:

```html
<button class="bg-primary text-on-primary rounded-md-corner-medium shadow-md-level1">
  Themed button
</button>

<m3e-button class="m3e-button-container-color-primary">
  Themed @m3e/web button
</m3e-button>
```

## Density

Material density makes components more compact **without** rescaling type, icons, corner radius, or the layout grid. It is a signed offset on component _height_: each step trims `4px` (the `--md-sys-density-size` interval), clamped at the densest scale each component supports.

`@m3e/web` components read `--md-sys-density-scale` at runtime, so density is a **scope** utility — set it on a container and every component inside recomputes:

```html
<section class="density-2">
  <m3e-button>-8px shorter</m3e-button>
  <m3e-text-field label="Compact field"></m3e-text-field>
</section>
```

| Class | `--md-sys-density-scale` | Effect per control |
|---|---|---|
| `density-0` | `0` | default (also resets a denser subtree) |
| `density-1` | `-1` | −4px |
| `density-2` | `-2` | −8px |
| `density-3` | `-3` | −12px (densest most M3 components support) |

For an arbitrary or dynamic value, set the source var directly — same idiom as the scoped overrides below:

```html
<div style="--md-sys-density-scale: -3;"> … </div>
```

> **Accessibility.** Scales below `0` can push controls under the 48×48dp touch target, so higher density is opt-in by design — it only applies where you add the class. Reserve it for pointer-dense surfaces (data tables, long forms), not primary touch targets. Density is intentionally **not** linked to Tailwind's `--spacing`; your `p-*`/`gap-*` grid stays fixed.

## Override

The plugin exposes four cascading layers. Override at whichever matches your intent:

```css
/* Layer 0 — rebrand the whole app with one var. */
:root { --md-seed-primary: #06765b; }

/* Layer 1 — replace a single tonal palette while keeping others derived. */
:root {
  --md-ref-palette-secondary-40: #abcdef;
  /* (… all 12 tones) */
}

/* Layer 2 — change how a role maps to tones. */
:root { --md-sys-color-primary: var(--md-ref-palette-primary-30); }

/* Layer 3 — override one Tailwind utility's value. */
@theme { --color-primary: tomato; }
```

Scoped overrides work too — any descendant of a styled element picks up the new seed:

```html
<div style="--md-seed-primary: #b00020;">
  <!-- everything inside computes from red -->
</div>
```

## How it works

```
Layer 0  SEED              --md-seed-primary, --md-seed-error
       │
Layer 1  REF PALETTE       --md-ref-palette-<palette>-<tone>
       │                   computed via oklch(from var(--md-seed-*) <L> <c-transform> <h-transform>)
       │
Layer 2  SYS ROLES         --md-sys-color-*, --md-sys-typescale-*, …
       │                   uses light-dark() for scheme-aware values
       │                   @m3e/web reads these directly from shadow DOM
       │
Layer 3  @theme            --color-primary, --text-body-lg, --radius-md-corner-medium, …
                           Tailwind v4 generates utilities
```

The tone-to-OKLCH-L mapping is calibrated offline against `@material/material-color-utilities` and shipped as a small CSS table — no MCU dep at consumer install.

## API surface

| Entry point | Surface |
|---|---|
| `tailwind-m3e-web` | Strict M3 spec — primary/secondary/tertiary/error/surface/outline/inverse/background roles + 6 spec tonal palettes + `density-0…3` scope utilities. |
| `tailwind-m3e-web/utilities` | Pre-built `@utility` rules for every public `--m3e-*` var in the pinned `@m3e/web` peerDep range. |
| `tailwind-m3e-web/roles-extended` | Opt-in success/info/warning roles + tonal namespaces. |

Internal CSS files (`./seed.css`, `./ref/*`, `./sys/*`, `./theme.css`) are not reachable via `@import`; the `exports` map prevents direct access.

## Versioning

Peer-dep range: `"@m3e/web": "^2.5.0 <3"`. Plugin minors track `@m3e/web` minors (new component vars regen the utilities). Plugin majors track `@m3e/web` breaking changes OR breaking `@theme` rename/remove.

## Acknowledgments

- **[@m3e/web](https://github.com/matraic/m3e)** by [matraic](https://github.com/matraic) — the library this plugin exists to support. All component CSS variables exposed here come from there. If you aren't using `@m3e/web`, this plugin probably isn't what you want.
- **[Material Color Utilities](https://github.com/material-foundation/material-color-utilities)** — referenced at build time to calibrate the OKLCH tone table. Apache-2.0. No runtime dependency.

## License

MIT, © 2026 Jack H Peterson and contributors.

This project is not affiliated with or endorsed by Google. "Material Design" and "Material 3" are trademarks of Google LLC. `@m3e/web` is an independent project by matraic — this plugin builds on it but is maintained separately.
