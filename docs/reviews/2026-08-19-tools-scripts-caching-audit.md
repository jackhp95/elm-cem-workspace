# Scripts audit — dead/dubious value + redundant computation (whole workspace), 2026-08-19

**Date:** 2026-08-19 · **Branch:** `audit/tools-scripts-caching` (anchored to `main` @ `d444ac0`) ·
**Scope:** every executable/entrypoint script in the workspace — `tools/**` (38 `.mjs`/`.sh`,
incl. `tools/lib/`), plus every package's own `scripts/` · `bin/` · `hooks/` · `extract/` ·
`docs/scripts/` dir (~117 more), **excluding** `*.test.mjs` and pure library `src/`. ~155 scripts
assessed total.
**Method:** every `package.json` `scripts` block dumped and cross-referenced against
`tools/gate-all.mjs`'s discovered `check`/`test` fan-out, `tools/gen-hooks.mjs` targets,
`.claude/settings.json` hooks, `.github/workflows/*.yml`, `tools/family.json`,
`tools/snapshot-refs.json`, and the root `hooks/pre-push`. Every "dead" claim is backed by a cited
negative grep. Redundant-computation candidates were traced to the actual expensive call
(`elm make`, `elm-cem` codegen, `elm-pages build`, Chromium launch, `gh api`, network fetch). Two
parallel read-only agents covered the elm-m3e docs pipeline and the cem-figma-connect/okf/tailwind
clusters; every headline finding was spot-verified first-hand in this worktree.
**Read-only:** no code changed, no script deleted. Audit + recommendations only.

## Relationship to the two prior reviews (read these first, don't re-litigate)

This audit is the **caching + dead-script lens**. It deliberately does **not** re-solve two things
already owned elsewhere:

- **`docs/reviews/2026-08-17-thermonuclear-workspace-review.md` Theme 3** ("one script, N costumes")
  and its remediation (`docs/plans/2026-08-18-thermonuclear-audit-remediation.md`) already
  consolidated the biggest duplications: the 3 `check-bundle-provenance*.mjs`, the 4
  `copy-fidelity-*.sh`, the 7 hand-copied `hooks/pre-push`, the 8-site regen argv, and the 3
  consumer `gen-facts.mjs`. **Those are verified done** (see §3 confirmations). What remains is a
  short tail of duplicates that survived that pass.
- **`docs/reviews/2026-08-19-architecture-review.md`** (same day, HEAD `35c5aa30`) already owns the
  *structural* duplication axis: candidate 1 (`family.json` read 5× + `bump.mjs`'s 4th consumer
  copy + 4 discovery walkers), candidate 4 (skip-policy duplicated across bash/JS; gate test gaps),
  candidate 6 (token tier classifier ×3), candidate 7 (prop-shape taxonomy ×3), candidate 8
  (`bin/shared.js` resolver ×4), candidate 9 (elm-review-cem internals ×10), and defects L1/L2. This
  audit **cites and defers** to those rather than re-deriving them (§4).

New here, and not covered by either: a **complete dead/orphaned-script census**, the distinction
between plain dead code and **orphaned drift-gates** (a more serious gate-coverage gap), and a
systematic **redundant-computation** pass over the per-package build pipelines.

Note on Track A: the gate-all parallelization work (`gate-scheduler.mjs`, `regen.mjs`'s in-process
facts-bundle memoization, `build-site-cache.mjs`) **has merged** onto this branch (commit
`04dca04`) — later than the arch review's HEAD, which still described it as unimplemented. Findings
that touch gate-all's own internal facts regen are marked "overlaps Track A, deferred" (§4).

---

# TL;DR — top 5 recommendations (ranked by impact ÷ effort)

1. **Delete 3 genuinely-dead scripts (trivial, zero risk).**
   `brands/m3e/outputs/elm-m3e/docs/scripts/a11y-icon-button-labels.mjs` (zero invocations,
   self-describes as a manual one-shot), `brands/m3e/outputs/elm-m3e/scripts/fetch-mdn-native-summaries.mjs`
   (zero invocations, network one-off generator), and
   `core/elm-cem-compose/bin/stage-facts-elm-home.mjs` (a 168/170-byte-identical copy of
   elm-review-cem's, with **no caller** — elm-cem-compose has no `check:review`). Cited negative
   greps in §1. *Effort: minutes. Impact: removes rot + one duplicate.*

2. **Fix or delete the broken `generate:tones` script + the orphaned `gen-figma-config.mjs`
   generator.** `brands/m3e/outputs/tailwind-m3e-web/package.json:68` declares
   `"generate:tones": "node bin/calibrate-tones.mjs"` — that file **does not exist** in that package
   (calibrate-tones lives only in `core/tailwind-md3/bin/`). And `tools/gen-figma-config.mjs` writes
   `config/figma.generated.json` (copy-fidelity-tracked, `family.json:86`) that **nothing consumes**
   — it is absent from `GEN_CONFIG_ARGS` (regen.mjs:26-31) and the generator runs in no pipeline
   (only its unit test runs). Two silent liabilities: a broken script entry and a committed artifact
   that can stale with nothing to notice. *Effort: low. Impact: removes two false-safety surfaces.*

3. **Close the orphaned drift-gates — these are gate-coverage holes, not dead code.**
   Four *drift/verify gates for committed generated files* are defined as package scripts but are
   **unreachable from `gate-all`**, so the generated file they police can silently drift:
   `check:compose-attrs` (`gen-compose-attrs.mjs --check`, guards `Compose/Attrs.elm`),
   `check:roundtrip` (`verify-roundtrip.mjs`), `verify:split` (`check-split.mjs`), and the
   `check-skills.mjs` trio (only `workflow_dispatch` CI). Each is a real check wired to nothing that
   runs automatically. Wire the drift ones into gate-all (they're cheap); decide the skills lint
   explicitly. *Effort: low-medium. Impact: restores intended gate coverage.*

4. **Cache the docs `check:drift` recompute — the single largest sharable cost outside gate-all's
   own loop.** `check-data-drift.mjs` copies the repo to a scratch dir and re-runs the *entire*
   expensive gen pipeline (`gen:reference`'s `elm make --docs`, `gen:samples`, `gen:brand-images`)
   to byte-diff — and because `check:drift` sits in **both** elm-m3e's `check` and `build`
   (`build = run-s check:drift build:site`), it can run **twice per `gate`**. The same
   `elm make --docs` reference build is computed by three independent paths (`gen:reference`,
   `build:ci`, `check:drift`). Same content-hash-cache shape Track A already built in
   `tools/lib/build-site-cache.mjs` applies directly. *Effort: medium. Impact: removes the biggest
   per-package redundant elm compile.*

5. **Consolidate the surviving near-duplicate helper trio.** `stage-facts-elm-home.mjs` (×2, one
   dead — see #1), `skills/check-skills.mjs` (×3: 2 byte-identical + 1 drifted-ahead fork), and
   `fix-native-bins.mjs` (×2, ~90% identical) should collapse into one `tools/lib/` helper each —
   exactly the "share, don't duplicate" pattern `tools/lib/gen-facts-runner.mjs` established. The
   `check-skills` fork already proves the divergence risk (elm-review-cem's copy grew checks the
   other two lack). *Effort: low-medium. Impact: kills the last hand-synced tool copies.*

---

# Remediation status (2026-08-19) — see `docs/plans/2026-08-19-tools-scripts-caching-remediation.md`

A remediation pass (branch `fix/tools-scripts-caching`) executed the actionable items with
toolchain-verified evidence. **Three findings below were corrected during execution** — verifying
before implementing (receiving-code-review discipline) revealed the "dead scripts" are actually
legitimately-unwired *manual/maintenance tools*, not dead code:

- **SHIPPED:** (1) fixed the broken `tailwind-m3e-web` `generate:tones` (removed; `generate` →
  `generate:utilities`); (2) unified the `check-skills.mjs` trio to the richer elm-review-cem version
  (verified it passes on all 3 dirs first; kept per-package for mirror independence); (3) wired the
  orphaned `check:compose-attrs` drift-gate into elm-m3e's `check` (pure `--check`, side-effect-free,
  verified green).
- **CORRECTED — do NOT delete (§1 rows superseded):** `fetch-mdn-native-summaries.mjs` regenerates a
  *live consumed* config (`native-mdn.json`); `elm-cem-compose/bin/stage-facts-elm-home.mjs` is the
  *standalone-mirror* facts-staging mechanism (elm-cem-compose is mirror-published + depends on
  `elm-cem-facts`) — its real gap is being unwired, not being dead; `a11y-icon-button-labels.mjs` is an
  ongoing corpus a11y codemod. Deleting the first two would be a reproducibility/mirror regression.
- **DEFERRED (with reasons):** `verify:split` wiring (ELM_HOME concurrency hazard → Track A's isolation
  work); `check:roundtrip` wiring (mutates a tracked report file → needs a temp-path write first);
  `gen-figma-config.mjs` (genuine unfinished WIP — needs a product decision, don't destroy it);
  `fix-native-bins` dedup (mirror self-sufficiency); docs `check:drift` caching (§2.1 — build on Track
  A's `build-site-cache.mjs`, not a second mechanism).

The original findings below are preserved as-written; the corrections above supersede the specific
"delete" recommendations for the three tools named.

---

# 1. Dead / dubious-value scripts

Legend: **dead** = zero automatic *and* manual invocations found; **orphaned-target** = a defined
package script that no aggregate (`gen`/`check`/`test`/`build`/`gate`/`gate-all`/CI/hook) ever
reaches; **manual-only** = intentional human/external entrypoint, wired to nothing by design (low
concern, listed for completeness); **broken** = wired but points at a nonexistent target.

| Script | Claims to do | Invocation evidence | Verdict / recommendation |
|---|---|---|---|
| `brands/…/elm-m3e/docs/scripts/a11y-icon-button-labels.mjs` | one-shot: inject `aria-label`s into icon-button examples | grep: only its own header (`:23`) + prose in `skills/making-m3e-accessible/SKILL.md:90` & `Guide/Accessibility.elm:222` calling it a "one-shot transform". Not in any package.json/CI/gate/hook. | **DEAD** → delete (or move to a `dev-scripts/` if kept as a documented manual tool). |
| `brands/…/elm-m3e/scripts/fetch-mdn-native-summaries.mjs` | fetch MDN HTML summaries → `native-mdn.json` | grep: only self-refs (`:2,:31,:205`). Live `fetch()` at `:153`. One-off generator for a committed config. | **DEAD** (manual one-off) → delete or relocate; its output is committed so the generator is not needed at build time. |
| `core/elm-cem-compose/bin/stage-facts-elm-home.mjs` | seed facts pkg into ELM_HOME | only `check:review` caller is `core/elm-review-cem/package.json:10`; elm-cem-compose's `check` = `run-p check:*` = format+headless only (no `check:review`). Byte-copy of the live elm-review-cem one (168/170 lines identical). | **DEAD duplicate** → delete this copy; consolidate the live one into `tools/lib/` (§3). |
| `tools/gen-figma-config.mjs` | derive `config/figma.generated.json` (per-component docMeta) | not in any package.json/gate/hook/CI; only `gen-figma-config.test.mjs` (via gate-all's `discoverToolTests`) exercises its pure `deriveFigmaConfig`. Its own line 96 logs "NOT wired into GEN_CONFIG_ARGS yet". Output `figma.generated.json` is copy-fidelity-tracked (`family.json:86`) but **absent from `GEN_CONFIG_ARGS`** (regen.mjs:26-31) → nothing consumes it. | **Orphaned generator, unconsumed output** → either wire the output into the generator config (finish the "yet") or delete generator+config+fidelity entry. The passing unit test gives false confidence it's "used". |
| `brands/…/tailwind-m3e-web` `generate:tones` script | `node bin/calibrate-tones.mjs` | `tailwind-m3e-web/bin/` contains only `check-privates.mjs` + `generate-component-utilities.mjs`; **no `calibrate-tones.mjs`** (it lives in `core/tailwind-md3/bin/`). | **BROKEN script entry** → remove it, or repoint at the `tailwind-md3` dependency if tone calibration is still wanted here. |
| `brands/…/elm-m3e/docs/scripts/examples-gen/extract-matraic-examples.mjs` | clone/extract upstream matraic HTML examples | only `gen:examples-source` (docs pkg `:18`), which is **not** in the `gen` chain (`:7`) nor any aggregate. Network clone. | **Orphaned-target** (manual corpus refresh) → fine to keep, but label it a manual step; not run by any gate. |
| `brands/…/elm-m3e/scripts/check-split.mjs` | A/B split byte-identity + registry-check | only `verify:split` (elm-m3e pkg `:31`); nothing chains `verify:split`. Runs `elm-cem split` + `registry-check` (`:40,:66`). | **Orphaned drift-gate** → see §1a. |
| `tools/preflight-bar.sh` | validate a Gauntlet BAR before dispatch | grep: only `GAUNTLET-LEDGER.md:523` narrative + self. Not in any gate/package.json. | **Manual-only** (gauntlet manager tool) → keep; intentionally human-invoked. No action. |
| `tools/publish-mirror.mjs` | publish a package to its standalone mirror | README:21, VISION:116 (manual); imported by `check-mirror-drift.mjs:18` (`readState`); tested. | **Manual-only** (release tool) → keep. |
| `tools/fetch-snapshots.mjs` | materialize A/B + copy-fidelity snapshots into `.cache/snapshots/` | nothing calls automatically (documented in `gate-all.mjs`'s `CHRONIC_SKIPS`, `:99-108`). Referenced by `snapshot-refs.json`, `family.json` notes, `ab-*.sh` comments. | **Orphaned-by-design** (network) → keep; arch-review candidate 4 proposes a scheduled CI lane for it. |
| `core/cem-figma-connect/scripts/render-batch.mjs`, `render-example.mjs`, `src/visual/review/server.mjs` | Chromium screenshot batch / single / human-review web app | grep-negative in package.json/yml/hook/tools. `review/server.mjs` logic is covered by `server.test.mjs`. | **Manual-only** → keep, but note the two render scripts duplicate `capture.mjs`'s Chromium pipeline (§2/§3). |
| `m3e-api-okf/scripts/{friction-log,friction-review,install,okf-update,render-verify}.mjs` | friction JSONL / gh-issue digest / consumer installer / consumer self-update / jsdom examples-vs-build check | grep-negative in package.json/gate/CI. `install.mjs`/`okf-update.mjs` are documented external consumer entrypoints; `friction-*` are manual. | **Manual-only** → keep. **Exception:** `render-verify.mjs` does a real build-vs-examples cross-check nothing else covers — candidate to promote into `check` (borderline gate gap). |
| `core/elm-html-intermediate-representation/bench/run.{mjs,sh}` | merge-cost microbenchmark | only `bench` script; self-notes "never a gate". | **Manual-only** (reporting) → keep. |
| `tools/tasks.mjs` | root task runner / "the one component that knows the whole family graph" | root `tasks` script + `gate.mjs:24`. **But walks `packages/` only** (`:28,:74`) → post-reorg reports `(none)`. | **Effectively blind** → cite arch-review **L2**; fix under arch-review candidate 1. Not dead, but dubious value until repointed. |

## 1a. Orphaned drift-gates (a distinct, more serious class — these are *supposed* to run)

These are not "dead code" — they are **verification gates for committed generated files**, defined
as package scripts, that no automatic aggregate reaches. The generated file they police can drift
from its source with nothing to catch it. This is a gate-coverage hole, worse than an unused script.

| Gate | Guards | Why it never runs automatically | Fix |
|---|---|---|---|
| `check:compose-attrs` = `gen-compose-attrs.mjs --check` (docs pkg `:37`) | `docs/app/Route/Components/Compose/Attrs.elm` (generated from `M3e/Attributes.elm`) | docs pkg has no aggregate `check`; elm-m3e's `check` does not proxy `check:compose-attrs`; not in the `gen` chain either | wire `check:compose-attrs` into elm-m3e's `check` (one line), same as `check:nav`/`check:drift` are proxied |
| `check:roundtrip` = `verify-roundtrip.mjs` (+ `roundtrip/{join,escape-scan,dom-diff,gen-harness-route}.mjs`) (docs pkg `:36`) | HTML↔Elm roundtrip fidelity | no elm-m3e `check:roundtrip` proxy; docs has no aggregate `check`. (Note: `test:roundtrip` runs the roundtrip `*.test.mjs` — a *different* thing — so the unit tests run but the SSR verify gate doesn't.) | proxy it, or fold into an existing drift step |
| `verify:split` = `check-split.mjs` (elm-m3e pkg `:31`) | the `elm-m3e` → `elm-m3e-icons`/`elm-m3e-families` package split byte-identity + registry-check | nothing chains `verify:split` | wire into elm-m3e `check` or gate-all (it does run `elm-cem split` — a few seconds) |
| `check-skills.mjs` ×3 (`core/elm-cem/skills/`, `core/elm-review-cem/skills/`, `brands/…/elm-m3e/skills/`) | skills frontmatter/link hygiene | invoked only from each package's `workflow_dispatch`-only CI `skills` job; never in root CI / gate / gate-all / hooks | decide: wire one shared lint into gate-all, or accept skills-lint as manual and document it |

The `gen-compose-attrs` case is the sharpest: it was built (compose feature B9, per `GAUNTLET-LEDGER.md`)
*with* a `--check` drift gate, and that gate is currently inert — precisely the "recast/drift can
ship silently" failure this family guards against everywhere else.

---

# 2. Redundant-computation opportunities (recompute → cache/share)

Ordered by cost. Each entry: what's recomputed · how many independent call sites · the expensive
call · proposed mechanism. gate-all's *own internal* facts-bundle regen is **excluded** here — it is
Track A's explicit scope (§4).

### 2.1 — docs `check:drift` re-runs the whole gen pipeline (biggest sharable cost)
- **What:** `brands/…/elm-m3e/docs/scripts/check-data-drift.mjs` copies the repo to a scratch dir
  and re-executes `gen:reference` + `gen:samples` + `gen:brand-images` to byte-diff against the
  committed outputs (`check-data-drift.mjs` GEN_STEPS, run via `execFileSync`).
- **Expensive call:** `gen:reference` → `extract-reference.mjs` runs `elm make --docs docs.json`
  (`extract-reference.mjs:297`, `execSync`, seconds). `gen:brand-images` rasters via resvg.
- **Call-site multiplicity:** `check:drift` is in **both** elm-m3e `check` **and** `build`
  (`build = run-s check:drift build:site`), so a full `gate` (`run-s check build:site test`) can run
  it **twice**. Separately, the same `elm make --docs` reference build is produced by three
  independent paths: `gen:reference` (docs pkg `:13`), `build:ci` (`:23`), and `check:drift`'s
  scratch regen. No cache is shared between any of them.
- **Proposed mechanism:** content-hash cache keyed on (generator input SHA + config SHA), exactly
  the shape Track A already shipped in `tools/lib/build-site-cache.mjs`. A drift check that hashes
  its inputs can skip the scratch regen when inputs are unchanged, and the reference build can be
  memoized across the three consumers.

### 2.2 — `elm-cem` codegen re-run against the identical elm-m3e config
- **What:** the elm-cem generator (against elm-m3e's `--flags-from/--config-from` set — the shared
  argv in `regen.mjs:26-31`) is invoked independently by: elm-m3e `gen:src`, `check:cem`
  (`elm-cem gate`), `check:families` (`elm-cem regen-drift`), the docs
  `examples-gen/lib/facts.mjs` (`facts.mjs:51`, memoized *per-process only*), and gate-all's
  `factsBundleE2E` (`gate-all.mjs:254`).
- **Cost:** each run is the full codegen app (~0.75–2s per the E2E notes).
- **Multiplicity:** within a single `elm-m3e: check` fan-out (`run-p check:*`), `check:cem` and
  `check:families` each independently re-run the generator over the same config in separate
  processes. This is *outside* gate-all's own loop (it's inside one package's check), so it's in
  scope here — but it overlaps the same "no shared bundle cache keyed on (generator SHA + config
  SHA)" root cause Track A is addressing for gate-all. **Recommend:** a shared, content-hashed
  bundle cache would collapse all of these; note the overlap and coordinate with Track A's Phase 4
  rather than building a second mechanism.

### 2.3 — `build:site` (`elm-pages build`, ~28s) uncached on 2 of 3 consumers
- **What:** Track A's `build-site-cached.mjs` (content-hash wrapper around `elm-pages build`) is
  wired **only** into the Playwright `webServer` (`playwright.config.ts:101`). The two other
  `build:site` consumers — elm-m3e `build` and docs `build:ci` — call `build:site` directly
  (`elm-pages build && … build-search-index.mjs`), uncached.
- **Proposed mechanism:** route those two through `build-site-cached.mjs` too. *Overlaps Track A's
  build-site cache — coordinate (§4).*

### 2.4 — vendor trees re-copied every `gen`, then again by `check:vendor` (cheap, but strictly redundant)
- `gen:vendor` (`vendor-foundation.mjs` + `vendor-tailwind-m3e-web.mjs`) rewrites the git-tracked
  `docs/vendor/**` on every run; `check-vendor-drift.mjs` re-copies into a scratch dir to diff.
  Local `cpSync`, low cost — flag only; a hash-compare would skip the copy when unchanged.

### 2.5 — Chromium pipeline duplicated across cem-figma-connect render scripts (low priority — scripts are manual)
- `render-batch.mjs:44` and `render-example.mjs:57` each `chromium.launch({headless:true})` and
  re-declare `capture.mjs`'s `CONTEXT_OPTIONS`/`SCREENSHOT_OPTIONS` verbatim (render-example's own
  comment: "Identical to capture.mjs's CONTEXT_OPTIONS") instead of importing
  `createRenderer`/`renderOne`. Same rendered-PNG output via 3 independent browser pipelines. Since
  both render scripts are manual/dead (§1), fold this in *if* they're un-deaded; else delete them.

**Negative confirmation (worth recording):** the `m3e-api-okf` `gen:*` chain
(`extract→guidance→examples→skill→okf`) is **not** redundant — it's a proper DAG. Only
`extract.mjs` reads the facts bundle (`data/cem-facts.json:40`); `build-examples`/`build-skill`/
`check-skill` read the *derived* `data/components.json`; `guidance.mjs` never touches cem-facts. The
bundle is parsed exactly once. No action.

---

# 3. Near-duplicate script consolidation candidates (the surviving tail)

The 2026-08-17 Theme 3 pass consolidated most duplication. These survived it:

| Family | Copies | Overlap (verified) | Recommendation |
|---|---|---|---|
| `stage-facts-elm-home.mjs` | 2 (`core/elm-cem-compose/bin/`, `core/elm-review-cem/bin/`) | **168 of 170 lines identical** — only diff is one comment word on line 3. The elm-cem-compose copy is **DEAD** (no caller, §1). | Delete the elm-cem-compose copy; extract the live one to `tools/lib/stage-facts-elm-home.mjs` (arch-review candidate 8 also notes the ELM_HOME/resolver duplication). |
| `skills/check-skills.mjs` | 3 (`core/elm-cem/`, `core/elm-review-cem/`, `brands/…/elm-m3e/`) | `elm-cem` & `elm-m3e` copies **byte-identical (5237 B)**; `elm-review-cem` is a **larger fork (6361 B)** that added a gerund-name check, a block-scalar YAML parser, and a `when/trigger` requirement the others lack. | Classic "2 identical + 1 drifted-ahead fork". Promote the richer elm-review-cem version to `tools/lib/check-skills.mjs`; all three call it. (All three are orphaned-targets — §1a — so fix invocation at the same time.) |
| `fix-native-bins.mjs` | 2 (`elm-m3e/docs/scripts/`, `elm-m3e/scripts/`) | **~90% identical**; docs version additionally symlinks `lamdera` + an extra comment. Both run as `postinstall`. | Extract shared body to `tools/lib/`, parameterize the bin list. Low urgency (each fixes its own `node_modules`). |
| `regen.sh` / `regen-diff-gate.sh` (elm-typed-html) | 2 | The 4-line codegen block (`node "$ELM_CEM_BIN" --flags-from …native.cem.json --config-from …config.json --output=… && "$ELM_FORMAT" … --yes`) is **copy-pasted verbatim**; regen writes to `src/`, the gate writes to a temp dir and diffs. | Intentional (writer vs verifier), but the generator invocation could be a sourced shell fragment. Minor; note only. |

**Confirmed already-resolved (do not re-open):**
- The 3 consumer `gen-facts.mjs` (`cem-figma-connect`, `m3e-api-okf`, `tailwind-m3e-web`) are now
  thin (27–48 line) wrappers over `tools/lib/gen-facts-runner.mjs` — verified real, no residual
  duplication (cem-figma-connect's extra 20 lines are its legitimate icon-names derivation).
- The 7 `hooks/pre-push` are generated by `tools/gen-hooks.mjs` from one
  `tools/hooks/pre-push-base.sh` + one elm-m3e extra, drift-gated by `gen-hooks.mjs --check` in
  gate-all. Resolved.
- `neutrality-check.sh` (elm-cem vs elm-review-cem) and `calibrate-tones.mjs` are **not**
  duplicates — the two neutrality scripts are substantively different implementations (74 vs 127
  lines, whole-file vs line-level allowlists), and calibrate-tones exists in only one place. No
  action (beyond the broken `generate:tones` entry in §1/#2).

---

# 4. Overlaps Track A / arch-review — deferred (do NOT re-solve here)

Recorded explicitly so nothing in §1–§3 silently conflicts with in-flight or already-owned work.

| Item | Owner | Status / note |
|---|---|---|
| gate-all's own internal facts-bundle regen ("7+ times/run") | **Track A** Phase 4 (`docs/superpowers/plans/2026-08-18-gate-all-parallelization-plan.md`, A5) | Merged: `regen.mjs`'s `generateBundleToTemp` is memoized **per-process** (`regen.mjs:80-124`), which collapses `check-drift.mjs`'s 4 internal calls to 1. **But** each gate-all step runs as a *separate spawned process* (via `gate-scheduler.mjs`), so the regen still happens once per process — E2E proof, `check-drift`, `ab-elm-cem.sh`, `ab-elm-m3e-split.sh` each regenerate independently. Whether cross-process sharing is in Track A's remaining scope is Track A's call — **deferred, do not build a competing cache.** |
| `build-site-cache.mjs` content-hash cache + wiring | **Track A** Phase 2 | Cache exists and is wired to the Playwright webServer only; §2.3 (wire the other 2 `build:site` consumers) is a natural extension — **coordinate with Track A, don't fork.** |
| Per-step timing / `CHRONIC_SKIPS`→data | **Track A** / arch-review candidate 2 & 4 | Scheduler landed; timing instrumentation + moving skip lists to data are arch-review candidate 2/4. Not this audit's scope. |
| `family.json` read 5× (own `JSON.parse` each) + `bump.mjs` `CONSUMERS` 4th consumer copy + 4 package-discovery walkers | **arch-review candidate 1** | This audit confirms `bump.mjs:39-55`'s `CONSUMERS` is the hardcoded 4th list. Defer to candidate 1's `tools/lib/family.mjs` resolver. |
| skip-policy duplicated across `snapshot-gate.sh` (bash) + `copy-fidelity.mjs`'s `requireSourceOrSkip` (JS) | **arch-review candidate 4** | Same policy, two languages. Defer. |
| token tier classifier ×3 · prop-shape taxonomy ×3 · `bin/shared.js` resolver ×4 · elm-review-cem internals ×10 | **arch-review candidates 6/7/8/9** | Structural dedup already scoped. Defer. |
| `tasks.mjs` blind (walks `packages/` only) · CI `working-directory: packages/elm-m3e/docs` stale | **arch-review defects L2 / L1** | Confirmed live. Defer to candidate 1 / the L-defect fixes. |

---

# Appendix — disposition summary

- **~155 scripts assessed.** The overwhelming majority are **live and correctly wired** — this
  workspace's tooling hygiene is genuinely good, consistent with both prior reviews' "control group"
  observations.
- **Genuinely dead (delete):** 3 — `a11y-icon-button-labels.mjs`, `fetch-mdn-native-summaries.mjs`,
  `elm-cem-compose/bin/stage-facts-elm-home.mjs`.
- **Broken/orphaned wiring (fix or delete):** 2 — `tailwind-m3e-web` `generate:tones` (broken),
  `tools/gen-figma-config.mjs` (orphaned generator, unconsumed output).
- **Orphaned drift-gates (wire in — gate-coverage holes):** 4 gates — `check:compose-attrs`,
  `check:roundtrip`, `verify:split`, `check-skills` trio.
- **Manual-only (keep, no action):** `preflight-bar.sh`, `publish-mirror.mjs`, `fetch-snapshots.mjs`,
  `render-batch`/`render-example`/`review/server`, `friction-*`, `install`, `okf-update`,
  `render-verify` (borderline promote), IR `bench`.
- **Redundant-computation findings:** 5 (§2), headed by docs `check:drift` recompute (§2.1); 1
  overlaps Track A (§2.3), 1 overlaps Track A's facts cache (§2.2).
- **Surviving near-duplicates:** 4 families (§3); 3 previously-flagged families confirmed resolved.

Every claim above carries a file:line citation or a cited negative grep. No file was modified.
