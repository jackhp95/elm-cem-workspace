# Theme-Host View Restructure — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the `themed` helper and the wrapper `<div>` from `Shared.elm`'s `view`, hoisting the shell's layout classes and `dir` onto the `m3e-theme` host — **without** collapsing the two branches' distinct class lists, which is what makes the naive version clip full-viewport examples.

**Architecture:** The `if` selects a `( shellClass, children )` pair; one `M3e.theme` call consumes both, one `M3e.toHtml` conversion. The hoist depends on the CSS scoping rule that outer-tree author styles beat a shadow tree's `:host`, since `@m3e/web` sets `:host { display: contents; }` — so a regression test pins the shell's computed layout.

**Tech Stack:** Elm 0.19, elm-pages 3.5, Playwright (`docs/tests-browser/`), Tailwind 4.

**Spec:** `specs/2026-08-05-theme-host-view-restructure-design.md`

## Global Constraints

- **Blocked on `plans/2026-08-05-shared-elm-value-primitives.md`.** Both change `view`. Land the Values refactor first, so a layout regression here cannot be mistaken for a type-refactor bug.
- **The class list stays per branch.** The two branches do *not* share one. Hoisting the docs-shell list onto both is the regression this plan exists to avoid:

  | branch | class list |
  |---|---|
  | `/examples/*` | `bg-surface text-on-surface h-dvh overflow-y-auto` |
  | docs shell | `bg-surface text-on-surface grid h-dvh grid-rows-[auto_1fr] overflow-hidden` |

- **Both scroll-region comments must survive.** They are the only record of why the lists differ, and the original diff deleted both while making the change they warn against.
- `@m3e/web` sets `M3eThemeElement.styles = css\`:host { display: contents; }\`` (`docs/node_modules/@m3e/web/dist/theme.js:7092`). Tailwind's `.grid` overrides it because outer-tree normal declarations win over `:host` ones. This is correct per spec but is a real coupling: if a future `@m3e/web` marks that declaration `!important`, the host stops generating a box and the shell silently collapses to flow content with no compile error. Task 2 pins it.
- The two `class` attributes on `M3e.theme` are intentional and already the existing pattern — the density one is a computed arbitrary-property class.

---

### Task 1: Hoist onto the host with per-branch class lists

**Files:**
- Modify: `docs/app/Shared.elm` — `view` (`:286` onward), deleting the `themed` helper from its `let`

**Interfaces:**
- Consumes: `model.scheme`, `model.contrast`, `model.dir` as `Value` tokens (delivered by the Values plan); `densityClass : Float -> String` (`:560`); `skipLink`, `appShellBar`, `drawerShell`, `View.body`, `View.title`.
- Produces: nothing consumed elsewhere. `themed` is deleted and had no other callers.

- [ ] **Step 1: Read the current `view` in full before editing**

```bash
rg -n "^view :" -A 75 docs/app/Shared.elm
```

Confirm what is actually there — the Values plan has already changed `schemeAttr model.scheme` to `M3e.Theme.scheme model.scheme`, so the attribute list you are hoisting may differ from the spec's illustration.

- [ ] **Step 2: Rewrite `view`'s body**

Replace the `let` (deleting `themed`, keeping `absolutePath`) and the `body` field:

```elm
view sharedData page model toMsg pageView =
    let
        absolutePath : String
        absolutePath =
            UrlPath.toAbsolute page.path

        ( shellClass, children ) =
            if String.startsWith "/examples/" absolutePath then
                -- Individual example routes take the full viewport; they include their
                -- own m3e nav chrome, so skip the docs shell to avoid double-nav.
                -- `h-dvh overflow-y-auto` makes each example its OWN bounded scroll
                -- region: the document (html/body) is fixed + non-scrolling for the
                -- stable mobile URL bar, so a full-viewport example must scroll itself
                -- rather than the document, or tall demos would clip.
                ( "bg-surface text-on-surface h-dvh overflow-y-auto"
                , View.body pageView
                )

            else
                -- Fixed-height, non-scrolling shell: `h-dvh` fits the stable visible
                -- viewport (see style.css app-shell note) and the `auto_1fr` rows pin
                -- the app bar while the 1fr content row (the drawer + its <main>) is
                -- the ONE scroll region — keeps the mobile URL bar from collapsing on
                -- scroll.
                ( "bg-surface text-on-surface grid h-dvh grid-rows-[auto_1fr] overflow-hidden"
                , [ skipLink
                  , M3e.mapMsg toMsg appShellBar
                  , drawerShell toMsg model page sharedData.components (View.body pageView)
                  ]
                )
    in
    { title = View.title pageView
    , body =
        [ M3e.theme
            [ M3e.Theme.color model.seed
            , M3e.Theme.scheme model.scheme
            , M3e.Theme.contrast model.contrast
            , M3e.Theme.density model.density
            , TypedHtml.Attributes.dir model.dir
            , TypedHtml.Attributes.class shellClass

            -- The m3e-theme element's `density` prop/attr is NON-reactive, so the
            -- control has no effect unless we drive `--md-sys-density-scale` (which
            -- the m3e components read via density.calc) ourselves. Elm can't set a
            -- CSS custom property directly — `style` uses `node.style[key]=…` which
            -- ignores `--vars`, and `attribute "style"` gets clobbered on re-render —
            -- so it goes through a Tailwind arbitrary-property CLASS instead.
            , TypedHtml.Attributes.class (densityClass model.density)
            ]
            children
            |> M3e.toHtml
        ]
    }
```

- [ ] **Step 3: Compile**

Run: `npm --prefix docs run build:site`
Expected: PASS.

**If it fails with a type mismatch on `children`:** binding both branches to one name forces the two element rows to unify, which the previous two-`M3e.theme`-call structure did not require. Do **not** widen a signature or add a coercion to force it. Fall back to keeping two `M3e.theme` calls and sharing only the class-list selection — the wrapper `<div>` is still removed either way, which is the actual goal. Record which shape you ended up with in the commit message.

- [ ] **Step 4: Confirm the wrapper div and helper are gone**

```bash
rg -n "themed" docs/app/Shared.elm
rg -n "M3e.toHtml" docs/app/Shared.elm
```

Expected: no `themed`; exactly one `M3e.toHtml` (or two, if Step 3's fallback was taken).

- [ ] **Step 5: Format and review**

```bash
npm run check:format && npm --prefix docs run check:review
```

Expected: PASS.

- [ ] **Step 6: Verify both branches by hand — this is the whole point**

```bash
npm run dev
```

Two checks, and neither is optional:

1. **A docs route** (`/`): the app bar stays pinned while the content area scrolls. Scroll on a mobile viewport size and confirm the URL bar does not collapse.
2. **A full-viewport example route** (`/examples/shop` or any `/examples/*` with content taller than the viewport): it **scrolls** and does **not clip**. If the bottom of a tall example is unreachable, the per-branch class list was not applied and this is exactly the regression the plan exists to prevent.

- [ ] **Step 7: Confirm `dir` still flips the shell**

In the settings drawer, switch direction to RTL. The drawer and app bar must mirror. `dir` now sits on a `display: contents` host, so confirm it still inherits to descendants.

- [ ] **Step 8: Commit**

```bash
git add docs/app/Shared.elm
git commit -m "Hoist the shell layout onto the m3e-theme host, keeping per-branch classes"
```

---

### Task 2: Pin the `display: contents` coupling

**Files:**
- Create or modify: `docs/tests-browser/app-shell.spec.ts`

**Interfaces:**
- Consumes: the DOM structure from Task 1.
- Produces: nothing. This is the regression gate for the coupling Task 1 introduces.

Check for an existing shell spec first (`ls docs/tests-browser/`) and add to it rather than creating a near-duplicate.

- [ ] **Step 1: Write the failing test**

The assertion is on **computed** style, because that is the only thing that distinguishes "Tailwind won the cascade" from "`:host` won and the shell silently reflowed".

```ts
import { expect, test } from "@playwright/test";

// `@m3e/web` sets `:host { display: contents }` on m3e-theme. Since Task 1 hoisted
// the shell's layout classes onto that host, the shell only works because normal
// declarations from the OUTER tree beat a shadow tree's `:host` rules. That is
// correct per CSS Scoping, but the failure mode is severe and silent: if a future
// @m3e/web marks it `!important`, the host stops generating a box and the whole
// app shell collapses to flow content — no compile error, no console warning.
// These assertions turn that into a red test.
test("the docs shell host is a grid, not display:contents", async ({ page }) => {
  await page.goto("/");
  const host = page.locator("m3e-theme").first();
  await expect(host).toHaveCSS("display", "grid");
  await expect(host).toHaveCSS("overflow-y", "hidden");
});

test("a full-viewport example route owns its own scroll region", async ({ page }) => {
  await page.goto("/examples/shop");
  const host = page.locator("m3e-theme").first();
  // NOT the docs-shell grid: examples scroll themselves or tall demos clip.
  await expect(host).not.toHaveCSS("display", "grid");
  await expect(host).toHaveCSS("overflow-y", "auto");
});
```

Confirm `/examples/shop` exists (`ls docs/app/Route/Examples/`); substitute a real example route if not.

- [ ] **Step 2: Run it**

Run: `npm run test:browser -- app-shell`
Expected: PASS if Task 1 is correct. **If the first test reports `display: contents`,** Task 1's class list did not reach the host and the shell is broken — fix Task 1, not the test.

- [ ] **Step 3: Prove the test can actually fail**

Temporarily delete `TypedHtml.Attributes.class shellClass` from `view`, re-run, and confirm both tests go red. Then restore it. A regression test that cannot fail is not a regression test.

- [ ] **Step 4: Full gate**

```bash
npm run check && npm run test
```

Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add docs/tests-browser
git commit -m "Pin the app shell's computed layout on the m3e-theme host"
```

---

## Self-Review

**Spec coverage.** DOM node removed, `themed` removed, one `M3e.toHtml` → Task 1 Step 2. Per-branch class lists → Task 1 Step 2, verified in Step 6 and pinned in Task 2. Both scroll-region comments preserved → Task 1 Step 2 (they are in the code block verbatim). `display: contents` coupling made deliberate and pinned → Task 2. Unification risk on `children` with a specified fallback → Task 1 Step 3. `dir` on the host → Task 1 Step 7.

**Placeholder scan.** No TBDs. Task 1 Step 3's failure branch names the concrete fallback rather than "resolve type errors". Task 2 Step 1 flags the route-existence check instead of assuming `/examples/shop`.

**Type consistency.** `( shellClass, children )` destructured once and both parts used once. `densityClass : Float -> String` matches `:560`. `M3e.Theme.scheme` / `.contrast` take `Value` tokens, which holds only after the Values plan lands — stated as the blocking constraint.

**Ordering note.** Task 1 Step 1 deliberately re-reads `view` rather than trusting this plan's illustration, because the Values plan edits the same attribute list first.

---

## OUTCOME (executed 2026-08-05)

Task 1 landed a **third shape**, because this plan's Step 2 does not compile. The failure is
not the predicted `children` unification (which was a non-issue — `View.body` is fully
row-polymorphic); it is the attribute list. `M3e.Theme.Attrs` is a closed generated row with
no `dir`, and `rg -l "dir : Supported" src/M3e/` returns nothing library-wide — elm-cem emits
only `class`/`id`/`slot`/`style` as globals. See the BLOCKED section in
`specs/2026-08-05-theme-host-view-restructure-design.md`.

Landed: `( shellClass, children )` pair → one `M3e.theme` → one `M3e.toHtml`, `themed`
deleted, wrapper `<div>` **retained** carrying the class list and `dir`.

Commits `1cd6fca0` (Task 1) and `2c366b41` (Task 2). Both scroll-region comments survive;
per-branch class lists intact. Falsification passed: collapsing the two branches onto the
docs-shell list failed exactly the two example assertions and left both docs-shell
assertions green, with `/examples/shop` scrollable overflow going 477px → 0 (clipped).

Task 2's spec selector is `"m3e-theme.h-dvh, m3e-theme > .h-dvh"`, matching host or wrapper,
so it keeps holding unchanged if `dir` ever becomes typeable and the hoist lands.
