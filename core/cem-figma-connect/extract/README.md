# extract/ — generalized Figma extraction

Produces `figma-export.json` — the ONE deterministic per-Figma-file JSON the rest of the
pipeline consumes (see `src/ingest/figma-export.schema.json` + `src/ingest/figma.mjs`).
**The schema is the contract, not the transport**: this directory is one producer of that
schema (a Figma plugin + WS relay + CLI), but it is not the only valid one — see
"Alternate producers of the same schema" below.

This is a generalized, narrowed fork of `avetta/akg-synapse`'s VSD Design System Dumper
plugin (`scripts/ingest/figma-plugin/`) and its WS relay (`scripts/ingest/figma-ws/`).
Every write primitive and everything VSD/push-synapse-specific was dropped; only the
read commands this pipeline needs were ported. **Provenance header present in every
ported file**: "Adapted from avetta/akg-synapse VSD plugin, itself adapted from
cursor-talk-to-figma-mcp (sonnylazuardi, MIT)."

## ⚠️ Release blocker

**This port has not yet been through Avetta IP review.** Do not make this repository
public until that review is recorded here. The code technique (WebSocket relay +
self-hosted Figma plugin bridge) originates with `cursor-talk-to-figma-mcp`
(sonnylazuardi, MIT) and was previously adapted once already inside `avetta/akg-synapse`;
this is a second-generation adaptation of Avetta-authored code, which is why it needs
sign-off before this repo (currently private) goes public.

## Layout

```
extract/
  plugin/           Figma plugin (self-hosted — install by manifest, no community
                     plugin dependency). code.js / manifest.json / ui.html.
  relay/socket.ts   WS relay server. Requires bun (Bun.serve, port 3055).
  lib/              Node-side WS client: channel auto-discovery, ping-verified
                     health check, and the request/response query function.
  export.mjs        CLI: orchestrates the bridge calls, assembles + validates +
                     writes figma-export.json.
```

## Runbook

### 1. Start the relay (bun required — node cannot run `Bun.serve`)

```bash
mise use -g bun
bun extract/relay/socket.ts
```

Leave this running in its own terminal. Default port `3055` (override with
`FIGMA_WS_PORT=3056 bun extract/relay/socket.ts` — if you do, also add the port to
`extract/plugin/manifest.json`'s `networkAccess.allowedDomains`, or the plugin's iframe
will not be permitted to open that WS URL).

### 2. ⚑ HUMAN — open the file in Figma desktop, in Design mode, and start the bridge

1. **Design mode, not Dev mode.** Dev-mode bridges are rejected as non-writable by the
   caller's channel-selection logic (`extract/lib/bridge-select.mjs` only picks
   `editorType === "figma"`), and some read calls (e.g. per-id variable getters) have been
   observed to throw in Dev Mode against the upstream plugin this was forked from. Toggle
   Dev Mode off (Shift+D) before running the plugin if the file opens into it by default.
2. One-time install: **Plugins → Development → Import plugin from manifest…** → select
   `extract/plugin/manifest.json`.
3. Run it: **Plugins → Development → cem-figma-connect Extract Bridge → "Start WS Bridge"**.
   A small panel opens and should show `✓ connected · channel: cem-<hex>` within a second
   or two. Keep the panel open for the duration of the extraction — closing it closes the
   WebSocket connection.
4. **Plugin code reloads ONLY when the plugin instance is re-run from Plugins →
   Development** — restarting the relay (step 1) is NOT enough to pick up a `code.js`
   edit. The tell that you're running stale plugin code: the channel id in the panel
   doesn't change between runs when it should, or a command the current source defines
   comes back `"unknown command"`.

### 3. Run the extractor

```bash
node extract/export.mjs \
  --file-label m3-kit \
  --file-key <figma-file-key> \
  --kit-version <tag> \
  --out research/figma-dumps/figma-export.<label>.json
```

This orchestrates, over the WS bridge: `get_document_info` → `get_local_components` →
`get_component_properties` for **every** `COMPONENT_SET` id returned by step 2 →
`get_variables` → `get_styles`; assembles the result into the Task-A2 schema shape;
validates it against `src/ingest/figma-export.schema.json`; and only then writes `--out`.
A validation failure exits non-zero and writes nothing — there is no such thing as a
partially-written, schema-invalid `figma-export.json` from this tool.

`meta` (`fileKey`, `kitVersionTag`, `extractedAt`) is stamped **verbatim from CLI args**,
never computed from the live document — this is a determinism requirement (D9): the same
invocation against the same file state should be reproducible. Pass `--extracted-at` (ISO
8601) explicitly if you need a fixed timestamp; otherwise it defaults to "now".

Channel selection is automatic: `extract/lib/bridge-health.mjs` asks the relay's
`list_bridges` registry, then **pings** each candidate (a real round-trip, not just a
`lastSeen` timestamp check — an idle-but-live bridge's `lastSeen` goes stale even though
it would answer instantly) and picks the newest writable (`editorType === "figma"`) one
that answers. Pass `--channel <name>` to skip discovery and target a specific channel
directly — required if more than one writable bridge is live and you don't want
"newest wins" to pick for you.

### `--dry`: no relay, no Figma

```bash
node extract/export.mjs --dry \
  --file-label m3-kit --file-key <k> --kit-version <tag> --out /tmp/figma-export.json
```

Stubs the bridge entirely with a small, schema-shaped fixture (one `COMPONENT_SET` with
two variants, a standalone, a variable, and one of each style type) and runs it through
the exact same assemble-then-validate path as the real bridge. Useful for developing
against this pipeline, and for CI, without a live Figma session. This is what task A3's
offline verification exercises — see `test/extract-export-dry.test.mjs`.

### 4. Master-file caveat

`get_local_components` only enumerates components **defined in the currently open file**.
The Figma Plugin API has no team-library component enumeration — its `teamLibrary` API
(used by `get_variables`) exposes **variables** from published libraries, but not
components or component sets. **Always confirm the file you have open is the kit itself**,
not a file that merely *consumes* the kit's published library — a consumer file will
silently produce an empty or near-empty `components` array with no error.

### ⚑ HUMAN acceptance run — deferred to a batched Figma session

Not attempted this session (no Figma access; explicitly out of scope for the offline
half of task A3). When it happens:

1. Re-extract the user's kit copy end-to-end via the runbook above.
2. Validate the result against `src/ingest/figma-export.schema.json` (`loadFigmaExport()`
   already does this on load — a thrown error means it's invalid).
3. Diff **structure**, not values, against the checked-in fixture
   (`test/fixtures/figma-export.m3-kit.json`) — component/variant/set counts, the set of
   `setProperties` keys, variable collection/mode shapes.
4. Confirm **171/171** `COMPONENT_SET`s now have a `setProperties` entry (the fixture only
   has the two captured button sets — see `test/fixtures/build-m3-kit-fixture.mjs`).
5. Refresh `research/figma-dumps/` with the now-complete dumps.

## Alternate producers of the same schema

`figma-export.json`'s schema is the contract; nothing requires it to come from this
plugin+relay. Two other paths can produce the same shape, with different tradeoffs:

- **Figma REST API.** Any Personal Access Token can fetch components, component sets, and
  styles per file. **The variables endpoint is Enterprise-only**, though — fine for
  adopters without plugin/Figma-desktop access, but lossy on design tokens (you'd be
  missing `variables.collections`/`variables.variables` entirely, or need a separate
  token-export path). No relay, no plugin install, but weaker coverage.
- **Figma MCP `use_figma`.** Read scripts driven through the official Figma MCP server can
  produce the same JSON shape — this was proven live for variables + `codeSyntax` in the
  akg-synapse work this was forked from (evidence #6 there). Slower than the WS bridge for
  bulk extraction, and needs claude.ai / Figma desktop MCP auth, but requires no plugin
  install and works from an agent session directly.

Both alternates must emit the **exact** Task-A2 schema (`src/ingest/figma-export.schema.json`)
to be usable by the rest of this pipeline — `loadFigmaExport()` doesn't know or care which
producer wrote the file it's loading.

## Plugin VM constraints (hit live in the akg-synapse runbook; preserved here)

- **The plugin VM is ES2019.** Do not use the nullish-coalescing operator (`??`) or
  optional-chaining (`?.`) ANYWHERE in `extract/plugin/code.js` — the Figma plugin JS
  engine fails to *parse* them, which silently breaks the entire plugin (the bridge never
  attaches, with no visible error in the Figma UI). Verify gate:
  ```bash
  grep -an '??\|?\.' extract/plugin/code.js   # must produce no output
  ```
- **`code.js` has historically contained a NUL byte** in the akg-synapse source this was
  forked from (inside a write-only font-loading helper that was not ported here — see the
  note in `extract/plugin/code.js`). Always search Figma plugin sources with `grep -a`,
  never plain `grep` — a NUL byte silently truncates a naive text-tool match without
  erroring.
- **Plugin code reloads only when the plugin instance is re-run** from Plugins →
  Development. Restarting the relay does not reload it — see step 2.4 above.

## Troubleshooting

- **Relay fails to start with `EADDRINUSE` on port 3055.** Don't assume it's your own
  stale process — port 3055 is also `avetta/akg-synapse`'s default WS relay port
  (`scripts/ingest/figma-ws/socket.ts`). If both projects' relays are ever run on the same
  machine, whichever binds first wins the port, and — since channel auto-discovery
  (`extract/lib/bridge-health.mjs`) has no project-scoping, only a `list_bridges` query
  against whatever relay answers on `:3055` — a caller here could silently talk to an
  **unrelated, already-live Figma bridge** from the other project instead of failing
  loudly. (Observed directly while building this: an `extract/export.mjs` smoke test
  during A3 development bound to an already-running akg-synapse relay this way, and its
  auto-discovery picked the other project's real, live bridge over a local test stub —
  harmless here, since every command `extract/plugin/code.js` can answer is read-only, but
  a real gotcha worth knowing about.) If you need both relays up at once, run one of them
  on a different port with `FIGMA_WS_PORT` and pass matching `--channel`/`FIGMA_WS_URL` on
  the caller side, or just don't run them concurrently.
- **`export.mjs` hangs on the first command.** The relay is up but no plugin panel is
  attached (or it's on a different channel and auto-discovery isn't finding it). Confirm
  the plugin panel shows `✓ connected`, and that `--channel` (if passed) matches.
- **`Cannot auto-select a Figma bridge (no_writable)`.** Only a Dev-Mode bridge was found.
  Open the file in Design mode instead (see step 2.1).
