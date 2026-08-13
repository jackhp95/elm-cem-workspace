# Elm Emit Gap Closure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the 3 Figma→Elm emit coverage gaps (`m3e-icon`, `m3e-circular-progress-indicator`, `m3e-linear-progress-indicator`) so `generated/m3-kit/elm/MANIFEST.json` reaches tag parity with `generated/m3-kit/web-components/MANIFEST.json` (43/43).

**Architecture:** Two mechanisms. (1) A parallel iconTable emit branch in `profiles/m3-kit/emitters/elm.mjs`, mirroring `src/emit/html-label.mjs`'s `emitIconTableEntry` (141 per-icon bindings, collision-suffixed), rendering `M3e.Icon.view [ M3e.Icon.name "…" ] []` with every name facts-resolved. (2) Group-component support in `profiles/m3-kit/emitters/elm-facts.build.mjs`: elm-m3e unifies the two progress tags into one `M3e.Progress` module exposing `linear`/`circular` group constructors; the builder learns to measure per-variant **alias facts** (`m3e-circular-progress-indicator` → module `M3e.Progress`, entry `circular`; linear likewise) so the existing `emitEntry` path in `elm.mjs` emits progress with **zero** emitter special-casing — honoring the CARDINAL RULE (no hardcoded Elm names; everything measured into `elm-facts.json`).

**Tech Stack:** Node ESM (`.mjs`), `node --test`, elm-m3e checkout at `~/Documents/code/elm-m3e` (facts measurement source), Figma Code Connect `.figma.ts` templates.

---

## Decision amendments (post-review with Jack, 2026-07-20)

Made AFTER the plan below was drafted. **Where these conflict with any task step or design section, THESE GOVERN.** They resolve Open Questions 1–3.

**A1 — elm-m3e refactor is in flight (affects Task 2, Risk 1, Open Q1).** A large elm-m3e refactor is being planned/executed concurrently, so `elm-facts.json` is a moving target and WILL be remeasured again after the refactor lands. Posture: facts are re-derivable; **never pin to the dangling `93d2edc`**. If Task 2's additions-only gate trips, accept-and-rebank *after inspecting the concrete diff* (surface it to Jack first — do not silently ship). A follow-up remeasure post-refactor is a known, accepted cost, not a regression.

**A2 — `[]` for no-text-content children, KIT-WIDE (affects D2, Task 4 Step 2, Task 5, Open Q2).** RESOLVED: emit `[]`, never `[ Kit.text "" ]`, for **every** component with no text content — not just icons. `renderExample` (elm.mjs) must render `[]` for the no-text-content case across ALL surfaces/entries; the existing ~40 banked Elm files get re-emitted with `[]` (a real content change, re-banked in Task 5). Consequences: D2's progress example becomes `M3e.Progress.circular [ M3e.Progress.value 70 ] []` (empty children); `check` will report intentional drift on the files that had `[ Kit.text "" ]` (re-bank, expected); add a test asserting `[]` for a no-text component and confirm the ONLY kit-wide content delta is `[ Kit.text "" ]` → `[]`.

**A3 — single provenance stamp, not per-file (affects D5, Task 4 Step 3 header, File structure, Open Q3).** RESOLVED: drop the `elm-m3e @ <commit>` line from every generated file's header; write `elmM3eCommit` ONCE for the Elm target — a sidecar `generated/m3-kit/elm/PROVENANCE.json` (or a manifest-level field), whichever keeps `run.mjs`'s generic `MANIFEST.json` contract intact with the least plumbing. Rationale: with A1's repeated remeasures, a per-file stamp churns all ~180 files every time and buries real changes; after A3 a binding-neutral remeasure yields ZERO file diffs. Consequences: Task 4's icon header omits the commit line; Task 5 Step 4's expected existing-file diff no longer includes a per-file stamp (it moves to the sidecar) — combined with A2, the expected existing-file delta is purely `[ Kit.text "" ]`→`[]` where present; byte-stability still holds (sidecar is deterministic).

---

## Problem statement

Two emitters run from `profiles/m3-kit/profile.json`'s `emitters[]` via the target-agnostic runner `src/emit/run.mjs`. The built-in `html-label` emitter covers 43 confirmed cemTags; the profile-local Elm emitter covers only 40. The 3 web-components-only tags:

1. **m3e-icon** — `elm.mjs:532` has `if (entry.kind === "iconTable") return [];` — the 141-row icon table is skipped entirely on the Elm side, while `html-label.mjs:479` (`emitIconTableEntry`) emits 141 per-icon bindings.
2. **m3e-circular-progress-indicator** and 3. **m3e-linear-progress-indicator** — no usable Elm facts exist for either tag, so `elm.mjs:295`'s no-facts no-op (`if (!comp) return []`) fires.

## Current-state evidence (verified 2026-07-20)

- `generated/m3-kit/web-components/MANIFEST.json`: 43 tags, `m3e-icon` → 141 files. `generated/m3-kit/elm/MANIFEST.json`: 40 tags. wc-only diff = exactly the 3 tags above; elm-only = none.
- **Icon facts are COMPLETE and ready.** `elm-facts.json` `components["m3e-icon"]`: module `M3e.Icon`, verified setters `name`/`filled`/`variant`/`grade`/`opticalSize`/`weight`, enums for `grade`+`variant`, surfaces `top` (`M3e.Icon` / `view` / `double-list`), `raw`, `html`, `build`. **No remeasure needed for gap 1.** (Note: `plans/2026-07-19-icon-emit-design.md` claimed "m3e-icon is not in elm-facts" — that claim is stale; the fact exists and is rich.)
- Real API confirmed from the elm-m3e checkout (`~/Documents/code/elm-m3e`, `src/M3e/Icon.elm`): `view : List (Attr …) -> List (Element …) -> Element …`, `name : String -> Attr …`, `filled : Bool -> Attr …`. elm-m3e's own doc example: `M3e.Icon.view [ M3e.Icon.name "home" ] []` — attrs list + **empty** children list.
- **The `m3e-progress` fact exists but is HOLLOW**: `setters:{}, enums:{}, surfaces:{}`. The orchestrating brief said the two progress tags were "absent from elm-facts" — the sharper truth: an alias fact pointing at the current hollow `m3e-progress` fact would not quietly no-op; `emitEntry` **throws** at the surface lookup (`elm.mjs:303-309`, "does not emit at surface \"top\"").
- **Root cause of the hollow fact**: elm-m3e's `Facts.elm` records progress as a *group component* — `{ component = "progress", module_ = "M3e.Progress", enums = [], attrRewrites = [], groupConstructors = [ "linear", "circular" ], … }`. The builder's entry heuristic (`elm-facts.build.mjs:585-589`: entry = component noun or `"view"`) finds neither `progress` nor `view` in `M3e.Progress`'s exposing list (it exposes `bufferValue, max, mode, value, variant, indeterminate, linear, circular`), so every surface was skipped with a concern → `surfaces:{}`. `groupConstructors` is not parsed at all today.
- Real Progress API confirmed (`src/M3e/Progress.elm`): `linear`/`circular` are each `List (Attr {…phantom…}) -> List (Element …) -> Element …`. Shared setters with per-constructor phantom gating: `circular` supports `{ indeterminate, max, valueFloat, variant, slot }`; `linear` supports `{ bufferValue, max, mode, valueFloat, variant, slot }`. Signatures: `value : Float -> Attr { c | valueFloat : … }`, `indeterminate : Bool -> …`, `mode : M3e.Token.Value { buffer, determinate, indeterminate, query } -> …`, `variant : M3e.Token.Value { flat, wavy } -> …`. `M3e.Token` exposes `determinate`, `indeterminate`, `buffer`, `query`, `flat`, `wavy` (verified in its exposing list).
- Correspondence entries for both progress tags are already **confirmed**, all axes **unmapped** (Type/Thickness/Progress — header notes only, no getEnum blocks), and `profiles/m3-kit/set-attrs.json` already carries the per-set attrs: circular-determinate `{value:"70"}`, circular-indeterminate `{indeterminate:"true"}`, linear-determinate `{value:"70"}`; linear's sets carry `fixedAttrs {mode:"determinate"/"indeterminate"}`. The whole progress emission need is: alias facts + a Float-literal path for `value`.
- **Checkout drift (critical):** `elm-facts.json` records `elmM3eCommit: 93d2edc`, but the checkout at `~/Documents/code/elm-m3e` is at `f1c7beb` and its visible history is only 3 commits (`cae04cb` "Initialize elm-m3e" → `6de4c90` → `f1c7beb`) — **93d2edc is a dangling object from a rewritten history** (still `git cat-file`-able, not an ancestor). Between the two, `Facts.elm` renamed `surfaces = […]` → `facets = […]` (and `Surface` → `Facet`). Rename-normalized diff of `Facts.elm` shows the ONLY other change is `slotKinds` values (`"text"`→`"shared:text"`, `"icon"`→`"shared:icon"`) — a field the builder does not parse. So a remeasure at `f1c7beb` with an upgraded parser is expected to reproduce every existing component's facts byte-identically except the `elmM3eCommit` stamp.
- **Latent footgun (discovered, fix included here):** running `elm-facts.build.mjs` today against the current checkout would find NO `surfaces = ` field (`sliceField` returns null → `parseSurfaces(null)` → `{matched:[], totalTokens:0}`) and — because matched(0) === totalTokens(0) raises no concern — **silently hollow out every component's surfaces**, breaking all 40 existing Elm emissions on the next emit. The parser upgrade in Task 1 removes this trap.
- **Check gate is safe by construction for this plan:** `src/publish/check.mjs:92-101` builds contexts via the same `computeEmitEntries` + `buildEmitContext` the runner uses. This plan adds **no new ctx fields** (icon branch uses `entry.icons` + existing ctx; progress flows through existing `setAttrs` threading), so the recurring "thread every new ctx field through check.mjs" bug cannot bite.
- Byte-stability contract: `src/emit/run.mjs` header + `test/emitter-api.test.mjs:256` (re-run byte-identical tree). No clocks/randomness anywhere in the touched paths.
- `elm`/`elm-format` binaries are NOT on PATH on this machine — compile verification of emitted snippets is not feasible locally; structural comparison against elm-m3e's own doc examples is the spot-check (matches precedent: `elm-facts.build.mjs --compile-check` self-skips).
- Downstream consumers: the visual pipeline (`src/visual/`) does not read the elm manifest (verified by grep). `src/publish/runner.mjs` reads each label's `MANIFEST.json` at publish time — publish is user-triggered; more files = bigger staging payload only.

## Resolved design decisions

### D1 — Icon Elm binding shape (gap 1)

**Chosen:** one `.figma.ts` per icon row, example:

```
M3e.Icon.view
    [ M3e.Icon.name "wifi"
    ]
    []
```

filled rows add `, M3e.Icon.filled True`. Every name facts-resolved: module + entry from `comp.surfaces[config.surface]`, `name`/`filled` through `setterOf()` (verified-or-throw). Children are the **empty list** — exactly elm-m3e's own documented icon idiom (`M3e.Icon.view [ M3e.Icon.name "home" ] []`); implemented by letting `renderExample` accept `contentExpr = null` → `[]` for double-list forms (record/pipeline forms throw on null content — icon has no record surface, and the profile pins `top`). Imports: `["import M3e.Icon"]` only (no token used, no text seam used). Filename/id mirrors html-label's collision scheme with the Elm emitter's existing `-elm` suffix: `m3e-icon-<kebab(symbolName)>[-filled][-N]-elm.figma.ts`, `-N` (`-2`, `-3`, …) assigned in the committed `entry.icons` array order — deterministic, no row ever silently dropped (18 duplicate (symbolName, filled) pairs exist).

**Rejected:**
- *`[ Kit.text "" ]` children* — the seam is for text content; icons carry none, and elm-m3e's own examples use `[]`.
- *Typed Name enum* — no such API exists; `name : String ->` measured from `M3e.Icon`'s signature.
- *Ligature-as-child (`[ Kit.text "wifi" ]`)* — html-label's reference emission uses the `name` attribute; the `name` setter is a verified library export, the ligature path is not the measured idiom.
- *One file with 141 connects* — architecture is one-binding-per-file; matches html-label + Jack's prior "one binding per icon" call.

### D2 — Progress mapping (gaps 2+3)

**Chosen: option (b)** — teach `elm-facts.build.mjs` group-component support, emitting per-variant **alias facts** keyed by the real CEM tags. For a fact with non-empty `groupConstructors`, the builder measures, per constructor:

- **alias cemTag** — from the delegate call inside the constructor body (`circular … = … M3e.Html.CircularProgressIndicator.circularProgressIndicator …` → segment `CircularProgressIndicator` → `camelToKebab` → `m3e-circular-progress-indicator`), cross-checked against the constructor's doc comment ("The \`m3e-circular-progress-indicator\` variant.") — mismatch → concern + skip (fail loud, never guess).
- **surfaces** — `top`: `{ module: <group module>, entry: <constructor>, form: "double-list" }` (module + constructor both read from the group module's own exposing list); `raw`/`html`: measured from the per-variant modules (`M3e.Raw.CircularProgressIndicator` etc.) exactly like the existing surface loop.
- **setters** — the group module's exposed setters, filtered to the constructor's phantom-record keys (each setter's own phantom key parsed from its signature: `value` → `valueFloat`; `mode` NOT on circular, `indeterminate` NOT on linear — illegal states unrepresentable at the facts level).
- **enums** — token-valued setters (`mode`, `variant`) get their value sets from the `M3e.Token.Value { … }` phantom record in the setter's signature, each value verified exposed in `M3e.Token` (all six needed values verify).
- **setterArgTypes** (new, additive facts field) — `"float"` / `"bool"` / `"string"` parsed from each primitive setter's first argument type, so the emitter can render `M3e.Progress.value 70` (bare Float literal) instead of the wrong `"70"` string.

With alias facts in place, `elm.mjs`'s existing `emitEntry` path emits both tags with **no emitter special-casing**: `fixedAttrs {mode}` resolves through the enum → `M3e.Token.determinate`; set-attrs `value`/`indeterminate` resolve through `resolveSetAttrExpr` (extended for `float` in Task 3). Expected examples:

```
M3e.Progress.circular          M3e.Progress.linear
    [ M3e.Progress.value 70        [ M3e.Progress.mode M3e.Token.determinate
    ]                              , M3e.Progress.value 70
    [ Kit.text "" ]                ]
                                   [ Kit.text "" ]
```

(the `[ Kit.text "" ]` children match the existing no-text-prop behavior of every current emission — changing it would rewrite existing banked files; see open question 2.)

**Rejected:**
- *(a) hand-add alias facts to `elm-facts.json`* — the file's own `$comment` says "do NOT hand-edit"; it is generated output (Jack's global rule: never hand-edit generated code). A hand edit would also be silently clobbered by the next regeneration.
- *(c) map circular/linear → `M3e.Progress` inside `elm.mjs`* — hardcodes a module name and two entry names in the emitter, a direct CARDINAL RULE violation, and leaves the hollow-fact/entry-heuristic bug in the builder unfixed for the next group component elm-m3e ships.

### D3 — Determinism / byte-stability

- No wall-clock, no randomness, no locale-sensitive sorts anywhere added. Icon files iterate the committed `entry.icons` order (same as html-label); setter lines keep the existing fixed→mapped→per-set order with ordinal sorts; alias facts are inserted into `components{}` in Facts.elm order at the parent's position (deterministic JSON key order).
- `emit()` stays a pure function of `(entry, ctx)`; `FACTS` remains static committed data loaded at module init.
- The existing `test/emitter-api.test.mjs` re-run test covers the new files automatically; Task 5 re-asserts byte-identical double-run over the full profile.
- `MANIFEST.json` continues to list exactly what is written (run.mjs owns writing; nothing changes there).

### D4 — Verification per gap (summary; per-task detail below)

| Gap | Proof |
|---|---|
| icon | unit tests (synthetic 4-row table → 4 files, exact contents, `-2` dedup, `-elm` suffix); elm MANIFEST `m3e-icon` length 141; spot-eyeball wifi/settings/filled vs elm-m3e's own doc example shape |
| progress | facts-diff gate (additions-only vs committed facts); unit tests off a pinned progress-facts fixture asserting the exact 4 examples above; 4 files in elm MANIFEST with clean slugs |
| both | wc/elm manifest tag parity 43/43; double-emit byte-identical; `check` reports 0 drift / 0 orphans; full `pnpm test` green |

### D5 — Blast radius

- **Remeasure rewrites `elm-facts.json`** → `elmM3eCommit` stamp becomes `f1c7beb`, and that stamp appears in a header comment of every emitted Elm file (`elm.mjs:477`) → all ~40 existing Elm files change **one comment line**. Benign: `check.mjs` diffs code-only (comments stripped), the re-emitted tree is committed in Task 5, and Code Connect payloads change trivially. Flagged, not avoided — pinning to a dangling commit would be worse provenance.
- **Facts-diff gate (Task 2) is the safety net**: if the remeasure changes ANY existing component's facts beyond the commit stamp (possible in principle — 507 source files changed between the commits), the task **stops and surfaces to Jack** rather than shipping a silent kit-wide emission change. The rename-normalized Facts.elm diff predicts additions-only; the gate proves it.
- The hermetic pin `test/fixtures/elm-facts.button.json` (asserted against committed facts by `test/elm-emitter.test.mjs`) fails loudly if button's slice drifts — an independent second net.
- +141 elm files + 2 progress tags: no visual-pipeline impact (elm manifest unread there); publish payload grows for the Elm label (user-triggered, no gate change); `test/correspond.test.mjs`'s 43-confirmed count is untouched (all 3 tags already confirmed — this plan changes emission only, zero correspondence/facts-input edits).
- No new ctx fields → `check.mjs`, `run.mjs`, `emitter-api.mjs` interfaces all untouched.
- elm-m3e checkout required for Task 2 only; it exists at `~/Documents/code/elm-m3e` — NOTE the builder's default path (`~/code/jackhp95/elm-m3e`) is wrong on this machine; pass `--elm-m3e="$HOME/Documents/code/elm-m3e"`.

---

## File structure

| File | Change | Responsibility |
|---|---|---|
| `profiles/m3-kit/emitters/elm-facts.build.mjs` | modify | parse `facets` (renamed from `surfaces`) + `groupConstructors`; group-component alias facts; `setterArgTypes`; export `_internal` for hermetic tests |
| `profiles/m3-kit/elm-facts.json` | regenerate (never hand-edit) | gains `m3e-circular-progress-indicator` + `m3e-linear-progress-indicator` alias facts; `elmM3eCommit: f1c7beb` |
| `profiles/m3-kit/emitters/elm.mjs` | modify | iconTable emit branch; `renderExample` null-content; `resolveSetAttrExpr` float path |
| `test/elm-facts-build.test.mjs` | create | hermetic parser/group-measure unit tests over synthetic Facts.elm lines + synthetic module sources |
| `test/elm-emitter.test.mjs` | modify | icon-branch tests; progress-alias emission tests; float set-attr test |
| `test/fixtures/elm-facts.progress.json` | create | pinned progress alias-facts slice (mirrors `elm-facts.button.json` pattern) |
| `generated/m3-kit/elm/**` | regenerate | +141 icon files, +4 progress files, header-line churn on existing 40, MANIFEST 43 tags |

---

## Tasks

Model-tier key (Jack's convention): power `fable > opus > sonnet > haiku`; effort `xhigh > high > medium > low`. Tiers below are **expected** — the orchestrator ticks down one when spawning and compensates with this plan as context.

### Task 1: Facts-builder group-component support — **expected tier: opus / medium**

**Files:**
- Modify: `profiles/m3-kit/emitters/elm-facts.build.mjs`
- Create: `test/elm-facts-build.test.mjs`

- [ ] **Step 1: Export the parser internals for hermetic testing**

At the bottom of `elm-facts.build.mjs` (before the dispatch block), add:

```js
export const _internal = {
  parseModuleHead,
  parseFacts,
  parseEnums,
  parseSurfaces,
  sliceField,
  camelToKebab,
  canon,
  parseSetterSignature,   // added in Step 4
  measureGroupAliases,    // added in Step 5
};
```

and guard the dispatch so importing the module for tests runs nothing:

```js
const isMain = process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  if (flags.has("--check")) runCheck();
  else if (flags.has("--compile-check")) runCompileCheck();
  else build();
}
```

- [ ] **Step 2: Write the failing parser tests (facets rename + groupConstructors)**

In `test/elm-facts-build.test.mjs`:

```js
import { test } from "node:test";
import assert from "node:assert/strict";
import { _internal } from "../profiles/m3-kit/emitters/elm-facts.build.mjs";

const PROGRESS_LINE =
  '    , { component = "progress", module_ = "M3e.Progress", enums = [], requiredSlots = [], multiSlots = [], attrRewrites = [], slotRewrites = [], slotUpgrades = [], slotKinds = [], groupConstructors = [ "linear", "circular" ], facets = [ Raw, Html, Standard ], requiredAttrs = [], actionMap = [], usesAction = False }';

test("parseFacts reads the post-rename `facets` field", () => {
  const [fact] = _internal.parseFacts(PROGRESS_LINE);
  assert.deepEqual(fact.surfaces, ["Raw", "Html", "Standard"]);
  assert.equal(fact.surfacesTotalTokens, 3);
});

test("parseFacts reads groupConstructors", () => {
  const [fact] = _internal.parseFacts(PROGRESS_LINE);
  assert.deepEqual(fact.groupConstructors, ["linear", "circular"]);
});

test("parseFacts on a non-group line yields empty groupConstructors", () => {
  const line =
    '    [ { component = "icon", module_ = "M3e.Icon", enums = [ ( "grade", [ "high", "low", "medium" ] ) ], requiredSlots = [], multiSlots = [], attrRewrites = [ ( "attrName", "name" ) ], slotRewrites = [], slotUpgrades = [], slotKinds = [], groupConstructors = [], facets = [ Raw, Html, Standard, Build ], requiredAttrs = [], actionMap = [], usesAction = False }';
  const [fact] = _internal.parseFacts(line);
  assert.deepEqual(fact.groupConstructors, []);
  assert.deepEqual(fact.surfaces, ["Raw", "Html", "Standard", "Build"]);
});
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `node --test test/elm-facts-build.test.mjs`
Expected: FAIL — `fact.surfaces` is `[]` (parser still slices `surfaces = `), `fact.groupConstructors` is `undefined`.

- [ ] **Step 4: Implement the parser changes**

In `parseFacts` (`elm-facts.build.mjs:277-298`), replace the surfaces slice and add groupConstructors:

```js
    const surfacesParsed = parseSurfaces(sliceField(line, "facets", "requiredAttrs"));
    const groupSection = sliceField(line, "groupConstructors", "facets");
    facts.push({
      component,
      module_,
      enums: parseEnums(sliceField(line, "enums", "requiredSlots")),
      attrRewrites: parseTupleList(sliceField(line, "attrRewrites", "slotRewrites")),
      slotRewrites: parseTupleList(sliceField(line, "slotRewrites", "slotUpgrades")),
      slotUpgrades: parseTupleList(sliceField(line, "slotUpgrades", "slotKinds")),
      groupConstructors: groupSection ? [...groupSection.matchAll(/"([^"]+)"/g)].map((m) => m[1]) : [],
      surfaces: surfacesParsed.matched,
      surfacesTotalTokens: surfacesParsed.totalTokens,
    });
```

Also update the builder's header comment block to document the `facets` rename (source-of-truth comments must not claim the old field name).

- [ ] **Step 5: Run parser tests to verify they pass**

Run: `node --test test/elm-facts-build.test.mjs` — Expected: PASS.

- [ ] **Step 6: Write the failing signature-parsing tests**

Add `parseSetterSignature(moduleText, setterName)` tests — it must return `{ argType, phantomKey, enumValues }`:

```js
const PROGRESS_MODULE = `module M3e.Progress exposing
    ( bufferValue, max, mode, value, variant, indeterminate
    , linear, circular
    )

value : Float -> Markup.Html.Attr.Attr { c | valueFloat : M3e.Token.Supported } msg
value =
    M3e.Html.LinearProgressIndicator.value

indeterminate :
    Bool
    -> Markup.Html.Attr.Attr { c | indeterminate : M3e.Token.Supported } msg
indeterminate =
    M3e.Html.CircularProgressIndicator.indeterminate

mode :
    M3e.Token.Value
        { buffer : M3e.Token.Supported
        , determinate : M3e.Token.Supported
        , indeterminate : M3e.Token.Supported
        , query : M3e.Token.Supported
        }
    -> Markup.Html.Attr.Attr { c | mode : M3e.Token.Supported } msg
mode =
    M3e.Html.LinearProgressIndicator.mode

circular :
    List
        (Markup.Html.Attr.Attr
            { indeterminate : M3e.Token.Supported
            , max : M3e.Token.Supported
            , valueFloat : M3e.Token.Supported
            , variant : M3e.Token.Supported
            , slot : M3e.Token.Supported
            }
            msg
        )
    -> List (Markup.Element.Element child msg)
    -> Markup.Element.Element { s | progress : M3e.Kind.Brand } msg
circular attributes children =
    Markup.Element.Internal.fromNode
        (Markup.Node.fromComponent
            (\\erased ch ->
                M3e.Html.CircularProgressIndicator.circularProgressIndicator
                    (List.map Markup.Html.Attr.Internal.forget erased)
                    ch
            )
            (List.map Markup.Html.Attr.Internal.forget attributes)
            (List.map Markup.Element.toNode children)
        )
`;

test("parseSetterSignature: Float primitive", () => {
  const sig = _internal.parseSetterSignature(PROGRESS_MODULE, "value");
  assert.equal(sig.argType, "float");
  assert.equal(sig.phantomKey, "valueFloat");
  assert.equal(sig.enumValues, null);
});

test("parseSetterSignature: Bool primitive", () => {
  const sig = _internal.parseSetterSignature(PROGRESS_MODULE, "indeterminate");
  assert.equal(sig.argType, "bool");
  assert.equal(sig.phantomKey, "indeterminate");
});

test("parseSetterSignature: Token.Value enum", () => {
  const sig = _internal.parseSetterSignature(PROGRESS_MODULE, "mode");
  assert.equal(sig.argType, "enum");
  assert.deepEqual(sig.enumValues, ["buffer", "determinate", "indeterminate", "query"]);
  assert.equal(sig.phantomKey, "mode");
});
```

Run: `node --test test/elm-facts-build.test.mjs` — Expected: FAIL (`parseSetterSignature` not defined).

- [ ] **Step 7: Implement `parseSetterSignature`**

Add to `elm-facts.build.mjs` (near the other measured-name helpers):

```js
// parseSetterSignature(moduleText, name) -> { argType, phantomKey, enumValues } | null.
//
// Reads the TYPE ANNOTATION of one exposed value from an Elm module's source:
// the text between `^<name> :` and the next line starting `<name> ` or
// `<name>=` (the definition). From the annotation's FIRST argument (text
// before the first top-level `->`):
//   `Float`                       -> argType "float"
//   `Bool`                        -> argType "bool"
//   `String`                      -> argType "string"
//   `M3e.Token.Value { k : … }`   -> argType "enum", enumValues = the record keys
//   anything else                 -> argType "opaque" (recorded, never guessed at)
// phantomKey: the extension-record key in the RETURN type's
// `Attr { c | <key> : … }` — this is what gates which setters a group
// constructor supports (its own phantom record lists the same keys).
function parseSetterSignature(moduleText, name) {
  const sigRe = new RegExp(`^${name} :([\\s\\S]*?)^${name}[ =]`, "m");
  const m = moduleText.match(sigRe);
  if (!m) return null;
  const annotation = m[1];

  // First top-level arg: split on `->` at paren/brace depth 0.
  let depth = 0;
  let firstArgEnd = annotation.length;
  for (let i = 0; i < annotation.length - 1; i += 1) {
    const ch = annotation[i];
    if (ch === "(" || ch === "{") depth += 1;
    else if (ch === ")" || ch === "}") depth -= 1;
    else if (depth === 0 && ch === "-" && annotation[i + 1] === ">") {
      firstArgEnd = i;
      break;
    }
  }
  const firstArg = annotation.slice(0, firstArgEnd).trim();

  const phantomMatch = annotation.match(/Attr\s*\{\s*\w+\s*\|\s*(\w+)\s*:/);
  const phantomKey = phantomMatch ? phantomMatch[1] : null;

  if (/^Float$/.test(firstArg)) return { argType: "float", phantomKey, enumValues: null };
  if (/^Bool$/.test(firstArg)) return { argType: "bool", phantomKey, enumValues: null };
  if (/^String$/.test(firstArg)) return { argType: "string", phantomKey, enumValues: null };

  const tokenValue = firstArg.match(/M3e\.Token\.Value\s*\{([\s\S]*)\}/);
  if (tokenValue) {
    const enumValues = [...tokenValue[1].matchAll(/(\w+)\s*:/g)].map((v) => v[1]);
    return { argType: "enum", phantomKey, enumValues };
  }
  return { argType: "opaque", phantomKey, enumValues: null };
}
```

Run: `node --test test/elm-facts-build.test.mjs` — Expected: PASS.

- [ ] **Step 8: Write the failing group-alias test**

```js
test("measureGroupAliases: progress -> two per-variant alias facts", () => {
  const fact = _internal.parseFacts(PROGRESS_LINE)[0];
  const aliases = _internal.measureGroupAliases({
    fact,
    rootNs: "M3e",
    groupModuleText: PROGRESS_MODULE,
    groupModuleName: "M3e.Progress",
    tokenModule: "M3e.Token",
    exposedTokens: new Set(["buffer", "determinate", "indeterminate", "query", "flat", "wavy"]),
    concerns: [],
  });
  const circ = aliases.find((a) => a.cemTag === "m3e-circular-progress-indicator");
  assert.ok(circ, "circular alias derived from the delegate call");
  assert.equal(circ.surfaces.top.module, "M3e.Progress");
  assert.equal(circ.surfaces.top.entry, "circular");
  assert.equal(circ.surfaces.top.form, "double-list");
  assert.equal(circ.setters.value, "value");
  assert.equal(circ.setters.indeterminate, "indeterminate");
  assert.equal(circ.setters.mode, undefined, "mode is linear-only (phantom gating)");
  assert.equal(circ.setterArgTypes.value, "float");
  assert.equal(circ.setterArgTypes.indeterminate, "bool");
});
```

(The synthetic `PROGRESS_MODULE` above deliberately includes only `circular`; the real run derives `linear` the same way. Add a `mode`-carrying `linear` constructor block to the fixture if you want both asserted — copy the real `linear` signature from `~/Documents/code/elm-m3e/src/M3e/Progress.elm:79-101` verbatim.)

Run: `node --test test/elm-facts-build.test.mjs` — Expected: FAIL (`measureGroupAliases` not defined).

- [ ] **Step 9: Implement `measureGroupAliases` + wire it into `build()`**

```js
// measureGroupAliases({ fact, rootNs, groupModuleText, groupModuleName,
//   tokenModule, exposedTokens, concerns }) -> alias component-fact objects.
//
// A GROUP component (Facts.elm `groupConstructors` non-empty, e.g. progress's
// [ "linear", "circular" ]) unifies several CEM tags into one Elm module whose
// entry constructors are the variants. The parent's own cemTag (m3e-progress)
// is NOT a real CEM tag; the real tags are derived per constructor, MEASURED:
//   - variant module segment: the qualified delegate call inside the
//     constructor body (`M3e.Html.CircularProgressIndicator.…`) — never guessed.
//   - cross-check: the constructor's doc comment names the tag verbatim
//     ("The `m3e-circular-progress-indicator` variant."); mismatch -> concern + skip.
//   - setters: the group module's exposed setters whose phantomKey appears in
//     the constructor's own phantom attr record (parsed from its signature).
//   - enums: Token.Value setters, values verified against exposedTokens.
//   - setterArgTypes: primitive arg kinds so the emitter can format literals.
function measureGroupAliases({ fact, rootNs, groupModuleText, groupModuleName, tokenModule, exposedTokens, concerns }) {
  const head = parseModuleHead(groupModuleText);
  if (!head) {
    concerns.push(`${fact.component}: group module head unparseable — no aliases emitted.`);
    return [];
  }
  const ctors = new Set(fact.groupConstructors);
  const setterNames = [...head.exposed].filter((n) => !ctors.has(n));

  // Signature per exposed setter (skip unparseable ones with a concern).
  const setterSigs = new Map();
  for (const s of setterNames) {
    const sig = parseSetterSignature(groupModuleText, s);
    if (!sig) concerns.push(`${fact.component}.${s}: group setter signature unparseable — omitted from aliases.`);
    else setterSigs.set(s, sig);
  }

  const aliases = [];
  for (const ctor of fact.groupConstructors) {
    if (!head.exposed.has(ctor)) {
      concerns.push(`${fact.component}: group constructor "${ctor}" not exposed by ${groupModuleName} — skipped.`);
      continue;
    }
    const ctorSig = parseSetterSignature(groupModuleText, ctor); // reuse: first arg = List (Attr { … })
    const ctorBodyRe = new RegExp(`^${ctor} [\\s\\S]*?M3e\\.(?:Html|Raw)\\.(\\w+)\\.`, "m");
    const delegate = groupModuleText.match(ctorBodyRe);
    if (!delegate) {
      concerns.push(`${fact.component}: no qualified delegate call found in constructor "${ctor}" — cannot derive its CEM tag; skipped.`);
      continue;
    }
    const variantSeg = delegate[1]; // "CircularProgressIndicator"
    const cemTag = `${camelToKebab(rootNs)}-${camelToKebab(variantSeg[0].toLowerCase() + variantSeg.slice(1))}`;

    // Cross-check against the doc comment's backticked tag, when present.
    const docRe = new RegExp("The `([a-z0-9-]+)` variant\\.[\\s\\S]{0,40}?" + ctor + " :");
    const doc = groupModuleText.match(docRe);
    if (doc && doc[1] !== cemTag) {
      concerns.push(`${fact.component}.${ctor}: delegate-derived tag "${cemTag}" != doc-comment tag "${doc[1]}" — skipped (refusing to guess).`);
      continue;
    }

    // Constructor's supported phantom keys (from its own attr record).
    const ctorPhantom = ctorSig
      ? new Set([...String(ctorSig && groupModuleText.match(new RegExp(`^${ctor} :([\\s\\S]*?)^${ctor} `, "m"))[1].matchAll(/(\w+)\s*:\s*M3e\.Token\.Supported/g)].map((m) => m[1]))
      : new Set();

    const setters = {};
    const enums = {};
    const setterArgTypes = {};
    for (const [s, sig] of setterSigs) {
      if (!sig.phantomKey || !ctorPhantom.has(sig.phantomKey)) continue; // not supported by this variant
      setters[s] = s; // exposed by the group module's own head — verified by construction here
      if (sig.argType === "enum") {
        enums[s] = {
          values: sig.enumValues.map((elm) => {
            const exposed = exposedTokens.has(elm);
            if (!exposed) concerns.push(`${fact.component}.${s}: enum value "${elm}" NOT exposed in ${tokenModule} — token:null.`);
            return { elm, key: canon(elm), token: exposed ? `${tokenModule}.${elm}` : null };
          }),
        };
      } else {
        setterArgTypes[s] = sig.argType;
      }
    }

    aliases.push({
      cemTag,
      component: fact.component,
      group: { module: groupModuleName, constructor: ctor },
      module: groupModuleName,
      rootNamespace: rootNs,
      tokenModule,
      actionModule: null, // group facts observed with usesAction = False; measure like the parent if that changes
      setters,
      setterArgTypes,
      enums,
      slotSetters: [],
      slotUpgrades: [],
      surfaces: {
        top: { surface: "Standard", module: groupModuleName, entry: ctor, form: "double-list" },
      },
    });
  }
  return aliases;
}
```

Wire into `build()`'s per-fact loop, right after `components[cemTag] = { … }`:

```js
    if (fact.groupConstructors.length > 0) {
      const groupModuleText = fs.existsSync(moduleFilePath(fact.module_))
        ? fs.readFileSync(moduleFilePath(fact.module_), "utf8")
        : null;
      if (!groupModuleText) {
        concerns.push(`${fact.component}: group module file missing at ${moduleFilePath(fact.module_)} — no aliases.`);
      } else {
        for (const alias of measureGroupAliases({
          fact,
          rootNs,
          groupModuleText,
          groupModuleName: fact.module_,
          tokenModule,
          exposedTokens,
          concerns,
        })) {
          // raw/html surfaces: measured from the per-variant modules, same
          // discipline as the main surfaces loop (module head + entry from
          // its own exposing list); skip-with-concern when absent.
          for (const [key, ctorName] of [["raw", "Raw"], ["html", "Html"]]) {
            if (!fact.surfaces.includes(ctorName)) continue;
            const segGuess = alias.cemTag.replace(/^m3e-/, "").split("-").map((w) => w[0].toUpperCase() + w.slice(1)).join("");
            const variantHead = moduleHeadFor(`${rootNs}.${ctorName}.${segGuess}`);
            if (!variantHead) {
              concerns.push(`${alias.cemTag}: ${ctorName} variant module not found — surface "${key}" omitted.`);
              continue;
            }
            const entry = [...variantHead.exposed].find((e) => canon(e) === canon(segGuess)) ?? (variantHead.exposed.has("view") ? "view" : null);
            if (!entry) {
              concerns.push(`${alias.cemTag}: no entry constructor exposed by ${variantHead.module} — surface "${key}" omitted.`);
              continue;
            }
            alias.surfaces[key] = { surface: ctorName, module: variantHead.module, entry, form: CTOR_FORM[ctorName] };
          }
          components[alias.cemTag] = alias;
        }
      }
    }
```

- [ ] **Step 10: Run the full new test file**

Run: `node --test test/elm-facts-build.test.mjs` — Expected: PASS (all parser + signature + alias tests).

- [ ] **Step 11: Commit**

```bash
git add profiles/m3-kit/emitters/elm-facts.build.mjs test/elm-facts-build.test.mjs
git commit -m "feat(elm-facts): parse post-rename facets + groupConstructors; measure per-variant alias facts for group components"
```

**Acceptance:** hermetic tests green; `elm-facts.json` NOT yet regenerated (that is Task 2's gated step); no emitter changes yet.

---

### Task 2: Remeasure facts + additions-only diff gate — **expected tier: sonnet / medium**

**Files:**
- Regenerate: `profiles/m3-kit/elm-facts.json`
- (read-only) `~/Documents/code/elm-m3e` at `f1c7beb`

- [ ] **Step 1: Sentinel check against the real checkout**

Run: `node profiles/m3-kit/emitters/elm-facts.build.mjs --check --elm-m3e="$HOME/Documents/code/elm-m3e"`
Expected: `OK — 0 occurrences of "import M3e.Value"` (exit 0).

- [ ] **Step 2: Snapshot the committed facts, then regenerate**

```bash
cp profiles/m3-kit/elm-facts.json /tmp/elm-facts.before.json
node profiles/m3-kit/emitters/elm-facts.build.mjs --elm-m3e="$HOME/Documents/code/elm-m3e"
```

Expected stdout: `wrote … — 124 components, elm-m3e @ f1c7beb.` (122 existing + 2 progress aliases; the count may differ if other group components exist — read the concerns list).

- [ ] **Step 3: THE GATE — diff must be additions-only**

```bash
node -e '
const a = require("/tmp/elm-facts.before.json"), b = require("./profiles/m3-kit/elm-facts.json");
const aK = Object.keys(a.components), bK = Object.keys(b.components);
const added = bK.filter(k => !aK.includes(k));
const removed = aK.filter(k => !bK.includes(k));
const changed = aK.filter(k => bK.includes(k) && JSON.stringify(a.components[k]) !== JSON.stringify(b.components[k]));
console.log("added:", added);
console.log("removed:", removed);
console.log("changed:", changed);
console.log("commit:", a.elmM3eCommit, "->", b.elmM3eCommit);
process.exit(removed.length || changed.length ? 1 : 0);
'
```

Expected: `added: [ 'm3e-circular-progress-indicator', 'm3e-linear-progress-indicator' ]`, `removed: []`, `changed: []` (or changed limited to `m3e-progress` gaining a `group` note if Task 1 chose to annotate the parent), commit `93d2edc -> f1c7beb`, exit 0.

**If `removed`/`changed` is non-empty: STOP. Do not commit. Surface the exact diff to Jack** — it means the f1c7beb source drift touched existing measured names, and shipping it silently would rewrite banked emissions kit-wide.

- [ ] **Step 4: Verify the new alias facts' content**

```bash
node -e '
const f = require("./profiles/m3-kit/elm-facts.json");
const c = f.components["m3e-circular-progress-indicator"], l = f.components["m3e-linear-progress-indicator"];
console.log(JSON.stringify(c, null, 2));
console.log(JSON.stringify(l, null, 2));
'
```

Expected: circular — surfaces.top `{module:"M3e.Progress", entry:"circular", form:"double-list"}`, setters `{indeterminate, max, value, variant}` (+ `slot` never recorded — no phantom-matched setter), `setterArgTypes` `{indeterminate:"bool", max:"float", value:"float"}`, enums.variant values flat/wavy with real tokens. linear — entry `"linear"`, setters `{bufferValue, max, mode, value, variant}`, enums.mode values buffer/determinate/indeterminate/query all with non-null tokens.

- [ ] **Step 5: Hermetic pin + existing suite still green**

Run: `node --test test/elm-emitter.test.mjs`
Expected: PASS — the `elm-facts.button.json` pin proves button's slice survived the remeasure byte-identically.

- [ ] **Step 6: Commit**

```bash
git add profiles/m3-kit/elm-facts.json
git commit -m "feat(elm-facts): remeasure at elm-m3e f1c7beb — adds m3e-{circular,linear}-progress-indicator group alias facts"
```

**Acceptance:** gate passed additions-only; pin test green. NOTE: `generated/m3-kit/elm/**` is now stale vs the new commit stamp — expected; Task 5 regenerates. Do not run `check` between Tasks 2 and 5 and treat its comment-tolerant pass/fail as final either way.

---

### Task 3: Float-literal set-attrs in `elm.mjs` — **expected tier: sonnet / low**

**Files:**
- Modify: `profiles/m3-kit/emitters/elm.mjs:178-188` (`resolveSetAttrExpr`)
- Test: `test/elm-emitter.test.mjs`

- [ ] **Step 1: Write the failing test**

```js
test("resolveSetAttrExpr: float argType renders a bare Elm number literal", () => {
  const comp = {
    component: "progress",
    setters: { value: "value" },
    setterArgTypes: { value: "float" },
    enums: {},
  };
  assert.equal(_internal.resolveSetAttrExpr(comp, "value", "70", "test"), "70");
});

test("resolveSetAttrExpr: float argType rejects a non-numeric value loudly", () => {
  const comp = { component: "progress", setters: { value: "value" }, setterArgTypes: { value: "float" }, enums: {} };
  assert.throws(() => _internal.resolveSetAttrExpr(comp, "value", "seventy", "test"), /not numeric/);
});

test("resolveSetAttrExpr: no argTypes -> existing behavior unchanged (string-quoted)", () => {
  const comp = { component: "x", setters: { href: "href" }, enums: {} };
  assert.equal(_internal.resolveSetAttrExpr(comp, "href", "70", "test"), '"70"');
});
```

Run: `node --test test/elm-emitter.test.mjs` — Expected: first two FAIL.

- [ ] **Step 2: Implement**

Replace `resolveSetAttrExpr`'s primitive fallback (`elm.mjs:184-187`):

```js
  // Primitive: facts-typed float, else boolean, else opaque string.
  const argType = comp.setterArgTypes?.[setter];
  if (argType === "float") {
    if (!/^-?[0-9]+(\.[0-9]+)?$/.test(String(value))) {
      throw new Error(
        `elm emitter: ${ctxLabel} — value "${value}" is not numeric, but setter "${setter}" ` +
          `takes Float (elm-facts setterArgTypes). Refusing to emit a malformed literal.`
      );
    }
    return String(value); // digits verbatim -> deterministic bare Elm number literal
  }
  if (value === "true") return "True";
  if (value === "false") return "False";
  return JSON.stringify(value);
```

- [ ] **Step 3: Run tests** — `node --test test/elm-emitter.test.mjs` — Expected: PASS (including all pre-existing tests: components without `setterArgTypes` hit the unchanged fallback, so the 40 existing emissions are byte-identical).

- [ ] **Step 4: Commit**

```bash
git add profiles/m3-kit/emitters/elm.mjs test/elm-emitter.test.mjs
git commit -m "feat(elm): setterArgTypes-aware set-attrs — float facts render bare Elm number literals"
```

---

### Task 4: iconTable emit branch in `elm.mjs` — **expected tier: sonnet / medium**

**Files:**
- Modify: `profiles/m3-kit/emitters/elm.mjs` (`renderExample`, new `emitIconTableEntry`, `emitter.emit`)
- Test: `test/elm-emitter.test.mjs`

- [ ] **Step 1: Write the failing tests**

```js
const ICON_ENTRY = {
  cemTag: "m3e-icon",
  kind: "iconTable",
  status: "confirmed",
  icons: [
    { figmaNodeId: "1:1", figmaName: "wifi", symbolName: "wifi", filled: false },
    { figmaNodeId: "1:2", figmaName: "stars", symbolName: "stars", filled: true },
    { figmaNodeId: "1:3", figmaName: "settings", symbolName: "settings", filled: false },
    { figmaNodeId: "1:4", figmaName: "settings-2", symbolName: "settings", filled: false },
  ],
};
const ICON_CONFIG = { fileKey: "K", fileName: "F", surface: "top", textSeam: "Kit" };

test("elm iconTable: one file per row, facts-resolved names, -elm suffix", () => {
  const files = _internal.emitIconTableEntry(ICON_ENTRY, ICON_CONFIG);
  assert.equal(files.length, 4);
  assert.deepEqual(files.map((f) => f.path), [
    "m3e-icon-wifi-elm.figma.ts",
    "m3e-icon-stars-filled-elm.figma.ts",
    "m3e-icon-settings-elm.figma.ts",
    "m3e-icon-settings-2-elm.figma.ts", // dup (symbolName, filled) -> -2, icons-array order
  ]);
  assert.match(files[0].contents, /M3e\.Icon\.view\n    \[ M3e\.Icon\.name "wifi"\n    \]\n    \[\]/);
  assert.match(files[1].contents, /M3e\.Icon\.filled True/);
  assert.match(files[0].contents, /"import M3e\.Icon"/);
  assert.doesNotMatch(files[0].contents, /Kit\.text|M3e\.Token/, "no seam/token import for icons");
});

test("elm iconTable: emitter.emit dispatches iconTable entries", () => {
  const ctx = {
    profile: { fileKey: "K", raw: { elm: { elmSurface: "top", textSeam: "Kit" } } },
    figma: { data: { meta: { fileName: "F" } } },
  };
  const files = emitter.emit(ICON_ENTRY, ctx);
  assert.equal(files.length, 4);
});
```

Run: `node --test test/elm-emitter.test.mjs` — Expected: FAIL (`emitIconTableEntry` not exported; `emitter.emit` returns `[]`).

- [ ] **Step 2: Extend `renderExample` for empty children**

In `elm.mjs:231-272`, allow `contentExpr = null` (double-list only):

```js
  switch (surfaceDef.form) {
    case "double-list":
      // <Module>.<entry> [attrs] [children] — a null contentExpr means NO
      // children (elm-m3e's own icon idiom: `M3e.Icon.view [ … ] []`).
      return `${mod}.${entry}\n    ${attrList}\n    ${contentExpr === null ? "[]" : `[ ${contentExpr} ]`}`;
```

and make `record-double-list` / `pipeline` throw on `contentExpr === null`:

```js
    case "record-double-list":
      if (contentExpr === null) {
        throw new Error(`elm emitter: surface ${surfaceDef.surface} requires content (record form) — cannot render a no-content entry here.`);
      }
```

(same guard at the top of the `pipeline` case).

- [ ] **Step 3: Implement `emitIconTableEntry`**

Add to `elm.mjs` (after `emitEntry`), mirroring `html-label.mjs:479-516`'s collision scheme exactly:

```js
// emitIconTableEntry(entry, config) -> [{ path, contents, id }]
//
// The Elm mirror of html-label.mjs's emitIconTableEntry (kind:"iconTable",
// the 141-row m3e-icon table): ONE file per icon row, each mapping a real
// Figma icon node -> `M3e.Icon.view [ M3e.Icon.name "<symbol>" (, filled) ] []`
// — elm-m3e's own documented icon idiom (children EMPTY, no text seam).
// Every name is facts-resolved (CARDINAL RULE): module+entry from the
// surface fact, name/filled through setterOf (verified-or-throw).
//
// COLLISION HANDLING mirrors html-label byte-for-byte in spirit: dup
// (symbolName, filled) filenames get -2/-3… in icons-array order, then the
// Elm emitter's own `-elm` suffix: m3e-icon-<kebab(symbol)>[-filled][-N]-elm.
function emitIconTableEntry(entry, config) {
  const comp = FACTS.components[entry.cemTag];
  if (!comp) return []; // no facts for this tag — same quiet no-op as emitEntry

  const surfaceKey = config.surface;
  if (!FACTS.surfaceKeys.includes(surfaceKey)) {
    throw new Error(`elm emitter: elmSurface "${surfaceKey}" is not one of ${FACTS.surfaceKeys.join(", ")}.`);
  }
  const surfaceDef = comp.surfaces[surfaceKey];
  if (!surfaceDef) {
    throw new Error(
      `elm emitter: component "${comp.component}" does not emit at surface "${surfaceKey}" ` +
        `(available: ${Object.keys(comp.surfaces).join(", ")}).`
    );
  }

  const nameSetter = setterOf(comp, "name", "iconTable name");
  const filledSetter = setterOf(comp, "filled", "iconTable filled");

  const files = [];
  const usedBases = new Map();
  for (const row of entry.icons) {
    const baseName = `${entry.cemTag}-${kebab(row.symbolName)}${row.filled ? "-filled" : ""}`;
    const priorCount = usedBases.get(baseName) ?? 0;
    const suffix = priorCount === 0 ? "" : `-${priorCount + 1}`;
    usedBases.set(baseName, priorCount + 1);
    const id = `${baseName}${suffix}-elm`;

    const url = buildNodeUrl(config, row.figmaNodeId);
    const setterLines = [
      { setter: nameSetter, expr: JSON.stringify(row.symbolName) },
      ...(row.filled ? [{ setter: filledSetter, expr: "True" }] : []),
    ];
    const example = renderExample(surfaceDef, comp, setterLines, null);

    const headerLines = [
      ` * GENERATED by cem-figma-connect (profiles/m3-kit/emitters/elm.mjs) — do not edit by hand.`,
      ` * ${entry.cemTag} (iconTable row "${row.figmaName}") -> ${surfaceDef.module}.${surfaceDef.entry} (elmSurface: "${surfaceKey}", surface ${surfaceDef.surface}).`,
      ` * bound to Figma icon node ${row.figmaNodeId}; symbol "${row.symbolName}"${row.filled ? " (filled)" : ""}.`,
      ` * names resolved from elm-facts.json (elm-m3e @ ${FACTS.elmM3eCommit}).`,
    ];

    const contents =
      `// url=${url}\n` +
      `import figma from "figma"\n` +
      `\n` +
      `/**\n${headerLines.join("\n")}\n */\n` +
      `\n` +
      `export default {\n` +
      `  example: figma.code\`${example}\`,\n` +
      `  imports: [${JSON.stringify(`import ${surfaceDef.module}`)}],\n` +
      `  id: ${JSON.stringify(id)},\n` +
      `  metadata: {\n` +
      `    nestable: true,\n` +
      `  },\n` +
      `}\n`;

    files.push({ path: `${id}.figma.ts`, contents, id });
  }
  return files;
}
```

Export it via `_internal` (add `emitIconTableEntry` to the `_internal` object), and replace the skip in `emitter.emit` (`elm.mjs:532`):

```js
  emit(entry, ctx) {
    const config = {
      fileKey: ctx.profile.fileKey,
      fileName: ctx.figma.data.meta.fileName,
      surface:
        ctx.profile.raw?.elm?.elmSurface ??
        ctx.profile.raw?.elmSurface ??
        FACTS.defaultSurface,
      textSeam: ctx.profile.raw?.elm?.textSeam ?? FACTS.textSeam?.module ?? "Kit",
      examples: ctx.examples ?? {},
      setAttrs: ctx.setAttrs ?? {},
    };

    if (entry.kind === "iconTable") {
      return emitIconTableEntry(entry, config).map(({ path, contents }) => ({ path, contents }));
    }
    if (!entry.figmaSets || entry.figmaSets.length === 0) return [];

    return emitEntry(entry, config).map(({ path, contents }) => ({ path, contents }));
  },
```

- [ ] **Step 4: Run tests** — `node --test test/elm-emitter.test.mjs` — Expected: PASS, including every pre-existing test (non-iconTable paths untouched).

- [ ] **Step 5: Commit**

```bash
git add profiles/m3-kit/emitters/elm.mjs test/elm-emitter.test.mjs
git commit -m "feat(elm): iconTable emit branch — 141 per-icon M3e.Icon bindings, facts-resolved, collision-suffixed"
```

---

### Task 5: Progress emission tests, full regenerate, parity + gates — **expected tier: sonnet / medium**

**Files:**
- Create: `test/fixtures/elm-facts.progress.json` (pin: the two alias facts copied verbatim from the regenerated `profiles/m3-kit/elm-facts.json`)
- Modify: `test/elm-emitter.test.mjs`
- Regenerate: `generated/m3-kit/elm/**` (and confirm `generated/m3-kit/web-components/**` byte-identical)

- [ ] **Step 1: Pin the progress alias facts**

```bash
node -e '
const f = require("./profiles/m3-kit/elm-facts.json");
const pin = {
  "m3e-circular-progress-indicator": f.components["m3e-circular-progress-indicator"],
  "m3e-linear-progress-indicator": f.components["m3e-linear-progress-indicator"],
};
require("fs").writeFileSync("test/fixtures/elm-facts.progress.json", JSON.stringify(pin, null, 2) + "\n");
'
```

- [ ] **Step 2: Write the progress emission tests (failing only if Tasks 1-3 mis-landed)**

```js
const PROGRESS_PIN = JSON.parse(fs.readFileSync(new URL("./fixtures/elm-facts.progress.json", import.meta.url), "utf8"));

test("committed facts still match the progress pin (regeneration drift guard)", () => {
  assert.deepEqual(FACTS.components["m3e-circular-progress-indicator"], PROGRESS_PIN["m3e-circular-progress-indicator"]);
  assert.deepEqual(FACTS.components["m3e-linear-progress-indicator"], PROGRESS_PIN["m3e-linear-progress-indicator"]);
});

test("circular progress: set-attrs value -> M3e.Progress.circular [ value 70 ]", () => {
  const entry = {
    cemTag: "m3e-circular-progress-indicator",
    status: "confirmed",
    figmaSets: [
      { nodeId: "58005:8459", setName: "Circular-determinate progress indicator", fixedAttrs: {} },
      { nodeId: "58005:8460", setName: "Circular-indeterminate progress indicator", fixedAttrs: {} },
    ],
    axes: [], props: [],
  };
  const files = emitEntry(entry, {
    fileKey: "K", fileName: "F", surface: "top", textSeam: "Kit",
    setAttrs: {
      "m3e-circular-progress-indicator": {
        "Circular-determinate progress indicator": { value: "70" },
        "Circular-indeterminate progress indicator": { indeterminate: "true" },
      },
    },
  });
  assert.equal(files.length, 2);
  assert.match(files[0].contents, /M3e\.Progress\.circular\n    \[ M3e\.Progress\.value 70\n    \]/);
  assert.match(files[1].contents, /M3e\.Progress\.indeterminate True/);
  assert.match(files[0].contents, /"import M3e\.Progress"/);
});

test("linear progress: fixedAttrs mode -> M3e.Token enum + set-attrs value", () => {
  const entry = {
    cemTag: "m3e-linear-progress-indicator",
    status: "confirmed",
    figmaSets: [
      { nodeId: "1:10", setName: "Linear-determinate progress indicator", fixedAttrs: { mode: "determinate" } },
      { nodeId: "1:11", setName: "Linear-indeterminate progress indicator", fixedAttrs: { mode: "indeterminate" } },
    ],
    axes: [], props: [],
  };
  const files = emitEntry(entry, {
    fileKey: "K", fileName: "F", surface: "top", textSeam: "Kit",
    setAttrs: { "m3e-linear-progress-indicator": { "Linear-determinate progress indicator": { value: "70" } } },
  });
  assert.match(files[0].contents, /M3e\.Progress\.mode M3e\.Token\.determinate\n    , M3e\.Progress\.value 70/);
  assert.match(files[1].contents, /M3e\.Progress\.mode M3e\.Token\.indeterminate/);
  assert.equal(files[0].id, "m3e-linear-progress-indicator-determinate-elm");
});
```

Run: `node --test test/elm-emitter.test.mjs` — Expected: PASS (these tests document behavior that Tasks 1-3 already built; a failure here means a real integration bug — fix before proceeding).

- [ ] **Step 3: Full regenerate, twice, byte-identical**

```bash
node src/cli.mjs emit --profile m3-kit
cp -R generated/m3-kit /tmp/emit-run-1
node src/cli.mjs emit --profile m3-kit
diff -r /tmp/emit-run-1 generated/m3-kit && echo BYTE-STABLE
```

(If the CLI verb differs, use the repo's actual emit invocation — see `src/cli.mjs`.)
Expected: `BYTE-STABLE`.

- [ ] **Step 4: Parity + spot checks**

```bash
node -e '
const wc = require("./generated/m3-kit/web-components/MANIFEST.json");
const elm = require("./generated/m3-kit/elm/MANIFEST.json");
const wcK = Object.keys(wc), elmK = Object.keys(elm);
console.log("wc", wcK.length, "elm", elmK.length);
console.log("wc-only:", wcK.filter(t => !elmK.includes(t)));
console.log("elm m3e-icon files:", elm["m3e-icon"].length);
console.log("elm circular files:", elm["m3e-circular-progress-indicator"]);
console.log("elm linear files:", elm["m3e-linear-progress-indicator"]);
'
```

Expected: `wc 43 elm 43`, `wc-only: []`, icon 141, circular 2 files (`…-circular-determinate-progress-indicator-elm` / `…-circular-indeterminate-progress-indicator-elm`), linear 2 (`…-determinate-elm` / `…-indeterminate-elm`).

Eyeball 4 emitted files against elm-m3e's own doc idioms (this is the well-formedness spot-check — `elm` is not on PATH, so no compile; structural match is the bar):
- `generated/m3-kit/elm/m3e-icon-wifi-elm.figma.ts` → `M3e.Icon.view\n    [ M3e.Icon.name "wifi"\n    ]\n    []`
- a `-filled` icon file → `, M3e.Icon.filled True`
- both determinate progress files → the D2 examples verbatim.
- Also confirm the wc tree is BYTE-IDENTICAL to its pre-plan state: `git diff --stat generated/m3-kit/web-components/` → empty.
- Expected git diff on existing elm files: exactly one header line each (`elm-m3e @ 93d2edc` → `@ f1c7beb`). Anything more → stop, investigate.

- [ ] **Step 5: Check gate + full suite**

```bash
node src/cli.mjs check --profile m3-kit
pnpm test
```

Expected: check reports 0 drift, 0 orphans; full suite green (43-confirmed tracer untouched; byte-stable re-run test green).

- [ ] **Step 6: Commit**

```bash
git add generated/m3-kit/elm test/fixtures/elm-facts.progress.json test/elm-emitter.test.mjs
git commit -m "feat(elm): close emit coverage gaps — icon (141) + circular/linear progress; elm manifest at 43/43 parity"
```

**Acceptance:** all of Step 3-5 outputs exactly as stated; wc tree untouched; final manifest parity 43/43.

---

## Risks / blast radius (consolidated)

1. **Remeasure drift beyond the commit stamp** — mitigated by Task 2's hard additions-only gate + the button pin. If tripped: stop, surface to Jack (open question 1).
2. **~40 existing elm files change one header comment line** (`elmM3eCommit`) — benign, committed in Task 5; check.mjs is comment-tolerant; Code Connect republish of the elm label will carry the line.
3. **Regex-based Elm signature parsing** (Task 1) — same technique the builder already uses for Facts.elm/module heads; failure mode is concern-and-skip (never a guessed name), so worst case is a missing alias fact and a loud emitter no-op/throw, not a wrong emission. Hermetic tests pin the real signatures.
4. **`[ Kit.text "" ]` children on progress** — consistent with every existing no-text-prop emission; cosmetic wart, deferred (open question 2).
5. **Publish payload** — +145 files under the elm label. Publish is user-triggered; no automatic effect.
6. **The silent-hollow-surfaces footgun** — anyone running the OLD builder against the current checkout would silently wipe all surfaces. Task 1 removes it; until Task 1 lands, nobody should run the builder (note left here as the warning).

## Open questions — RESOLVED (see Decision amendments at top: A1→Q1, A2→Q2, A3→Q3)

1. **If Task 2's gate trips** (existing facts changed at f1c7beb beyond the stamp): accept the drift and re-bank, or pin a measurement worktree at the dangling `93d2edc`? Recommendation: accept-and-rebank only after seeing the concrete diff; the dangling commit is not durable provenance (a `git gc` can reap it).
2. **Progress children `[]` vs `[ Kit.text "" ]`**: emitting `[]` for ALL no-text-content components would be cleaner but rewrites existing banked files (blast radius beyond this plan). Ship `[ Kit.text "" ]` now for consistency, schedule a kit-wide `[]` cleanup separately?
3. **`elmM3eCommit` in every file header** couples all emitted elm bytes to the measurement commit. Keep (provenance-per-file, current behavior) or move to a single MANIFEST-level stamp in a future change?

## Self-review notes

- Spec coverage: 5 design questions → D1-D5; 3 gaps → Tasks 4 (icon), 1+2+3+5 (progress); verification per gap → D4 + per-task steps; blast radius → D5 + consolidated list; expected model tier on every task.
- Type consistency: `parseSetterSignature` return `{argType, phantomKey, enumValues}` used identically in Steps 6-9 of Task 1; `setterArgTypes` read in Task 3 exactly as written in Task 1; `emitIconTableEntry(entry, config)` signature matches both its test and `emitter.emit` call.
- The `measureGroupAliases` ctorPhantom extraction (Task 1 Step 9) re-derives the constructor annotation inline — implementers may factor it through `parseSetterSignature`'s annotation slice; keep the phantom-record-keys semantics exactly (keys with `: M3e.Token.Supported` in the constructor's first-arg record).
