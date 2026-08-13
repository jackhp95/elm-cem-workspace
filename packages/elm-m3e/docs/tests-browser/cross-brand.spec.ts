import { test, expect } from "@playwright/test";

/**
 * RC5 — the cross-brand content vocabulary, asserted in the browser
 * (Jack's rule: every UI-facing change ships a Playwright test at the 411×761
 * mobile viewport before merge).
 *
 * The type-level guarantees are pinned by the compiler and by
 * elm-typed-html's acid suite. What those CANNOT show is that the arrangement
 * they now permit actually renders: `AppBar.trailing` admits `sharedFlow`, so
 * the /guide/seams showcase slots a native <div> wrapper into an m3e-app-bar
 * and puts an m3e-icon-button + m3e-badge inside it. Before RC5 that shape
 * needed an `M3e.Unsafe.recast`; a slot assignment that type-checks but whose
 * children never get distributed to the shadow slot would look identical in
 * Elm and be invisible to every other test we have.
 *
 * So this asserts the DOM contract underneath the type: the wrapper carries
 * slot="trailing", the custom elements inside it upgrade, and the whole
 * arrangement is actually painted.
 */

const MOBILE = { width: 411, height: 761 };

test.use({ viewport: MOBILE });

test("a native wrapper lands in an m3e slot and its children upgrade", async ({
  page,
}) => {
  await page.goto("/guide/seams");
  await expect(page.locator("#docs-app-bar")).toBeVisible();

  // The showcase app bar (not the docs chrome app bar, which is #docs-app-bar).
  const bar = page.locator("m3e-app-bar").filter({ hasText: "Inbox" });
  await expect(bar).toBeVisible();

  // RC5: a NATIVE div assigned to the trailing slot. This is the element that
  // previously could not satisfy `html : M3e.Kind.Brand` at any price.
  const wrapper = bar.locator('div[slot="trailing"]');
  await expect(wrapper).toHaveCount(1);

  // Its children are m3e components, and they upgraded inside the native
  // wrapper — i.e. the wrapper did not break custom-element distribution.
  const iconButton = wrapper.locator("m3e-icon-button");
  const badge = wrapper.locator("m3e-badge");
  await expect(iconButton).toHaveCount(1);
  await expect(badge).toHaveCount(1);
  await expect(badge).toHaveText("3");

  for (const el of [iconButton, badge]) {
    await expect(el).toBeVisible();
    // `:defined` means the custom element upgraded rather than staying inert.
    expect(
      await el.evaluate((n) => n.matches(":defined")),
      "custom element inside the native slot wrapper never upgraded",
    ).toBe(true);
  }

  // …and it is actually painted, not zero-sized behind the FOUC guard.
  const box = await wrapper.boundingBox();
  expect(box, "the trailing wrapper has no layout box").not.toBeNull();
  expect(box!.width).toBeGreaterThan(0);
  expect(box!.height).toBeGreaterThan(0);
});

test("the guide documents the one-way limit", async ({ page }) => {
  await page.goto("/guide/seams");
  await expect(page.locator("#docs-app-bar")).toBeVisible();

  // The reverse direction is a designed limit, and the guide has to say so —
  // otherwise the next reader re-derives it from a type error. (It already has
  // been re-derived twice.)
  await expect(
    page.getByText("The other direction is a designed limit"),
  ).toBeVisible();
});
