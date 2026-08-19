// tools/nudge-m3e-skill.test.mjs — picked up automatically by gate-all's
// tools/*.test.mjs discovery (see tools/gate-all.mjs).
//
// Pins the three properties the brief asked for:
//   1. a file containing `import M3e` triggers the nudge (both the pure
//      matcher and the --hook mode's stdout).
//   2. a file with no m3e patterns does NOT trigger it.
//   3. the hook NEVER returns a blocking exit code, match or no match, valid
//      or garbage stdin.

import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

import { matchesM3ePattern, checkFileForNudge } from "./nudge-m3e-skill.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const script = path.join(here, "nudge-m3e-skill.mjs");

function writeTemp(name, content) {
  const dir = mkdtempSync(path.join(tmpdir(), "nudge-m3e-"));
  const file = path.join(dir, name);
  writeFileSync(file, content);
  return file;
}

function runHook(filePath) {
  return spawnSync(process.execPath, [script, "--hook"], {
    input: JSON.stringify({ tool_input: { file_path: filePath } }),
    encoding: "utf8",
  });
}

test("matchesM3ePattern recognizes real m3e usage shapes", () => {
  assert.ok(matchesM3ePattern("import M3e exposing (Element)\n"));
  assert.ok(matchesM3ePattern("import M3e.Component.Badge\n"));
  assert.ok(matchesM3ePattern("view = M3e.Component.Badge.view []\n"));
  assert.ok(matchesM3ePattern("import M3e.Attributes\n"));
  assert.ok(matchesM3ePattern("<p>See <m3e-icon>star</m3e-icon></p>\n"));
  assert.ok(matchesM3ePattern("built on @m3e/web\n"));
});

test("matchesM3ePattern does not fire on unrelated content", () => {
  assert.equal(
    matchesM3ePattern(
      "module Foo exposing (view)\n\nview =\n    div [ class \"flex\" ] []\n",
    ),
    false,
  );
  assert.equal(matchesM3ePattern("<p>hello world</p>\n"), false);
});

test("checkFileForNudge: import M3e triggers, unrelated content does not", () => {
  const withM3e = writeTemp(
    "WithM3e.elm",
    "module WithM3e exposing (view)\n\nimport M3e exposing (Element)\nimport M3e.Component.Button\n\nview = M3e.Component.Button.view []\n",
  );
  assert.equal(checkFileForNudge(withM3e), true);

  const withoutM3e = writeTemp(
    "Plain.elm",
    "module Plain exposing (view)\n\nview =\n    div [ class \"flex\" ] []\n",
  );
  assert.equal(checkFileForNudge(withoutM3e), false);

  // Non-.elm/.html extensions are out of scope even if the content matches.
  const wrongExt = writeTemp("notes.md", "import M3e exposing (Element)\n");
  assert.equal(checkFileForNudge(wrongExt), false);
});

test("--hook emits additionalContext for a matching file, exit 0", () => {
  const withM3e = writeTemp(
    "WithM3e.elm",
    "module WithM3e exposing (view)\n\nimport M3e exposing (Element)\n",
  );
  const result = runHook(withM3e);
  assert.equal(result.status, 0);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.hookSpecificOutput.hookEventName, "PostToolUse");
  assert.match(payload.hookSpecificOutput.additionalContext, /m3e/i);
  assert.match(payload.hookSpecificOutput.additionalContext, /m3e-api-okf/);
});

test("--hook stays silent (no stdout) for a non-matching file, exit 0", () => {
  const plain = writeTemp(
    "Plain.elm",
    "module Plain exposing (view)\n\nview =\n    div [ class \"flex\" ] []\n",
  );
  const result = runHook(plain);
  assert.equal(result.status, 0);
  assert.equal(result.stdout.trim(), "");
});

test("--hook never blocks: garbage stdin, missing file_path, non-.elm/.html all exit 0", () => {
  const garbage = spawnSync(process.execPath, [script, "--hook"], {
    input: "not json",
    encoding: "utf8",
  });
  assert.equal(garbage.status, 0);

  const noPath = spawnSync(process.execPath, [script, "--hook"], {
    input: JSON.stringify({}),
    encoding: "utf8",
  });
  assert.equal(noPath.status, 0);

  const missingFile = runHook("/tmp/does-not-exist-nudge-m3e-skill-test.elm");
  assert.equal(missingFile.status, 0);

  const wrongExt = writeTemp("notes.md", "import M3e exposing (Element)\n");
  const result = runHook(wrongExt);
  assert.equal(result.status, 0);
  assert.equal(result.stdout.trim(), "");
});
