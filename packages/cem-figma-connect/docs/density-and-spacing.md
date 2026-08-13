# Density & spacing policy (v1 scope)

Task D4 (`plans/plan/D-tokens.md` Task D4). This is a **deliberate scope decision**,
recorded with rationale, not an oversight: `plans/BRIEF.md` §9 asks for
density-sensitive spacing, but the measured kit gives us nothing to bind that to.

**Measured reality this policy is built on:**

- Evidence #13: the m3-kit copy's Figma variable dump
  (`research/figma-dumps/kit-variables.json`) has 304 variables across 6 families
  (`Schemes` 49, `State Layers` 147, `Static` 95, `Corner` 10, `Tracking` 2,
  `Add-ons` 1) — **zero** are spacing or density variables. There is nothing on the
  Figma side to stamp a `--md-sys-spacing-*`-style codeSyntax onto (the mechanism
  Task D3 uses for color/corner/typescale tokens has no target here).
- Evidence #4: a real `get_design_context` call against a FRAME
  (`Examples/Messaging-Mobile` 56615:46684) confirmed generated layout code
  hard-codes spacing as literal arbitrary-value Tailwind classes — `px-[24px]`,
  `gap-[8px]` — because no spacing token exists on the Figma side to reference
  instead.

Given that, this policy splits spacing into two concerns with different owners.

## 1. Component-internal spacing — the component's own runtime concern

Padding, icon gaps, and touch-target sizing *inside* one `@m3e/web` component are
**not this project's concern to encode as a token-table row.** They are already
handled, end to end, by tailwind-m3e-web's density system:

- `tailwind-m3e-web/src/sys/density.css` declares the raw tokens:
  `--md-sys-density-scale: 0` (default) and `--md-sys-density-size: 0.25rem`
  (the base spatial unit, 4px).
- `tailwind-m3e-web/src/density.css` surfaces four **scope utilities**,
  `density-0` … `density-3`, that set `--md-sys-density-scale` to `0, -1, -2, -3`
  on a subtree. Per that file's own header comment: each @m3e/web component
  reads the scale at runtime via
  `calc(max(minScale, --md-sys-density-scale) * --md-sys-density-size)` and
  trims **4px per level** off its own base dimension (0 / −4px / −8px / −12px),
  clamped at whatever minimum scale that particular component supports.
- This is **already shipped** and requires nothing from this repo: a consumer
  who wants a denser button row adds `class="density-2"` (or equivalent) to a
  container; the components inside recompute their own size.

**The token table's job here is nothing.** `profiles/m3-kit/tokens.json` (Task D2)
does not — and should not — grow a row for this. There is no Figma variable to
correspond to (`--md-sys-density-scale` is not backed by any kit variable), and
adding a synthetic row would misrepresent a runtime CSS custom property as if it
were a derived Figma↔code correspondence.

**Explicitly NOT density-affected, by tailwind-m3e-web's own documented design:**
`density.css`'s header comment states density is "deliberately NOT wired to
Tailwind's `--spacing`" — M3 keeps the 4/8dp layout grid, typography, icon sizes,
and corner radius fixed under density; only component *chrome* shrinks. That
design choice is exactly why §2 below treats between-component layout spacing as
a wholly separate, non-density-sensitive concern.

## 2. Between-component (layout) spacing — stays literal px in v1

Spacing *between* components in Figma-generated layout (frame padding, flex/grid
gaps in auto-layout) is a different problem: it isn't a component's own runtime
concern, and — per evidence #4/#13 above — there is no Figma-side token to bind
it to at all.

**Policy: this stays literal px in v1. The tool does not rewrite it.**

An advisory mapping table is provided — `profiles/m3-kit/spacing-advisory.json`
— that maps common px values to the Tailwind gap/padding utility of the same
magnitude (e.g. `8px → gap-2`, `16px → gap-4`), assuming Tailwind v4's default
`--spacing` scale (1 unit = 4px), which tailwind-m3e-web does not override. It
exists so a human or an agent adapting raw `get_design_context` output has a
quick, checked-in reference for "what utility name corresponds to this px
value" — **not** so the tool can silently substitute one for the other.

**Why no auto-rewrite (this is the load-bearing decision, not an oversight):**

- Per `plans/01-architecture.md` §1, Figma is authoritative for **design
  intent** and visual truth. Rewriting a literal `gap-[8px]` to `gap-2` is a
  no-op *only* if the kit's Tailwind config genuinely resolves `gap-2` to
  exactly 8px in every consuming context. If it doesn't (a different
  `--spacing` base, a consumer app with a customized theme, a future kit
  version), a silent rewrite would change the rendered layout while looking
  like a harmless "tidy-up" — exactly the kind of divergence the visual gate
  (Task C-series) exists to catch, but only after the fact and only if someone
  runs it.
- Every other codeSyntax stamping pass in this project (Task D3) only ever
  substitutes a name for an *equivalent* value — `var(--md-sys-color-on-surface,
  #1d1b20)` still resolves to the same computed color. There is no equivalent
  guarantee available for spacing, because there is no spacing *variable* on
  the Figma side to alias into — a px→utility rewrite here would be a value
  substitution dressed up as a naming one.
- Scope: this task is "policy + advisory data," not "a second rewrite engine."
  Building a safe, verified auto-rewrite (one that could prove equivalence
  before touching layout) is real, non-trivial engineering — see the
  `#future` section below — and is explicitly out of v1.

**Where the advisory table lives, and why:** `profiles/m3-kit/tokens.json` is
generated byte-stable by `src/tokens/derive.mjs --check` from the Figma variable
dump; hand-adding a spacing table there would either (a) require inventing rows
for variables that don't exist, breaking the derive/check invariant, or (b)
require `derive.mjs` to grow logic for a family it has no input data for. Instead
the advisory table is a **separate, hand-authored data file**,
[`profiles/m3-kit/spacing-advisory.json`](../profiles/m3-kit/spacing-advisory.json),
that is cross-linked from here and from
[`profiles/m3-kit/README.md`](../profiles/m3-kit/README.md), and is validated by
a small shape test (`test/spacing-advisory.test.mjs`) rather than a
derive-and-diff check, since there's nothing to re-derive it from.

That file's own `autoApplied: false` field and header comment repeat this same
point, so a reader who jumps straight to the JSON (skipping this doc) still
gets the "advisory, not applied" warning in context.

### Gap-report tooling (Plan A) — not wired, on purpose

`src/correspond/gap-report.mjs` (Task A7) reports CEM↔Figma *component/attribute*
correspondence gaps; it has no notion of layout spacing today, and this task does
not add one. Wiring even a "light pointer" line into its generated Markdown would
require regenerating the byte-stable, checked-in `profiles/m3-kit/gap-report.md`
tracer artifact (`test/gap-report.test.mjs` asserts byte-identity) for a
cross-link whose only value is discoverability — and this doc, plus the
profile README cross-link below, already give an agent reading either entry
point a path to the advisory table. Kept out to avoid scope creep on A7's logic;
revisit if gap-report ever gains a layout-spacing section for its own reasons.

## #future — out of v1, parked with rationale

The real fix, if this ever becomes worth the investment: **add spacing
variables to our own copy of the kit.** Since the Community kit only exists as a
Figma *file* copy this project owns (not something upstream/Google publishes),
nothing stops us from:

1. Adding a `Spacing/*` variable collection to the kit copy (e.g. `Spacing/2`,
   `Spacing/4`, `Spacing/6` → 8px/16px/24px, mirroring the Tailwind scale) —
   these would be **ours**, not Google's, so we'd own their naming and upkeep.
2. Re-binding the example frames' auto-layout gaps/padding to those variables
   instead of literal px, the same way any Figma auto-layout property can bind
   to a variable.
3. Stamping `codeSyntax` on them (the exact Task D3 mechanism, `variable.
   setVariableCodeSyntax("WEB", ...)`) so that generated layout code would emit
   `var(--spacing-2, 8px)`-shaped classes instead of `gap-[8px]` — giving
   generated layout the same "speaks our vocabulary" property Task D3 already
   won for colors/corners/typescale.

**Why this is parked, not built now:**

- It requires *designing* a spacing scale and variable-naming convention from
  scratch (there's no upstream one to normalize against, unlike color/corner/
  typescale where the kit's own naming was the source of truth) — a real design
  decision, not a mechanical derivation.
- It requires binding every example frame's auto-layout properties to the new
  variables by hand (or via a Figma Plugin API pass) — much larger surface than
  the codeSyntax-only stamping Task D3 did, and mutates the design file's actual
  layout data, not just its variable metadata.
- It only pays off once there are enough consuming frames/components generating
  layout code for the win (named spacing in generated Tailwind classes) to
  outweigh the setup cost — not yet established as a real bottleneck.
- It doesn't yet solve the density question either: per §1's evidence, density
  intentionally does *not* touch layout spacing, so this future work would still
  produce a single, non-density-sensitive spacing scale — density-sensitive
  *layout* spacing remains unsolved even after this future work, because the M3
  spec itself doesn't ask for it (only component chrome scales with density).

If picked up, the natural home is a new Plan-D-style task (e.g. "D-tokens
follow-up: kit spacing variables") that extends Task D2's ingest/derive
machinery to a new `Spacing` family, once the variables actually exist to
derive from.

## See also

- [`profiles/m3-kit/spacing-advisory.json`](../profiles/m3-kit/spacing-advisory.json)
  — the advisory px→utility table itself.
- [`profiles/m3-kit/README.md`](../profiles/m3-kit/README.md) — cross-links back
  here.
- `plans/BRIEF.md` §9 — the original density-sensitive-spacing ask.
- `plans/01-architecture.md` §1 — per-concern authority table ("Spacing/density
  — Code (tailwind-m3e-web density scopes) — Figma has no density tokens").
- `plans/plan/D-tokens.md` Task D4 — this task's brief.
- `research/evidence/2026-07-10-verification-ledger.md` Item 4 — evidence #4's
  `px-[24px]` / `gap-[8px]` measurement.
