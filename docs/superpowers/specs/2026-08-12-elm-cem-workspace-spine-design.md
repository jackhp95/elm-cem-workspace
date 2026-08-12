# elm-cem-workspace — Sustainability Spine (Phase 0) Design

> **Status:** Design / spec, awaiting review. Authored 2026-08-12 via superpowers brainstorming.
> **Scope:** Phase 0 of the "full unified vision" (BRIEF.md). This spec covers ONLY the
> sustainability spine. Phases 1–5 are captured as roadmap context but are out of scope here
> and get their own spec → plan → build cycles.
> **Home note:** this doc currently lives in `cem-figma-connect` (the initiative's existing
> planning hub — see `plans/BRIEF.md`, `plans/00-mission-and-decisions.md`). It migrates into
> the new `elm-cem-workspace` monorepo at migration Step 0.
>
> **Framing:** the workspace is **elm-cem-centered** — `elm-cem` (the CEM→Elm codegen engine) is the
> producer the spine turns on; `elm-m3e` is the flagship *brand* fed to it; the Figma/Tailwind/OKF tools are
> output modalities. Named `elm-cem-workspace`; brand- and output-pluggable.

## 1. The endgame and where Phase 0 sits

The target is the full BRIEF.md vision: `@m3e/web` (CEM) ⋈ Figma ⋈ Tailwind merged into one
model, from which Figma Code Connect for **web components + Elm + Tailwind** (plus hybrid
outputs), a token model, and a visual gate all fall out — eventually upstreamed to
`matraic/m3e`. That is six roughly-independent subsystems. It is sequenced foundation-first:

| Phase | Subsystem | Status today | This spec |
|---|---|---|---|
| **0** | **Sustainability spine** — one canonical CEM-facts producer; monorepo; one gated `bump` | ❌ the big gap | **← IN SCOPE** |
| 1 | One html↔elm engine — package `to-elm.mjs`'s mapper; kill the duplicate *shape* logic | ⚠️ duplicated | out of scope |
| 2 | Tailwind Code Connect label + hybrid outputs | ⚠️ token bridge only | out of scope |
| 3 | Figma → Elm reverse direction | ❌ not built | out of scope |
| 4 | Token model hardening (tiers, density, "required code change" surfacing) | ⚠️ partial | out of scope |
| 5 | Upstream to `matraic/m3e` | ❌ not started | out of scope |

**Why the spine comes first even though the target is the whole vision:** adding the Tailwind
label, hybrid outputs, and the reverse direction on top of today's four-parser / eight-step /
already-drifted base multiplies the exact fragility the vision is supposed to remove. Build the
foundation, then layer on it.

## 2. Problem — the current fragility (verified 2026-08-12)

Five repos under `~/code/jackhp95/` all derive from one upstream (`matraic/m3e` → `@m3e/web` →
its CEM), but they are threaded together by hand-maintained copies and divergent pins:

- **Four independent CEM parsers, zero shared library.** `m3e-okf/scripts/extract.mjs`,
  `elm-cem/bin/elm-cem.js`, `cem-figma-connect/src/ingest/cem.mjs`, and
  `tailwind-m3e-web/bin/generate-component-utilities.mjs` each re-parse the same CEM facts
  (tags/attrs/enums/slots/defaults). Overlap on the primitive facts is ~100%, extracted 3–4×.
- **Four different pins in two version clusters that have already drifted.** m3e-okf pins a raw
  git SHA of `matraic/m3e` main (`a2844143`, `data/sources.json`); elm-m3e pins npm `^2.7.3`;
  cem-figma-connect pins a checked-in fixture `2.7.0`; tailwind declares `^2.5.14` but runs an
  installed `2.5.11`. A git SHA is not even comparable to a semver range without resolving it.
- **Two duplicate html→elm projections** producing the identical shape
  (`M3e.Button.view [ M3e.Button.variant M3e.Values.filled ] [ …, Kit.text ]`):
  elm-m3e's `docs/scripts/examples-gen/lib/to-elm.mjs` (oracle-driven from CEM+`slots.json`)
  and cem-figma-connect's `profiles/m3-kit/emitters/elm.mjs` + `elm-facts.json`
  (re-measured from elm-m3e's generated `Facts.elm`). Phase 0 kills the duplicate *facts*
  (`elm-facts.build.mjs`); Phase 1 later kills the duplicate *shape* logic.
- **Five vendored copies + one copy-pasted code path** that all rot silently on a bump:
  cem-figma-connect's `test/fixtures/m3e-web-{2.7.0,2.5.14}/` (CEM copies),
  `test/fixtures/tailwind-m3e-web-0.1.0/` and elm-m3e's `docs/vendor/tailwind-m3e-web/`
  (tailwind CSS copies), `cem-figma-connect/profiles/m3-kit/elm-facts.json` (re-measured elm
  facts, pinned to elm-m3e commit `336e7242`), and m3e-okf's hand-port of elm-cem's
  `reconcileTagNames`.
- **A `@m3e/web` bump is therefore ~8 manual re-pin+regen+commit steps** across 4 repos + the
  elm-cem tool, with ordering constraints and no single command.

## 3. Target architecture

Two collapses, composed — a **monorepo** as the physical container, with a **single facts
producer** as the pattern inside it. They operate at different layers and reinforce each other:
workspace deps replace the vendored copies; one producer replaces the four parsers.

The key enabling fact: **elm-cem is already the one tool that reads the CEM, resolves the
`.d.ts` enum unions, applies the per-brand config, and knows the generated Elm API surface**
(it emits both `M3e.*` and `M3e.Review.Facts` from a single model). So it can emit that model
as a canonical **facts bundle with three faces**, and every other repo stops parsing:

```
                        @m3e/web CEM   (single pin, one place)
                               │
                          ┌────▼─────┐
                          │  elm-cem  │   ← the ONE producer (CEM + .d.ts + config → model)
                          └────┬─────┘
        ┌──────────────────────┼─────────────────────────────┐
   Face A: Elm source    Face B: cem-facts.json        Face C: elm-api-facts.json
   (M3e.* + Facts.elm)   (tags/attrs/enums/slots/       (module/entry/setter/token/
        │                 defaults/cssProps/.d.ts-        surface names — the projection
        ▼                 resolved unions)                elm-m3e's generated API exposes)
     elm-m3e                    │                                │
   (M3e.* pkgs)     ┌───────────┼───────────┐                    │
                    ▼           ▼           ▼                    ▼
                m3e-okf     tailwind-    cem-figma-connect    cem-figma-connect
             components.   m3e-web       (matcher: CEM ⋈     (Elm emitter: consumes
                json       utilities      Figma dump →         Face C → DELETES
                           (--md-*)       correspondence)      elm-facts.build.mjs)
```

**What each face is for**

- **Face A — Elm source.** Unchanged in kind: elm-cem keeps generating `M3e.*` +
  `M3e.Review.Facts` into elm-m3e. (The duplicate `Facts.elm` mirror in `elm-m3e-components/`
  collapses to one source of generation.)
- **Face B — `cem-facts.json`.** The primitive CEM facts, `.d.ts`-resolved, that m3e-okf,
  tailwind, and cem-figma-connect's *matcher* consume instead of re-parsing. This is the
  artifact that ends the four-parser drift.
- **Face C — `elm-api-facts.json`.** The generated-Elm API projection (module, entry
  constructor, per-surface forms, setter names, token names) that cem-figma-connect's *Elm
  emitter* consumes. Because elm-cem *emitted* those names, it hands them over directly —
  cem-figma-connect no longer re-measures elm-m3e's output, so
  `profiles/m3-kit/emitters/elm-facts.build.mjs` (the ~900-line re-parser) and the committed
  `elm-facts.json` are **deleted**.

**Non-goal for Phase 0:** consolidating the two html→elm *shape* implementations. Face C removes
the duplicate *facts*; cem-figma-connect's `elm.mjs` keeps its own shape logic (`renderExample`
etc.) for now. Merging that with `to-elm.mjs` into one importable engine is Phase 1.

## 4. The facts-bundle schema — the linchpin

The bundle is the single most load-bearing artifact; the whole spine's correctness rests on it
being **rich enough that all four consumers can fully drop their own parsers.** If it misses a
field a consumer needs, that consumer keeps a parser and the drift returns.

**De-risking task (first real task of implementation):** an explicit **coverage audit** —
enumerate every field each consumer reads from the CEM (or re-measures from generated Elm)
today, and confirm the bundle carries it:

- **m3e-okf** reads: tag, attributes (+ `type.text` unions), defaults, slots, events,
  cssProperties, **and** README-vs-code drift provenance (its `report.md` kinds:
  `DEFAULT-MISMATCH`, `UNDOCUMENTED`, `EXAMPLE-DRIFT`). Provenance is m3e-okf-specific and may
  stay a thin layer *over* the bundle rather than in it — the audit decides.
- **tailwind-m3e-web** reads: `cssProperties` (the `--md-*` surface) + density tokens.
- **cem-figma-connect (matcher)** reads: tag, attributes, `.d.ts`-resolved enum value sets,
  slots, and keyword/synonym descriptions used for fuzzy matching.
- **cem-figma-connect (Elm emitter)** reads Face C: per-component `module`, `entry`, per-surface
  `form` (double-list / record-double-list / pipeline), `setters` (verified-exposed), enum
  `token` names, `slotSetters`, `actionModule`, plus the userland-seam facts (`textSeam` =
  `Kit.text`, `htmlSeam` = `TypedHtml`, `attrSeam` = `Native`). These seams are config-declared
  userland conventions, not library exports — they remain profile config, not bundle facts.
- **elm-cem itself** (Face A generation) already holds the full model these derive from —
  **but** Face C requires *surfacing* fields elm-cem currently computes internally for codegen
  (per-surface `form`, `actionModule`, the exposed-setter/exposed-token sets) as emitted data.
  The win is reliability: today cem-figma-connect *re-measures and re-verifies* these from
  generated output it did not produce; emitting them from the producer removes the guesswork
  (the producer knows exactly what it exposed). The coverage audit must confirm the model
  surfaces every Face-C field, and elm-cem may need to expose model fields it keeps internal today.

The bundle carries a **provenance stamp**: the `@m3e/web` version/SHA it was generated from,
and (for Face C) the elm-cem/elm-m3e generation commit, so any consumer can assert it is reading
current facts. This replaces today's scattered `elmM3eCommit` / `data/sources.json` / fixture
version pins with one stamp.

## 5. The `bump` orchestrator

One gated command replaces the ~8 manual steps. `m3e bump <version>`:

1. **Re-pin once.** One `@m3e/web` entry (at the elm-cem package that reads the CEM);
   `pnpm install`; one lockfile moves. One anchor — no SHA-vs-semver mismatch.
2. **Regenerate the bundle once.** elm-cem re-reads CEM + `.d.ts` + config and emits Faces A/B/C.
3. **Fan out to consumers in DAG order — each re-reads the bundle, none re-parses:** elm-m3e
   recompiles; m3e-okf rebuilds `components.json`/skill/OKF; tailwind rebuilds utilities;
   cem-figma-connect re-runs `match` → `emit`.
4. **Gate at every hop.** The union of the family's existing gates — Elm compile +
   elm-review-cem, m3e-okf `check:skill`/`check:okf`, cem-figma-connect `check` (0 drift / 0
   orphan) **and the visual-diff gate** — plus one new **cross-cutting drift gate**: regenerate
   everything and diff against committed; any nonzero diff means a consumer is stale ⇒ red.
5. **Report, don't auto-publish.** Emit a human-readable diff: new components, changed
   enums/attrs (cem-figma-connect's `gap-report` already produces this), and — the one that
   needs a human — any component whose Figma match or **visual diff now fails**. The existing
   review webapp handles these.
6. **Coordinated release** after human approval: Elm packages → Elm registry, JS packages → npm,
   skill/OKF, and the token-gated Figma Code Connect `publish`, in dependency order.

**Properties:**

- **Idempotent.** Re-running on an unchanged pin is a byte-stable no-op — cem-figma-connect's
  `emit` and m3e-okf's `gen` are already deterministic. Determinism is what makes the drift gate
  a reliable equality check.
- **Upstream-staleness is a family signal.** m3e-okf's `check:staleness` generalizes to "upstream
  moved past our pin ⇒ a bump is available" — the trigger to *run* `bump`. It stays outside the
  blocking gate (it reports about the outside world, not about this push).

## 6. Dual-ecosystem handling

This is a monorepo spanning **two package ecosystems**, not a plain pnpm workspace:

- **JS side** — elm-cem, m3e-okf, tailwind-m3e-web, cem-figma-connect: a pnpm workspace manages
  the dependency graph; the facts bundle is consumed via `workspace:*`.
- **Elm side** — the `elm-m3e` brand packages (the `core`/`components`/`builder` split, **retained** — the
  split exists for Elm's package **size limit**, so Phase 0 does NOT collapse it), plus the separate packages
  (`elm-m3e-icons`, `elm-m3e-review-facts`, `elm-review-cem`, `elm-cem-facts`, and the IR / typed-html
  substrate): these have their own `elm.json` registry graph pnpm cannot see. Within the workspace they
  resolve by `source-directories` / local paths during development; at release (Phase 5) they publish to the
  Elm registry. The published-boundary shape (monolith vs split) is a **Phase-5 verify-then-decide** item
  (reconcile the size ceiling against the 2026-08-12 liaison's "monolith is registry-faithful" claim). One
  fact binds Phase 0: **exactly one `Cem.Facts`** must exist in the graph — today `elm-cem-facts` and
  `elm-review-cem` both expose it, a duplicate-expose that breaks a consumer's `review/` compile —
  consolidated to `elm-cem-facts` (plan M1.d).

The `bump` orchestrator therefore drives **both** toolchains (invokes `elm` builds/tests and the
`pnpm` scripts) in one DAG. The task runner is the one component that must understand the whole
family graph; individual packages keep their existing `gen:*`/`check:*`/`test:*` scripts.

## 7. Consumer rewiring — what changes, what gets deleted

- **elm-m3e:** `gen:src` points at the workspace elm-cem (not `../elm-cem`). Generated `Facts.elm`
  has one source of truth (the mirror in `elm-m3e-components/` is generated, not hand-kept).
- **m3e-okf:** `scripts/extract.mjs` reads Face B instead of cloning `matraic/m3e` and parsing;
  the hand-ported `reconcileTagNames` is **deleted**. The README-drift audit stays as a thin
  layer over the bundle. `data/sources.json` SHA pin is subsumed by the bundle's provenance stamp.
- **tailwind-m3e-web:** `bin/generate-component-utilities.mjs` reads Face B's `cssProperties`
  instead of parsing `node_modules/@m3e/web`. The stale-install problem (declares 2.5.14, runs
  2.5.11) disappears — there is one install.
- **cem-figma-connect:** `src/ingest/cem.mjs` + `src/ingest/dts-inline.mjs` read Face B (the
  `.d.ts` inlining moves to the producer). The Elm emitter reads Face C. **Deleted:**
  `profiles/m3-kit/emitters/elm-facts.build.mjs`, `profiles/m3-kit/elm-facts.json`, and the
  `test/fixtures/m3e-web-*` + `test/fixtures/tailwind-m3e-web-*` vendored copies. The engine stays
  general (CEM-agnostic); m3e-specificity remains quarantined in `profiles/m3-kit/`. The Figma
  export dump stays a checked-in input (it is Figma-side truth, pinned by `kitVersionTag`, and is
  not derived from the CEM).

## 8. Migration path (incremental, producer-first, green at every step)

Simplified by the confirmed constraints — **nothing is released and history-loss is acceptable
(all prerelease)** — so repos are brought in by **flat copy** (no `git subtree`/`filter-repo`),
and there are no registry identities to preserve.

- **Step 0 — workspace shell.** New `elm-cem-workspace` repo (a fresh, elm-cem-centered umbrella so no
  single brand's identity dominates), `pnpm-workspace.yaml` + Elm source layout + the top-level task
  runner. Nothing moved yet.
- **Step 1 — elm-cem in first** (the producer; brings `elm-cem-facts` / `elm-typed-html`).
  **Add the "emit facts bundle (Faces B + C)" output.** Run the **coverage audit** (§4). The
  bundle now exists as a workspace artifact.
- **Step 2 — elm-m3e.** Point `gen:src` at workspace elm-cem. Verify Elm compiles +
  elm-review-cem green.
- **Step 3 — one JS consumer at a time onto the bundle:** cem-figma-connect first (biggest win:
  deletes `elm-facts.build.mjs` + the CEM fixture; its byte-deterministic `check` proves parity),
  then m3e-okf (drops the parser + `reconcileTagNames`; `check:skill`/`check:okf` prove parity),
  then tailwind.
- **Step 4 — wire `bump` + the drift gate** across the colocated family.
- **Step 5 — retire** the vendored copies, the duplicate `Facts.elm` mirror, and the dead parsers.

Each step is independently green. Value accrues: after Steps 1–2 the Elm side is unified; after
Step 3 each consumer sheds its parser; after Step 4 the bump is one command.

## 9. Testing, gates, drift-detection

- **Determinism is the test.** Every producer/emitter is byte-deterministic; the drift gate =
  "regenerate from the current bundle, diff against committed, require zero diff." This is a hard
  equality check, run in CI, that structurally cannot pass while any consumer is stale.
- **Existing gates are retained and unioned** into `bump` and CI: Elm compile + elm-review-cem
  (elm-m3e), `check:skill` / `check:okf` (m3e-okf), `check` 0-drift/0-orphan (cem-figma-connect),
  and the visual-diff gate. The old `elm-facts.build --check` sentinel (which asserted the
  re-measured elm facts were current) is **superseded** by the bundle provenance stamp + drift
  gate — the facts are now produced, not re-measured, so staleness is a stamp mismatch, not a
  re-parse.
- **The facts bundle gets its own schema validation** (required fields per face; provenance stamp
  present) so a malformed regen fails fast rather than silently under-serving a consumer.
- **Coverage audit (§4) is a one-time gate** proving no consumer needs a field the bundle lacks,
  run before each consumer is allowed to delete its parser.

## 10. Risks and open questions

- **Facts-bundle schema coverage (highest risk).** If the bundle under-serves a consumer, that
  consumer can't drop its parser and the drift returns. Mitigated by the §4 audit as a gating
  first task. Specifically watch: m3e-okf's README-drift provenance, and cem-figma-connect's
  `.d.ts`-resolved enum unions (today recovered by `dts-inline.mjs`).
- **Elm-in-a-JS-monorepo tooling.** The Elm packages don't participate in pnpm resolution; how
  they resolve locally during dev vs at Elm-registry release needs a concrete convention. Low
  risk (elm-m3e already develops this way locally), but must be pinned down in Step 0.
- **Monorepo root/name.** Named `elm-cem-workspace` (elm-cem-centered; `elm-m3e` is the flagship brand, not
  the identity).
- **Elm published-package boundaries (Phase 5, not Phase 0).** The `core`/`components`/`builder` split is
  RETAINED for Elm's package size limit; a 2026-08-12 liaison review argued for a monolith and claimed it is
  "registry-faithful today," which conflicts with the size rationale. Verify the size ceiling before Phase 5
  touches boundaries; Phase 0 co-locates the packages exactly as they are.
- **cem-figma-connect stays general.** Confirmed decision: fold it in whole, swap vendored inputs
  for workspace deps, keep the engine CEM-agnostic; do **not** split the engine out (premature).
- **The Figma export dump remains hand-refreshed** and pinned by `kitVersionTag` — it is not
  CEM-derived, so it is deliberately outside the facts bundle and outside the `bump` (it changes
  only when the design kit itself changes). Publish `--file-key` remains an unresolved
  owner-decision inherited from cem-figma-connect (`STATUS.md`), not created here.
- **Interaction with Phase 5 (upstreaming).** If the CEM⋈Figma Code Connect work eventually moves
  to `matraic/m3e`, the monorepo boundary shifts. Phase 0 does not block this; it just makes the
  interim family coherent.

## 11. Non-goals (explicit YAGNI for Phase 0)

Deferred to their own phases, deliberately NOT designed here: the one-engine html↔elm
consolidation (Phase 1), the Tailwind Code Connect label + hybrid outputs (Phase 2), the
Figma → Elm reverse direction (Phase 3), token-tier/density hardening (Phase 4), and upstreaming
(Phase 5). Phase 0 is only: one producer, one bundle, one monorepo, one gated bump.
