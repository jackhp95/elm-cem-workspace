# 2026-08-17 — Figma ⇄ Elm codegen: CEM-config integration design & forward plan

**Status:** design + phased plan, for Jack's review. Investigation-only session (no live
Figma, no `src/` edits, no regeneration).
**Prerequisite reads:** `plans/00-mission-and-decisions.md` (D1–D13, evidence #1–14),
`plans/01-architecture.md` (§1–§6), `src/correspond/schema.json`, `STATUS.md`.
**Grounding:** every claim below was verified this session against the files cited — the
engine source, the m3-kit profile, the elm-cem facts-bundle schema
(`../../../docs/facts-bundle/schema.json`), and elm-cem's config-primitive catalog
(`packages/elm-cem/docs/config-primitives.md`).

---

## 0. The corrected premise, and assumptions made

The originating ask was dictated as if a Figma↔Elm system were being scoped from scratch.
It is not: **cem-figma-connect is a working tool** — CLI subcommands
`match / review / confirm / gap / extract / emit / publish / unpublish / check / capture`
(`src/cli.mjs`), 224 Code Connect bindings **per label** committed under
`generated/m3-kit/{web-components,elm}/`, byte-stable `pnpm check` + `pnpm test` (711
tests) green on `main` (`STATUS.md`). This document therefore does three things: proves
the current system is understood (§1), evaluates the one genuinely new proposal in the
ask — *"add a Figma field to elm-cem's custom config"* — against the system's deliberate
design (§3), and lays out the phased plan that best serves "best possible Figma Code
Connect codegen" from here (§5).

Assumptions made where the dictated ask was ambiguous (recorded per instruction, not
guessed silently):

| Phrase in the ask | Assumption adopted |
|---|---|
| "a sub repo … CEM Figma Connect" | `packages/cem-figma-connect` in this monorepo (a workspace package, not a git submodule). |
| "bi-directional communication between Figma and our Elm code" | The two directions Code Connect actually supports, per verified evidence #4/#6 — see §2. NOT live two-way sync. |
| "add a Figma field to associate the component node to the component in our CEM" | A per-element field in elm-cem's `--config-from=config/*.json` channel (the "custom configuration" `docs/config-primitives.md` describes), keyed by constructor name — the only config surface matching the description. Evaluated in §3. |
| "we don't have … the plugin" | The `extract/` path (self-hosted Figma plugin + bun WS relay, `extract/README.md`) requires Figma desktop + a plugin install; unavailable this session. The checked-in dumps under `research/figma-dumps/` are the Figma ground truth used throughout. |

---

## 1. Current system — verified understanding (proof-of-reading, not a re-explanation)

**The correspondence model is the heart and it is richer than any single field.** One
entry per `cemTag` (`src/correspond/schema.json`): `figmaSets[]` (0..N sets — N for
set-fusion, one fixed attr per sibling set, e.g. `Button - tonal` ⇒ `variant:"tonal"`;
per-set `slugSuffix` and inline `example` for appended sets), `axes[]` (enum / boolean /
multi-boolean valueMaps, or `unmapped` with a reason — never silently dropped), `props[]`
(text/boolean/instanceSwap bindings incl. human-authored `visibilityAxis`/`visibleWhen`,
`literalIcon`, `slotTag`), `confidence`, `provenance`
(`auto-exact|auto-fuzzy|auto-contains|auto-gap|human|manual`), `status`, and
`proposedUpdate`. The live m3-kit file is 5,032 lines / 64 entries / 52 confirmed / 12
carrying `proposedUpdate`.

**Human decisions are structurally protected.** `mergeCorrespondence`
(`src/correspond/merge.mjs:317`) never modifies a protected entry
(`provenance:"human"` OR `status:"confirmed"`); a differing fresh auto-proposal is parked
in `proposedUpdate` instead. Deletion is a human action, never a side effect of re-running
`match`. Rejections are protected too: any decision applied from `overrides.json` stamps
`provenance:"human"` (`src/correspond/review.mjs:145`).

**Three hand-authored inputs with distinct roles** (all profile-local, discovered by
hardcoded filename in `loadProfile`, `src/correspond/merge.mjs:683-718`):
- `manual-correspondence.json` (object keyed by cemTag, 21 keys) — *authoring* input for
  matcher-unreachable bindings: `figmaSets` only replaces UNBOUND entries (fail-loud
  otherwise), `appendSets` only extends already-bound ones; validated against the live
  CEM + figma export before anything touches disk.
- `overrides.json` (array, 52 entries, all `status:"confirmed"`) — the *decision ledger*:
  confirm/reject + visual-gate verdicts (`gate:"approved"` with diff ratios, or
  `"example-verified"` for composed bindings), with dated evidence notes.
- `examples.json` / `set-attrs.json` — representative child content and per-set static
  attrs, consumed by both emitters.

**The emit pipeline is deterministic and label-symmetric.** `computeEmitEntries` filters
`status:"confirmed"` then applies the delta overlay (`computeEmitSet` — add / override /
suppress per cemTag, the consumer-deviation mechanism from evidence-doc's consumption
model) (`src/emit/run.mjs:176-190`). One `.figma.ts` **per fused figmaSet** per label;
the raw-template form (no `figma.connect()` call — `parser:"html"` + the label are
injected at publish time by `writeFigmaConfig`, `src/publish/runner.mjs:160`). The Elm
emitter (`profiles/m3-kit/emitters/elm.mjs`) hardcodes zero Elm names: every module /
setter / token comes from the elm-cem facts bundle Face C
(`profiles/m3-kit/facts/elm-api-facts.json`), with only the userland seams
(`textSeam:"M3e"`, `htmlSeam:"TypedHtml"`, `attrSeam:"TypedHtml.Unsafe.Attributes"`)
coming from `profile.json` (corrected 2026-08-17 by Stream 2).

**The elm-cem seam is a versioned, provenance-stamped bundle, not a config import.**
elm-cem generates Face B (CEM facts, `.d.ts`-resolved) + Face C (generated-Elm API
projection) per `docs/facts-bundle/schema.json` (workspace root) — strict
`additionalProperties:false` throughout, `schemaVersion` const, provenance stamps
carrying the upstream `@m3e/web` version/sha AND the brand's `configFiles` merge list.
`scripts/gen-facts.mjs` (the *only* writer) copies the bundle into
`profiles/m3-kit/facts/`; `src/ingest/cem.mjs`'s `loadCem()` projects Face B onto the
matcher's shape. `profile.json` pins the Figma side symmetrically:
`fileKey` + `kitVersionTag` refresh together, never independently (node-ids anchor within
a kit-version epoch; component keys re-mint on file duplication — evidence #5 — so keys
live in a per-fileKey cache, never in correspondence).

**Publish is already fileKey-parameterized.** `materializeStaging`
(`src/publish/runner.mjs:113`) rewrites each staged `.figma.ts`'s `// url=` line to the
`--file-key` passed at publish time, preserving node-ids; `generated/**` always carries
the profile's canonical fileKey; `check:drift` normalizes the URL line to
`// node-id=…` so fileKey churn is never drift but a node-id change always is
(`src/publish/check.mjs:67`). Token = `FIGMA_ACCESS_TOKEN` env-only, redacted from all
output.

**Verification without Figma is the designed default.** `pnpm gate` = byte-stable
re-emit against the committed dump + 711 unit tests; the extraction path has a `--dry`
fixture mode through the identical assemble-then-validate path; the visual gate renders
the code side headlessly (byte-stable, evidence #14) against checked-in Figma exports.

---

## 2. What "bidirectional" means in the delivered system — precisely

Code Connect is **not** live two-way sync, and this plan does not promise it. The
delivered system has exactly two directions, both already built:

1. **Design → code (node binding).** A bound Figma node shows our snippet — per label,
   "Web Components" and "Elm" — in Dev Mode, and `get_design_context` returns that
   snippet verbatim with imports, replacing raw markup (evidence #4). This is
   *read-side*: Figma is the surface, our generated code is the content.
2. **Code → Figma (vocabulary push).** Variable `codeSyntax` stamping
   (`src/tokens/stamp.mjs`, the D-plan token bridge) writes our token names
   (`--md-sys-color-*` …) onto kit variables, so Figma-generated layout code for
   *unbound* frames speaks our vocabulary (evidence #6). This is *write-side*: our
   naming becomes Figma's output language.

The loop that makes the pair feel bidirectional is **regeneration**, not sync: CEM/library
changes → `gen:facts` → `match` (human-protected merge) → `emit` → `publish` per fileKey;
kit changes → re-extract → same path. "Later tweaks are extremely minor" (the ask's
closing claim) is true *because* both directions are deterministic codegen over one
checked-in correspondence model — that property is the thing to protect, and it drives
the verdict in §3.

What would require machinery Code Connect does not provide, and is explicitly out of
scope: editing Figma nodes from code changes, editing code from Figma edits, or any
runtime channel between the two. (The nearest sanctioned write path is `use_figma`
codeSyntax stamping and, in the future, `figma-generate-*` authoring flows — separate
tools, separate plans.)

---

## 3. The core question: should a Figma field live in elm-cem's per-element config?

Jack's proposal: elm-cem already has a per-element custom-config channel
(`--config-from=config/*.json`, deep-merged, entries keyed by constructor name — the ten
primitives plus P1 curation fields, `packages/elm-cem/docs/config-primitives.md`); add a
`figma` field there associating the component's Figma node, and let codegen flow from it.

### 3.1 What the evaluation found

**(a) Multiplicity/versioning: a single field cannot hold the real relation.** The real
binding for `m3e-button` is *five* sibling sets, each contributing a fixed
`variant` value, with two mapped axes (each with a per-value map), an unmapped axis with
a recorded reason, three prop bindings, and a provenance trail — and that is a *typical*
confirmed entry, not a worst case (`profiles/m3-kit/correspondence.json`). Node-ids are
only meaningful against the profile's pinned `(fileKey, kitVersionTag)` epoch. A
`"figma": "58650:9294"`-style field per element is therefore not a compression of the
correspondence model; it is a *different, lossier* model that would still need the full
`correspondence.json` beside it. Partial embedding (just a node-id or set name as a
"match hint") adds nearly nothing: name-level matching already binds those cases at
exact/contains tier, and the hard cases (set-fusion membership, matcher-unreachable sets,
per-set examples) are exactly the ones a single field can't express —
`manual-correspondence.json` already is the escape hatch for them, validated fail-loud
against both the CEM and the export.

**(b) Genericity cuts against it twice.** `src/` has nothing m3e-specific
(`plans/01-architecture.md` §4) and a second consumer (Avetta, D12) is in-plan. elm-cem's
`config/*.json` is one brand's input to one Elm generator; a CEM+Figma project that
doesn't use elm-cem at all (any `custom-elements.json` producer) could never supply
correspondence that way. Conversely, cem-figma-connect would have to learn elm-cem's
config format — today it deliberately consumes only the neutral, versioned facts bundle
(`src/ingest/cem.mjs`). Embedding would convert a schema-stamped seam into a config-format
coupling.

**(c) The lifecycle argument is the decisive form of the D9 lesson.** D9's VOLT-2003
precedent rejected annotation-in-*source* because annotations don't fit generated code.
elm-cem's config is source-adjacent *curation*, not generated code — so, honestly
assessed, it would **not** reproduce that exact failure mode. What it would reproduce is
the underlying one: **coupling data with different change cadences and different
reviewers.** elm-cem config churns when *library semantics* change (slots, kinds,
containment) and is reviewed against the CEM; correspondence churns when the *Figma
epoch* changes (re-extraction, kit version bump, file duplication re-minting keys) and is
reviewed against renders and the decision ledger. Fusing them means every kit refresh
dirties brand config, and every brand-config review drags Figma node-ids it can't
evaluate. The facts bundle's own provenance design (Face C stamps `configFiles`
*because* "a Face-C fact can change from config alone") shows the workspace already
treats these cadences as distinct.

**(d) The human-verification machinery has no equivalent on the config side.**
`merge.mjs`'s protected-entry / `proposedUpdate` mechanism, `overrides.json`'s
evidence-carrying gate verdicts, and the fail-loud manual-correspondence validators are
what make re-runs safe. elm-cem's deep-merge config channel has none of this and
shouldn't grow it — it would be a reimplementation of `correspond/` inside a generator
that has no Figma inputs to validate against.

### 3.2 Verdict — and the form of Jack's idea worth adopting

**Authored correspondence stays exactly where it is: `cem-figma-connect` profile config
(`correspondence.json` ⊕ `manual-correspondence.json` ⊕ `overrides.json`). Nothing
Figma-related is hand-written into elm-cem's `config/*.json`. D9 is reaffirmed, now with
the config-side variant explicitly evaluated rather than assumed.**

But Jack's underlying instinct — *"the CEM component should know its Figma node"* — is
right, and the system can honor it in the direction its authority model already points:
**as a derived projection, generated from correspondence, flowing back into elm-cem's
config channel as data.** Concretely (Phase 2):

- cem-figma-connect gains a `links` derivation: `profiles/<p>/figma-links.json`, one
  entry per confirmed cemTag — `{ fileKey, kitVersionTag, sets: [{nodeId, setName,
  url}], status, gate, labels }` — computed from `correspondence.json` +
  `overrides.json` + `profile.json`, deterministic and drift-gated like every other
  artifact.
- elm-m3e consumes it as a *generated* config file (`config/figma.generated.json`),
  exactly like `config/examples.generated.json` already rides the `--config-from`
  channel — feeding per-component **doc metadata** (elm-cem's existing `docMeta`
  opaque key/value doc hook, `codegen/Generate/Config.elm`), so generated Elm
  doc-comments can carry "Open in Figma" node URLs and the binding's verification
  status. (Verifying `docMeta`'s exact doc-emission shape is a task step in Phase 2,
  not assumed here.)

This gives every consumer of the generated Elm surface the Figma association Jack asked
for — in the CEM-config channel he named — while keeping a single source of truth,
one-directional derivation, and zero new authoring surfaces. A field that is *generated*
can never drift from the correspondence; a field that is *authored* is a second source of
truth from day one. That is the whole recommendation in one sentence.

### 3.3 The seam contract, restated end-to-end

```
                         (authored)                        (authored)
   @m3e/web CEM ──► elm-cem ──► facts bundle Face B/C ──► cem-figma-connect ingest
                    ▲   (schema.json, provenance-stamped,   (src/ingest/cem.mjs)
   config/*.json ───┘    copied by scripts/gen-facts.mjs)        │
   (brand curation;                                              ▼
    NO figma data authored here)                    matcher ⊕ manual ⊕ overrides
                                                                 │
                                                    correspondence.json (merged, checked in)
                                                                 │
                              ┌──────────────────────────────────┼──────────────────┐
                              ▼                                  ▼                  ▼
                     generated/<p>/… per label          figma-links.json      gap-report.md
                     (Code Connect publish units)      (NEW, derived) ───► elm-m3e
                                                                            config/figma.generated.json
                                                                            (docMeta only, generated,
                                                                             never hand-edited)
```

Forward flow (facts bundle) is unchanged. The one new edge is the derived reverse flow,
and it terminates in a generated file with the same "build artifact — regenerate, never
hand-edit" contract the workspace already applies to `examples.generated.json` and
ejected component code (`docs/distribution-model.md`).

---

## 4. Phased implementation plan

Granularity follows `plans/plan/A-engine-core.md` style: each phase states files, offline
verification, live-Figma dependency, and an informational expected model tier (per the
global planning policy; non-blocking). Ordering of independent phases is best-judgment.
Every phase preserves the byte-stability gate: `pnpm gate` green before and after.

### Phase 0 — Decisions & doc reconciliation (no code) — tier: human + sonnet/low scribe

**What:** resolve the fileKey question *structurally* (see §5 blocker 1): update
`plans/00-mission-and-decisions.md` (D2 note), `STATUS.md`, and `docs/USAGE.md` to state
the two distinct roles the current code already implements —
(1) **extraction-epoch anchor** = `profile.json` `fileKey`+`kitVersionTag`, must match the
committed dump (`UtwpUdPiOZEuxp8Nq1d5yQ` / `m3-community-2026-07-13` today); (2)
**publish target** = the explicit `--file-key` per publish run, rewritten at staging
(`runner.mjs:81`), valid for any same-kit-version duplicate because node-ids survive
duplication (evidence #5). Jack picks the actual publish-target file (§6). Also fold this
doc's verdict into the decision ledger as **D14: correspondence stays external to CEM
config; CEM-side Figma data is derived-only (figma-links)**.
**Files:** the three docs above + this one.
**Verify:** docs-only; `pnpm gate` untouched. **Live Figma:** not needed (the *decision*
needs Jack, not Figma; confirming write access on the chosen target is Phase 4).

### Phase 1 — Seam hardening (small engine cleanups the design surfaced) — tier: sonnet/medium

1. **Elm emitter facts path → profile config.** `elm.mjs:102-104` hardcodes
   `here/../facts/elm-api-facts.json`; move to `profile.json` `elm.factsPath` (+
   `elm.iconNamesPath`), defaulting to the current locations. Removes the one
   genericity leak a second Elm-consuming profile would hit.
   **Files:** `profiles/m3-kit/emitters/elm.mjs`, `profiles/m3-kit/profile.json`,
   `src/correspond/merge.mjs` (`loadProfile` passthrough), tests.
2. **Provenance staleness check.** New `check:facts` script: assert Face B/C
   `provenance.source.{package,version}` === `profile.json` `cem.{package,version}`, and
   Face C `provenance.brand.name` is the expected brand. Turns "stale bundle" from a
   silent mis-emit into a red gate. **Files:** `scripts/check-facts.mjs`,
   `package.json` (`check:*` namespace picks it up via `run-p "check:*"`).
3. **Profile sidecar contract doc.** `loadProfile` discovers `examples.json`,
   `set-attrs.json`, `manual-correspondence.json` by hardcoded filename; `buildEmitContext`
   is constructed in *two* places that must stay in lockstep (`run.mjs:237`,
   `check.mjs:101`). Write `docs/PROFILE-CONTRACT.md` recording every file a profile may
   contain, who reads it, and the lockstep rule — this is the doc a second consumer
   (Avetta) needs anyway. **Files:** new doc; pointer from `README.md` Layout section.

**Verify (all offline):** `pnpm gate` byte-identical `generated/**`; new unit tests for
1–2. **Live Figma:** none.

### Phase 2 — `figma-links`: the derived CEM-side association (adopts §3.2) — tier: sonnet/medium, elm-m3e wiring opus/medium

1. **Derivation.** `src/links/derive.mjs` + CLI subcommand `links --profile <p>`:
   read `correspondence.json` + `overrides.json` + `profile.json`; for each
   `status:"confirmed"` entry emit `{ cemTag, fileKey, kitVersionTag, sets:[{nodeId,
   setName, url}], status, gate, labels }` (URLs via the existing `buildNodeUrl`
   helper, `src/emit/emitter-api.mjs:140`); write
   `profiles/<p>/figma-links.json` sorted by cemTag, 2-space, trailing newline.
   Include the iconTable entry as a single `m3e-icon` row (link to the icon page, not
   141 rows). **Files:** `src/links/derive.mjs`, `src/cli.mjs`, `test/links.test.mjs`.
2. **Drift gate.** `check:links` recomputes in memory and diffs — same pattern as
   `check:drift`. **Files:** `package.json`, reuse of derive module.
3. **elm-m3e consumption (docs metadata only).** A workspace tool
   (`tools/gen-figma-config.mjs` or an elm-m3e script — match wherever
   `examples.generated.json`'s producer lives) joins `figma-links.json` with Face C
   (`components[cemTag].component/module`) to key by constructor name, and writes
   `packages/elm-m3e/config/figma.generated.json` carrying per-component `docMeta`
   entries (`figmaUrl`, `figmaStatus`). Wire into the brand's `--config-from` list
   (`tools/lib/regen.mjs`). **First task step: verify `docMeta`'s emission shape in
   `codegen/Generate/Config.elm` / the docs projection (E6) actually renders opaque
   key/values into doc-comments; if it doesn't, extend the docs projection there rather
   than inventing a parallel channel.** **Files:** new tool, `tools/lib/regen.mjs`,
   possibly `packages/elm-cem/codegen/Generate/Docs.elm`.
4. **Decide-and-document publication stance.** Node URLs point into Jack's private kit
   copy; decide whether they belong in *published* elm-m3e docs or only local/ejected
   docs (open question §6). Default until decided: generate the file, gate doc-comment
   emission behind a config flag.

**Verify (all offline):** unit tests on derive; byte-stable `figma-links.json` across
re-runs; elm-m3e regen diff shows only the intended doc-comment additions;
`pnpm gate` + elm-cem's own gates green. **Live Figma:** none (URLs are constructed,
not fetched).

### Phase 3 — Residual coverage worklist (offline-doable parts) — tier: opus/medium (fiddly per-set example authoring)

From `plans/next-agent-handoff.md`, in its stated value order:

1. **`m3e-card`** — convert the auto-`contains` match to a manual binding with per-set
   `example.children` (the mechanism `m3e-tab`/`m3e-date-input` already use), one example
   per structurally-distinct node (horizontal / vertical). **Files:**
   `profiles/m3-kit/manual-correspondence.json`, regenerated `correspondence.json` +
   `generated/**`. Handoff calls this "byte-stable; cleanest high-value win."
2. **`m3e-date-input` docked set (`51954:18567`)** — wrap like the modal set already is.
   **Files:** `manual-correspondence.json` (appendSets), harness config.
3. **`m3e-fab-menu`** — composed example (FAB + trigger, `variant="tertiary"`, corrected
   item content) **plus** the render-harness change to open the sibling menu. Heed the
   handoff's warning about the portal/naive-sibling layout trap.
4. **`m3e-search-view` fullscreen pixel-match — only if Jack asks** (current binding is
   intentionally representative, user-approved 2026-07-30).

**Verify:** `pnpm gate`; code-side renders re-run headlessly; pixel re-approval against
the *checked-in* Figma-side exports where those PNGs exist in `profiles/m3-kit/assets/`.
**Live Figma:** only where a fresh Figma-side `export-png` is needed for final
`gate:"approved"` status — those specific re-approvals move to Phase 4; the bindings
themselves land now as `example-verified`.

### Phase 4 — Live-Figma bridge session (BLOCKED on Figma access; runbook now, run later) — tier: opus/medium + human

Everything here is *already specified* by existing runbooks; this phase is scheduling,
not design: (1) acceptance extraction run — exit criterion 171/171 sets carrying
`setProperties` (`extract/README.md:123-136`), then `match` (human-protected) →
review deltas; (2) fileKey confirmation — dry-run `publish --dry-run --file-key <target>`
against Jack's chosen file, verifying node-id resolution; (3) real publish per label +
`published.json` state; (4) codeSyntax stamping pass (`src/tokens/stamp.mjs` runbook,
pre-state snapshot first); (5) the Phase-3 leftovers needing fresh Figma-side PNGs;
(6) rotate/revoke the PAT after the session (`STATUS.md` hygiene note).
**Verify:** each step's own recorded evidence (dry-run output, `pnpm check` after
re-extraction, gate diffs). **Live Figma: required — this is the only phase that is.**

### Phase 5 — Second consumer & release track (deferred, listed for completeness) — tier: opus/high when picked up

Avetta delta profile over the base correspondence (`computeEmitSet` deltas — the
mechanism is built and tested, unexercised by a real second profile), published-library
instance resolution test (Plan F), and the `extract/` IP review recording that gates
taking the repo public. Deferred: no dependency from Phases 0–4, and both need
inputs (Avetta priorities; legal review) this plan can't supply.

---

## 5. The three STATUS.md blockers — explicit calls

1. **Canonical publish fileKey (3-way disagreement).** **In scope — Phase 0** resolves
   the *structure* (extraction-anchor vs publish-target are different roles; the code
   already implements the split via staging-time rewrite), which dissolves two of the
   three "disagreements" into role confusion. The remaining genuine decision — *which
   file is the publish target* (likely the writable copy behind
   `figma-export.m3-kit-copy.json`, `iPFL8MH2R1Xphe94j7g809`) — **is deliberately left
   to Jack** (§6): it depends on account/seat facts (org plan, write access) not
   discoverable from the repo, and `publish` requiring an explicit `--file-key` means
   nothing breaks while it stays open.
2. **`extract/` IP review.** **Deferred (Phase 5)** — it gates *making the repo public*,
   not any work in Phases 0–4; the repo stays private meanwhile, per `STATUS.md`. No
   design decision here changes the ported technique's provenance, so nothing in this
   plan can resolve it.
3. **Residual coverage gaps.** **In scope — Phase 3** for everything doable against the
   checked-in dump (card, docked date-input, fab-menu composition, all landing as
   `example-verified`); the final pixel re-approvals and `m3e-search-view` (only-if-asked)
   ride the Phase 4 live session.

---

## 6. Migration note — nothing existing is invalidated

- **`correspondence.json` / `manual-correspondence.json` / `overrides.json`:** schema and
  content untouched by Phases 0–2. Phase 3 edits `manual-correspondence.json` through its
  designed mechanisms (`figmaSets` replace-unbound / `appendSets`), which
  `applyManualToExisting` mirrors onto stored entries so confirmed work lands live
  without `proposedUpdate` churn (`merge.mjs:610`).
- **The 224×2 committed bindings:** byte-identical through Phases 0–2 (Phase 1's emitter
  path change is config-plumbing with unchanged defaults — the gate proves it). Phase 3
  produces *intended* diffs on exactly the four named tags, reviewed per the normal
  confirm flow.
- **`figma-links.json` / `figma.generated.json`:** purely additive artifacts with their
  own drift gates; deleting them reverts cleanly.
- **No schema version bumps anywhere:** the facts bundle is consumed as-is (the §3
  verdict is precisely what avoids touching `docs/facts-bundle/schema.json`), and
  `correspondence.json`'s schema gains no fields.

## 7. Open questions deliberately left for Jack

1. **Publish-target fileKey** (§5.1): which file — the D2 drafts copy
   (`KujuFlfJSwHI6ua1b7RZvL`), or the 2026-08-04 writable copy
   (`iPFL8MH2R1Xphe94j7g809`)? Needs your seat/write-access facts; confirmed by the
   Phase 4 dry-run either way.
2. **Figma URLs in published docs** (Phase 2.4): should generated elm-m3e doc-comments
   carry node URLs into a private file (visible to anyone reading the published/ejected
   docs), or stay local-docs-only behind a flag? **Sharpened by Phase 2.3's finding
   (see progress log below): today the answer doesn't even matter — `docMeta` renders
   as an invisible marker that `docs/scripts/extract-reference.mjs` actively strips.
   The real question is now "is it worth extending the docs renderer to surface this at
   all," not just "public vs. local."**
3. **`m3e-search-view` pixel-match**: the standing instruction is "only if asked" — this
   plan keeps that default; say the word and it joins Phase 3/4.

## 8. Progress log

- **2026-08-18 — Phase 0 done** (`e5f874f`): D14 added to the decision ledger; `STATUS.md`
  and `docs/USAGE.md` rewritten to state the fileKey role split (extraction anchor vs.
  publish target).
- **2026-08-18 — Phase 1.2 + 1.3 done** (`3572182`): `check:facts` provenance-staleness
  gate (`scripts/check-facts.mjs`) + `docs/PROFILE-CONTRACT.md`. **Phase 1.1 deliberately
  deferred** — it touches a purity-contract-protected module-init load in
  `profiles/m3-kit/emitters/elm.mjs` (~1000 lines) and has no live urgency (no second Elm
  consumer exists; that's Phase 5). Flagged, not attempted.
- **2026-08-18 — Phase 2.1 + 2.2 done** (`f062df6`): `links` CLI subcommand
  (`src/links/derive.mjs`) derives `profiles/m3-kit/figma-links.json` from
  `correspondence.json` ⊕ `overrides.json` ⊕ `profile.json`; `check:links` drift gate.
  52 confirmed entries linked; the iconTable collapses to one row with an honestly-labeled
  `representative: true` node (no single "icon page" node exists in the data — see the
  module's own comment for why a fabricated one wasn't used).
- **2026-08-18 — Phase 2.3 partially done** (`7c47a99`): `tools/gen-figma-config.mjs`
  joins `figma-links.json` with elm-cem's Face C bundle and writes
  `packages/elm-m3e/config/figma.generated.json` (52 components, `docMeta.figmaUrl` +
  `docMeta.figmaStatus`), keyed by the module's constructor-name suffix (verified against
  `config/examples.generated.json`'s real key casing — Face C's own `component` field is
  lowercase and would NOT have matched). **Deliberately NOT added to
  `tools/lib/regen.mjs`'s `GEN_CONFIG_ARGS`** — source-read verification (not assumed)
  found `docMeta` renders as an invisible `<!-- elm-cem:docmeta … -->` HTML-comment marker
  (`packages/elm-cem/codegen/Docs.elm`'s `docMetaMarker`), and
  `packages/elm-m3e/docs/scripts/extract-reference.mjs` explicitly drops that marker
  before rendering the public reference pages. Wiring it in today would embed private-file
  Figma URLs into shipped package doc-comment bytes for zero visible effect — this is
  open question 2 above, now concrete. Held for Jack's steer; see the script's header for
  the full account.
- **Not started: Phase 3** (coverage worklist — `m3e-card`, `m3e-date-input` docked set,
  `m3e-fab-menu`). Deliberately not rushed into the same pass as Phases 0–2: the plan
  itself rates this fiddly per-component example-authoring work at a higher tier
  (opus/medium vs. Phases 1–2's sonnet/medium), and `plans/next-agent-handoff.md` flags
  real per-component traps (`m3e-fab-menu`'s portal/sibling-layout trap). Worth its own
  focused pass rather than being squeezed in.
- **Phase 4 (live-Figma bridge session): still fully blocked**, runbook unchanged — this
  is the "run one command when I have Figma access" step; everything through Phase 2 was
  designed so that session should need at most the fileKey dry-run (open question 1) plus
  whatever Phase 3 leaves for live pixel-approval.
- **Phase 5: untouched**, no dependency from anything above.
