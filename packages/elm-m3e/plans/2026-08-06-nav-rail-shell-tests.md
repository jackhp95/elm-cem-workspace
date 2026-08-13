# Nav Rail Shell Tests — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `app-shell.spec.ts` to pin the shell contract as it exists after both `plans/2026-08-06-nav-rail-layout.md` and `plans/2026-08-06-nav-rail-tree-toc.md` have landed — the outer wrapper is now `flex-row` (rail | main-column), not `flex-col` directly under `m3e-theme`.

**Architecture:** No production code changes in this plan — test-only. Existing granular coverage (`nav-rail.spec.ts` for rail/bar behavior, `nav.spec.ts` for the tree's category grouping, `toc.spec.ts` for TOC jump-links) already covers the pieces; this plan's job is only to fix `app-shell.spec.ts`'s selector, which currently targets a DOM shape that no longer exists after Plan 1.

**Tech Stack:** Playwright (`docs/tests-browser/`).

**Spec:** `specs/2026-08-06-nav-rail-migration-design.md`

## Global Constraints

- **Blocked on both `plans/2026-08-06-nav-rail-layout.md` and `plans/2026-08-06-nav-rail-tree-toc.md`.** This plan asserts the combined end state of both.
- **Do not duplicate coverage.** `nav-rail.spec.ts`, `nav.spec.ts`, and `toc.spec.ts` already assert rail navigation, category grouping, and TOC jump-links respectively — this plan only fixes `app-shell.spec.ts`'s now-broken selector and confirms the pieces compose correctly together (rail + tree + content + TOC all present and correctly nested on one real page), not re-testing each piece in isolation again.
- The static site must be rebuilt (`npm run build:site`) and re-served (`PORT=1239 npm run serve`, after `pkill -f "PORT=1239"`) before any Playwright run.

---

### Task 1: Fix `app-shell.spec.ts`'s selector for the new `flex-row` wrapper

**Files:**
- Modify: `docs/tests-browser/app-shell.spec.ts`

**Interfaces:** none — this task only changes test code.

- [ ] **Step 1: Rebuild, serve, and run the current suite to see the actual failure**

```bash
cd docs
npm run build:site
pkill -f "PORT=1239" 2>/dev/null; (PORT=1239 npm run serve > /tmp/serve.log 2>&1 &); sleep 2
BASE_URL=http://localhost:1239 npx playwright test tests-browser/app-shell.spec.ts
```

Expected: FAIL on "the docs shell is a fixed-viewport flex column with one scroll region" — its `DOCS_SHELL` locator (`m3e-theme > div.h-dvh.flex.flex-col`) no longer matches, because Plan 1 changed the outer div's classes to `h-dvh flex flex-row` and moved the `flex-col` div one level deeper (`flex flex-1 flex-col min-w-0`, no longer carrying `h-dvh`).

- [ ] **Step 2: Update the `DOCS_SHELL` selector and its assertions**

In `docs/tests-browser/app-shell.spec.ts`, the current constant and first test:

```ts
const DOCS_SHELL = "m3e-theme > div.h-dvh.flex.flex-col";
```

Replace with two named selectors — the outer viewport-fixed wrapper (now `flex-row`) and the inner main-column (now nested one level deeper):

```ts
const DOCS_SHELL = "m3e-theme > div.h-dvh.flex.flex-row";
const MAIN_COLUMN = `${DOCS_SHELL} > div.flex.flex-1.flex-col`;
```

Update the first test (currently "the docs shell is a fixed-viewport flex column with one scroll region") to assert on both levels:

```ts
test("the docs shell is a fixed-viewport flex row (rail | main column) with one scroll region", async ({
  page,
}) => {
  await page.goto("/");
  await expect(page.locator("#docs-app-bar")).toBeVisible();

  const shell = page.locator(DOCS_SHELL);
  await expect(shell).toHaveCSS("display", "flex");
  await expect(shell).toHaveCSS("flex-direction", "row");
  await expect(shell).toHaveCSS("overflow-y", "visible");

  const mainColumn = page.locator(MAIN_COLUMN);
  await expect(mainColumn).toHaveCSS("display", "flex");
  await expect(mainColumn).toHaveCSS("flex-direction", "column");

  await expect(page.locator("#main-content m3e-content-pane").first()).toHaveCSS(
    "overflow-y",
    "auto",
  );
});
```

- [ ] **Step 3: Rebuild, re-serve, run to verify it passes**

Same commands as Step 1. Expected: PASS — all 4 tests in the file (the other 3 — examples-skip-shell, tall-example-reachable, dir — are unaffected by Plan 1's change and should already pass unmodified).

- [ ] **Step 4: Commit**

```bash
git add docs/tests-browser/app-shell.spec.ts
git commit -m "Fix app-shell.spec.ts selector for the flex-row rail wrapper"
```

---

### Task 2: One composed end-to-end assertion — rail, tree, content, and TOC all present together

**Files:**
- Modify: `docs/tests-browser/app-shell.spec.ts`

**Interfaces:** none.

- [ ] **Step 1: Write the failing test**

Add to `docs/tests-browser/app-shell.spec.ts`:

```ts
test("a component page composes rail, tree, content, and TOC together", async ({ page }) => {
  await page.goto("/components/button");

  // Rail: present, Components selected. `m3e-nav-item` exposes ARIA role
  // "button" (Role(LitElement, "button") in its mixin stack), not "link",
  // even though `href` drives real navigation — see nav-rail-layout.md Task 1.
  await expect(
    page.locator("m3e-nav-rail").getByRole("button", { name: "Components", exact: true }),
  ).toHaveAttribute("selected", "");

  // Tree: pinned open on desktop, showing Button's category.
  await expect(page.locator("#docs-drawer")).toHaveAttribute("start", "");
  await expect(page.getByText("Actions", { exact: true })).toBeVisible();

  // Content: the page's own heading renders in the content pane.
  await expect(
    page.locator("#main-content m3e-content-pane").first().getByRole("heading", { name: "Button" }),
  ).toBeVisible();

  // TOC: the API jump-link exists (wired in the tree/TOC plan).
  await expect(
    page.locator("#docs-drawer [slot='end']").getByRole("link", { name: "API" }),
  ).toBeVisible();
});
```

- [ ] **Step 2: Rebuild, serve, run it**

```bash
cd docs
npm run build:site
pkill -f "PORT=1239" 2>/dev/null; (PORT=1239 npm run serve > /tmp/serve.log 2>&1 &); sleep 2
BASE_URL=http://localhost:1239 npx playwright test tests-browser/app-shell.spec.ts
```

Expected: PASS — every piece this test checks was already built and individually tested by the two prior plans; this test only confirms they compose without interfering on one real page.

If it fails, that's a real integration gap the two prior plans' isolated tests didn't catch (e.g. a z-index/stacking conflict between the rail and the tree drawer) — do not weaken this test to make it pass; fix the underlying composition issue in the relevant plan's code first.

- [ ] **Step 3: Run the full browser suite**

```bash
BASE_URL=http://localhost:1239 npx playwright test
```

Expected: all tests pass, no skips beyond the pre-existing environment-gated `feedback-fab` test.

- [ ] **Step 4: Commit**

```bash
git add docs/tests-browser/app-shell.spec.ts
git commit -m "Add a composed rail+tree+content+TOC integration test"
```

---

### Task 3: `npm run gate` clean pass

**Files:** none new — verification only.

- [ ] **Step 1: Run the full gate**

```bash
npm run gate
```

- [ ] **Step 2: Confirm only the pre-existing, unrelated findings remain**

At this point, of the original 4 pre-existing `elm-review` findings (`Browser.Events` unused, `initialViewportWidth` unused, and two duplicate-`class`-attribute calls), the first two should already be resolved (Task 1 of the tree/TOC plan). The two duplicate-`class` findings (`Shared.elm:268`, `Shared.elm:723`) are unrelated to this whole migration and out of scope for all three plans — confirm they're the only findings left, don't fix them here.

- [ ] **Step 3: Commit any formatting fixes**

```bash
git add -u
git commit -m "elm-format"
```
