# USAGE — the end-to-end pipeline

One walkthrough, in order, from a fresh clone to published Figma Code Connect bindings.
Commands are verified against `src/cli.mjs` and `package.json`; see
[`../README.md`](../README.md) for prerequisites and the no-Figma quickstart, and
[`../extract/README.md`](../extract/README.md) for extraction details.

The pipeline is:

```
install → extract → match → review/confirm → gap → emit → visual gate → publish
```

Steps **extract**, **visual gate**, and **publish** need live Figma access (and, for
publish, a token — see below). Everything between them runs offline against the
checked-in dump in `research/figma-dumps/`, so you can do `match → … → emit` with no
Figma at all.

## Key concepts

- **`--profile <name>`** — every CLI command resolves a bare profile name to
  `profiles/<name>/` (never a path). The only profile today is **`m3-kit`**. It pins the
  CEM (`@m3e/web`), the Figma export, and the target `fileKey`
  (`profiles/m3-kit/profile.json`).
- **Two emitter labels.** The profile emits each confirmed correspondence entry under two
  Figma Code Connect labels — **"Web Components"** (the built-in `html-label` emitter →
  `generated/m3-kit/web-components/`) and **"Elm"** (the profile-local emitter at
  `profiles/m3-kit/emitters/elm.mjs` → `generated/m3-kit/elm/`). Both labels coexist on the
  same Figma node, filterable in Dev Mode via `codeConnectLabel`.
- **`--file-key <key>`** — the Figma file to publish into. Passed explicitly to `publish`;
  it is not defaulted (see "Two different fileKeys, two different roles" at the bottom —
  this is the *publish-target* fileKey, distinct from the profile's extraction-anchor
  fileKey).
- **`FIGMA_ACCESS_TOKEN`** — required for `publish`/`unpublish` only. Read from the
  **environment only** (`requireToken` in `src/publish/runner.mjs` refuses to read it from a
  file). Needs scopes **Code Connect: Write** + **File content: Read** on a Figma
  **Organization or Enterprise** plan.

---

## 0. Install

```bash
pnpm install
```

Requires Node `>=22` and pnpm. See the README for the full-pipeline prerequisites (bun,
Playwright Chromium, Figma desktop, a token).

## 1. Extract — produce `figma-export.json` (⚑ needs Figma desktop + bun)

The rest of the pipeline consumes one deterministic per-file JSON. A checked-in dump
already exists (`research/figma-dumps/figma-export.m3-kit.json`), so **you can skip this
step** unless you are re-pulling the kit. Full runbook and troubleshooting:
[`../extract/README.md`](../extract/README.md).

```bash
# a) Start the WS relay (bun required — Node cannot run Bun.serve). Leave it running.
bun extract/relay/socket.ts

# b) ⚑ HUMAN: in Figma desktop, open the kit file in DESIGN mode (not Dev mode),
#    then Plugins → Development → Import plugin from manifest… → extract/plugin/manifest.json,
#    then run it and click "Start WS Bridge". Wait for "✓ connected · channel: cem-<hex>".

# c) Run the extractor (writes only on schema-valid output):
node extract/export.mjs \
  --file-label m3-kit \
  --file-key <figma-file-key> \
  --kit-version <tag> \
  --out research/figma-dumps/figma-export.m3-kit.json
```

If you refresh the export, update `figmaExportPath` / `fileKey` / `kitVersionTag` in
`profiles/m3-kit/profile.json` together (they pin one kit version), then re-run `match`.

## 2. Match — build the correspondence model

```bash
node src/cli.mjs match --profile m3-kit      # or: pnpm match
```

Merges the CEM and the Figma export into `profiles/m3-kit/correspondence.json`. The merge
**preserves human-confirmed entries** and only regenerates the `auto-*` ones, so re-running
after a kit refresh never clobbers your decisions.

## 3. Review & confirm — the human gate

`match` proposes; a human confirms. Nothing publishes until an entry is `confirmed`.

```bash
node src/cli.mjs review --profile m3-kit     # writes profiles/m3-kit/REVIEW.md for eyeballing
node src/cli.mjs confirm --profile m3-kit    # applies decisions (e.g. profiles/m3-kit/overrides.json) → correspondence.json
```

For the pixel-diff side of the gate there is also a small **review web app**:

```bash
node src/visual/review/server.mjs --profile m3-kit          # http://127.0.0.1:<port>
node src/visual/review/server.mjs --profile m3-kit --port 5173   # stable URL
# add --host 0.0.0.0 to expose on a tailnet (opt-in)
```

## 4. Gap — the code-only / Figma-only report

```bash
node src/cli.mjs gap --profile m3-kit        # or: pnpm gap
```

Writes `profiles/m3-kit/gap-report.md` (matched / code-only / figma-only /
valid-but-undrawn / unmapped-axes counts). A first-class report, not a failure — it is how
coverage gaps stay visible instead of silent.

## 5. Emit — generate the Code Connect bindings

```bash
node src/cli.mjs emit --profile m3-kit       # or: pnpm emit
```

Emits every `confirmed` entry into `generated/m3-kit/<label-slug>/` for **both** labels,
each with a `MANIFEST.json`. Deterministic (byte-stable). The drift/orphan gate enforces
that the committed output matches the correspondence model:

```bash
pnpm check                                   # generated/** matches correspondence.json (0 drift, 0 orphan)
```

Never hand-edit files under `generated/**` — `check` (and CI) will fail.

## 6. Visual gate — "matched" must mean "pixel-proven" (⚑ needs the Figma bridge)

Before publishing a component, prove its rendered output matches Figma. The single-component
orchestrator hits the live bridge for the Figma-export side, so the relay + plugin from
step 1 must be connected (note the `--channel` from the plugin panel):

```bash
node src/visual/gate.mjs --tag=<cemTag> --channel=cem-<hex> [--profile=m3-kit] [--scale=2]
```

Exit code `1` (and `status: "failed"`) on a diff over threshold; a passing/approved gate is
what lets `publish` include that binding (blocked ones are skipped unless `--force-gate`).

## 7. Publish — upload the bindings (⚑ needs a token + org/enterprise plan)

```bash
export FIGMA_ACCESS_TOKEN=…    # Code Connect: Write + File content: Read; org/enterprise plan

# Dry-run first — validates and stages without binding anything in Figma:
node src/cli.mjs publish --profile m3-kit --label "Web Components" --file-key <key> --dry-run

# Real publish, per label:
node src/cli.mjs publish --profile m3-kit --label "Web Components" --file-key <key>
node src/cli.mjs publish --profile m3-kit --label "Elm"            --file-key <key>
```

Notes:

- **Omit `--label` to publish every label** in the profile (both "Web Components" and "Elm").
- `publish` refuses unless `check` passes (no drift/orphan) and the profile has a real
  `kitVersionTag` (not the placeholder). It stages a per-`fileKey` copy, rewriting each
  binding's URL to the target file (node-ids intact) — `generated/**` itself is never
  mutated.
- Only entries the visual gate marks `pass`/`approved` are published; others are listed and
  skipped. `--force-gate` overrides this (loud per-binding warning; never for CI).
- Tear a binding down with `node src/cli.mjs unpublish --profile m3-kit --label <label> --file-key <key>`.

---

## Two different fileKeys, two different roles (D14)

What looked like a 3-way disagreement was actually two distinct roles being named with the
same word. Both are settled structurally; only one still needs a live-Figma decision.

- **Extraction anchor** — `profiles/m3-kit/profile.json`'s `fileKey` (`UtwpUdPiOZEuxp8Nq1d5yQ`)
  + `kitVersionTag`. This pins the epoch the checked-in dump
  (`research/figma-dumps/figma-export.m3-kit.json`) and every node-id in
  `correspondence.json` were matched against. **Settled, not in question** — it refreshes
  only when the kit is re-extracted, and `fileKey`/`kitVersionTag` always move together
  (architecture §1, evidence #5).
- **Publish target** — the `--file-key` flag passed to `publish` at run time.
  `materializeStaging` (`src/publish/runner.mjs`) rewrites each staged binding's `// url=`
  line to this value at publish time; node-ids resolve correctly against **any** duplicate
  of the same kit version, because component keys re-mint on duplication but node-ids don't
  (evidence #5). This is genuinely still open between the two candidates below — but
  resolving it costs one `--dry-run`, and nothing in the pipeline before `publish` depends
  on the answer.
  - **`KujuFlfJSwHI6ua1b7RZvL`** — the D2 drafts copy (`plans/00-mission-and-decisions.md`).
  - **`iPFL8MH2R1Xphe94j7g809`** — a 2026-08-04 writable duplicate
    (`research/figma-dumps/figma-export.m3-kit-copy.json`), possibly made specifically to
    get write access — unconfirmed.

`--file-key` is always passed explicitly, so no command picks silently. Resolve the publish
target with `node src/cli.mjs publish --profile m3-kit --dry-run --file-key <candidate>`
the next time live Figma access is available (see `plans/2026-08-17-figma-elm-config-integration-design.md`
Phase 4) — whichever candidate doesn't error is the answer.
