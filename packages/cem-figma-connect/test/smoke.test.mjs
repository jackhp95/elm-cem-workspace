import { test } from "node:test";
import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { randomUUID } from "node:crypto";

import { validate } from "../src/lib/validate.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..");
const cliPath = path.join(repoRoot, "src", "cli.mjs");

function runCli(args) {
  return spawnSync(process.execPath, [cliPath, ...args], {
    cwd: repoRoot,
    encoding: "utf8",
  });
}

test("cli: unknown command prints usage and exits 2", () => {
  const result = runCli(["nosuch"]);
  assert.equal(result.status, 2);
  assert.match(result.stderr, /Usage: cem-figma-connect/);
});

test("cli: no command prints usage and exits 2", () => {
  const result = runCli([]);
  assert.equal(result.status, 2);
  assert.match(result.stderr, /Usage: cem-figma-connect/);
});

test("cli: known command stub exits 0", () => {
  const result = runCli(["extract"]);
  assert.equal(result.status, 0);
  assert.match(result.stdout, /extract: not yet implemented/);
});

test("cli: every still-stubbed subcommand dispatches to the stub, not usage", () => {
  // match/review/confirm were wired to real implementations in task A6
  // (src/correspond/merge.mjs + review.mjs); gap was wired in task A7
  // (src/correspond/gap-report.mjs); emit was wired in task B1
  // (src/emit/html-label.mjs) and rewired through the general runner in
  // task B2 (src/emit/run.mjs); check/publish/unpublish were wired in task
  // B4 (src/publish/check.mjs + src/publish/runner.mjs) — all covered
  // separately below and in test/correspond.test.mjs / test/gap-report.test.mjs /
  // test/html-label.test.mjs / test/emitter-api.test.mjs / test/publish-check.test.mjs.
  // Only `extract` remains a stub (Plan A3 live re-extraction, ⚑ HUMAN).
  for (const command of ["extract"]) {
    const result = runCli([command]);
    assert.equal(result.status, 0, `${command} should exit 0`);
    assert.match(result.stdout, new RegExp(`^${command}: not yet implemented`));
  }
});

test("cli: check/publish/unpublish (wired to real implementations, task B4) require --profile", () => {
  for (const command of ["check", "publish", "unpublish"]) {
    const result = runCli([command]);
    assert.equal(result.status, 2, `${command} without --profile should exit 2`);
    assert.match(result.stderr, /requires --profile/);
  }
});

test("cli: publish/unpublish (task B4) require --file-key once --profile is given", () => {
  for (const command of ["publish", "unpublish"]) {
    const result = runCli([command, "--profile", "m3-kit"]);
    assert.equal(result.status, 2, `${command} without --file-key should exit 2`);
    assert.match(result.stderr, /requires --file-key/);
  }
});

test("cli: check --profile m3-kit passes against the committed generated/** tree (no drift/orphan today)", () => {
  // No self-heal pre-emit needed (review round, root-cause test-isolation
  // fix): the only test that used to destructively narrow/wipe the
  // committed generated/m3-kit/** tree (test/emitter-api.test.mjs's --page
  // CLI tests) now runs against a throwaway profile copy instead, so
  // nothing in this suite leaves generated/m3-kit/** disturbed out from
  // under this test anymore.
  const result = runCli(["check", "--profile", "m3-kit"]);
  assert.equal(result.status, 0, `check should pass; stderr:\n${result.stderr}`);
  assert.match(result.stdout, /check: OK/);
});

test("cli: publish refuses a profile whose kitVersionTag is still the A3 placeholder (carry-in guard, WB/m6)", () => {
  // The real m3-kit profile carries a real kitVersionTag since the
  // 2026-07-13 A3 live extraction, so exercise the CLI-layer guard against a
  // throwaway profile under profiles/ (bare-name resolvable) that reinstates
  // the placeholder. The runner must refuse outright, before ever touching
  // the network or a token — the guard fires right after loadProfile.
  const tmpName = `guard-placeholder-${randomUUID()}`;
  const tmpDir = path.join(repoRoot, "profiles", tmpName);
  fs.mkdirSync(tmpDir, { recursive: true });
  try {
    const profile = JSON.parse(
      fs.readFileSync(path.join(repoRoot, "profiles", "m3-kit", "profile.json"), "utf8")
    );
    profile.kitVersionTag = "unknown-pre-a3-fixture";
    fs.writeFileSync(path.join(tmpDir, "profile.json"), `${JSON.stringify(profile, null, 2)}\n`);
    const result = runCli([
      "publish",
      "--profile",
      tmpName,
      "--file-key",
      "iPFL8MH2R1Xphe94j7g809",
      "--dry-run",
    ]);
    assert.equal(result.status, 2);
    assert.match(result.stderr, /kitVersionTag/);
    assert.match(result.stderr, /unknown-pre-a3-fixture/);
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});

test("cli: --profile resolves a bare name to profiles/<name> (stub command)", () => {
  const result = runCli(["extract", "--profile", "m3-kit"]);
  assert.equal(result.status, 0);
  assert.match(result.stdout, /profile: profiles[\\/]m3-kit/);
});

test("cli: match/review/confirm/gap/emit (wired to real implementations, tasks A6/A7/B1) require --profile", () => {
  for (const command of ["match", "review", "confirm", "gap", "emit"]) {
    const result = runCli([command]);
    assert.equal(result.status, 2, `${command} without --profile should exit 2`);
    assert.match(result.stderr, /requires --profile/);
  }
});

test("cli: emit --profile m3-kit writes the html-label .figma.ts files + MANIFEST.json (task B1, rewired through B2's run.mjs)", () => {
  // Task B2: emit output moved from generated/<profile>/html-label/ to
  // generated/<profile>/<label-slug>/ (the html-label emitter's OWN `label`
  // field, "Web Components", slugified — src/emit/run.mjs), and now also
  // writes a MANIFEST.json alongside the generated files.
  //
  // generated/m3-kit/** is COMMITTED (task B2's decision — see
  // .superpowers/sdd/task-B2-report.md: B4's `check` needs a committed
  // baseline to diff regenerated output against for drift detection), so
  // this test deliberately does NOT `rmSync` the whole `generated/` root —
  // only the m3-kit/web-components dir it's about to rewrite anyway, and
  // `emit` itself is byte-stable, so the working tree is left matching the
  // committed baseline exactly (no leftover diff) rather than deleted.
  //
  // Confirmed set (banked 2026-07-14, after false-pass revert 2026-07-14):
  // m3e-badge, m3e-button (5 sets), m3e-icon-button (4 sets), m3e-switch, m3e-checkbox
  // (1 set each), m3e-assist-chip, m3e-filter-chip, m3e-input-chip, m3e-suggestion-chip
  // (1 set each), m3e-search-bar (1 set, RC5 2026-07-14), m3e-list-item (1 set, #11 2026-07-14),
  // m3e-shape (1 set, #12 2026-07-14 digit-name canon fix), m3e-fab (1 set, #13
  // 2026-07-18 benignAa tier — curved-shape + icon-glyph AA, offline capture),
  // m3e-avatar (1 set, #14 2026-07-18 monogram-variant pin — Style fixedAttrs; gate 0.0000),
  // m3e-segmented-button (1 set, #15 2026-07-18 representative example — 3 m3e-button-segment children)
  // m3e-split-button (1 set, #16 2026-07-18 representative example — leading m3e-button + trailing m3e-icon-button chevron)
  // m3e-button-group (2 sets, #17 2026-07-18 representative example — 2 outlined m3e-button children)
  // m3e-card (2 sets, #18 2026-07-18 representative example — header/content spans + text action button)
  // m3e-menu-item (1 set, #19 2026-07-18 representative example — settings icon + label)
  // m3e-nav-item (1 set, #20 2026-07-18 representative example — home icon + label)
  // m3e-app-bar (1 set, #21 2026-07-18 representative example — leading menu icon-button + title + trailing overflow)
  // m3e-dialog (1 set, #22 2026-07-19 representative example — header span + content span + Cancel/Reset action buttons)
  // m3e-list (1 set, #23 2026-07-19 representative example — 3 m3e-list-item children)
  // m3e-tabs (1 set, #24 2026-07-19 representative example — 3 m3e-tab children, first selected)
  // m3e-toolbar (1 set, #25 2026-07-19 representative example — 3 icon-buttons bold/italic/underline)
  // m3e-tab (1 set, #32 2026-07-19 manual-correspondence — Primary tabs/Icon and label; example = favorite icon + label)
  // = 34 .figma.ts files + MANIFEST.json.
  // Reverted (FALSE PASSES): m3e-snackbar.
  const outDir = path.join(repoRoot, "generated", "m3-kit", "web-components");
  fs.rmSync(outDir, { recursive: true, force: true });

  const result = runCli(["emit", "--profile", "m3-kit"]);
  assert.equal(result.status, 0);
  // 83 non-icon files + 141 icon files = 224 .figma.ts (+ MANIFEST.json, not counted by emit).
  // 2026-07-30 coverage remediation: +11 non-icon files (P1–P5 appends + P6 timepicker binds).
  // 2026-07-30 conflict fixes: nav-menu remapped to Navigation Drawer; nav-rail gains the
  // "Navigation Rail: Expanded" set (+1). datepicker's text-entry set moved to the new
  // m3e-date-input tag (modal + docked, net +1 non-icon file).
  assert.match(result.stdout, /emit: wrote 224 file\(s\)/);
  const written = fs.readdirSync(outDir).sort();
  // The written array now contains 141 m3e-icon-*.figma.ts files, which would make a
  // full deepEqual unwieldy. Strategy: verify non-icon files exactly (preserving
  // the original deepEqual intent for those 42 files) + verify icon file COUNT.
  const iconFiles = written.filter((f) => f.startsWith("m3e-icon-") && !f.startsWith("m3e-icon-button-"));
  const nonIconFiles = written.filter((f) => !f.startsWith("m3e-icon-") || f.startsWith("m3e-icon-button-"));
  assert.equal(iconFiles.length, 141, "should be exactly 141 m3e-icon-* files (not m3e-icon-button)");
  assert.deepEqual(nonIconFiles, [
    "MANIFEST.json",
    "m3e-app-bar-app-bar.figma.ts",
    "m3e-assist-chip-assistive-chip.figma.ts",
    "m3e-avatar-generic-avatar.figma.ts",
    "m3e-badge-badges.figma.ts",
    "m3e-bottom-sheet-bottom-sheet.figma.ts",
    "m3e-button-elevated.figma.ts",
    "m3e-button-filled.figma.ts",
    "m3e-button-group-connected.figma.ts",
    "m3e-button-group-standard.figma.ts",
    "m3e-button-outlined.figma.ts",
    "m3e-button-segment-building-blocks-segmented-button-button-segment-middle.figma.ts",
    "m3e-button-text.figma.ts",
    "m3e-button-toggle-elevated.figma.ts",
    "m3e-button-toggle-filled.figma.ts",
    "m3e-button-toggle-outlined.figma.ts",
    "m3e-button-toggle-tonal.figma.ts",
    "m3e-button-tonal.figma.ts",
    "m3e-card-horizontal.figma.ts",
    "m3e-card-vertical.figma.ts",
    "m3e-checkbox-checkboxes.figma.ts",
    "m3e-chip-set-chip-groups.figma.ts",
    "m3e-circular-progress-indicator-circular-determinate-progress-indicator.figma.ts",
    "m3e-circular-progress-indicator-circular-indeterminate-progress-indicator.figma.ts",
    "m3e-date-input-docked.figma.ts",
    "m3e-date-input-modal.figma.ts",
    "m3e-datepicker-modal.figma.ts",
    "m3e-dialog-basic-dialog.figma.ts",
    "m3e-dialog-list.figma.ts",
    "m3e-dialog-scrollable-list.figma.ts",
    "m3e-drawer-container-side-sheet.figma.ts",
    "m3e-expandable-list-item-list-item-accordion.figma.ts",
    "m3e-fab-extended.figma.ts",
    "m3e-fab-fab.figma.ts",
    "m3e-fab-menu-fab-menu.figma.ts",
    "m3e-fab-menu-item-building-blocks-fab-menu-primary-segment.figma.ts",
    "m3e-filter-chip-filter-chip.figma.ts",
    "m3e-form-field-filled.figma.ts",
    "m3e-icon-button-filled.figma.ts",
    "m3e-icon-button-outlined.figma.ts",
    "m3e-icon-button-standard.figma.ts",
    "m3e-icon-button-toggle-filled.figma.ts",
    "m3e-icon-button-toggle-outlined.figma.ts",
    "m3e-icon-button-toggle-standard.figma.ts",
    "m3e-icon-button-toggle-tonal.figma.ts",
    "m3e-icon-button-tonal.figma.ts",
    "m3e-input-chip-input-chip.figma.ts",
    "m3e-linear-progress-indicator-determinate.figma.ts",
    "m3e-linear-progress-indicator-indeterminate.figma.ts",
    "m3e-list-item-list-item.figma.ts",
    "m3e-list-list.figma.ts",
    "m3e-loading-indicator-loading-indicator.figma.ts",
    "m3e-menu-item-menu-item-standard.figma.ts",
    "m3e-menu-menu.figma.ts",
    "m3e-nav-bar-navigation-bar-horizontal-items.figma.ts",
    "m3e-nav-item-building-blocks-nav-item.figma.ts",
    "m3e-nav-menu-navigation-drawer.figma.ts",
    "m3e-nav-rail-expanded.figma.ts",
    "m3e-nav-rail-navigation-rail.figma.ts",
    "m3e-radio-radio-buttons.figma.ts",
    "m3e-rich-tooltip-rich-tooltip.figma.ts",
    "m3e-search-bar-search-bar.figma.ts",
    "m3e-search-view-docked.figma.ts",
    "m3e-search-view-fullscreen.figma.ts",
    "m3e-segmented-button-segmented-button.figma.ts",
    "m3e-shape-shape-set.figma.ts",
    "m3e-slider-range.figma.ts",
    "m3e-slider-standard-slider.figma.ts",
    "m3e-snackbar-snackbar.figma.ts",
    "m3e-split-button-split-button.figma.ts",
    "m3e-suggestion-chip-suggestion-chip.figma.ts",
    "m3e-switch-switch.figma.ts",
    "m3e-tab-primary-icon-only.figma.ts",
    "m3e-tab-primary-label-only.figma.ts",
    "m3e-tab-primary-tabs-icon-and-label.figma.ts",
    "m3e-tab-secondary-icon-label.figma.ts",
    "m3e-tab-secondary-label-only.figma.ts",
    "m3e-tabs-tabs.figma.ts",
    "m3e-timepicker-dial.figma.ts",
    "m3e-timepicker-input-period-toggle-horizontal.figma.ts",
    "m3e-timepicker-input-period-toggle-vertical.figma.ts",
    "m3e-timepicker-keyboard.figma.ts",
    "m3e-toolbar-toolbar.figma.ts",
    "m3e-tooltip-plain-tooltip.figma.ts",
  ]);
  const manifest = JSON.parse(fs.readFileSync(path.join(outDir, "MANIFEST.json"), "utf8"));
  assert.deepEqual(Object.keys(manifest).sort(), ["m3e-app-bar", "m3e-assist-chip", "m3e-avatar", "m3e-badge", "m3e-bottom-sheet", "m3e-button", "m3e-button-group", "m3e-button-segment", "m3e-card", "m3e-checkbox", "m3e-chip-set", "m3e-circular-progress-indicator", "m3e-date-input", "m3e-datepicker", "m3e-dialog", "m3e-drawer-container", "m3e-expandable-list-item", "m3e-fab", "m3e-fab-menu", "m3e-fab-menu-item", "m3e-filter-chip", "m3e-form-field", "m3e-icon", "m3e-icon-button", "m3e-input-chip", "m3e-linear-progress-indicator", "m3e-list", "m3e-list-item", "m3e-loading-indicator", "m3e-menu", "m3e-menu-item", "m3e-nav-bar", "m3e-nav-item", "m3e-nav-menu", "m3e-nav-rail", "m3e-radio", "m3e-rich-tooltip", "m3e-search-bar", "m3e-search-view", "m3e-segmented-button", "m3e-shape", "m3e-slider", "m3e-snackbar", "m3e-split-button", "m3e-suggestion-chip", "m3e-switch", "m3e-tab", "m3e-tabs", "m3e-timepicker", "m3e-timepicker-input-period-toggle", "m3e-toolbar", "m3e-tooltip"]);
  assert.equal(Object.keys(manifest).length, 52);
  assert.equal(manifest["m3e-app-bar"].length, 1);
  assert.equal(manifest["m3e-assist-chip"].length, 1);
  assert.equal(manifest["m3e-avatar"].length, 1);
  assert.equal(manifest["m3e-badge"].length, 1);
  assert.equal(manifest["m3e-fab"].length, 2);
  assert.equal(manifest["m3e-button"].length, 9);
  assert.equal(manifest["m3e-checkbox"].length, 1);
  assert.equal(manifest["m3e-filter-chip"].length, 1);
  assert.equal(manifest["m3e-icon-button"].length, 8);
  assert.equal(manifest["m3e-input-chip"].length, 1);
  assert.equal(manifest["m3e-list-item"].length, 1);
  assert.equal(manifest["m3e-search-bar"].length, 1);
  assert.equal(manifest["m3e-segmented-button"].length, 1);
  assert.equal(manifest["m3e-shape"].length, 1);
  assert.equal(manifest["m3e-split-button"].length, 1);
  assert.equal(manifest["m3e-button-group"].length, 2);
  assert.equal(manifest["m3e-card"].length, 2);
  assert.equal(manifest["m3e-menu-item"].length, 1);
  assert.equal(manifest["m3e-nav-item"].length, 1);
  assert.equal(manifest["m3e-suggestion-chip"].length, 1);
  assert.equal(manifest["m3e-switch"].length, 1);
  assert.equal(manifest["m3e-dialog"].length, 3, "m3e-dialog: basic + list + scrollable-list");
  assert.equal(manifest["m3e-list"].length, 1);
  assert.equal(manifest["m3e-tabs"].length, 1);
  assert.equal(manifest["m3e-toolbar"].length, 1);
  assert.equal(manifest["m3e-menu"].length, 1);
  assert.equal(manifest["m3e-tooltip"].length, 1);
  assert.equal(manifest["m3e-circular-progress-indicator"].length, 2);
  assert.equal(manifest["m3e-linear-progress-indicator"].length, 2);
  assert.equal(manifest["m3e-rich-tooltip"].length, 1);
  assert.equal(manifest["m3e-icon"].length, 141, "m3e-icon manifest entry must list all 141 icon bindings");
  assert.equal(manifest["m3e-tab"].length, 5, "m3e-tab manifest entry: 3 primary (icon-and-label + icon-only + label-only) + 2 secondary (icon-label + label-only)");
  assert.equal(manifest["m3e-chip-set"].length, 1);
  assert.equal(manifest["m3e-nav-bar"].length, 1);
  assert.equal(manifest["m3e-nav-rail"].length, 2, "m3e-nav-rail: Navigation Rail (collapsed) + Navigation Rail: Expanded");
  assert.equal(manifest["m3e-radio"].length, 1);
  assert.equal(manifest["m3e-datepicker"].length, 1, "m3e-datepicker: calendar (modal) only — text-entry moved to m3e-date-input");
  assert.equal(manifest["m3e-date-input"].length, 2, "m3e-date-input: modal-input + docked-input text-entry field");
  assert.equal(manifest["m3e-drawer-container"].length, 1);
  assert.equal(manifest["m3e-expandable-list-item"].length, 1);
  assert.equal(manifest["m3e-form-field"].length, 1);
  assert.equal(manifest["m3e-nav-menu"].length, 1);
  assert.equal(manifest["m3e-search-view"].length, 2, "m3e-search-view: docked + fullscreen");
  assert.equal(manifest["m3e-slider"].length, 2, "m3e-slider: standard + range");
  assert.equal(manifest["m3e-timepicker"].length, 2, "m3e-timepicker: dial + keyboard (mode variants)");
  assert.equal(manifest["m3e-timepicker-input-period-toggle"].length, 2, "m3e-timepicker-input-period-toggle: vertical + horizontal");
});

test("cli: --profile rejects a path, not just a name", () => {
  const result = runCli(["match", "--profile", "../etc"]);
  assert.equal(result.status, 2);
  assert.match(result.stderr, /bare name/);
});

test("validate: accepts data matching a trivial schema", () => {
  const schema = {
    type: "object",
    required: ["name"],
    properties: {
      name: { type: "string" },
      age: { type: "integer" },
    },
    additionalProperties: false,
  };

  const result = validate(schema, { name: "m3e-button", age: 5 });
  assert.deepEqual(result, { valid: true, errors: [] });
});

test("validate: rejects wrong type, missing required, and extra properties", () => {
  const schema = {
    type: "object",
    required: ["name"],
    properties: {
      name: { type: "string" },
    },
    additionalProperties: false,
  };

  const missingRequired = validate(schema, { extra: true });
  assert.equal(missingRequired.valid, false);
  assert.ok(missingRequired.errors.some((e) => e.includes('missing required property "name"')));
  assert.ok(missingRequired.errors.some((e) => e.includes('additional property "extra"')));

  const wrongType = validate(schema, { name: 42 });
  assert.equal(wrongType.valid, false);
  assert.ok(wrongType.errors.some((e) => e.includes("expected type string")));
});

test("validate: enforces enum values", () => {
  const schema = { type: "string", enum: ["a", "b"] };
  assert.equal(validate(schema, "a").valid, true);
  assert.equal(validate(schema, "c").valid, false);
});

test("cli: capture requires --profile and --channel", () => {
  const noProfile = runCli(["capture"]);
  assert.equal(noProfile.status, 2);
  assert.match(noProfile.stderr, /requires --profile/);
  const noChannel = runCli(["capture", "--profile", "m3-kit"]);
  assert.equal(noChannel.status, 2);
  assert.match(noChannel.stderr, /requires --channel/);
});
