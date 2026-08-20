// Task B2: emitter plugin API + deterministic emit runner.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test test/emitter-api.test.mjs
//
// Exercises src/emit/run.mjs against test/fixtures/toy-profile/ — a
// synthetic profile (NOT profiles/m3-kit) whose `emitters` array registers
// ONE dynamically-imported profile-local emitter
// (test/fixtures/toy-profile/emitters/toy.mjs) and whose correspondence.json
// is hand-built to exercise every filtering rule this task owns: status
// (confirmed/proposed/rejected), delta suppression, and --page.
//
// html-label's own emission behavior is NOT re-tested here (test/html-
// label.test.mjs already owns that, golden-fixture and all) — this file's
// job is the RUNNER (emitter resolution, ctx construction, file writing,
// manifest, determinism), using a throwaway toy emitter as the probe.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";
import crypto from "node:crypto";

import { runEmit, loadEmitters, computeEmitEntries } from "../src/emit/run.mjs";
import { slugify, figmaFileSlug, buildNodeUrl, conditionalLine, resolveCemComponent } from "../src/emit/emitter-api.mjs";
import { loadProfile } from "../src/correspond/merge.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..");
const toyProfileDir = path.join(here, "fixtures", "toy-profile");
const generatedRoot = path.join(repoRoot, "generated");

// generated/m3-kit/** is COMMITTED (task B2's decision — B4's `check` needs
// a committed baseline to diff against for drift detection; see
// .superpowers/sdd/task-B2-report.md). This test file only ever emits into
// the synthetic toy-profile/evil-profile profile names, so cleanup is
// scoped to JUST those two subdirectories — never `rmSync(generatedRoot)`,
// which would also delete the committed generated/m3-kit/** tree as an
// unrelated side effect of running this test file.
function cleanGenerated() {
  fs.rmSync(path.join(generatedRoot, "toy-profile"), { recursive: true, force: true });
  fs.rmSync(path.join(generatedRoot, "evil-profile"), { recursive: true, force: true });
}

function readTree(dir) {
  const out = {};
  for (const name of fs.readdirSync(dir).sort()) {
    out[name] = fs.readFileSync(path.join(dir, name), "utf8");
  }
  return out;
}

// -- emitter-api.mjs helpers (unit-level) -------------------------------------

test("slugify: ordinal kebab-case, not locale-sensitive", () => {
  assert.equal(slugify("Web Components"), "web-components");
  assert.equal(slugify("  Toy  "), "toy");
  assert.equal(slugify("A/B_C"), "a-b-c");
});

test("figmaFileSlug: every non-alphanumeric char becomes its own dash (Figma's own URL-slug algorithm)", () => {
  assert.equal(figmaFileSlug("Material 3 Design Kit (Community)"), "Material-3-Design-Kit--Community-");
});

test("buildNodeUrl: canonical form; throws on /branch/", () => {
  const url = buildNodeUrl({ fileKey: "ABC123", fileName: "My Kit" }, "1:2");
  assert.equal(url, "https://www.figma.com/design/ABC123/My-Kit?node-id=1-2");
  assert.throws(
    () => buildNodeUrl({ fileKey: "ABC123", fileName: "My Kit", url: "https://www.figma.com/design/ABC123/branch/xyz/My-Kit" }, "1:2"),
    /branch/
  );
});

test("conditionalLine: the VOLT-2003 idiom, generalized", () => {
  const line = conditionalLine({ lineVar: "xLine", condVar: "x", trueBody: "<a></a>" });
  assert.equal(line, "const xLine = x ? figma.code`<a></a>` : figma.code``");
});

test("resolveCemComponent: finds by tag, null when absent", () => {
  const cem = { components: [{ tag: "m3e-button" }, { tag: "m3e-badge" }] };
  assert.equal(resolveCemComponent(cem, "m3e-badge").tag, "m3e-badge");
  assert.equal(resolveCemComponent(cem, "no-such-tag"), null);
});

// -- loadEmitters: built-in + dynamic import -----------------------------------

test("loadEmitters: resolves the built-in 'html-label' by name", async () => {
  const profile = loadProfile(path.join(repoRoot, "profiles", "m3-kit"));
  const emitters = await loadEmitters(profile);
  // m3-kit registers the built-in html-label PLUS B3's profile-local Elm
  // emitter; the built-in must resolve by its bare name (this test's point).
  const htmlLabel = emitters.find((e) => e.name === "html-label");
  assert.ok(htmlLabel, "html-label should resolve by bare name");
  assert.equal(htmlLabel.label, "Web Components");
  // the Elm emitter resolves via its repo-root-relative path spec.
  assert.ok(emitters.some((e) => e.name === "elm" && e.label === "Elm"));
});

test("loadEmitters: dynamically imports a profile-local emitter by repo-root-relative path", async () => {
  const profile = loadProfile(toyProfileDir);
  const emitters = await loadEmitters(profile);
  assert.equal(emitters.length, 1);
  assert.equal(emitters[0].name, "toy");
  assert.equal(emitters[0].label, "toy");
  assert.equal(typeof emitters[0].emit, "function");
});

test("loadEmitters: throws Node's module-not-found error for a spec that doesn't resolve to any file", async () => {
  const badModulePath = path.join(here, "fixtures", "toy-profile", "emitters", "does-not-exist.mjs");
  const profile = { emitters: [path.relative(repoRoot, badModulePath)] };
  await assert.rejects(() => loadEmitters(profile));
});

test("loadEmitters: throws run.mjs's OWN custom validation error (not ENOENT) for a module that resolves but doesn't export a valid emitter shape, naming the missing fields", async () => {
  const invalidModulePath = path.join(here, "fixtures", "toy-profile", "emitters", "invalid-shape.mjs");
  const spec = path.relative(repoRoot, invalidModulePath);
  const profile = { emitters: [spec] };
  await assert.rejects(
    () => loadEmitters(profile),
    (err) => {
      assert.match(err.message, /does not export a valid emitter/);
      assert.match(err.message, /missing\/invalid: name, label, emit/);
      return true;
    }
  );
});

// -- loadEmitters: dynamic-import path containment (review fix, security) -----
//
// The emitter module path is `import()`ed as CODE — strictly more dangerous
// than the returned-file-path guard on WRITTEN DATA (below, run.mjs
// ~line 185+). An absolute path or a `../`-escaping relative path in
// profile.json's `emitters[]` must never reach `import()` unmodified.

test("loadEmitters: rejects an absolute emitters[] path before ever importing it", async () => {
  const absPath = path.join(repoRoot, "test", "fixtures", "toy-profile", "emitters", "toy.mjs");
  const profile = { emitters: [absPath] };
  await assert.rejects(() => loadEmitters(profile), /must not be an absolute path/);
});

test("loadEmitters: rejects a '..'-escaping relative emitters[] path before ever importing it", async () => {
  const profile = { emitters: ["../../../../../../etc/passwd"] };
  await assert.rejects(() => loadEmitters(profile), /escapes the repo root/);
});

// The legitimate case — a genuine profile-local relative path staying
// within the repo root — is already covered end-to-end by "loadEmitters:
// dynamically imports a profile-local emitter by repo-root-relative path"
// above; repeated here only as an explicit regression marker for this fix.
test("loadEmitters: a legitimate repo-root-relative profile-local path (contained) still loads", async () => {
  const profile = loadProfile(toyProfileDir);
  const emitters = await loadEmitters(profile);
  assert.equal(emitters.length, 1);
  assert.equal(emitters[0].name, "toy");
});

// -- computeEmitEntries: status / suppression / page filtering -----------------

test("computeEmitEntries: only status:confirmed AND not-suppressed entries, sorted by cemTag", () => {
  const { entries } = computeEmitEntries({ profileDir: toyProfileDir });
  const tags = entries.map((e) => e.cemTag);
  // m3e-app-bar (proposed), m3e-assist-chip (confirmed but suppressed), and
  // m3e-bottom-sheet (rejected) must all be absent.
  assert.deepEqual(tags, ["m3e-badge", "m3e-button"]);
});

test("computeEmitEntries: --page narrows to entries whose figma sets live on that kit page", () => {
  const buttons = computeEmitEntries({ profileDir: toyProfileDir, page: "Buttons" });
  assert.deepEqual(buttons.entries.map((e) => e.cemTag), ["m3e-button"]);

  const badges = computeEmitEntries({ profileDir: toyProfileDir, page: "Badges" });
  assert.deepEqual(badges.entries.map((e) => e.cemTag), ["m3e-badge"]);

  const noSuchPage = computeEmitEntries({ profileDir: toyProfileDir, page: "Nonexistent Page" });
  assert.deepEqual(noSuchPage.entries, []);
});

// -- runEmit: the toy emitter, end-to-end --------------------------------------

test("runEmit: toy emitter receives ctx and its files land under generated/<profile>/toy/", async () => {
  cleanGenerated();
  try {
    const results = await runEmit({ profileDir: toyProfileDir, profileName: "toy-profile" });
    assert.equal(results.length, 1);
    const [result] = results;
    assert.equal(result.name, "toy");
    assert.equal(result.label, "toy");
    assert.equal(result.labelSlug, "toy");

    const labelDir = path.join(generatedRoot, "toy-profile", "toy");
    assert.equal(result.dir, labelDir);
    assert.ok(fs.existsSync(labelDir), "generated/toy-profile/toy/ exists");

    const written = fs.readdirSync(labelDir).sort();
    assert.deepEqual(written, ["MANIFEST.json", "m3e-badge-badges.toy.txt", "m3e-button-button.toy.txt"]);

    const buttonFile = fs.readFileSync(path.join(labelDir, "m3e-button-button.toy.txt"), "utf8");
    assert.match(buttonFile, /^entry: m3e-button$/m);
    assert.match(buttonFile, /^set: Button \(57994:2227\)$/m);
    assert.match(buttonFile, /^url: https:\/\/www\.figma\.com\/design\/TOYFILEKEY0000000000000\//m);
    assert.match(buttonFile, /^cem: m3e-button$/m, "ctx.cem resolved the real CEM component for this tag");
  } finally {
    cleanGenerated();
  }
});

test("runEmit: MANIFEST.json lists EXACTLY the emitted files — no more, no less", async () => {
  cleanGenerated();
  try {
    const [result] = await runEmit({ profileDir: toyProfileDir, profileName: "toy-profile" });
    const labelDir = result.dir;
    const onDisk = new Set(fs.readdirSync(labelDir).filter((f) => f !== "MANIFEST.json"));
    const manifest = JSON.parse(fs.readFileSync(path.join(labelDir, "MANIFEST.json"), "utf8"));

    const manifestFiles = new Set(Object.values(manifest).flat());
    assert.deepEqual(manifestFiles, onDisk, "manifest's file set exactly equals what's on disk");
    assert.deepEqual(Object.keys(manifest).sort(), ["m3e-badge", "m3e-button"]);
    // Suppressed/rejected/proposed cemTags never appear as manifest keys.
    for (const absentTag of ["m3e-app-bar", "m3e-assist-chip", "m3e-bottom-sheet"]) {
      assert.ok(!(absentTag in manifest), `${absentTag} must not appear in the manifest`);
    }
  } finally {
    cleanGenerated();
  }
});

test("runEmit: stale files from a prior run (different entries) are wiped, not accumulated", async () => {
  cleanGenerated();
  try {
    const labelDir = path.join(generatedRoot, "toy-profile", "toy");
    fs.mkdirSync(labelDir, { recursive: true });
    fs.writeFileSync(path.join(labelDir, "stale-leftover.toy.txt"), "should not survive\n", "utf8");

    await runEmit({ profileDir: toyProfileDir, profileName: "toy-profile" });

    const written = fs.readdirSync(labelDir).sort();
    assert.ok(!written.includes("stale-leftover.toy.txt"), "stale file must be removed by the wipe-before-write step");
  } finally {
    cleanGenerated();
  }
});

test("runEmit: re-run is byte-stable (determinism gate)", async () => {
  cleanGenerated();
  try {
    await runEmit({ profileDir: toyProfileDir, profileName: "toy-profile" });
    const labelDir = path.join(generatedRoot, "toy-profile", "toy");
    const before = readTree(labelDir);

    await runEmit({ profileDir: toyProfileDir, profileName: "toy-profile" });
    const after = readTree(labelDir);

    assert.deepEqual(after, before, "byte-identical tree (including MANIFEST.json) across re-runs");
  } finally {
    cleanGenerated();
  }
});

test("runEmit: rejects an emitter-returned path escaping its label directory", async () => {
  cleanGenerated();
  const evilProfileDir = path.join(here, "fixtures", "evil-profile");
  const escapedPath = path.join(repoRoot, "escaped.txt");
  try {
    await assert.rejects(
      () => runEmit({ profileDir: evilProfileDir, profileName: "evil-profile" }),
      /unsafe path/
    );
    assert.ok(!fs.existsSync(escapedPath), "the path-traversal payload must never actually be written");
  } finally {
    fs.rmSync(escapedPath, { force: true });
    cleanGenerated();
  }
});

// -- CLI integration: node src/cli.mjs emit --profile <m3-kit copy> -----------
//
// (Root-cause test-isolation fix, review round.) These two tests exercise
// the CLI's --page wiring against the REAL m3-kit correspondence data (not
// the toy fixture) — but MUST NOT run `emit` against the real `--profile
// m3-kit`, because that writes (wipes-then-rewrites) the COMMITTED
// `generated/m3-kit/**` tree. `node --test` runs test FILES as concurrent
// processes, so a `--page`-narrowed (or nonexistent-page) emit here would
// otherwise race every other test file that reads
// `generated/m3-kit/**` (test/publish-check.test.mjs, test/smoke.test.mjs)
// — and this file's own `finally`/`cleanGenerated()` never restored
// `m3-kit` anyway, so a run of these two tests used to leave the committed
// tree mutated (narrowed to the Buttons-only entries, or wiped to empty
// MANIFESTs) until some OTHER file's test happened to re-emit it.
//
// Fix: copy just the two profileDir-relative inputs `emit` actually reads
// (profile.json, correspondence.json) into a throwaway `profiles/<tmp>/`
// dir and point `--profile` at that instead. Every OTHER path in
// profile.json (figmaExportPath, cem.manifestPath/dtsDir, and the Elm
// emitter's own repo-root-relative module path) is resolved against the
// REPO ROOT, not profileDir (src/correspond/merge.mjs's loadProfile doc
// comment; profiles/m3-kit/emitters/elm.mjs itself also reads
// elm-facts.json relative to its OWN file location, not profileDir) — so
// the copy still exercises the real m3-kit data/emitters end-to-end, it
// just writes to a throwaway `generated/<tmp>/**` instead of the committed
// `generated/m3-kit/**`.
function makeThrowawayM3KitProfile() {
  const tmpName = `m3-kit-cli-test-${crypto.randomUUID()}`;
  const tmpProfileDir = path.join(repoRoot, "profiles", tmpName);
  fs.mkdirSync(tmpProfileDir, { recursive: true });
  for (const file of ["profile.json", "correspondence.json", "matcher.json"]) {
    fs.copyFileSync(path.join(repoRoot, "profiles", "m3-kit", file), path.join(tmpProfileDir, file));
  }
  return tmpName;
}

function cleanThrowawayM3KitProfile(tmpName) {
  fs.rmSync(path.join(repoRoot, "profiles", tmpName), { recursive: true, force: true });
  fs.rmSync(path.join(generatedRoot, tmpName), { recursive: true, force: true });
}

test("cli: emit --profile <m3-kit copy> --page Buttons filters to the Buttons-page entries", () => {
  const tmpName = makeThrowawayM3KitProfile();
  try {
    const result = spawnSync(process.execPath, [path.join(repoRoot, "src", "cli.mjs"), "emit", "--profile", tmpName, "--page", "Buttons"], {
      cwd: repoRoot,
      encoding: "utf8",
    });
    assert.equal(result.status, 0);
    assert.match(result.stdout, /emit: wrote 26 file\(s\)/);
  } finally {
    cleanThrowawayM3KitProfile(tmpName);
  }
});

test("cli: emit --profile <m3-kit copy> --page <nonexistent> emits zero files", () => {
  const tmpName = makeThrowawayM3KitProfile();
  try {
    const result = spawnSync(process.execPath, [path.join(repoRoot, "src", "cli.mjs"), "emit", "--profile", tmpName, "--page", "Nonexistent"], {
      cwd: repoRoot,
      encoding: "utf8",
    });
    assert.equal(result.status, 0);
    assert.match(result.stdout, /emit: wrote 0 file\(s\)/);
  } finally {
    cleanThrowawayM3KitProfile(tmpName);
  }
});
