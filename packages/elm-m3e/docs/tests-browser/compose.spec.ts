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
 * A slot chip that affords more than one option is a toggle `M3e.button` (not
 * an `m3e-filter-chip` — `M3e.filterChip`'s `Content` cannot host `menuTrigger`
 * at all). The attribute/slot buttons wrap in a plain `flex flex-wrap` row, so
 * they carry `role="button"` (an earlier `M3e.buttonGroup` was dropped: it
 * overflowed instead of wrapping and stamped `role="radiogroup"`/`role="radio"`
 * on these independent toggles). Their accessible name is a leading `add` icon
 * plus the slot/attribute name (never a literal "+"), matched here by substring.
 *
 * The editor opens with a STARTER tree (see `init`/`starterEdits`): a root
 * `m3e-list` holding two `listItem`s labeled "First item" / "Second item". So
 * the tests that build from scratch add their own node and scope to it with
 * `.last()` (a new child appends last) and, for the opened menu, `:visible`
 * (every menu is always in the DOM, only the clicked one is shown).
 */

test("a slot menu offers every valid kind, not just text", async ({ page }) => {
  await page.goto("/components/compose");

  // Add a fresh listItem via the ROOT list's "unnamed" slot (`.first()` — the
  // starter's own listItems each expose an "unnamed" button too).
  await page.getByRole("button", { name: "unnamed" }).first().click();
  await page.getByRole("menuitem", { name: "listItem", exact: true }).click();

  // The new listItem is last; its "trailing" slot is the §8.7 acceptance case:
  // it affords text, an icon, AND five components at once.
  await page.getByRole("button", { name: "trailing" }).last().click();

  // Every menu is in the DOM; only the just-opened one is visible.
  const trailingMenu = page.locator("m3e-menu[id*='trailing']:visible");
  await expect(trailingMenu).toBeVisible();

  // `.compose-example-item` items (one per real example a component has) are
  // excluded here — this asserts the plain option set, not the real-example
  // options G-Ex2 adds alongside them (see the "real example" test below).
  const items = trailingMenu.locator("m3e-menu-item:not(.compose-example-item)");
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
  // button: filled, outlined, ... — click it (`.first()` = the root's) and
  // pick a token.
  await page.getByRole("button", { name: "variant" }).first().click();
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

  // list > listItem > (trailing) checkbox — three levels, buttons and menus
  // only, no hand-authored code. Add a fresh listItem and drive ITS trailing.
  await page.getByRole("button", { name: "unnamed" }).first().click();
  await page.getByRole("menuitem", { name: "listItem", exact: true }).click();
  await page.getByRole("button", { name: "trailing" }).last().click();
  await page.locator("m3e-menu[id*='trailing']:visible").getByRole("menuitem", { name: "checkbox", exact: true }).click();

  await expect(page.locator("m3e-list > m3e-list-item > m3e-checkbox")).toHaveCount(1);
});

test("changing a node's component (edit the tag) rewrites the tree", async ({ page }) => {
  await page.goto("/components/compose");

  // The root starts as "list". The tag name is an m3e-heading; editing is a
  // separate "Change component" icon button (`.first()` = the root's). Its menu
  // offers every known component (the root has no parent slot to constrain it).
  await page.getByRole("button", { name: "Change component" }).first().click();
  await page.getByRole("menuitem", { name: "accordion", exact: true }).click();

  // The live preview: the root element's own tag changed.
  await expect(page.locator("m3e-list")).toHaveCount(0);
  await expect(page.locator("main m3e-accordion")).toHaveCount(1);

  // The generated-code snippet: the top-level call changed too.
  await expect(page.locator(".cf-root").first()).toContainText("M3e.Html.accordion");
});

test("loading a real example (G-Ex2) fills the node with its actual content", async ({ page }) => {
  await page.goto("/components/compose");

  // The root starts as "list"; its change-component menu offers every known
  // component (no parent slot to constrain it), each with an extra
  // `.compose-example-item` per real example that component has in
  // data/examples.json. Many components share an example titled "Anatomy",
  // so scope to the one immediately following the exact "appBar" plain
  // option — its own sibling example item, not some other component's.
  await page.getByRole("button", { name: "Change component" }).first().click();
  const appBarAnatomy = page.locator(
    'm3e-menu:visible m3e-menu-item:text-is("appBar") + m3e-menu-item.compose-example-item'
  );
  await expect(appBarAnatomy).toHaveText("Anatomy");
  await appBarAnatomy.click();

  // The live preview: a real m3e-app-bar, carrying the "Anatomy" example's
  // ACTUAL recovered content — its leading/trailing m3e-icon-buttons' own
  // nested m3e-icons and the trailing button's "tonal" variant attribute.
  // (The example's title/subtitle <span>s have no matching Fact and are
  // dropped by Compose.FromHtml's parser — by design, not asserted here.)
  await expect(page.locator("main m3e-app-bar")).toHaveCount(1);
  await expect(page.locator("m3e-app-bar m3e-icon-button m3e-icon[name='arrow_back']")).toHaveCount(1);
  await expect(page.locator("m3e-app-bar m3e-icon-button[variant='tonal'] m3e-icon[name='bookmark']")).toHaveCount(1);

  // The generated-code snippet reflects the same recovered content.
  await expect(page.locator(".cf-root").first()).toContainText("arrow_back");
});

test("a nested node's edit-tag menu only offers what its parent slot accepts", async ({ page }) => {
  await page.goto("/components/compose");

  // Add a fresh listItem, then open ITS edit-tag control — the "Change
  // component" icon button on the just-added node (`.last()`; the starter and
  // the root have their own).
  await page.getByRole("button", { name: "unnamed" }).first().click();
  await page.getByRole("menuitem", { name: "listItem", exact: true }).click();
  await page.getByRole("button", { name: "Change component" }).last().click();

  // list.unnamed affords divider/expandableListItem/listAction/listItem/
  // listOption — never anything list.unnamed doesn't name, and never the
  // current component ("listItem") itself. Only the opened menu is visible.
  // `.compose-example-item` items (real-example options, G-Ex2) are excluded
  // — see the note on the slot-menu test above.
  await expect(page.locator("m3e-menu:visible m3e-menu-item:not(.compose-example-item)")).toHaveText([
    "divider",
    "expandableListItem",
    "listAction",
    "listOption",
  ]);
});

test("up/down controls reorder siblings within a slot", async ({ page }) => {
  await page.goto("/components/compose");

  // The starter tree already holds two labeled list items, so the reorder
  // arrows are present from the start. Preview order follows child order.
  const items = page.locator("m3e-list").first().locator("> m3e-list-item");
  await expect(items).toHaveCount(2);
  await expect(items.nth(0)).toContainText("First item");
  await expect(items.nth(1)).toContainText("Second item");

  // The first item's "Move up" is disabled and its "Move down" is enabled
  // (`.first()` = the first item's controls); clicking it swaps the two.
  await page.getByRole("button", { name: "Move down" }).first().click();

  await expect(items.nth(0)).toContainText("Second item");
  await expect(items.nth(1)).toContainText("First item");
});

test("a newly added text child defaults to placeholder copy", async ({ page }) => {
  await page.goto("/components/compose");

  // Add a text child to the first list item's "supporting-text" slot (it
  // affords text AND a heading, so it opens a menu; pick "Text"). The consumer
  // seeds a fresh text node with "lorem ipsum" rather than an empty string.
  await page.getByRole("button", { name: "supporting-text" }).first().click();
  await page.locator("m3e-menu:visible").getByRole("menuitem", { name: "Text", exact: true }).click();

  // It shows up in the live preview as real content.
  await expect(page.locator("m3e-list").first()).toContainText("lorem ipsum");
});

test("the collapse chevron hides and restores a node's body", async ({ page }) => {
  await page.goto("/components/compose");

  // Root starts expanded: its "unnamed" slot button is visible.
  await expect(page.getByRole("button", { name: "unnamed" }).first()).toBeVisible();

  // Collapse the root card (`.first()` chevron) — its whole body, including the
  // child cards, disappears; only the header remains.
  await page.getByRole("button", { name: "Collapse" }).first().click();
  await expect(page.getByRole("button", { name: "unnamed" })).toHaveCount(0);

  // Expanding restores it.
  await page.getByRole("button", { name: "Expand" }).first().click();
  await expect(page.getByRole("button", { name: "unnamed" }).first()).toBeVisible();
});

test("prefill off adds empty content instead of placeholder", async ({ page }) => {
  await page.goto("/components/compose");

  // Prefill starts on; turn it off.
  await page.getByRole("switch", { name: "Prefill examples" }).click();

  // Add a text child to the first item's supporting-text slot (affords text +
  // heading, so a menu; pick "Text"). With prefill off, no "lorem ipsum".
  await page.getByRole("button", { name: "supporting-text" }).first().click();
  await page.locator("m3e-menu:visible").getByRole("menuitem", { name: "Text", exact: true }).click();

  await expect(page.locator("m3e-list").first()).not.toContainText("lorem ipsum");
});

test("the drawer links to Compose", async ({ page }) => {
  await page.goto("/components/button");
  // At a desktop width the tree is already pinned open (`Shared.init` seeds
  // `treeOpen` from `treePinsOpen`), so there is nothing to click first.
  const drawer = page.locator(".primary-nav-drawer");
  await expect(drawer.getByRole("link", { name: "Compose", exact: true })).toBeVisible();
});
