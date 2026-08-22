# DAG rework — Task 8 (bundle re-baseline) + Task 9 (html hand-off) + Task 10 (final gate) CLOSEOUT

Companion to `docs/plans/2026-08-21-dag-rework-plan.md`. This closes the plan.
Every figure below is machine-captured evidence from this run, not a citation of
an earlier task's report.

Branch `docs/dag-rework-plan`, worktree HEAD before this doc = `e74c932f`.
Identity guard: `git config user.name`/`user.email` = `JackHP95` /
`git@jackhpeterson.com` (asserted before both Task-8 and Task-9 commits).

## Task 8 — Face-A generator bundle re-baseline

**Why.** The pinned `tools/snapshots/elm-cem-generator.bundle` (contained-commit
sha `c054df46`, the reconciliation-Task-8 baseline pinned at reconciliation
commit `3e77975e`) predated this branch's DAG-rework emitter change. The pristine
tree still emitted the OLD per-element `M3e/Build/*.elm` + `M3e/Build.elm` barrel,
so Face A (`ab-elm-cem`) failed with `Only in out-pristine/M3e: Build` — the
reserved red the Task 5-6 milestone flagged for Task 8.

**What moved (the emitter delta the bundle now captures), diffed OLD bundle tree
vs NEW bundle tree:**

- NEW `codegen/Generate/Phantom/Emit/BuildPackage.elm` (config-driven family
  builder emitter — one composed `M3e.Build.<Family>` per `_families` entry, plus
  degenerate single-member families for standalone elements, importing
  `M3e.Component.<Family>`).
- CHANGED `codegen/Generate/Phantom/Emit.elm` (drop per-element `compBuildModule`
  from the concatMap; wire `BuildPackage.files brand families`).
- CHANGED `codegen/Generate/Phantom/Emit/FamilyPackage.elm`.
- CHANGED `bin/{acid.js,registry-check.js,validate.js}` (stage split siblings for
  the gate probes).

**Branch-scope guard (critical).** The bundle carries ONLY what is an ancestor of
this HEAD (`45f28d31`). It does NOT include the sibling
`docs/families-a11y-composition-plan` branch's `shared:interactive` field split
(`718d44d1`) or `!@set/!kind` admits primitive (`7721dd6c`) — both verified NOT
ancestors of HEAD (`git merge-base --is-ancestor` → false for each), and the live
generator's atom vocab is still `shared:phrasing` (not `shared:interactive`),
confirming the field split is absent.

**Mechanics.** Fresh `git archive HEAD:pipeline/elm-cem` → temp git repo →
single subtree-snapshot commit (sha `0d25913d`) → `git bundle create --all`.
`export-ignore` exclusions (tests/, node_modules, .github, dotfiles) match the
prior bundle exactly. Re-pinned in `tools/snapshot-refs.json`
(`c054df46 -> 0d25913d`) with the D-046 standing note appended.

**Proof after re-baseline:**

- `ab-elm-cem` (Face A byte-identity): **A/B PASS — 272 files, byte-identical**.
- `ab-elm-m3e-split` (split-step byte-identity): **A/B PASS — 284 files,
  byte-identical**.
- All-brand regen-diff, byte-identical to a clean regen:
  - `svg`: `regen-diff gate: OK — src/ is byte-identical to a clean regen`
    (EXEMPT — unchanged, pure no-op).
  - `html`: `regen-diff gate: OK — src/ is byte-identical to a clean regen`
    (EXEMPT — unchanged, pure no-op).
  - `shoelace`: `regen-diff gate: OK — src/ is byte-identical to a clean regen`.
  - `m3e`: covered by `ab-elm-m3e-split` byte-identity above.
- **Phantom re-bless:** the goldens were already re-blessed inline during Tasks
  1-3 (e.g. `Or/Build/Plain.elm` imports `Or.Component.Plain as Component`, not
  `Or.Element.*`). `node tests/phantom/bless.mjs` this run = **`blessed 0 file(s)`
  — 0 added, 0 removed** (idempotent no-op), and `test:phantom` = **ALL GREEN**.
  Task 8's phantom re-bless therefore carries no residual churn.

Commit: `96916b29` (only `tools/snapshot-refs.json` +
`tools/snapshots/elm-cem-generator.bundle` — no generated output touched).

## Task 9 — html 5-tier follow-up hand-off (doc-only)

Recorded as § Follow-ups / **FU-1** in the plan doc: html's 5-tier target is now
UNBLOCKED (the `BuildPackage.elm` emitter is brand-agnostic; shoelace already
rides it) but html has no Build tier and no `_families` config today (verified:
only `elm-typed-html{,-core,-elements,-facts}`, no `TypedHtml.Build.*` tree), so
standing up its Components + Builders tiers is a genuine design task deferred to
its own plan (OQ-5 resolution). svg is separately exempt. Task 9 checkbox marked
done. Commit: `e74c932f`.

## Task 10 — final gate + P1-P5 re-assertion

### Final `GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs`

**Result: 61/63 passed, 1 skipped, 1 failed.** (vs the pre-Task-8 baseline this
run measured: 60/63 passed, 3 failed.) The two Task-8 reds (`ab-elm-cem`,
`check-drift`'s Face-A sub-check) are now GREEN.

- **1 SKIP** — `check-drift (M4.b cross-cutting drift gate)`: now a CHRONIC SKIP
  for an unrelated reason (its m3e-okf consumer-output sub-check needs a full
  npm-built `matraic/m3e@v2.7.3` `.cache/m3e`, a heavier third-party dependency).
  Its Face-A sub-check — the thing that was RED at Task 6 — now passes after the
  bundle re-baseline; the skip is the okf provisioning gap, not DAG drift.
- **1 FAIL** — `copy-fidelity elm-m3e`: **out of this plan's scope (publish).**
  Root cause verified this run: `source tracked=547 workspace tracked+addable=394`
  — the published mirror (`jackhp95/elm-m3e`) still carries the OLD per-element
  `src/M3e/Build/*.elm` (130 modules) + `src/M3e/Build.elm` barrel that the
  workspace no longer emits (`MISSING — git-tracked in source, absent from
  workspace copy: src/M3e/Build.elm, src/M3e/Build/Accordion.elm, …`). The
  standalone `jackhp95/*` repos are read-only published mirrors; re-publishing the
  mirror to absorb the composed-Build rename is a separate publish step, exactly
  as reserved by the Task 5-6 report.

Every other gate — including the Task-5 `check-package-dag` DAG gate,
`check-m3e-5pkg`, all `elm-m3e-*` and `elm-shoelace-*` and `elm-typed-{html,svg}`
package checks, and all four `copy-fidelity` gates for the non-m3e targets —
PASSES.

### P1-P5 re-assertion (each re-verified fresh against the live tree)

| claim (as stated in the plan's "before" snapshot) | status now | fresh evidence this run |
|---|---|---|
| **P1** Builders consume Elements, not Components | **FALSE (fixed)** | `elm-m3e-build/src/M3e/Build/` — **0** modules import `M3e.Element.*`, **131** import `M3e.Component.*`; `Build/Accordion.elm:19` = `import M3e.Component.Accordion as Component` |
| **P2** parallel siblings: build & components both hang off elements, neither chains the other | **FALSE (fixed)** | Builders now chain THROUGH Components (P1); Components import `M3e.Build.*` **0** times (no back-edge / cycle) |
| **P3** parallelism baked into the package DAG | **FALSE (fixed)** | `elm-m3e-build/elm.json` deps = `{core, components}` (DROPPED `elements`, ADDED `components`); `elm-m3e-components/elm.json` deps = `{core, elements}`, does NOT list `build` (no cycle). Linear `build → components → elements → core`. |
| **P4** Builders CEM-emitted per-element | **FALSE (fixed)** | `Emit.elm`: `compBuildModule` removed from the per-element concatMap (only removal-comments remain); `Emit.elm:158` = `Generate.Phantom.Emit.BuildPackage.files brand families` (config-driven pass). The +1 composed `M3e.Build.Progress` family (no 1:1 element) proves config-derivation. |
| **P5** Components re-export only the type-level surface (constrains "Builders consume Components") | **FALSE (constraint satisfied)** | `check-package-dag` gate: **132 `M3e.Build.*` modules, 0 import `M3e.Element.*` (all route through `M3e.Component.*`)** for m3e; **59 `Sl.Build.*`, 0 import `Sl.Element.*`** for shoelace. Shape A's type-only Component import is sufficient — every builder compiles against the Component façade. |

Holistic proof: `node tools/check-package-dag.mjs` → `OK — Build consumes
Components (no Elements dep, no Components→Build cycle) and no Build module imports
Elements directly. Linear DAG intact.` (exit 0).

## Verdict

The linear `IR → Core → Elements → Components → Builders` DAG is materialized,
gate-enforced, Face-A re-baselined, and P1-P5 re-verified FALSE. The one remaining
gate red (`copy-fidelity elm-m3e`) is a published-mirror re-publish delta, out of
this plan's scope. **DAG rework plan complete.**
