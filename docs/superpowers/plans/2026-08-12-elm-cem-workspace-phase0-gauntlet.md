# elm-cem-workspace — Phase 0 Sustainability Spine — Gauntlet Orchestration Plan

> **For the manager:** This plan is executed by a **Paseo "manager" agent** (Opus, `planning`/`audit`
> tier) running the **Gauntlet Loop** — NOT superpowers subagent-driven-development. The manager
> decomposes each milestone into independently-judgeable parts, dispatches a **builder** per part into
> an isolated worktree workspace, gates each part against a **concrete reference bar** via a fresh
> **critic**, loops failed parts with a changed strategy, and escalates only per the Human-Gate Policy.
> Tasks are written at **part + reference-bar** granularity on purpose: the builder owns the micro-steps;
> the reference bar decides "done."
>
> **Source spec:** `docs/superpowers/specs/2026-08-12-m3e-family-spine-design.md`. The manager MUST read
> it before Milestone 0. This plan implements it; where they disagree, the spec wins and the manager
> escalates the conflict.

**Goal:** Consolidate the **elm-cem codegen family** — the CEM→artifacts producer (`elm-cem` + its
substrate) plus its brands (flagship: `elm-m3e`) and output tools (Figma Code Connect, Tailwind, OKF/skill)
— into one `elm-cem-workspace` where the single producer (`elm-cem`) emits a canonical facts bundle that
every consumer reads, so a library version change is one gated `bump` command instead of eight
hand-maintained steps.

**Architecture:** A pnpm-workspace + Elm-source monorepo. elm-cem reads the CEM once and emits a
three-face facts bundle (Elm source, `cem-facts.json`, `elm-api-facts.json`); m3e-okf, tailwind-m3e-web,
and cem-figma-connect stop parsing and consume the bundle via workspace deps. Executed as a Gauntlet Loop
on Paseo: mechanical builders (Sonnet/Haiku) against deterministic reference bars, adversarial Opus
critics, human only on product/irreversible calls.

**Tech Stack:** pnpm workspaces (JS graph), Elm + `elm.json` (Elm registry graph), `elm-codegen`
(elm-cem), Node scripts, Paseo (`create_workspace`, `create_agent`, `paseo loop run`).

## Global Constraints

Every part's requirements implicitly include this section. The manager injects the relevant lines into
every builder and critic brief.

- **Model resolution — never hardcode a provider.** Resolve every role through
  `~/.paseo/orchestration-preferences.json` (categories `impl`/`ui`/`research`/`planning`/`audit`), read
  fresh at manager startup. **This effort's overrides:** builder = **Sonnet** (`impl`) for substantive
  mechanical work; **Haiku permitted for low-risk, fully-specified parts** (mass find/replace, wiring an
  import, moving files, writing tests) — but see the Haiku guardrail below. Critic + integrator + product
  decisions = **Opus** (`audit`/`planning`). `opencode`/local = only mechanical + integrity-gated work.
  Providers available on this machine: claude (opus/sonnet/haiku), opencode (local Ollama), pi. codex /
  copilot / omp are NOT available — mapping to them fails.
- **Haiku guardrail.** A weaker builder's cheapest way to green a gate is to *cheat* it. Haiku parts get:
  (1) the integrity gate below run BEFORE the functional gate counts; (2) escalation to Sonnet after **2**
  failed rounds with no new strategy (do not burn more rounds on Haiku); (3) no schema/emitter/config
  design work — those are Sonnet with Opus on the design call.
- **Generated code is the specification.** NEVER hand-edit an emitted or golden file to make a gate pass.
  Change the config or the emitter and regenerate. A builder that edits emitted output fails its part
  regardless of gate color.
- **A/B generation is the emitter reference bar.** Prove an emitter/producer change is a no-op for
  unaffected output by **A/B generation** — run the pristine generator and the modified generator against
  the *same* config and diff the output trees — NOT regenerate-and-diff, because several repos carry
  pre-existing staleness that masks the real answer.
- **Integrity gate.** Before any functional gate counts for a part, verify the builder deleted or
  hand-edited nothing outside what its brief explicitly authorized (`git diff --stat` vs the brief's
  declared file set; flag any emitted-file edit or unlisted deletion). This is the deletion-detector the
  local-model incident earned.
- **Determinism is the test.** Reference bars are deterministic gates. A part is "done" only when its gate
  is green AND the critic confirms the change landed in config/producer, not in emitted output.
- **Direct-to-main, ask before branching.** These repos commit directly to `main` with no feature
  branches. Worktree isolation for parallel parts is allowed, but **creating any branch is a human-gated
  act** (Human-Gate Policy). Sequential work on the monorepo `main` is the default.
- **Coverage audit gates the migration.** No consumer may delete its own CEM parser until the facts-bundle
  coverage audit (Milestone 1) proves the bundle carries every field that consumer reads today.

## Package structure & identity (peer input, 2026-08-12)

This workspace is **elm-cem-centered**, not m3e-centered: `elm-cem` (the CEM→Elm codegen engine) is the
producer the whole spine turns on; `elm-m3e` is the flagship **brand/config** fed to it, `gren-m3e` and
future brands are peers, and the Figma/Tailwind/OKF tools are **output modalities**. The workspace is
therefore **brand- and output-pluggable** — new brands and outputs drop into a structure organized around
the general pipeline (CEM + config + docs + Figma → Elm packages + Figma Code Connect + Tailwind + skills),
not around any one brand.

A liaison agent deep in the repos left a structure recommendation + a live blocker on `origin/main`
(`elm-m3e/plans/2026-08-12-{repo-structure-recommendation,split-fix-design,publish-readiness,publish-runbook}.md`).
One point binds THIS plan; the rest is the **Phase-5 publish blueprint**, not Phase 0:

- **The published Elm package boundaries are Phase 5 — and the `core`/`components`/`builder` split is
  RETAINED, not collapsed.** The split exists for Elm's **package size limit** (the combined surface doesn't
  ship as one package), so it stays. (The liaison read it as a leaky `M3e.Forge.Internal` seam and thought a
  monolith was "registry-faithful today"; that conflicts with the size rationale and is a **Phase-5
  verify-then-decide** item — reconcile the size ceiling against the liaison's claim before touching
  boundaries. Phase 0 does NOT collapse anything; it co-locates the packages exactly as they are.)
- **Exactly one `Cem.Facts`** (the live blocker — the one thing that binds Phase 0). Both `elm-cem-facts` and
  `elm-review-cem` expose a module named `Cem.Facts`; a consumer's `review/` config needing the rules AND the
  generated facts pulls both → Elm module-name clash, won't compile (+ `Fact`-type-identity mismatch).
  **M1.d** consolidates to one source (`elm-cem-facts`); the publish-time vendor-vs-depend flavor is a
  Phase-5 call.

## Human-Gate Policy (decided: "Product & irreversible only")

The manager runs ALL mechanical, reversible work autonomously and leans on **git revert as the safety net**
rather than upfront human gates — these repos have clear inputs/outputs, and a bad change is cheap to undo.
It PAUSES for the human ONLY for:

1. **Truly irreversible acts:** any `git push`, any registry `publish` (neither occurs in Phase 0), and
   **branch creation** (per your prefs' ask-before-branching — though the default is sequential work on the
   monorepo `main`, so branching normally never comes up; see the Gauntlet Contract).
2. **Stuck loops:** a part that fails its reference bar across the full escalation ladder
   (builder-resume → stronger model) without a new strategy.

There are **no product/architecture human checkpoints in Phase 0** — it is pure internal infrastructure with
no product surface. The two decisions that looked like checkpoints (the facts-bundle schema and the
Elm-in-JS convention) are *derived and verifiable*, not free product choices: the schema falls out of the
Milestone 1 coverage audit (an adversarial Opus critic is the gate), and the Elm-in-JS convention is a
standard technical call an Opus builder makes and a critic verifies. The manager **decides both
autonomously and records the decision in the ledger** so you can review — and revert — without it being a
blocking gate. The genuine product questions live in Phases 1–3, not here.

Everything else — creating the new empty monorepo, moving files, wiring workspace deps, regenerating,
running gauntlet loops, deleting intra-monorepo dead code the plan authorizes — is autonomous.

## The Gauntlet Contract (how the manager runs every part)

1. **Decompose.** The six milestones below are the coarse, dependency-ordered decomposition (a mostly
   *sequential spine*; only Milestone 3's three consumer migrations are independent and parallelizable).
   Within a milestone, the manager (lead) chooses the fine-grained parts — the smallest units that can be
   built and judged independently. Do NOT fan out coupled work just because agents are free.
2. **Build.** Per part: `create_workspace` (worktree isolation) + a self-contained builder brief (zero
   context: task, files, the exact reference-bar command, the Global Constraints lines that apply,
   acceptance criteria). Builder model per policy.
3. **Judge.** The reference bar is the exact deterministic gate. Run the part as a
   `paseo loop run`: `--verify-check "<gate command>"` (deterministic) + `--verify "<critic brief>"`
   (fresh Opus critic, cross-provider from the builder, inspects the REAL diff/output, not a summary,
   confirms integrity + that changes landed in config/producer + coherence), `--max-iterations` bounded,
   `--archive` on. The critic never suggests fixes and never edits; it verdicts against the bar.
4. **Loop.** On failure, feed the largest concrete gap back with a *changed strategy*. Escalation ladder:
   Haiku→Sonnet after 2 failures; Sonnet→Opus after a further 2; then **human** (stuck). Same failure with
   no new strategy = stop, do not repeat.
5. **Integrate.** After a milestone's parts land, a fresh **Opus integrator** runs the milestone's whole
   gate together and smooths seams without redesigning.
6. **Ledger.** The manager appends a deterministic progress line per part to
   `elm-cem-workspace/GAUNTLET-LEDGER.md` so state survives context resets and the human can watch:
   - `M<n>.<part>: pass (gate <cmd> green, critic clean, builder <model>)`
   - `M<n>.<part>: round <r> (gate red: <one-liner>; strategy: <one-liner>; builder <model>)`
   - `M<n>.<part>: escalated <from>→<to> (<reason>)`
   - `M<n>.<part>: BLOCKED — <one-liner> — [HUMAN]`
   - `M<n>: integrated (whole-milestone gate green)`
   A part is DONE iff it has a `pass` line. A milestone is DONE iff it has an `integrated` line.

## Manager Bootstrap (first actions, before Milestone 0)

- [ ] Read the source spec (above) and this whole plan.
- [ ] Read `~/.paseo/orchestration-preferences.json`; resolve builder/critic/integrator providers; note the
      Haiku override for this effort.
- [ ] Confirm the Paseo daemon is reachable (`paseo daemon status`); do NOT restart it.
- [ ] Create `elm-cem-workspace/GAUNTLET-LEDGER.md` with the milestone checklist.
- [ ] Snapshot the five source repos' current gate states (record each repo's `check`/`gate` result NOW),
      so "identical to pre-migration" reference bars have a baseline. Record baselines in the ledger.

---

## Milestone 0 — Workspace shell

**Objective:** A new empty `elm-cem-workspace` that installs cleanly and can host both the JS (pnpm) and Elm
(`elm.json`) graphs. Nothing migrated yet.

**Parts (coarse):**
- **0.a** Create the monorepo skeleton: `pnpm-workspace.yaml`, root `package.json`, the top-level task
  runner (the thing `bump` will later drive), and the directory layout for JS packages + Elm source. Flat
  copy is fine (all prerelease, history-loss accepted).
- **0.b** Establish the **Elm-in-JS coexistence convention** — how the Elm packages resolve locally during
  dev (source-directories / local paths) vs. how they'd publish to the Elm registry. The manager (Opus)
  decides a concrete convention from spec §6 and **records it in the ledger**; the critic verifies it does
  not box in future Elm-registry publishing (Phase 5). No human block — revert if the recorded convention
  looks wrong.

**Reference bar:** `pnpm install` at the root exits 0; the task runner enumerates every (future) package
script; a trivial Elm module under the chosen layout resolves/compiles. Integrity gate: only the declared
skeleton files created.

**Builder:** Sonnet (0.a mechanical; 0.b proposal). **Critic:** Opus (confirm the convention is coherent
and doesn't box in future Elm registry publishing).

**Escalation:** none blocking — the 0.b convention is recorded in the ledger for review, not gated.

---

## Milestone 1 — elm-cem in + the facts bundle + the coverage audit (the linchpin)

**Objective:** elm-cem lives in the monorepo and emits the canonical facts bundle (Faces B + C); an audit
proves the bundle can replace every consumer's parser.

**Parts:**
- **1.a** Move `elm-cem` (+ its siblings `elm-cem-facts`, `elm-typed-html`) into the workspace (flat copy).
  **Reference bar (A/B):** run pristine elm-cem (pre-move) and workspace elm-cem against elm-m3e's exact
  config; diff the generated trees → **empty**. Builder: Sonnet. Critic: Opus.
- **1.b** **Coverage audit** — enumerate every field each consumer reads from the CEM today
  (m3e-okf `extract.mjs` incl. README-drift provenance; tailwind `generate-component-utilities.mjs`
  cssProperties; cem-figma-connect `cem.mjs`/`dts-inline.mjs` incl. `.d.ts`-resolved enum unions; the Elm
  emitter's Face-C needs: module/entry/per-surface `form`/`setters`/enum `token`/`slotSetters`/
  `actionModule`) and map each to a bundle field. **Reference bar:** an audit doc where every consumer
  field maps to a bundle field or a documented thin-layer exception (m3e-okf provenance may stay a layer
  over the bundle). Builder: Opus (this is design). Critic: Opus (adversarial — hunt for an unmapped
  field; **this critic IS the gate**). The resulting schema is **recorded in the ledger** for review — no
  human block; the audit is the verification, and a wrong schema is caught here or reverted later.
- **1.c** Implement the two new emitter faces in elm-cem: `cem-facts.json` (Face B, incl. moving the
  `.d.ts` inlining into the producer) and `elm-api-facts.json` (Face C, surfacing the internal model
  fields the audit named), plus a bundle **schema validator** and the **provenance stamp**
  (`@m3e/web` version + generation commit). **Reference bar:** unit tests on the validator (TDD here —
  malformed bundle fails, valid passes); the bundle validates; A/B generation of Face A stays empty (the
  new faces must not perturb Elm source). Builder: Sonnet. Critic: Opus.

- **1.d** Resolve the **`Cem.Facts` duplicate-expose** (peer blocker — see Package structure): consolidate
  to one source — `elm-cem-facts` owns `Cem.Facts`; `elm-review-cem` and the generated review-facts
  workspace-dep on it rather than vendoring a copy. **Reference bar:** exactly one `Cem.Facts` in the graph
  (a manifest check finds no duplicate expose) AND elm-m3e's `review/` config compiles + elm-review-cem is
  green. Builder: Sonnet. Critic: Opus (confirm no vendored `Cem.Facts` copy remains and the `Fact` type is
  single-sourced). *Phase-0 scope = remove the in-graph duplication; the publish-time vendor-vs-depend flavor
  is Phase 5.*

**Integrator (M1):** Opus — the bundle is internally consistent, stamped, schema-valid, Face A is
byte-identical to pre-move, and there is exactly one `Cem.Facts` in the graph.

**Escalation:** an unmapped field the critic and builder cannot resolve → treat as a stuck loop and escalate
to human (the linchpin risk from spec §10) — but the default path is the critic forcing a schema revision,
not a human gate.

---

## Milestone 2 — elm-m3e onto workspace elm-cem

**Objective:** elm-m3e generates from the workspace elm-cem; the duplicate `Facts.elm` mirror collapses to
one generation source.

**Parts:**
- **2.a** Point elm-m3e's `gen:src` at the workspace elm-cem (not `../elm-cem`); regenerate. **Reference
  bar:** Elm compiles; `elm-review` with the elm-review-cem config is green; **A/B**: the generated `src/`
  and split packages (incl. `M3e/Review/Facts.elm` and the `elm-m3e-components/` mirror) are byte-identical
  to pre-change. elm-m3e's published package boundaries (the `core`/`components`/`builder` split) are
  **retained as-is** — Phase 0 changes only *where* generation runs (workspace elm-cem), not the package
  structure. Builder: Sonnet. Critic: Opus (confirm no emitted file was hand-touched; the mirror is
  *generated*, not hand-synced).

**Integrator (M2):** Opus — full elm-m3e gate green from a clean checkout.

---

## Milestone 3 — Consumers onto the bundle (PARALLELIZABLE — 3 independent parts)

**Objective:** each JS consumer reads the bundle and deletes its own parser. These three depend only on the
bundle, not on each other → the manager runs them as **three concurrent gauntlet loops** in three worktree
workspaces.

- **3.a — cem-figma-connect.** `src/ingest/cem.mjs`/`dts-inline.mjs` read Face B (matcher); the Elm emitter
  reads Face C. **Authorized deletions:** `profiles/m3-kit/emitters/elm-facts.build.mjs`,
  `profiles/m3-kit/elm-facts.json`, `test/fixtures/m3e-web-*`, `test/fixtures/tailwind-m3e-web-*`.
  **Reference bar:** `pnpm check` green (0 drift / 0 orphan) — byte-deterministic emit proves parity — AND
  the `generated/**` trees byte-identical to the pre-migration baseline. Integrity gate: only the four
  authorized deletions; no `generated/**` or `.figma.ts` hand-edit. Builder: Sonnet (the Face-C rewire has
  judgment). Critic: Opus.
- **3.b — m3e-okf.** `scripts/extract.mjs` reads Face B; delete its CEM parse path and the hand-ported
  `reconcileTagNames`; the README-drift audit stays as a thin layer over the bundle; the `data/sources.json`
  SHA pin is subsumed by the bundle provenance stamp. **Reference bar:** `check:skill` + `check:okf` green;
  `data/components.json` byte-identical to baseline. Builder: Sonnet. Critic: Opus.
- **3.c — tailwind-m3e-web.** `bin/generate-component-utilities.mjs` reads Face B `cssProperties`; delete
  its CEM parse. **Reference bar:** `generated/utilities.css` + `CSS_CUSTOM_PROPERTIES.md` byte-identical to
  baseline (this also fixes the 2.5.14-declared / 2.5.11-installed skew — one install now). Builder: Sonnet
  (a Haiku sub-part is fine for the pure find/replace of the parse call, under the guardrail). Critic: Opus.

**Integrator (M3):** Opus — all three consumers green against the bundle simultaneously; no consumer still
imports a removed parser.

---

## Milestone 4 — The `bump` orchestrator + drift gate

**Objective:** one command drives a version change across both ecosystems, gated.

**Parts:**
- **4.a** Implement `m3e bump <version>`: re-pin `@m3e/web` once → regenerate the bundle → fan out to
  consumers in DAG order → run the union of gates → emit the human-readable diff report (new components,
  changed enums/attrs, any failed Figma match / visual diff). Idempotent. Builder: Sonnet. Critic: Opus.
  **Reference bar:** `m3e bump <current-version>` is a **byte-stable no-op** (idempotence test — nothing in
  the tree changes); the report is produced.
- **4.b** The **cross-cutting drift gate** for CI: regenerate everything from the current bundle, diff
  against committed, require zero diff; generalize m3e-okf's `check:staleness` into the family "upstream
  moved past our pin" signal (non-blocking). **Reference bar (TDD):** a *negative* test — inject a
  one-field staleness into a consumer's committed output and assert the gate reddens; assert it greens on a
  clean tree. Builder: Sonnet. Critic: Opus (verify the gate can't be fooled by pre-existing staleness —
  it must use A/B generation semantics, not naive regenerate-and-diff).

**Integrator (M4):** Opus — a real dry-run `bump` to an adjacent patch version produces a coherent report
and every gate fires correctly (then revert the pin — bumping for real is a separate human decision).

---

## Milestone 5 — Retire the migration's dead weight (intra-monorepo)

**Objective:** delete what the migration made dead *inside the monorepo* (per spec §8 Step 5). The five
original source repos are NOT touched — once their code is absorbed they are simply inert snapshots; leave
them in place (no deletion). The monorepo is now the sole place work happens, and its own `bump`/gate
machinery is what "pulls latest, tests across all, and propagates" — from the one true upstream
(`@m3e/web`), not from the old repos.

**Parts:**
- **5.a** Remove remaining vendored copies / dead parsers / duplicate mirrors not already deleted in M1–M3
  (e.g. elm-m3e's `docs/vendor/tailwind-m3e-web/`, any leftover `test/fixtures/*` CEM copies).
  **Reference bar:** the full family gate is green; `rg` for every deleted path/symbol returns empty; A/B
  generation across the family is clean. Builder: Sonnet; Haiku permitted for the pure grep-guided
  deletions under the guardrail. Critic: Opus.

**Integrator (M5):** Opus — final whole-family gate green; the monorepo is the sole source of truth; the
original repos are untouched and inert.

---

## Milestone 6 — Deep clean (separate commit)

**Objective:** aggressively remove cruft now that the full picture exists. These repos are straightforward —
clear inputs and outputs — so the essential surface is small and everything else is fair game. This lands as
its OWN commit (easy to revert wholesale) after the family is green.

**Keep / remove rule (confirm before running):** KEEP anything that (a) is part of the input→output
pipeline, (b) is the *unique* explanation of a part of it, or (c) tests a part of it. REMOVE everything
else — dead code, superseded/redundant docs, stale framings, old plans/handoffs, orphaned tests, historical
snapshots that no longer describe the system. When in doubt about uniqueness, keep and flag rather than
delete.

**Parts:**
- **6.a** Sweep each package for cruft against the keep/remove rule and delete it in one reviewable commit.
  (The `core`/`components`/`builder` split packages are NOT cruft — they're retained published packages, see
  Package structure — so they're out of scope for deletion.) Builder: Sonnet (needs judgment about what's
  load-bearing). **Reference bar (floor):** the full family
  gate stays green AND A/B generation stays clean after the deletions — this deterministically proves
  nothing load-bearing was removed. **Critic (ceiling):** Opus, doing the real work the gates cannot — it
  verifies no removed doc was the *unique* explanation of a non-obvious mechanism and no removed test was the
  *only* cover for a behavior. Anything the critic flags as uniquely valuable is restored.
- **6.b** If both the critic and the gates pass, the deep-clean commit stands. If either flags over-reach,
  restore the specific items — or revert the whole commit and re-run with a tighter rule.

**Integrator (M6):** Opus — one final read that the monorepo now contains only the pipeline, its unique
docs, and its tests; the commit is self-contained and revertible.

## Self-Review — spec coverage map

| Spec section | Covered by |
|---|---|
| §3 monorepo + single producer + 3-face bundle | M0 (shell), M1 (producer + faces) |
| §4 facts-bundle schema + coverage audit (linchpin) | M1.b (audit; adversarial-critic gate), M1.c (faces + validator) |
| §5 `bump` orchestrator | M4.a |
| §6 dual-ecosystem handling | M0.b (Elm-in-JS convention; Opus-decided, critic-verified, ledger-recorded) |
| §7 consumer rewiring + deletions | M2 (elm-m3e), M3.a/b/c (consumers), M5.a (cleanup) |
| §8 incremental flat-copy migration, producer-first | M0→M5 ordering; M3 parallel |
| §9 determinism drift gate + A/B generation | M4.b + the A/B reference bar in every emitter part |
| §10 risks (schema coverage; Elm-in-JS tooling) | M1.b adversarial critic; M0.b critic — verified, not human-gated |
| §11 non-goals (Phases 1–5) | out of scope; not planned here |
| Deep clean (your request) | M6 (separate revertible commit; gates = floor, Opus critic = ceiling) |

**Placeholder scan:** no `TBD`/`TODO`/"handle edge cases"; every part names its exact reference-bar command
and builder/critic model. **Consistency:** Face A/B/C names, the milestone→spec mapping, and the
authorized-deletion lists match the spec's §3/§4/§7. **No product/architecture human checkpoints** — Phase 0
is pure infrastructure; the schema and Elm-in-JS convention are derived and verified by adversarial critics
and recorded in the ledger, not human-gated. Human involvement is limited to genuinely irreversible acts
(none occur in Phase 0 beyond the ask-before-branch default) and stuck loops.
