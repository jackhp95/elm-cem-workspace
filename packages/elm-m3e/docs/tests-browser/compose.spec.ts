import { test, expect } from "@playwright/test";

/**
 * Compose is a type-directed tree editor: what a slot's menu offers is derived
 * from that slot's `kinds` in `M3e.Review.Facts`, not hand-written. These tests
 * defend the wiring, not the logic — the logic is covered by elm-test in
 * packages/elm-cem-compose/tests.
 *
 * The `trailing` test is the one that matters most: it is the acceptance check
 * for the decision that a slot offers EVERY valid content kind rather than the
 * highest-precedence one. Under the superseded rule `listItem.trailing`
 * collapsed to a text box and the checkbox was unreachable.
 *
 * A slot chip that affords more than one option (every test here except the
 * single-option shortcut, which none of these exercise) is a toggle `button`,
 * not an `m3e-filter-chip` — `M3e.filterChip`'s `Content` cannot host
 * `menuTrigger` at all, and nesting a trigger's ANCESTOR chip among sibling
 * triggers inside a filter chip was found, empirically, to open every
 * sibling's menu at once. `M3e.button` is the host verified (by hand, against
 * this exact page) to scope a trigger's click to itself.
 */

test("a slot menu offers every valid kind, not just text", async ({ page }) => {
  await page.goto("/components/compose");

  // Root is "list": its default ("unnamed") slot affords five component
  // kinds and no text/icon, so its chip opens straight to a menu.
  await page.getByRole("button", { name: "+ unnamed" }).click();
  await page.getByRole("menuitem", { name: "listItem", exact: true }).click();

  // listItem's "trailing" slot is the §8.7 acceptance case: it affords text,
  // an icon, AND five components at once.
  await page.getByRole("button", { name: "+ trailing" }).click();

  const trailingMenu = page.locator("m3e-menu[id*='trailing']");
  await expect(trailingMenu).toBeVisible();

  const items = trailingMenu.getByRole("menuitem");
  await expect(items).toHaveText([
    "Text",
    "Icon",
    "avatar",
    "checkbox",
    "heading",
    "radio",
    "switch",
  ]);

  // Picking `checkbox` — one of five component options this menu did NOT
  // collapse away — puts a real `m3e-checkbox` in the rendered tree.
  await trailingMenu.getByRole("menuitem", { name: "checkbox", exact: true }).click();
  await expect(page.locator("m3e-list-item m3e-checkbox")).toHaveCount(1);
});

test("setting an attribute updates both the live element and the snippet", async ({ page }) => {
  await page.goto("/components/compose");

  // The root "list" node's own "variant" attribute is a discrete (enum)
  // chip: filled, outlined, ... — click it and pick a token.
  await page.getByRole("button", { name: "variant" }).click();
  await page.getByRole("menuitem", { name: "segmented", exact: true }).click();

  // The live preview: a real `m3e-list` carrying the attribute.
  await expect(page.locator("m3e-list").first()).toHaveAttribute("variant", "segmented");

  // The generated-code snippet: the setter call that produced it.
  const snippet = page.locator(".cf-root").first();
  await expect(snippet).toContainText("M3e.Attributes.variant");
  await expect(snippet).toContainText("M3e.Values.segmented");
});

test("nesting three levels deep works with chips alone", async ({ page }) => {
  await page.goto("/components/compose");

  // list > listItem > (trailing) checkbox — three levels, chips and menus
  // only, no hand-authored code.
  await page.getByRole("button", { name: "+ unnamed" }).click();
  await page.getByRole("menuitem", { name: "listItem", exact: true }).click();
  await page.getByRole("button", { name: "+ trailing" }).click();
  await page.getByRole("menuitem", { name: "checkbox", exact: true }).click();

  await expect(page.locator("m3e-list > m3e-list-item > m3e-checkbox")).toHaveCount(1);
});

test("changing a node's component (edit the tag) rewrites the tree", async ({ page }) => {
  await page.goto("/components/compose");

  // The root starts as "list". Its edit-tag menu offers every known
  // component (the root has no parent slot to constrain it) — pick a
  // different one.
  await page.getByRole("button", { name: "Change component" }).click();
  await page.getByRole("menuitem", { name: "accordion", exact: true }).click();

  // The live preview: the root element's own tag changed.
  await expect(page.locator("m3e-list")).toHaveCount(0);
  await expect(page.locator("main m3e-accordion")).toHaveCount(1);

  // The generated-code snippet: the top-level call changed too.
  await expect(page.locator(".cf-root").first()).toContainText("M3e.Html.accordion");
});

test("a nested node's edit-tag menu only offers what its parent slot accepts", async ({ page }) => {
  await page.goto("/components/compose");

  // list > listItem, then listItem's OWN edit-tag menu (the second
  // "Change component" control on the page — the first is the root's).
  await page.getByRole("button", { name: "+ unnamed" }).click();
  await page.getByRole("menuitem", { name: "listItem", exact: true }).click();
  await page.getByRole("button", { name: "Change component" }).nth(1).click();

  // list.unnamed affords divider/expandableListItem/listAction/listItem/
  // listOption — never anything list.unnamed doesn't name, and never the
  // current component ("listItem") itself.
  await expect(page.getByRole("menuitem")).toHaveText([
    "divider",
    "expandableListItem",
    "listAction",
    "listOption",
  ]);
});

test("the drawer links to Compose", async ({ page }) => {
  await page.goto("/components/button");
  // At a desktop width the tree is already pinned open (`Shared.init` seeds
  // `treeOpen` from `treePinsOpen`), so there is nothing to click first.
  const drawer = page.locator(".primary-nav-drawer");
  await expect(drawer.getByRole("link", { name: "Compose", exact: true })).toBeVisible();
});
