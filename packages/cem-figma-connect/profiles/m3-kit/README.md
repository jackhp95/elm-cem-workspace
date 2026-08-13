# m3-kit visual gate — calibration record

This is the canonical record of how `profiles/m3-kit/visual.json`'s visual-gate
thresholds (`maxDiffRatio`, `pixelThreshold`) were chosen. It exists so this
profile is self-describing — a reviewer or a future maintainer shouldn't have
to go read `src/visual/diff.mjs`'s implementation to know what evidence backs
these numbers. `src/visual/diff.mjs` carries only a short summary and a
pointer back here; this file is where the full table lives.

Related: `profiles/m3-kit/gap-report.md` (the CEM<->Figma correspondence gap
report) is the other profile-adjacent standalone record — this file follows
the same precedent for the visual-gate's own evidence.

Also related: [`profiles/m3-kit/spacing-advisory.json`](spacing-advisory.json)
— the Task D4 density/spacing policy's advisory px→Tailwind-utility mapping
table (e.g. `8px → gap-2`). It is **not** auto-applied — see
[`../../docs/density-and-spacing.md`](../../docs/density-and-spacing.md) for
the full component-internal-vs-layout split and the rationale for why v1 does
not rewrite px automatically.

Also related: the **"Token family coverage"** section at the bottom of this
file — Task D6's family-by-family coverage table and policy rationale for
`profiles/m3-kit/tokens.json` (built by `src/tokens/derive.mjs`, human
decisions layered in via `profiles/m3-kit/tokens-overrides.json`).

## Chosen values

```json
{ "maxDiffRatio": 0.02, "pixelThreshold": 0.1 }
```

Both are the brief's suggested starting values for Task C4 (the pixel-diff
pipeline, `src/visual/diff.mjs`), read via `loadThresholds()`.

- `pixelThreshold` — pixelmatch's own per-pixel YIQ color-distance threshold
  (0..1, smaller = more sensitive to per-pixel color difference).
- `maxDiffRatio` — this module's own gate: the ratio of mismatched pixels to
  total union-box pixels; a comparison passes when `diffRatio <=
  maxDiffRatio`.

## CAVEAT — calibration is proxy-only, not yet code-vs-Figma same-state

**Every row in the table below is a proxy, not the real comparison this gate
performs in production.** The two capture paths that would produce a genuine
row (a code-side Playwright render and a Figma-side export of the exact same
component state) were not both available, in a matched pair, at the time this
calibration was measured (2026-07-10):

- The "same-pair" rows are **code-vs-code**: two (or three) byte-identical
  Playwright element-screenshot renders of the same element, re-captured.
- The "cross-variant" rows are **Figma-vs-Figma**: different variant exports
  (filled/tonal/outline/text/elevated) of the same nominal state, compared
  against each other.

**No row is a true code-vs-Figma pair for the same state.** That means
`maxDiffRatio: 0.02` is validated only against these proxies — it has **not**
been validated against the actual code-render-vs-Figma-export comparison the
gate exists to make in production.

**Treat `maxDiffRatio: 0.02` (and `pixelThreshold: 0.1`) as provisional
starting values.** Task C8 (live render + Figma export, driving both sides
from the same correspondence state — see `.superpowers/sdd/task-C8-brief.md`
Steps 1-2) **must re-verify `maxDiffRatio` against at least one genuine
matched code-vs-Figma pair before this gate is trusted to fail a real CI
build.** If C8's real pair shows meaningfully more pixel noise than these
proxies suggest (e.g. from font hinting, anti-aliasing, or sub-pixel
rendering differences between the Playwright renderer and Figma's own
rasterizer), `maxDiffRatio` and/or `pixelThreshold` should be revised here
and in `visual.json` at that point — not left at these provisional values.

## Fixture dimensions (measured 2026-07-10)

Both capture paths pin `deviceScaleFactor` 2, so these are directly
comparable pixel counts.

| File | Role | Dimensions |
| --- | --- | --- |
| `btn-57994-2322.png` | Figma export, Button (filled) set, "Type=Round, Size=Medium, State=Enabled" | 120x56 |
| `btn-57994-2262.png` | Figma export, Button - text set, same nominal state | 120x56 |
| `btn-57994-2282.png` | Figma export, Button - outline set, same nominal state | 120x56 |
| `btn-57994-2302.png` | Figma export, Button - tonal set, same nominal state | 120x56 |
| `btn-57994-2242.png` | Figma export, Button - elevated set, same nominal state | **136x72** (elevation shadow widens node bounds) |
| `figma-button-filled-medium.png` | A split/combo button (filled button + separate chevron segment) — **not** a plain Button variant | 178x56 |
| `shots/button-filled-run1.png` / `run2.png` (/ `run3.png`) | Code render (Playwright element screenshot), m3e-button variant=filled, no explicit `size` attribute pinned, byte-identical across runs | 134x80 |

The code renders never pinned a `size` attribute, so they cannot be proven to
correspond to any specific Figma export's exact state (Medium/Small/etc.) —
this is exactly why no row below is a genuine code-vs-Figma same-state pair
(see the caveat above).

## Calibration table (evidence, pixelThreshold=0.1, union-box aligned)

| Pair | Dims (a vs b -> union) | diffRatio | Verdict @ maxDiffRatio=0.02 |
| --- | --- | --- | --- |
| same-pair: button-filled-run1 vs run2 (byte-identical, code-vs-code) | 134x80 vs 134x80 -> same | 0.0000 | PASS (must pass) |
| same-pair: button-filled-run1 vs run3 (byte-identical, code-vs-code) | 134x80 vs 134x80 -> same | 0.0000 | PASS (must pass) |
| cross-variant: filled(2322) vs tonal(2302) (Figma-vs-Figma) | 120x56 vs 120x56 -> same | 0.8470 | FAIL (must fail) |
| cross-variant: filled(2322) vs outline(2282) (Figma-vs-Figma) | 120x56 vs 120x56 -> same | 0.8348 | FAIL (must fail) |
| cross-variant: filled(2322) vs text(2262) (Figma-vs-Figma) | 120x56 vs 120x56 -> same | 0.8500 | FAIL (must fail) |
| cross-variant: filled(2322) vs elevated(2242, diff size) (Figma-vs-Figma) | 120x56 vs 136x72 -> 136x72 | 0.5741 | FAIL |
| cross-variant: tonal(2302) vs outline(2282) (Figma-vs-Figma) | 120x56 vs 120x56 -> same | 0.7850 | FAIL |
| cross-variant: tonal(2302) vs elevated(2242) **[closest pair]** (Figma-vs-Figma) | 120x56 vs 136x72 -> 136x72 | 0.0788 | FAIL (must fail; smallest margin, ~4x maxDiffRatio) |
| other: figma-button-filled-medium (split/combo, 178x56) vs filled(2322) (Figma-vs-Figma, structurally different) | 178x56 vs 120x56 -> 178x56 | 0.3689 | FAIL (structurally different composition, correctly flagged) |

**pixelThreshold sensitivity** (checked on the closest pair, tonal vs
elevated, to confirm 0.1 isn't a knife-edge choice): ratio was 0.65 @
pixelThreshold=0.02, 0.60 @ 0.05, **0.079 @ 0.1**, 0.055 @ 0.2, 0.051 @ 0.3 —
every tested value in pixelmatch's own documented range keeps this pair
comfortably above maxDiffRatio=0.02, so 0.1 (pixelmatch's own documented
default) was kept rather than hand-tuned further.

**Conclusion from this (proxy-only) evidence:** at these numbers there is a
wide (~4x) separation between the code-vs-code same-pair rows (diffRatio
0.0000) and even the closest Figma-vs-Figma cross-variant row (diffRatio
0.0788). That separation is real and reassuring about the general shape of
the gate, but — per the caveat above — it says nothing about how much noise
a genuine code-vs-Figma same-state comparison will show, since rendering
differences between the Playwright renderer and Figma's own rasterizer
(font hinting, anti-aliasing, sub-pixel placement) are exactly the kind of
noise this calibration set cannot exercise. That is C8's job.

See `src/visual/diff.mjs`'s module docstring for the short summary and
`src/visual/diff.test.mjs` for the executable version of the decisive rows.

## Token family coverage (Task D6)

`profiles/m3-kit/tokens.json` (304 rows, one per Figma variable in the M3 kit;
built by `src/tokens/derive.mjs`, `pnpm run check` and
`node src/tokens/derive.mjs --check` gate it in CI) carries a `status` per
row: `"mapped"` (a real, verified code-side `--md-*` correspondence),
`"policy"` (a human decision, recorded in `tokens-overrides.json`, that a row
deliberately has **no** code-side correspondence to derive — not a gap), or
`"unmapped"` (undecided). Task D2 derived the mechanical rows and left 170
undecided; Task D6 closed every one of them to `mapped` or an explicit,
evidence-based `policy` decision. **0 rows are bare `unmapped`** (i.e. every
`unmapped` row, if any remain in a future re-derive, must carry a note — see
"Coverage assertion" below).

| Family | Rows | Mapped | Policy | Unmapped | Coverage |
| --- | --- | --- | --- | --- | --- |
| Schemes | 49 | 49 | 0 | 0 | 49/49 mapped |
| Corner | 10 | 10 | 0 | 0 | 10/10 mapped |
| Static | 95 | 75 | 20 | 0 | 95/95 mapped-or-policy |
| State Layers | 147 | 0 | 147 | 0 | 147/147 policy |
| Tracking | 2 | 0 | 2 | 0 | 2/2 policy |
| Add-ons | 1 | 0 | 1 | 0 | 1/1 policy |
| **Total** | **304** | **134** | **170** | **0** | **304/304, 0 bare unmapped** |

Regenerate this table's counts with:
`node -e "import('./src/tokens/derive.mjs').then(m => console.log(m.familyStatusCounts(m.deriveTokenRows())))"`.

### Family-level policy rationale

- **State Layers/\* (147, whole family) → `policy`.** These are Figma-side
  conveniences for painting hover/press/focus/drag overlays over each of the
  49 M3 color roles at 3 opacities (08/10/16 = 147). On the code side,
  `@m3e/web` consumes only 3 **generic** opacity tokens internally
  (`--md-sys-state-{hover,focus,pressed}-state-layer-opacity` — verified in
  `test/fixtures/m3e-web-2.5.14/dist/custom-elements.json`), and
  `tailwind-m3e-web` **intentionally** does not surface `--md-sys-state-*` as
  `@theme` keys — its own `src/theme.css` documents this: "consumed
  internally by `@m3e/web`'s state-layer `calc()` expressions, not surfaced
  as user-facing utilities." There is no per-color-role state-layer token on
  the code side to map *to* — this is a documented design decision on both
  sides of the boundary, not a gap.

- **Tracking/Small, Tracking/None (2) → `policy`.** Standalone letter-spacing
  preset constants (values `0.1` and `0`). Verified in
  `research/figma-dumps/kit-variables.json`: every per-scale
  `Static/<Scale>/Tracking` row (already `mapped` →
  `--md-sys-typescale-<scale>-tracking`) carries its own literal tracking
  value baked directly into `typescale.css` — none of them alias to either
  `Tracking/*` variable. These are reusable Figma-side constants whose values
  are already folded into the per-scale typescale tokens that are mapped;
  they have no independent code-side token of their own.

- **Add-ons/Section background (1) → `policy`.** A `COLOR` variable with 24
  mode values (one per M3/Monochrome/Pink/Rose/etc. theme ×
  light/dark/high-contrast). Verified: no `"section"` token exists anywhere
  in `tailwind-m3e-web/src/theme.css` or `m3e-web`'s `custom-elements.json` —
  this is a kit-specific presentation/documentation-background convenience
  used to paint section-divider frames inside the Figma file itself, not
  part of the M3 design-token vocabulary `@m3e/web` or `tailwind-m3e-web`
  consume.

### Static/\* Font-axis investigation (the 20 rows Task D2 left unmapped)

Two distinct sub-groups, both investigated against
`test/fixtures/tailwind-m3e-web-0.1.0/src/sys/typescale.css` (the code-side
naming source of truth) and `research/figma-dumps/kit-variables.json` (the
raw Figma values) — **not** bulk-`policy`'d without checking:

- **17 rows: the typeface/font-family axis** — 15 per-scale
  `Static/<Scale>/Font` rows + the 2 standalone constants they alias to,
  `Static/Font/Brand` (`"Roboto"`/`"Flow Circular"`) and `Static/Font/Plain`
  (same two values). `typescale.css` defines **exactly 4 axes per scale**
  (`font-size`, `font-weight`, `line-height`, `tracking` — verified by direct
  read) and **0** font-family axes; a repo-wide grep for `typeface` /
  `font-family` across the vendored fixtures returns zero matches. `@m3e/web`
  and `tailwind-m3e-web` do not expose a swappable font-family token at
  all — **`policy`**, not a gap.
- **3 rows: the standalone named-weight constants** — `Static/Weight/Bold`
  (`"SemiBold"`/`"Regular"` across modes), `Static/Weight/Medium`
  (`"Medium"`/`"Regular"`), `Static/Weight/Regular` (`"Regular"`). These are
  `STRING` constants holding a font-weight **name**, used as a Figma
  text-style-selection label. Verified in `kit-variables.json`: the
  already-`mapped` `Static/<Scale>/Weight` rows are `VARIABLE_ALIAS`es that
  resolve *through* these three constants — but the code-side
  `--md-sys-typescale-<scale>-font-weight` token they're mapped to is a
  **numeric** value (400/500/700) in `typescale.css`, independent of this
  name-string layer. `typescale.css` defines no standalone named-weight
  constant of its own — **`policy`**, not a gap.

No Static/\* row was mappable that D2 hadn't already mapped: all 20 were
verified to have zero code-side counterpart in the vendored fixtures.

### Coverage assertion

`node src/tokens/derive.mjs --check` (run by `pnpm run check`) asserts two
things: (1) the committed `tokens.json` is byte-stable — regenerating it from
`research/figma-dumps/kit-variables.json` + the vendored fixtures +
`tokens-overrides.json` produces byte-identical output — and (2) **zero rows
are `status:"unmapped"` with an empty/missing `note`** (a "bare" unmapped
row — a silent gap nobody has looked at). A `mapped` row, a `policy` row, or
an `unmapped` row *with* a note documenting the open question are all
acceptable; only a bare `unmapped` row fails the build. See
`src/tokens/derive.mjs`'s `checkCoverage()` and
`src/tokens/derive.test.mjs`'s "Task D6: checkCoverage" tests (including a
synthetic bare-unmapped-row case proving the assertion actually fails).
