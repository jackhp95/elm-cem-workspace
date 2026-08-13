# Visual gate review webapp (task C6)

Human review UI for the visual gate (Plan C, D8). Lists every **failing** comparison
from the latest results run (`render-cache/results/<runId>.jsonl`, written by
`src/visual/diff.mjs`) whose entry is not already decided, and lets a human
approve/reject/retarget it. Decisions write **immediately** into the profile's
`overrides.json` — there is no bulk "save" step to lose a session's work.

## Run it

```sh
node src/visual/review/server.mjs --profile m3-kit --port 4747
```

On start it prints a one-line summary (`N pending failure(s) to review (run <runId>)`,
or a note that no results run exists yet), then serves the UI at
`http://127.0.0.1:4747`. Omit `--port` (or pass `--port=0`) to bind an ephemeral port
instead — the server prints whichever URL it actually bound.

## How a gate status is derived

`src/visual/status.mjs`'s `status(entry)` is the single source of truth (also the
function `src/publish/runner.mjs`'s publish gate calls). It is **derived at read
time** from two files — never a third mutable store:

- the latest run's results JSONL (`pass`/`diffRatio` per `{entryId, stateId}`), and
- the profile's `overrides.json` (a human decision, if any, for that `cemTag`).

This webapp's job is entirely about producing decisions that land in the second
file; it never writes results itself.

## Actions

| Action     | Writes (into `overrides.json`, keyed by `cemTag`)          | Effect on `status(entry)`                    |
|------------|--------------------------------------------------------------|-----------------------------------------------|
| Approve    | `{ gate: "approved", provenance: "human", note? }`            | Always reports `"approved"`, regardless of results. |
| Reject     | `{ gate: "rejected", provenance: "human", note? }`             | Always reports `"rejected"` — binding stays blocked for publish. |
| Retarget   | `{ gate: "pending", provenance: "human", note? }`              | Reports `"pending"` — frees the binding, e.g. after a human edits the entry's mapping in `correspondence.json`, so a stale failing result stops blocking as `"failed"`. |

Every write goes through `upsertOverride` (`src/correspond/review.mjs`) — the same
shallow-merge-by-`cemTag` discipline Plan A's binding-confirm flow (`runConfirm`)
already uses for the same file, so a `status`/`provenance` decision from that flow
and a `gate`/`note` decision from this webapp coexist on one `cemTag`'s entry without
clobbering each other.

The `note` you type is never written into `correspondence.json`'s `rationale` field
(protected/confirmed entries there are never silently mutated). Instead the UI's
displayed rationale is synthesized at read time — the entry's stored rationale
joined with `"APPROVED: <note>"` / `"REJECTED: <note>"` / `"RETARGETED: <note>"` —
by `effectiveRationale()` in `server.mjs`.

## API (what the UI actually calls; also what the tests call directly)

- `GET /api/queue` → `{ runId, items: [{ cemTag, stateId, diffRatio, threshold,
  matcherKind, rationale, artifacts: { code, figma, diff } }] }`. `artifacts.*` are
  `/api/image?path=...` URLs, not raw filesystem paths.
- `GET /api/image?path=<artifact path>` → the PNG bytes, if (and only if) the
  resolved path lives under the server's cache root (`render-cache/` by default) —
  refuses anything else, 404.
- `POST /api/approve` / `/api/reject` / `/api/retarget`, body `{ cemTag, note? }` →
  `{ cemTag, gate, queue }` (the fresh queue, so the UI/a script can re-render
  without a second round-trip).

## Testing without a browser

`src/visual/review/server.test.mjs` exercises `buildQueue`/`approve`/`reject`/
`retarget` as plain function calls (no HTTP at all) and separately spins up a real
`createServer(...)` instance on an ephemeral loopback port for one end-to-end
HTTP-round-trip check per route. Nothing in the test suite opens a browser or needs
`ui.html`'s JS to execute — the actual human clicking through `ui.html` in a real
browser is the one deferred (⚑ HUMAN) part; everything it would trigger is already
proven here.
