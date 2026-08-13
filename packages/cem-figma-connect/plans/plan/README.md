# cem-figma-connect — Implementation Plans (index)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement these plans task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking. Read
> [`../00-mission-and-decisions.md`](../00-mission-and-decisions.md) and
> [`../01-architecture.md`](../01-architecture.md) before ANY plan.

Six plans. Each produces a working, verifiable state on its own. The tracer bullet runs
through A→B: **m3e-button end-to-end (ingest → match → correspondence → both labels →
publish to `KujuFlfJSwHI6ua1b7RZvL` → MCP verification)** before any breadth work.

> ⚠️ **fileKey conflict (needs an owner decision).** This document names
> `KujuFlfJSwHI6ua1b7RZvL` as the canonical publish target (here, in the kit-version pin
> below, and in `00-mission-and-decisions.md` D2), but the actual profile
> (`profiles/m3-kit/profile.json`) and the 2026-07-14 handoff use
> `UtwpUdPiOZEuxp8Nq1d5yQ`. These disagree. This has **not** been reconciled — do not assume
> either is authoritative; see `STATUS.md`. (Not resolved here on purpose.)

| Plan | What | Depends on | Parallel? |
|---|---|---|---|
| [A — engine core](A-engine-core.md) | Scaffold, CEM+dts ingest, figma-export schema + extraction port, matcher, correspondence schema, gap report | — | starts alone |
| [B — emitters & publish](B-emitters-publish.md) | html-label emitter, emitter API, Elm emitter bridge, publish/check/unpublish runner, tracer publish | A (correspondence schema + button entry) | after A's tracer slice |
| [C — visual gate](C-visual-gate.md) | Render harness productization, export-png batching, diff pipeline, review webapp, gate wiring | A (correspondence drives parity states); B for gate-blocks-publish wiring | bulk parallel with B |
| [D — tokens](D-tokens.md) | Token table, codeSyntax stamping, density policy, mismatch classification | A (figma variables ingest) | parallel with B/C |
| [E — consumer: elm-m3e](E-consumer-elm-m3e.md) | Full-breadth m3-kit profile (all matched components + icons), elm-m3e integration + CI drift guards | B, C (gate), D (tokens in snippets) | after tracer proven |
| [F — consumer: Avetta](F-consumer-avetta.md) | Published-library resolution test, ADS delta profile, branding tokens, stale mapping retirement | E | last |

**herdr parallelization:** A is the single-threaded foundation (~its first half). Once A's
tracer slice lands (button correspondence entry + schemas), B, C, D can run in **separate
herdr panes/worktrees** — they touch disjoint `src/` subtrees by design. E fans out
per-component work (one subagent per component family) against the frozen A–D core. The
orchestrator holds this index; workers hold one plan file each.

## Ground rules for every plan

- **This repo is PRIVATE until release** (user decision D9). No publishing to npm; no
  public GitHub until the user says so.
- **Branch per plan** (`plan/a-engine-core`, …); commit after every task (conventional
  commits). Never commit to `main` directly once implementation starts.
- **Determinism is a gate, not a preference.** Every generator must be byte-stable:
  regenerate + `git diff --exit-code` on generated outputs before claiming a task done
  (pattern proven in tailwind-m3e-web's `prepublishOnly` and VOLT-2003's `--check`).
- **Never edit generated files by hand**; drift/orphan checks enforce this (Plan B).
- **The matcher never overwrites human decisions** — provenance-checked merge (Plan A).
- **Node-id anchors, keys are cache** (evidence #5): any code that stores a component key
  must record the fileKey it came from and refresh at publish time.
- **Figma writes only where authorized**: canonical publishes to `KujuFlfJSwHI6ua1b7RZvL`;
  mutation experiments to the throwaway Copy (`iPFL8MH2R1Xphe94j7g809`); ADS work only in
  Plan F with explicit user sign-off per step.
- **Human checkpoints are batched** and marked `⚑ HUMAN` in plan tasks (Figma desktop
  sessions, token-gated publishes, review-webapp passes).
- **Verification bar for engine code** (run before claiming any task done):
  `node --test` (unit suites), regenerate-and-diff on all generated artifacts, and — for
  publish-touching tasks — `npx figma connect publish --dry-run --skip-update-check` green.
- **elm-m3e / elm-cem verification bars** (Plan E): the post-review-2026-07 bars from that
  effort's index (elm make, elm-review, elm-test, `docs && pnpm run check`), plus this
  repo's drift checks.
- **Evidence citations**: when a plan step relies on a verified fact, cite the ledger item
  (e.g. "evidence #5") instead of re-arguing it.

## The kit-version pin

The canonical profile pins: kit fileKey `KujuFlfJSwHI6ua1b7RZvL` (user's copy), the
checked-in dump (`research/figma-dumps/m3-kit-components.json`, 5,770 nodes, 2026-07-10),
and `@m3e/web` **2.5.14**. Kit updates or @m3e/web bumps re-run the matcher; diffs surface
in the gap report + correspondence diff (never silent).

> ⚠️ **This `KujuFlfJSwHI6ua1b7RZvL` value conflicts with `profiles/m3-kit/profile.json`
> (`UtwpUdPiOZEuxp8Nq1d5yQ`) — unresolved owner decision.** See the note at the top of this
> file and `STATUS.md`.

## Done means

1. All six plans' acceptance boxes checked.
2. In the user's kit copy: Dev Mode + MCP return Web Components AND Elm snippets on every
   matched, gate-passed component; generated layout code speaks `--md-sys-*`.
3. In Avetta's org (Plan F): the published-library resolution question answered with
   evidence; ADS delta profile publishes green; no stale `Ui.*` mappings remain.
4. Gap report published as a maintained artifact.
5. Follow-up reminders emitted (NOT executed): upstream PR to `matraic/m3e`; token rotation;
   public-release checklist (license/IP review of `extract/`).
