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
 * A slot that affords more than one option opens an add-child PANEL (M-IA2b):
 * a plain positioned `.compose-slot-panel` (NOT an `m3e-menu`, whose `Content`
 * cannot host the panel's "Nest a component"/"Load an example" captions),
 * addressed by route `Model` state per `(path, slot)`. Its options are plain
 * `<button>`s (primitives `Text`/`Icon`, editorially-labeled component types,
 * and source-qualified `.compose-example-item` examples). The attribute/slot
 * buttons wrap in a plain `flex flex-wrap` row, so they carry `role="button"`
 * (an earlier `M3e.buttonGroup` was dropped: it overflowed instead of wrapping
 * and stamped `role="radiogroup"`/`role="radio"` on these independent toggles).
 * Their accessible name is a leading `add` icon plus the slot/attribute name
 * (never a literal "+"), matched here by substring.
 *
 * The editor opens with a STARTER tree (see `init`/`starterEdits`): a root
 * `m3e-list` holding two `listItem`s labeled "First item" / "Second item". So
 * the tests that build from scratch add their own node and scope to it with
 * `.last()` (a new child appends last) and, for the opened menu, `:visible`
 * (every menu is always in the DOM, only the clicked one is shown).
 */

test("a slot's add-child panel offers every valid kind, not just text (M-IA2b)", async ({
  page,
}) => {
  await page.goto("/components/compose");

  // Add a fresh listItem via the ROOT list's "unnamed" slot. That slot affords
  // only component types, so its add-child panel (M-IA2b — a plain
  // `.compose-slot-panel`, NOT an `m3e-menu`) leads straight into the "Nest a
  // component" group; pick `listItem` there (`.first()` — the starter's own
  // listItems each expose an "unnamed" button too).
  await page.getByRole("button", { name: "unnamed" }).first().click();
  const rootPanel = page.locator(".compose-slot-panel");
  await rootPanel.getByRole("button", { name: "listItem", exact: true }).click();

  // The new listItem is last; its "trailing" slot is the §8.7 acceptance case:
  // it affords text, an icon, AND five components at once.
  await page.getByRole("button", { name: "trailing" }).last().click();
  const panel = page.locator(".compose-slot-panel");
  await expect(panel).toBeVisible();

  // The panel leads with the two structural primitives, then a captioned
  // "Nest a component" group holding the five component types (by editorial
  // label; `radio` has no reference category so it keeps its raw name) — NONE
  // collapsed away. The intent of the old flat-menu assertion, preserved
  // against the new grouped panel.
  await expect(panel.getByRole("button", { name: "Text", exact: true })).toBeVisible();
  await expect(panel.getByRole("button", { name: "Icon", exact: true })).toBeVisible();
  await expect(panel.getByText("Nest a component", { exact: true })).toBeVisible();
  for (const label of ["Avatar", "Checkbox", "Heading", "radio", "Switch"]) {
    await expect(panel.getByRole("button", { name: label, exact: true })).toBeVisible();
  }

  // Picking `Checkbox` — one of five component options this panel did NOT
  // collapse away — puts a real `m3e-checkbox` in the rendered tree.
  await panel.getByRole("button", { name: "Checkbox", exact: true }).click();
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

  // list > listItem > (trailing) checkbox — three levels, buttons and panels
  // only, no hand-authored code. Add a fresh listItem and drive ITS trailing.
  await page.getByRole("button", { name: "unnamed" }).first().click();
  await page.locator(".compose-slot-panel").getByRole("button", { name: "listItem", exact: true }).click();
  await page.getByRole("button", { name: "trailing" }).last().click();
  await page.locator(".compose-slot-panel").getByRole("button", { name: "Checkbox", exact: true }).click();

  await expect(page.locator("m3e-list > m3e-list-item > m3e-checkbox")).toHaveCount(1);
});

test("changing a node's component (edit the tag) rewrites the tree", async ({ page }) => {
  await page.goto("/components/compose");

  // The root starts as "list". The tag name is an m3e-heading; editing is a
  // separate "Change component" icon button (`.first()` = the root's) that
  // opens the grouped/searchable picker panel (M-IA2a) — not an `m3e-menu`.
  // It offers every known component (the root has no parent slot to
  // constrain it); "accordion" has no reference category, so it's a plain
  // button labeled with its raw name in the picker's "Other" group.
  await page.getByRole("button", { name: "Change component" }).first().click();
  const picker = page.locator(".compose-component-picker");
  await picker.getByRole("button", { name: "accordion", exact: true }).click();

  // The live preview: the root element's own tag changed.
  await expect(page.locator("m3e-list")).toHaveCount(0);
  await expect(page.locator("main m3e-accordion")).toHaveCount(1);

  // The generated-code snippet: the top-level call changed too.
  await expect(page.locator(".cf-root").first()).toContainText("M3e.Html.accordion");
});

test("the change-component picker is grouped, searchable, and offers no example items (M-IA2a)", async ({
  page,
}) => {
  await page.goto("/components/compose");

  await page.getByRole("button", { name: "Change component" }).first().click();
  const picker = page.locator(".compose-component-picker");
  await expect(picker).toBeVisible();

  // (a) Real component types only — no example titles mixed in. The plain
  // appBar option exists (labeled with its editorial name, "App Bar" — it
  // has a reference category, unlike "accordion" below); a real example
  // titled "Anatomy" does NOT — G-Ex2's examples stayed on the add-child
  // menu, never this one (§3.1).
  await expect(picker.getByRole("button", { name: "App Bar", exact: true })).toBeVisible();
  await expect(picker.getByText("Anatomy")).toHaveCount(0);
  await expect(picker.locator(".compose-example-item")).toHaveCount(0);

  // Grouped by nav category: "App Bar" (category "Navigation") sits under a
  // visible "Navigation" caption; "accordion" (no reference category) sits
  // under the trailing "Other" group.
  await expect(picker.getByText("Navigation", { exact: true })).toBeVisible();
  await expect(picker.getByText("Other", { exact: true })).toBeVisible();
  await expect(picker.getByRole("button", { name: "accordion", exact: true })).toBeVisible();

  const before = await picker.getByRole("button").count();

  // (b) Typing a query narrows the list — "accordion" is a unique-enough
  // substring that only it should remain.
  await picker.getByPlaceholder("Search components").fill("accordion");
  await expect(picker.getByRole("button")).toHaveCount(1);
  await expect(picker.getByRole("button", { name: "accordion", exact: true })).toBeVisible();

  const after = await picker.getByRole("button").count();
  expect(after).toBeLessThan(before);
});

test("loading a real example (G-Ex2) fills the node with its actual content", async ({ page }) => {
  await page.goto("/components/compose");

  // Add a fresh listItem, then open ITS "trailing" slot panel — one of the
  // five components it affords is "heading", which (via data/examples.json)
  // has a real "Typescale variants and sizes" example (root
  // `<m3e-heading variant="display" size="large">Display Large</m3e-heading>`),
  // offered under the panel's captioned "Load an example" group as a
  // `.compose-example-item` QUALIFIED by its source component ("Heading —
  // Typescale variants and sizes", M-IA2b). (M-IA2a removed examples from the
  // CHANGE-COMPONENT menu only — see the picker test above; the add-child
  // panel keeps them.) ("avatar", also offered here, is NOT usable for this:
  // its Fact declares no slots at all, so it can never receive slot content
  // through `Cem.Compose` regardless of FromHtml — a real, pre-existing
  // modeling limit, not something this test should paper over.)
  await page.getByRole("button", { name: "unnamed" }).first().click();
  await page.locator(".compose-slot-panel").getByRole("button", { name: "listItem", exact: true }).click();
  await page.getByRole("button", { name: "trailing" }).last().click();

  const panel = page.locator(".compose-slot-panel");
  await expect(panel.getByText("Load an example", { exact: true })).toBeVisible();
  const headingExample = panel.locator(
    "button.compose-example-item",
    { hasText: "Heading — Typescale variants and sizes" }
  );
  await expect(headingExample).toHaveText("Heading — Typescale variants and sizes");
  await headingExample.click();

  // The live preview: a real m3e-heading in the trailing slot, carrying the
  // example's ACTUAL recovered content and attributes.
  const heading = page.locator("m3e-list-item m3e-heading");
  await expect(heading).toContainText("Display Large");
  await expect(heading).toHaveAttribute("variant", "display");
  await expect(heading).toHaveAttribute("size", "large");

  // The generated-code snippet reflects the same recovered content.
  await expect(page.locator(".cf-root").first()).toContainText("Display Large");
});

test("a nested node's edit-tag menu only offers what its parent slot accepts", async ({ page }) => {
  await page.goto("/components/compose");

  // Add a fresh listItem, then open ITS edit-tag control — the "Change
  // component" icon button on the just-added node (`.last()`; the starter and
  // the root have their own).
  await page.getByRole("button", { name: "unnamed" }).first().click();
  await page.locator(".compose-slot-panel").getByRole("button", { name: "listItem", exact: true }).click();
  await page.getByRole("button", { name: "Change component" }).last().click();

  // list.unnamed affords divider/expandableListItem/listAction/listItem/
  // listOption — never anything list.unnamed doesn't name, and never the
  // current component ("listItem") itself. "divider" has a reference
  // category ("Containment"), so it renders under that group with its
  // editorial label ("Divider"); the other three have none, so they land in
  // the trailing "Other" group under their raw names.
  const picker = page.locator(".compose-component-picker");
  await expect(picker.getByRole("button")).toHaveText([
    "Divider",
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
  // affords text AND a heading, so it opens the add-child panel; click "Text").
  // The consumer seeds a fresh text node with "lorem ipsum" rather than empty.
  await page.getByRole("button", { name: "supporting-text" }).first().click();
  await page.locator(".compose-slot-panel").getByRole("button", { name: "Text", exact: true }).click();

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
  // heading, so a panel; click "Text"). With prefill off, no "lorem ipsum".
  await page.getByRole("button", { name: "supporting-text" }).first().click();
  await page.locator(".compose-slot-panel").getByRole("button", { name: "Text", exact: true }).click();

  await expect(page.locator("m3e-list").first()).not.toContainText("lorem ipsum");
});

test("selecting an attribute value updates the chip, the live preview, and the snippet together", async ({ page }) => {
  await page.goto("/components/compose");

  // Lock-in for the IA review's §1.3 finding ("chip presses but preview/
  // snippet don't update") — reproduced only on `elm-pages dev`; on the
  // PRODUCTION build (what this suite runs against) all three move together.
  // The button's own accessible name carries "name" until set, then
  // "name: value" (`attrButtonLabel`) — match by prefix so this locator is
  // valid both before and after the click.
  const variantButton = page.getByRole("button", { name: /^variant/ }).first();
  await variantButton.click();
  await page.getByRole("menuitem", { name: "segmented", exact: true }).click();

  // (a) The chip/button itself: elevated→filled is F3's visible "is this
  // set" signal, and its label now carries the chosen token.
  await expect(variantButton).toHaveAttribute("variant", "filled");
  await expect(variantButton).toHaveText("variant: segmented");

  // (b) The live preview: a real `m3e-list` carrying the attribute.
  await expect(page.locator("m3e-list").first()).toHaveAttribute("variant", "segmented");

  // (c) The generated-code snippet: the setter call that produced it.
  const snippet = page.locator(".cf-root").first();
  await expect(snippet).toContainText("M3e.Attributes.variant");
  await expect(snippet).toContainText("M3e.Values.segmented");
});

test("dismissing an attribute chip's menu without picking a value does not mark it selected", async ({ page }) => {
  await page.goto("/components/compose");

  // Regression for the fix removing `M3e.Attributes.toggle True` from these
  // chips: `m3e-button`'s own ButtonElement self-flips its reflected
  // `selected` on the menu-OPENING click when `toggle` is set, independent of
  // whether anything was actually applied. `selected` must instead be purely
  // model-derived (`info.isSet`), so opening-then-dismissing must leave it
  // unset. (`variant`, elevated/filled, was always model-derived and never
  // exhibited the bug — assert on `selected`, not `variant`.)
  const variantButton = page.getByRole("button", { name: /^variant/ }).first();
  await variantButton.click();

  const menu = page.locator("m3e-menu:visible");
  await expect(menu).toBeVisible();

  await page.keyboard.press("Escape");
  await expect(menu).toBeHidden();

  await expect(variantButton).not.toHaveAttribute("selected", /.*/);
  await expect(page.locator(".cf-root").first()).not.toContainText("M3e.Attributes.variant");

  // Positive path in the same test: this guards against a "fix" that simply
  // never sets `selected` at all.
  await variantButton.click();
  await page.getByRole("menuitem", { name: "segmented", exact: true }).click();

  await expect(variantButton).toHaveAttribute("selected", /.*/);
  await expect(page.locator(".cf-root").first()).toContainText("M3e.Attributes.variant");
});

test("adding slot content updates the preview and the snippet", async ({ page }) => {
  await page.goto("/components/compose");

  // Lock-in for the IA review's §1.3 finding, slot side: the first listItem's
  // "overline" slot affords text (and a heading, so it opens the add-child
  // panel); click "Text". (Not `list.unnamed` — it doesn't afford text at all.)
  await page.getByRole("button", { name: /overline/ }).first().click();
  await page.locator(".compose-slot-panel").getByRole("button", { name: "Text", exact: true }).click();

  // The live preview: a real slotted child under the first listItem, seeded
  // (prefill is on by default) with placeholder copy.
  await expect(page.locator("m3e-list-item [slot='overline']").first()).toContainText("lorem ipsum");

  // The generated-code snippet reflects the same new child (a named-slot
  // text child emits a slotted `TypedHtml.span`, per `Compose.Codegen`).
  await expect(page.locator(".cf-root").first()).toContainText('TypedHtml.Attributes.slot "overline"');
});

test("collapsing a card hides its body", async ({ page }) => {
  await page.goto("/components/compose");

  // Lock-in for the IA review's §1.9 finding ("collapse no-op") — reproduced
  // only on `elm-pages dev`. The root card's "Slots" group label is part of
  // its body (rendered before the recursive child cards, so this is the
  // FIRST "Slots" caption on the page); collapsing removes the whole body
  // from the DOM, not just rotating the chevron, so the label itself
  // actually stops being visible/present — not a proxy like button removal.
  const rootSlotsCaption = page.getByText("Slots", { exact: true }).first();
  await expect(rootSlotsCaption).toBeVisible();

  await page.getByRole("button", { name: "Collapse" }).first().click();
  await expect(rootSlotsCaption).toBeHidden();

  await page.getByRole("button", { name: "Expand" }).first().click();
  await expect(rootSlotsCaption).toBeVisible();
});

test("the drawer links to Compose", async ({ page }) => {
  await page.goto("/components/button");
  // At a desktop width the tree is already pinned open (`Shared.init` seeds
  // `treeOpen` from `treePinsOpen`), so there is nothing to click first.
  const drawer = page.locator(".primary-nav-drawer");
  await expect(drawer.getByRole("link", { name: "Compose", exact: true })).toBeVisible();
});
