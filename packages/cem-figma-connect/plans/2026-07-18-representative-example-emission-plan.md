# Representative-Example Emission — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let composite/container components bank via a correct, representative code example (web-components) instead of the pixel gate, by driving the emitters from a per-component `examples.json` of structured slot children.

**Architecture:** A new pure `src/emit/example-content.mjs` turns `ChildSpec[]` into an HTML snippet + validates it against the CEM. A new `profiles/m3-kit/examples.json` holds the per-component children. Both emitters, when a component has an examples entry, use it for the inner content and skip prop-derived slot content — which also dissolves the multi-`content` crash. Banking is by structural verification (`gate:"example-verified"`).

**Tech Stack:** Node ESM, zero deps; `node --test`; `pnpm test` (scoped glob). Determinism/byte-stability preserved (the 14 existing banks aren't in examples.json → their emit path is unchanged).

**Spec:** `plans/2026-07-18-representative-example-emission-design.md`.

**v1 scope note:** html-label (web-components) gets FULL representative children. The Elm emitter, for examples.json components, emits the component with its mapped attrs and EMPTY children (minimal, correct, no crash) — representative Elm children are a documented follow-on (needs the tag→Elm-module mapping via elm-facts). Both emitters must not crash and must keep the 14 existing banks byte-identical.

---

## File Structure

- **`src/emit/example-content.mjs`** (create) — pure. `renderChildrenHtml(childSpecs) -> string`; `validateExamples(examples, cem) -> void (throws)`. One job: ChildSpec[] → HTML + CEM validation.
- **`profiles/m3-kit/examples.json`** (create) — `{ cemTag: { children: ChildSpec[] } }` for the target composites.
- **`src/correspond/merge.mjs` `loadProfile`** (modify) — load `examples.json` (missing → `{}`) onto the profile object.
- **`src/emit/run.mjs`** (modify) — thread `examples` into the `config` passed to each emitter (where iconTable/iconPlaceholder are already threaded).
- **`src/emit/html-label.mjs`** (modify) — when `config.examples[cemTag]` exists: inner content = `renderChildrenHtml(...)`, skip prop-derived slot content. Plus a no-crash guard for >1 TEXT→content.
- **`profiles/m3-kit/emitters/elm.mjs`** (modify) — when `config.examples[cemTag]` exists: empty children, skip prop-content (minimal correct example).
- **Tests:** `src/emit/example-content.test.mjs` (create); additions to `test/html-label.test.mjs`, the elm emitter test, and the loader test.

`ChildSpec = { tag, slot?, text?, attrs?: {name:value}, children?: ChildSpec[] }`.

---

## Task 1: `example-content.mjs` — render + validate

**Files:** create `src/emit/example-content.mjs`, `src/emit/example-content.test.mjs`.

- [ ] **Step 1: Write the failing tests** (`src/emit/example-content.test.mjs`)

```js
import { test } from "node:test";
import assert from "node:assert/strict";
import { renderChildrenHtml, validateExamples } from "./example-content.mjs";

test("renderChildrenHtml: text child", () => {
  assert.equal(renderChildrenHtml([{ tag: "m3e-button-segment", text: "Label" }]),
    `<m3e-button-segment>Label</m3e-button-segment>`);
});

test("renderChildrenHtml: slot + attrs + nested children", () => {
  const out = renderChildrenHtml([
    { tag: "m3e-icon-button", slot: "trailing-button", children: [
      { tag: "m3e-icon", attrs: { name: "arrow_drop_down" } } ] },
  ]);
  assert.equal(out, `<m3e-icon-button slot="trailing-button"><m3e-icon name="arrow_drop_down"></m3e-icon></m3e-icon-button>`);
});

test("renderChildrenHtml: multiple children joined; empty/undefined -> empty string", () => {
  assert.equal(
    renderChildrenHtml([{ tag: "span", text: "A" }, { tag: "span", text: "B" }]),
    `<span>A</span><span>B</span>`);
  assert.equal(renderChildrenHtml([]), "");
  assert.equal(renderChildrenHtml(undefined), "");
});

test("validateExamples: every child tag is a real CEM tag (or plain HTML) and every slot is a real slot of its parent", () => {
  const cem = {
    tags: new Set(["m3e-segmented-button", "m3e-button-segment", "m3e-split-button", "m3e-button"]),
    slotsByTag: { "m3e-segmented-button": new Set([""]), "m3e-split-button": new Set(["leading-button", "trailing-button"]) },
  };
  // valid
  validateExamples({ "m3e-segmented-button": { children: [{ tag: "m3e-button-segment", text: "L" }] } }, cem);
  validateExamples({ "m3e-split-button": { children: [{ tag: "m3e-button", slot: "leading-button", text: "L" }] } }, cem);
  // bad child tag
  assert.throws(() => validateExamples({ "m3e-segmented-button": { children: [{ tag: "m3e-nope" }] } }, cem), /unknown tag 'm3e-nope'/);
  // slot not on parent
  assert.throws(() => validateExamples({ "m3e-split-button": { children: [{ tag: "m3e-button", slot: "middle", text: "x" }] } }, cem), /slot 'middle' is not a slot of 'm3e-split-button'/);
});
```

- [ ] **Step 2: Run to verify FAIL** — `node --test src/emit/example-content.test.mjs` → `Cannot find module`.

- [ ] **Step 3: Implement** (`src/emit/example-content.mjs`)

```js
// Turns a component's representative example children (from examples.json) into
// an HTML snippet for the html-label emitter, and validates the config against
// the CEM (every child tag real; every slot a real slot of its parent). Pure,
// zero deps. See plans/2026-07-18-representative-example-emission-design.md.

// Plain HTML tags allowed as example scaffolding (text containers etc.).
const HTML_TAGS = new Set(["span", "div", "p", "img", "input", "button"]);

function esc(s) {
  return String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

// renderChildrenHtml(childSpecs) -> HTML string (no surrounding whitespace).
export function renderChildrenHtml(childSpecs) {
  if (!Array.isArray(childSpecs)) return "";
  return childSpecs.map(renderOne).join("");
}

function renderOne(spec) {
  const slotAttr = spec.slot ? ` slot="${esc(spec.slot)}"` : "";
  const attrs = spec.attrs
    ? Object.entries(spec.attrs).map(([k, v]) => ` ${k}="${esc(v)}"`).join("")
    : "";
  const inner = (spec.text != null ? esc(spec.text) : "") + renderChildrenHtml(spec.children);
  return `<${spec.tag}${slotAttr}${attrs}>${inner}</${spec.tag}>`;
}

// validateExamples(examples, cem) -> throws on the first problem.
//   cem: { tags: Set<string>, slotsByTag: { [tag]: Set<slotName> } }
export function validateExamples(examples, cem) {
  for (const [parentTag, entry] of Object.entries(examples)) {
    const parentSlots = cem.slotsByTag[parentTag] ?? new Set();
    walk(entry.children, parentTag, parentSlots, cem);
  }
}

function walk(children, parentTag, parentSlots, cem) {
  if (!Array.isArray(children)) return;
  for (const c of children) {
    if (!cem.tags.has(c.tag) && !HTML_TAGS.has(c.tag)) {
      throw new Error(`examples.json: unknown tag '${c.tag}' under '${parentTag}' (not a CEM custom element or allowed HTML tag)`);
    }
    if (c.slot && !parentSlots.has(c.slot)) {
      throw new Error(`examples.json: slot '${c.slot}' is not a slot of '${parentTag}' (child '${c.tag}')`);
    }
    // Nested children are validated against THEIR parent's slots.
    const childSlots = cem.slotsByTag[c.tag] ?? new Set();
    walk(c.children, c.tag, childSlots, cem);
  }
}
```

- [ ] **Step 4: Run to verify PASS** — `node --test src/emit/example-content.test.mjs` (4 pass). Then full suite: `rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (pass|fail)'` (0 fail; publish-check #554 may flake on a single run — rerun to confirm).

- [ ] **Step 5: Commit**

```bash
git add src/emit/example-content.mjs src/emit/example-content.test.mjs
git commit -m "feat(emit): example-content — render ChildSpec[] to HTML + validate vs CEM"
```

---

## Task 2: `examples.json` + loader threading

**Files:** create `profiles/m3-kit/examples.json`; modify `src/correspond/merge.mjs` (`loadProfile`); modify `src/emit/run.mjs`; test in the existing loader/emit test.

- [ ] **Step 1: Create `profiles/m3-kit/examples.json`** with the target composites (the reference bank uses `m3e-segmented-button`; the rest seed the follow-on loop):

```json
{
  "m3e-segmented-button": { "children": [
    { "tag": "m3e-button-segment", "text": "Label" },
    { "tag": "m3e-button-segment", "text": "Label" },
    { "tag": "m3e-button-segment", "text": "Label" }
  ]},
  "m3e-button-group": { "children": [
    { "tag": "m3e-button", "text": "Label" },
    { "tag": "m3e-button", "text": "Label" }
  ]},
  "m3e-split-button": { "children": [
    { "tag": "m3e-button", "slot": "leading-button", "text": "Label" },
    { "tag": "m3e-icon-button", "slot": "trailing-button", "children": [
      { "tag": "m3e-icon", "attrs": { "name": "arrow_drop_down" } } ] }
  ]}
}
```

- [ ] **Step 2: Write the failing loader test** — find how `loadProfile` is tested (grep `loadProfile` in `test/` and `src/`); add a test asserting `loadProfile(profileDir).examples["m3e-segmented-button"].children.length === 3`, and that a profile dir WITHOUT an examples.json yields `examples === {}` (or `{}`-equivalent). Run it → FAIL (`examples` undefined).

- [ ] **Step 3: Thread it in `loadProfile`** (`src/correspond/merge.mjs`). Find the `loadProfile` function; after it reads `profile.json`, add:

```js
  // Optional per-component representative example content (by-example banking).
  // Missing file -> {} (backward-compatible; profiles without it are unaffected).
  const examplesPath = path.join(profileDir, "examples.json");
  profile.examples = fs.existsSync(examplesPath) ? JSON.parse(fs.readFileSync(examplesPath, "utf8")) : {};
```
(Use the same `fs`/`path` already imported in merge.mjs; mirror how `profile.json` itself is read there.)

- [ ] **Step 4: Thread `examples` into the emit config** (`src/emit/run.mjs`). Find where the `config` object passed to `emitEntry`/each emitter is built (it already carries `fileKey`, `iconTable`, `iconPlaceholder`). Add `examples: profile.examples ?? {}` to that config object.

- [ ] **Step 5: Run to verify PASS** — the loader test passes; `rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (pass|fail)'` 0 fail. **Byte-stable check:** `node src/cli.mjs emit --profile m3-kit && git status --short generated/` — MUST be empty (no component is confirmed-in-examples yet, so emit is unchanged).

- [ ] **Step 6: Commit**

```bash
git add profiles/m3-kit/examples.json src/correspond/merge.mjs src/emit/run.mjs test/<the-loader-test-file>.mjs
git commit -m "feat(emit): load examples.json + thread into emit config (no-op until a component uses it)"
```

---

## Task 3: html-label emitter — inject representative children + crash guard

**Files:** modify `src/emit/html-label.mjs`; test in `test/html-label.test.mjs`.

The example is assembled at ~line 675: `const example = \`<${cemTag}${attrs}>${contentExpr}${slotExprs}${defaultSlotIconExprs}${literalIconUnconditionalExprs}${namedInputSlotExprs}</${cemTag}>\`;`. When `config.examples[cemTag]` exists, the inner content becomes the rendered example children and NONE of the prop-derived exprs are used.

- [ ] **Step 1: Write the failing tests** (append to `test/html-label.test.mjs`)

```js
import { renderChildrenHtml } from "../src/emit/example-content.mjs";

test("emitEntry: a component with an examples entry emits its representative children + skips prop-slot-content", () => {
  const entry = {
    cemTag: "m3e-segmented-button", status: "confirmed",
    figmaSets: [{ nodeId: "53923:36615", setName: "Segmented button", fixedAttrs: {} }],
    axes: [], props: [{ figmaProp: "Label text", kind: "text", binding: "content" }],
  };
  const cfg = { ...config, examples: { "m3e-segmented-button": { children: [
    { tag: "m3e-button-segment", text: "Label" }, { tag: "m3e-button-segment", text: "Label" }, { tag: "m3e-button-segment", text: "Label" } ] } } };
  const files = emitEntry(entry, cfg);
  const ex = files[0].contents.match(/example:\s*figma\.code`([\s\S]*?)`,\n\s*imports/)[1];
  // inner is exactly the 3 segments — the "Label text"->content prop is NOT emitted as a default-slot label var
  assert.match(ex, /<m3e-segmented-button><m3e-button-segment>Label<\/m3e-button-segment><m3e-button-segment>Label<\/m3e-button-segment><m3e-button-segment>Label<\/m3e-button-segment><\/m3e-segmented-button>/);
  assert.ok(!ex.includes("${"), "no prop-derived code-block variables in an examples-driven example");
});

test("emitEntry: a component WITHOUT an examples entry is unchanged (m3e-button still 5 files, golden-shaped)", () => {
  const files = emitEntry(buttonEntry, config); // config has no examples for m3e-button
  assert.equal(files.length, 5);
});

test("emitEntry: >1 TEXT->content prop no longer throws — first emitted, rest noted", () => {
  const entry = {
    cemTag: "m3e-fake-multitext", status: "confirmed",
    figmaSets: [{ nodeId: "1:1", setName: "X", fixedAttrs: {} }], axes: [],
    props: [{ figmaProp: "Header", kind: "text", binding: "content" }, { figmaProp: "Subhead", kind: "text", binding: "content" }],
  };
  const files = emitEntry(entry, config); // no examples entry -> guard path
  assert.ok(files.length >= 1);
  assert.match(files[0].contents, /note: additional text prop\(s\) .*Subhead.* not emitted/);
});
```

- [ ] **Step 2: Run to verify FAIL** — `node --test test/html-label.test.mjs` (first test: examples not honored; third: still throws).

- [ ] **Step 3: Implement** in `src/emit/html-label.mjs`. Add the import at top: `import { renderChildrenHtml } from "./example-content.mjs";`. In `emitEntry`, locate the block that computes `contentBlock`/`contentExpr` and the prop-content assembly. Wrap with an examples short-circuit — put this BEFORE the prop-content computation and use it at the example-assembly line:

```js
  const exampleChildren = config.examples && config.examples[entry.cemTag];
  // ... (existing attrs computation stays) ...
```
Then at the example assembly (~line 675), branch:
```js
  const innerContent = exampleChildren
    ? renderChildrenHtml(exampleChildren.children)
    : `${contentExpr}${slotExprs}${defaultSlotIconExprs}${literalIconUnconditionalExprs}${namedInputSlotExprs}`;
  const example = `<${entry.cemTag}${attrs ? " " + attrs : ""}>${innerContent}</${entry.cemTag}>`;
```
And guard the prop loop so it does NOT run (or its throwing branches are skipped) when `exampleChildren` is set — the simplest correct form: compute `contentExpr`/`slotExprs` only when `!exampleChildren`. For the multi-`content` guard: find the throw for an unhandled/duplicate `content` prop; when NOT in examples mode, instead of throwing on a SECOND text→content prop, emit the first and append a `// note: additional text prop(s) <names> not emitted — add an examples.json entry` line to the file header. (Keep the existing single-content behavior for the 14 banks byte-identical — the note path only triggers with ≥2 content props, which none of them have.)

- [ ] **Step 4: Run to verify PASS** — `node --test test/html-label.test.mjs`; then `rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (pass|fail)'` 0 fail. **Byte-stable:** `node src/cli.mjs emit --profile m3-kit && git status --short generated/` empty (14 banks unchanged).

- [ ] **Step 5: Commit**

```bash
git add src/emit/html-label.mjs test/html-label.test.mjs
git commit -m "feat(emit): html-label injects examples.json children + no-crash multi-content guard"
```

---

## Task 4: Elm emitter — minimal correct example for examples.json components

**Files:** modify `profiles/m3-kit/emitters/elm.mjs`; test in its existing test file.

For an examples.json component, the Elm emitter emits the component with mapped attrs and EMPTY children (no crash, correct-but-minimal). Representative Elm children are a follow-on (needs tag→Elm-module mapping).

- [ ] **Step 1: Write the failing test** — find the elm emitter test (grep the emitter's exported fn in `test/` or a co-located test). Add: an examples.json component (e.g. `m3e-segmented-button`) with a `config.examples` entry emits an Elm `.figma.ts` with an EMPTY child list (`[ ]`) and does NOT throw on its text→content prop. Assert the example body contains the module call with `[ ]` (or the emitter's empty-content form) and no crash.

- [ ] **Step 2: Run to verify FAIL.**

- [ ] **Step 3: Implement** — in `profiles/m3-kit/emitters/elm.mjs`, where `contentExpr` (the example children) is computed for `renderExample`, short-circuit: if `config.examples && config.examples[comp.cemTag]` (match how the emitter references the tag), set `contentExpr` to the emitter's EMPTY-content form (mirror what it emits for a component with no text content today — likely `""` inside `[ ${contentExpr} ]`, i.e. `[ ]`) and SKIP the prop-content/throw path. Keep every non-examples component byte-identical.

- [ ] **Step 4: Run to verify PASS** — the elm test + `pnpm test` 0 fail; `git status --short generated/` empty (byte-stable).

- [ ] **Step 5: Commit**

```bash
git add profiles/m3-kit/emitters/elm.mjs test/<elm-test>.mjs
git commit -m "feat(emit): elm emits minimal correct example for examples.json components (repr-children = follow-on)"
```

---

## Task 5: Reference bank — `m3e-segmented-button` (#15), by-example

**Files:** `profiles/m3-kit/overrides.json`; regen `correspondence.json`/`generated/`; the 4 tracer tests. Plus a lead structural-eyeball (the controller does the render + eyeball; the implementer wires the bank once told it passed).

> **NOTE for the controller:** BEFORE this task, render the emitted segmented-button example markup and eyeball it (structural correctness — 3 segments, matches Figma's kind) + run `validateExamples` against the CEM. Only proceed to bank if both pass. This task assumes that verification passed.

- [ ] **Step 1: `validateExamples` runs in the suite** — add a test (in `example-content.test.mjs` or a profile test) that loads the REAL `profiles/m3-kit/examples.json` + builds the CEM `{tags, slotsByTag}` view (from `loadCem`) and calls `validateExamples` — asserting the committed examples.json is valid against the CEM. Run → PASS. (This is the machine half of verification, permanent.)

- [ ] **Step 2: Bank segmented-button** — append to `profiles/m3-kit/overrides.json`:
```json
{ "cemTag": "m3e-segmented-button", "status": "confirmed", "gate": "example-verified", "note": "Banked by representative example 2026-07-18 (contains-tier match; pixel gate N/A — rich Figma showcase; example = 3 m3e-button-segment children, structurally verified)." }
```

- [ ] **Step 3: confirm → gap → emit** — `node src/cli.mjs confirm --profile m3-kit && node src/cli.mjs gap --profile m3-kit && node src/cli.mjs emit --profile m3-kit`. Verify the segmented-button `.figma.ts` contains the 3-segment example. Verify byte-stability: `node src/cli.mjs match --profile m3-kit && git status --short profiles/m3-kit/correspondence.json` empty.

- [ ] **Step 4: Update the 4 tracer tests** (15 confirmed now; mirror fab/avatar):
  - `test/correspond.test.mjs`: CONFIRMED_TAGS + `"m3e-segmented-button"` (alphabetical), `confirmed.length` 14→15, a per-entry assertion (status confirmed + provenance human), and that its override `gate` is `"example-verified"` if the tracer checks gate.
  - `test/smoke.test.mjs`: emit file-list — add segmented-button's filename (from `ls generated/m3-kit/web-components/ | grep segmented`), bump the `wrote NN file(s)` count, add to `written` + manifest keys + a manifest length assertion.
  - `test/html-label.test.mjs`: add `"m3e-segmented-button"` to the confirmedTags Set.
  - `test/emitter-api.test.mjs`: run `emit --page Buttons` and only change the count if segmented-button is on the Buttons page.

- [ ] **Step 5: Full suite + commit**
```bash
rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (pass|fail)'   # 0 fail
git add profiles/m3-kit/overrides.json profiles/m3-kit/correspondence.json profiles/m3-kit/gap-report.md \
  test/correspond.test.mjs test/smoke.test.mjs test/html-label.test.mjs generated/m3-kit/web-components generated/m3-kit/elm \
  src/emit/example-content.test.mjs
git commit -m "feat(bank): m3e-segmented-button (#15) by representative example (gate:example-verified)"
```

---

## Follow-on (documented, not this plan): bank the rest

With the machinery proven, bank each remaining composite the same way — one at a time: add its `ChildSpec[]` to `examples.json`, render + structural-eyeball, `overrides.json` (`gate:"example-verified"`), confirm/emit, tracer tests. Candidates: button-group, split-button, dialog, card, app-bar, fab-menu, menu-item, tooltip, slider (each needs its Figma default eyeballed for the right children). Representative **Elm** children (tag→Elm-module mapping) is a separate enhancement.

---

## Self-Review

**Spec coverage:** Unit 1 (examples.json + emitter injection) → Tasks 1–3. Unit 2 (multi-content crash guard) → Task 3 Step 3. Unit 3 (verification + banking) → Task 5 (Step 1 machine validate + controller eyeball + `gate:"example-verified"`). Elm → Task 4 (v1 minimal). Config/loader → Task 2. Testing/byte-stability → every task's Step 4/5.

**Placeholder scan:** the two `<the-loader-test-file>`/`<elm-test>` filenames are "find the real path" instructions (the plan can't know them without a grep), not code placeholders — the implementer greps for the existing test. The Task 4 Elm `contentExpr` empty-form is described precisely (mirror the no-text-content form) rather than guessed, because the exact Elm string must match the emitter's own convention — flagged as the judgment step. No `TBD`/`add error handling`/`similar to Task N`.

**Type consistency:** `ChildSpec` fields (`tag`/`slot`/`text`/`attrs`/`children`) are consistent across example-content.mjs, examples.json, and the tests. `renderChildrenHtml(childSpecs)` and `validateExamples(examples, cem)` signatures match their call sites (html-label Task 3, validate Task 5). The CEM view `{tags:Set, slotsByTag:{}}` is defined in Task 1's test and reused in Task 5 Step 1.

**Known risk (flag to controller):** Task 3's exact edit depends on how `emitEntry` currently structures the prop-content computation (it must be made conditional on `!exampleChildren`). The implementer must READ the current emitEntry body and make the prop-content path conditional cleanly — if that restructure is unclear, STOP and report rather than force it (the emitter is intricate; the 14 banks must stay byte-identical).
