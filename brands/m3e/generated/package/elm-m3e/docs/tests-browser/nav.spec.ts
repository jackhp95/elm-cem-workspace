import { test, expect } from "@playwright/test";

/**
 * The tree drawer is per-route: it renders ONLY the current top-level
 * section's items (`Shared.currentSectionItems`), not every section stacked
 * together. The rail (`nav-rail.spec.ts`) already shows which section is
 * current, so the tree doesn't repeat that -- it's just that one section's
 * page list, flat (no category sub-groups, not even for Components).
 */
test("drawer on a Components route shows only components, flat", async ({ page }) => {
  await page.goto("/components/button");
  // At a desktop width the tree is already pinned open (`Shared.init` seeds
  // `treeOpen` from `treePinsOpen`), so there is nothing to click first --
  // tapping the hamburger here would CLOSE it.
  const drawer = page.locator(".primary-nav-drawer");

  await expect(drawer.getByRole("link", { name: "All components", exact: true })).toBeVisible();
  await expect(drawer.getByRole("link", { name: "Button", exact: true })).toBeVisible();

  // No category headers -- the sub-grouping by category (Actions,
  // Communication, ...) was dropped; components are one flat alphabetical
  // list.
  await expect(drawer.getByText("Actions", { exact: true })).toHaveCount(0);
  await expect(drawer.getByText("Containment", { exact: true })).toHaveCount(0);

  // Per-route scoping: no other section's items leak into the Components
  // tree.
  await expect(drawer.getByRole("link", { name: "Installation", exact: true })).toHaveCount(0);
  await expect(drawer.getByRole("link", { name: "Start here", exact: true })).toHaveCount(0);
});

test("drawer on a Guide route shows only Guide items, including dissolved Reference links", async ({
  page,
}) => {
  await page.goto("/guide");
  // Pinned open at a desktop width -- see the note in the test above.
  const drawer = page.locator(".primary-nav-drawer");

  // Reference is gone as its own section; its 4 links live under Guide
  // instead, as real navLeaf anchors.
  await expect(drawer.getByText("Reference", { exact: true })).toHaveCount(0);
  await expect(drawer.getByRole("link", { name: "Full API reference", exact: true })).toBeVisible();
  await expect(drawer.getByRole("link", { name: "Round-trip report", exact: true })).toBeVisible();
  await expect(drawer.getByRole("link", { name: "Cheat sheet", exact: true })).toBeVisible();
  await expect(drawer.getByRole("link", { name: "Glossary", exact: true })).toBeVisible();

  // Per-route scoping: no other section's items leak into the Guide tree.
  await expect(drawer.getByRole("link", { name: "Button", exact: true })).toHaveCount(0);
  await expect(drawer.getByRole("link", { name: "Installation", exact: true })).toHaveCount(0);
});

test("drawer switches to the new section's items on navigation", async ({ page }) => {
  await page.goto("/guide");
  const drawer = page.locator(".primary-nav-drawer");
  await expect(drawer.getByRole("link", { name: "Start here", exact: true })).toBeVisible();

  await page.locator("m3e-nav-rail").getByRole("link", { name: "Styles", exact: true }).click();
  await expect(drawer.getByRole("link", { name: "Color", exact: true })).toBeVisible();
  await expect(drawer.getByRole("link", { name: "Start here", exact: true })).toHaveCount(0);
});
