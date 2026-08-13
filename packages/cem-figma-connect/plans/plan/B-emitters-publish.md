# Plan B — Emitters & publish: html label, emitter API, Elm label, publish runner, tracer

> Depends on Plan A (correspondence schema + confirmed `m3e-button` entry, Task A8).
> Read `plans/00-mission-and-decisions.md` + `plans/01-architecture.md` first.
> The live-publish mechanics here are NOT speculative — every step reproduces what was
> proven on 2026-07-10 (evidence #1–#4), now from generated instead of hand-written files.

Deliverable: `emit` + `publish` CLI paths that turn the confirmed button entry into BOTH
labels ("Web Components", "Elm"), publish them to the user's kit copy, verify via MCP, and
unpublish — all from generated artifacts with drift guards.

---

### Task B1: Spike fixtures + html-label emitter

**Files:** Create: `src/emit/html-label.mjs`, `test/html-label.test.mjs`,
`profiles/m3-kit/fixtures/M3eButton.webcomponents.figma.ts`,
`profiles/m3-kit/fixtures/M3eButton.elm.figma.ts` (copies of the proven scratch spikes —
see below). Modify: `src/cli.mjs` (`emit` subcommand).

- [ ] Copy the two live-proven spike templates from the 2026-07-10 session
  (preserved in-repo at `research/spikes/01-publish-gate/M3eButton.figma.ts` and
  `research/spikes/02-elm-label/M3eButton.figma.ts`) into
  `profiles/m3-kit/fixtures/` — they are the golden references the emitter must be able to
  reproduce semantically.
- [ ] `html-label.mjs`: correspondence entry → **one `.figma.ts` per (component × fused
  set)**, template form exactly as proven (evidence #1–#2):
  `// url=<node URL>` first line → `import figma from "figma"` →
  `const instance = figma.selectedInstance` → one `getEnum(figmaProp, valueMap)` per mapped
  VARIANT axis (keys **verbatim Figma variant values, case-sensitive** — footgun; the
  value side comes from `axes[].valueMap`) → `getBoolean`/`getString` per prop (display
  names WITH spaces are fine, evidence #2: `"Label text"`) → `figma.code\`<tag …>\``
  interpolating axis vars + `fixedAttrs` baked as literals (`variant="tonal"` for the
  tonal set) → `export default { example, imports, id, metadata: { nestable: true } }`.
  `id` = `<cemTag>-<setSlug>`; `imports` from profile config (m3-kit:
  `import "@m3e/web/all"`).
- [ ] Boolean props bound to slots (`Show icon` → `slot:icon`) emit the conditional-line
  idiom from VOLT-2003's generator (`const x = cond ? figma.code\`…\` : figma.code\`\``) —
  the snippet includes a slotted `<m3e-icon name="…">` line only when the Figma boolean is
  on, sourcing the glyph from the INSTANCE_SWAP prop when mapped (evidence #12) and a
  profile placeholder otherwise.
- [ ] Hard rules enforced by the emitter (VOLT-2003 footguns, verified still real):
  node URLs are **main-file form only** — the emitter throws on `/branch/` in any
  configured URL; generated files carry a `GENERATED — do not edit` header; generated
  output dirs are listed in `.prettierignore` (Prettier's semicolons break the code-level
  drift diff).
- [ ] Emitted URL policy: files are written with the **profile's canonical fileKey**
  (`profile.json`), but the URL line is regenerated at publish time for other targets —
  see B4. Node IDs come from `figmaSets[].nodeId` (stable across duplicates, evidence #5).

**Verify:** `node --test test/html-label.test.mjs`: emitting the confirmed button entry
yields 5 files; the main-set file is semantically equal to the golden fixture (same
getEnum maps, same example line modulo whitespace/id); a `/branch/` URL in profile config
throws; `size` map contains `XSmall: "extra-small"` (not a lowercased Figma key).
**Commit:** `feat: html-label Code Connect emitter reproducing the proven template form`

---

### Task B2: Emitter plugin API

**Files:** Create: `src/emit/emitter-api.mjs`, `src/emit/run.mjs`,
`test/emitter-api.test.mjs`. Modify: `profiles/m3-kit/profile.json`.

- [ ] Interface (documented in the file header):
  `{ name: string, label: string, emit(entry, ctx) -> [{ path, contents }] }` where `ctx`
  gives profile config, resolved CEM data for the tag, export views, and helpers
  (URL builder, slugify, conditional-line builder). Emitters are **pure** — no fs, no
  network; `run.mjs` owns writing.
- [ ] `run.mjs`: for each emitter in `profile.json.emitters` (built-in `html-label` +
  dynamic `import()` of profile-local emitters like
  `profiles/m3-kit/emitters/elm.mjs`), emit all `status:"confirmed"` entries into
  `generated/<profile>/<label-slug>/…`, deterministically ordered, then write a manifest
  (`generated/<profile>/<label-slug>/MANIFEST.json`: entry→files map) used by `check` and
  publish.
- [ ] `emit --page <name>` filters to entries whose figma sets live on that kit page
  (Plan E's per-page fan-out relies on this).
- [ ] Suppressed/rejected entries emit nothing; `unmapped` axes are skipped with a comment
  line in the generated file (visible, not silent — mirrors gap report).

**Verify:** `node --test`: a toy emitter registered in a test profile receives ctx and its
files land under `generated/<profile>/toy/`; re-run byte-stable; MANIFEST lists exactly the
emitted files.
**Commit:** `feat: pure emitter plugin API + deterministic emit runner with manifest`

---

### Task B3: Elm emitter (m3-kit profile, elm-m3e-backed)

**Files:** Create: `profiles/m3-kit/emitters/elm.mjs`,
`profiles/m3-kit/emitters/elm-facts.build.mjs`, `profiles/m3-kit/elm-facts.json`
(generated), `test/elm-emitter.test.mjs`.

**Never hardcode Elm names.** The post-review-2026-07 elm-m3e (D10) is the source of truth
for module/setter/token names; module shapes changed in that effort, so guesses from older
docs are wrong by construction.

- [ ] `elm-facts.build.mjs` ⚑ HUMAN-adjacent (needs a local elm-m3e checkout at
  `~/code/jackhp95/elm-m3e`, post-review state): extract per-component facts —
  component module name, view/entry function, per-attribute setter name, token constructor
  per enum value (`M3e.Token.*` vocabulary), slot placer names — from the machine-readable
  sources in that repo (the `M3e.Review` facts module and/or the generator's emitted
  metadata; the docs corpus `docs.json` as fallback). Write `elm-facts.json` (committed);
  record the elm-m3e commit hash inside it.
- [ ] `elm.mjs` (label `"Elm"`): correspondence entry + `elm-facts.json` → `.figma.ts`
  per set, same template mechanics as B1 but `figma.code` emits the Elm pipeline. Surface
  is **configurable** (D5): profile key `elmSurface: "top" | "build" | "record" | "html" |
  "raw"`, default `top`; each surface is a template over the same facts. `getEnum` value
  maps target token expressions (`XSmall → "M3e.Token.xs"`-style, resolved from facts, not
  guessed). `imports` from facts (e.g. `import M3e.Button`, `import M3e.Token`).
- [ ] Compile gate (optional but wired): `--compile-check` renders every generated Elm
  snippet into a scratch module set and runs elm-m3e's examples verify harness (the shared
  harness from review-2026-07 Plan D, `docs/scripts/examples-gen/` lineage) with the
  repo's elm binary. Snippets are illustrative (placeholders allowed per VOLT-2003
  precedent) but must at minimum parse; full compile is the aspiration the harness reports
  on.
- [ ] Golden test: the generated main-set Elm file is semantically equal to
  `profiles/m3-kit/fixtures/M3eButton.elm.figma.ts` — the exact template that returned
  per-variant `M3e.Token.md` / `M3e.Token.rounded` snippets live (evidence #3) — modulo
  facts-driven names.

**Verify:** `node --test test/elm-emitter.test.mjs` (facts fixture pinned in test); then
`node src/cli.mjs emit --profile m3-kit` produces both labels' trees;
`node profiles/m3-kit/emitters/elm-facts.build.mjs --check` fails loudly if elm-m3e's
checkout predates the review-2026-07 renames (`grep -rF "import M3e.Value"` → must be 0;
a bare `M3e.Value` pattern false-matches doc-link slugs like `M3e-Value-Core` that
legitimately remain in the current elm-m3e).
**Commit:** `feat(m3-kit): elm-facts extraction + surface-configurable Elm emitter`

---

### Task B4: Publish runner (per-fileKey, label-scoped) + drift guards

**Files:** Create: `src/publish/runner.mjs`, `src/publish/check.mjs`,
`test/publish-check.test.mjs`. Modify: `src/cli.mjs`, `package.json` (dep:
`@figma/code-connect` — the one allowed runtime dep, it IS the publisher).

- [ ] `runner.mjs`: `publish --profile m3-kit --label Elm --file-key <k> [--dry-run]`.
  Omitting `--label` iterates all labels in the profile manifest (publish-all).
  Steps: (1) materialize a **staging dir** per (label × fileKey): copy
  `generated/<profile>/<label>/*.figma.ts` rewriting each `// url=` line to
  `https://www.figma.com/design/<fileKey>/x?node-id=<nodeId dashed>` from the
  correspondence nodeIds — this is the **per-copy republish** mechanism (evidence #5:
  node-ids stable, keys re-mint; .figma.ts on disk stay fileKey-agnostic templates
  carrying the canonical key); (2) write the label's `figma.config.json`
  (`{ codeConnect: { parser: "html", include: [staging glob], exclude, label } }` — the
  exact config shape proven live); (3) exec `npx figma connect publish
  --skip-update-check [--dry-run]` with `FIGMA_ACCESS_TOKEN` **from env only** — the
  runner refuses to read token files and never logs the token; (4) parse CLI output,
  record published (fileKey × label × nodeIds) into `profiles/<p>/published.json` (state
  for unpublish + audits).
- [ ] `unpublish --profile m3-kit --label <l> --file-key <k>`: same staging → `npx figma
  connect unpublish`; update `published.json`.
- [ ] `check.mjs` (CI gate, port of VOLT-2003 `generate.mjs --check` semantics): re-emit
  in-memory and diff **code-only** (strip comments/blank lines before comparing) against
  `generated/**`; flag **DRIFT** (committed ≠ regenerated) and **ORPHAN** (committed file
  no producing correspondence entry); nonzero exit on either. Wire as `npm run check`.
- [ ] Guard: `publish` refuses if `check` fails or if the target entry is not publishable
  per the Plan-C gate — publishable = status `pass|approved` (C's vocabulary:
  `pass|approved|failed|rejected|pending`, derived at read time). The hook invokes
  `src/visual/status.mjs` `status(entry)` if that module exists, else warn-and-pass
  (pre-C interim) — so B doesn't depend on C's internals (D8).

**Verify:** `node --test test/publish-check.test.mjs` (staging URL rewrite: canonical →
`iPFL8MH2R1Xphe94j7g809` swaps every url line, node-ids intact; check catches a
hand-edited generated file and an orphan); `node src/cli.mjs publish --profile m3-kit
--label "Web Components" --file-key KujuFlfJSwHI6ua1b7RZvL --dry-run` → "All Code Connect
files are valid" (offline-ish: dry-run still needs the token + resolves nodes, so run in
the B5 session if no token is at hand).
**Commit:** `feat: per-fileKey publish/unpublish runner with staging URL rewrite + drift/orphan check`

---

### Task B5: Tracer publish ⚑ HUMAN

**Files:** Modify: `profiles/m3-kit/published.json` (transient), evidence note in
`research/evidence/`.

Batch this as ONE session with the user (token in env, ~10 minutes).

- [ ] ⚑ HUMAN: `FIGMA_ACCESS_TOKEN` present in the shell env (rotate afterwards — the
  2026-07-10 token was pasted in chat and must be considered burned; ledger cleanup note).
- [ ] `publish --label "Web Components" --file-key KujuFlfJSwHI6ua1b7RZvL --dry-run` then
  real; same for `--label Elm`. Expect the two success lines seen on 2026-07-10
  (evidence #1, #3).
- [ ] Verify via Figma MCP `get_code_connect_map` on set `57994:2227` and variant
  `57994:2322`, once per `codeConnectLabel`: per-variant evaluated snippets for BOTH
  labels (`size="medium" shape="rounded"` on 2322; `M3e.Token.md`/`M3e.Token.rounded` on
  the Elm side) — the acceptance is that GENERATED artifacts reproduce the hand-written
  spike results (evidence #2–#4).
- [ ] ⚑ HUMAN (optional, 10s): eyeball Dev Mode's Code Connect panel label dropdown shows
  both labels.
- [ ] `unpublish` both labels (leave the file clean until Plan E breadth publish);
  `published.json` returns to empty; write the session's outcomes into
  `research/evidence/` as a dated note.

**Verify:** MCP responses captured in the evidence note; `published.json` empty;
`npm run check` green; `git status` clean except intended artifacts.
**Commit:** `test(m3-kit): tracer publish/verify/unpublish from generated artifacts (evidence note)`

---

## Acceptance (Plan B done)

1. `emit` produces both labels from `status:"confirmed"` entries; byte-stable; drift+orphan
   guarded (`npm run check` in CI posture).
2. Publish runner is fileKey-parameterized (per-copy republish proven by the staging-rewrite
   test) and token-safe.
3. Tracer: button published, MCP-verified per-variant for both labels, unpublished — from
   generated files only.
4. Elm names provably sourced from post-review elm-m3e facts (no hardcoded vocabulary).
