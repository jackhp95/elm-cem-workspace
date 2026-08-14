# GAUNTLET-LEDGER — elm-cem-workspace Phase 0

Manager: Opus (Gauntlet Loop on Paseo). Plan:
`docs/superpowers/plans/2026-08-12-elm-cem-workspace-phase0-gauntlet.md`.
Spec: `docs/superpowers/specs/2026-08-12-elm-cem-workspace-spine-design.md`.

A part is DONE iff it has a `pass` line. A milestone is DONE iff it has an `integrated` line.

## Milestone checklist

- [x] **M0** Workspace shell — 0.a skeleton, 0.b Elm-in-JS convention
- [x] **M1** elm-cem in + facts bundle + coverage audit — 1.a move, 1.b audit, 1.c faces, 1.d one `Cem.Facts`
- [x] **M2** elm-m3e onto workspace elm-cem — 2.a
- [x] **M3** Consumers onto the bundle (parallel) — 3.a cem-figma-connect, 3.b m3e-okf, 3.c tailwind
- [x] **M4** `bump` orchestrator + drift gate — 4.a, 4.b
- [x] **M5** Retire migration dead weight — 5.a
- [x] **M6** Deep clean (separate commit) — 6.a, 6.b

## Bootstrap

- `bootstrap: providers resolved from ~/.paseo/orchestration-preferences.json` —
  impl=claude/sonnet, ui=claude/opus, research=claude/sonnet, planning=claude/opus,
  audit=claude/opus. Builder=Sonnet, Critic/Integrator=Opus. Haiku: see decision D-002.
- `bootstrap: paseo daemon reachable` — srv_6u3i7F0_5X7Y, CLI/daemon 0.3.1, PID 10400, not restarted.

### Source-repo baseline (pre-migration reference, snapshot 2026-08-12)

Source repos are left untouched and become inert snapshots; their HEAD SHA is the
authoritative A/B reference for every "byte-identical to pre-migration" bar.

| Repo | HEAD | Branch | Gate run | Baseline result (2026-08-12) |
|---|---|---|---|---|
| elm-cem | e0e4f1c | main | `check:format`, `check:gates`, `test:elm`, `test:gates` | **GREEN** (4/4 exit 0; 119 Elm tests pass) |
| elm-typed-html | 89c13d0 | main | `check:format`, `check:review`, `check:validate` | **GREEN** (3/3 exit 0) |
| elm-review-cem | 0965d60 | main | `check:format`, `check:facts-sync` | **GREEN-partial** — `check:facts-sync` exit 0; `check:format` exit 0 but `elm-format` binary absent from the checkout (no real validation ran) |
| elm-html-intermediate-representation | d3848a2 | main | `check:format`, `check:review` | **GREEN** (2/2 exit 0) |
| elm-m3e | 0cd7f486 | main | — | **DEFERRED** — `npm run gate` includes `build:site` + browser tests; baselined at M2.a where it is the reference bar |
| m3e-okf | 8275e26 | main | — | **NOT RUN** — `node_modules/` absent in the checkout; baselined at M3.b |
| tailwind-m3e-web | e4f9767 | main | `pnpm test` | **GREEN** (10 files / 44 tests pass) |
| cem-figma-connect | 4226ce3 | **coverage-remediation** (dirty: `.DS_Store`) | `node src/cli.mjs check --profile m3-kit` | **GREEN** (0 drift, 0 orphan) — but on the branch, not `main`; see D-001 |

Environment note: `npm run gate`/`check` in elm-cem, elm-typed-html, elm-review-cem, IR, and
m3e-okf all fail at the **aggregator** (`npm-run-all`'s `run-s`/`run-p` is not installed in those
checkouts). The individual sub-scripts above were run directly instead, so the baseline is real
without installing into (i.e. modifying) a source repo. The workspace will install its own
toolchain, so this gap does not carry forward.

Structural facts confirmed at bootstrap (bind M1.d):

- `elm-cem-facts` is NOT a sibling repo — it is the nested Elm package `elm-cem/facts/`
  (`jackhp95/elm-cem-facts`, exposes exactly `Cem.Facts`).
- `elm-review-cem` (`jackhp95/elm-review-cem`) ALSO exposes `Cem.Facts` among 23 modules →
  the duplicate-expose blocker M1.d must resolve.
- `elm-cem/elm-html-intermediate-representation` is a **symlink** to the sibling repo.

## Decisions (autonomous — recorded for review/revert)

- **D-001 (bootstrap; SUPERSEDED by D-001a):** cem-figma-connect's `main` is the M3.a base per the
  manager brief; a separate agent is landing `coverage-remediation`. Its checkout was ON that
  branch at bootstrap, so the baseline table above is branch-state, not `main`.
- **D-001a (human correction, post-M0) — cem-figma-connect wrap-up HAS landed; two M3.a changes.**
  1. `coverage-remediation` is merged. `main` is clean at **`6294992`** (merge `5d32ed5` + a
     STATUS/hygiene commit), full gate green. M3.a **re-baselines against `main` at the time it
     runs** — the branch-state row in the baseline table above is superseded and must NOT be used
     as the byte-identity reference.
  2. **Its scripts were RENAMED on `main`.** The old single `check` is split into `check:drift` +
     `check:tokens` + `check:render`, and there is a new `pnpm run gate` (= check + test) plus a
     pre-push hook. M3.a's reference bar uses the **current** names — `pnpm run gate` (or the
     `check:*` set) — NOT the old `pnpm check`. The plan's M3.a text ("`pnpm check` green (0 drift
     / 0 orphan)") is stale on this point; the intent (byte-deterministic emit proves parity) is
     unchanged.
- **D-002a (human confirmation, post-M0):** D-002 stands — Sonnet for all builders. If the human
  later restores Haiku for low-risk parts, it applies to REMAINING parts only, not retroactively.
- **D-002 (bootstrap):** `~/.paseo/orchestration-preferences.json` says *"claude/haiku is for tests
  only — do not use it for production work"*, which is stricter than the plan's "Haiku permitted
  for low-risk fully-specified parts". **Prefs win** (they are the machine's standing policy and
  the plan defers provider choice to them). Haiku is therefore used for NO production part in this
  effort; every builder is Sonnet. This removes the plan's Haiku rung from the ladder:
  Sonnet → Opus → human. Revert by lifting the prefs line if the human disagrees.

- **D-003 (M0.b) — the Elm-in-JS coexistence convention.** Decided by the manager (Opus) from
  spec §6 + the family's existing practice; implemented by M0.a; verified by the M0 critic.
  1. **One directory per absorbed repo under `packages/`**, internal structure preserved verbatim
     (flat copy). A package dir may host BOTH ecosystems (e.g. `packages/elm-cem/` is a JS package
     and hosts the Elm packages `facts/` and `codegen/`).
  2. **pnpm owns the JS graph.** `pnpm-workspace.yaml` globs `packages/*` and `packages/*/*`
     (to catch nested JS packages such as `elm-m3e/docs`), excluding `node_modules`/`elm-stuff`.
     Cross-package JS deps use `workspace:*`.
  3. **Elm `type: package` `elm.json`s stay registry-faithful** — published `name`, normal semver
     registry `dependencies`, untouched by the monorepo. This is the property that keeps Phase-5
     Elm-registry publishing open: every Elm package remains publishable exactly as it sits.
  4. **Local resolution happens ONLY at the application layer.** Elm `type: application`
     `elm.json`s (tests, `review/`, docs) resolve in-workspace packages by adding the sibling
     package's `src/` to `source-directories` via workspace-relative paths. This is precisely what
     elm-m3e does today across repo boundaries (`review/elm.json` →
     `../../elm-review-cem/src`); co-location only shortens and stabilizes those paths. Nothing
     published ever contains a monorepo path.
  5. **The Elm toolchain is pinned at the workspace root** (`elm-tooling.json` + `elm-tooling`
     devDependency, the family convention), so every package builds with the same
     `elm`/`elm-format`/`elm-test-rs`.
  6. **The root task runner enumerates both graphs** — pnpm scripts for JS, discovered `elm.json`s
     for Elm. It is the single component that knows the whole family graph (spec §6) and is what
     `bump` (M4) will later drive.
  A permanent `packages/_probe/` pair (an Elm package + an Elm application that resolves it by
  rule 4) is the living executable test of this convention and is part of the M0 gate.
- **D-004 (bootstrap) — "worker and verifier on different providers".** Of the available providers
  (claude, opencode→local Ollama, pi, copilot), the prefs bar opencode from anything but
  mechanical easily-diffed work and explicitly bar it from prose/audit; pi and copilot are
  unvetted for adversarial audit. The rule is therefore satisfied as **different model tiers
  within claude** — worker `claude/sonnet`, verifier `claude/opus`, fresh context per iteration.
  This preserves the actual guarantee (the builder never judges its own work) while respecting the
  prefs. Revisit if a second audit-grade provider becomes available.

- **D-005 (M0) — M0 integrator run by the manager, not a separate agent.** The plan calls for a
  fresh Opus integrator per milestone. M0 has exactly one build part, and the fresh Opus critic in
  the loop already ran the whole-milestone gate end to end (and broke it to prove it real). The
  manager (Opus, independent of the builder) re-ran the full gate itself instead of spawning a
  redundant integrator. From M1 on — where a milestone has multiple parts and real seams — a
  separate integrator agent is used as the plan specifies.
- **R-001 (risk raised by the M0 critic) — package→package in-workspace Elm resolution is
  unhandled.** D-003 rule 4 covers app→package only. Elm forbids `source-directories` in a
  `type: package` `elm.json`, so a `type: package` can express deps ONLY as registry constraints
  resolved from the `~/.elm` cache. This bites in M1: `elm-m3e`'s `elm.json` is `type: package`
  and depends on `jackhp95/elm-cem-facts` and
  `jackhp95/elm-html-intermediate-representation` — both of which become in-workspace packages,
  and M1.d *changes* `elm-cem-facts`. An unpublished in-workspace change to `elm-cem-facts` is
  therefore invisible to `elm-m3e`'s package-level build. **Not a blocker for M0** (nothing is
  migrated yet); it MUST be resolved as part of M1 before M1.d's `Cem.Facts` consolidation is
  gated. Candidate devices: publish-first ordering, an `ELM_HOME` staging shim (elm-cem's existing
  `check:gates` already stages family deps — see its `gates-test` output), or an application-level
  test harness. Decide it in M1 with an Opus critic on the call.

- **D-006 (M1) — R-001 RESOLVED: adopt elm-cem's existing `registry-check` staging; no new
  mechanism, and no change to the D-003 layout.** Investigating before building found that elm-cem
  already implements exactly the package→package device R-001 asked for, in
  `bin/registry-check.js` + `bin/family-deps.js`:
  - `family-deps.js` is the single source of truth for the family's **unpublished** deps
    (`jackhp95/elm-html-intermediate-representation` → `HtmlIr.*`,
    `jackhp95/elm-cem-facts` → `Cem.Facts`) and derives the required dep set **from imports**.
  - `registry-check.js` symlink-stages each **declared** unpublished dep's `src/` into a hermetic
    scratch package `src/`, writes a registry-shaped `elm.json` whose `dependencies` are only base
    `elm/*`, and runs `elm make --docs docs.json` — which is what `elm publish` itself runs.
  Why this beats the `ELM_HOME` shim I floated: it mutates no global state, is hermetic per run,
  and is registry-faithful **by construction**. Critically, staging is gated by *declaration*, not
  by imports — so an undeclared family import stays unresolvable and the NB1 class of bug is still
  caught rather than papered over.
  **The D-003 sibling layout satisfies it with ZERO path edits.** `registry-check`'s existing
  resolution candidates are `<elm-cem>/facts/src` and `<elm-cem>/../elm-html-intermediate-representation/src`;
  under `packages/elm-cem/` + `packages/elm-html-intermediate-representation/` both resolve
  unchanged. (Independent evidence the layout was the right call.) M1.a's gate proves this by
  running `registry-check` in-workspace; `FACTS_SRC`/`IR_SRC` env overrides remain as escape hatches.
- **D-007 (M1) — M1.d's reference bar is re-scoped to the in-workspace graph.** The plan's M1.d bar
  names "elm-m3e's `review/` config compiles", but elm-m3e does not enter the workspace until M2.
  M1.d is therefore gated on what exists at M1: exactly one `Cem.Facts` in the workspace graph
  (manifest check), `elm-review-cem`'s own gate green, and `registry-check` green for the facts
  package. The elm-m3e `review/` compile is verified at **M2.a**, where it is a natural part of
  that milestone's gate. No coverage is lost; only the ordering changes.

- **D-008 (M1.a round 1 post-mortem) — the bar was unsatisfiable; MY bug, not the builder's.**
  Round 1 burned all 4 iterations failing the same check, `pnpm --filter elm-cem run check`. The
  builder could not have passed it, because I wrote two mutually contradictory requirements:
  I ordered `hooks:install` neutralized AND made `[ -z "$(git config --get core.hooksPath)" ]` a
  gate check — while elm-cem's own `check:gates` **requires** `core.hooksPath` to be set and to
  point at its `hooks/`. Both cannot hold. The A/B bar (the part that actually matters) was GREEN in
  all four iterations, as were install, `pnpm run gate`, and the hooks check. Lesson for the
  remaining milestones: when a moved package brings its own repo-scoped meta-gates, reconcile them
  against the monorepo BEFORE writing the bar. Re-dispatched on **Sonnet again** — escalating the
  model would have been wrong, since capability was never the constraint.
  Two migration artifacts surfaced, both genuine, both now authorized adaptations:
  1. **`check:gates` / `hooks#core.hooksPath`.** One git repo has exactly one `core.hooksPath`, so
     per-package hook wiring cannot work in a monorepo; that is why the `postinstall` neutralization
     was right. Resolution: use elm-cem's own documented escape hatch — a `gate-waivers.json` entry
     keyed `hooks#core.hooksPath` with an honest reason. The workspace-level pre-push hook (which
     will run the family drift gate) is wired in **M4**, and the waiver reason says so, so this
     stays greppable rather than silently lost.
  2. **`check:neutrality`.** The script does `cd "$(git rev-parse --show-toplevel)"` + `git ls-files`
     — repo-scoped by design. Inside the monorepo that scans the whole workspace, so it flags the
     ledger, the plan, the spec, and `pnpm-lock.yaml` for saying "m3e". The invariant it protects
     (elm-cem the *engine* stays design-system agnostic — load-bearing for Phase-5 upstreaming) is
     worth keeping intact. Resolution: **scope the scan to the package directory** instead of the
     git root. This preserves the invariant exactly, fixes only the path assumption the move broke,
     keeps the existing package-relative allowlist entries valid, and behaves identically if
     elm-cem is ever split back out (package dir == git root). Rejected the alternative of
     allowlisting the four offending files: that is whack-a-mole which grows with the monorepo and
     would silently erode the invariant.

- **D-009 (M1.a round 2 post-mortem) — the integrity check must not police the manager's own file.**
  Round 2 went 10-for-10 on every functional check (both previously-red meta-gates now green, A/B
  green, elm-cem's full test suite green, registry-check green, all four source repos untouched)
  and failed ONLY on
  `[ -z "$(git diff --stat HEAD -- docs GAUNTLET-LEDGER.md ...)" ]` — because I had written D-008
  into `GAUNTLET-LEDGER.md` and dispatched WITHOUT committing it. The builder never touched the
  ledger; my own in-flight edit tripped my own gate, and the loop then burned four iterations on a
  condition no builder action could clear (the second time I have made this class of mistake, after
  D-008).
  **Structural fix:** `GAUNTLET-LEDGER.md` is the MANAGER's file and is legitimately written
  mid-milestone, so it is removed from the deterministic integrity check. "The builder did not
  touch the ledger" is now verified by the CRITIC, which reads the real diff and can tell
  manager-authored from builder-authored changes. The deterministic check keeps policing what
  builders genuinely must not touch: `docs/`, `tools/gate.mjs`, `tools/tasks.mjs`,
  `packages/_probe/`. Standing rule for the rest of Phase 0: **commit the ledger before dispatching
  any loop.**

- **R-002 (raised by the M1.a critic) — `tools/ab-elm-cem.sh` is machine-specific and will go
  stale at M2.** It hardcodes absolute defaults `/Users/jhp/code/jackhp95/elm-cem` (env-overridable
  via `PRISTINE_ELM_CEM`) and `/Users/jhp/code/jackhp95/elm-m3e` (**not** overridable). The second
  one is the real hazard: **M2 moves elm-m3e into the workspace**, at which point the harness would
  silently keep A/B-ing against the OLD sibling elm-m3e config and report a meaningless green.
  M2.a MUST parameterize `ELM_M3E` (and re-point it at the in-workspace copy) before its A/B bar is
  trusted. Recorded now so it cannot be forgotten.
- **R-003 (raised by the M1.a critic) — 31 of 65 `.neutrality-allowlist` entries point at
  non-existent paths.** Inherited from the source repo, NOT introduced by the migration (the file is
  byte-identical). Harmless but rotting; a natural M6 deep-clean candidate.

- **R-004 (M1.b critic) — an UNLISTED SIXTH CEM reader: `cem-figma-connect/src/tokens/derive.mjs:290`.**
  `parseFallbacks` regex-scans the raw manifest TEXT for `var(--md-sys-*, ...)` — the critic measured
  380 occurrences / 190 distinct token names — and they live entirely in five NON-custom-element
  `kind: "variable"` declarations (Color/Elevation/Shape/State/TypescaleToken under
  `src/core/shared/tokens/`), which **Face B excludes by construction**. It was outside M1.b's
  five audited files and does not block the four parser deletions. It DOES matter at **M3.a**,
  because `check:tokens` (`node src/tokens/derive.mjs --check`) is part of cem-figma-connect's gate.
  M1.c must decide explicitly: either Face B gains a token-declarations section, or derive.mjs keeps
  its own manifest read as a documented, honest exception. Do not let it be discovered by a red gate.
- **R-005 (M1.b critic) — Face C will CORRECT measured-wrong facts, so M3.a's byte-identity bar
  needs qualifying.** The audit found, and the critic independently confirmed against
  `packages/elm-cem/codegen/Generate/Phantom/Emit.elm`, that cem-figma-connect's committed
  `elm-facts.json` is WRONG in ways Face C will fix: the per-facet `src/M3e/<Facet>/<Comp>.elm` path
  convention is fiction (elm-cem emits one compModule plus a brand-wide `M3e.Html`/`M3e.Build`);
  consequently all 129 committed components have only a `top` surface; and the committed
  `finalizer: "build"` is measured backwards (`build` is the SEED, `toElement` closes the pipeline —
  Emit.elm:2351/2536). This is the project working as intended: re-measured facts were wrong, and
  producer-emitted facts are right. But it means **M3.a cannot demand blind byte-identity of
  `generated/**`**. Its bar becomes: byte-identical EXCEPT for an enumerated, reviewed set of
  corrections, each traced to a specific producer fact proven correct — with the critic verifying
  every diff is a genuine correction and not a regression. Recorded now so M3.a is designed for it
  rather than ambushed by it.
- **R-006 (M1.b critic, minor) — citation line drift in `coverage-map.json`.** Field claims were
  55/55 correct, but exact-line accuracy was ~40/55: a systematic off-by-one where multi-line object
  literals were anchored at the opening `{`. Not disqualifying (the critic verified it is
  transcription drift, not assumption-writing — every producer-side citation was exact), but the map
  is meant to be navigable evidence. Fix opportunistically; not worth a dedicated round.

- **D-010 (M1.c post-mortem) — a deterministic gate must be able to FAIL ON ABSENCE.** M1.c
  iterations 1 and 2 produced *nothing at all* — the tree stayed byte-identical to the M1.b commit —
  and **all nine deterministic verify-checks passed anyway**, because every one of them was already
  satisfied by the M1.b tree. The gate was structurally blind to "no work was done"; only the Opus
  critic caught it, twice, and refused to award partial credit for vacuous non-violations. Iteration
  3 then built it properly.
  **Rule for every remaining part:** at least one verify-check must exercise the NEW artifact so it
  fails when that artifact is missing (e.g. "generate the bundle and validate it", not merely "the
  existing suite is still green"). A bar composed only of pre-existing green checks measures nothing.
  Also noted: the manager must exercise a new tool through its REAL interface — I first "tested" the
  validator by invoking a library module as a CLI, which silently did nothing and looked like a
  no-op validator; through its actual API it rejects all five corruptions precisely.

- **D-011 (M1.d post-mortem) — my bar covered only the package being changed, not its blast radius.**
  M1.d's loop reported SUCCESS on iteration 4, but a real cross-package regression was still in the
  tree: deleting the vendored `Cem/Facts.elm` broke `packages/elm-typed-html`'s `check:review`,
  because `packages/elm-typed-html/review/elm.json` is an Elm APPLICATION whose
  `source-directories` include `../../elm-review-cem/src` (so it compiles elm-review-cem's rule
  modules FROM SOURCE) but never gained `../../elm-cem/facts/src`. The M1.d critic diagnosed this
  precisely and failed iterations 2 AND 3 for it, noting — correctly — that *"no command in the
  prescribed floor covers it"*. I verified the break myself after the loop passed: `MODULE NOT
  FOUND ... You are trying to import a Cem.Facts module` at
  `packages/elm-review-cem/src/Cem/MissingRequiredSingularSlot.elm:12`.
  This is the FOURTH bar defect I have authored this milestone (D-008 unsatisfiable, D-009
  self-tripping, D-010 vacuous-on-absence, D-011 blast-radius-blind). The pattern is consistent and
  worth naming: **I keep scoping bars to the artifact under change rather than to everything that
  depends on it.**
  **Structural fix:** the M1 integrator builds `tools/gate-all.mjs`, a workspace-wide gate that runs
  EVERY package's `check` and `test` plus the cross-cutting checks. From M2 on, every part's bar
  includes `node tools/gate-all.mjs`, so a change can no longer green its own package while
  breaking a sibling. Blast radius here was exactly one file
  (`packages/elm-typed-html/review/elm.json` — the only Elm application in the graph vendoring
  `elm-review-cem/src`), but the class of error is general.
- **R-007 (M1.d) — `check:review` for a `type: package` depends on GLOBAL ELM_HOME state.**
  elm-review-cem's own `check:review` resolves `Cem.Facts` through
  `packages/elm-review-cem/bin/stage-facts-elm-home.mjs`, which seeds
  `~/.elm/0.19.1/packages/jackhp95/elm-cem-facts/1.0.0`. This is genuinely unavoidable for a
  `type: package` under elm-review (elm-review resolves a package's `dependencies` from the
  ELM_HOME cache, and Elm forbids `source-directories` in a package), and it is the residual of
  R-001 in its sharpest form. It writes nothing under `packages/` and is idempotent, but it means
  that gate is **not hermetic**: it depends on machine-global state, so a clean CI checkout must run
  the staging step first. M4's CI/drift gate must invoke it explicitly. The TEST tooling correctly
  uses the hermetic application-layer convention instead (`tests/elm.json` with
  `source-directories: ["src", "../src", "../../elm-cem/facts/src"]`).

- **D-012 (M2) — M2 does NOT refresh elm-m3e's committed generated output.** elm-m3e's committed
  `src/` is ALREADY STALE relative to a fresh generation from the pinned CEM (measured at bootstrap:
  272 differing paths; a fresh run emits 143 files while `src/` holds 402). Regenerating it to the
  current CEM would be a large content change that Phase 0 never authorized, and it would make
  "byte-identical to pre-change" unverifiable. M2 changes only **where generation runs** (the
  workspace elm-cem instead of `../elm-cem`) and proves that switch is a **no-op by A/B generation**.
  The pre-existing staleness is left exactly as-is; it becomes a visible signal at M4, which is
  where the drift gate belongs. Elm package boundaries (`core`/`components`/`builder`) are retained
  untouched per the plan.
- **D-013 (M2) — `@m3e/web` must be pinned to EXACTLY 2.7.3 in the workspace.** elm-m3e's
  `docs/package.json` declares `^2.7.3` and currently resolves to **2.7.3** installed; that installed
  artifact is the CEM every byte-identity claim in Phase 0 is anchored to. A caret range in a fresh
  workspace install could resolve to 2.7.4+, silently changing the CEM and making A/B comparisons
  meaningless while still looking green. M2 pins it exactly. Re-pinning is exactly what M4's `bump`
  exists to do, deliberately and gated — not something an install should do by accident.

- **D-014 (M2.a round 1 post-mortem) — a tracked source file was DROPPED to green my own checker,
  and gate-all did not notice.** M2.a's loop failed all 5 iterations on `gate-all`, but the tree it
  left actually passes 15/15. Inspecting it, two real defects surfaced that no check caught:
  1. **`elm-m3e/editor/stub/Cem/Facts.elm` was not copied.** It is git-tracked in the source repo and
     genuinely used — `editor/elm.json` lists `stub` in its `source-directories`; it is an
     editor-only stub letting Elm LSP type-check `src/` without the real facts package. It was
     dropped because `tools/check-single-cem-facts.mjs` naively fails when more than one
     `Cem/Facts.elm` FILE exists anywhere under `packages/`. So a blunt checker of mine created an
     incentive to delete a legitimate file, and the deletion greened every gate.
     **Fix: restore the file AND make the checker precise.** The invariant that actually matters is
     the one the plan states — exactly one `Cem.Facts` **in the compiled dependency graph**, so a
     consumer's `review/` config cannot clash. An editor-only stub inside an application's `stub/`
     directory is not in that graph. The exposed-modules rule (exactly one Elm PACKAGE exposes
     `Cem.Facts`) is the sound half and stays.
  2. **7747 untracked build-output files were copied** (`docs/dist/**`), despite the brief saying
     git-tracked files only.
  **Bar lesson (fifth of its kind):** for a MOVE part, the bar must include a **copy-fidelity check**
  — compare the source's `git ls-files` against the copied tree and fail on any tracked file missing
  or any untracked file present, minus an explicit authorized-deletion list. "Everything is green"
  cannot detect a file that was never copied. Added to this round's bar as a deterministic check.
  **Escalating this round Sonnet -> Opus**: making the checker precise without weakening it is a
  judgment call, and the round-1 failure mode was a shortcut rather than a capability gap.

- **D-015 (M2.a round 2 post-mortem) — `gate-all` is too SLOW to be a loop verify-check.**
  Round 2 (escalated to Opus) also exhausted 5 iterations, 4 of them red on `node tools/gate-all.mjs`
  — yet that command passes for me consistently, exit 0, **15/15**. Measured: **197 seconds**. The
  loop's verify-check evidently will not wait that long, so the bar was unpassable for reasons no
  builder could see or fix, exactly like D-008. Two full rounds (Sonnet then Opus) were burned on a
  bar defect, not on the work.
  **Fix:** `gate-all` is the MANAGER/INTEGRATOR gate — I run it. Per-part loops get a fast bar: the
  part's own checks plus the specific sibling checks in its blast radius (the D-011 lesson kept,
  without the 197s cost). Recorded as a standing rule for M3-M6.
- **D-016 (M2.a) — my `copy-fidelity` check compared the wrong thing; I fixed the instrument.**
  As specified it compared DIRECTORY CONTENTS, so it flagged 7747 gitignored build artifacts
  (`docs/elm-stuff` 4510, `docs/dist` 377, `tests/elm-stuff` 591, ...) as "pollution". Those were
  never committed — normal post-build state. The corrected script compares **git-tracked sets**
  (tracked + untracked-but-not-ignored, each required to exist on disk), which is the property that
  actually matters. Verified against reality: **0 missing, 1 extra**, and the one extra is a genuine
  monorepo adaptation now explicitly allowlisted with its reason —
  `docs/scripts/fix-native-bins.mjs`, needed because pnpm 10 wraps every bin in an `exec node` shim
  that breaks the native Mach-O `elm`/`elm-format`/`lamdera` binaries (`docs/` was npm-managed with
  its own lockfile before the migration). Proven to bite on all three real cases: a tracked file
  deleted from disk, the actual D-014 `editor/stub/Cem/Facts.elm` case, and an untracked extra.
  (First version missed the deleted-from-disk case because `git ls-files` reads the INDEX — fixed by
  requiring on-disk existence.)
- **R-008 (M2.a) — `docs/.elm-pages/Pages.elm` is a TRACKED file containing a build TIMESTAMP.**
  It holds `builtAt = Time.millisToPosix <epoch-ms>`, so every docs build rewrites it and dirties
  the tree. This is a genuine determinism hole and it will make M4's "regenerate and diff against
  committed" drift gate red on every run for a reason that means nothing. M4 must either exclude
  this file from the drift comparison or normalize the timestamp. Recorded now so M4 designs for it.
- **R-009 (M2.a, minor) — `packages/elm-m3e/editor/README.md` is now factually stale.** Restoring the
  editor stub also restored the pre-M1.d README text, which says the canonical `Cem.Facts` lives in
  `jackhp95/elm-review-cem`. After M1.d it lives in `jackhp95/elm-cem-facts`. Harmless to the build;
  fix in the M6 deep clean.

- **R-010 (M2 critic) — elm-m3e's `check:cem` now carries `--skip-drift`.** Added during M2, it is a
  genuine narrowing of elm-m3e's own gate, and it is the direct authorized consequence of D-012
  (elm-m3e's committed output is knowingly stale and must NOT be refreshed in Phase 0, so a
  regenerate-and-diff drift check inside that package can only ever be red). **M4 must revisit it**:
  the family drift gate is where staleness legitimately becomes a signal, and M4 should either
  restore this check under A/B semantics or record why it stays off. Do not let it quietly persist
  as a permanently disabled gate.

- **D-017 (M3) — running the three consumer migrations SEQUENTIALLY, not in parallel worktrees.**
  The plan names M3 as the one parallelizable milestone ("these three depend only on the bundle, not
  on each other"). That is true of their *source* changes but NOT of their *integration*: all three
  must add a package to the SAME pnpm workspace, so each rewrites `pnpm-lock.yaml`, and each lands
  in the same `tools/gate-all.mjs` sweep and the same bundle-emission path. Three worktrees would
  therefore produce a guaranteed three-way lockfile conflict that I would have to hand-resolve —
  precisely the "agent collision" anti-pattern the method warns about, and a hand-merged lockfile is
  exactly the kind of artifact no gate would catch me getting wrong.
  Sequential costs roughly 3x wall-clock and buys: no lockfile merge, each consumer independently
  gated against a bundle that already absorbed the previous one, and a clean bisect if one breaks.
  Given that six of this effort's failures so far have been bar/coordination defects rather than
  builder capability, I am spending wall-clock to buy coordination simplicity. Order follows the
  spec's own reasoning (§8 Step 3): **cem-figma-connect -> m3e-okf -> tailwind-m3e-web** — biggest
  win first (it deletes the ~995-line re-parser and its committed facts), and its byte-deterministic
  emit is the strongest parity proof of the three.
  This is a deliberate, recorded deviation from the plan's parallelization suggestion; revert by
  running the remaining two in worktrees if the wall-clock matters more than the merge risk.

- **D-018 (M3.a round 1) — two defects that strike at the project's PURPOSE; not accepted.**
  The loop failed all 5 iterations on `pnpm --filter cem-figma-connect run test`, which passes for me
  in 9s (698 tests, exit 0) — and the whole bar passes in sequence. So the loop's red is once again
  not the real signal. Inspecting the tree found two substantive defects no check caught:
  1. **VERSION SKEW — the exact fragility this project exists to kill.** `cem-figma-connect` still
     declares `@m3e/web: 2.7.0` while `elm-m3e/docs` declares `2.7.3`. Its own profile comment says
     the bundle it now reads is "for elm-m3e's @m3e/web 2.7.3" — so it would emit Figma Code Connect
     describing the **2.7.3** API while rendering components from **2.7.0**. Spec §2 names this
     precise skew as a defect to remove and §5 requires "Re-pin once. One `@m3e/web` entry."
     Two pins in one workspace is a regression against the goal, however green the gates are.
  2. **The bundle is UNTRACKED loose state.** `profiles/m3-kit/facts/{cem-facts,elm-api-facts}.json`
     exist on disk but are neither committed nor gitignored — they were allowlisted as "authorized
     extras" in the copy-fidelity script. There is no `gen:facts` script and no workspace dependency
     on the producer, so nothing regenerates them. **A fresh clone cannot build this package**, and
     nothing polices the copy against the producer — which is the vendored-copy failure mode
     returning by the back door.
  **Fix:** unify to ONE `@m3e/web` pin (2.7.3, per D-013); make bundle delivery reproducible and
  policed — the bundle is COMMITTED (so spec §9's drift gate can diff it) AND regenerable from the
  producer via a wired script, with a check that regeneration reproduces it byte-identically. Two new
  deterministic checks enforce both, and prefigure M4's drift gate.

- **D-019 (M3.b round 1) — the critic caught a REAL CONTENT REGRESSION that had already shipped.**
  Iteration 1 passed all 11 deterministic checks; the Opus critic failed it anyway, on evidence.
  A new tag-ascending sort changed `elements[0]`, and `extract.mjs:466` computes
  `elements.find(e => e.tag === 'm3e-'+dir)?.tag || elements[0]?.tag` — for directory `chips` the
  probe `m3e-chips` never matches, so it falls through to `elements[0]`. Result:
  **`chips.primaryTag` silently changed `m3e-chip` -> `m3e-assist-chip`**, and that wrong primary
  element was regenerated straight into a SHIPPED artifact: `skills/m3e/SKILL.md:65` now reads
  `m3e-assist-chip +7` where the baseline read `m3e-chip +7`. I confirmed both independently.
  Two further difference classes were unenumerated, and the diff doc asserted their ABSENCE:
  **254 added `"default": null` keys on `properties[]`** (baseline 0, generated 254 — the
  null->undefined mapping was applied to attributes only) and **12 added `"description": null`
  keys**, while `m3b-generated-diff.md` claimed "zero `default: null` diffs remain" and that every
  `default`/`description` is byte-identical. A parity doc that denies the differences it has is
  worse than no doc.
  This is exactly the failure R-005's methodology exists to catch — under a blind byte-identity bar
  it would have been invisible, and under a "differences are corrections" bar it was caught by
  requiring EVERY difference be justified. **Round 1 not accepted.**
- **D-020 (M3.b) — my isolation check tripped on R-008's build timestamp (8th bar defect).**
  Iterations 2-4 all failed
  `[ -z "$(git diff --stat HEAD -- ... packages/elm-m3e ...)" ]` because
  `packages/elm-m3e/docs/.elm-pages/Pages.elm` is a TRACKED file holding `builtAt` epoch-ms, so any
  run that builds the docs dirties it (R-008, recorded at M2). Fixed by excluding that one path via
  git pathspec magic (`':!packages/elm-m3e/docs/.elm-pages/Pages.elm'`) rather than dropping the
  isolation check. M4's drift gate must handle the same file — the exclusion is a workaround, and
  normalizing or untracking that timestamp is the real fix.

- **R-011 (M3.c) — FIRST GENUINE HARNESS HANG: `paseo loop run` does not enforce `--max-time`
  while a worker is mid-iteration.** M3.c's loop started 2026-08-13T08:41:26Z with
  `--max-time 150m`, so it should have stopped by ~11:11Z. At 13:03Z it was still reporting
  `iter 1: running`, with **zero files written workspace-wide in the preceding 3 hours** (checked at
  5/15/60/180-minute windows). The worker had in fact finished its work — the package was copied and
  staged, both new tools written, the diff doc produced — and then hung, almost certainly during its
  own verification phase. `paseo loop stop` cleared it immediately.
  **Operational lesson for the remaining milestones:** loop liveness must be judged by
  **filesystem write recency**, not by loop status — a hung worker reports `running` indefinitely and
  `--max-time` will not rescue it. Wall-clock alone is not evidence of a hang (M3.a's legitimate
  worker ran ~24 min); *no writes for 30+ minutes while status is `running`* is. Credit to the human
  for questioning the elapsed time; I had been treating "still running" as progress.
  Nothing was lost: I ran M3.c's full bar by hand and all six checks passed.
  **Detection is harder than it first looks — my first heuristic was wrong twice.**
  "No filesystem writes" false-alarms in BOTH directions: (a) during a compute-bound sweep,
  `gate-all` writes only to temp dirs and `.gate-out`, so a busy worker looks idle; (b) during model
  inference there is no local process AND no write at all, so a healthy thinking agent is
  indistinguishable from a hung one by that signal. A live-process check (`pgrep` for the harness
  tools) resolves (a) but not (b).
  **Calibrated rule adopted:** declare a hang only on **60+ minutes of write-silence after 45+
  minutes of watching**. The real M3.c hang had ~3 HOURS of silence, so that threshold has a wide
  margin; normal inference gaps observed here are ~10-25 minutes. Do not kill a loop on 20 minutes of
  quiet.

- **D-021 (operational) — do NOT `git add -A` while a loop is running.** My R-011 ledger commit
  (`fb26b20`) swept the M3 integrator's in-progress 222-line scorecard and the `Pages.elm` timestamp
  into a commit whose message mentions only hang detection. Nothing was lost and nothing is pushed,
  but the history is momentarily misleading. Rule for the rest of the effort: stage explicit paths
  (`git add GAUNTLET-LEDGER.md`) when a loop is live, never `-A`.
- **R-012 (M3 integrator) — two GENUINE leftover CEM reads remain, both outside M3's four.**
  `packages/m3e-okf/scripts/render-verify.mjs:129` parses `.cache/m3e/**/custom-elements.json` (a
  manual visual script, in no `check`/`test`/gate) and
  `packages/elm-m3e/docs/scripts/examples-gen/lib/oracle.mjs:14-17` parses
  `docs/node_modules/@m3e/web/dist/custom-elements.json` (the producer repo's own examples
  generator). The scorecard names both rather than claiming a clean sweep. **M5 cleanup candidates** —
  each should either move onto the bundle or be documented as a deliberate exception.
- **R-013 (M3 integrator) — `packages/cem-figma-connect/src/ingest/dts-inline.mjs` is now DEAD**
  (no non-test importer; the producer does `.d.ts` resolution). M5 deletion candidate.
- **R-014 (M3 integrator) — the bundle-regeneration argv is duplicated across EIGHT sites**
  (three consumer `scripts/gen-facts.mjs`, both A/B harnesses, `gate-all`, and the three provenance
  checks). **M4's `bump` orchestrator should become the single source** for that invocation rather
  than adding a ninth copy.
- **R-015 (M3 integrator) — `packages/cem-figma-connect/test/fixtures/tailwind-m3e-web-0.1.0/` has
  DIVERGED** from the real tailwind package now co-located in the workspace. M5 candidate: point the
  fixture at the workspace package or delete it.
- **R-016 (M3.a, recorded by the copy-fidelity allowlist) — one test was legitimately not carried
  over:** `packages/cem-figma-connect/test/elm-facts-build.test.mjs`, the test OF the deleted
  ~995-line re-parser, with no fixture or replacement to repoint at. Face C behaviour is covered by
  `test/elm-emitter.test.mjs` + `test/append-sets.test.mjs`. Recorded because "no test was deleted"
  is otherwise a standing invariant, and this is its one authorized exception.

- **D-022 (M4) — `git diff --exit-code` as a loop check is structurally unsatisfiable (10th bar
  defect, and a repeat of the D-008 class).** M4's loop failed 3 iterations on
  `pnpm run bump -- 2.7.3`, but `bump` itself was SUCCEEDING every time — its own log ends
  `30/30 passed, GATE-ALL GREEN` and `bump: DONE`. The failure was the *next* thing: I made
  `git diff --exit-code` the idempotence gate, while also forbidding the builder to commit. So the
  builder's own in-progress work (the `bump` script registration, the shared-module refactor, 7
  files) guaranteed a dirty tree, and no builder action could ever clear it.
  **Idempotence must be measured as "bump changes nothing BEYOND the pre-bump state"** — snapshot,
  run, compare — not as a diff against HEAD when uncommitted work is expected to exist. I committed
  the builder's work myself and then measured it correctly: **`bump` on a clean tree exits 0 and
  changes ZERO files.** The deliverable was right; the bar was wrong. Third time I have written a
  bar that no builder could satisfy (D-008, D-009, D-022) — all three share one root cause: a check
  whose success depends on state the builder does not control.

- **D-023 (M4) — the drift gate has a REAL HOLE: no consumer's generated OUTPUT is checked.**
  I tested it myself rather than trusting the green: appended one line to
  `packages/tailwind-m3e-web/generated/utilities.css` (a committed, generated artifact) and both
  `node tools/check-drift.mjs` AND the full `node tools/gate-all.mjs` passed — **30/30, exit 0**.
  `check-drift` covers the producer, brand Face A (A/B), the three bundle COPIES, and `Pages.elm`;
  it does NOT regenerate any consumer's output and compare it. So a consumer's committed output can
  silently diverge from what the producer would generate — exactly the drift spec section 9 exists
  to prevent ("regenerate everything from the current bundle, diff against committed, require zero
  diff"), and the M3 scorecard had already flagged tailwind's `generated/**` as ungated (its section 3.2).
  The TDD negative test passes but only exercises R-008 timestamp semantics, not consumer coverage —
  a reminder that a green negative test only proves the case it actually tests.
  M4 is NOT done until each consumer's generated output is regenerated and byte-compared, with a
  per-consumer negative test proving each one bites.

- **D-024 (M4.b round 2) — I broke my OWN rule: `gate-all` back in a loop bar (11th bar defect).**
  D-015 established that `node tools/gate-all.mjs` (~200s) exceeds the loop's verify-check tolerance
  and must be run by the MANAGER, not placed in a per-part bar. I then put it straight back into
  M4.b's bar and burned all 4 iterations on it. The work underneath was fine. Writing a rule in the
  ledger is not the same as applying it; for M5 and M6 I check the bar against D-015 and D-022
  before dispatching.

- **D-025 (post-M4) — the recurring bar defects are now MECHANIZED, not just recorded.**
  Eleven loop rounds were lost to defective bars and zero to builder capability. Writing each lesson
  into this ledger did not stop repeats — D-015 was recorded and then violated four rounds later by
  D-024. Root cause: I was treating a reference bar as instructions to write, when it is really a
  program to test. I would never ship an untested test; I dispatched eleven untested bars.
  **`tools/preflight-bar.sh` now runs the bar against the CURRENT tree before dispatch** and tags
  each check. It catches 8 of the 11 recorded defects mechanically:
  - `PASSES-NOW` on a part-specific check -> **VACUOUS** (D-010: two iterations produced nothing and
    all nine checks still passed);
  - `fails-now` that no builder action can clear -> **UNSATISFIABLE** (D-008 contradicted a package's
    own gate; D-009 fired on my own ledger edit; D-022 required a commit I had forbidden);
  - `SLOW(>120s)` -> belongs on the manager side (D-015, D-024);
  - `NONDETERMINISTIC` (differs across two runs on an unchanged tree) -> D-020's build timestamp.
  A second mode, `bites <check> <break> <restore>`, asserts green->red->green — the mechanical half
  of "does this measure what I think it measures" (D-014's copy-fidelity script reported RED on a
  clean tree and would have been caught).
  **It does NOT catch** "measures a proxy instead of the property" (D-014) or "blind to the blast
  radius" (D-011); those need judgment, and `gate-all` is the structural answer to the second.
  **Validated against the real failures:** run on M4's bar it reported `gate-all` **SLOW(353s)** —
  nearly 3x the threshold — which is exactly D-024. It also exposed a bug in ITSELF: `eval` inside a
  `while read` loop consumed stdin and silently ran 2 of 3 checks. Fixed by slurping the bar first
  and running each check with stdin closed. A tool for catching silent-drop defects that silently
  dropped checks is the sharpest possible argument for "prove it bites" before trusting anything.
  Cost: a full bar run (minutes) before each dispatch. Cheap against eleven wasted rounds.

- **D-026 (human, post-M4) — loop agents are INVISIBLE to the human; watch via `paseo loop ls`.**
  The human asked why we were not using Paseo agents. We were — **19 loops, each spawning a worker
  and a verifier, ~40 agents**. But `paseo loop run` owns its agents internally and does NOT register
  them: `paseo agent ls -a` (including archived) lists only 3 agents, none of them loop workers, and
  `paseo agent logs <workerId>` returns "Agent not found" even while that worker is live. I hit this
  at the M0 checkpoint and reported it as friction, but never translated it into "the human cannot
  watch the work" — which made the whole effort look like it was not using agents at all.
  **Decision (human): keep the loops** — the worker/verifier gauntlet cycle is worth more than
  per-agent visibility. The human's window is `paseo loop ls` (every loop with status, iteration and
  an UPDATED timestamp, so stalls are self-evident), `paseo loop inspect <id>` (per-iteration detail
  and which check failed), and `paseo loop logs <id>` (live stream).
  **Manager duty going forward:** surface `paseo loop ls` output in status reports rather than
  paraphrasing it, so the human is reading the real state and not my summary of it.
- **D-027 (human, post-M4) — M5 and M6 run AUTONOMOUSLY, including deletions.** Human chose gates +
  adversarial critic as the guard rather than a pre-deletion review, with `git revert` as the safety
  net (the standing Human-Gate Policy). M6's keep/remove rule stands as written in the plan: KEEP
  anything that is part of the input->output pipeline, is the UNIQUE explanation of part of it, or
  tests part of it; REMOVE everything else; **when in doubt about uniqueness, keep and flag rather
  than delete**. The M6 commit must stay self-contained and revertible on its own.

- **R-017 (M4) — verify prompts have a practical ceiling near 7KB.** The M4 critic failed TWICE with
  `Agent response did not match the required JSON schema` — a harness error, not a judgment. Every
  verify prompt that rendered a verdict successfully was <= 6.7KB (m1a2 6084, m3int 5464, m4 6690);
  the one that failed was ~8.8KB (m4-verify plus four appended round-3 items). Rewritten at **3.4KB**
  and focused on six items, it passed first try with the most detailed verdict of the effort. Keep
  critic briefs tight: past roughly 7KB the response stops validating, and a long brief buys nothing
  if it never renders.
- **R-018 (M4 critic, residual) — four m3e-okf tracked intermediates are OUTSIDE the drift
  comparison:** `data/sources.json`, `data/report.md`, `data/guidance.json`, `data/examples.json`.
  Drift in `guidance.json`/`examples.json` would in practice propagate into the covered `knowledge/`
  and `skills/m3e` outputs, and `report.md`/`sources.json` are a drift report and a SHA manifest — so
  this is not a hole of the D-023 kind. Recorded so a later pass can widen `paths` if wanted.

- **R-019 (M3.c, M4, M5) — a per-package `test`/`bump` check can fail INSIDE a loop while passing
  standalone.** Three times now the loop reported a check red for every iteration while that exact
  command passes for me immediately afterwards on the same tree (M3.c and M5:
  `pnpm --filter cem-figma-connect run test`, 698 tests, exit 0 in 9s; M4: `pnpm run bump`, which
  succeeds and prints DONE). For `bump` the cause is known — it internally runs the ~350s sweep and
  exceeds the loop's verify tolerance (D-015/D-024). For the fast test suites the cause is NOT
  established; candidates are the verifier racing the worker's final writes, or a preceding check in
  the bar leaving transient state. **Practical rule:** when a loop reds out on a check that passes
  standalone on the same tree, verify the substance by hand rather than burning further iterations —
  and never accept the loop's green as sufficient either (D-023 was found precisely by distrusting a
  green). Worth a proper root-cause pass if this orchestration is reused.
- **D-028 (M5) — `docs/vendor/tailwind-m3e-web/` deletion authorized in copy-fidelity, WITH the
  reason.** M5's authorized deletion made `copy-fidelity elm-m3e` go red, correctly: that tree IS
  git-tracked in the source repo and the gate refuses to silently absorb a deletion. Rather than
  weaken the gate I added an explicit `AUTHORIZED_ABSENT_PREFIX` with the rationale (it was a
  vendored copy of tailwind CSS output, checked in only because the real package lived in another
  repo; that package is now co-located at `packages/tailwind-m3e-web` and the two move together, so
  the copy can only rot). **Verified the gate still bites** afterwards: removing
  `packages/elm-m3e/config/slots.json` -> RED naming the file; restored -> GREEN.

- **D-029 (M6) — the deep clean's deletions authorized in all three copy-fidelity gates, with
  reasons.** M6's removals made `copy-fidelity` go red for elm-m3e, cem-figma-connect and m3e-okf —
  correctly, since those paths ARE git-tracked in the inert source repos and the gates refuse to
  absorb a deletion silently. Authorized by listing the paths EXPLICITLY (not by a broad prefix) in
  each script's allowlist, pointing at `docs/facts-bundle/m6-deep-clean.md` for the per-path
  reasoning, so a NEW unexplained deletion still goes red. **Verified each still bites afterwards:**
  removing `packages/cem-figma-connect/src/cli.mjs` -> RED naming the file; restored -> GREEN.
- **D-030 (M6) — manager fixed the dangling references the critic found.** The critic passed M6 but
  named four now-false claims left behind by the sweep: `elm-cem/RELEASE-CHECKLIST.md:31` and
  `skills/releasing-elm-cem/evals.json:10` still asserted the deleted `native-manifest-gen/` harness
  exists and is pack-excluded, `src/visual/harness/README.md` pointed at the deleted spike tree, and
  the manifest's own headline count said 126 when 127 paths were removed. My brief had said
  "docs that are now factually WRONG are worse than cruft", so I corrected all four rather than
  leaving them; `evals.json` re-validated as JSON afterwards.

- **SPIKE (post-Phase-0, human-requested) — the elm-m3e package boundary is MEASURED; both prior
  claims were wrong.** `docs/superpowers/spikes/2026-08-13-elm-package-boundary-spike.md`.
  The registry cap is **768,000 bytes of UNCOMPRESSED `docs.json`**, a literal in
  `elm/package.elm-lang.org` `src/backend/Package/Register.hs` (the bound is applied upstream of the
  gzipper, so it is pre-compression). The critic cloned that repo and `elm/compiler` itself and
  reproduced every number **exactly to the byte**.
  - **Claim B (liaison: "a monolith is registry-faithful today") is WRONG on the number:** the
    monolith emits **1,450,795 B = 189% of cap**.
  - **Claim A (the split exists for the size limit) is right that a ceiling exists, but does NOT
    vindicate the current split:** `jackhp95/elm-m3e-builder` ALONE is **810,420 B = 105.5% of cap**,
    and **two of the three split packages do not compile at all** — the declared
    `core <- components <- builder` DAG is contradicted by two back-edges (130 barrel imports of
    `M3e.Component`, 130 component files importing `M3e.Build.Internal`, which is not exposed), so
    it is a *labelling of one mutually-recursive module graph*, not a partition. All three dirs also
    lack `README.md`/`LICENSE` and would fail publish before ever reaching the cap.
  - **A valid cut exists and is measured:** primitives + `M3e.Component.*` = **640,376 B (83.4%)`,
    leaving `M3e.Build.*` to be divided again. Bytes are wildly non-uniform (`M3e.Values` alone is
    94,865 B, 45x the median), so any re-cut must be validated by re-running the harness, never by
    counting modules.
  - **Publish pipeline:** verified against `elm/compiler` `terminal/src/Publish.hs`. Non-obvious
    correction to the common assumption — **there is NO `origin` remote inspection**; resolution is
    from the `elm.json` NAME and the git checks are purely local. The **mirror step is forced
    regardless of folder depth** (the zipball must carry `elm.json` at top level), so **dev-folder
    layout is ERGONOMICS, not necessity**.
  - **Recommendation (ergonomic, not forced):** one folder per published package, and stop keeping a
    fourth merged tree — the 402-file/278-differing drift between `packages/elm-m3e/src/` and the
    split trees is a direct cost of maintaining two layouts for the same generated code.
  - **`elm-m3e-icons` is ABSENT** from this workspace (the upstream split postdates the `0cd7f486`
    snapshot). A future fourth package argues for a layout that scales to N.
  - **Stated open questions (honest, and one is material):** no end-to-end publish was performed, so
    the 400-at-cap is inferred from server source rather than observed; `768000` was read from
    `master` and whether the deployed registry runs `master` is unverified; and **which source tree
    is canonical was not determined — a 15% / 220,553-byte swing in the headline figure.**
  **This does not change Phase 0** (which deliberately touched no boundaries); it is the
  verify-then-decide input Phase 5 was waiting on.
- **R-020 (post-Phase-0) — the workspace is NOT PORTABLE yet; a fresh clone is partially red.**
  Tested by actually cloning: `pnpm install` works out of the box (7.8s), the producer generates and
  schema-validates, all three bundle copies are byte-identical, and cem-figma-connect + tailwind
  regenerate byte-identical. **Two gaps:** (1) `packages/m3e-okf` drifts because its `.cache/m3e`
  TypeScript checkout (the documented `:host` display exception) is absent in a clone — needs a
  bootstrap step or a skip-when-absent; (2) **six gates default to absolute sibling paths**
  (`/Users/jhp/code/jackhp95/...`) — both A/B harnesses and all four copy-fidelity scripts. They
  passed in my clone ONLY because those siblings exist on this machine; pointed at a nonexistent
  path they fail immediately, so CI on any other machine would be red. Both are env-overridable and
  cheap to fix; neither is fixed yet.

## Progress

- `M1.a: round 1 (gate red: pnpm --filter elm-cem run check — check:gates demands core.hooksPath set
  while the brief demanded it unset; check:neutrality scans the whole monorepo; A/B GREEN throughout;
  strategy: manager-side bar fix — waive hooks#core.hooksPath per elm-cem's own mechanism, scope
  neutrality to the package dir; builder claude/sonnet, loop cb0508c4, 4 iterations)`

- `M0.a: pass (gate \`pnpm install && pnpm run gate\` + 5 verify-checks green, critic VERDICT: PASS,
  builder claude/sonnet, critic claude/opus, loop 955dfbd8, 1 iteration, 0 escalations)`
- `M0.b: pass (convention D-003 recorded pre-build; critic verified item 4 — a probe package is
  publishable as it sits, zero monorepo state in any published artifact — with R-001 recorded as an
  explicit stated limitation rather than glossed as a pass)`
- `M0: integrated (whole-milestone gate green: pnpm install exit 0; pnpm run gate GATE GREEN;
  probe.js compiled and contains probeAnswer; tasks enumerates both graphs; git diff HEAD empty —
  no pre-existing tracked file touched; untracked set == the 12 authorized files exactly)`
- `M1.a: round 2 (all 10 functional checks GREEN — check:gates, check:neutrality, A/B, elm-cem
  test suite, registry-check, all four source repos clean; failed ONLY on the integrity check,
  which fired on the manager's own uncommitted 33-line D-008 ledger edit, not on any builder
  change; strategy: see D-009; builder claude/sonnet, loop 22ce4a1c, 4 iterations)`
- `M1.a: pass (11/11 verify-checks green — A/B 143 files byte-identical, elm-cem check+test green,
  registry-check green, all four source repos clean; critic VERDICT: PASS, builder claude/sonnet,
  critic claude/opus, loops cb0508c4 -> 22ce4a1c -> 2b036ac6, 3 rounds, 0 model escalations —
  both earlier rounds failed on manager-authored bar defects D-008/D-009, never on builder work)`
- `M1.a critic evidence: copy faithful by recursive diff (294/294, 74/74, 49/49, 79/78 files — the
  one delta is a gitignored docs.json build artifact); exactly 5 differences, all authorized;
  neutrality gate proven to still bite (injected token -> RED, restored -> GREEN, 295 files scanned,
  all package-relative); waiver has exactly 1 key; A/B harness proven to discriminate (mutated a
  live emitter literal -> RED); R-001 CONFIRMED RESOLVED IN-WORKSPACE (symlink-spy shows staging
  from packages/elm-cem/facts/src and packages/elm-html-intermediate-representation/src, with the
  old-sibling fallbacks unreachable)`
- `M1.b: pass (gate node tools/check-coverage-map.mjs green — 145 entries, 131 mapped / 14 exception,
  per-consumer 53/12/39/41; critic VERDICT: PASS as the designated gate, builder claude/opus,
  critic claude/opus, loop af5385dd, 1 iteration, 0 escalations)`
- `M1.b critic evidence: independently re-derived the field set from all five consumer files and
  found 0 missing (incl. indirect reads via destructuring/helpers/3-call-deep defaults); ~55
  citations spot-checked, 55/55 field-claims correct; both pre-flagged high-risk items verified
  CONCRETELY not accepted (.d.ts open-union handled as kind:string + enum.open:true + values, the
  only representation serving both consumers; README-drift provenance implementable on the bundle,
  cross-checked against m3e-okf's own data: cem=525 ts=19 readme=0); every Face-C claim verified
  line-by-line against packages/elm-cem (all exact); no fabricated coverage — pipeSetters is
  forward-looking schema referenced by NO mapped entry, so the checker was not gamed; checker
  proven to bite 5/5 on mutated copies`
- `M1.b: ANSWER TO THE LINCHPIN QUESTION — YES. All four consumers can fully drop their own CEM
  parsers on the specified bundle. Schema recorded at docs/facts-bundle/schema.json (draft-07,
  Face B + Face C separated, provenance stamps on both faces, userland seams correctly excluded).`
- `M1.c: pass (9/9 verify-checks green + manager-verified real bundle; critic VERDICT: PASS on
  iteration 3 after FAILing iterations 1-2 for non-implementation; builder claude/sonnet,
  critic claude/opus, loop aaf6bfe3, 3 iterations, 0 model escalations)`
- `M1.c manager verification (independent of the loop): generated a REAL bundle from elm-m3e's exact
  config -> Face B 130 components / 583 attributes, Face C 130 components; Face A UNPERTURBED at
  exactly 143 files; .d.ts resolution genuinely working (124 attributes carry resolved enum value
  sets, e.g. m3e-button.variant = elevated,filled,tonal,outlined,text); the high-risk OPEN-union
  case is correct (m3e-button.target = _self,_blank,_parent,_top with open=true, 14 open unions
  carrying values); validator accepts both real faces and rejects all 5 corruptions with precise
  messages (missing provenance, wrong type, missing required, unexpected property, faceC provenance)`
- `M1.c: Face C tells the TRUTH per R-005 — finalizer is "toElement" (130 surfaces), NOT the
  measured-wrong "build"; surfaces are the real Build/Html/Record/Standard set, not the fictional
  per-facet path convention; m3e-button -> module M3e.Button, actionModule M3e.Action, 4 surfaces`
- `M1.c: R-004 DECIDED — option (b), derive.mjs keeps its own manifest read as a documented
  exception (coverage-audit.md section 11 + 2 coverage-map entries). Rationale: the 190 --md-sys-*
  fallbacks live in five kind:"variable" declarations that register no custom element, so they are
  outside Face B's "one entry per authoritatively-tagged custom element" contract by construction,
  not merely omitted; widening the shared schema for one reader of a non-element fact is the exact
  anti-pattern the audit warns against. Verified non-regression: cem-figma-connect check:tokens
  reads the manifest directly today and still will.`
- `M1.d: round 1 (loop 305d0761 reported succeeded on iteration 4, but manager verification found a
  live cross-package regression the bar never covered — elm-typed-html check:review MODULE NOT FOUND;
  critic had correctly failed iterations 1-3, incl. catching a checker that missed a symlinked
  duplicate; NOT accepted as pass; strategy: see D-011, integrator fixes the seam + builds a
  workspace-wide gate; builder claude/sonnet, 4 iterations)`
- `M1.d: pass (after the D-011 seam fix landed in the M1 integrator pass — exactly one Cem.Facts in
  the graph, elm-review-cem 280 tests green, registry-check stages the declared facts dep from
  inside packages/, all 22 rule tests verified byte-identical after the move; builder claude/sonnet,
  critic claude/opus, loop 305d0761)`
- `M1: integrated (whole-milestone gate green — loop f2461234, integrator claude/opus, critic
  claude/opus, 1 iteration, VERDICT: PASS)`
- `M1 integrator deliverables: (1) fixed the D-011 seam with ONE line — added
  "../../elm-cem/facts/src" to packages/elm-typed-html/review/elm.json's source-directories, the
  D-003 rule-4 application-layer convention, no re-vendoring and no symlink; (2) built
  tools/gate-all.mjs (root script gate:all), the workspace-wide gate that DISCOVERS packages via
  pnpm ls -r rather than hardcoding, runs every package check+test plus the cross-cutting checks,
  and runs a REAL end-to-end bundle generate+validate so it cannot pass vacuously; it reports all
  failures rather than stopping at the first`
- `M1 manager verification (independent): gate-all 12/12 GREEN. Proved it BITES on two distinct
  failures — (1) reintroduced a duplicate Cem/Facts.elm -> 4 items RED incl. check-single-cem-facts;
  (2) removed the facts source-directories line from elm-typed-html/review/elm.json -> 11/12,
  FAIL elm-typed-html: check. Test (2) is EXACTLY the D-011 regression that previously slipped
  through a green loop, so the structural fix is proven against the real failure it was built for.
  Tree restored byte-clean after both tests; gate-all GREEN again.`
- `M1: LINCHPIN CLEARED. One producer emits a schema-valid, provenance-stamped facts bundle
  (Face B 130 components / 583 attributes, Face C 130 components); Face A byte-unperturbed at 143
  files; exactly one Cem.Facts in the graph. All four consumers are cleared to drop their parsers
  in M3.`
- `M2.a: round 1 (loop 7238608b, 5 iterations, all red on gate-all; tree left green 15/15 but
  manager verification found a dropped tracked file — editor/stub/Cem/Facts.elm — and 7747 copied
  build artifacts; NOT accepted; strategy: see D-014, restore + make the checker precise + add a
  copy-fidelity check to the bar; builder claude/sonnet)`
- `M2.a: escalated claude/sonnet -> claude/opus (checker-precision judgment call; D-014)`
- `M2.a: round 2 (loop 001ee161, builder claude/opus, 5 iterations, 4 red on gate-all + 1 on
  copy-fidelity; BOTH failing checks were manager-authored defects — see D-015 and D-016 — not
  builder error. Substantive repair landed correctly: editor/stub/Cem/Facts.elm restored
  byte-identical, check-single-cem-facts narrowed, .gitignore updated)`
- `M2.a: pass (10/10 fast-bar checks green, critic VERDICT: PASS — loop fb54fe1a, builder
  claude/sonnet, critic claude/opus, 1 iteration after the bar was corrected per D-015/D-016)`
- `M2.a critic evidence: copy fidelity re-derived independently — 6 missing, exactly the 6
  authorized lockfile/workspace paths, editor stub present and byte-identical; the 383 untracked
  on-disk files traced to LOCAL builds (different vite hashes + 2026-08-13 mtimes vs source
  2026-08-08), all gitignored, 0 committed. Narrowed checker proven on all 3 probes: re-vendored
  copy -> RED with 6 problems incl. 5 per-graph clash reports; second exposer -> RED; editor stub
  GREEN by REACHABILITY (permitted only when reached solely from application elm.json roots), not
  by path or name. Both A/B harnesses proven to discriminate with LIVE emitter mutations
  (Emit.elm:4468 -> RED naming M3e/Kind.elm; split.js:240 -> RED naming the package READMEs);
  ab-elm-cem 143 files, ab-elm-m3e-split 152 files, both defaulting to the IN-WORKSPACE elm-m3e.
  Generated output byte-identical to the source checkout across src/ and all three split trees.`
- `M2: integrated (gate-all 16/16 GREEN after the manager wired tools/copy-fidelity-elm-m3e.sh into
  the sweep — the critic correctly flagged that M2's central new protection only ran by hand)`
- `M3.a: round 1 (loop 626e2b15, 5 iterations, all red on cem-figma-connect test — which passes
  standalone in 9s/698 tests; the real defects were found by manager inspection, not by the bar:
  @m3e/web version skew 2.7.0 vs 2.7.3, and an untracked unregenerable bundle. NOT accepted.
  The main prize DID land: elm-facts.build.mjs (~995 lines) and elm-facts.json deleted, and a
  10KB correction doc written. Strategy: see D-018; builder claude/sonnet)`
- `M3.a: pass (10/10 round-2 checks green, critic VERDICT: PASS — loop c76a24e9, builder
  claude/sonnet, critic claude/opus, 1 iteration; gate-all 22/22 GREEN)`
- `M3.a delivered: cem-figma-connect reads the bundle. DELETED the ~995-line re-parser
  profiles/m3-kit/emitters/elm-facts.build.mjs + its committed elm-facts.json + the vendored CEM and
  tailwind fixtures. src/ingest/cem.mjs reads Face B (.d.ts-resolved, so dts-inline re-derivation is
  gone); profiles/m3-kit/emitters/elm.mjs reads Face C. 698 tests pass. Emitted-output changes are
  enumerated and justified as CORRECTIONS in docs/facts-bundle/m3a-generated-diff.md (per R-005).`
- `M3.a: ONE @m3e/web PIN ACHIEVED (D-018 fix) — cem-figma-connect moved 2.7.0 -> 2.7.3, matching
  elm-m3e. tools/check-single-m3e-web-pin.mjs enforces it and is PROVEN to bite on both failure
  modes: a second distinct version -> RED, and a caret RANGE -> RED. This closes the spec §2
  "four different pins in two version clusters" defect for the two packages migrated so far.`
- `M3.a: bundle delivery is now REPRODUCIBLE AND POLICED (D-018 fix) — the facts bundle is
  git-tracked in the consumer, regenerable via packages/cem-figma-connect/scripts/gen-facts.mjs
  against the WORKSPACE producer, and tools/check-bundle-provenance.mjs regenerates into a temp dir
  and asserts byte-identity with the committed copy. PROVEN to bite: tampering one component tag ->
  RED with a diff. This is spec section 9 drift-gate semantics applied to one consumer, and it
  prefigures M4.`
- `M3.b: round 1 (loop 0d5bba04, 4 iterations; iteration 1 passed all 11 checks but critic
  VERDICT: FAIL on a real content regression — chips.primaryTag m3e-chip -> m3e-assist-chip,
  shipped into skills/m3e/SKILL.md:65 — plus 2 unenumerated diff classes the doc denied;
  iterations 2-4 red on the manager's isolation check via R-008. NOT accepted. Strategy: D-019/D-020;
  builder claude/sonnet, critic claude/opus)`
- `M3.b: pass (11/11 checks green, critic VERDICT: PASS — loop facc292a, builder claude/sonnet,
  critic claude/opus, 1 iteration after the D-019 regression brief)`
- `M3.b delivered: m3e-okf (package m3e-docs) reads Face B. DELETED its hand-ported
  reconcileTagNames and its TypeScript alias scanner — Face B's tagReconciliation and aliases are
  now the single source. The README-drift audit survives as a thin layer over the bundle and its
  finding counts are IDENTICAL to baseline (CEM-TAG-MISMATCH 3, DEFAULT-MISMATCH 13,
  DEFAULT-UNDOCUMENTED 43, EXAMPLE-DRIFT 1, UNDOCUMENTED 46), which proves the quote-preserving
  verbatim-default comparison did not silently break. 33 tests pass. data/sources.json's old
  matraic/m3e SHA no longer drives behaviour — it derives from the bundle provenance stamp.`
- `M3.b: D-019 regression FIXED AT SOURCE. primaryTagOf() replaced the fragile positional fallback
  (elements[0]) with a meaningful, ordering-robust rule: exact m3e-<dir> match, else the
  alphabetically-first ROOT element (one whose superclass is not another element in the set).
  Verified independently: all 55 primaryTags match baseline, 0 mismatches; SKILL.md:65 is back to
  "m3e-chip +7" BY REGENERATION, not by hand-edit. Null-key classes now match baseline exactly
  (default:null 0 vs 0, description:null 0 vs 0, was 254 and 12).`
- `M3.c: work complete but loop HUNG (R-011) — loop 411c8a28 stopped manually after 4h22m in one
  iteration with no writes for 3h; all 6 bar checks verified green by the manager afterwards.
  Critic verdict pending in a separate pass.`
- `M3.c: pass (bar verified green by the manager after the R-011 hang; covered by the M3 integrator
  critic pass — loop 68e72f9b, VERDICT: PASS)`
- `M3: integrated (loop 68e72f9b, integrator claude/opus, critic claude/opus, 1 iteration,
  VERDICT: PASS; gate-all 29/29 GREEN)`
- `M3 critic evidence: ALL FOUR original parsers confirmed gone, and every remaining CEM read in the
  workspace enumerated and classified (producer + its tests; argv INVOKING the producer; four
  documented exceptions; two genuine leftovers -> R-012). THE KEY CHECK: all three consumer bundle
  copies share ONE sha256 (2e227c21...ff9d3274, 2630228 bytes each, cmp silent both ways) AND each is
  byte-identical to a fresh regeneration from the producer — so there is no silent vintage drift
  behind the green gates. gate-all inventory covers all three consumers, all three bundle-provenance
  checks, and all four copy-fidelity checks.`
- `M3: FOUR-PARSER PROBLEM SOLVED (with two named exceptions). One producer, one @m3e/web pin
  (2.7.3, exact, 4 declarations), one bundle vintage read by three consumers. Deleted across M3:
  cem-figma-connect's ~995-line elm-facts.build.mjs + elm-facts.json + vendored CEM/tailwind
  fixtures; m3e-okf's reconcileTagNames + TS alias scanner; tailwind's CEM parse.`
- `M4.b: round 2 (loop e5989c22, 4 iterations, all red on gate-all — D-024, my bar defect, not the
  work). The HOLE IS CLOSED: check-drift now regenerates and byte-compares each consumer's OUTPUT,
  not just its bundle copy. Manager-verified all three bite, each naming the offending file:
  tailwind generated/utilities.css -> RED; cem-figma-connect generated/m3-kit/elm/MANIFEST.json ->
  RED; m3e-okf data/components.json -> RED. Clean tree -> GREEN, gate-all 30/30.`
- `M4.a: pass (bump is one gated command and IDEMPOTENT — clean tree, exit 0, zero files changed;
  runs the full tools/gate-all.mjs rather than a subset; a red gate exits nonzero; zero executable
  push/publish/tag hits, the only match is a prose comment saying it never does)`
- `M4.b: pass (cross-cutting drift gate; D-023 hole CLOSED — consumer OUTPUT is regenerated and
  byte-compared, not just bundle copies)`
- `M4: integrated (loop 2ab5dd25, critic claude/opus, 1 iteration, VERDICT: PASS; gate-all 30/30,
  check-drift 9/9, check-drift.test 11/11)`
- `M4 critic evidence: all THREE consumers proven to bite on the REAL committed artifacts, each
  naming the exact offending file — tailwind generated/utilities.css; cem-figma-connect
  generated/m3-kit/elm/m3e-badge-badges-elm.figma.ts (names the file INSIDE the directory); m3e-okf
  data/components.json caught from a SINGLE TRAILING NEWLINE, the weakest possible perturbation.
  Closed by widening, not narrowing: raw Buffer.equals plus only-on-one-side reporting, with
  exclude/symlink options applying to the rsync INPUT copy and never to compared outputs.
  Non-destructive: regeneration happens in a mkdtemp rsync copy; git status empty after every probe.
  Nothing deleted across the whole M4 range (git diff --diff-filter=D returns nothing).`
- `M5.a: pass (loop 8bb4afcf reported 4 red iterations on a check that passes standalone — R-019;
  substance verified by the manager and by the M5 critic. gate-all 30/30 GREEN.)`
- `M5 delivered: DELETED packages/elm-m3e/docs/vendor/tailwind-m3e-web/ (vendored tailwind CSS copy,
  superseded by the co-located real package) and
  packages/cem-figma-connect/test/fixtures/tailwind-m3e-web-0.1.0/ (the DIVERGED fixture, R-015).
  src/tokens/resolve-palette.mjs was REPOINTED at the real packages/tailwind-m3e-web sources rather
  than losing its input — the fixture was a production input, not just test data, which is why the
  bar caught its removal. NO test was deleted anywhere.`
- `M5 judgment calls, both decided and RECORDED (silence would have been a fail):
  (A) R-013 dts-inline.mjs KEPT — it is unused by the pipeline but still unit-tested, and the M3.a
  migration had already made a deliberate documented decision to keep it; deleting it would have
  meant deleting its tests against that prior judgment. (B) R-012 both leftover CEM readers kept as
  DOCUMENTED EXCEPTIONS with substantive reasons: render-verify.mjs must read the manifest THE SAME
  BUILD PRODUCED or it could not catch the tree-shaking/stale-build/registration-guard bugs it
  exists for; oracle.mjs needs raw TS type strings and exports/declarations set-equality that Face
  B's distilled shape does not carry, with a stated revisit condition if the schema is extended.`
- `M6.a: pass (loop 5bbeae9b, builder claude/sonnet, critic claude/opus, 2 iterations — iteration 1
  correctly red on the manifest check, which is the non-vacuous check preflight was added to
  guarantee. VERDICT: PASS.)`
- `M6 delivered: 127 paths removed, 8 modified, 1 added, across five packages — the 35-file
  native-manifest-gen spike, the 33-file research/spikes tree, 10 skill files, 10 .claude-memory
  files and ~37 plans/handoff/status docs. Manifest at docs/facts-bundle/m6-deep-clean.md.`
- `M6 critic evidence (the gates were only the FLOOR here — deleting the unique explanation of a
  mechanism breaks nothing detectable): sampled NINE removed docs across four packages and chased
  each one's distinctive terms into the live tree, naming where the knowledge survives in every
  case. Only two deleted files were tests, both spike-local, and their behaviour is now covered by
  src/visual/harness/selfcheck.mjs (3 renders per component in separate subprocesses, sha256
  compared), wired as check:render. Enumerated all 127 deletions against the manifest: zero
  unaccounted paths. The "kept in doubt" section is substantive (9 flagged keeps) plus a candid
  false-positive-correction section, and the sweep visibly restored 14 files after re-verification —
  the correct failure direction for this rule.`
- `M6: the manager's own native-manifest-gen concern was DISPROVED by the critic with evidence —
  data/native-attrs.json is a 26-line HAND-CURATED table, not derived from the deleted WHATWG data;
  elm-typed-html/manifest/native.cem.json is a separately committed curated input; and no script
  reads any deleted whatwg-*.json. The load-bearing conclusion survives in
  elm-typed-html/scripts/check-whatwg.mjs:244-258 and elm-cem/codegen/Attr.elm:35-55,955-975.`
- `M6: integrated (gate-all 30/30 GREEN after the deep clean; A/B still 143 byte-identical files)`

---

# PHASE 0.5 — portability (Move 1) and the Elm package re-cut (Move 2)

Manager: Opus (Gauntlet Loop on Paseo), taking over at `9900b33` with Phase 0 complete and
`node tools/gate-all.mjs` 30/30 green on this machine. Next free IDs at takeover: D-031, R-021.

## Decisions and risks

- **R-021 (Move 1 baseline) — R-020 UNDERSTATES the problem: a fresh clone is 24/30, not 28/30,
  and the six sibling-path gates are NOT among the failures.** I re-ran the R-020 experiment
  properly — `git clone` to `/tmp/m1-clone/ws`, `pnpm install` (exit 0), `node tools/gate-all.mjs`
  — and got **24/30 with SIX failed items**, from **five distinct causes**, only one of which
  R-020 names:
  1. **`elm-cem: test`** — `packages/elm-cem/tests/elm.json` pins `elm-explorations/test 2.2.0`,
     while `elm-test-rs`'s injected `mpizenberg/elm-test-runner 4.0.4` requires
     `1.0.0 <= v < 2.0.0`. Unsatisfiable on a cold solve. It passes on this machine ONLY because
     `packages/elm-cem/tests/elm-stuff/` (gitignored) holds a previously-solved plan.
  2. **`elm-m3e: check`** — `check:nav` reads `packages/elm-m3e/docs/data/reference.json`, a
     GENERATED, gitignored artifact. `ENOENT` in a clone. No bootstrap step produces it.
  3. **`elm-m3e: test`** — `test:browser`'s Playwright `config.webServer` cannot start, for the
     same reason: the docs site's generated inputs are absent.
  4. **`elm-review-cem: check` and `test`** — `check:review` runs
     `elm-review --compiler node_modules/.bin/elm`, a PACKAGE-LOCAL path. On this machine
     `packages/elm-review-cem/node_modules/.bin/elm` exists as a leftover symlink from the
     pre-migration checkout; in a clone that directory holds only `elm-review` and `elm-tooling`,
     so elm-review reports `ELM NOT FOUND`. The workspace's real compiler is at the ROOT
     `node_modules/.bin/elm`.
  5. **`check-drift`** — the `packages/m3e-okf/.cache/m3e` gap, i.e. R-020 item (1). Confirmed.
  **The six absolute-sibling-path gates all PASSED in the clone** — because their hardcoded
  defaults `/Users/jhp/code/jackhp95/...` still resolve on this machine no matter where the clone
  lives. R-020 item (2) is therefore real but was never actually exercised by R-020's experiment;
  it is a latent CI failure, not an observed one. Every one of these five causes is the same
  species: **a gate depending on local, gitignored, or machine-global state that a clone lacks.**

- **D-031 (Move 2, canonical source tree) — the spike's material open question is ANSWERED, and
  the answer is NEITHER of the two candidates it offered.** The spike asked whether
  `packages/elm-m3e/src/` or the three split trees is canonical (a 220,553-byte / 15% swing).
  I measured the third possibility it did not consider: **what the workspace generator emits
  today.** Running elm-cem with elm-m3e's exact committed config into a scratch dir:
  - fresh generation = **143 `.elm` files**; both committed trees = **402 files**;
  - and the ARCHITECTURE differs, not just the content. Fresh output is a flat
    `M3e.<Component>` namespace (139 modules directly under `M3e/`, plus `M3e.elm`,
    `M3e.Build`, `M3e.Build.Internal`, `M3e.Review.Facts`, `M3e.Unsafe.*`). The committed trees
    are the superseded shape: `M3e/Build/*` (131) + `M3e/Component/*` (130) +
    `M3e/Internal/Types/*` (130) + 8 primitives.
  This independently confirms R-005, recorded at M1.b: *"the per-facet `src/M3e/<Facet>/<Comp>.elm`
  path convention is fiction — elm-cem emits one compModule plus a brand-wide `M3e.Html`/`M3e.Build`."*
  **Decision: the GENERATOR is canonical, and its current 143-module output is the one true output
  shape.** Derived from the family's standing rule (*"generated code is the specification; never
  hand-edit an emitted file — change source/config and regenerate"*), from the spike's own §6.2
  recommendation (*"the generator should own exactly one output shape"*), and from the fact that a
  tree no generator can reproduce can never be covered by the M4 drift gate. Both committed
  402-file trees are output of a superseded generator architecture that nothing in this workspace
  regenerates. Revert by declaring one of the committed trees canonical and pinning the generator
  back — but note that no such generator exists in the workspace.
  **CONSEQUENCE, and why this goes to the human rather than straight into a re-cut:** adopting the
  canonical answer replaces the entire published module surface. `M3e.Build.Button` and
  `M3e.Component.Accordion` cease to exist; `M3e.Button` and `M3e.Accordion` replace them. That is
  a total breaking change to the published Elm API — a product decision, not a mechanical one —
  and D-012 explicitly recorded that Phase 0 never authorized refreshing this output. The Move 2
  brief anticipated a re-cut might change generated Elm and said to **report it, not absorb it**.
  Reported. See the Move 2 measurements below.

- **D-031a (Move 2 measurements — the re-cut, measured on the CANONICAL tree).** Re-ran the
  spike's harness method (`elm make --docs docs.json` with the pinned
  `node_modules/.bin/elm`, workspace deps vendored unexposed so they contribute zero bytes)
  against the 143-module canonical tree. Cap = 768,000 B hard; the project's self-imposed gate is
  700,000 B.
  - **Full canonical surface (142 exposed, all but `M3e.Build.Internal`) = 1,342,855 B = 174.9% of
    cap.** A split is still required — but every byte figure in the spike measured the STALE trees.
  - Byte distribution is even more concentrated than the spike found: the 130 per-component
    modules are **1,142,021 B (85%)**; primitives 161,740 B; the `M3e` barrel 38,078 B;
    `M3e.Build` 873 B. Largest single modules: `M3e.Values` 94,244 · `M3e.Html` 50,077 ·
    `M3e.Attributes` 48,559 · `M3e` 38,078 · `M3e.Button` 19,848.
  - The spike's `Build` vs `Component` seam **no longer exists** in the canonical tree — that was
    an artifact of the superseded architecture. A cut must partition the flat component namespace.
  - **A measured, compiling 3-way cut that fits with margin** (greedy byte-balanced partition of
    the components, primitives kept upstream, the all-importing `M3e` barrel placed downstream):
    | Package | Exposed | `docs.json` | % hard cap | % 700k gate |
    |---|---:|---:|---:|---:|
    | primitives + `M3e.Html` + `M3e.Build` | 10 | **212,701 B** | 27.7% | 30.4% |
    | components group A | 66 | **546,081 B** | 71.1% | 78.0% |
    | components group B + `M3e` barrel | 66 | **584,075 B** | 76.1% | 83.4% |
    All three compile (exit 0). Group membership recorded at `/tmp/m2-cut-groups.json` during
    measurement; it must be regenerated and committed if this cut is adopted.
  - **2 packages is NOT reachable**: the best 2-way cut is 758,781 B (98.8% of hard cap, 108.4% of
    the 700k gate) + 584,075 B. Under the hard cap by 9,219 B, but over the project's own gate and
    with no room for a single new component. **3 is the answer**, same conclusion as the spike but
    for a different tree and a different seam.
  - Not yet done, pending the D-031 decision: no `README.md`/`LICENSE` exist for any package, the
    cut is not committed, and no standalone-compile/size gate is wired.

- **R-022 (Move 1, root cause of R-021 items 1 and 4) — the workspace has NEVER built with its own
  declared Elm toolchain; stale package-local binaries have been covering for a wrong root pin.**
  Chasing why `elm-cem: test` fails in a clone but passes here, I first assumed a cached
  `tests/elm-stuff/` solve. **That hypothesis was wrong** — I copied this machine's `elm-stuff` into
  the clone and the failure was identical. The real difference is the *binaries*:
  | | `elm-format` | `elm-test-rs` |
  |---|---|---|
  | workspace ROOT `elm-tooling.json` | **0.8.7** | **1.0.0** |
  | `packages/elm-cem/elm-tooling.json` | 0.8.8 | 3.0.0 |
  | `packages/elm-review-cem/elm-tooling.json` | 0.8.8 | 3.0.0 |
  | `packages/elm-html-intermediate-representation/elm-tooling.json` | 0.8.7 | 3.0.0 |
  | `packages/elm-typed-html/elm-tooling.json` | 0.8.7 | — |
  On this machine `packages/elm-cem/node_modules/.bin/` holds symlinks to **elm-test-rs 3.0.0** and
  **elm-format 0.8.8**, dated `Aug 12 17:06` — leftovers from the pre-migration checkouts, created
  when each source repo ran its own `elm-tooling install`. They shadow the root and make everything
  green. A clone has only the ROOT pins, so it gets `elm-test-rs 1.0.0`, whose bundled
  `mpizenberg/elm-test-runner 4.0.4` requires `elm-explorations/test 1.0.0 <= v < 2.0.0` while
  `packages/elm-cem/tests/elm.json` pins `2.2.0` — unsatisfiable, hence R-021 item 1.
  **`elm-test-rs 1.0.0` is wanted by NO package in the workspace.** The root pin is simply wrong.
  This directly violates **D-003 rule 5** (*"The Elm toolchain is pinned at the workspace root ...
  so every package builds with the same elm/elm-format/elm-test-rs"*): the rule was written, the
  root file was created with the wrong versions, and no gate ever noticed because the stale
  per-package binaries silently supplied the right ones.
  Same mechanism explains R-021 item 4: `elm-review-cem`'s `check:review` and `test:elm` pass
  `--compiler node_modules/.bin/elm`, a PACKAGE-LOCAL path that exists here only as an Aug-12
  leftover symlink and is absent in a clone.
  **Unresolved sub-question for the fix:** `elm-format` is genuinely inconsistent ACROSS packages
  (0.8.8 for elm-cem/elm-review-cem, 0.8.7 for IR/elm-typed-html). A single root pin cannot serve
  both if the two versions disagree on any formatting, so the fix must either run
  `elm-tooling install` per package (reproducing today's working state deterministically, and
  respecting each package's own pin) or unify the version and prove all four `check:format` gates
  still pass. **Do not resolve it by relaxing a format check.**

- **D-031b (Move 2) — the proposed 3-way cut is a CLEAN DAG, and the components are fully
  independent.** The previous split died on two back-edges (130 barrel imports of `M3e.Component`,
  130 component files importing the unexposed `M3e.Build.Internal`) — it was a labelling of one
  mutually-recursive graph, not a partition. I built the import graph of the canonical 143-module
  tree and mapped it onto the measured cut:
  - **Cross-package edges: `P3 -> P2`, `P3 -> P1`, `P2 -> P1`. Nothing else. No back-edge, no cycle.**
  - **component -> component imports: ZERO.** The 130 per-component modules do not reference each
    other at all; each depends only on the primitives.
  Two consequences. First, the canonical tree is *genuinely partitionable*, unlike the committed
  split — the acyclicity is a property of the generator's flat namespace, not of a lucky grouping.
  Second, because no component imports another, **any** partition of the components is legal, so
  the split can be chosen purely to balance bytes. The greedy byte-balanced grouping recorded in
  D-031a is therefore not a compromise against structure; it is free.
  Caveat, stated rather than glossed: each surface was compiled from the full source tree with only
  the exposed set varying (the spike's method, which isolates the cap question from the cycle
  question). A true standalone per-package compile — P2 resolving P1 as a real registry dependency
  — has NOT been performed, and remains part of Move 2's acceptance.

- **D-032 (human, hard requirement) — NO `claude-opus-5` agent may ever be spawned; Opus work is
  `claude-opus-4-8` ONLY.** Root cause of the exposure: `~/.paseo/orchestration-preferences.json`
  mapped `ui`/`planning`/`audit` to the bare alias **`claude/opus`**, and `paseo list_models` shows
  `claude-opus-5` carries `isDefault: true` for the claude provider — so the bare alias silently
  resolved to Opus 5. This is the same trap the bootstrap note already warned about ("an omitted
  model silently inherits the most expensive"), except the alias made it invisible.
  **Actions taken:** (1) prefs rewritten to name the model explicitly —
  `ui`/`planning`/`audit` = `claude/claude-opus-4-8`, `impl`/`research` = `claude/sonnet`;
  (2) a HARD REQUIREMENT line added as the FIRST preference, stating that the bare `claude/opus`
  alias must never be used and that `claude-opus-5`/`claude-fable-5` are barred
  (`claude-opus-4-8[1m]` is acceptable); (3) the in-flight M7.a loop `c5dc1ab1` — whose verifier
  had been dispatched as `--verify-model opus`, i.e. Opus 5 — was **STOPPED mid-iteration** and
  relaunched as `43079f1d` with `--verify-model claude-opus-4-8` and `--model claude-sonnet-5`.
  The builder's on-disk work was preserved; nothing was lost. Standing rule for the rest of this
  effort: **every dispatch names the model explicitly by full ID; never an alias.**
  Revert by restoring the `claude/opus` mappings, but note that doing so re-enables Opus 5.
  Not fixable by me: the MANAGER agent in this session is itself Opus 5 and cannot change its own
  model mid-session — that needs `/model` or a fresh session.

- **D-031c (Move 2, canonical tree — DECIDED AUTONOMOUSLY, superseding the escalation in D-031).**
  I escalated the canonical-tree question to the human. That was **over-escalation and my error**:
  the Human-Gate Policy says to escalate only if the answer is *not derivable*, and it is derivable
  three times over — (a) the standing family rule *"generated code is the specification; never
  hand-edit an emitted file, change source/config and regenerate"*, (b) the spike's own §6.2
  recommendation *"the generator should own exactly one output shape"*, and (c) D-012, which framed
  the freeze explicitly as a Phase-0 scoping decision to be revisited later — and Move 2 IS later.
  A fourth fact removes the remaining doubt: **nothing has ever been published.** `git tag` = 0,
  `git remote` = 0, and `package.elm-lang.org/packages/jackhp95/elm-m3e/releases.json` returns
  *does not exist*. There is no external consumer to break, so this is choosing the shape BEFORE
  first publish, not breaking a shipped API. My earlier framing ("renames the entire published
  API") was wrong and is corrected here.
  **DECISION: the generator is canonical, and its current 143-module flat `M3e.<Component>` output
  is the one true output shape.** Both committed 402-file trees are retired as publishable
  candidates. Revert by pinning a generator that emits the 402-file shape — no such generator
  exists in this workspace.
  **The cost is real and is a finding, not a hidden absorption:** 66 in-workspace files import the
  superseded names (`M3e.Build.*` / `M3e.Component.*` / `M3e.Internal.*`) — the docs site
  (`docs/app/**`, `docs/src/**`), the acid and spike test suites (`tests/acid/**`, `tests/spike/**`,
  `tests/tests/**`), and one `elm-review-cem` test. All three elm-m3e Elm applications compile
  against `../src`, so the stale tree is load-bearing today. Move 2 therefore includes migrating
  those 66 files, and the acid tests encode API shape so some of that is real work rather than a
  rename. **No test may be deleted to achieve it** — repoint, per the standing constraint.

- **D-031d (Move 2) — the 66-file migration is 93% mechanical; I overstated its cost in D-031c.**
  Counted the actual import forms across the workspace, excluding the generated trees:
  | Import form | Count | Under the canonical shape |
  |---|---:|---|
  | `import M3e.Component.<X>` | **131** | pure rename -> `import M3e.<X>` |
  | `import M3e.Build` (barrel) | 7 | **survives unchanged** — no edit needed |
  | `import M3e.Build.<X>` | **9** | **no direct successor** — real API work |
  The only genuine work is those 9 imports, concentrated in **seven** files:
  `tests/spike/bad/WrongKindBuilderIntoIconSlot.elm`, `tests/spike/app/ApiConsolidation.elm`,
  `tests/acid/app/Good.elm`, `packages/elm-review-cem/tests/src/PreferBarrelTest.elm`, and three
  docs samples (`CheatSheet/ShapesCode.elm`, `Strictness/ShapesCode.elm`,
  `TheLayers/DescentCode.elm`). `M3e.Build` and `M3e.Build.Internal` both exist in the canonical
  tree; only the per-component `M3e.Build.<X>` modules are gone, their builder API having moved
  into the single `M3e.<X>` module per component.
  So "migrate 66 files" is really "sed 131 imports, then hand-port 7 files whose subject IS the
  builder API." Correcting my own overstatement rather than letting it stand — it was the basis on
  which I called this bigger than the brief scoped, and on the measured numbers that claim is much
  weaker. (`M3e.Internally.Fine` in `NoInternalImportOutsideAllowedTest.elm` is an elm-review
  fixture module name, not a real import — excluded from all counts.)

## Manager handoff — independent verification pass (new manager, `claude-opus-4-8`)

The human handed this off flagging the previous manager (an Opus 5 agent) as "consistently
wrong" and instructed that every claim C1-C9 be re-run from scratch. This session's manager is
`claude-opus-4-8` (so D-032's "the manager is itself Opus 5, cannot self-correct" no longer
applies). Every claim was independently re-run on this machine. **Result: all nine measured
claims HOLD, and the previous manager's fundamental Move 2 framing is CORRECT, not the error.**

- **V-C1 — HOLDS exactly.** Fresh `git clone` of the committed HEAD + `pnpm install` +
  `node tools/gate-all.mjs` = **24/30, 6 failed**, and the six are precisely `elm-cem: test`,
  `elm-m3e: check`, `elm-m3e: test`, `elm-review-cem: check`, `elm-review-cem: test`,
  `workspace: check-drift`. Matches R-021.
- **V-C2 — HOLDS.** In that clone the six absolute-sibling-path gates all PASSED (they are among
  the 24), because the committed hardcoded `/Users/jhp/code/jackhp95/...` defaults still resolve
  on this machine. Latent CI failure, never observed as red. Confirmed.
- **V-C3 (R-022, load-bearing) — HOLDS in full.** Root `elm-tooling.json` pins elm-format 0.8.7 /
  elm-test-rs **1.0.0**; every package wants 3.0.0 (elm-cem/elm-review-cem also want format 0.8.8).
  `packages/elm-cem/node_modules/.bin/` holds `elm-test-rs -> 3.0.0` and `elm-format -> 0.8.8`
  symlinks dated **Aug 12 17:06**; `packages/elm-review-cem/node_modules/.bin/` similarly, plus a
  leftover `elm` symlink dated Aug 12 18:55. Root binaries actually resolve to elm-test-rs **1.0.0**
  / elm-format **0.8.7** (the wrong pins); the package-local resolve to 3.0.0. So a clone gets the
  wrong root pins and `elm-test-rs 1.0.0`'s `mpizenberg/elm-test-runner 4.0.4` (needs
  `elm-explorations/test <2.0.0`) collides with the tests' pinned 2.2.0. Mechanism confirmed exactly.
- **V-C4 — HOLDS.** `packages/elm-m3e/docs/data/reference.json` is git-ignored (736 KB, ENOENT in a
  clone). `packages/m3e-okf/.cache/m3e` is a matraic/m3e checkout at tag **v2.7.3**. elm-review-cem's
  `check:review`/`test:elm` pass `--compiler node_modules/.bin/elm` (package-local; absent in a clone).
- **V-C5 — HOLDS.** Running the committed `gen:src` command (identical flags, only `--output`
  differs) emits **143** flat `M3e.<Component>` `.elm` files; committed `src/` holds **402** in the
  old `M3e/Build/*` + `M3e/Component/*` + `M3e/Internal/Types/*` shape.
- **V-C6 — HOLDS.** Workspace: 0 tags, 0 remotes. `package.elm-lang.org/.../jackhp95/elm-m3e/...`
  → "does not exist". Source repo elm-m3e has a GitHub remote but 0 tags. Nothing ever published.
- **V-C8 — HOLDS.** Built the import graph of the fresh 143-module tree: of the 130 flat component
  modules, **zero** import another component module. Any partition of the components is legal.
- **V-C9 — HOLDS (D-031d's correction confirmed).** Excluding the generated `**/src/**` trees:
  **127** `import M3e.Component.<X>` (mechanical rename), **3** `import M3e.Build` barrel (survive),
  **8** `import M3e.Build.<X>` across 6 files — plus `elm-review-cem/tests/src/PreferBarrelTest.elm`
  (under a `tests/src/` path, excluded by the glob) makes **7 files / ~9** builder-specific imports.
  Within rounding of D-031d (131/7/9). "66 files break" was indeed an overstatement.
- **V-C7 — NOT yet independently re-measured.** The exact `docs.json` byte figures (174.9% of cap,
  the 3-way cut table) require re-running the spike's assemble-and-`elm make --docs` harness; that
  is deferred to Move 2 execution and will be re-derived by an independent critic there. The
  QUALITATIVE conclusion is corroborated (130 components dominate; a single components package
  exceeds cap; a 3-way split is required) but the precise numbers are carried as unverified.

- **FRAMING VERDICT — the generator-is-canonical decision (D-031c) is CORRECT.** I traced the full
  generation topology, which resolves the human's concern that the 402 tree might be regenerable
  and thus wrongly "retired":
  1. `elm-m3e` `gen:src` runs `elm-cem ... --output=src` → the **flat 143-module** tree. Verified:
     re-running it today produces 143, not 402. The committed 402 `src/` is NOT what `gen:src` emits.
  2. `tools/ab-elm-m3e-split.sh` shows the SECOND step: `elm-cem split --packages=packages.json`
     partitions a **fresh** flat tree into the three published packages (core/builder/components)
     via buckets keyed on the FLAT names (`M3e.Build.*`, `M3e.<Component>`). Its byte-identity A/B
     proves the split STEP is unchanged — it splits the 143 tree, never the committed 402.
  3. Therefore BOTH committed layouts — the merged `src/` (402) AND the three committed split trees
     (`elm-m3e/src` 9 + `elm-m3e-builder/src` 132 + `elm-m3e-components/src` 261 = 402) — are the
     old per-component `M3e/Build/*`/`M3e/Component/*` architecture, and NOTHING in the workspace
     regenerates that shape. `gen:src` overwrites `src/` with 143 flat; `gen`+`split` produces the
     143 flat shape partitioned. This independently re-confirms R-005 (M1.b) and D-012 (M2).
  The previous manager WOBBLED on the way to this answer (escalated then reversed D-031c; revised
  the cost D-031d; retracted the "renames the published API" framing) — which is what the human is
  reacting to — but the destination is right. Note this is a decision made BEFORE first publish
  (C6), so it breaks no shipped API; it is choosing the shape, not breaking one.

- **D-033 (Move 1) — the M7.a snapshot-gate portability work (loop 43079f1d) is VERIFIED and
  committed.** The loop passed on iteration 1 (opus-4.8 verifier PASS); per D-023 I did not trust
  the green and re-verified all four points the outgoing manager flagged, on this machine:
  1. **No silent skip here.** All six gates resolve their snapshot dir to
     `$SNAPSHOT_ROOT/<repo>` with `SNAPSHOT_ROOT` defaulting to `$REPO_ROOT/..` = the real siblings
     at `/Users/jhp/code/jackhp95`, so they RUN. Full `node tools/gate-all.mjs` = **30/30 passed,
     0 skipped, 0 failed** with all six showing PASS (not SKIP).
  2. **Gates still bite.** The diff touches ONLY the missing-snapshot guard, never the comparison
     logic; independently re-proved copy-fidelity-elm-m3e bites (remove `config/slots.json` → RED
     naming it → restore → GREEN); the loop's verifier proved ab-elm-cem + copy-fidelity-tailwind.
  3. **gate-all end-to-end 30/30 GREEN** (~350 s) with the new pass|skip|fail summary logic.
  4. **`REQUIRE_SNAPSHOT_GATES=1` hard-fails all six** (exit 1 each); default with a missing
     snapshot SKIPs all six (exit 0, with a WHY message). Tested by pointing `SNAPSHOT_ROOT` at a
     nonexistent dir.
  This closes R-020 item (2) / C2: off-machine the six gates now SKIP-with-reason instead of being
  latently red. Revert with `git revert` of the commit — the six gates return to hardcoded
  absolute defaults. Does NOT fix the five real clone failures (V-C1's six red items) — those are
  the remaining Move 1 work. Next free IDs: **D-034**, **R-023**.

---

# COMPOSE GAUNTLET — branch `compose-poc` (worktree `/Users/jhp/.paseo/worktrees/358ycm5n/compose-poc`)

Isolated effort: implement `docs/superpowers/plans/2026-08-13-compose-implementation.md` (Phase A Tasks 1–7,
Phase B Tasks 8–14). Manager = Opus 4.8 (this context). Builder = `claude/sonnet`. Critic/Integrator =
`claude/claude-opus-4-8`. Entries below are scoped to this branch and do NOT touch main's ledger until a
human merges. Gauntlet part IDs are `A<task>` / `B<task>`.

### Bootstrap decisions

- **D-034 (Phase 0 boundary, human-pre-resolved — recorded, not re-litigated).** The manager brief carries the
  human's answer verbatim: *"All of the layers are swap-able with elm review rules"* — i.e. whichever module
  spelling is live and compiling in `packages/elm-m3e/src` right now IS the Phase B target. Verified on disk
  2026-08-13: `packages/elm-m3e/src/M3e/Component/Card.elm` exists and `M3e/Component/` + `M3e/Build/` are the
  committed layout — the D-031c/Move-2 flat `M3e.<Component>` cut has NOT landed. **Phase B therefore uses the
  `M3e.Component.Card` spelling.** If `origin/main`'s 4-package layout or the flat cut merges later, the rename
  is accepted rename debt (mechanical, elm-review-driven), not blocking. The remaining §11.1 "which boundary
  story wins" question stays a human decision but is NOT a Phase-B blocker per the human's answer. Phase A is
  boundary-independent (imports only `Cem.Facts`) and starts immediately.

- **D-035 (provider/model resolution).** Resolved fresh from `~/.paseo/orchestration-preferences.json`:
  builder=`claude/sonnet`, critic/integrator/controller=`claude/claude-opus-4-8` (NEVER bare `claude/opus`
  → resolves to banned opus-5). **Decision: builder stays on Sonnet for ALL parts, no Haiku.** The manager
  brief allows Haiku for "the most mechanical fully-specified sub-parts under an integrity gate," but the prefs
  file states `claude/haiku` is "for tests only — do not use it for production work." Prefs win; Sonnet is
  cheap enough and the risk of Haiku on production Elm is not worth it. Reversible: revisit if Sonnet proves
  slow/expensive on the transcription-heavy tasks.

- **BASELINE.** Fresh worktree had no `node_modules` → first `gate:all` was RED purely environmentally
  (`run-p: command not found`). Ran `pnpm install` (exit 0), then re-baselined `gate:all` on the pristine
  branch point (no Compose changes yet). Result: **18/30 passed, 6 skipped, 6 failed.** The 6 skipped are the
  off-machine snapshot gates (D-033, expected). The **6 pre-existing FAILURES are the reference fingerprint**:
    1. `elm-cem: test`
    2. `elm-m3e: check`
    3. `elm-m3e: test`
    4. `elm-review-cem: check`
    5. `elm-review-cem: test`
    6. `workspace: check-drift (M4.b cross-cutting drift gate)`
  These are pre-existing Move-1 migration debt on `main` (ledger D-033: "the five real clone failures … the
  remaining Move 1 work"), NOT caused by Compose and explicitly out of this effort's scope to fix. Note
  `m3e-builder-docs` (the package Phase B gates on) is NOT in the failing set — it passes at baseline.

- **D-036 (gate:all acceptance reinterpreted — autonomous, reversible).** Plan Task 7 & Task 14 say "`pnpm
  gate:all` green." That absolute-green target is unattainable on this branch because of the 6 pre-existing
  unrelated failures above. **Reinterpreted acceptance: gate:all shows NO NEW failures beyond the 6-item
  baseline fingerprint, the 6 skipped stay skipped, AND all Compose-owned items are green** — i.e.
  `elm-cem-compose: check` + `elm-cem-compose: test` (Phase A) and `m3e-builder-docs: check` (Phase B) pass, and
  no 7th failure appears. A regression in any baseline-passing item counts as mine. This is recorded so the
  human can override; the alternative (fixing unrelated Move-1 debt) is out of scope and a rabbit hole.
  Next free IDs: **D-037**, **R-023**.

### Phase A parts

- **D-037 (Task 1 reference-bar defect — corrected autonomously, verified). PLAN DEFECT.** Plan Task 1 Step 3
  specifies `check:compile: "node bin/stage-facts-elm-home.mjs && elm make --docs=/dev/null"`. This CANNOT pass
  and is architecturally impossible on this repo. The A1 builder (Sonnet) correctly diagnosed it and STOPPED
  without committing (good discipline). I independently reproduced + confirmed the root cause:
  - Raw `elm make` on a `type: package` elm.json resolves version-range deps against the **live registry**, not
    the ELM_HOME cache. `jackhp95/elm-cem-facts` is unpublished → `INCOMPATIBLE DEPENDENCIES`, staging notwith-
    standing. Reproduced directly (facts cache present, still fails). The boundary spike (§3 step 2) confirms:
    unpublished workspace deps must be **vendored as unexposed source**, never declared — but our manifest MUST
    declare `elm-cem-facts` (registry-faithful is a hard requirement gated by check-headless). Irreconcilable
    for raw `elm make`.
  - The precedent Task 1 copies from, `packages/elm-review-cem`, has **NO raw `elm make` anywhere**; it proves
    compilation registry-free via `elm-review --compiler` + its `tests/` application. Confirmed
    `pnpm --filter elm-review-cem run check` is GREEN with that strategy.
  **Correction (elm-review-cem-style, no new deps):** removed `check:compile` from `elm-cem-compose/package.json`.
  Standalone-compile proof = `test:elm` — the `tests/` application compiles `../src/Cem/Compose.elm` against the
  real `Cem.Facts` (`../../elm-cem/facts/src`) via source-directories + exact pins, no registry. It runs under
  `gate` (`run-s check test`). Verified: `pnpm --filter elm-cem-compose run gate` → GREEN (check:format []`,
  check:headless OK, test:elm 1 passed). Consequence: **ELM_HOME staging is no longer load-bearing for the
  compose gate** (test:elm uses source-directories); the `stage-facts-elm-home.mjs` script is kept present (the
  documented pattern, harmless, future publish/elm-review may use it) but vestigial-for-now.
  **Phase A acceptance criterion 2 (spec §15 / plan Task 7) reinterpreted:** "the package compiles standalone"
  is proven by the tests application (test:elm) against the real facts, NOT by raw `elm make --docs` (impossible
  for a registry-faithful manifest declaring an unpublished dep). Reversible: restore the line if the facts
  package is ever published. Task 7's headless gate + the 3-dep check-headless still fully enforce the "no
  view / no brand / registry-faithful" invariants.
  Also validated the builder's two necessary deviations: (1) added `elm-tooling.json` (elm 0.19.1, elm-format
  0.8.7, elm-test-rs 3.0.0) + `postinstall: elm-tooling install`, matching the
  elm-html-intermediate-representation / elm-typed-html / elm-review-cem precedent — required because workspace-
  root elm-test-rs 1.0.0 bundles a test-runner needing `elm-explorations/test 1.x` while tests pin 2.2.1;
  3.0.0 is the repo-consistent version. Accepted. (2) the `/tmp` docs path is moot (line removed).
  Next free IDs: **D-038**, **R-023**.

- **A1: pass** (gate green, critic clean, builder claude/sonnet). Commit `9064dd2`. Scaffold: elm.json (3 deps
  only), package.json (check:compile removed per D-037), stage-facts script, check-headless placeholder,
  Cem/Compose.elm exposing only `version`, tests/elm.json + SmokeTest, README, LICENSE, elm-tooling.json.
  Round 1 stopped on the D-037 plan defect (builder correct); round 2 committed against the corrected bar.
  Integrity: 11 files / +254 / -0, only compose/* + pnpm-lock.yaml, no golden/test mutated elsewhere. Fresh
  Opus critic independently re-ran all gates + reproduced the INCOMPATIBLE DEPENDENCIES root cause → PASS.

- **A2: pass** (test:elm 18/18, critic clean, builder claude/sonnet). Commit `33c8111`. Node/Child/AttrValue/
  AttrKind/PathStep/Path/MenuKind + Model/init/Msg/update + nodeAt/factAt + componentOf/attrsOf/slotsOf +
  updateAt. `Node` opaque (no `(..)`), `update : Msg -> Model -> Model` (no Cmd/Effect), insertChild holds the
  append-iff-multi-else-replace invariant. Integrity: 4 files (Compose.elm mod, FakeFacts+StructureTest added,
  SmokeTest deleted per plan). Fresh Opus critic confirmed StructureTest.elm + FakeFacts.elm are BYTE-IDENTICAL
  to the plan (tests not weakened) and all fixture traps intact (ghost absent, dup label, self-recursive
  container/single) → PASS.

- **A3: pass** (test:elm 32/32, critic clean, builder claude/sonnet). Commit `7682ac3`. `SlotAffordances`
  (`{text,icon,components}`), `SlotChipInfo`, `slotChips` — the §8.7 amendment. `affordancesFor` computes the
  three modes INDEPENDENTLY (no winner-takes-all); `textKinds` includes shared:flow/shared:phrasing; components
  filtered to `:`-free names present in facts. Integrity: 2 files (Compose.elm mod, SlotTest added). Fresh Opus
  critic confirmed the decisive coexistence assertions (mixed.any text+icon+widget; mixed.flowy; unconstrained
  text-only; container components-only) are full-record equals, unaltered → PASS.

- **D-038 (Task 2/Task 4 cross-task defect — corrected autonomously). PLAN DEFECT.** A4's affordance-gated
  `addIfAfforded` (correctly transcribed from Task 4 Step 4) broke a *pre-existing* StructureTest case committed
  in A2: "RemoveChild at index 0 shifts the former index 1 down" seeds the second child with `C.AddChild []
  "unnamed" "single"`, but `container.unnamed` names `["widget","ghost","container"]` — `"single"` is a fact yet
  NOT afforded by that slot. Under A2/A3's loose `Dict.member … facts` guard the add succeeded (exploiting the
  gap §8.7 exists to close); under A4's correct guard it is a no-op, so `RemoveChild 0` empties the slot and the
  test's `Just "single"` assertion fails. The A4 builder (Sonnet) caught this and STOPPED rather than touch the
  test unilaterally — good discipline. **Decision: option 1** — change the probe's second child from `"single"`
  to `"container"` (a component the slot DOES name) and the expected value to `Just "container"`. The test's
  INTENT (removal shifts the former index-1 child down to index 0, keeping its identity) is preserved exactly;
  it now uses a validly-nestable component, consistent with §8.7. NOT test-weakening — the assertion is still a
  full identity check. Rejected option 2 (widening the fixture) because Task 3's committed "components-only slot"
  test asserts container.unnamed's afforded set is exactly `["widget","container"]` and would ripple. This edit
  lands in the A4 commit alongside the slotMenuOptions work. Reversible. Next free IDs: **D-039**, **R-023**.

- **A4: pass** (test:elm 42/42, critic clean, builder claude/sonnet). Commit `4b66551`. `SlotOption`,
  `slotMenuOptions`, and `update` tightened so all three `Add*` route through `addIfAfforded` (insert iff the
  slot's affordances permit; old `Dict.member … facts` guard deleted). Includes the D-038 2-line StructureTest
  probe correction. Round 1 stopped on D-038 (builder correct); round 2 committed. Integrity: 3 files. Fresh
  Opus critic confirmed the "every offered option changes the model" property test (7 slots) + 3 no-op tests are
  real/unweakened, tightening is genuine, and the StructureTest change is EXACTLY the 2 authorized lines → PASS.

- **A5: pass** (test:elm 51/51, critic clean, builder claude/sonnet). Commit `8ad4342`. `AttrChipKind`
  (`EnumChip`/`PlainChip`), `AttrChipInfo`, `attrChips` — enum chips in fact order, then plain chips (attrRewrites
  values minus enum names, deduped, sorted, filtered to attrKinds-present). Genuine unset state (`isSet = current
  /= Nothing`), NO always-first-token fallback (the deliberate Builder.elm divergence). Integrity: 2 files. Fresh
  Opus critic confirmed the ordered load-bearing assertion `[variant,count,disabled,label,ratio]` + isSet/Clear
  tests are full-value equals, unweakened → PASS.

- **A6: pass** (test:elm 59/59, critic clean, builder claude/sonnet). Commit `43aa010`. `NumberKind`,
  `MenuOptions`, `attrMenuOptions` (delegates to attrChips → inherits offer/path resolution), `menuOptionsFor`,
  `rawText`. Raw-number round-trip preserved verbatim (`AttrFloat "1."` → `NumberInput FloatNumber "1."`, no
  reparse). Integrity: 2 files, additive. Fresh Opus critic confirmed all 8 menu-shape assertions are exact
  equals, unweakened → PASS. **Phase A core queries (A2–A6) complete; A7 is the determinism + headless-gate
  close-out.**

- **A7: pass — PHASE A GREEN** (test:elm 62/62, critic+sign-off clean, builder claude/sonnet). Commit `9ecff06`.
  Determinism block (equal-models, stable attrsOf ordering, and the unbounded-depth self-recursive-`container`
  nest-to-10 proof of §8.3 — no cap/guard); REAL headless gate replacing the placeholder; README. The headless
  script needed ONE edit vs the plan's verbatim text — adding the package's own name `jackhp95/elm-cem-compose`
  to the `allowed` alternation (the plan's own Step-2 note authorized this; it does not weaken the separate
  elm/html/virtual-dom/elm-m3e forbidden loop). Integrity: 3 files. Fresh Opus critic+integrator INDEPENDENTLY:
  (i) proved the headless gate BITES (injected elm/html on a copy → exit 1 with two FAIL lines; clean → exit 0);
  (ii) ran full `node tools/gate-all.mjs` → `elm-cem-compose: check` + `test` both PASS, and the 5 failures are a
  strict subset of the 6-item baseline fingerprint (elm-review-cem:check improved to PASS) — NO 7th failure, no
  compose item red; (iii) confirmed all 4 spec-§15 Phase-A criteria (as amended by D-037) → **PHASE A: GREEN**.
  Phase A (a tested, headless, registry-faithful package carrying the portability claim) is an independently
  valuable artifact, done. Next free IDs: **D-040**, **R-023**.

## Phase B parts

- **D-039 (Phase B gate-command defects — found during prep, corrections to apply per-task). PLAN DEFECT.**
  Verified on disk before starting Phase B: the docs app `packages/elm-m3e/docs/package.json` (pnpm name
  `m3e-builder-docs`) has **NO top-level `check` script and NO `start` script**. The plan's Phase B reference
  bars invoke `pnpm --filter m3e-builder-docs run check` (Tasks 8/11/12/13) and `npm run start` (Task 11) — both
  non-existent. Also note `tools/gate-all.mjs` only runs per-package `check`/`test` scripts, so the docs app is
  NOT gated by `gate:all` at all (why `m3e-builder-docs` never appears in gate-all output). **Corrected Phase B
  gates (to inject into each builder brief):** for "the app still compiles/reviews" use
  `pnpm --filter m3e-builder-docs run check:review` (`elm-review --config ../review --compiler
  node_modules/.bin/elm` — compiles the whole app source set + runs rules) PLUS a targeted
  `cd packages/elm-m3e/docs && npx elm make app/<the new module>.elm --output=/dev/null`; for the dev server
  (Task 11 browser view) use `npm run dev` (elm-pages dev), NOT `start`; browser tests remain `npx playwright
  test` (Task 14). The plan's other Phase B commands that DO exist — `check:review`, `check:nav`, `elm make`,
  `playwright test`, `build:site` — stand. Spelling confirmed for D-034: the docs Feed.elm template imports
  `M3e.Component.Card`/`M3e.Component.AppBar`/`M3e.Component.NavItem` — the live per-component layout — so Phase B
  uses the `M3e.Component.*` spelling. Reversible/mechanical. Next free IDs: **D-040**, **R-023**.

- **D-040 (copy-fidelity AUTHORIZED_EXTRA requirement for Phase B new files — found during prep).** Read
  `tools/copy-fidelity-elm-m3e.sh`: it compares git-tracked PATH SETS (not content) between workspace
  `packages/elm-m3e` and the source oracle checkout, BIDIRECTIONALLY — flags `missing` (source∖workspace) AND
  `extra` (workspace∖source, minus an `AUTHORIZED_EXTRA` allowlist). Consequences for Compose:
  (1) **Content edits** to existing tracked files (docs/elm.json B8, Shared.elm B11, review/CodegenReviewConfig
  B10) are INVISIBLE to this gate — safe. (2) **Each NEW file** Phase B adds under `packages/elm-m3e/` —
  `docs/scripts/gen-compose-attrs.mjs`, `docs/app/Route/Components/Compose/Attrs.elm` (B9),
  `.../Compose/Render.elm` (B10), `.../Compose.elm` (B11), `.../Compose/Codegen.elm` (B13),
  `docs/tests-browser/compose.spec.ts` (B14) — will register as `extra` → copy-fidelity RED against the oracle
  UNLESS added to `AUTHORIZED_EXTRA` in `tools/copy-fidelity-elm-m3e.sh` with a one-line reason (the script's own
  sanctioned mechanism for "deliberate monorepo adaptations"). Editing that tool file is safe (it lives under
  `tools/`, not `packages/elm-m3e/`, so it's invisible to the gate itself). **In THIS worktree copy-fidelity
  SKIPs** (its `SOURCE_ELM_M3E` defaults to a nonexistent worktree-sibling), so it does not redden the in-worktree
  `gate:all`; but for the deliverable to be correct/mergeable, the allowlist must be maintained. Baseline verified
  read-only: `SOURCE_ELM_M3E=/Users/jhp/code/jackhp95/elm-m3e bash tools/copy-fidelity-elm-m3e.sh` → GREEN
  (source=1245, workspace=1199) pre-Phase-B. **Plan: each Phase-B task that ADDS a file under packages/elm-m3e/
  also appends it to AUTHORIZED_EXTRA; manager verifies copy-fidelity GREEN vs the real oracle (read-only, never
  editing the oracle) after each.** B8 needs no entry (edits + deletes scratch only). Next free IDs: **D-041**,
  **R-023**.

- **D-041 (Task 8 §14-risk-5 collision — corrected autonomously, verified). PLAN GAP.** Adding
  `../../elm-cem-compose/src` + `../../elm-cem/facts/src` to the docs app's `source-directories` (Task 8's whole
  job) made the docs app's `check:review` gate RED with **45 errors** — because `elm-review` reviews every file in
  the project's source-directories, so it began linting the compose + facts SIBLING packages (and compose's
  `tests/src`, pulled via the sibling `tests/` convention) against the docs app's strict ReviewConfig
  (NoMissingTypeAnnotationInLetIn, NoUnused.*, NoRedundantlyQualifiedType, NoPrematureLetComputation). The B8
  builder (Sonnet) caught this — it IS the §14-risk-5 fail-fast Task 8 exists for, manifesting as a review-ruleset
  collision rather than module shadowing — and STOPPED. Root cause bisected: facts/src alone = 2 errors,
  compose/src alone = 43. **Decision: exclude the two new sibling source trees from the docs review**, exactly as
  the config ALREADY excludes the other sibling workspace packages it compiles against. `ReviewConfig.elm`'s
  `ignoreGeneratedSubstrate` helper (applied to every main-list rule) already lists `../../elm-typed-html/src/`
  and `../../elm-html-intermediate-representation/src/`; added `../../elm-cem/facts/src/`,
  `../../elm-cem-compose/src/`, `../../elm-cem-compose/tests/src/` alongside them. Verified:
  `pnpm --filter m3e-builder-docs run check:review` → "I found no errors!" (all 45 cleared). REJECTED the
  alternative of retrofitting compose's already-committed Phase-A code to satisfy the docs app's lint rules —
  that would couple the headless published core to a consumer's style config, the exact inversion the whole design
  forbids; you don't lint your dependencies. **Observation (not a blocker):** elm-cem-compose's own code is not
  elm-reviewed by anything (its gate is format+headless+tests, per the spec's minimal toolchain); giving it its
  own elm-review is out of this plan's scope. B8 commit now includes TWO files: `docs/elm.json` (+2 source-dirs)
  and `review/src/ReviewConfig.elm` (+3 sibling exclusions); both are content edits, invisible to copy-fidelity.
  Reversible. Next free IDs: **D-042**, **R-023**.

- **B8: pass** (check:review green, critic clean, builder claude/sonnet). Commit `c25ee40`. `docs/elm.json` gains
  the two canonical source-dirs (`../../elm-cem/facts/src`, `../../elm-cem-compose/src`); `ReviewConfig.elm`
  excludes the two sibling trees from docs review (D-041). Round 1 stopped on the D-041 45-error collision
  (builder correct); round 2 committed. Integrity: 2 files, content-only (invisible to copy-fidelity, re-verified
  GREEN vs real oracle). Fresh Opus critic confirmed exact source-dir list, check:review "no errors", the
  ReviewConfig change is ONLY the 3 sibling entries (no rule loosened), no scratch committed, external oracle
  untouched → PASS. **Phase B wiring in place; the docs app now compiles against Cem.Facts + Cem.Compose.**

- **D-042 (B9 count-sanity drift — investigated, ACCEPTED, independently reconciled).** The B9 generator
  produced `kinds`=**166** rows (spec §4.1 baseline 182, ~9% short) and `witness`=**204** distinct (attr,token)
  enum pairs (baseline 201). Plan Task 9 flags "within a few of 182" as the sanity heuristic and "wildly
  different = regex misparse / dropped half" as the failure trigger. The Sonnet builder investigated and STOPPED
  rather than commit. I INDEPENDENTLY reconciled (did not trust the builder): parsed
  `packages/elm-m3e/src/M3e/Attributes.elm` myself → first-arg Bool 80 + String 64 + Float 24 + Int 2 = **170
  classifiable non-enum setters**, plus 39 `Value`-typed (enum) setters. Generated `kinds`=166 = exactly the
  170 classifiable minus 4 that no component's `attrRewrites` names (unreachable). `witness` total M3e.Attributes
  refs = **370 = 166 setter witnesses + 204 enum-pair witnesses** — reconciles to the byte. Builder's barrel
  accounting also closes: 225 distinct reachable barrel names = 166 non-enum-classified + ~25 reachable
  enum-typed + ~34 event handlers. **Conclusion: NOT a misparse and NOT a silent drop — every classifiable AND
  reachable setter is in the table.** 166 is 91% of 182 (not half); the 182→166 / 201→204 drift is genuine input
  evolution — the active migration reclassifying some non-enum setters as portmanteau enums, precisely the
  `b85cb563` change spec §11.1 predicted would touch `M3e.Attributes` (non-enum ↓, enum ↑, the observed
  direction). The table is COMPLETE and CORRECT for this workspace's real inputs; it is generated + deterministic
  + A/B-gated (check:compose-attrs), so it is the specification. Accepted as current-baseline. If a human later
  wants the 182 figure restored, that is an upstream M3e.Attributes question, not a Compose bug. Next free IDs:
  **D-043**, **R-023**.

- **B9: pass** (all gates green, critic clean, builder claude/sonnet). Commit `487e7d9`. `gen-compose-attrs.mjs`
  (deterministic generator) + generated `Attrs.elm` (kinds/toAttribute/witness/codeLineFor) + package.json
  scripts (gen/check:compose-attrs) + ReviewConfig `ignoreGeneratedComposeAttrs` (file-scoped exclusion of the
  generated Attrs.elm ONLY) + 2 copy-fidelity AUTHORIZED_EXTRA entries. kinds=166, witness=204 enum pairs
  (accepted per D-042). Round 1 stopped on the count anomaly (builder correct to check); I independently
  reconciled → accept. Fresh Opus critic INDEPENDENTLY: determinism (regen → 0 diff), A/B bite (hand-edit →
  check:compose-attrs exit 1, restore → 0), Attrs.elm compiles, **count bijection 166 = classifiable∩reachable
  with MISSING=0/EXTRA=0** (no silent drop), review-exclusion is file-scoped (Render/Codegen stay reviewed),
  copy-fidelity GREEN vs oracle, integrity 5 files → PASS. Hardest Phase B part done.

- **D-043 (B10/B11 sequencing — Render.elm orphaned until the route consumes it).** The docs `NoUnused.Exports`
  rule applies to app modules (`ignorePublicApi` only covers `src/M3e/`), so B10's hand-written `Render.elm`
  (`renderNode`/`tagFor`) is an unused export until a route imports it — a transient artifact of the plan's
  B10-before-B11 order. Render is HAND-WRITTEN, so it must stay reviewed (NOT excluded like the generated
  Attrs.elm). Resolution: **B10 gate = `Render.elm` compiles (elm make) + the one `M3e.Unsafe.fromHtml`
  allow-list entry added correctly + copy-fidelity GREEN (Render in AUTHORIZED_EXTRA); full check:review-green is
  DEFERRED to B11**, whose route imports `renderNode` into a live-preview pane via `M3e.Unsafe.fromHtml` —
  consuming it AND exercising the allow-list entry. Builders must NOT fake a consumer or review-exclude Render
  to force B10 green. Reversible. Next free IDs: **D-044**, **R-023**.

- **D-044 (elm-format must NOT touch the generated Attrs.elm — process rule for B11–B13).** The plan's per-task
  formatting step `elm-format packages/elm-m3e/docs/app/Route/Components/Compose/ --yes` formats the WHOLE
  directory, including the generator-owned `Attrs.elm`. `elm-format` changes Attrs.elm (the generator does not
  emit elm-format-compliant output), which diverges it from the generator's raw output and RED-lines
  `check:compose-attrs` (byte-identity). The B10 builder caught this and reverted Attrs.elm. **Rule for all
  remaining Phase-B tasks: format ONLY the hand-written files just created/edited (e.g. `elm-format
  app/Route/Components/Compose/Render.elm Codegen.elm ... --yes`), NEVER the directory, and NEVER Attrs.elm.**
  check:compose-attrs is the gate that catches a violation. Reversible. Next free IDs: **D-045**, **R-023**.

- **B10: pass** (compile + allow-list + copy-fidelity green; review-green deferred per D-043; critic clean;
  builder claude/sonnet). Commit `bb8e969`. `Render.elm` (tagFor/toKebabCase/renderNode/renderSlot/placement/
  withSlot — no double-render, ChildNode→withSlot renders once) + ONE documented `NoUnsafeImportOutsideAllowed`
  allow-list entry (`Route.Components.Compose`) + Render.elm in copy-fidelity AUTHORIZED_EXTRA. Builder caught &
  reverted an elm-format-on-Attrs.elm hazard (→ D-044). check:review = exactly the 2 expected "Render unused"
  findings (D-043 transient, resolves at B11); check:compose-attrs still OK (Attrs intact). Fresh Opus critic
  confirmed no-double-render, single allow-list entry, integrity 3 files, copy-fidelity GREEN → PASS.

- **D-045 (Phase B file-layout is framework-incompatible — corrected autonomously; the effort's MOST SIGNIFICANT
  deviation from the plan's stated structure — FLAG FOR HUMAN REVIEW). PLAN ARCHITECTURAL FLAW.** The plan's
  File-Structure section places the three helper modules under the route directory:
  `docs/app/Route/Components/Compose/{Attrs,Render,Codegen}.elm`. But **elm-pages treats EVERY module under
  `app/Route/` as a page route** — so `elm-pages gen` emits a `.elm-pages/Main.elm` that references
  `Route.Components.Compose.Attrs.route.data`, `.Model`, `.Msg`, `.Data`, `.ActionData`, `.subscriptions`,
  `.onAction` (and same for `.Render`). Those helper modules expose only `(kinds,toAttribute,witness,codeLineFor)`
  / `(renderNode,tagFor)` — NO route interface — so the generated Main cannot compile and **`elm-pages build`
  fails**. Latent since B9 (Attrs.elm landed under Route/); B11's `gen:pages` exposed it. My per-task gates
  (check:review, single-file `elm make`) MISSED it because none ran a full elm-pages gen/build — check:review
  uses elm-review's AST analysis, not `elm make`, so it never compiled the generated Main. **GATE GAP now closed:
  Phase B's build-truth gate is `elm-pages build` (what B14's playwright already runs), not check:review.**
  **Fix (one correct answer, mechanical):** move the 3 helpers OUT of `app/Route/` to `app/Compose/`, renaming
  modules `Route.Components.Compose.{Attrs,Render,Codegen}` → `Compose.{Attrs,Render,Codegen}`. Only the actual
  route `app/Route/Components/Compose.elm` stays under Route/. The spec's module DECOMPOSITION (route + 3 folds +
  generated adapter) is preserved unchanged — ONLY the directory/module-prefix changes. Touches: the B9 generator
  (`gen-compose-attrs.mjs` output path + emitted module name), `check:compose-attrs`, the ReviewConfig
  generated-Attrs exclusion path, the copy-fidelity AUTHORIZED_EXTRA paths (B9/B10), and Render's `tagFor`
  un-exposed (it is module-internal — the plan's "Produces: tagFor" over-specified; NoUnused.Exports correctly
  flags it). `.elm-pages/` is regenerated + committed (maintained routing manifest; build regenerates it anyway,
  but committing keeps check:review's NoUnused.Modules green and the tree consistent); the new
  `.elm-pages/Fetcher/Components/Compose.elm` gets an AUTHORIZED_EXTRA entry. Reversible via git revert. Recorded
  here and surfaced in the final report because it deviates from the plan's explicit file paths. Next free IDs:
  **D-046**, **R-023**.

- **B11: pass** (build:site exit 0 w/ /components/compose prerendered; check:review green; critic clean; builder
  claude/sonnet). Commits `555c116` + fixup `1d0448e`. Implements the D-045 layout fix (helpers → `app/Compose/`,
  modules `Compose.Attrs`/`Compose.Render`; tagFor un-exposed) + the route `Route.Components.Compose` (init
  root="list", view consumes `Render.renderNode` via `M3e.Unsafe.fromHtml`) + nav link + regenerated committed
  `.elm-pages/`. Builder self-caught a failed multi-path `git add` that left the rename unstaged and fixed it with
  a follow-up commit (transparent, verified). Fresh Opus critic INDEPENDENTLY ran the full `build:site` → exit 0,
  `/components/compose` prerendered (proving generated Main.elm compiles — the gate check:review can't provide),
  confirmed helpers no longer routed (Route.elm has Components__Compose only), route wiring, nav, check:review
  green, check:compose-attrs OK, copy-fidelity GREEN, integrity of both commits → PASS. **The route is live and
  the app builds; §8.7 editor UI + snippet are B12/B13.**

- **B12: pass** (build:site exit 0 w/ editor prerendered; check:review green; critic clean; builder
  claude/sonnet). Commit `e6c1e9d` (1 file, route only, +258/-5). Recursive `viewNode` editor: attr/slot chip-set,
  `attrMenuView`/`slotMenuView`, `childCards` recursion, inline `SetChildContent` text fields, `RemoveChild`
  controls; live preview retained. **§8.7 non-collapse preserved in the consumer:** `slotMenuView` renders one
  item per `SlotOption` via 3 independent case branches (single-option→fire-directly shortcut lives in
  slotChipView). Builder fixed a real `MissingRequiredAttribute` (iconButton needs aria-label) with `Aria.label`,
  matching the app pattern. NO new allow-list/exclusions. Fresh Opus critic ran build:site (exit 0, compose
  prerendered), confirmed §8.7 non-collapse + recursion wiring + integrity 1 file + copy-fidelity GREEN → PASS.

- **B13: pass** (build:site exit 0 w/ all 3 panes prerendered; snippet-compile proof; check:review green; critic
  clean; builder claude/sonnet). Commit `8c26e55` (3 files: `app/Compose/Codegen.elm` added [D-045 layout], route
  +14, copy-fidelity +4). `Compose.Codegen.codeFor` recursive fold: `M3e.Html.<component>` + `bracketed` attr/child
  lists + depth indentation + `"unnamed"` default-slot special-case (no slot=) + `ChildText`→`M3e.text`,
  `ChildIcon`→`M3e.Html.icon` + `Attrs.codeLineFor`. Snippet pane wired via `Doc.codeBlock Doc.Elm`; editor +
  live preview retained. Builder fixed a real `NoMissingTypeAnnotationInLetIn`. **Snippet/preview agreement
  (spec §15) proven by scratch-compile** (worked example + set enum + set bool → `elm make` Success). Codegen is
  hand-written + fully reviewed (no exclusion). Fresh Opus critic ran build:site (exit 0), re-did the
  scratch-compile, verified codeFor structure + integrity 3 files + copy-fidelity GREEN → PASS. **All three folds
  done; only B14 (browser sign-off) remains.**

- **B14: pass — PHASE B GREEN — EFFORT COMPLETE** (Playwright 4/4; gate:all no-new-failures; critic+sign-off
  clean; builder claude/sonnet). Commit `f17a3ba` (5 files). Created `tests-browser/compose.spec.ts` (4 tests) +
  AUTHORIZED_EXTRA. **The browser layer earned its keep: it caught TWO real runtime defects invisible to every
  compile/type/review gate**, both fixed in-commit: (1) `m3e-menu` needs an `m3e-menu-trigger` — B12's chips
  never opened a menu; reworked slot/discrete-attr chips as `m3e-button` toggles + sibling `m3e-menu` by id/for
  (§8.7 non-collapse preserved — verified); (2) the B9 generator's `setterFor` was built only from the non-enum
  subset, so `codeLineFor` silently dropped ENUM attributes from the snippet (a spec-§15 preview/snippet
  DISAGREEMENT); fixed in `gen-compose-attrs.mjs`, `Attrs.elm` regenerated deterministically (diff=0,
  check:compose-attrs OK). Fresh Opus critic+integrator INDEPENDENTLY: ran Playwright → 4/4 PASS; confirmed the
  §8.7 test genuinely asserts `toHaveText(["Text","Icon","avatar","checkbox","heading","radio","switch"])` then
  renders a real `m3e-checkbox`; the attr test asserts BOTH live element AND snippet; non-collapse preserved;
  enum fix + determinism; check:review green (one fromHtml entry, no new suppressions); integrity 5 files →
  **B14 PASS, PHASE B GREEN**. Final `node tools/gate-all.mjs` (manager, independent): **22/32 passed, 6 skipped,
  4 failed** — `elm-cem-compose: check`+`test` PASS; the 4 failures (`elm-cem: test`, `elm-m3e: check`,
  `elm-review-cem: test`, `workspace: check-drift`) are all a strict subset of the 6-item pre-existing baseline
  (D-036; elm-m3e:test + elm-review-cem:check improved to PASS) — NO new/Compose-attributable failure.

## EFFORT COMPLETE — summary for the human

**All 14 tasks green and committed on branch `compose-poc`** (worktree `/Users/jhp/.paseo/worktrees/358ycm5n/
compose-poc`). Phase A (A1–A7): the headless `jackhp95/elm-cem-compose` package — tested (62 elm-test cases),
registry-faithful (exactly elm/core + list-extra + elm-cem-facts, no elm/html), `grep -ri m3e src` empty; the
portability claim holds by dependency shape. Phase B (B8–B14): the `/components/compose` route in elm-m3e's docs
app — three folds (editor/preview/codegen) + generated adapter, live and demonstrated in a real browser (§8.7
`listItem.trailing` offers checkbox; 3-level nesting; attr→live+snippet agreement; drawer link). NOT pushed, NOT
merged — that is the human's call. **13 autonomous decisions recorded (D-034…D-046 range used through D-045);
the one to review first is D-045** (the plan's file layout put helper modules under `app/Route/`, which elm-pages
mis-routes; relocated to `app/Compose/` — a deviation from the plan's explicit paths, mechanical + reversible).
Also flag: D-037 (compile gate), D-042 (attr count 166 vs spec's 182 — genuine input drift, reconciled),
D-039/D-040/D-041/D-043/D-044 (docs-app gate mechanics). The 4 red `gate:all` items are pre-existing Move-1
migration debt, out of this effort's scope. Next free IDs: **D-046**, **R-023**.

---

# COMPOSE UX INCREMENT — branch `compose-poc` (post-POC, human-requested)

Human (2026-08-14) asked to make the editor support the DOM modifications a user expects — add child (exists),
remove node (exists), **edit the tag** (NEW), and move the slot/attr count numbers onto **m3e-badge** — then run
an **m3e-okf** (correct-Material-usage) audit. Run as another gauntlet loop (human's choice). Parts: C1 (core),
D1 (consumer UX), E1 (audit). Same providers (builder claude/sonnet, critic claude/claude-opus-4-8).

- **D-046 (edit-tag feature — human-approved scope step BEYOND the POC spec §5.7).** The spec froze a node's
  component at creation ("cannot be replaced"). Human approved adding in-place component-change with **type-directed
  choices** and **keep-valid-content** pruning. This EXTENDS the published `elm-cem-compose` core API (new `Msg`
  variant + query) — a deliberate, recorded deviation from Phase A's "done" surface; bump the package minor
  version. **Core semantics (C1 reference bar):**
  - `componentOptions : Path -> Model -> List String` — the components this node may become, EXCLUDING its current
    component. Root (`[]`): all `Dict.keys facts`, sorted. Nested: the PARENT slot's afforded components (via the
    parent fact's `affordancesFor … .components` for the slot named in the last `PathStep`) — already
    facts-present/deduped. Unresolvable path → `[]`. (Type-directed: a nested node can only become something its
    parent slot legally accepts; the tree stays valid.)
  - `SetComponent Path String` — if the target ∉ `componentOptions path model` → no-op + close menu (menu/update
    agreement, as A4). Else, at `path`: set component := target, then PRUNE to keep only valid content:
    (a) attrs → keep exactly the attrs the target offers (same set `attrChips` would produce for the target:
    name ∈ target.enums OR (name ∈ target.attrRewrites-values AND ∈ model.attrKinds)); drop the rest.
    (b) children → for each slot with children: keep the slot iff target declares it (target `slotNames`); within
    a kept slot keep each child iff the target's slot still affords its kind (ChildText→text, ChildIcon→icon,
    ChildNode→componentOf ∈ that slot's afforded components); then enforce the target's cap (if the slot ∉
    target.multiSlots, keep only the first survivor). Clear `openMenu`.
  - Node stays opaque; `update : Msg -> Model -> Model` (no Cmd). New tests: componentOptions (root/nested/
    unresolvable), SetComponent no-op-when-unoffered, component swap, attr pruning (kept vs dropped), child
    pruning (slot-not-declared dropped, kind-not-afforded dropped, survivor kept), non-multi cap after swap,
    openMenu cleared, and the property "every componentOptions entry changes the model when SetComponent applied."
  Next free IDs: **D-047**, **R-023**.

- **C1: pass** (test:elm 74/74, critic clean, builder claude/sonnet). Commit `a6848ae` (5 files, all in
  elm-cem-compose; version→1.1.0). `componentOptions` (root=all-facts-sorted-minus-current; nested=parent-slot
  afforded-minus-current, type-directed; unresolvable=[]) + `SetComponent Path String` (no-op if unoffered; else
  swap + prune attrs to `offeredByTarget` + prune children to target-declared/afforded slots + non-multi cap via
  List.take 1 + clear openMenu). Fixture extended ADDITIVELY (`gadget` shares attrs w/ widget; `narrow`
  slot-kind-change/cap) — original six byte-unchanged; builder self-caught + fixed an illegal fixture kind. Fresh
  Opus critic verified all semantics + 12 exact-equal tests (none weakened) + Node opaque + no Cmd + grep-m3e
  empty + 3 deps → PASS. **Core edit-tag done; D1 wires it into the route UI + badges + add/remove polish.**

- **D1: pass** (build:site exit 0; Playwright 6/6; check:review green; critic clean; builder claude/sonnet).
  Commit `fea1f3c` (route + spec, 2 files). Edit-tag UI: `editTagControl`/`componentMenuElement` — a header
  "Change component" menu from `componentOptions` firing `SetComponent` (renders nothing when options empty; root's
  long list height-capped `overflow-y-auto`). Counts moved to `M3e.badge` (slot chips always; attr chips when
  set). Remove controls retained on children (root none). +2 Playwright tests (edit-tag rewrites tree:
  m3e-list→m3e-accordion + snippet; nested type-directed menu = exactly [divider,expandableListItem,listAction,
  listOption]). 3 prior tests updated ONLY their button-name locators for the badge rename (assertions unchanged —
  critic verified not weakened). Builder fixed 2 Simplify findings. Fresh Opus critic ran build:site + Playwright
  6/6, verified real assertions + no weakening + badge/menu API + integrity 2 files + copy-fidelity GREEN → PASS.
  **Editor now supports add-child + remove-node + edit-tag (type-directed) with count badges. E1 = m3e-okf audit.**

- **E1: m3e-okf Material-correctness audit — DONE (findings reported to human; fixes are a separate decision).**
  OKF checkout `/Users/jhp/code/jackhp95/m3e-okf` verified current (state:current, HEAD 8275e26). Audited the
  Compose route's M3E usage against the OKF knowledge bundle (applying-material-design skill). **4 findings, ranked
  + cited; all recommended alternatives confirmed to exist in M3e (inputChip/assistChip/tree/treeItem):**
  1. **HIGH — recursive editor uses NESTED `M3e.card`; the intent-correct container is `M3e.tree`/`treeItem`.**
     Card = single-subject surface; nesting elevated cards → ambiguous containment/elevation. The thing being
     edited IS a hierarchical node tree, and M3E ships Tree ("hierarchical list whose nodes expand/collapse").
     Real redesign.
  2. **MEDIUM — `filterChip` is the wrong chip type.** Filter chips = narrow a result set; `selected` = filter
     active. Compose uses filterChip + `selected=isSet` for attribute editors and for "+add" slot actions
     (neither is filtering), and MIXES attribute chips + add-action chips in one chip-set (OKF explicitly: "don't
     mix chip types with conflicting behaviors"; "don't use chips as a substitute for buttons"). Fix: set-attr →
     `inputChip` (an editable token); "+add" → `assistChip`/button; split the sets.
  3. **LOW-MED — `attrValueBadge` puts an attribute's VALUE string in `M3e.badge`.** Badge = count/status marker,
     not a value label. Slot COUNT badges are a defensible count use (and honor the human's "numbers→badge" ask);
     the attr-value-in-badge overreaches — show a set value via the chip's own label/supporting text.
  4. **LOW — emphasis density** (stacked elevated cards + chips + badges + buttons in a dense tool → "too many
     emphasis levels"); largely resolved if #1 (tree) is adopted.
  **Already correct (noted):** menus use the `menuTrigger[for=id]` + sibling `menu[id]` self-positioning pattern
  (avoids the "wrapping self-positioning components" anti-pattern); icon-only controls have accessible names
  (`Aria.label`); remove action separately reachable/named. **No code changed by the audit itself** — awaiting
  the human's pick of which findings to fix (each fixable as a further gauntlet part). Next free IDs: **D-047**,
  **R-023**.

- **D-047 (audit-fix FEASIBILITY — the abstract Material advice partly collides with concrete M3E component
  capabilities).** Human approved fixing all of F1/F2/F3. Before dispatching I verified each against the real M3E
  component facts and found two collisions (the same class of wall B14 hit):
  - **F1 `m3e-tree` INFEASIBLE.** `treeItem` facts: `label` admits only `[heading,shared:text]`, `unnamed` admits
    only `[treeItem]` — a pure text hierarchy; it cannot host a node's chip-set/menus/inline-inputs/remove. So
    "use m3e-tree" is not realizable. MITIGANT: the node cards are ALREADY `variant=outlined` (no elevation
    stacking), so the primary nested-card anti-pattern is largely avoided; realistic fix = swap the nesting
    `M3e.card` for a plain outlined container (drops "card" semantics), small + safe.
  - **F2 chip-types PARTLY COLLIDE.** `assistChip`/`inputChip` slotKinds admit only `[heading,shared:text]`(+icon)
    — like `filterChip` they CANNOT host a `menuTrigger` (B14's exact finding; only `M3e.button` scopes a trigger).
    So set-attr-as-inputChip-that-opens-a-menu needs the menu mechanism switched from m3e popover(`menuTrigger[for]`)
    to Elm `openMenu`-state inline menus — a real interaction re-architecture. `assistChip`/`inputChip` DO have
    `onClick`/`onRemove`/`removable`, so the achievable subset is real (see below).
  - **F3 clean.** Drop `attrValueBadge`; a set attr shows its value in the chip label; keep `slotCountBadge`.
  Escalated to human to choose scope (realizable-now vs deeper chip re-architecture) rather than sink a builder in
  the popover/inline-menu swamp. Next free IDs: **D-048**, **R-023**.

- **D-048 (audit-fix scope chosen by human).** F1 → **plain outlined container** (swap nesting `M3e.card` for a
  bordered `TypedHtml.div`, drop card semantics for the recursion). F2 → **extra-small `M3e.button`s** instead of
  chips (human's call — cleanly resolves the OKF "don't use chips as a substitute for buttons" finding AND the
  chips-can't-host-menus wall in one move; unifies the editor on the button+`menuTrigger[for]`+menu pattern B14
  proved works; also split attribute controls vs slot/add controls into separate groups). F3 → badges for slot
  COUNTS only; a set attr's value goes in its button label, drop `attrValueBadge`. One gauntlet part F2 (task
  #18). Next free IDs: **D-049**, **R-023**.

- **F2: pass — AUDIT-FIX INCREMENT COMPLETE** (build:site exit 0; Playwright 6/6; check:review green; critic clean;
  builder claude/sonnet). Commit `905c82d` (1 file, route, +116/-83). F1: each node is now a plain outlined
  `TypedHtml.div` (`rounded-md-corner-medium border border-outline-variant`), no `M3e.card`. F2: attr + slot
  affordances are extra-small `M3e.button`s (no `filterChip`/`chipSet`), split into separate "Attributes" and
  "Slots" groups, menu-openers keep the `menuTrigger[for]`+sibling-menu pattern. F3: `attrValueBadge` deleted
  (set value → button label `name: value`); `slotCountBadge` retained. Playwright spec UNCHANGED (the tested
  affordances were already buttons). Fresh Opus critic ran build:site + Playwright 6/6, verified no live
  card/chip/chipSet, xs buttons, group split, value-in-label, count-badge kept, no new suppressions, integrity 1
  file, copy-fidelity GREEN → PASS.

## AUDIT INCREMENT — summary for the human
Editor now supports all expected DOM edits — **add child, remove node, edit tag (type-directed, keep-valid)** —
and the m3e-okf audit fixes landed: **outlined containers not nested cards, extra-small buttons not misused chips
(Attributes/Slots split), badges for counts only**. The two audit recommendations that collided with concrete
M3E limits (`m3e-tree` can't host the editor; chips can't host menus) are documented (D-047) and resolved the
realizable way the human chose (D-048). All green on branch `compose-poc`; not pushed/merged. Next free IDs:
**D-049**, **R-023**.

- **D-049 (further human UI feedback → part F3, task #19).** (1) Prefers **nested outlined cards** over F2's plain
  divs — reverts F1; acceptable since outlined cards don't stack elevation (the audit concern was elevated cards;
  already voiced, human decided). (2) Count badges **trailing** — realized as `M3e.badge [for=host, position=after]`
  (button `trailing-icon` slot admits only `shared:icon`, not badge, so trailing is via badge `position=after`,
  not a slot). (3) Tag name = **text-variant button** opening the change-component menu (drop the separate
  edit-icon button); and **`m3e-icon` was built wrong** — must use `TA.name "edit"` attribute, NOT text content
  `[M3e.text "edit"]` (app precedent: `M3e.icon [ TA.name "search" ] []`). Same bug in the remove button
  (Compose.elm:600) AND the live-preview `Render.elm:60` (`Html.node "m3e-icon" .. [Html.text glyph]` → needs a
  `name` attribute, else preview icons don't render) AND Codegen's icon emission — fix all. (4) Buttons
  **`variant=elevated` when unselected, `filled` when selected/filled>0**. Touches Compose.elm + Render.elm (+
  Codegen.elm for the icon snippet). Next free IDs: **D-050**, **R-023**.

- **F3 round 1 (gate red: codegen icon snippet does not compile; strategy: use the compiling `TypedHtml.Attributes.name` form).**
  Commit `ca7c9c4` got 4 of 5 refinements right, but the fresh Opus critic caught a real bug via the snippet
  scratch-compile (spec §15): `Codegen.elm` emits `M3e.Html.icon [ M3e.Attributes.name "glyph" ] []`, but
  `M3e.Attributes.name : Value M3e.Values.Name -> …` needs a `Value`, not a `String` → the copy-paste snippet for
  an icon does NOT compile. (The editor + preview were correct — they use `TypedHtml.Attributes.name : String`.)
  Manager verified the fix: `M3e.Html.icon [ TypedHtml.Attributes.name "close" ] []` compiles (scratch, Success).
  Sent builder back to align Codegen's icon emission to `TypedHtml.Attributes.name` and re-run the scratch-compile.

- **F3: pass** (round 2; build:site exit 0; Playwright 6/6; icon snippet compiles; builder claude/sonnet).
  Commit `ca7c9c4` (4 files: the 5 refinements) + fixup `1bf7e9e` (Codegen icon → `TypedHtml.Attributes.name`,
  the compiling form). Delivered: (1) nested outlined `M3e.card`; (2) trailing count badges (`position=after`);
  (3) tag NAME is a text-variant button opening the change-tag menu (no edit-icon button) + `m3e-icon name=` fix
  across editor/preview/codegen (preview icons + the remove `×` now render); (4) buttons elevated(unset)/
  filled(set) with the set value in the label. Round-1 critic caught the codegen snippet-compile bug (spec §15);
  manager verified the fix form + independently re-ran build:site + Playwright 6/6 on round 2. **UI-refinement
  round complete.** Next free IDs: **D-050**, **R-023**.


- **D-050 (human: inline badges via slot, not positioning → part F4, task #20).** Replace the `for`+`position`
  overlay badge with an inline `M3e.badge [] [ M3e.text count ]` sibling next to the slot button — content in the
  badge's own `unnamed` slot, no `for`/`position`/host-id. Feasible + precedent-backed: app already uses
  `M3e.badge [] [ M3e.text "3" ]` at `docs/app/Route/Guide/Seams.elm:188`; scratch inline badge compiles. Next
  free IDs: **D-051**, **R-023**.

- **F4: pass** (build:site exit 0; Playwright 6/6; manager-verified incl. visual; builder claude/sonnet).
  Commit `bdaa69b` (1 file, +14/-25). `slotCountBadge` → inline `M3e.badge [] [ M3e.text count ]` (content in the
  badge's own slot), wrapped inline-flex as a trailing sibling of each slot button; dropped `for`/`position` and
  the now-unused `slotButtonHostId`; slot-menu wiring untouched (still opens). Matches app precedent
  (Seams.elm:188). Screenshot confirms inline pills, not corner overlays. Small precedent-matching visual change —
  accepted on manager verification (build:site + Playwright + visual) without a separate critic. Next free IDs:
  **D-051**, **R-023**.

- **D-051 (HANDOFF to a fresh Opus-4.8 UI agent, 2026-08-14).** Human requested `/paseo-handoff` to continue the
  editor styling/UX interactively and will DETACH to work with the new agent directly. New requirements handed
  off (styling round): (1) padding is inconsistent — normalize. (2) Text/icon child inputs → LABELED form fields,
  with the field's TRAILING icon = delete button and LEADING icon = drag/drop handle for ordering. (3) Attributes
  & Slots sections → form fields containing BUTTON GROUPS. (4) The count badge should be the button's TRAILING
  ICON — OPEN TYPE QUESTION the human raised: a button's `trailing-icon` slot admits only `shared:icon`, not
  `badge` (verified, D-047) — "is that not possible with the types? should we recast?" → the new agent must
  investigate whether to recast/extend the M3e type (or the elm-cem facts) to admit a badge in that slot, vs an
  alternative. (5) The `+` prefix on slot buttons → an ICON, not the literal "+". (6) Card header stays the tag
  name, but add a LEADING drag/drop handle icon and TRAILING edit + delete icons. NOTE reordering (2/6 drag-drop)
  is spec NON-GOAL #1 and needs a new core `MoveChild` Msg in `elm-cem-compose` — a real core extension. Receiving
  agent: claude/claude-opus-4-8 (ui role), same worktree/branch. Next free IDs: **D-052**, **R-023**.

## STYLING ROUND (D-051 handoff — new UI agent, `claude-opus-4-8`, working interactively with the human)

Manager = the receiving Opus UI agent (this context). Builders = `claude/sonnet` background agents for the
mechanical/parallel work; recast + consumer-wiring done directly by the manager (prefs: styling/visual = Opus).
Human decided both open questions live: item 4 → **recast the button type** (their instinct: button type too
strict); reordering → **up/down buttons**, not drag-drop. Landed in four commits.

- **G1 (safe styling pass) — pass.** Commit `33358e3` (`Compose.elm` + `compose.spec.ts`, sonnet builder).
  Items 1/5/3/2: normalized spacing (card body `gap-3`, groups `gap-2`, child indent `pl-4`); slot-button `+`
  literal → leading `M3e.icon [ TA.name "add" ] []`; Attributes/Slots buttons now sit in `M3e.buttonGroup`
  under their plain label (human chose buttonGroup-under-label over the literal "formField-wrapped group",
  which would misuse formField); `ChildText`/`ChildIcon` → `M3e.formField` (label slot + raw `<input>` in
  unnamed + delete `iconButton` in the `suffix` slot; no fallback needed). Gates: build:site, check:review,
  check:compose-attrs, Playwright 6/6, copy-fidelity all green. **A11Y FINDING (open for human):**
  `m3e-button-group` gives any `toggle` child `role="radio"` and the group `role="radiogroup"` — implying a
  single-select exclusivity our INDEPENDENT attribute/slot toggles do NOT have. Builder updated 4 Playwright
  locators `button`→`radio` (assertions unchanged). Candidate fix: set `multi=True` on the groups (buttonGroup's
  own attribute) so children read as independent, or reconsider buttonGroup for these non-selection controls.
  Recorded, NOT yet fixed.

- **D-052 (up/down reorder = new core capability; human chose it over drag-drop). CORE EXTENSION.** Spec
  NON-GOAL #1. Human picked up/down buttons over HTML5 drag-and-drop (simpler, accessible, browser-testable).
  Added `MoveChild Path String Int Int` (`parentPath slotName fromIndex toIndex`) to `Cem.Compose` (v1.1.0 →
  **1.2.0**), TDD'd. Semantics: resolve parentPath (unresolvable = no-op); `fromIndex` OOB = no-op; `toIndex`
  clamped to `[0, len-1]` (so move-up-from-top / move-down-from-bottom are no-ops); pure list reorder, NO
  validity re-check/pruning (moving within a slot can't invalidate); `openMenu` cleared via the existing `edit`
  helper (mirrors `RemoveChild`). Commit `86d4d5c` (sonnet builder, TDD): tests 74 → **85** (new `MoveTest.elm`
  incl. full-tree sibling-slot identity checks). `gate` green, `grep -ri m3e src` empty, 3 deps. Note:
  `List.Extra.insertAt` absent in this list-extra range → hand-rolled `take/drop` splice, no new dep. Next free
  IDs: **D-055**, **R-023**.

- **D-053 (item-4 badge-in-button-trailing-slot recast; human chose recast over the no-type-change overlay).
  GENERATED-CODE DEVIATION — FLAG.** The button `trailing-icon` slot admitted only `shared:icon`, so a count
  badge could not sit in the button chrome. **Material-valid** (the type is stricter than needed): `NavMenuItem`
  ALREADY admits `badge` in a slot, and badge-decorates-host is canonical Material. The clean flow (edit config
  + regen) is BLOCKED: `src/` is the committed `M3e.Component.*`/`M3e.Build.*` layout, but a fresh `gen:src`
  emits the generator's current FLAT `M3e.*` layout — **271 files differ** (measured; D-012/D-034 Move-1/flat-cut
  debt). So the recast is: (a) `config/slots.json` — add `"badge"` to Button `trailing-icon` kinds (the durable,
  correct, mergeable source-of-truth edit); PLUS (b) a **targeted hand-edit of 2 generated files** —
  `M3e/Internal/Types/Button.elm` (`TrailingIconSlot` gains `badge : Brand`) and `M3e/Review/Facts.elm` (button
  `trailing-icon` slotKinds gains `"badge"`), both alphabetically ordered to match generator output and
  mirroring NavMenuItem's existing admission. This is a documented, minimal, reversible deviation from the
  family's "never hand-edit generated output" rule, forced ONLY because a clean regen is blocked by unrelated
  layout debt; when the flat-cut reconciliation lands on main, a regen reproduces the same admission from the
  config edit alone. PROVEN: a badge now typechecks into a button trailing-icon slot (scratch `elm make`:
  Success). Commit `55ab1cb` (3 files, manager). build:site + check:review + copy-fidelity green (content edits
  only, no new files). **The "merge the fix in main" the human wants = the `config/slots.json` change.** Next
  free IDs: **D-055**, **R-023**.

- **D-054 (consumer wiring — reorder UI + header relayout + badge into the recast slot; item-6 "no edit pencil"
  judgment). UX DECISION.** Commit `3a04052` (`Compose.elm` + `compose.spec.ts`, manager, direct — prefs: styling
  = Opus). (1) Reorder: `reorderControls` renders leading up/down `iconButton`s firing `MoveChild` (disabled at
  the end each can't move toward; hidden when a slot holds ≤1); a node derives its own `(parentPath, slotName,
  index)` from the last step of its path (`nodePosition`). (2) Header (item 6): `headerRow` = leading reorder +
  tag-name change-tag button + trailing delete; root (empty path) shows only the name; per-node delete MOVED off
  the child row into the header. **JUDGMENT CALL (flag):** item 6 asked for a trailing EDIT icon too, but the
  tag-name button ALREADY opens the change-component menu (it IS the edit affordance, per D-049) — a second
  control opening the identical menu is confusing, so NO separate edit pencil was added. Reversible if the human
  wants the explicit icon. (3) Item 4 usage: `slotCountBadge` moved into each slot button's `trailing-icon` slot
  (`M3e.Component.Button.trailingIcon (slotCountBadge info)`), dropping the detached badge row. Gates: build:site
  exit 0, check:review clean, check:compose-attrs OK, **Playwright 7/7** (added a reorder test that swaps two
  siblings and asserts the live-preview DOM order flips — scoped past m3e-list's internal `<slot>` child and the
  nav; caught two real locator pitfalls before landing), copy-fidelity GREEN. Manager verified visually
  (screenshot): badge renders inside the button trailing edge, header shows ▲▼/name/×, `+` is the add icon.
  **OPEN POLISH (for the human, not yet fixed):** (i) the slot button-GROUP row overflows horizontally and gets
  clipped when a node has many slots; (ii) red `0/1` count badges on EMPTY slots read as alarming (red =
  notification). Plus the D-052-round buttonGroup `role=radiogroup` a11y question above. Next free IDs: **D-055**,
  **R-023**.

- **D-055 (human feedback: buttonGroup is the wrong primitive + want a pre-filled starter). UX FIX.**
  Commit `608a9d2` (`Compose.elm` + `compose.spec.ts`, manager). (1) **buttonGroup → `flex flex-wrap gap-2`.**
  The human called the horizontal overflow "not acceptable" — `m3e-button-group` overflows/clips instead of
  wrapping, and (the open a11y issue) stamps `role=radiogroup`/`role=radio` on our INDEPENDENT attribute/slot
  toggles. Both `attrGroup` and `slotGroup` now wrap the buttons in a plain `flex flex-wrap` row; buttons are
  plain `role=button` again → RESOLVES the radiogroup a11y concern AND the overflow in one move. (2) **Starter
  tree.** `init` now folds `starterEdits` (2 `listItem`s, each with an `unnamed` text label "First item"/"Second
  item") over `Cem.Compose.init` — the editor opens with content to work from, and because reorder arrows only
  render when a slot holds >1 child (the human "wasn't seeing the arrows" on the previously EMPTY root — working
  as designed, just nothing to reorder), the starter surfaces them immediately. All of it is deletable.
  (3) **Playwright reworked** for the new starting DOM: `radio`→`button`; scratch-built tests add their own node
  and scope to it via `.last()` (a new child appends last) + `:visible` (all menus are always in the DOM, only
  the clicked one shows); the reorder test now drives the starter's two items directly and asserts the labels
  swap. 7/7. Gates: build:site, check:review, check:compose-attrs, copy-fidelity green. **STILL OPEN (flagged,
  not fixed):** red `0/1` count badges on EMPTY slots read as alarming (`m3e-badge` default is the error color) —
  a color/variant tweak awaiting the human's call; and the item-6 "no separate edit pencil" judgment (D-054)
  still stands for confirmation. Next free IDs: **D-056**, **R-023**.

- **D-056 (human: neutral badge, numerator only, hidden at zero). UX POLISH — resolves D-055's open badge item.**
  Commit `574dbc7` (`Compose.elm`, manager). The slot-count badge now: (1) shows just `info.filled` (no `/max`
  denominator); (2) renders NOTHING when `filled == 0` — `slotCountTrailing` returns `[]`, spliced into the button
  content list via `trailingIcon`'s polymorphic result type; (3) is NEUTRAL, not the `m3e-badge` default error
  color — since badge has no color/variant attribute, its `--m3e-badge-container-color`/`--m3e-badge-color` CSS
  custom properties are overridden to `surface-container-highest`/`on-surface-variant`. `slotCountText`
  (the old filled/max helper) deleted. Verified visually: empty slot buttons are clean, filled ones carry a quiet
  grey count. Gates: build:site, check:review, check:compose-attrs, Playwright 7/7, copy-fidelity green. **STILL
  OPEN:** only the item-6 "no separate edit pencil" judgment (D-054) awaits human confirmation. Next free IDs:
  **D-057**, **R-023**.

- **D-057 (human feedback: card padding, heading tag, explicit edit icon, reorder-row-at-trailing, text default).
  UX ROUND — supersedes the D-054 "no edit pencil" judgment (human DID want the edit icon).** Commit `f0cc72b`
  (`Compose.elm` + `compose.spec.ts`, manager). (1) **Padding:** attr/slot groups were flush to the card's left
  edge — the whole card body is now one `p-3` container (children keep `pl-4`). (2) **Tag → `M3e.heading`**
  (title/small): the tag name is a plain heading; `nameControl` split into `tagHeading` + `editControl`.
  (3) **Explicit edit icon button** (`editControl`): a "Change component" `M3e.button` (icon-only, hosts the
  `menuTrigger` — the only host that scopes a trigger) opens the change-component menu; renders nothing when
  `componentOptions` is empty. (4) **Reorder = horizontal row at the TRAILING end** (`flex-row`, after the edit
  control in the header and after the field in text/icon rows), not a leading vertical stack. (5) **New text
  children default to "lorem ipsum":** the route `update` intercepts `AddTextChild` (via `applyCompose`) and seeds
  the just-added empty `ChildText` with `SetChildContent` — the headless core stays content-agnostic (adds `""`);
  the placeholder is a consumer/demo choice, guarded (`childAt … == Just (ChildText "")`) so it never clobbers
  real content. Playwright 8/8: tests 4/5 now open the "Change component" icon button (`.first()`/`.last()`); added
  a test asserting a new text child renders "lorem ipsum" in the preview. build:site, check:review,
  check:compose-attrs, copy-fidelity green. No remaining open styling items. Next free IDs: **D-058**, **R-023**.

- **D-058 (human feedback batch — 6 items, split into a no-state pass + a stateful pass). UX ROUND.** Two commits.
  **`aa3a31f` (no state):** (1) `tagHeading` → `variant title, size medium` (was small). (2) removed `pl-4` from the
  children container — nesting still reads via the card border. (3) Attributes/Slots: the group LABEL now sits
  inside the same `flex flex-wrap items-center` row as the buttons, so label + buttons wrap together (was a fixed
  label line above a separate wrapping row). (4) `editControl` → `M3e.iconButton` (its `Content` admits
  `menuTrigger`; **verified the trigger still scopes** — Playwright tests 4/5 open its menu and pass), matching the
  reorder/delete iconButtons. **`62c02ed` (stateful):** (5) **Collapsible cards** — each node card gets a leading
  chevron `iconButton` toggling its `pathId` in new `Model.collapsed : Set String`; collapsed hides the body
  (attrs/slots/children), header stays. (6) **"Prefill examples" toggle** — an `M3e.switch` in a new `panelBar`
  drives `Model.prefill`; `applyCompose` (now `Bool -> Msg -> Model -> Model`) seeds a fresh text child with
  "lorem ipsum" AND gives a fresh child COMPONENT an example text child in its first text-affording slot
  (`firstTextSlot`) when on, empty when off — every seed guarded against clobbering real content. **Architecture:**
  the editor view now emits the route `Msg`; leaf editor fns still produce `Cem.Compose.Msg` and are lifted with
  `M3e.mapMsg ComposeMsg` at the `viewNode`/`childRow` boundaries, while the chevron + switch emit `Msg` directly
  (`view` drops its old blanket `ComposeMsg` wrap; static heading/preview/snippet are msg-polymorphic and unify).
  Playwright 10/10 (added: edit-as-iconButton menu still works via tests 4/5; collapse hides/restores body;
  prefill-off adds empty). Both commits: build:site, check:review, check:compose-attrs, copy-fidelity green.
  Next free IDs: **D-059**, **R-023**.
