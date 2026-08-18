// Task B4: publish/unpublish runner (src/publish/runner.mjs) + drift/orphan
// CI gate (src/publish/check.mjs).
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test test/publish-check.test.mjs
//
// OFFLINE, per the task's scope: every `figma connect publish`/`unpublish`
// invocation in this file is a FAKE `execFn` — no test here ever touches
// the network or needs a real FIGMA_ACCESS_TOKEN (the one real exec path,
// `defaultExec`, is exercised nowhere in this suite; that's B5's job, ⚑
// HUMAN, with a real token). `generated/m3-kit/**` (the real, committed
// tree) is only ever READ here (the URL-rewrite tests) — every write goes
// to a scratch `generated/b4-profile/` dir (mirroring the toy-profile/
// evil-profile convention in test/emitter-api.test.mjs) or an OS temp dir,
// both cleaned up per test.

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  rewriteFigmaTsForFileKey,
  materializeStaging,
  writeFigmaConfig,
  requireToken,
  resolveStatusFn,
  publish,
  unpublish,
  readPublished,
  writePublished,
  redact,
} from "../src/publish/runner.mjs";
import { runCheck, codeOnly, computeInMemoryEmit } from "../src/publish/check.mjs";
import { runEmit } from "../src/emit/run.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..");
const generatedRoot = path.join(repoRoot, "generated");

const b4ProfileDir = path.join(here, "fixtures", "b4-profile");
const b4ProfileName = "b4-profile";
const b4LabelSlug = "web-components"; // html-label's own `label`, slugified

const REAL_M3_KIT_DIR = path.join(repoRoot, "profiles", "m3-kit");
const THROWAWAY_FILE_KEY = "iPFL8MH2R1Xphe94j7g809"; // brief's own example throwaway target

// Task C6 landed src/visual/status.mjs, which ACTIVATES resolveStatusFn's
// "module present" branch by default (no statusModulePath override needed
// to find it — it's just there at the real path now). Every test below that
// is NOT specifically about the publishability gate (i.e. everything except
// the "-- publishability guard --" block, which already injects its own
// b4-status-{passing,blocking}.mjs fixtures) predates C6 and is testing
// something else entirely (drift, token redaction, label filtering,
// staging...) against the synthetic b4-profile fixture, whose entries
// (m3e-badge, m3e-bottom-sheet) have no committed visual results and would
// now resolve to "pending" under the REAL status.mjs — which would make
// publish() refuse and break these tests for a reason unrelated to what
// they're actually verifying. Pointing statusModulePath at this deliberately
// NONEXISTENT path forces resolveStatusFn back to its null/warn-and-pass
// branch, exactly reproducing this suite's pre-C6 behavior for those tests
// — without weakening the (separate, still fully real) publishability-guard
// tests below, and without touching runner.mjs itself.
const NO_STATUS_MODULE = path.join(here, "fixtures", "b4-status-none-such-file.mjs");

function cleanB4Generated() {
  fs.rmSync(path.join(generatedRoot, b4ProfileName), { recursive: true, force: true });
}

function mkScratchDir() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-b4-test-"));
}

function makeFakeExec(response = { status: 0, stdout: "All Code Connect files are valid", stderr: "" }) {
  const calls = [];
  const fn = (invocation) => {
    calls.push(invocation);
    return typeof response === "function" ? response(invocation) : response;
  };
  fn.calls = calls;
  return fn;
}

// -- codeOnly (check.mjs) ------------------------------------------------------

test("codeOnly: strips /** */ block comments and whole-line // comments and blank lines, but normalizes (not drops) the url= line's node-id", () => {
  const src = [
    "// url=https://www.figma.com/design/ABC/x?node-id=1-2",
    "/**",
    " * GENERATED — do not edit.",
    " * some rationale prose",
    " */",
    "",
    "const x = 1",
    "",
    "const y = 2",
  ].join("\n");
  assert.equal(codeOnly(src), "// node-id=1-2\nconst x = 1\nconst y = 2");
});

test("codeOnly: an inline (not whole-line) // is left alone — never touches real code", () => {
  const src = 'const url = "https://example.com" // trailing note';
  assert.equal(codeOnly(src), src.trimEnd());
});

test("codeOnly: two sources differing only in the url= line's fileKey/slug / header prose / blank lines compare equal (node-id unchanged)", () => {
  const a = "// url=https://www.figma.com/design/AAA/x?node-id=1-2\n/**\n * v1 rationale\n */\n\nconst z = 3\n";
  const b = "// url=https://www.figma.com/design/BBB/y?node-id=1-2\n/**\n * v2 rationale, longer\n */\nconst z = 3\n";
  assert.equal(codeOnly(a), codeOnly(b));
});

// WB-review N1 fix: the drift check must NOT be blind to a changed node-id
// — that's the whole point of this fix (a stale nodeId in committed
// generated/** used to slip past `check` as a false-negative because the
// entire url= line, node-id included, was blanket-stripped).
test("codeOnly: two sources differing ONLY in the url= line's node-id are NOT equal (node-id-sensitive)", () => {
  const a = "// url=https://www.figma.com/design/AAA/x?node-id=1-2\n/**\n * same rationale\n */\n\nconst z = 3\n";
  const b = "// url=https://www.figma.com/design/AAA/x?node-id=9-9\n/**\n * same rationale\n */\n\nconst z = 3\n";
  assert.notEqual(codeOnly(a), codeOnly(b));
});

// -- rewriteFigmaTsForFileKey — against the REAL committed generated/m3-kit tree --

test("rewriteFigmaTsForFileKey: every committed generated/m3-kit/**/*.figma.ts url= line swaps fileKey, node-id intact", async () => {
  // No self-heal re-emit needed here (review round, root-cause test-
  // isolation fix): the only test that used to destructively wipe/narrow
  // the committed generated/m3-kit/** tree (test/emitter-api.test.mjs's
  // --page CLI tests) now runs against a throwaway profile copy instead —
  // this file reads the committed tree exactly as checked in.
  for (const labelSlug of ["elm", "web-components"]) {
    const dir = path.join(generatedRoot, "m3-kit", labelSlug);
    const files = fs.readdirSync(dir).filter((f) => f.endsWith(".figma.ts"));
    assert.ok(files.length > 0, `expected .figma.ts files under ${dir}`);

    for (const name of files) {
      const original = fs.readFileSync(path.join(dir, name), "utf8");
      const originalUrlLine = original.split("\n")[0];
      const nodeIdMatch = originalUrlLine.match(/\?node-id=([A-Za-z0-9-]+)/);
      assert.ok(nodeIdMatch, `${name}'s first line should be a // url= line with a node-id`);

      const rewritten = rewriteFigmaTsForFileKey(original, THROWAWAY_FILE_KEY);
      const rewrittenUrlLine = rewritten.split("\n")[0];

      assert.equal(
        rewrittenUrlLine,
        `// url=https://www.figma.com/design/${THROWAWAY_FILE_KEY}/x?node-id=${nodeIdMatch[1]}`,
        `${name}: rewritten url line`
      );
      // Everything after the first line is untouched.
      assert.equal(rewritten.slice(rewritten.indexOf("\n")), original.slice(original.indexOf("\n")));
    }
  }
});

test("rewriteFigmaTsForFileKey: throws (fail-loud) when there is no // url= line to rewrite", () => {
  assert.throws(() => rewriteFigmaTsForFileKey('import figma from "figma"\n', "X"), /no "\/\/ url=" line/);
});

// -- materializeStaging + writeFigmaConfig -------------------------------------

test("materializeStaging: stages every .figma.ts from generated/<profile>/<label>/, url= rewritten, node-ids intact", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });

    const { dir, files } = materializeStaging({
      repoRoot,
      profileName: b4ProfileName,
      labelSlug: b4LabelSlug,
      fileKey: THROWAWAY_FILE_KEY,
      stagingRoot: path.join(scratch, "staging"),
    });

    assert.deepEqual(files.sort(), ["m3e-badge-badges.figma.ts", "m3e-bottom-sheet-bottom-sheet.figma.ts"]);

    const badge = fs.readFileSync(path.join(dir, "m3e-badge-badges.figma.ts"), "utf8");
    assert.match(
      badge,
      new RegExp(`^// url=https://www\\.figma\\.com/design/${THROWAWAY_FILE_KEY}/x\\?node-id=51592-4768$`, "m")
    );

    const bottomSheet = fs.readFileSync(path.join(dir, "m3e-bottom-sheet-bottom-sheet.figma.ts"), "utf8");
    assert.match(
      bottomSheet,
      new RegExp(`^// url=https://www\\.figma\\.com/design/${THROWAWAY_FILE_KEY}/x\\?node-id=51827-5859$`, "m")
    );

    writeFigmaConfig(dir, "Web Components");
    const config = JSON.parse(fs.readFileSync(path.join(dir, "figma.config.json"), "utf8"));
    assert.deepEqual(config, {
      codeConnect: { parser: "html", include: ["*.figma.ts"], exclude: [], label: "Web Components" },
    });
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("materializeStaging: throws clearly when the source label dir doesn't exist (emit hasn't run)", () => {
  cleanB4Generated();
  assert.throws(
    () =>
      materializeStaging({
        repoRoot,
        profileName: b4ProfileName,
        labelSlug: b4LabelSlug,
        fileKey: THROWAWAY_FILE_KEY,
      }),
    /no generated output at/
  );
});

// -- requireToken: env-only, never a file --------------------------------------

test("requireToken: throws when FIGMA_ACCESS_TOKEN is absent from the given env, and says it refuses to read a file", () => {
  assert.throws(() => requireToken({}), /FIGMA_ACCESS_TOKEN is not set/);
  assert.throws(() => requireToken({}), /refuses to read a token from any file/);
});

test("requireToken: returns the token when present in the given env", () => {
  assert.equal(requireToken({ FIGMA_ACCESS_TOKEN: "shh" }), "shh");
});

// -- resolveStatusFn: D8's warn-and-pass fallback ------------------------------

// Task C6 landed src/visual/status.mjs — the gate is now genuinely active by
// default (no override needed), which is the opposite of what this test
// used to assert ("does not exist (true today, pre-Plan-C)"). Per this
// task's brief ("adjust them to assert the new correct behavior"), this is
// rewritten to prove the module resolves for real, plus a second test
// confirming the null/warn-and-pass branch is still reachable on demand
// (an explicit, deliberately nonexistent statusModulePath).
test("resolveStatusFn: resolves the REAL src/visual/status.mjs now that Plan C's gate exists (no longer null-by-default)", async () => {
  assert.equal(fs.existsSync(path.join(repoRoot, "src", "visual", "status.mjs")), true);
  const fn = await resolveStatusFn({ repoRoot });
  assert.equal(typeof fn, "function");
});

test("resolveStatusFn: the REAL status.mjs, called on the REAL m3e-button entry, reports its committed gate decision ('approved') — proving the now-active gate genuinely derives a real decision, not just 'module present'", async () => {
  const fn = await resolveStatusFn({ repoRoot });
  const correspondence = JSON.parse(fs.readFileSync(path.join(REAL_M3_KIT_DIR, "correspondence.json"), "utf8"));
  const buttonEntry = correspondence.find((e) => e.cemTag === "m3e-button");
  assert.ok(buttonEntry, "sanity: the real m3-kit profile carries a confirmed m3e-button entry");
  // m3e-button was human-approved in the 2026-07-13 visual gate (overrides.json
  // gate:"approved"); the gate derives that real decision, not null/module-present.
  // A controlled empty resultsDir is passed so this test never reads from the
  // shared render-cache/results/ — the override branch fires before latestRunRecords
  // is ever called, so resultsDir contents are irrelevant to the gate decision being
  // proven here (the test is hermetic regardless of any stray gate run on disk).
  const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-b4-resolve-test-"));
  try {
    const resultsDir = path.join(scratch, "results"); // empty, never created — override wins first
    assert.equal(fn(buttonEntry, { resultsDir }), "approved");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
  }
});

test("resolveStatusFn: still returns null (the warn-and-pass fallback) when explicitly pointed at a nonexistent module path", async () => {
  const fn = await resolveStatusFn({ repoRoot, statusModulePath: NO_STATUS_MODULE });
  assert.equal(fn, null);
});

test("resolveStatusFn: throws if the resolved module exists but has no status/default export function", async () => {
  await assert.rejects(
    () =>
      resolveStatusFn({
        repoRoot,
        statusModulePath: path.join(here, "fixtures", "b4-status-invalid-shape.mjs"),
      }),
    /does not export a `status` function/
  );
});

test("resolveStatusFn: resolves a fixture module's exported status()", async () => {
  const fn = await resolveStatusFn({
    repoRoot,
    statusModulePath: path.join(here, "fixtures", "b4-status-passing.mjs"),
  });
  assert.equal(typeof fn, "function");
  assert.equal(fn({ cemTag: "anything" }), "approved");
});

// -- runCheck: DRIFT + ORPHAN ---------------------------------------------------

test("runCheck: a freshly emitted tree is clean (no drift, no orphan)", async () => {
  cleanB4Generated();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const result = await runCheck({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    assert.deepEqual(result, { ok: true, drift: [], orphan: [] });
  } finally {
    cleanB4Generated();
  }
});

test("runCheck: catches a hand-edited committed file as DRIFT", async () => {
  cleanB4Generated();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const filePath = path.join(generatedRoot, b4ProfileName, b4LabelSlug, "m3e-badge-badges.figma.ts");
    const original = fs.readFileSync(filePath, "utf8");
    // A genuine CODE edit (not a comment-only one — see the codeOnly test
    // below for that case): inject an extra real statement.
    const edited = original.replace(
      "const instance = figma.selectedInstance",
      'const instance = figma.selectedInstance\nconst handEdited = "not part of the real output"'
    );
    assert.notEqual(edited, original, "the edit must actually land somewhere in the file");
    fs.writeFileSync(filePath, edited, "utf8");

    const result = await runCheck({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    assert.equal(result.ok, false);
    assert.equal(result.orphan.length, 0);
    assert.equal(result.drift.length, 1);
    assert.equal(result.drift[0].path, `${b4LabelSlug}/m3e-badge-badges.figma.ts`);
    assert.match(result.drift[0].reason, /differs from regenerated output/);
  } finally {
    cleanB4Generated();
  }
});

// WB-review N1 fix: a changed node-id in the committed `// url=` line — the
// ONLY difference from what a fresh re-emit would produce (e.g. a stale
// node-id left behind after correspondence.json's figmaSets[].nodeId
// changed and someone forgot to re-run `emit`) — must be caught as DRIFT.
// Before this fix, codeOnly() blanket-stripped the whole url= line
// (node-id included), so this exact scenario stayed invisible/GREEN.
test("runCheck: catches a changed node-id in the committed // url= line as DRIFT (node-id drift alone, no other code change)", async () => {
  cleanB4Generated();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const filePath = path.join(generatedRoot, b4ProfileName, b4LabelSlug, "m3e-badge-badges.figma.ts");
    const original = fs.readFileSync(filePath, "utf8");
    const originalUrlLine = original.split("\n")[0];
    const nodeIdMatch = originalUrlLine.match(/\?node-id=([A-Za-z0-9-]+)/);
    assert.ok(nodeIdMatch, "m3e-badge-badges.figma.ts's first line should be a // url= line with a node-id");
    assert.notEqual(nodeIdMatch[1], "99999-9999", "sanity: the swapped-in node-id must differ from the real one");

    const editedUrlLine = originalUrlLine.replace(`node-id=${nodeIdMatch[1]}`, "node-id=99999-9999");
    const edited = original.replace(originalUrlLine, editedUrlLine);
    assert.notEqual(edited, original, "the node-id edit must actually land in the file");
    fs.writeFileSync(filePath, edited, "utf8");

    const result = await runCheck({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    assert.equal(result.ok, false);
    assert.equal(result.orphan.length, 0);
    assert.equal(result.drift.length, 1);
    assert.equal(result.drift[0].path, `${b4LabelSlug}/m3e-badge-badges.figma.ts`);
    assert.match(result.drift[0].reason, /differs from regenerated output/);
  } finally {
    cleanB4Generated();
  }
});

test("runCheck: a comment/whitespace-only hand-edit does NOT count as drift (code-only diffing)", async () => {
  cleanB4Generated();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const filePath = path.join(generatedRoot, b4ProfileName, b4LabelSlug, "m3e-badge-badges.figma.ts");
    const original = fs.readFileSync(filePath, "utf8");
    fs.writeFileSync(filePath, original + "\n\n\n// a trailing comment that changes nothing code-wise\n", "utf8");

    const result = await runCheck({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    assert.deepEqual(result, { ok: true, drift: [], orphan: [] });
  } finally {
    cleanB4Generated();
  }
});

test("runCheck: catches a stray committed file with no producing correspondence entry as ORPHAN", async () => {
  cleanB4Generated();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const labelDir = path.join(generatedRoot, b4ProfileName, b4LabelSlug);
    fs.writeFileSync(path.join(labelDir, "m3e-nonexistent-tag.figma.ts"), "// stray file\n", "utf8");

    const result = await runCheck({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    assert.equal(result.ok, false);
    assert.equal(result.drift.length, 0);
    assert.equal(result.orphan.length, 1);
    assert.equal(result.orphan[0].path, `${b4LabelSlug}/m3e-nonexistent-tag.figma.ts`);
  } finally {
    cleanB4Generated();
  }
});

test("runCheck: an entirely unregistered label directory is wholly orphaned", async () => {
  cleanB4Generated();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const strayLabelDir = path.join(generatedRoot, b4ProfileName, "some-old-label");
    fs.mkdirSync(strayLabelDir, { recursive: true });
    fs.writeFileSync(path.join(strayLabelDir, "leftover.figma.ts"), "// stray\n", "utf8");
    fs.writeFileSync(path.join(strayLabelDir, "MANIFEST.json"), "{}\n", "utf8");

    const result = await runCheck({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    assert.equal(result.ok, false);
    assert.equal(result.drift.length, 0);
    const paths = result.orphan.map((o) => o.path).sort();
    assert.deepEqual(paths, ["some-old-label/MANIFEST.json", "some-old-label/leftover.figma.ts"]);
  } finally {
    cleanB4Generated();
  }
});

test("computeInMemoryEmit: matches computeEmitEntries' entry set (badge + bottom-sheet), no fs writes", async () => {
  cleanB4Generated(); // nothing should be written even without cleanup, this asserts that
  const before = fs.existsSync(path.join(generatedRoot, b4ProfileName));
  const labels = await computeInMemoryEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
  assert.equal(labels.length, 1);
  assert.equal(labels[0].labelSlug, b4LabelSlug);
  assert.deepEqual(Object.keys(labels[0].manifest).sort(), ["m3e-badge", "m3e-bottom-sheet"]);
  assert.equal(fs.existsSync(path.join(generatedRoot, b4ProfileName)), before, "computeInMemoryEmit must not touch fs");
});

// -- pnpm run check on the REAL committed m3-kit tree --------------------------

test("runCheck: the REAL committed profiles/m3-kit + generated/m3-kit/** passes clean today", async () => {
  // No self-heal re-emit needed (see rewriteFigmaTsForFileKey test above) —
  // the root-cause fix means nothing in this suite mutates generated/m3-kit/**
  // out from under a reader anymore.
  const result = await runCheck({ profileDir: REAL_M3_KIT_DIR, profileName: "m3-kit" });
  assert.deepEqual(result, { ok: true, drift: [], orphan: [] }, JSON.stringify(result, null, 2));
});

// -- publish(): kitVersionTag placeholder guard (carry-in requirement, WB/m6) --

test("publish: refuses a profile whose kitVersionTag is still the A3 placeholder (synthetic profile — decoupled from the now-stamped real m3-kit profile)", async () => {
  // The real m3-kit profile has carried a real kitVersionTag since the
  // 2026-07-13 A3 live extraction, so the guard can no longer be exercised
  // against it. Prove the guard still fires by pointing publish() at a
  // synthetic profile.json that reinstates the placeholder — the guard runs
  // right after loadProfile, before anything reads generated/.
  const execFn = makeFakeExec();
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), "cfc-placeholder-"));
  try {
    const profile = JSON.parse(fs.readFileSync(path.join(REAL_M3_KIT_DIR, "profile.json"), "utf8"));
    profile.kitVersionTag = "unknown-pre-a3-fixture";
    fs.writeFileSync(path.join(tmpDir, "profile.json"), `${JSON.stringify(profile, null, 2)}\n`);
    // loadProfile() also requires matcher.json (finding 2.4) — copy the real
    // m3-kit one so this test still exercises the kitVersionTag guard itself,
    // not an unrelated "matcher.json missing" failure.
    fs.copyFileSync(path.join(REAL_M3_KIT_DIR, "matcher.json"), path.join(tmpDir, "matcher.json"));
    await assert.rejects(
      () =>
        publish({
          profileDir: tmpDir,
          profileName: "m3-kit",
          label: "Elm",
          fileKey: THROWAWAY_FILE_KEY,
          dryRun: true,
          env: { FIGMA_ACCESS_TOKEN: "fake-token-never-used" },
          execFn,
        }),
      (err) => {
        assert.match(err.message, /kitVersionTag/);
        assert.match(err.message, /unknown-pre-a3-fixture/);
        assert.match(err.message, /A3/);
        return true;
      }
    );
    assert.equal(execFn.calls.length, 0, "must refuse before ever touching exec");
  } finally {
    fs.rmSync(tmpDir, { recursive: true, force: true });
  }
});

// -- publish(): full offline flow, warn-and-pass fallback ----------------------
//
// WB-review N4 fix: `publish --dry-run` must not persist state — it used to
// write a `{dryRun:true, ...}` entry into published.json unconditionally,
// which a LATER real `unpublish` could act on, and which an audit could
// misread as a real publish. The dry run still computes and returns its
// full `results` (nodeIds, stdout, staging dir, etc.); it just must not
// touch published.json on disk.

test("publish: --dry-run full offline flow (warn-and-pass when statusModulePath points at a nonexistent module) returns results, never logs env, never calls the real exec, and does NOT persist published.json", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  const publishedJsonPath = path.join(scratch, "published.json");
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    assert.equal(fs.existsSync(publishedJsonPath), false, "sanity: no published.json before the dry run");

    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token-never-used" },
      execFn,
      publishedJsonPath,
      stagingRoot: path.join(scratch, "staging"),
      now: () => "2026-07-11T00:00:00.000Z",
      statusModulePath: NO_STATUS_MODULE,
    });

    assert.equal(result.warnAndPass, true);
    assert.equal(result.results.length, 1);
    const [r] = result.results;
    assert.equal(r.label, "Web Components");
    assert.equal(r.fileKey, THROWAWAY_FILE_KEY);
    assert.equal(r.dryRun, true);
    assert.deepEqual(r.nodeIds.sort(), ["51592:4768", "51827:5859"]);

    assert.equal(execFn.calls.length, 1);
    const call = execFn.calls[0];
    assert.deepEqual(call.args, ["connect", "publish", "--skip-update-check", "--dry-run"]);
    assert.equal(call.cwd, r.stagingDir);
    assert.equal(call.env.FIGMA_ACCESS_TOKEN, "fake-token-never-used");

    // The core of the fix: a dry run must not create (or, in a pre-existing-
    // file scenario, modify) published.json.
    assert.equal(fs.existsSync(publishedJsonPath), false, "dry run must not create published.json");
    assert.deepEqual(readPublished(publishedJsonPath), {});
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("publish: --dry-run does NOT modify a PRE-EXISTING published.json (unrelated prior binding stays untouched)", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  const publishedJsonPath = path.join(scratch, "published.json");
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });

    const preexisting = {
      "some-other-file-key": { "Web Components": { publishedAt: "2026-01-01T00:00:00.000Z", dryRun: false, nodeIds: ["1:1"] } },
    };
    writePublished(publishedJsonPath, preexisting);
    const beforeMtime = fs.statSync(publishedJsonPath).mtimeMs;

    const execFn = makeFakeExec();
    await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token-never-used" },
      execFn,
      publishedJsonPath,
      stagingRoot: path.join(scratch, "staging"),
      statusModulePath: NO_STATUS_MODULE,
    });

    assert.deepEqual(readPublished(publishedJsonPath), preexisting, "dry run must not touch the existing file's contents");
    assert.equal(fs.statSync(publishedJsonPath).mtimeMs, beforeMtime, "dry run must not even rewrite the file");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("publish: a REAL (non-dry-run, stubbed-exec) publish DOES persist published.json", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  const publishedJsonPath = path.join(scratch, "published.json");
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });

    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: false,
      env: { FIGMA_ACCESS_TOKEN: "fake-token-never-used" },
      execFn,
      publishedJsonPath,
      stagingRoot: path.join(scratch, "staging"),
      now: () => "2026-07-11T00:00:00.000Z",
      statusModulePath: NO_STATUS_MODULE,
    });

    assert.equal(result.results[0].dryRun, false);
    assert.equal(fs.existsSync(publishedJsonPath), true, "a real publish must persist published.json");

    const state = readPublished(publishedJsonPath);
    assert.deepEqual(state, {
      [THROWAWAY_FILE_KEY]: {
        "Web Components": {
          publishedAt: "2026-07-11T00:00:00.000Z",
          dryRun: false,
          nodeIds: ["51592:4768", "51827:5859"],
        },
      },
    });
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("publish: refuses when `check` fails (drift) — never calls exec", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const filePath = path.join(generatedRoot, b4ProfileName, b4LabelSlug, "m3e-badge-badges.figma.ts");
    // A genuine CODE edit (see the check.mjs tests for why a comment-only
    // edit deliberately would NOT trigger this).
    fs.writeFileSync(
      filePath,
      fs.readFileSync(filePath, "utf8").replace(
        "const instance = figma.selectedInstance",
        'const instance = figma.selectedInstance\nconst handEdited = "not part of the real output"'
      ),
      "utf8"
    );

    const execFn = makeFakeExec();
    await assert.rejects(
      () =>
        publish({
          profileDir: b4ProfileDir,
          profileName: b4ProfileName,
          fileKey: THROWAWAY_FILE_KEY,
          dryRun: true,
          env: { FIGMA_ACCESS_TOKEN: "fake-token" },
          execFn,
          publishedJsonPath: path.join(scratch, "published.json"),
          stagingRoot: path.join(scratch, "staging"),
        }),
      /check` failed/
    );
    assert.equal(execFn.calls.length, 0);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("publish: refuses when FIGMA_ACCESS_TOKEN is missing from env, before check/staging/exec", async () => {
  cleanB4Generated();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();
    await assert.rejects(
      () =>
        publish({
          profileDir: b4ProfileDir,
          profileName: b4ProfileName,
          fileKey: THROWAWAY_FILE_KEY,
          env: {},
          execFn,
        }),
      /FIGMA_ACCESS_TOKEN is not set/
    );
    assert.equal(execFn.calls.length, 0);
  } finally {
    cleanB4Generated();
  }
});

// -- publish(): publishability guard, WITH a fixture visual/status.mjs --------
//
// Task C7 superseded the pre-C7 all-or-nothing behavior (ANY blocked cemTag
// in a label refused the WHOLE label, publishing nothing) with a real
// per-binding gate: a label with a mix of publishable and blocked cemTags
// still publishes the publishable ones, and lists the rest in
// `results[].gate.blocked` instead of throwing. The two tests below used to
// assert the old throw-based behavior against b4-status-blocking.mjs
// (m3e-badge "pending", m3e-bottom-sheet "approved") — rewritten here to
// assert the new partial-publish behavior instead.

test("publish: a present status module BLOCKING one entry (of two) publishes ONLY the publishable one; the blocked one is listed in the summary, not staged", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath: path.join(scratch, "published.json"),
      stagingRoot: path.join(scratch, "staging"),
      statusModulePath: path.join(here, "fixtures", "b4-status-blocking.mjs"),
    });

    assert.equal(result.warnAndPass, false);
    const [r] = result.results;
    // Exactly the publishable one is staged/published — the blocked
    // m3e-badge's file never makes it into staging at all.
    assert.deepEqual(r.files, ["m3e-bottom-sheet-bottom-sheet.figma.ts"]);
    assert.deepEqual(r.gate.published, ["m3e-bottom-sheet"]);
    assert.equal(r.gate.forced, false);
    assert.equal(r.gate.blocked.length, 1);
    assert.equal(r.gate.blocked[0].cemTag, "m3e-badge");
    assert.equal(r.gate.blocked[0].status, "pending");
    assert.deepEqual(r.gate.blocked[0].diffs, []); // "pending" never has a diff artifact
    assert.equal(execFn.calls.length, 1, "the publishable half still calls `figma connect publish`");

    // published.json's nodeIds reflect only what was ACTUALLY published.
    assert.deepEqual(r.nodeIds, ["51827:5859"]); // m3e-bottom-sheet's nodeId only
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("publish: a present status module PASSING every entry publishes normally (not warn-and-pass), gate.blocked empty", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath: path.join(scratch, "published.json"),
      stagingRoot: path.join(scratch, "staging"),
      statusModulePath: path.join(here, "fixtures", "b4-status-passing.mjs"),
    });
    assert.equal(result.warnAndPass, false);
    assert.equal(execFn.calls.length, 1);
    const [r] = result.results;
    assert.deepEqual(r.gate.blocked, []);
    assert.deepEqual(r.gate.published.sort(), ["m3e-badge", "m3e-bottom-sheet"]);
    assert.equal(r.gate.forced, false);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

// -- publish(): task C7 acceptance — ONE passing + ONE failing binding -------
//
// The brief's exact verify scenario: a fixture profile with one passing
// binding and one failing binding. The publish SET must contain EXACTLY the
// passing one (the failing one listed in the summary with its diff path,
// not published); `--force-gate` publishes BOTH and flags the record
// `forced: true`.

test("publish: ONE passing + ONE failing binding -> publish set is EXACTLY the passing one; the failing one is listed with its diff path, not published", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath: path.join(scratch, "published.json"),
      stagingRoot: path.join(scratch, "staging"),
      statusModulePath: path.join(here, "fixtures", "b4-status-failing.mjs"),
    });

    const [r] = result.results;
    assert.deepEqual(r.files, ["m3e-bottom-sheet-bottom-sheet.figma.ts"]);
    assert.deepEqual(r.gate.published, ["m3e-bottom-sheet"]);
    assert.equal(r.gate.forced, false);
    assert.equal(r.gate.blocked.length, 1);
    assert.deepEqual(r.gate.blocked[0], {
      cemTag: "m3e-badge",
      status: "failed",
      diffs: ["/fake/render-cache/diffs/m3e-badge__default.png"],
    });
    assert.equal(execFn.calls.length, 1);

    // dryRun, so published.json isn't written — but the in-memory record the
    // write WOULD have made is exactly what we check via nodeIds above; a
    // real (non-dry) run's persisted record is covered by the next test.
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("publish --force-gate: BOTH the passing and the failing binding publish; the run + published.json record are flagged forced:true", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  const publishedJsonPath = path.join(scratch, "published.json");
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: false,
      forceGate: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath,
      stagingRoot: path.join(scratch, "staging"),
      now: () => "2026-07-11T00:00:00.000Z",
      statusModulePath: path.join(here, "fixtures", "b4-status-failing.mjs"),
    });

    const [r] = result.results;
    assert.deepEqual(r.files.sort(), ["m3e-badge-badges.figma.ts", "m3e-bottom-sheet-bottom-sheet.figma.ts"]);
    assert.deepEqual(r.gate.published.sort(), ["m3e-badge", "m3e-bottom-sheet"]);
    assert.equal(r.gate.forced, true);
    assert.equal(r.gate.blocked.length, 1);
    assert.equal(r.gate.blocked[0].cemTag, "m3e-badge");
    assert.equal(execFn.calls.length, 1);

    // published.json's record for this (fileKey, label) is stamped forced:true.
    const state = readPublished(publishedJsonPath);
    assert.equal(state[THROWAWAY_FILE_KEY]["Web Components"].forced, true);
    assert.deepEqual(state[THROWAWAY_FILE_KEY]["Web Components"].nodeIds.sort(), ["51592:4768", "51827:5859"]);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

// -- publish(): a `pending` binding (no committed visual results) ------------
//
// b4-status-blocking.mjs reports m3e-badge as "pending" (no override, no
// results — the everyday pre-first-render state, e.g. today's real
// confirmed m3e-button). Refused without --force-gate; force-published with
// it, exactly like the "failed" case above.

test("publish: a `pending` binding (no renders) is refused without --force-gate", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath: path.join(scratch, "published.json"),
      stagingRoot: path.join(scratch, "staging"),
      statusModulePath: path.join(here, "fixtures", "b4-status-blocking.mjs"),
    });
    const [r] = result.results;
    assert.equal(r.gate.blocked.some((b) => b.cemTag === "m3e-badge" && b.status === "pending"), true);
    assert.equal(r.gate.published.includes("m3e-badge"), false);
    assert.equal(r.gate.forced, false);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("publish --force-gate: a `pending` binding IS force-published, flagged forced:true", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      forceGate: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath: path.join(scratch, "published.json"),
      stagingRoot: path.join(scratch, "staging"),
      statusModulePath: path.join(here, "fixtures", "b4-status-blocking.mjs"),
    });
    const [r] = result.results;
    assert.deepEqual(r.gate.published.sort(), ["m3e-badge", "m3e-bottom-sheet"]);
    assert.equal(r.gate.forced, true);
    assert.deepEqual(r.files.sort(), ["m3e-badge-badges.figma.ts", "m3e-bottom-sheet-bottom-sheet.figma.ts"]);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

// -- publish(): every cemTag blocked, no --force-gate -> label is SKIPPED ----

test("publish: every cemTag in a label blocked (no --force-gate) -> staging/exec skipped entirely, results[].skipped is true", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();
    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath: path.join(scratch, "published.json"),
      stagingRoot: path.join(scratch, "staging"),
      // b4-status-all-blocked.mjs: every cemTag resolves to "rejected", so
      // NOTHING in this label is publishable.
      statusModulePath: path.join(here, "fixtures", "b4-status-all-blocked.mjs"),
    });
    const [r] = result.results;
    assert.equal(r.skipped, true);
    assert.deepEqual(r.files, []);
    assert.deepEqual(r.nodeIds, []);
    assert.equal(r.gate.published.length, 0);
    assert.equal(r.gate.blocked.length, 2);
    assert.equal(execFn.calls.length, 0, "nothing publishable -> figma CLI never invoked");
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

// -- unpublish(): shares staging, updates published.json -----------------------

test("unpublish: stages + calls `figma connect unpublish`, and clears the fileKey/label from published.json", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  const publishedJsonPath = path.join(scratch, "published.json");
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });

    // Pre-seed published.json as if a prior `publish` recorded this binding.
    writePublished(publishedJsonPath, {
      [THROWAWAY_FILE_KEY]: {
        "Web Components": { publishedAt: "2026-07-10T00:00:00.000Z", dryRun: false, nodeIds: ["51592:4768"] },
      },
      "some-other-file-key": { "Web Components": { publishedAt: "x", dryRun: false, nodeIds: [] } },
    });

    const execFn = makeFakeExec();
    const result = await unpublish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath,
      stagingRoot: path.join(scratch, "staging"),
    });

    assert.equal(result.results.length, 1);
    assert.equal(execFn.calls.length, 1);
    assert.deepEqual(execFn.calls[0].args, ["connect", "unpublish", "--skip-update-check"]);

    const state = readPublished(publishedJsonPath);
    // This fileKey's binding is gone; the unrelated fileKey's is untouched.
    assert.deepEqual(state, {
      "some-other-file-key": { "Web Components": { publishedAt: "x", dryRun: false, nodeIds: [] } },
    });
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

// -- publish(): --label narrows to one emitter; unknown label errors ---------

test("publish: --label narrows to the matching emitter only; an unknown label errors clearly", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec();

    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      label: "Web Components",
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: "fake-token" },
      execFn,
      publishedJsonPath: path.join(scratch, "published.json"),
      stagingRoot: path.join(scratch, "staging"),
      statusModulePath: NO_STATUS_MODULE,
    });
    assert.equal(result.results.length, 1);

    await assert.rejects(
      () =>
        publish({
          profileDir: b4ProfileDir,
          profileName: b4ProfileName,
          label: "Nonexistent Label",
          fileKey: THROWAWAY_FILE_KEY,
          dryRun: true,
          env: { FIGMA_ACCESS_TOKEN: "fake-token" },
          execFn,
          publishedJsonPath: path.join(scratch, "published.json"),
          stagingRoot: path.join(scratch, "staging2"),
        }),
      /no emitter with label "Nonexistent Label"/
    );
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

// -- token redaction (review fix, token safety) -------------------------------
//
// The brief: the token must never appear "in output parsing, not in
// errors" — if `@figma/code-connect` ever echoes auth material back
// verbatim in its own stdout/stderr, that text must never reach a thrown
// Error message or a console log unscrubbed. `redact` is the one helper
// both throw sites (and the success-path `results[].stdout`, which cli.mjs
// just echoes) route through.

test("redact: replaces every occurrence of the token with '***'; no-ops without a token or non-string input", () => {
  assert.equal(redact("token=SECRET123 more SECRET123 text", "SECRET123"), "token=*** more *** text");
  assert.equal(redact("no token here", ""), "no token here");
  assert.equal(redact("no token here", undefined), "no token here");
  assert.equal(redact(undefined, "SECRET123"), undefined);
});

test("publish: a fake exec whose stderr CONTAINS the token — the thrown error redacts it (never verbatim)", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  const token = "figd_super-secret-token-value";
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec({
      status: 1,
      stdout: "",
      stderr: `auth failed for token ${token} — check your PAT`,
    });

    await assert.rejects(
      () =>
        publish({
          profileDir: b4ProfileDir,
          profileName: b4ProfileName,
          fileKey: THROWAWAY_FILE_KEY,
          dryRun: true,
          env: { FIGMA_ACCESS_TOKEN: token },
          execFn,
          publishedJsonPath: path.join(scratch, "published.json"),
          stagingRoot: path.join(scratch, "staging"),
          statusModulePath: NO_STATUS_MODULE,
        }),
      (err) => {
        assert.ok(!err.message.includes(token), `error message must not contain the raw token:\n${err.message}`);
        assert.match(err.message, /\*\*\*/);
        assert.match(err.message, /auth failed for token \*\*\* — check your PAT/);
        return true;
      }
    );
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("unpublish: a fake exec whose stdout CONTAINS the token — the thrown error redacts it (never verbatim)", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  const token = "figd_another-secret-token";
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec({
      status: 1,
      stdout: `request failed, Authorization: Bearer ${token}`,
      stderr: "",
    });

    await assert.rejects(
      () =>
        unpublish({
          profileDir: b4ProfileDir,
          profileName: b4ProfileName,
          fileKey: THROWAWAY_FILE_KEY,
          env: { FIGMA_ACCESS_TOKEN: token },
          execFn,
          publishedJsonPath: path.join(scratch, "published.json"),
          stagingRoot: path.join(scratch, "staging"),
        }),
      (err) => {
        assert.ok(!err.message.includes(token), `error message must not contain the raw token:\n${err.message}`);
        assert.match(err.message, /Authorization: Bearer \*\*\*/);
        return true;
      }
    );
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

test("publish: a fake exec whose stdout CONTAINS the token on the SUCCESS path — the recorded/logged stdout redacts it", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  const token = "figd_success-path-secret";
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec({
      status: 0,
      stdout: `All Code Connect files are valid (token ${token} accepted)`,
      stderr: "",
    });

    const result = await publish({
      profileDir: b4ProfileDir,
      profileName: b4ProfileName,
      fileKey: THROWAWAY_FILE_KEY,
      dryRun: true,
      env: { FIGMA_ACCESS_TOKEN: token },
      execFn,
      publishedJsonPath: path.join(scratch, "published.json"),
      stagingRoot: path.join(scratch, "staging"),
      statusModulePath: NO_STATUS_MODULE,
    });

    const [r] = result.results;
    assert.ok(!r.stdout.includes(token), `results[].stdout must not contain the raw token:\n${r.stdout}`);
    assert.match(r.stdout, /token \*\*\* accepted/);
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});

// -- Fix 3: spawn-level exec errors surfaced (e.g. ENOENT — figma binary missing) --

test("publish: a spawn-level exec error (execResult.error, e.g. ENOENT) is surfaced in the thrown message, not swallowed into '(no output)'", async () => {
  cleanB4Generated();
  const scratch = mkScratchDir();
  try {
    await runEmit({ profileDir: b4ProfileDir, profileName: b4ProfileName });
    const execFn = makeFakeExec({
      status: null,
      stdout: "",
      stderr: "",
      error: new Error("spawnSync figma ENOENT"),
    });

    await assert.rejects(
      () =>
        publish({
          profileDir: b4ProfileDir,
          profileName: b4ProfileName,
          fileKey: THROWAWAY_FILE_KEY,
          dryRun: true,
          env: { FIGMA_ACCESS_TOKEN: "fake-token" },
          execFn,
          publishedJsonPath: path.join(scratch, "published.json"),
          stagingRoot: path.join(scratch, "staging"),
          statusModulePath: NO_STATUS_MODULE,
        }),
      (err) => {
        // stdout/stderr are both empty (the exec never actually ran the
        // figma binary), so the "(no output)" placeholder is expected too —
        // the point of Fix 3 is that the spawn error is ALSO present, not
        // silently dropped.
        assert.match(err.message, /spawn error: spawnSync figma ENOENT/);
        return true;
      }
    );
  } finally {
    fs.rmSync(scratch, { recursive: true, force: true });
    cleanB4Generated();
  }
});
