# Remove the `raw-html` Element — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Delete `js/raw-html.js` and the last `innerHTML` sink in the docs app, by generating each mined example's preview as structural Elm at build time.

**Architecture:** A new generator walks the mined example HTML with `linkedom` (already a dependency, already used for exactly this parse) and emits one Elm module per component containing `Html.node`/`attribute`/`Html.text` trees. `Doc.rawPreview` becomes a keyed lookup into generated Elm. Custom elements upgrade because Elm's virtual DOM creates them — the same mechanism the entire typed M3e library relies on.

**Tech Stack:** Node ESM (`docs/scripts/previews-gen/`), `linkedom`, Elm 0.19, elm-pages 3.5.

**Spec:** `specs/2026-08-05-remove-raw-html-element-design.md`

## Global Constraints

- **The generator is deliberately dumb.** Always `Html.node "<tag>"`, never a typed `M3e.*` helper. Mapping to typed setters is what makes the existing `examples-to-elm.mjs` degrade; a structural conversion cannot fail, and that property is the whole reason this change is possible.
- **Fail the build loudly** on `<script>`, `<style>`, `<link>`, or any `on*` attribute, naming the component and example. Do not strip them silently. This is the enforcement the `raw-html` SECURITY CONTRACT comment only ever requested.
- **Do not touch `examples-to-elm.mjs`, `config/examples.generated.json`, or the code-display panes.** The `HTML` surface tab must keep showing the original source string — that is a `<pre>`, not a DOM sink. Only the *live preview* changes.
- Text-node whitespace collapsing must match `docs/scripts/roundtrip/dom-diff.mjs`, so previews and the round-trip DOM diff agree rather than drifting.
- Preview lookup must be **total**: an out-of-range index yields an empty preview, never a crash. The generator asserts count parity with `docs/data/examples.json` so a mismatch fails the build instead.
- `docs/` uses **pnpm**; the repo root uses npm. `linkedom` is already a `docs` dependency — do not add anything.
- End state, greppable: `rg -n 'raw-html' --glob '!node_modules' .` and `rg -n 'innerHTML' js docs/scripts docs/*.ts` both return nothing.

**Environment note:** the `docs/node_modules` corruption and the missing `npm-run-all2` have been repaired, and Playwright browsers are installed — so `npm --prefix docs run build:site`, `npm run check`, and `npm run test:browser` all work now. Use them. The one gate still broken for unrelated reasons is `check:review`: `review/src/CodegenReviewConfig.elm` imports `NoRedundantAttributeEscape`, a rule that no longer exists in `elm-review-cem`. Do not try to fix that; note it if it blocks you.

---

### Task 1: Spike one component, and look at the output

**Files:**
- Create: `docs/scripts/previews-gen/html-to-elm.mjs`
- Create: `docs/scripts/previews-gen/html-to-elm.test.mjs`

**Interfaces:**
- Produces: `toStructuralElm(html, { indent }) -> string` — one Elm expression for one example's HTML. `elmModule(componentName, expressions) -> string`. Task 2 consumes both.

This task exists so the generated Elm gets eyeballed before a pipeline is built on top of it.

- [ ] **Step 1: Read the prior art first**

```bash
sed -n '1,60p' docs/scripts/roundtrip/dom-diff.mjs
rg -n "parseHTML" docs/scripts/examples-gen/lib/to-elm.mjs | head
```

You are reusing `linkedom`'s `parseHTML` the same way, and copying `dom-diff.mjs`'s whitespace-collapsing rule. Do not invent a second convention.

- [ ] **Step 2: Write the failing test**

`docs/scripts/previews-gen/html-to-elm.test.mjs`:

```js
import { test } from "node:test";
import assert from "node:assert/strict";
import { toStructuralElm, elmModule } from "./html-to-elm.mjs";

test("converts a nested custom-element tree structurally", () => {
  const html = `<m3e-app-bar size="medium">
  <span slot="title">Hi</span>
</m3e-app-bar>`;
  assert.equal(
    toStructuralElm(html, { indent: 4 }),
    `Html.node "m3e-app-bar"
        [ attribute "size" "medium" ]
        [ Html.node "span"
            [ attribute "slot" "title" ]
            [ Html.text "Hi" ]
        ]`,
  );
});

test("keeps an empty boolean attribute as an empty string", () => {
  // The corpus writes `filled=""`, and dom-diff.mjs canonicalises to that form.
  assert.match(toStructuralElm(`<m3e-icon filled=""></m3e-icon>`, { indent: 4 }), /attribute "filled" ""/);
});

test("escapes quotes and backslashes in text", () => {
  assert.match(toStructuralElm(`<span>a "b" \\ c</span>`, { indent: 4 }), /Html\.text "a \\"b\\" \\\\ c"/);
});

test("wraps multiple top-level siblings in a list-friendly fragment", () => {
  const out = toStructuralElm(`<m3e-button></m3e-button><m3e-button></m3e-button>`, { indent: 4 });
  // Two roots become one node with no wrapper element of its own.
  assert.match(out, /Html\.node "div"\n\s+\[\]/);
});

test("drops comments", () => {
  assert.doesNotMatch(toStructuralElm(`<span><!-- x -->y</span>`, { indent: 4 }), /x/);
});

test("FAILS LOUDLY on a script element", () => {
  assert.throws(() => toStructuralElm(`<script>alert(1)</script>`, { indent: 4 }), /script/i);
});

test("FAILS LOUDLY on an event-handler attribute", () => {
  assert.throws(() => toStructuralElm(`<span onclick="x()">y</span>`, { indent: 4 }), /onclick/i);
});

test("emits a compilable module shell", () => {
  const m = elmModule("AppBar", [`Html.text "a"`]);
  assert.match(m, /^module Gen\.Preview\.AppBar exposing \(previews\)/m);
  assert.match(m, /import Html exposing \(Html\)/);
  assert.match(m, /import Html\.Attributes exposing \(attribute\)/);
  assert.match(m, /previews : List \(Html msg\)/);
});
```

- [ ] **Step 3: Run it to verify it fails**

Run: `cd docs && node --test scripts/previews-gen/html-to-elm.test.mjs`
Expected: FAIL — cannot find module.

- [ ] **Step 4: Implement the converter**

`docs/scripts/previews-gen/html-to-elm.mjs`:

```js
// Converts mined example HTML into STRUCTURAL Elm — Html.node / attribute /
// Html.text — so the docs previews are real virtual-DOM nodes instead of an
// innerHTML injection through the `raw-html` custom element.
//
// Why structural and not typed: examples-to-elm.mjs maps to the typed M3e API and
// therefore DEGRADES (a top that will not compile is nulled and the example keeps
// only its HTML surface). That is precisely why the preview used to render the raw
// string. A structural conversion has no API to satisfy, so it cannot degrade —
// which is what makes deleting the sink possible.
//
// Custom elements upgrade fine: they upgrade whenever ANY DOM API creates them,
// which is how every other <m3e-*> on this site already works.

import { parseHTML } from "linkedom";

const BANNED_TAGS = new Set(["script", "style", "link", "iframe", "object", "embed"]);

const esc = (s) => s.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
const pad = (n) => " ".repeat(n);

// Same rule as docs/scripts/roundtrip/dom-diff.mjs: collapse runs of whitespace,
// and drop nodes that are whitespace-only, so previews and the round-trip diff agree.
const collapse = (s) => s.replace(/\s+/g, " ");

function node(el, indent, where) {
  const tag = el.tagName.toLowerCase();
  if (BANNED_TAGS.has(tag)) {
    throw new Error(
      `${where}: refusing to convert <${tag}>. The preview generator emits only inert ` +
        `structure; an executable element in the corpus is a corpus change that needs a human.`,
    );
  }

  const attrs = [];
  for (const { name, value } of [...el.attributes]) {
    if (/^on/i.test(name)) {
      throw new Error(
        `${where}: refusing to convert event-handler attribute '${name}' on <${tag}>. ` +
          `Previews must be inert.`,
      );
    }
    attrs.push(`attribute "${esc(name)}" "${esc(value ?? "")}"`);
  }

  const kids = children(el, indent + 4, where);

  const i = pad(indent);
  const attrStr = attrs.length ? `[ ${attrs.join("\n" + pad(indent + 4) + ", ")} ]` : "[]";
  const kidStr = kids.length
    ? `[ ${kids.join("\n" + pad(indent + 4) + ", ")}\n${pad(indent + 4)}]`
    : "[]";
  return `Html.node "${tag}"\n${i}    ${attrStr}\n${i}    ${kidStr}`;
}

function children(el, indent, where) {
  const out = [];
  for (const child of [...el.childNodes]) {
    if (child.nodeType === 8) continue; // comment
    if (child.nodeType === 3) {
      const t = collapse(child.textContent ?? "");
      if (t.trim() === "") continue;
      out.push(`Html.text "${esc(t)}"`);
      continue;
    }
    if (child.nodeType === 1) out.push(node(child, indent, where));
  }
  return out;
}

export function toStructuralElm(html, { indent = 4, where = "preview" } = {}) {
  const { document } = parseHTML(`<body>${html}</body>`);
  const roots = [...document.body.children];
  if (roots.length === 0) return `Html.text ""`;
  if (roots.length === 1) return node(roots[0], indent, where);

  // Multi-root examples (e.g. five button variants) become ONE node so `previews`
  // stays a flat List (Html msg). A bare <div> adds no styling of its own; the
  // showcase wrapper owns layout, exactly as it did for the raw-html element.
  const kids = roots.map((r) => node(r, indent + 4, where));
  return `Html.node "div"\n${pad(indent)}    []\n${pad(indent)}    [ ${kids.join(
    "\n" + pad(indent + 4) + ", ",
  )}\n${pad(indent + 4)}]`;
}

export function elmModule(componentName, expressions) {
  const body = expressions.length
    ? `    [ ${expressions.join("\n    , ")}\n    ]`
    : "    []";
  return `module Gen.Preview.${componentName} exposing (previews)

{-| GENERATED by docs/scripts/previews-gen/previews-to-elm.mjs — do not edit.

Structural renderings of this component's mined examples, in corpus order. Emitted
as \`Html.node\` rather than the typed API on purpose: the typed converter degrades,
a structural one cannot, and these only need to render.

@docs previews

-}

import Html exposing (Html)
import Html.Attributes exposing (attribute)


{-| This component's example previews, in corpus order.
-}
previews : List (Html msg)
previews =
${body}
`;
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `cd docs && node --test scripts/previews-gen/html-to-elm.test.mjs`
Expected: PASS, 8 tests. Adjust the indentation expectations in the test to whatever `elm-format` would produce if they disagree — but keep the *semantic* assertions (banned tags, `on*`, escaping, comment dropping) exactly as written.

- [ ] **Step 6: Spike one real component and READ the output**

```bash
cd docs && node -e '
import("./scripts/previews-gen/html-to-elm.mjs").then(async ({ toStructuralElm, elmModule }) => {
  const fs = await import("node:fs");
  const data = JSON.parse(fs.readFileSync("data/examples.json", "utf8"));
  // Find the AppBar entry — inspect the shape first if this key guess is wrong.
  const key = Object.keys(data).find((k) => /appbar/i.test(k));
  console.log("KEY:", key);
  const examples = (data[key].examples ?? data[key]).slice(0, 2);
  console.log(elmModule("AppBar", examples.map((e) => toStructuralElm(e.html, { indent: 6 }))));
});
'
```

Read the emitted module. It must be plausible Elm with balanced brackets. **Report this output before proceeding to Task 2** — this is the eyeball checkpoint the whole task exists for.

- [ ] **Step 7: Commit**

```bash
git add docs/scripts/previews-gen
git commit -m "Add a structural HTML-to-Elm converter for docs previews"
```

---

### Task 2: Generate every component's previews

**Files:**
- Create: `docs/scripts/previews-gen/previews-to-elm.mjs`
- Create (generated): `docs/gen/Gen/Preview/*.elm`
- Modify: `docs/elm.json` (add `gen` to `source-directories`)
- Modify: `docs/package.json` (`gen:previews`, add to the `gen` chain)
- Modify: `docs/scripts/check-data-drift.mjs` (gate the generated modules)

**Interfaces:**
- Consumes: `toStructuralElm`, `elmModule` from Task 1.
- Produces: `Gen.Preview.<Component>.previews : List (Html msg)` per component. Task 3 consumes them.

- [ ] **Step 1: Inspect the data shape before writing the orchestrator**

```bash
jq -r 'keys | .[0:5]' docs/data/examples.json
jq -r '(to_entries|.[0].value) | keys' docs/data/examples.json
```

Match the real shape. Do not assume `{ examples: [ { html } ] }` — confirm it.

- [ ] **Step 2: Write the orchestrator**

`docs/scripts/previews-gen/previews-to-elm.mjs`, modelled on `examples-to-elm.mjs`'s structure (read its top 40 lines first):

```js
import { readFileSync, writeFileSync, mkdirSync, rmSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { toStructuralElm, elmModule } from "./html-to-elm.mjs";

const HERE = dirname(fileURLToPath(import.meta.url));
const DOCS = resolve(HERE, "..", "..");
const OUT = resolve(DOCS, "gen", "Gen", "Preview");

const data = JSON.parse(readFileSync(resolve(DOCS, "data", "examples.json"), "utf8"));

rmSync(OUT, { recursive: true, force: true }); // so a removed component leaves no stale module
mkdirSync(OUT, { recursive: true });

let modules = 0;
let previews = 0;
for (const [component, entry] of Object.entries(data)) {
  const examples = entry.examples ?? [];
  const exprs = examples.map((ex, i) =>
    toStructuralElm(ex.html, { indent: 6, where: `${component}[${i}] "${ex.title ?? ""}"` }),
  );
  writeFileSync(resolve(OUT, `${component}.elm`), elmModule(component, exprs));
  modules += 1;
  previews += exprs.length;
}
console.log(`Wrote ${modules} preview module(s), ${previews} preview(s).`);
```

Note `rmSync` before regenerating: without it, deleting a component from the corpus would leave a stale module that still compiles, and the drift gate would not notice.

- [ ] **Step 3: Generate, format, and compile**

```bash
cd docs && node scripts/previews-gen/previews-to-elm.mjs
../node_modules/.bin/elm-format gen --yes
```

Add `"gen"` to `docs/elm.json`'s `source-directories` (it currently lists `app`, `src`, `.elm-pages`, `../src`, `vendor/elm-foundation`), then:

```bash
cd docs && ./node_modules/.bin/elm make $(find gen -name '*.elm' | tr '\n' ' ') --output=/dev/null
```

Expected: `Success!`. If `elm-format` reports a parse error, the converter's bracket layout is wrong — fix `html-to-elm.mjs`, not the generated file.

- [ ] **Step 4: Wire the gen chain and the drift gate**

`docs/package.json`:

```json
"gen:previews": "node scripts/previews-gen/previews-to-elm.mjs && elm-format gen --yes",
```

Add `gen:previews` to the `gen` chain after `gen:examples`, since it reads `data/examples.json`.

Then add the generated modules to `check-data-drift.mjs`'s `ARTIFACTS` allow-list and `gen:previews` to its `GEN_STEPS`, following the pattern the favicon work used (`git log -1 --format=%H -- docs/scripts/check-data-drift.mjs` will show you that commit).

- [ ] **Step 5: Prove the drift gate covers it**

```bash
printf '\n' >> docs/gen/Gen/Preview/*.elm 2>/dev/null || true
npm --prefix docs run check:drift; cd docs && git checkout gen
```

Expected: the gate names a preview module. If it does not, the generated output is ungated — fix it.

- [ ] **Step 6: Commit**

```bash
git add docs/scripts/previews-gen docs/gen docs/elm.json docs/package.json docs/scripts/check-data-drift.mjs
git commit -m "Generate structural Elm previews for every component's examples"
```

---

### Task 3: Switch the call site and delete the element

**Files:**
- Modify: `docs/src/Doc.elm` — delete `rawPreview` (`:65`), add `preview`
- Modify: `docs/src/Doc/Usage.elm` — `:170`
- Modify: `docs/index.ts` — remove the `raw-html` import
- Delete: `js/raw-html.js`
- Modify: `docs/composition.md`, `docs/style.css`, `docs/tests-browser/usage.spec.ts` as needed

**Interfaces:**
- Consumes: `Gen.Preview.<Component>.previews`.
- Produces: `Doc.preview : Html msg -> Element accepts admittedBy msg`.

- [ ] **Step 1: Replace `rawPreview` with `preview` in `Doc.elm`**

```elm
{-| A live preview of one mined example, as generated structural Elm
(`Gen.Preview.*`). Previously this injected an HTML string through the `raw-html`
custom element; it is now ordinary virtual DOM, so the embedded `<m3e-*>` elements
upgrade the same way every other component on this site does — and there is no
`innerHTML` sink left in the docs app.
-}
preview : Html msg -> Element accepts admittedBy msg
preview html =
    M3e.Unsafe.fromHtml html
        |> List.singleton
        |> TypedHtml.div
            -- Plain block flow, matching matraic's `.showcase` (which sets no
            -- flex): each component uses its own `display`, so inline components
            -- (buttons/chips) flow and wrap while full-width components (linear
            -- progress, sliders, dividers, text fields) fill the row. No flex
            -- row — that collapses width-less components to min-content. No
            -- overflow clipping either: an escaping menu/tooltip must be free to
            -- leave the card, and `overflow-x-auto` would force a spurious
            -- vertical scrollbar off the ~4px state-layer bleed.
            [ TA.class "max-w-full py-2" ]
```

Check `M3e.Unsafe.fromHtml`'s real signature before committing to this shape — if it already returns an `Element`, the wrapper is simpler. Update `Doc.elm`'s `module ... exposing` list: `rawPreview` out, `preview` in.

- [ ] **Step 2: Switch the `Usage.elm` call site**

`Doc/Usage.elm:170` currently reads `, Doc.showcase (Doc.rawPreview ex.html)`. Replace with a total lookup by corpus index:

```elm
        , Doc.showcase (Doc.preview (previewAt index))
```

and add, near `exampleBlock`:

```elm
{-| This component's generated preview for `index`, or an empty node if the corpus
and the generated modules ever disagree. Total by construction — a missing preview
must not crash the page, and the generator asserts count parity so a mismatch fails
the build instead.
-}
previewAt : Int -> Html msg
previewAt index =
    Gen.Preview.<Component>.previews
        |> List.drop index
        |> List.head
        |> Maybe.withDefault (Html.text "")
```

**`Usage.elm` is one module serving every component**, so it cannot import a single `Gen.Preview.<Component>`. Read how it resolves the current component first (`rg -n "component|moduleName" docs/src/Doc/Usage.elm | head -20`). If it is parameterised by name, the generator must also emit a **dispatch module** — `Gen.Preview.previewsFor : String -> List (Html msg)` with a `case` over component names, defaulting to `[]`. Add that to `previews-to-elm.mjs` and import only the dispatch module here. Report which shape the codebase forced.

- [ ] **Step 3: Compile and check**

```bash
cd docs && npm run build:site
cd .. && npm run check:format
```

Expected: `build:site` succeeds (the environment is repaired). `check:review` will still fail on the pre-existing `NoRedundantAttributeEscape` import — ignore that one.

- [ ] **Step 4: Delete the element and its references**

```bash
git rm js/raw-html.js
```

Remove `import "../js/raw-html.js";` from `docs/index.ts`. Then find every remaining mention and clear it:

```bash
rg -n 'raw-html' --glob '!node_modules' --glob '!dist' .
```

Expected remaining hits are prose in `docs/composition.md`, possibly a `style.css` rule, and possibly `docs/tests-browser/usage.spec.ts`. Update each: the prose should now describe the generated-preview seam, and any spec asserting on `raw-html` should assert the preview renders real elements instead.

- [ ] **Step 5: Prove the sink is gone**

```bash
rg -n 'raw-html' --glob '!node_modules' --glob '!dist' . || echo "no raw-html anywhere"
rg -n 'innerHTML|setHTMLUnsafe|insertAdjacentHTML' js docs/scripts docs/*.ts || echo "no innerHTML sink"
```

Both must be empty. This is the deliverable.

- [ ] **Step 6: Verify the previews actually render**

```bash
npm run test:browser
```

Playwright works now. Then open a few component Usage pages on `npx elm-pages dev` and confirm the previews are **live, themed components** — not empty boxes and not unstyled text. Spot-check at least one multi-root example (five button variants) and one with a slotted layout (`m3e-app-bar`). Compare against the pre-change rendering:

```bash
git stash && npm run dev   # observe, then restore
```

- [ ] **Step 7: Run the round-trip gate**

```bash
npm run test:roundtrip
```

This compares mined HTML against rendered output and is the natural check that the structural conversion is faithful. Report its result explicitly.

- [ ] **Step 8: Commit**

```bash
git add -u && git add docs/src docs/index.ts docs/composition.md
git commit -m "Delete the raw-html element; previews are generated structural Elm"
```

---

## Self-Review

**Spec coverage.** Structural generator with the dumb-conversion rationale → Task 1. Loud failure on `<script>`/`on*` → Task 1 Step 4, tested Step 2. Whitespace rule shared with `dom-diff.mjs` → Task 1 Step 4 (`collapse`). Generated modules, gen chain, drift gate → Task 2. Total lookup and count parity → Task 2 Step 2 + Task 3 Step 2. Call-site switch, element deletion, prose cleanup → Task 3. Greppable end state → Task 3 Step 5. Code panes untouched → Global Constraints.

**Placeholder scan.** One deliberate unknown, flagged rather than hidden: Task 3 Step 2 does not know whether `Usage.elm` is parameterised by component, so it specifies both shapes and tells the implementer to read the file and report which. That is a read-then-decide instruction with both branches specified, not a TODO.

**Type consistency.** `toStructuralElm(html, {indent, where}) -> string` and `elmModule(name, exprs) -> string` are used identically in Tasks 1 and 2. `previews : List (Html msg)` is what Task 3's `previewAt` consumes via `List.drop`/`List.head`. `Doc.preview : Html msg -> Element …` matches the `Doc.showcase` argument that `rawPreview` used to supply.

**Risk carried into execution.** The `Doc.preview` body assumes `M3e.Unsafe.fromHtml : Html msg -> Element …`; Step 1 says to verify before committing to the shape. Note the irony worth watching: this change removes an `innerHTML` sink but still crosses the Html→Element boundary via `M3e.Unsafe.fromHtml`. That is a *structural* escape, not a string-parsing one, and it is the same escape `Doc.elm` already used — but if it can be avoided entirely, prefer that and say so.
