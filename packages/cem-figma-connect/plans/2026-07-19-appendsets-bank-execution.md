# appendSets 2nd-set Banking — Execution Plan

> **For agentic workers:** execute task-by-task. Steps use `- [ ]` checkboxes. This is EXECUTION of the already-designed `appendSets` mechanism (see `plans/2026-07-19-append-sets-mechanism-design.md`); the design work is done. The one design-bearing piece is Task 1 (the confirmed-entry parking fix).

**Goal:** Bank 13 "2nd-set" Code Connect bindings — `m3e-button` +4 (toggle variants), `m3e-icon-button` +4 (toggle variants), `m3e-fab` +1 (Extended FAB), `m3e-tab` +4 (content variants). Bindings 43→~56; the **component count stays 43** (same confirmed set, more Figma sets each).

**Architecture:** (1) Complete the mechanism so a manual set added to an *already-confirmed* entry lands in live `figmaSets` instead of parking in `proposedUpdate` — by mirroring manual-correspondence onto the `existing` merge input. (2) Apply the render-verified config. (3) `match → emit`, verify byte-stability + AF-07 render + `check` 0-drift. (4) Update the concentrated tracer tests. (5) Full suite + commit.

**Tech Stack:** Node `.mjs`, `node --test`, `pnpm test`, `scripts/render-batch.mjs` (Playwright).

---

## Decisive context (verified this session — don't re-derive)

- **All 4 targets are `status:confirmed` + `provenance:human`** → `isProtected` true → `mergeCorrespondence` parks any figmaSets change in `proposedUpdate` (merge.mjs:336-347). Deltas: **button 5→9, icon-button 4→8, fab 1→2, tab 1→5.**
- **The settled state is already byte-stable under current code** (`proposedWithManual` == `existing` once the sets are live → merge is a no-op). The fix in Task 1 only handles the *transition* (old→new) cleanly, so `match` does it instead of a hand-edit.
- **`proposedUpdate` is consumed by nobody** (written only in merge.mjs; allowed in schema.json; mentioned in review.mjs) → affects only correspondence.json bytes, never emit/`check` drift.
- **fab already carries a benign `proposedUpdate`** — same figmaSets, only an axis divergence (human added `Default→small`). Appended sets land on the human's live set; fab keeps a stable matcher-axes proposedUpdate. No test asserts it.
- **#531 (`html-label.test.mjs:355`) is a red herring.** It's a synthetic boolean-throw test; the real breakage vector is its trailing `assert.equal(emitEntry(buttonEntry, config).length, 5)` (line 374). `buttonEntry` is a SHARED synthetic fixture. **DO NOT mutate the html-label synthetic fixtures** — banking touches the real correspondence.json + tracer tests only. Leave them and #531 stays green. (The toggle sets' boolean fixedAttrs never reach the line-673 throw — that path is for `props`, not `fixedAttrs`.)
- **`toggle`/`selected`/`variant` are real `m3e-button` CEM attrs** → emit renders them (html-label.mjs:806 filters only figma-axis-pin keys like `Style`). `slugSuffix` REPLACES the slug → `m3e-button-toggle-filled` (no collision with `m3e-button-filled`).
- **No nodeId collisions** — config appendSets nodeIds are disjoint from every primary set (verified).
- **graphify hook misfires** for this sub-repo (no `graphify-out/graph.json`) — ignore the nag; use targeted Read/grep.
- **Subagents truncate on the tracer step** (handoff AF) → controller does Tasks 1/2/4/5 by hand; Task 3 render-verify MAY be delegated but controller eyeballs the PNGs.

---

## Task 1: Complete the appendSets confirmed-entry transition (merge.mjs)

**Files:**
- Modify: `src/correspond/merge.mjs` (add helper + `applyManualToExisting`; 1-line change in `runMatch`)
- Test: `test/append-sets.test.mjs`

**Why:** `applyManualCorrespondence` runs on `proposed` only (pre-merge). A manual change to a confirmed entry then looks like auto-drift to `mergeCorrespondence` and parks. Applying manual symmetrically to `existing` too makes the change land live and keeps re-match byte-stable. `applyManualCorrespondence` stays UNCHANGED → its 19 tests + the manual-correspondence tests stay green.

- [ ] **Step 1 — Extract a shared figmaSet builder** (byte-identical key order for both call sites). In `applyManualCorrespondence`, replace the inline object (lines ~526-532) with a call to this new module-level helper:

```js
// Build a figmaSet object from an appendSet config entry. Shared by
// applyManualCorrespondence (proposed side) and applyManualToExisting (stored
// side) so both produce byte-identical objects (key order matters for the
// JSON.stringify byte-stability comparison in mergeCorrespondence).
function toAppendedFigmaSet(appendSet) {
  return {
    nodeId: appendSet.nodeId,
    setName: appendSet.setName,
    fixedAttrs: appendSet.fixedAttrs ?? {},
    ...(appendSet.slugSuffix !== undefined ? { slugSuffix: appendSet.slugSuffix } : {}),
    ...(appendSet.example !== undefined ? { example: appendSet.example } : {}),
  };
}
```

- [ ] **Step 2 — Add `applyManualToExisting`** (export it, next to `applyManualCorrespondence`):

```js
// applyManualToExisting(existing, manual) -> entries[]
//
// Mirror manual-correspondence onto the ALREADY-STORED entries so a manual
// change to a confirmed entry (a 2nd set via appendSets, or an extended manual
// figmaSets list) is applied to BOTH mergeCorrespondence inputs. Otherwise the
// merge sees it as auto-drift against the protected entry and parks it in
// proposedUpdate instead of landing it live. Manual config is an explicit human
// decision; symmetric application lands it live and keeps re-match byte-stable.
//
// Idempotent + confirmed-safe: never throws (unlike applyManualCorrespondence,
// which authoritatively guards the proposed side). On a re-run the sets are
// already present, so appendSets is a no-op.
export function applyManualToExisting(existing, manual) {
  if (!manual || Object.keys(manual).length === 0) return existing;
  return existing.map((entry) => {
    const m = manual[entry.cemTag];
    if (!m) return entry;
    if (m.appendSets?.length && Array.isArray(entry.figmaSets) && entry.figmaSets.length > 0) {
      const present = new Set(entry.figmaSets.map((s) => s.nodeId));
      const toAdd = m.appendSets.filter((s) => !present.has(s.nodeId)).map(toAppendedFigmaSet);
      return toAdd.length ? { ...entry, figmaSets: [...entry.figmaSets, ...toAdd] } : entry;
    }
    if (m.figmaSets) {
      // A manual figmaSets list is the full desired set for that tag; adopt it.
      return { ...entry, figmaSets: m.figmaSets };
    }
    return entry;
  });
}
```

- [ ] **Step 3 — Wire it into `runMatch`** (merge.mjs ~682-686). Add the mirrored input:

```js
  const existing = readCorrespondence(outPath);
  // Mirror manual-correspondence onto the stored entries too, so a manual set
  // added to an already-confirmed entry is applied to BOTH merge inputs and
  // lands live instead of parking in proposedUpdate.
  const existingWithManual = applyManualToExisting(existing, profile.manualCorrespondence);
  const merged = mergeCorrespondence(existingWithManual, proposedWithManual);
```

- [ ] **Step 4 — Failing tests first** (`test/append-sets.test.mjs`, import `applyManualToExisting`):

```js
test("existing-mirror: appendSets onto a CONFIRMED bound entry appends missing sets, no throw", () => {
  const existing = [makeBoundEntry("m3e-button")]; // status:confirmed, 2 primary sets
  const manual = { "m3e-button": { appendSets: [
    { nodeId: "900:1", setName: "Toggle", fixedAttrs: { toggle: "true" }, slugSuffix: "toggle" },
  ] } };
  const out = applyManualToExisting(existing, manual);
  const e = out.find((x) => x.cemTag === "m3e-button");
  assert.equal(e.figmaSets.length, 3, "appended onto confirmed without throwing");
  assert.equal(e.figmaSets[2].slugSuffix, "toggle");
  assert.equal(e.status, "confirmed", "status untouched");
});

test("existing-mirror: re-applying is idempotent (no duplicate sets, no throw)", () => {
  const existing = [makeBoundEntry("m3e-button")];
  const manual = { "m3e-button": { appendSets: [{ nodeId: "900:1", setName: "Toggle", fixedAttrs: {} }] } };
  const once = applyManualToExisting(existing, manual);
  const twice = applyManualToExisting(once, manual);
  assert.equal(JSON.stringify(once), JSON.stringify(twice), "second application is a no-op");
});

test("existing-mirror: figmaSets list is adopted on a confirmed manual entry (tab-style extend)", () => {
  const existing = [{ ...makeBoundEntry("m3e-tab"), matcherKind: "manual",
    figmaSets: [{ nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} }] }];
  const manual = { "m3e-tab": { figmaSets: [
    { nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} },
    { nodeId: "54563:40209", setName: "Primary tabs/Icon only", fixedAttrs: {}, slugSuffix: "primary-icon-only" },
  ] } };
  const out = applyManualToExisting(existing, manual);
  assert.equal(out[0].figmaSets.length, 2, "adopted the full 2-set manual list");
});

test("existing-mirror: a tag not in manual is byte-identical", () => {
  const existing = [makeBoundEntry("m3e-badge")];
  assert.equal(JSON.stringify(applyManualToExisting(existing, { "m3e-tab": { figmaSets: [] } })),
    JSON.stringify(existing));
});
```

- [ ] **Step 5** — `node --test test/append-sets.test.mjs` → all green (new + existing 19). Then `node --test test/correspond.test.mjs` → still green (the merge/manual tests are unaffected because `applyManualCorrespondence` is unchanged and the on-disk config hasn't changed yet).
- [ ] **Step 6** — Commit: `fix(appendSets): mirror manual-correspondence onto stored entries so 2nd-sets on confirmed entries land live`.

---

## Task 2: Apply the render-verified config (`profiles/m3-kit/manual-correspondence.json`)

**Files:** Modify `profiles/m3-kit/manual-correspondence.json`.

- [ ] Add three new entries + extend `m3e-tab`. **Keep `m3e-tab`'s existing `note` UNCHANGED** (its `rationale` feeds byte-stability). New content:

```jsonc
"m3e-fab": { "appendSets": [
  { "nodeId": "57998:43095", "setName": "Extended FAB", "fixedAttrs": { "extended": "true" }, "slugSuffix": "extended",
    "example": { "children": [ { "tag": "m3e-icon", "attrs": { "name": "edit" } }, { "tag": "span", "slot": "label", "text": "New document" } ] } }
], "note": "Manual 2026-07-19: Extended FAB 2nd-set; icon in default slot + slot=label text." },

"m3e-button": { "appendSets": [
  { "nodeId": "57994:2328",  "setName": "<VERIFY setName>", "fixedAttrs": { "toggle": "true", "selected": "true", "variant": "filled" },   "slugSuffix": "toggle-filled",   "example": { "children": [ { "tag": "m3e-icon", "slot": "icon", "attrs": { "name": "favorite" } }, { "tag": "span", "text": "Favorite" } ] } },
  { "nodeId": "58653:13968", "setName": "<VERIFY setName>", "fixedAttrs": { "toggle": "true", "selected": "true", "variant": "elevated" }, "slugSuffix": "toggle-elevated", "example": { "children": [ { "tag": "m3e-icon", "slot": "icon", "attrs": { "name": "favorite" } }, { "tag": "span", "text": "Favorite" } ] } },
  { "nodeId": "58653:16237", "setName": "<VERIFY setName>", "fixedAttrs": { "toggle": "true", "selected": "true", "variant": "outlined" }, "slugSuffix": "toggle-outlined", "example": { "children": [ { "tag": "m3e-icon", "slot": "icon", "attrs": { "name": "favorite" } }, { "tag": "span", "text": "Favorite" } ] } },
  { "nodeId": "58653:17539", "setName": "<VERIFY setName>", "fixedAttrs": { "toggle": "true", "selected": "true", "variant": "tonal" },    "slugSuffix": "toggle-tonal",    "example": { "children": [ { "tag": "m3e-icon", "slot": "icon", "attrs": { "name": "favorite" } }, { "tag": "span", "text": "Favorite" } ] } }
], "note": "Manual 2026-07-19: 4 toggle-button 2nd-sets (filled/elevated/outlined/tonal)." },

"m3e-icon-button": { "appendSets": [
  { "nodeId": "57994:10368", "setName": "<VERIFY setName>", "fixedAttrs": { "toggle": "true", "selected": "true", "variant": "filled" },   "slugSuffix": "toggle-filled",   "example": { "children": [ { "tag": "m3e-icon", "attrs": { "name": "favorite_border" } }, { "tag": "m3e-icon", "slot": "selected", "attrs": { "name": "favorite" } } ] } },
  { "nodeId": "58665:42416", "setName": "<VERIFY setName>", "fixedAttrs": { "toggle": "true", "selected": "true", "variant": "standard" }, "slugSuffix": "toggle-standard", "example": { "children": [ { "tag": "m3e-icon", "attrs": { "name": "favorite_border" } }, { "tag": "m3e-icon", "slot": "selected", "attrs": { "name": "favorite" } } ] } },
  { "nodeId": "58668:45603", "setName": "<VERIFY setName>", "fixedAttrs": { "toggle": "true", "selected": "true", "variant": "outlined" }, "slugSuffix": "toggle-outlined", "example": { "children": [ { "tag": "m3e-icon", "attrs": { "name": "favorite_border" } }, { "tag": "m3e-icon", "slot": "selected", "attrs": { "name": "favorite" } } ] } },
  { "nodeId": "58668:48104", "setName": "<VERIFY setName>", "fixedAttrs": { "toggle": "true", "selected": "true", "variant": "tonal" },    "slugSuffix": "toggle-tonal",    "example": { "children": [ { "tag": "m3e-icon", "attrs": { "name": "favorite_border" } }, { "tag": "m3e-icon", "slot": "selected", "attrs": { "name": "favorite" } } ] } }
], "note": "Manual 2026-07-19: 4 icon-button togglable 2nd-sets." }
```

For **`m3e-tab`**, extend its `figmaSets` array from 1 to 5 (keep primary `54563:40142` first, no slugSuffix): add `54563:40209` (`slugSuffix:"primary-icon-only"`, example = icon slot only), `54563:40268` (`primary-label-only`, example = span text only), `54563:40366` (`secondary-icon-label`), `54563:40319` (`secondary-label-only`). Keep the existing `note`.

- [ ] **`<VERIFY setName>`** — each `setName` MUST match the figma export node name exactly or `validateManualCorrespondence` throws. Resolve via:
  `node -e 'const fs=require("fs");const j=JSON.parse(fs.readFileSync("test/fixtures/figma-export.m3-kit.json","utf8"));for(const id of ["57994:2328","58653:13968","58653:16237","58653:17539","57994:10368","58665:42416","58668:45603","58668:48104","57998:43095","54563:40209","54563:40268","54563:40366","54563:40319"]){console.log(id, JSON.stringify(j.components[id]?.name))}'`
  (Also confirms each is a real `COMPONENT_SET`.)

---

## Task 3: Regenerate + verify (match → emit → AF-07 → check)

**Files:** none edited — generates `profiles/m3-kit/correspondence.json` + `.figma.ts` outputs.

- [ ] Discover exact subcommands: `node src/cli.mjs --help`. Expected flow (targets already confirmed → **no `confirm` step needed**): `match` → `emit`.
- [ ] `node src/cli.mjs match --profile m3-kit` — then confirm live counts:
  `node -e 'const fs=require("fs");const c=JSON.parse(fs.readFileSync("profiles/m3-kit/correspondence.json","utf8"));for(const t of ["m3e-button","m3e-icon-button","m3e-fab","m3e-tab"]){const e=c.find(x=>x.cemTag===t);console.log(t,"sets="+e.figmaSets.length,"pu="+!!e.proposedUpdate)}'`
  Expect **button 9, icon-button 8, fab 2, tab 5**; `pu=false` for button/icon-button/tab (fab may keep its benign axis proposedUpdate).
- [ ] **Byte-stability:** run `match` a second time; the file must not change (`git diff --stat profiles/m3-kit/correspondence.json` clean on the 2nd run). This is what A8 enforces.
- [ ] `node src/cli.mjs emit --profile m3-kit` (verify command). Confirm the new files exist: `m3e-button-toggle-{filled,elevated,outlined,tonal}`, `m3e-icon-button-toggle-{...}`, `m3e-fab-extended`, `m3e-tab-{primary-icon-only,primary-label-only,secondary-icon-label,secondary-label-only}` (+ their `-elm` variants where the elm emitter runs).
- [ ] **AF-07 (non-negotiable):** render the EMITTED example markup for each new set via `scripts/render-batch.mjs` and **Read each PNG**. Faithful shapes: toggle-button = filled/selected heart + "Favorite"; icon-button togglable = filled selected; fab = Extended pill w/ icon + "New document"; tab icon-only / label-only / secondary variants. A ~10187-byte PNG = blank baseline (fail). Render the emitted `<m3e-…>` markup, NOT the hand-written config.
- [ ] `node src/cli.mjs check --profile m3-kit` → **0 drift, 0 orphan.** If drift on the new sets: verify `src/publish/check.mjs` re-emits with the same ctx — but the per-set `example`/`slugSuffix` travel INSIDE the figmaSet objects (unlike examples.json), so `check` should already thread them. Investigate only if it drifts.

---

## Task 4: Update the tracer tests (concentrated — NOT html-label synthetics)

**Files:** `test/correspond.test.mjs`, `test/smoke.test.mjs`, `test/emitter-api.test.mjs`.

- [ ] `test/correspond.test.mjs`: `button.figmaSets.length` **5→9** (~line 514); `tab.figmaSets.length` **1→5** (~line 668, keep `figmaSets[0].nodeId === "54563:40142"`). `CONFIRMED_TAGS` + `confirmed.length === 43` **UNCHANGED** (no new components). Optionally add per-entry assertions for the appended sets. The two byte-stability re-runs (lines ~681, ~964) validate the Task-1 fix end-to-end.
- [ ] `test/smoke.test.mjs`: update wrote-count / written-file list / manifest per-tag lengths for the +13 files.
- [ ] `test/emitter-api.test.mjs`: update the Buttons-page (and icon-button) file count.
- [ ] **DO NOT edit `test/html-label.test.mjs` synthetic fixtures** (`buttonEntry`, etc.) — the #531 trap. Its `confirmedTags` Set (43) is unchanged. Verify `html-label` + `append-sets` tests pass untouched.
- [ ] Straggler sweep: `grep -nE "figmaSets\.length|\.length, [0-9]|m3e-(button|icon-button|fab|tab)-" test/*.mjs` — reconcile any remaining hardcoded count.

---

## Task 5: Full suite + commit

- [ ] Prelude `rm -rf render-cache/results`, then `pnpm test`. The **AF-03 flake** (`publish-check` "runCheck…") fails ~half the time in the full suite only → rerun isolated `node --test test/publish-check.test.mjs` to confirm green (not a regression).
- [ ] Review gate (self): `git diff` — merge.mjs fix (design-bearing → full read), config + tracers (mechanical → scan). Verdict before commit.
- [ ] Commit (direct to `main` per repo convention): `feat(bank): 13 appendSets 2nd-sets — button/icon-button toggle ×8, Extended FAB, tab content ×4`.

---

## Verification gates (Jack's #1 — non-negotiable)
1. **Byte-stable re-match** — `match` twice diff-clean + both A8 re-run tests green.
2. **AF-07** — eyeball every new PNG (Read it); never trust byte-size.
3. **`check` 0-drift / 0-orphan.**
4. **Full `pnpm test` green** (AF-03 flake confirmed isolated).

## Execution model
**Hybrid, controller-driven** (subagent tracer-truncation risk). Controller does Tasks 1/2/4/5 by hand. Task 3's render-batch sweep may be delegated to a subagent that renders + reports PNG paths, but the controller **Reads every PNG**. Every subagent prompt includes the friction-logging instruction + the graphify-hook note.
