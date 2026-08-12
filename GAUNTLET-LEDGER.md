# GAUNTLET-LEDGER — elm-cem-workspace Phase 0

Manager: Opus (Gauntlet Loop on Paseo). Plan:
`docs/superpowers/plans/2026-08-12-elm-cem-workspace-phase0-gauntlet.md`.
Spec: `docs/superpowers/specs/2026-08-12-elm-cem-workspace-spine-design.md`.

A part is DONE iff it has a `pass` line. A milestone is DONE iff it has an `integrated` line.

## Milestone checklist

- [x] **M0** Workspace shell — 0.a skeleton, 0.b Elm-in-JS convention
- [ ] **M1** elm-cem in + facts bundle + coverage audit — 1.a move, 1.b audit, 1.c faces, 1.d one `Cem.Facts`
- [ ] **M2** elm-m3e onto workspace elm-cem — 2.a
- [ ] **M3** Consumers onto the bundle (parallel) — 3.a cem-figma-connect, 3.b m3e-okf, 3.c tailwind
- [ ] **M4** `bump` orchestrator + drift gate — 4.a, 4.b
- [ ] **M5** Retire migration dead weight — 5.a
- [ ] **M6** Deep clean (separate commit) — 6.a, 6.b

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
