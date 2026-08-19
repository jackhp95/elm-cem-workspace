# Handoff prompt — Figma Code Connect "identical views" (elm-cem / m3-kit)

You are picking up an in-progress effort in `/Users/jhp/code/jackhp95/cem-figma-connect`
(branch `coverage-remediation`). Read this whole prompt first, then start at **"Start here."**
Deeper history/method is in `plans/identical-views-handoff.md` (session 1 + 2 addenda) — this
prompt is the actionable entry point.

## Mandate
Figma Code Connect binds each code snippet (`example:` in a generated `.figma.ts`) to a Figma
node. The two must render the **same view**. A pixel-diff gate scores each binding; **the diff is
trustworthy** (union-box aligns + trims, no scaling). A low score means the binding renders a
*different* view — fix the binding, don't explain it away. Exception (honesty rule): a low score
can be genuinely benign (representative content, or a render-harness artifact) — but *prove* it.

## Where things stand (2026-07-31)
Committed on `coverage-remediation`; `pnpm test` = **711/711**; `pnpm check` byte-stable.
Current gate decisions (in the overrides snapshot): **29 approved / 12 example-verified / 11 rejected.**

The **11 still-rejected** components (the gate now shows only these — 16 item-states):
`badge, card, date-input, dialog, drawer-container, fab-menu, fab-menu-item, list, list-item, nav-item, search-view`

Of those, most were **fixed this session but not yet re-approved** — on reload they should look
right and be ready for the user to approve:
- badge 94%, list 95%, list-item 93%, nav-item 95%, dialog 73–89%, drawer-container 83%,
  fab-menu-item 91%, **date-input MODAL 88%** (docked still 16%).

**Genuinely open (your worklist), highest-value first:**
1. **card** (38/47%) — TWO structurally different nodes (horizontal = avatar+text|media;
   vertical = header avatar+more_vert + media + Title/Subtitle + supporting + Secondary/Primary)
   share ONE `examples.json` example, so any change helping one hurts the other. **Fix:** convert
   card from its auto-`[contains]` match to a **manual** binding with per-set examples (the exact
   mechanism date-input/tab/fab-menu-item already use — `manual-correspondence` `figmaSets[].example`).
   Byte-stable. This is the cleanest high-value win.
2. **fab-menu** (55%) — node is the open menu (3 **tertiary** segments "First/Second/Third", star
   icons) + a **FAB (close icon) at bottom-right**. Needs the real FAB + `m3e-fab-menu-trigger`
   composition, `variant="tertiary"`, corrected item content, AND a render-harness change to open
   the *sibling* menu (the reveal only opens the root). A naive sibling FAB lands at the top
   (the open menu portals) and made it worse — don't repeat that.
3. **date-input docked** (16%) — the modal is done (wrapped); the docked set (`51954:18567`,
   "Docked input date picker [desktop]") is a separate smaller layout — wrap it similarly.
4. **search-view** (3%) — a **representative** binding (auto-banked 2026-07-19, user-approved
   2026-07-30 by eyeball per its overrides note); the gap is by design (its example uses
   image-results; the node shows an avatar+Label+supporting list). Only pixel-match if the user
   asks — rebuild the fullscreen per-set example to avatar + "Label text" + supporting (×3),
   search text "Input text".

## Tooling (some was ephemeral — now preserved in `plans/gate-tooling/`)
- **Repo:** `/Users/jhp/code/jackhp95/cem-figma-connect`, branch `coverage-remediation`.
- **Bridge:** `bun extract/relay/socket.ts` on `:3055`; the Figma **desktop plugin must be
  connected**. `CHANNEL` is per-session — check the plugin's "connecting channel" line and
  **update the `CHANNEL` const in `render-all.mjs`** (currently `cem-504138`). Verify: `lsof -i:3055`.
- **Gate renderer:** `plans/gate-tooling/render-all.mjs` (preserved from scratch). Run
  `node plans/gate-tooling/render-all.mjs --only=<tag1,tag2>`. Reads generated `.figma.ts`
  examples, renders code-vs-**cached**-Figma, writes `render-cache/coverage-review-all/items.json`.
  Figma pngs are cached (no bridge needed for code-only re-renders; delete a figma png to refresh it).
- **Gate UI:** `plans/gate-tooling/review-launch.mjs` → `http://127.0.0.1:4747`, exposed to the
  user via `tailscale serve --https=4747` (tailnet link
  `https://avetta-ykn6hhwjhr.tail93dc3b.ts.net:4747/`). It reads `items.json` **once at startup**
  (restart it to reflect new renders) and **auto-drops approved/example-verified** items (reads the
  scratch overrides), so restarts never re-show cleared sets. It **only re-seeds the scratch
  overrides if that file is missing** (a guard) — never delete it, or you lose the decisions.
- **Decisions = the spec:** the user's approve/reject + per-set notes live in the gate's
  `overrides-review-scratch.json`. **Current snapshot preserved at
  `plans/gate-tooling/overrides-snapshot.json`.** If the live scratch is gone, copy the snapshot to
  wherever `review-launch.mjs` expects it (next to the script) BEFORE starting the gate — otherwise
  it seeds from the committed `profiles/m3-kit/overrides.json` (an all-approved baseline with NO
  rejections) and you lose the review state.
- **`render-cache/coverage-review-all/`** (items.json + code/figma/diff pngs) is on disk but
  **gitignored** — regenerate with render-all (a full run needs the bridge to export figma pngs).
- **Commands:** `pnpm emit --profile m3-kit` (regen 224 `.figma.ts` from examples.json +
  correspondence.json + manual-correspondence.json), `pnpm check` (byte-stable + 0 drift/orphan),
  `pnpm test` (711).

## Method (per binding)
1. Read the user's note for the set in the overrides (the spec). If none, reuse the family's note.
2. Capture the node (`wsQuery("capture_set", {nodeId, scale:1, offset:0, limit:1}, {channel})` —
   render-all imports `extract/lib/ws-query.mjs`) AND view `render-cache/.../figma/<base>.png`.
3. Read the m3e API from `~/.claude/skills/m3e/components/<name>.md` — exact tags/attrs/slots. Don't guess.
4. Rebuild the example: `profiles/m3-kit/examples.json` (matcher bindings, keyed by cemTag) OR
   `manual-correspondence.json` `figmaSets[].example` (manual/per-set). For gate-only representative
   state (size/mode/color/wrap), edit **render-all.mjs** (SELECTED / REVEAL / WIDTHS / WRAP), NOT the binding.
5. `pnpm emit` → `pnpm check` → `node render-all.mjs --only=<tag>` → read the new diffRatio from
   items.json → **view the code png** to confirm.
6. `pnpm test` BEFORE committing. Commit per binding / small batch. **No push/PR unless asked.**
7. Restart the gate so the user can re-review; tell them to reload.

## Gotchas (learned the hard way)
- **Background parity** (the pivotal fix): render-all composites the code side onto the Figma
  node's OWN backdrop — `figmaBgColor()` samples the export's top-left corner; transparent → keep
  alpha, opaque → composite onto that color. This alone fixed ~61/83. Don't revert it.
- **Two artifact classes:** genuine content mismatch (fix examples.json) vs render-harness artifact
  (fix render-all — a stripped `${variant}` default, a missing surface/mode/color, wrong size, a
  needed wrapper). Many "rejections" were the latter, and the binding was already correct.
- **`correspondence.json` is the MERGED file emit reads** (there is NO merge script). Its
  `fixedAttrs` are **matcher-regenerated** — hand-editing them (e.g. a `mode`/`variant`) breaks the
  A8 byte-stability test. Put representative state in the **render harness**, not fixedAttrs.
- **`validateExamples` HTML allowlist is small** (`span div p img input button label`). Using
  `aside`/`nav`/`main`/etc. fails `pnpm test`. Use `div`, or add the tag to
  `src/emit/example-content.mjs`.
- **The example root is always the cemTag** (emit wraps children in `<cemTag>…</cemTag>`). When a
  node is a COMPOSITION the element sits *inside* (date-input modal → dialog; fab-menu → +sibling
  FAB), your options are: (a) **render-harness WRAP** (render-all `WRAP` map — gate-only, low risk;
  date-input-modal already uses this), (b) **rebind** the node, or (c) extend the emit to allow a
  non-cemTag root — which touches BOTH the web-components AND Elm emitters + `validateExamples` +
  the byte-stability/snapshot tests (real blast radius). Prefer (a)/(b).
- **Per-set examples** are supported via `manual-correspondence` `figmaSets[].example` — that's how
  to give a multi-set binding (card, date-input) different content per set.

## Rules / working style
- The user reviews via the gate (tailscale link); their overrides notes are the spec; push back
  with reasoning when something seems off (they value it — "we own the format," so a "blocker" is
  usually just a bounded change with a cost to name).
- Commit per binding; no push/PR unless asked. Commit trailer (see `git log`):
  `Generated with [Claude Code](https://claude.ai/code)` / `via [Happy](https://happy.engineering)` /
  `Co-Authored-By: Claude <noreply@anthropic.com>` / `Co-Authored-By: Happy <yesreply@happy.engineering>`.

## Start here
1. `git log --oneline -15` (see the session's fix trail); `pnpm test` (expect 711/711).
2. Confirm the bridge (`lsof -i:3055`) + Figma plugin channel; update `CHANNEL` in
   `plans/gate-tooling/render-all.mjs` if it changed.
3. Make sure the gate's scratch overrides = the current decisions (restore from
   `plans/gate-tooling/overrides-snapshot.json` if needed), then start the gate.
4. Take **card** first — convert to a manual binding with per-set horizontal/vertical examples.
   Then fab-menu (FAB-trigger composition), date-input docked (wrap), and search-view (only if asked).
