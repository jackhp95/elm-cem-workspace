# M3 consumer scorecard — did the "four independent CEM parsers" problem actually get solved?

Written at the M3 integration point (`main`, HEAD = `345140b`), after M3.a
(cem-figma-connect), M3.b (m3e-okf) and M3.c (tailwind-m3e-web) all landed and
were verified together.

Evidence base for every claim below:

```
node tools/gate-all.mjs      # 29/29 passed, 0 failed — GATE-ALL GREEN
```

All three consumers appear in that inventory with their own scripts
(`cem-figma-connect: check`, `cem-figma-connect: test`, `m3e-docs: check`,
`m3e-docs: test`, `tailwind-m3e-web: test`), alongside the three per-consumer
bundle-provenance gates.

"Old" line counts and file paths below are read from the pre-migration
snapshots at `/Users/jhp/code/jackhp95/{cem-figma-connect,m3e-okf,tailwind-m3e-web}`
(the same checkouts `tools/copy-fidelity-*.sh` diffs against, read-only).

---

## 1. The four parsers, one row each

### 1.1 cem-figma-connect — CEM ingest (`src/ingest/cem.mjs`)

| | |
|---|---|
| **Deleted** | The raw-manifest parse and the `.d.ts` alias-inlining call chain. `src/ingest/cem.mjs` went **212 → 154 lines**; it no longer opens `custom-elements.json`, no longer calls `inlineTypeAliases()`, and no longer needs a `dist/` layout to find `.d.ts` files beside the manifest. The vendored `test/fixtures/m3e-web-2.7.0/**` CEM fixture (459 tracked files) went with it. |
| **Replaced by** | A read of Face B — `profiles/m3-kit/facts/cem-facts.json` — projected onto the small shape `matcher.mjs` / `merge.mjs` / `gap-report.mjs` already consumed. Tag reconciliation and `.d.ts` alias resolution now happen once, upstream, in `packages/elm-cem`. |
| **Non-CEM layer that legitimately remains** | Nothing in the ingest path. `src/ingest/dts-inline.mjs` is still **tracked and still unit-tested** (`test/cem-ingest.test.mjs`), but nothing in the pipeline calls it — see §3.1, this is dead code retained for its tests, not a live second parser. |

### 1.2 cem-figma-connect — Elm re-measurer (`profiles/m3-kit/emitters/elm-facts.build.mjs`)

| | |
|---|---|
| **Deleted** | The whole file — **995 lines** — plus its committed output `profiles/m3-kit/elm-facts.json` (169 KB). This was the re-measurer that read elm-m3e's `Facts.elm` and `.elm` sources to recover Elm module/constructor/setter names. |
| **Replaced by** | `profiles/m3-kit/emitters/elm.mjs` reads Face C — `profiles/m3-kit/facts/elm-api-facts.json` — emitted by the same `elm-cem --facts-bundle` run that emits Face B. Emitted-output changes are enumerated and justified as corrections in `docs/facts-bundle/m3a-generated-diff.md`. |
| **Non-CEM layer that legitimately remains** | The userland seams (`textSeam` / `htmlSeam` / `attrSeam`) stay as **profile config**, which is where they already lived and where the coverage audit (§6) says they belong — they are project policy, not measurable facts. |

### 1.3 m3e-okf — `scripts/extract.mjs`

| | |
|---|---|
| **Deleted** | The hand-ported `reconcileTagNames` (old `extract.mjs:44-88` — a copy of elm-cem's registration-export-vs-jsdoc tag-truth resolver) and the TypeScript literal-union alias scanner (old `:144-164`). The script no longer clones-and-builds a Custom Elements Manifest at all. `extract.mjs` went **614 → 570 lines**. |
| **Replaced by** | A read of Face B — `data/cem-facts.json`. Tag-truth findings are now reported straight out of the bundle's own `tagReconciliation.mismatches`; enum types come from Face B's `.d.ts`-resolved `type.resolved`; the upstream pin stamped into `data/sources.json` comes from the bundle's `provenance.source` (currently `v2.7.3`) rather than a hand-managed SHA. |
| **Non-CEM layer that legitimately remains** | Two, both named by the coverage audit. (a) **README prose + the README-vs-bundle drift audit** — kept as a thin layer over the bundle (audit §5.1): the bundle is ground truth, README API claims are *verified against it* and flagged in `data/report.md`, never silently trusted. (b) **The resting `:host` `display` derivation**, read out of a `css` template literal in `.cache/m3e/packages/web/src/**/*.ts`. The audit calls this **a real gap** (§5.3): it is not a CEM or `.d.ts` fact, so no face carries it today. |

### 1.4 tailwind-m3e-web — `bin/generate-component-utilities.mjs`

| | |
|---|---|
| **Deleted** | The manifest read and walk — old `:32` `MANIFEST_PATH = node_modules/@m3e/web/dist/custom-elements.json` plus the `mod.declarations` traversal and the cross-module merge for elements split across modules (old `:130-160`). File went **276 → 271 lines**; the size barely moved because the parse it dropped was replaced by a one-line bundle read, and the bulk of the file was never CEM parsing. |
| **Replaced by** | A read of Face B's `components[].cssProperties` from `data/cem-facts.json`. Face B has already done the dedup/merge the old cross-module merge was hand-rolling. |
| **Non-CEM layer that legitimately remains** | (a) **Tailwind type inference** (`inferType()` + the `OVERRIDES` map): the manifest declares no `syntax` and no default for these custom properties, so the `<length>` / `<color>` / `<number>` typing is this package's own judgement, not a CEM fact — correctly kept local. (b) **Hand-authored `src/density.css`**, and the rest of `src/**` (theme/palette/typescale), which were never CEM-derived. |

---

## 2. Verdict

**The "four independent CEM parsers" problem is solved for the four parsers it
named — with one documented, pre-authorised exception and two honest caveats.**

What "solved" means concretely, and how it was checked:

1. **There is exactly one CEM parser left in the workspace that answers
   component-API questions**: `packages/elm-cem/bin/elm-cem.js`. Enforced by
   `tools/check-single-cem-facts.mjs` (green in the sweep) and visible in the
   fact that no consumer any longer opens a `custom-elements.json` to learn what
   a component's attributes, slots, events, enums or CSS properties are.

2. **All three consumers read the same bytes.** Each keeps its own committed
   Face B copy (deliberately — see the rationale in
   `tools/check-bundle-provenance-tailwind.mjs`'s header: each package stays
   independently publishable). Verified two ways:

   ```
   shasum -a 256 packages/cem-figma-connect/profiles/m3-kit/facts/cem-facts.json \
                 packages/m3e-okf/data/cem-facts.json \
                 packages/tailwind-m3e-web/data/cem-facts.json
   2e227c2147fa23123e1c012f7bda99e684a28d485ba3048048e21f13ff9d3274  …cem-figma-connect/…
   2e227c2147fa23123e1c012f7bda99e684a28d485ba3048048e21f13ff9d3274  …m3e-okf/data/cem-facts.json
   2e227c2147fa23123e1c012f7bda99e684a28d485ba3048048e21f13ff9d3274  …tailwind-m3e-web/data/cem-facts.json
   ```

   All three are **byte-identical to each other** (2 630 228 bytes each), and each
   is independently proven byte-identical to a *fresh* regeneration from the
   producer by its own provenance gate (`check-bundle-provenance{,-m3e-okf,-tailwind}`,
   all green). Mutual agreement is therefore not a coincidence of one commit —
   it is transitively enforced: three copies, each pinned to the same single
   producer output.

3. **Exactly one `@m3e/web` pin** — 2.7.3, across four declarations in three
   `package.json` files (`tools/check-single-m3e-web-pin.mjs`, green). m3e-okf's
   upstream TS checkout `.cache/m3e` is at tag `v2.7.3`, matching.

4. **~1 100 lines of duplicated parsing are gone** (995 + 58 + 44 + 5 net),
   along with a 169 KB committed re-measured facts file and a 459-file vendored
   CEM fixture.

### Still reading a CEM by some route — the complete list

| Where | What it reads | Status |
|---|---|---|
| `packages/elm-cem/bin/elm-cem.js` | `@m3e/web` `custom-elements.json` (+ `.d.ts`) | **The one producer.** This is the point. |
| `packages/cem-figma-connect/src/tokens/derive.mjs:290,422` | `test/fixtures/m3e-web-2.5.14/dist/custom-elements.json`, as **text**, via a regex for `var(--md-sys-*, …)` fallback values | **Authorised exception**, resolved as R-004 in `docs/facts-bundle/coverage-audit.md` §11: those 190 token fallbacks live in five `kind: "variable"` declarations (`ColorToken`, `ElevationToken`, `ShapeToken`, `StateToken`, `TypescaleToken` under `src/core/shared/tokens/`) that register no custom element, so they are outside Face B's "one entry per authoritatively-tagged custom element" contract *by construction*, not merely omitted from it. A token-correspondence input, not a component-API question. Not a component parser. |
| `packages/m3e-okf/scripts/extract.mjs:216` | `.cache/m3e/packages/web/src/**/*.ts` — `:host { display: … }` out of a `css` template literal | **Known gap**, coverage audit §5.3. Not a CEM read (it is TS source), but it *is* a fact-about-components read from outside the bundle. |
| `packages/m3e-okf/scripts/render-verify.mjs:129` | `.cache/m3e/packages/web/dist/custom-elements.json` | **Real, still live.** A manual visual-verification script; not in `check`, not in `test`, not in `gate-all`. It parses a locally-built manifest to drive rendering. Small and out of the milestone's declared scope, but it is a fifth CEM read and this scorecard will not pretend otherwise. |
| `packages/elm-m3e/docs/scripts/examples-gen/lib/oracle.mjs:16` | `docs/node_modules/@m3e/web/dist/custom-elements.json` | **Real, still live.** elm-m3e's own examples generator builds a slot/attribute oracle straight from the manifest. It was never one of the "four", and elm-m3e is the producer's own consumer — but it is an independent manifest read that Face B could plausibly serve. |
| `packages/cem-figma-connect/research/spikes/inline-coverage.js:19` | `dist/custom-elements.json` | Historical research spike in its own nested pnpm workspace. Not wired into anything. |
| `packages/tailwind-m3e-web/test/check-privates.test.mjs:39` | asserts the file **exists** in `node_modules/@m3e/web/dist` | Not a parse. Existence assertion only. |

So the accurate claim is: **solved, except** `render-verify.mjs` and
`oracle.mjs` — two manifest readers outside the milestone's four, neither of
which was ever claimed to be in scope, plus `derive.mjs`'s explicitly-authorised
text scan.

---

## 3. Caveats that a green sweep does not cover

These are honest limits of the current evidence, not failures. They are
reported, not fixed, because each would be a design change rather than a seam.

### 3.1 A dead alias-inliner is still tracked

`packages/cem-figma-connect/src/ingest/dts-inline.mjs` is a faithful standalone
port of elm-cem's `inlineTypeAliases()` / `collectLiteralAliases()`. M3.a removed
its last caller but kept the file and its tests. It cannot drift *into* the
pipeline (nothing imports it outside tests), but as long as it exists, a future
reader can mistake it for a live second implementation of a bundle fact. Its
header comment does say so; deleting it is a judgement call M3 did not make.

### 3.2 Two consumers' generated artifacts are not gated against regeneration

- `tailwind-m3e-web`: `generated/utilities.css` and
  `generated/CSS_CUSTOM_PROPERTIES.md` are regenerated from `data/cem-facts.json`
  by `bin/generate-component-utilities.mjs`, but the only thing that *proves*
  the committed copies match is `prepublishOnly`
  (`pnpm run generate && git diff --exit-code -- generated/`), which `gate-all`
  never runs. The bundle could be regenerated and `generated/**` left stale, and
  the sweep would stay green. cem-figma-connect has the analogous proof
  (`tools/check-emit-determinism-cfc.mjs`, in the sweep); tailwind has none.
  **Checked by hand at this commit and it is *not* stale**: running
  `pnpm --filter tailwind-m3e-web run generate:utilities` left `git status`
  clean.
- `m3e-okf`: `check:okf` / `check:skill` prove the skill and OKF bundles
  regenerate clean *from* `data/components.json`, but nothing proves
  `data/components.json` itself matches a fresh `extract.mjs` run — and nothing
  can, hermetically, while that run needs the gitignored `.cache/m3e` checkout.
  **Checked by hand at this commit and it is *not* stale**: running
  `pnpm --filter m3e-docs run gen:extract` left `git status` clean
  (55 components, 116 elements, 97 findings).

### 3.3 `.cache/m3e`'s actual vintage is not verified against the bundle

`extract.mjs` stamps `data/sources.json` with `provenance.source.version` from
**Face B** (`v2.7.3`), while the README prose and `:host display` values in the
same run come from whatever `.cache/m3e` happens to be checked out at. Those two
are only equal by convention. At this commit they agree — `.cache/m3e` is at tag
`v2.7.3` — but a stale local clone would silently produce v2.5-era prose stamped
`v2.7.3`. That is precisely the flavour of drift this milestone exists to remove,
and it is the one place M3.b left it unpoliced. A one-line assertion in
`extract.mjs` (read `.cache/m3e/packages/web/package.json`'s `version`, compare
to `PROVENANCE.source.version`, fail loudly) would close it.

### 3.4 cem-figma-connect's token layer reads a frozen copy of a sibling package

`src/tokens/derive.mjs` and `src/tokens/audit.mjs` read
`test/fixtures/tailwind-m3e-web-0.1.0/src/**` — a vendored snapshot of what is
now the in-workspace sibling `packages/tailwind-m3e-web/src/**`. Both are
labelled version 0.1.0; they have **diverged**:

```
SAME  theme.css        SAME  sys/shape.css     SAME  seed.css
DIFF  sys/typescale.css     (7 lines)
DIFF  sys/color.css         (12 lines)
```

The divergence is not cosmetic. The live sibling has already applied fixes that
cem-figma-connect's committed `profiles/m3-kit/token-audit.md` still reports as
**open "required-code-change" / "spec-failure" findings**:

- `--md-sys-typescale-display-large-tracking` — the audit's remedy reads
  *"`tailwind-m3e-web/src/sys/typescale.css` — change … to `-0.25`"*. The live
  sibling already says `-0.015625rem` (= −0.25px). The fixture still says `+`.
- the four `container-tone-regression` rows (`--md-sys-color-on-{primary,
  secondary,tertiary,error}-container`, deltaE 14–16) correspond exactly to the
  `palette-10 → palette-30` light-mode tone change the live sibling has already
  made in `sys/color.css`. The fixture still says `10`.

This predates M3 (both files date to 2026-07-13, and `derive.mjs` pointed at
these fixtures before the migration), and every gate is green because both the
fixture and the audit report are internally consistent. It only becomes visible
now that the vendoring source and the vendored copy sit in one workspace. It is
reported, not fixed: repointing the token paths at the sibling would change
`profiles/m3-kit/tokens.json` and `token-audit.md` and would need
`test/fixtures/tailwind-computed-palette.json` re-derived — a redesign of M3.a's
inputs, not a seam.

### 3.5 Bundle-plumbing code is triplicated

Not a correctness problem today; a maintenance one. Three near-identical
generators and three near-identical drift gates:

- `packages/{cem-figma-connect,m3e-okf,tailwind-m3e-web}/scripts/gen-facts.mjs`
  — 74 / 72 / 72 lines. `m3e-okf`'s and `tailwind-m3e-web`'s differ in **2 lines
  out of 72** (a usage comment and a tmpdir prefix). cem-figma-connect's differs
  only by copying two files instead of one.
- `tools/check-bundle-provenance{,-m3e-okf,-tailwind}.mjs` — 153 / 143 / 153
  lines, with the `regenerateBundle()` invocation (the exact `--flags-from` /
  `--config-from` / `--output` / `--facts-bundle` argv) copied verbatim **six**
  times across those three plus the three `gen-facts.mjs`, and a seventh and
  eighth time in `tools/gate-all.mjs` and `tools/ab-elm-cem.sh`.

The failure mode is concrete: changing elm-m3e's config file set means editing
eight call sites, and missing one produces a gate that regenerates a *different*
bundle than the generator writes — a drift gate that silently checks the wrong
thing. A single shared `regenerateFactsBundle(outDir)` helper plus one
parameterised provenance checker would collapse it. **Deliberately not done in
this pass** — it is a refactor, and a later concern.
