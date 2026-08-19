# Remediation — tools/scripts caching + dead-code audit (2026-08-19)

**Source audit:** `docs/reviews/2026-08-19-tools-scripts-caching-audit.md`
**Worktree:** `/Users/jack/.paseo/worktrees/3ov4grvm/fix-tools-scripts-caching` · branch `fix/tools-scripts-caching`
**Manager:** this session (gauntlet, inline executor). Status legend: `queued → dispatched → in-verify → done | deferred | reclassified`.

## Goal + acceptance

Apply the actionable fixes (audit §1–§3), each verified against **captured** command output from
this clean worktree. Explicitly DO NOT touch §4 deferrals (Track A: gate-all-internal facts regen,
build-site cache wiring; arch-review candidates 1/4/6/7/8/9; defects L1/L2). Recompose-gate: the
packages I touch must pass their own `check`/`test` from a clean tree.

## Hard constraints (checked before every leaf)

- **Mirror independence** (`github.com/jackhp95/<name>` are read-only published mirrors): per-package
  scripts a mirror's own CI runs (`skills/check-skills.mjs`, `bin/*`, `docs/scripts/*`) **cannot** be
  centralized into `tools/lib/` — the mirror has no `tools/`. Dedupe-in-place, don't centralize.
  This overrides the audit's "extract to tools/lib" phrasing wherever the script ships in a mirror.
- Don't wire an orphaned gate into gate-all **until** it's confirmed GREEN on the current tree —
  wiring a red gate turns the whole gate red on a pre-existing drift nobody's been catching.
- Deletion is real: re-verify each "dead" script's deadness first-hand before removing; a script
  that regenerates a **live committed config** is a manual tool, not dead code (keep it).

## Task table

| # | Leaf | Kind | Final status | Evidence |
|---|---|---|---|---|
| L1 | Fix broken `tailwind-m3e-web` `generate:tones` (nonexistent `bin/calibrate-tones.mjs`) | mechanical | **SHIPPED** | `pnpm --filter tailwind-m3e-web run generate` → exit 0 (generate:utilities only); tailwind `check`+`test` (28 passed) green |
| L2 | `a11y-icon-button-labels.mjs` | delete→**RECLASSIFIED (keep)** | not dead | ongoing a11y maintenance codemod over a *growing* example corpus (edits `config/examples.rich.json` + `docs/data/examples.json` in lock-step, idempotent). Deleting = future icon-button examples ship unlabelled (the exact bug it fixed). Keep; optionally promote to a real check. |
| L3 | `core/elm-cem-compose/bin/stage-facts-elm-home.mjs` | delete→**RECLASSIFIED (keep)** | not dead | elm-cem-compose is independently mirror-published (`publish-mirror-state.json:34`) and its `elm.json` depends on `jackhp95/elm-cem-facts` (+ `src/Cem/Compose.elm` imports `Cem.Facts`). This is the standalone-mirror ELM_HOME facts-staging mechanism — dead only in-monorepo (shared warm ELM_HOME). Real gap = it's *unwired* (compose's `test:elm` should self-stage). Recommend wiring, not deleting. |
| L4 | Unify `check-skills.mjs` trio → richer elm-review-cem version (keep per-package, mirror rule) | dedupe | **SHIPPED** | proved the stricter linter passes on all 3 dirs first (elm-cem 2, elm-review-cem 3, elm-m3e 8 skills, all exit 0); after unify all 3 md5 `ad2a504…`, all exit 0 |
| L5 | Probe the orphaned drift-gates for green/cost/side-effects | investigate | **done** | verify:split green (~20-30s, writes ELM_HOME); check:compose-attrs green (fast, pure `--check`); check:roundtrip green but **mutates tracked `roundtrip-report.json`** |
| L6 | Wire the safe orphaned gate(s) | wire | **SHIPPED (compose-attrs)** | added `elm-m3e` `check:compose-attrs` proxy → picked up by `run-p check:*`; verified exit 0. verify:split + check:roundtrip **deferred** (see decisions) |
| L7 | `gen-figma-config.mjs` orphaned generator | design | **DEFERRED** | genuine unfinished WIP ("NOT wired into GEN_CONFIG_ARGS yet") — wiring needs a product call (should elm-cem consume Figma docMeta?); deleting destroys WIP + a fidelity-tracked artifact. Jack's decision. |
| L8 | `fetch-mdn-native-summaries.mjs` | delete→**RECLASSIFIED (keep)** | not dead | regenerates `config/native-mdn.json` — a **live consumed config** (`gen:src`/`check:cem`/`check:families`, `regen.mjs:29`). Manual regenerator like `fetch-snapshots`/`publish-mirror`; deleting loses reproducibility of a committed input. |
| L9 | `fix-native-bins.mjs` ×2 dedup | dedupe | **DEFERRED** | ~90% identical but each fixes its own package's `node_modules` (`m3e-builder-docs` vs `elm-m3e`), both run as `postinstall`, both ship in the same mirror. `tools/lib` extraction breaks mirror self-sufficiency; low value. Leave. |
| L10 | docs `check:drift` recompute caching (audit §2.1) | design | **DEFERRED** | real feature; overlaps Track A's `build-site-cache.mjs` content-hash infra + touches the perf-critical path. Build on Track A's primitive, not a second mechanism. |
| L11 | Recompose sanity from clean toolchained tree | verify | **done** | tailwind check+test green (28 passed); tree shows only the 4 intended edits + docs |
| L12 | Record remediation + corrections; commit | manage | in-progress | this doc + audit-doc remediation section |

## Decisions log (execution)

**Provisioning:** fresh worktree had no `node_modules`/elm toolchains; ran `pnpm install --frozen-lockfile`
(exit 0, ~6s warm store) to enable real green-verification of gates before wiring any.

**The "delete 3 dead scripts" recommendation was over-aggressive — execution corrected it.** On
first-hand inspection all three are legitimately-unwired **manual/maintenance tools**, not dead code:
`fetch-mdn` regenerates a live consumed config; `elm-cem-compose` stage-facts is standalone-mirror
staging scaffolding; `a11y-icon-button-labels` is an ongoing corpus a11y codemod. Deleting any of the
first two is a reproducibility/mirror regression. This is the receiving-code-review discipline working:
the audit was a recommendation; verification before implementation caught the nuance. **Zero deletions.**

**Orphaned-gate wiring — only the side-effect-free one shipped.** Each gate was RUN before any wiring:
- `check:compose-attrs` — pure `--check`, no ELM_HOME, no tree mutation, green → **wired** into elm-m3e `check`.
- `verify:split` — green, but registry-check stages into shared ELM_HOME; adding it to `run-p check:*`
  puts a 3rd concurrent ELM_HOME writer alongside `check:cem`/`check:families` → concurrency-hazard
  territory Track A's ELM_HOME-isolation work owns. **Deferred**; recommend a properly-tagged gate-all
  scheduler step under Track A rather than run-p.
- `check:roundtrip` (Layer 1) — green, but writes tracked `docs/data/roundtrip-report.json` on every run
  → wiring dirties the tree each gate (same class as the docs/dist churn arch-review candidate 3 flags).
  **Deferred** until it writes to a temp/ignored path.

**check-skills unify is safe + kept per-package** (mirror rule: a mirror has no `tools/`, so centralizing
to `tools/lib` breaks its self-contained CI — dedupe-in-place instead). Gate-all wiring of the (still-
orphaned) skills lint deferred as a separate, bigger decision.
