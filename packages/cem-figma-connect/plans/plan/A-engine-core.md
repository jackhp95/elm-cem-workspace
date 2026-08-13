# Plan A — Engine core: scaffold, ingest, matcher, correspondence, gap report

> Read `plans/00-mission-and-decisions.md` + `plans/01-architecture.md` first.
> Evidence citations ("evidence #N") refer to the ledger table in 00.
> Everything here runs offline against checked-in fixtures — no Figma session required
> except the ⚑ HUMAN re-extraction task (A3), which the checked-in dumps stand in for.

Deliverable: `node src/cli.mjs match --profile m3-kit` produces
`profiles/m3-kit/correspondence.json` containing (among proposals for all 121 tags) a
**button entry with 5-set fusion, Size/Type axis maps, and Label text/Show icon/Icon
property maps** — the tracer input Plan B consumes — plus `gap-report.md`.

---

### Task A1: Repo scaffold

**Files:** Create: `package.json`, `src/cli.mjs`, `src/lib/validate.mjs`,
`test/smoke.test.mjs`. Modify: `.gitignore`.

- [ ] `package.json`: `"name": "cem-figma-connect"`, `"private": true` (D9 — repo private
  until release; flip to publishable only on the user's release call), `"type": "module"`,
  `"engines": {"node": ">=22"}`, scripts: `"test": "node --test test/"`,
  `"match"`, `"emit"`, `"publish:cc"`, `"gap"` (wired in later tasks; stub now to
  `node src/cli.mjs <cmd>`).
- [ ] Dependencies: **none for core logic**. Schema validation is **hand-rolled**
  (`src/lib/validate.mjs`): our schemas are small, closed, and stable, and a ~120-line
  checker (type/enum/required/items/additionalProperties) keeps the core zero-dep, which is
  a stated architecture goal (§4). Rationale recorded here so nobody "helpfully" adds ajv:
  if schema needs outgrow the hand-rolled checker (conditionals, refs), switch to ajv as a
  **devDependency** with a compiled-validator build step — not before.
- [ ] `src/cli.mjs`: subcommand dispatcher (`match`, `review`, `confirm`, `gap`, `extract`,
  `emit`, `publish`, `unpublish`, `check`) — unknown commands exit 2 with usage. No
  framework; `process.argv` parsing only. `--profile <name>` takes a bare profile name,
  resolved to `profiles/<name>/` — never a path.
- [ ] Directory skeleton per architecture §4: `src/{ingest,match,correspond,emit,tokens,publish,visual}/`,
  `extract/`, `profiles/m3-kit/`, `test/fixtures/`.
- [ ] `test/smoke.test.mjs`: CLI dispatches + validator accepts/rejects a trivial schema.

**Verify:** `node --test test/` green; `node src/cli.mjs nosuch; echo $?` → prints usage,
exit `2`.
**Commit:** `feat: scaffold cem-figma-connect CLI, zero-dep validator, src layout`

---

### Task A2: figma-export.json schema, loader, fixtures

**Files:** Create: `src/ingest/figma.mjs`, `src/ingest/figma-export.schema.json`,
`test/figma-ingest.test.mjs`, `test/fixtures/figma-export.m3-kit.json` (built from the
checked-in dumps).

The export is ONE JSON file per Figma file — the deterministic input the whole pipeline
consumes (D9). Shape (top-level keys):

- [ ] `meta`: `{ fileKey, fileName, extractedAt, kitVersionTag }` — `extractedAt` and
  `kitVersionTag` are **passed in** by the extractor invocation, never computed at load
  time (determinism).
- [ ] `components`: flat array `{ id, name, type: "COMPONENT"|"COMPONENT_SET", key,
  description, page }` — exactly the 6-field shape of
  `research/figma-dumps/m3-kit-components.json` (5,770 nodes; component counts per
  `research/evidence/06a-expressive-delta.md`). `key` is retained but downstream code MUST
  treat it as per-fileKey cache (evidence #5).
- [ ] `setProperties`: `{ [setNodeId]: [{ name, type: "VARIANT"|"TEXT"|"BOOLEAN"|
  "INSTANCE_SWAP", defaultValue, variantOptions?, preferredValues? }] }` — the shape
  observed in `research/figma-dumps/kit-props-button-main.json` (evidence #10). Note
  non-variant property names carry a `#id` suffix (`"Label text#58653:0"`); the loader
  exposes both `rawName` and `displayName` (suffix stripped) — Code Connect's `getString`
  consumes the display name ("Label text" worked live, evidence #2).
- [ ] `variables`: `{ collections: [{ id, name, modes: [{ id, name }] }], variables:
  [{ id, name, resolvedType, collectionId, valuesByMode, codeSyntax, scopes }] }` — shape
  as in `research/figma-dumps/kit-variables.json` (304 vars, 4 collections, 32-mode M3
  collection; evidence #13).
- [ ] `styles`: `{ paintStyles, textStyles, effectStyles }` pass-through of
  `kit-styles.json` shapes.
- [ ] Loader `loadFigmaExport(path)`: validates against the schema, derives
  `sets`/`standalones`/`variants` views (variant = COMPONENT whose name contains `=`;
  standalone = the rest — the reconstruction proven in the ledger), parses variant names
  into `{prop: value}` pairs, groups variants by page.
- [ ] Build `test/fixtures/figma-export.m3-kit.json` with a committed builder script
  (`test/fixtures/build-m3-kit-fixture.mjs`) that assembles it from
  `research/figma-dumps/{m3-kit-components,kit-variables,kit-styles,kit-doc-info,kit-props-*}.json`
  with `meta.fileKey = "KujuFlfJSwHI6ua1b7RZvL"`. `setProperties` will only contain the two
  button sets we captured — the schema marks it optional-per-set; A3's extractor fills it
  for all 171 sets later. Matcher tasks must therefore not hard-require `setProperties`.

**Verify:** `node --test test/figma-ingest.test.mjs` asserts: 5,770 components, 171 sets,
5,354 variants, 245 standalones, 304 variables, 32 modes on the `M3` collection, 0 variables
with non-empty codeSyntax, button set `57994:2227` has VARIANT props `Type/Size/Width/State`
and TEXT `Label text`.
**Commit:** `feat: figma-export schema, loader, m3-kit fixture from checked-in dumps`

---

### Task A3: Extraction port (`extract/`) ⚑ HUMAN (live half)

**Files:** Create: `extract/README.md` (runbook), `extract/plugin/` (generalized fork),
`extract/relay/socket.ts`, `extract/export.mjs`. Copy provenance from
`~/code/avetta/akg-synapse/scripts/ingest/{figma-plugin,figma-ws}/`.

- [ ] Port ONLY the needed plugin handlers into `extract/plugin/code.js`: `ping`,
  `get_document_info`, `get_local_components`, `get_component_properties`, `get_variables`,
  `get_styles`, `export_node_as_image`. Drop write handlers and everything VSD-specific.
  **Provenance headers in every ported file**: "Adapted from avetta/akg-synapse VSD plugin,
  itself adapted from cursor-talk-to-figma-mcp (sonnylazuardi, MIT)."
  **Release blocker (record in README): Avetta IP review of this port before the repo goes
  public** (architecture §4 note).
- [ ] Plugin constraints preserved as comments + README rules (all hit live, per the akg
  runbook): plugin VM is **ES2019 — no `??`/`?.`** (they fail to parse and silently kill
  the plugin); `code.js` historically contained a **NUL byte** — always search with
  `grep -a`; plugin code reloads ONLY when the plugin instance is re-run from Plugins →
  Development (a relay restart is not enough — the tell is an unchanged channel id).
- [ ] `extract/relay/socket.ts`: port of the WS relay. **Requires bun** (`Bun.serve`, port
  3055) — node cannot run it; README says `mise use -g bun` then
  `bun extract/relay/socket.ts`.
- [ ] `extract/export.mjs` (node): one command →
  `node extract/export.mjs --file-label m3-kit --file-key <k> --kit-version <tag> --out <path>`.
  Orchestrates over the WS bridge: `get_document_info` → `get_local_components` →
  `get_component_properties` for **every** COMPONENT_SET id → `get_variables` →
  `get_styles`, assembles the Task-A2 schema, stamps `meta` from CLI args. Channel
  auto-discovery per the akg client (`list_bridges`); `--channel` override for
  multi-bridge situations.
- [ ] `extract/README.md` runbook: (1) bun relay up; (2) ⚑ HUMAN: open the target file in
  Figma desktop **in Design mode** (Dev-mode bridges are rejected as non-writable and
  per-id variable getters throw), run the plugin, click "Start WS Bridge"; (3) run
  `export.mjs`; (4) **master-file caveat**: `get_local_components` only enumerates
  components defined in the OPEN file — Figma's Plugin API has no team-library component
  enumeration (its `teamLibrary` API exposes variables only), so always confirm the open
  file is the kit itself, not a consumer.
- [ ] README section "Alternate producers of the same schema": (a) **Figma REST API** —
  components/sets/styles per file with any PAT, **but the variables endpoint is
  Enterprise-only**; fine for adopters without plugin access, lossy on tokens. (b)
  **Figma MCP `use_figma`** — read scripts can produce the same JSON (proven for
  variables/codeSyntax live, evidence #6); slower, needs claude.ai auth. Both must emit the
  exact Task-A2 schema; the schema, not the transport, is the contract.
- [ ] ⚑ HUMAN acceptance run (batched with any other Figma session): re-extract the user's
  kit copy end-to-end and diff structure (not values) against the checked-in fixture;
  refresh `research/figma-dumps/` with the now-complete `setProperties` for all 171 sets.

**Verify (offline):** relay + export.mjs lint-run with `--dry` flag that stubs the bridge
and emits fixture-shaped output; `grep -rn "??\|?\." extract/plugin/code.js` → no modern
syntax. **Verify (⚑ HUMAN):** live re-extraction validates against the schema and reports
171/171 sets with properties.
**Commit:** `feat: generalized Figma extraction (plugin+relay+export) with provenance and runbook`

---

### Task A4: CEM ingest with .d.ts alias inlining

**Files:** Create: `src/ingest/cem.mjs`, `src/ingest/dts-inline.mjs`,
`test/cem-ingest.test.mjs`. Fixtures: vendor `custom-elements.json` + `dist/src/**/*.d.ts`
of `@m3e/web@2.5.14` under `test/fixtures/m3e-web-2.5.14/` (copy from
`~/code/jackhp95/elm-m3e/docs/node_modules/.pnpm/@m3e+web@2.5.14_*/node_modules/@m3e/web/` —
note the pnpm dir has a peer-dep suffix, not bare `@2.5.14`).

- [ ] `dts-inline.mjs`: standalone **port** (do NOT import elm-cem) of the algorithm in
  `~/code/jackhp95/elm-cem/bin/elm-cem.js` (`inlineTypeAliases`,
  `collectLiteralAliases`, ~lines 391–520): scan the package's `.d.ts` files, collect
  `export type X = "a" | "b" | …` **pure string-literal unions**, rewrite attribute
  `type.text` where it references a collected alias (bare, or in `X | null` / `X |
  undefined` compounds). Single pass is sufficient — the 2.5.14 audit found **zero
  alias-of-alias chains** (evidence #7 / `research/evidence/06b-dts-inlining-coverage.md`).
- [ ] `cem.mjs`: load manifest → tagged declarations → **dedupe to unique tags** (123
  declarations → 121 tags; dupes `m3e-menu-item`, `m3e-stepper-previous` — keep first,
  log). Per attribute, classify post-inline: `boolean | enum | string | number | none |
  other` (mirror the 06b taxonomy). Expose per component: tag, description, attributes
  (with resolved value sets), slots, events, cssProperties, module path.
- [ ] Known-good fallback: `LinkTarget` stays unresolved (its `.d.ts` union contains
  `(string & {})` — deliberately open) → classify `string`. This is CORRECT, not a bug
  (06b §3); encode as a test so nobody "fixes" it.

**Verify:** `node --test test/cem-ingest.test.mjs` asserts the 06b acceptance numbers on
the 2.5.14 fixture: 121 unique tags, 505 attributes, **72/73 distinct aliases collected**,
**96 attribute rows fully inlined**, `LinkTarget` → string, `m3e-button.variant` →
`["elevated","filled","tonal","outlined","text"]`, `m3e-button.size` →
`["extra-small","small","medium","large","extra-large"]`.
**Commit:** `feat: CEM ingest with standalone .d.ts string-literal-union inlining`

---

### Task A5: Normalization + matcher

**Files:** Create: `src/match/normalize.mjs`, `src/match/matcher.mjs`,
`src/match/fusion.mjs`, `test/matcher.test.mjs`.

- [ ] `normalize.mjs`: slug both sides — strip `m3e-` prefix; kebab/space/case-fold;
  singular/plural fold (`Checkboxes` page ↔ `m3e-checkbox`); strip `.Building Blocks/` and
  `Building Blocks/` prefixes but **tag** the origin (`buildingBlock: "dot"|"plain"|null`)
  — they are matched, never excluded (D7).
- [ ] Value normalization for axis values: `XSmall ↔ extra-small`, `XLarge ↔
  extra-large`, `Round ↔ rounded` require a small synonym table + edit-distance ≤ 2 fuzz
  that also absorbs kit typos — the acceptance case is `Presssed → pressed` (evidence:
  ledger 6a caveat).
- [ ] `fusion.mjs` — set-fusion detection (evidence #9): sibling sets on one page matching
  `<Base> - <value>` (and the bare `<Base>`) whose variant-axis signatures are compatible
  ⇒ ONE logical component with a **fixed attribute value per set**, where `<value>`
  fuzzy-matches a member of some CEM enum attribute of the matched component (`Button -
  tonal` ⇒ `variant="tonal"`; bare `Button` ⇒ the enum's CEM default, `filled` per the
  observed kit). Emit fusion groups as single match candidates.
- [ ] `matcher.mjs` — tiers: **exact** (normalized name equal) → **fuzzy** (signals:
  set/page name distance, description token overlap, shared `m3.material.io/components/…`
  URLs — present on BOTH sides: kit set descriptions and CEM class descriptions carry them)
  → **gap**. Output per candidate: `{ cemTag, figmaSetIds, tier, score, rationale }` with
  rationale strings a human can audit ("page 'Buttons', set fusion of 5, doc URL match").
- [ ] Axis + property proposal per match: VARIANT axes → CEM enum attrs via value-set
  overlap (`Size` ↔ `size` because 5/5 values map); axes with no CEM counterpart (`Width`,
  `State`) → `unmapped` with reason; TEXT/BOOLEAN/INSTANCE_SWAP properties → proposals
  (TEXT default→content, `Show icon`→icon-slot presence, INSTANCE_SWAP `Icon`→icon slot).
- [ ] Icons (D7, evidence #12): standalone components on the Icons page match `m3e-icon`
  with `name = <snake_case component name>` — one logical entry with a per-icon value
  table, not 141 entries.

**Verify:** `node --test test/matcher.test.mjs` on the fixtures asserts: button fusion
group = 5 sets incl. `57994:2227`; `Size` axis maps all five values; `Type` maps
`Round→rounded, Square→square`; `Width`/`State` emitted as `unmapped`; `Presssed`
normalizes to `pressed`; checkbox/chips match at exact tier; icon entry covers 141 names.
**Commit:** `feat: normalization, set-fusion detection, tiered matcher with auditable rationale`

---

### Task A6: Correspondence schema, merge semantics, review CLI

**Files:** Create: `src/correspond/schema.json`, `src/correspond/merge.mjs`,
`src/correspond/review.mjs`, `profiles/m3-kit/profile.json`,
`profiles/m3-kit/overrides.json` (empty scaffold), `test/correspond.test.mjs`.

- [ ] `schema.json` — `correspondence.json` is an array of entries:
  ```jsonc
  {
    "cemTag": "m3e-button",
    "figmaSets": [{ "nodeId": "57994:2227", "setName": "Button",
                    "fixedAttrs": { "variant": "filled" } }, …],
    "axes":  [{ "figmaProp": "Size", "attr": "size",
                "valueMap": { "XSmall": "extra-small", … } },
              { "figmaProp": "Width", "unmapped": "no CEM counterpart" }],
    "props": [{ "figmaProp": "Label text", "kind": "text",   "binding": "content" },
              { "figmaProp": "Show icon",  "kind": "boolean","binding": "slot:icon" },
              { "figmaProp": "Icon",       "kind": "instanceSwap", "binding": "slot:icon" }],
    "confidence": 0.97, "provenance": "auto-exact",
    "rationale": "…", "status": "proposed"
  }
  ```
  `provenance ∈ auto-exact|auto-fuzzy|human`; `status ∈ proposed|confirmed|rejected`.
  **Component keys live in a separate per-fileKey cache**
  (`profiles/<p>/keys.<fileKey>.json`), never in correspondence — evidence #5.
- [ ] `iconTable` entry kind (icons as ONE logical entry, D7 + A5): the schema admits
  `{ "kind": "iconTable", "cemTag": "m3e-icon", "icons": [{ "figmaNodeId", "figmaName",
  "symbolName" }], "provenance", "status" }` — a per-icon value table, not 141 entries; it
  flows through the same merge/provenance/status semantics as component entries.
- [ ] `merge.mjs`: `match` regenerates proposals but an existing entry with
  `provenance:"human"` or `status:"confirmed"` is **never modified** — new auto data lands
  as `proposedUpdate` alongside it. Delta configs (consumer profiles, Plan F) overlay with
  `add | override | suppress` per cemTag. Deterministic ordering (sort by cemTag) so diffs
  are reviewable.
- [ ] `review.mjs`: `review` emits `profiles/<p>/REVIEW.md` — one table row per
  component+property decision (never per-variant, architecture §3.5): tag, sets, axis proposals,
  confidence, rationale, `[ ]` accept column. `confirm --from REVIEW.md` (or
  `overrides.json` edits) flips status/provenance.
- [ ] `profiles/m3-kit/profile.json`: pins fileKey `KujuFlfJSwHI6ua1b7RZvL`, kit version
  tag, export path, `@m3e/web` version `2.5.14`, emitter list (Plan B fills).

**Verify:** `node --test test/correspond.test.mjs`: schema validates the button entry;
re-running `match` twice is byte-stable; a hand-flipped `provenance:"human"` entry survives
a re-match unchanged; suppress-delta removes a tag from emit set without deleting the entry.
**Commit:** `feat: correspondence schema, human-preserving merge, review/confirm CLI`

---

### Task A7: Gap report

**Files:** Create: `src/correspond/gap-report.mjs`, `test/gap-report.test.mjs`.

- [ ] `gap` CLI → `profiles/<p>/gap-report.md` with sections (D6 — log, never author):
  **code-only** (CEM tags with no kit counterpart — expect the select/autocomplete/
  breadcrumb/stepper/tree/paginator family plus triggers/infra, ~68 at name level),
  **figma-only** (kit sets with no CEM tag — carousel, time pickers, side sheet, bottom app
  bar, XR sets), **valid-but-undrawn** (per matched component: cartesian CEM value space
  minus materialized kit variants — the completeness inversion, plans/BRIEF.md §7.4),
  **unmapped-axes** (`Width`, `State`, … with per-component notes).
- [ ] Counts header + per-section tables with rationale; deterministic ordering.

**Verify:** on fixtures, section counts within the 06a envelope (53 matched / 68 CEM-only
at name tier; kit-only list contains carousel + time pickers), and the button's
valid-but-undrawn includes `variant=elevated × shape=square × size=extra-small` style
combinations only if absent from the dump.
**Commit:** `feat: gap report (code-only/figma-only/undrawn/unmapped) as first-class artifact`

---

### Task A8: Tracer acceptance — the button entry

**Files:** Create: `profiles/m3-kit/correspondence.json` (generated),
`profiles/m3-kit/gap-report.md` (generated).

- [ ] `node src/cli.mjs match --profile m3-kit && node src/cli.mjs gap --profile m3-kit`;
  commit the outputs (they are inputs to B and reviewable artifacts).
- [ ] Confirm (via `review`/`confirm`) the button entry ONLY — the tracer proceeds on a
  `status:"confirmed"` button; everything else stays `proposed` until Plan E breadth.

**Verify:** `jq '.[] | select(.cemTag=="m3e-button")' profiles/m3-kit/correspondence.json`
shows 5 fused sets, Size/Type axis maps, 3 props, `status:"confirmed"`; regenerate → only
provenance-respecting changes (`git diff --exit-code` after a second run).
**Commit:** `feat(m3-kit): generated correspondence + gap report; confirm m3e-button tracer entry`
