# Icon Registry Seam Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Render the GitHub mark through `m3e-icon`'s own icon registry instead of injecting a raw SVG string through the `raw-html` `innerHTML` element, and narrow `raw-html.js` to its one legitimate caller.

**Architecture:** A build step reads `config/icons.json`, resolves each Iconify id from the offline `@iconify-json/*` packages, and emits a generated module of `registerIcon(name, variant, data)` calls that `docs/index.ts` imports as a side effect. Elm then uses the ordinary typed `M3e.Icon.name` setter, with no escape hatch.

**Tech Stack:** Node ESM build scripts (`docs/scripts/`), `@iconify/utils` + `@iconify-json/*` (dev deps, offline), `@m3e/web/icon`, Vite, pnpm (in `docs/`), Elm.

**Spec:** `specs/2026-08-05-icon-registry-seam-design.md`

## Global Constraints

- Icon data comes from **offline npm packages** (`@iconify-json/mdi`, `@iconify-json/material-symbols`) as `devDependencies` in `docs/`. Nothing is fetched from the Iconify CDN at build time or at runtime.
- `docs/` uses **pnpm** (`docs/pnpm-lock.yaml`, no `package-lock.json`). Use `pnpm add -D` there. The repo root uses npm; run scripts with the existing `npm --prefix docs run …` form.
- `IconRegistry.addIcon` accepts **one path `d` per fill state**. Multi-element Iconify bodies must **fail the build loudly**, naming the icon and its id. Never keep just the first path.
- Always emit the **object** form `{ viewBox, path }`. Passing a bare string makes `addIcon` assume the Material viewBox `0 -960 960 960` and skip viewBox validation, silently mis-scaling any non-Material icon.
- `variant` is the Material style (`"outlined" | "rounded" | "sharp"`, default `"outlined"`). `fillSet.outlined` / `fillSet.filled` are the *fill states*. They are unrelated; do not conflate them.
- The generator must itself apply m3e's two validation patterns so a bad icon is a build error, not a runtime `throw` that blanks the app bar:
  - `PATH_DATA_PATTERN = /^[MmLlHhVvCcSsQqTtAaZz0-9.,\s-]+$/`
  - `VIEW_BOX_PATTERN = /^-?\d+(\.\d+)?\s+-?\d+(\.\d+)?\s+-?\d+(\.\d+)?\s+-?\d+(\.\d+)?$/`
- **Do not delete `js/raw-html.js`.** Its other caller, `Doc.rawPreview`, is a real docs feature. Narrow it.
- Retiring the 3.9MB `material-symbols-outlined.woff2` is **out of scope**. 252 distinct icon names appear across `config/examples.*.json`; any unregistered name regresses to a visible text label.

---

### Task 1: Verify the icon data is usable before building anything

**Files:**
- Modify: `docs/package.json` (add two `devDependencies`)

**Interfaces:**
- Produces: confirmation that `mdi:github` and `material-symbols:palette` are single-path and pass m3e's validators. Tasks 2–4 and the favicon plan both depend on this being true.

This task exists because the whole design rests on an unverified assumption. Find out first.

- [ ] **Step 1: Add the offline icon-set packages**

```bash
cd docs && pnpm add -D @iconify-json/mdi @iconify-json/material-symbols @iconify/utils
```

- [ ] **Step 2: Write a throwaway probe and run it**

```bash
cd docs && node -e '
import("@iconify/utils").then(async ({ getIconData, iconToSVG }) => {
  const sets = {
    mdi: (await import("@iconify-json/mdi/icons.json", { with: { type: "json" } })).default,
    "material-symbols": (await import("@iconify-json/material-symbols/icons.json", { with: { type: "json" } })).default,
  };
  for (const id of ["mdi:github", "material-symbols:palette"]) {
    const [prefix, name] = id.split(":");
    const data = getIconData(sets[prefix], name);
    const { body, attributes } = iconToSVG(data);
    const paths = body.match(/<path\b/g) || [];
    const others = body.replace(/<path\b[^>]*\/?>/g, "").match(/<[a-z]/g) || [];
    console.log(id, "| viewBox:", attributes.viewBox, "| paths:", paths.length, "| other elements:", others.length);
    console.log("   body:", body.slice(0, 120));
  }
});
'
```

Expected: `paths: 1` and `other elements: 0` for both, with a viewBox matching `VIEW_BOX_PATTERN`.

- [ ] **Step 3: Decide based on what you actually saw**

- Both single-path → continue to Task 2.
- Either is multi-element → **stop and report**. The `addIcon` single-path constraint is real; the options are picking a different Iconify id (e.g. `simple-icons:github`) or extending the design to a slotted-SVG approach, and that is a spec decision, not an implementation one.

- [ ] **Step 4: Commit the dependency addition**

```bash
git add docs/package.json docs/pnpm-lock.yaml
git commit -m "Add offline Iconify icon-set packages for the icon registry seam"
```

---

### Task 2: The icon config and generator

**Files:**
- Create: `config/icons.json`
- Create: `docs/scripts/icons-gen/icons-to-js.mjs`
- Create: `docs/scripts/icons-gen/icons-to-js.test.mjs`
- Create (generated): `docs/gen/icons.js`
- Modify: `docs/package.json` (add `gen:icons` to the `gen` chain, add `test:icons-gen`)

**Interfaces:**
- Consumes: `@iconify/utils`' `getIconData` / `iconToSVG`; the icon-set JSON from Task 1.
- Produces: `docs/gen/icons.js`, a side-effect module calling `registerIcon` from `@m3e/web/icon` for every entry in `config/icons.json`, registered across all three variants. Task 3 imports it; the favicon plan reuses `resolveIcon`.
- Produces (exported for test and for the favicon plan): `resolveIcon(sets, id) -> { viewBox, path }`, throwing on multi-element bodies or validation failure.

- [ ] **Step 1: Write the config**

`config/icons.json`:

```json
{
  "github": "mdi:github"
}
```

- [ ] **Step 2: Write the failing test**

`docs/scripts/icons-gen/icons-to-js.test.mjs`:

```js
import { test } from "node:test";
import assert from "node:assert/strict";
import { resolveIcon } from "./icons-to-js.mjs";

// A minimal fake icon set — no network, no dependency on real Iconify content.
const sets = {
  fake: {
    prefix: "fake",
    width: 24,
    height: 24,
    icons: {
      ok: { body: '<path d="M4 4h16v16H4z"/>' },
      multi: { body: '<path d="M0 0h1v1H0z"/><circle cx="5" cy="5" r="2"/>' },
      twopaths: { body: '<path d="M0 0h1v1H0z"/><path d="M2 2h1v1H2z"/>' },
      badchars: { body: '<path d="M0 0 L1e2 5"/>' },
    },
  },
};

test("resolves a single-path icon to viewBox + path", () => {
  assert.deepEqual(resolveIcon(sets, "fake:ok"), { viewBox: "0 0 24 24", path: "M4 4h16v16H4z" });
});

test("rejects a body with a non-path element, naming the icon and id", () => {
  assert.throws(() => resolveIcon(sets, "fake:multi"), /fake:multi.*single path/is);
});

test("rejects a body with two paths rather than silently keeping the first", () => {
  assert.throws(() => resolveIcon(sets, "fake:twopaths"), /fake:twopaths.*single path/is);
});

test("rejects path data m3e's allowlist would reject at runtime", () => {
  // `e` (scientific notation) is not in PATH_DATA_PATTERN, so addIcon would throw
  // in the browser. Catch it at build time instead.
  assert.throws(() => resolveIcon(sets, "fake:badchars"), /fake:badchars.*path data/is);
});

test("rejects an unknown id", () => {
  assert.throws(() => resolveIcon(sets, "fake:nope"), /fake:nope/);
});
```

- [ ] **Step 3: Run it to verify it fails**

Run: `cd docs && node --test scripts/icons-gen/icons-to-js.test.mjs`
Expected: FAIL — cannot find module `./icons-to-js.mjs`.

- [ ] **Step 4: Write the generator**

`docs/scripts/icons-gen/icons-to-js.mjs`:

```js
// Generates docs/gen/icons.js — registerIcon() calls for every entry in
// config/icons.json, resolved from the OFFLINE @iconify-json/* packages.
//
// Why this exists: m3e-icon renders a registered icon from IconRegistry and
// otherwise falls back to a text div that the Material Symbols ligature font
// turns into a glyph. Non-Material marks (the GitHub logo) have no ligature, so
// they used to be smuggled in as a raw SVG string through the `raw-html`
// innerHTML element. registerIcon is the library's own extension point and is a
// VALIDATED channel: addIcon character-allowlists the path data and lit binds it
// as an attribute, so there is no markup parsing at all.
//
// Constraints this file enforces, all of them load-bearing:
//   * addIcon takes ONE path `d` per fill state. A multi-element Iconify body
//     cannot be represented, so we FAIL rather than drop geometry.
//   * Always emit the OBJECT form { viewBox, path }. The string form makes
//     addIcon assume the Material viewBox "0 -960 960 960" and skip viewBox
//     validation, which silently mis-scales anything not on that grid.
//   * Apply m3e's own regexes here, so a bad icon is a build error rather than a
//     runtime throw that blanks the app bar.

import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { getIconData, iconToSVG } from "@iconify/utils";

const HERE = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(HERE, "..", "..", "..");

// Copied verbatim from @m3e/web dist/icon.js:13-15. If a future @m3e/web loosens
// these, this generator becomes stricter than necessary — never looser.
const PATH_DATA_PATTERN = /^[MmLlHhVvCcSsQqTtAaZz0-9.,\s-]+$/;
const VIEW_BOX_PATTERN = /^-?\d+(\.\d+)?\s+-?\d+(\.\d+)?\s+-?\d+(\.\d+)?\s+-?\d+(\.\d+)?$/;

const VARIANTS = ["outlined", "rounded", "sharp"];

export function resolveIcon(sets, id) {
  const [prefix, name] = id.split(":");
  const set = sets[prefix];
  if (!set) throw new Error(`Unknown icon set '${prefix}' for id '${id}'.`);

  const data = getIconData(set, name);
  if (!data) throw new Error(`Icon '${id}' is not in the '${prefix}' set.`);

  const { body, attributes } = iconToSVG(data);

  const paths = [...body.matchAll(/<path\b[^>]*\bd="([^"]+)"[^>]*\/?>/g)];
  const remainder = body.replace(/<path\b[^>]*\/?>/g, "").trim();
  if (paths.length !== 1 || remainder !== "") {
    throw new Error(
      `Icon '${id}' does not reduce to a single path (${paths.length} path(s)` +
        `${remainder ? `, plus: ${remainder.slice(0, 80)}` : ""}). ` +
        `m3e's IconRegistry.addIcon takes one path 'd' per fill state, so this ` +
        `icon cannot be registered without dropping geometry. Pick a different ` +
        `Iconify id or change the approach — do not keep the first path.`,
    );
  }

  const path = paths[0][1];
  const viewBox = attributes.viewBox;

  if (!VIEW_BOX_PATTERN.test(viewBox)) {
    throw new Error(`Icon '${id}' has a viewBox m3e will reject: '${viewBox}'.`);
  }
  if (!PATH_DATA_PATTERN.test(path)) {
    throw new Error(
      `Icon '${id}' has path data m3e will reject (addIcon allowlists only path ` +
        `commands, digits, '.', ',', '-' and whitespace — note that scientific ` +
        `notation is excluded): ${path.slice(0, 80)}`,
    );
  }

  return { viewBox, path };
}

export function loadSets(prefixes) {
  const sets = {};
  for (const p of prefixes) {
    sets[p] = JSON.parse(
      readFileSync(resolve(HERE, "..", "..", "node_modules", `@iconify-json/${p}/icons.json`), "utf8"),
    );
  }
  return sets;
}

export function generate(config, sets) {
  const lines = [
    "// GENERATED by docs/scripts/icons-gen/icons-to-js.mjs — do not edit.",
    "// Source of truth: config/icons.json",
    'import { registerIcon } from "@m3e/web/icon";',
    "",
  ];
  for (const [name, id] of Object.entries(config)) {
    const { viewBox, path } = resolveIcon(sets, id);
    lines.push(`// ${name} <- ${id}`);
    lines.push(`{`);
    lines.push(`  const data = ${JSON.stringify({ viewBox, path })};`);
    // Registered for every variant: a brand mark has no Material style, and
    // renderIcon keys on variant, so registering only "outlined" would make the
    // mark vanish for any call site that asks for variant="rounded".
    lines.push(`  for (const variant of ${JSON.stringify(VARIANTS)}) {`);
    lines.push(`    registerIcon(${JSON.stringify(name)}, variant, { outlined: data, filled: data });`);
    lines.push(`  }`);
    lines.push(`}`);
    lines.push("");
  }
  return lines.join("\n");
}

// Run as a script (not when imported by the test).
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const config = JSON.parse(readFileSync(resolve(REPO, "config", "icons.json"), "utf8"));
  const prefixes = [...new Set(Object.values(config).map((id) => id.split(":")[0]))];
  const out = resolve(REPO, "docs", "gen", "icons.js");
  mkdirSync(dirname(out), { recursive: true });
  writeFileSync(out, generate(config, loadSets(prefixes)));
  console.log(`Wrote ${out} (${Object.keys(config).length} icon(s)).`);
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `cd docs && node --test scripts/icons-gen/icons-to-js.test.mjs`
Expected: PASS, 5 tests.

- [ ] **Step 6: Generate for real and read the output**

Run: `cd docs && node scripts/icons-gen/icons-to-js.mjs && cat gen/icons.js`
Expected: a `registerIcon("github", variant, …)` loop with an explicit `viewBox` and a path that visibly starts with a path command.

- [ ] **Step 7: Wire into the gen chain and the test chain**

In `docs/package.json`, add `gen:icons` and put it in the `gen` chain:

```json
"gen": "run-s gen:vendor gen:icons gen:reference gen:examples-config gen:examples-surfaces gen:examples-barrel gen:examples gen:samples",
"gen:icons": "node scripts/icons-gen/icons-to-js.mjs",
"test:icons-gen": "node --test scripts/icons-gen/*.test.mjs",
```

Then add `test:icons-gen` to the root `package.json`'s `test:fast`:

```json
"test:fast": "run-p test:elm test:examples-gen test:samples-gen test:roundtrip test:icons-gen",
"test:icons-gen": "npm --prefix docs run test:icons-gen",
```

- [ ] **Step 8: Confirm the generated file is tracked**

```bash
git check-ignore -v docs/gen/icons.js || echo "not ignored — will be committed"
```

If `docs/gen` is gitignored, the drift-check convention in this repo (committed generated output, `check:drift`) does not apply to it — add an exception for `docs/gen/icons.js` so a stale registration is visible in review.

- [ ] **Step 9: Commit**

```bash
git add config/icons.json docs/scripts/icons-gen docs/gen/icons.js docs/package.json package.json
git commit -m "Generate m3e icon registrations from offline Iconify sets"
```

---

### Task 3: Use the registry from Elm and delete the raw-SVG detour

**Files:**
- Modify: `docs/index.ts:5-9` (add the side-effect import)
- Modify: `docs/app/Shared.elm` — `githubLink` (`:420`), delete `githubMark` (`:431`), delete `githubMarkSvg` (`:440`)

**Interfaces:**
- Consumes: `docs/gen/icons.js` from Task 2, which registers the name `"github"`.
- Produces: nothing downstream. This is the payoff task.

- [ ] **Step 1: Import the generated registrations**

In `docs/index.ts`, beside the existing side-effect imports. It must come **after** `@m3e/web/all` so the element is defined first, though `IconRegistry.observe` means late registration also works.

```ts
import "@m3e/web/all";
import "./gen/icons.js";
import "../js/avt-snackbar.js";
import "../js/raw-html.js";
import "../js/slide-panels.js";
import "./style.css";
```

- [ ] **Step 2: Rewrite `githubLink` to use the typed setter**

```elm
{-| The GitHub link. The mark is registered into `m3e-icon`'s own icon registry at
startup (`docs/gen/icons.js`, generated from `config/icons.json`), so this is an
ordinary typed icon — no raw SVG string and no `M3e.Unsafe` escape. Registry-rendered
icons are `<svg><path/></svg>` inside `m3e-icon`, so the mark still inherits the app
bar's on-surface foreground and adapts to light/dark.
-}
githubLink : Element { s | iconButton : M3e.Kind.Brand } admittedBy Msg
githubLink =
    M3e.iconButton
        [ Aria.label "GitHub repository"
        , M3e.Attributes.href "https://github.com/jackhp95/elm-m3e"
        , M3e.Attributes.target "_blank"
        , M3e.Attributes.rel "noreferrer noopener"
        ]
        [ M3e.icon [ M3e.Icon.name "github" ] [] ]
```

- [ ] **Step 3: Delete `githubMark` and `githubMarkSvg`**

Delete both declarations entirely, including the long doc comment on `githubMark`'s predecessor that explains the `raw-html` routing — it documents a mechanism that no longer exists here.

- [ ] **Step 4: Remove now-unused imports**

```bash
npm --prefix docs run check:review
```

`elm-review` will name any import that became unused (likely `Html.node` and `attribute`, if `Shared.elm` used them only for `githubMark`). Remove exactly what it names. Do not guess — other code in this file may still use them.

- [ ] **Step 5: Compile**

Run: `npm --prefix docs run build:site`
Expected: PASS.

- [ ] **Step 6: Confirm the detour is gone**

```bash
rg -n "githubMarkSvg|githubMark" docs/app/Shared.elm
rg -c "M3e.Unsafe.fromHtml" docs/app/Shared.elm
rg -n "raw-html" docs/app/Shared.elm docs/src/Doc.elm
```

Expected: no matches for the first; one fewer `M3e.Unsafe.fromHtml` than before; `raw-html` referenced only from `docs/src/Doc.elm`.

- [ ] **Step 7: Verify in a browser that the icon actually renders**

```bash
npm run dev
```

The app-bar GitHub button must show a **vector mark**. If it shows the literal text `github`, registration did not happen — that is `m3e-icon`'s unregistered-name fallback, and it is the exact failure this task must not ship. Check the console for an `addIcon` throw. Toggle light/dark and confirm the mark inverts with the app bar.

- [ ] **Step 8: Commit**

```bash
git add docs/index.ts docs/app/Shared.elm
git commit -m "Render the GitHub mark through m3e's icon registry, not raw-html"
```

---

### Task 4: Narrow the `raw-html` security contract

**Files:**
- Modify: `js/raw-html.js:1-14`
- Modify: `docs/tests-browser/usage.spec.ts` (only if it asserts on the GitHub mark; check first)

**Interfaces:**
- Consumes: Task 3 having removed the second caller.
- Produces: nothing. Documentation truth-up.

- [ ] **Step 1: Check whether the browser suite references the mark**

```bash
rg -n "github|raw-html" docs/tests-browser/usage.spec.ts
```

If a test asserts the GitHub mark arrives via `raw-html`, it now tests a mechanism that is gone — update it to assert on `m3e-icon[name="github"]` instead.

- [ ] **Step 2: Rewrite the contract comment to match reality**

Replace the header of `js/raw-html.js`. The change: one caller, not two; and the trusted source is generated data, not a hand-pasted literal.

```js
// <raw-html content="..."> — renders its `content` attribute as DOM so the
// embedded <m3e-*> custom elements upgrade in place. Used by the docs Usage
// previews (Doc.rawPreview). Elm can't set innerHTML via a property under
// elm-pages hydration, so a custom element owns its own subtree instead.
//
// SECURITY CONTRACT: `content` MUST be build-time-constant, author-controlled
// HTML only. This element has exactly ONE caller — Doc.rawPreview, fed by
// docs/data/examples.json, generated at build time from config/*.rich.json.
// Never from user input, URL/query params, or any string fetched or derived at
// runtime. Do NOT route untrusted input here: parsing an arbitrary HTML string
// into the live DOM is a DOM-XSS sink (inline event handlers, <img onerror>,
// etc. execute on adoption). If a future caller needs to render untrusted HTML,
// sanitize it (e.g. DOMPurify) BEFORE it reaches this element, or upgrade this
// element to sanitize internally.
//
// If you are here to render an ICON, you are in the wrong place: register it via
// config/icons.json and m3e's IconRegistry (docs/gen/icons.js), which is a
// validated path-data channel rather than an innerHTML sink.
```

- [ ] **Step 3: Confirm the caller count claim is true**

```bash
rg -n 'raw-html' --glob '!node_modules' --glob '!dist' .
```

Expected: `js/raw-html.js` itself, `docs/index.ts`'s import, `docs/src/Doc.elm`'s one call, and prose in `docs/composition.md` / `docs/style.css`. **No** second Elm caller. If the comment's "exactly ONE caller" claim is not true, fix the comment rather than shipping a false contract.

- [ ] **Step 4: Full gate**

```bash
npm run check && npm run test
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add js/raw-html.js docs/tests-browser
git commit -m "Narrow the raw-html security contract to its one remaining caller"
```

---

## Self-Review

**Spec coverage.** Offline icon-set sourcing → Task 1. `config/icons.json` + generator + `registerIcon` emission across all three variants + object-form viewBox → Task 2. Single-path hard constraint with loud failure → Task 2 Step 4, tested in Step 2. Build-time application of m3e's own regexes → Task 2 Step 4, tested. Gen-chain and test-chain wiring → Task 2 Step 7. Elm switch to the typed setter and deletion of `githubMark`/`githubMarkSvg`/one `M3e.Unsafe.fromHtml` → Task 3. `raw-html` narrowed not deleted, contract updated → Task 4. Font retirement stays out of scope → Global Constraints.

**Placeholder scan.** No TBDs. Task 1 is a genuine verification gate with a specified stop condition rather than an assumption. Task 3 Step 4 delegates import removal to `elm-review`'s actual output instead of guessing which imports die, which is the honest instruction.

**Type consistency.** `resolveIcon(sets, id) -> { viewBox, path }` is defined in Task 2 Step 4 and used with that exact shape in the test (Step 2), in `generate`, and by the favicon plan. `loadSets(prefixes) -> Record<prefix, set>` matches `resolveIcon`'s first parameter. `VARIANTS` is the `IconVariant` union from `dist/icon.js`, not the fill-state keys.

**Risk carried into execution.** Task 1 may falsify the single-path assumption for `mdi:github`. That is why it is Task 1 with an explicit stop-and-report, rather than a surprise discovered in Task 3.
