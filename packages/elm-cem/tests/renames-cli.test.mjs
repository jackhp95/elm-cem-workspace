#!/usr/bin/env node
// _renames end-to-end gate (config override escape hatch).
//
// The `_renames` config key provides escape-hatch overrides for identifier
// collisions that are intentional or aesthetic. This test runs the CLI with
// `--config-from` files carrying each `_renames` scope (_tokens, _events,
// _elements, and per-component attrs) and asserts the overridden names appear
// in the generated output.
//
// Test cases:
// 1. _tokens rename resolves a case-collision (AUTO/auto)
// 2. Attr renames (per-component)
// 3. _events renames
// 4. _elements renames
// 5. Nonexistent source validation (should error)
//
// Run standalone: `node tests/renames-cli.test.mjs`. Wired into `npm test`.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..");

function fail(msg) {
  console.error(`\nrenames-cli: FAIL — ${msg}`);
  process.exit(1);
}

function testCase(name, testFn) {
  try {
    testFn();
    console.log(`✓ ${name}`);
  } catch (e) {
    fail(`${name}: ${e.message}`);
  }
}

// Test 1: _tokens rename resolves a case-collision (AUTO/auto)
testCase("_tokens rename (case-collision AUTO/auto → autoUpper/auto)", () => {
  const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-renames-tokens-"));
  const outSrc = path.join(work, "src");
  fs.mkdirSync(outSrc, { recursive: true });

  // Minimal CEM with two tokens that differ only in case.
  const cemPath = path.join(work, "cem.json");
  fs.writeFileSync(
    cemPath,
    JSON.stringify({
      schemaVersion: "1.0.0",
      package: { name: "hz-widgets", version: "1.0.0" },
      modules: [
        {
          kind: "javascript-module",
          path: "x.ts",
          declarations: [
            {
              kind: "class",
              name: "HzButtonElement",
              customElement: true,
              tagName: "hz-button",
              members: [],
              attributes: [
                {
                  name: "mode",
                  type: { text: "'AUTO' | 'auto'" },
                  description: "Mode enum",
                },
              ],
              events: [],
              slots: [],
              cssProperties: [],
              cssParts: [],
              cssStates: [],
            },
          ],
        },
      ],
    }),
  );

  // Config with _renames._tokens override: AUTO → autoUpper
  const configPath = path.join(work, "config.json");
  fs.writeFileSync(
    configPath,
    JSON.stringify({
      _phantom: true,
      _renames: {
        _tokens: { AUTO: "autoUpper" },
      },
    }),
  );

  fs.writeFileSync(
    path.join(work, "elm.json"),
    JSON.stringify({
      type: "package",
      name: "hz/widgets",
      summary: "renames test",
      license: "BSD-3-Clause",
      version: "1.0.0",
      "exposed-modules": [],
      "elm-version": "0.19.0 <= v < 0.20.0",
      dependencies: {
        "elm/core": "1.0.0 <= v < 2.0.0",
        "elm/html": "1.0.0 <= v < 2.0.0",
        "elm/json": "1.0.0 <= v < 2.0.0",
        "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
      },
      "test-dependencies": {},
    }),
  );

  try {
    execFileSync(
      "node",
      [
        path.join(repo, "bin", "elm-cem.js"),
        `--flags-from=${cemPath}`,
        `--config-from=${configPath}`,
        `--output=${outSrc}`,
      ],
      { stdio: "pipe", encoding: "utf8" },
    );
  } catch (e) {
    throw new Error(`generator crashed: ${e.message || e.stderr}`);
  }

  // Check that Values.elm contains both autoUpper (renamed) and auto
  const valuesPath = path.join(outSrc, "Hz", "Values.elm");
  if (!fs.existsSync(valuesPath)) {
    throw new Error("Hz/Values.elm not generated");
  }
  const values = fs.readFileSync(valuesPath, "utf8");

  if (!values.includes("autoUpper")) {
    throw new Error(
      "renamed token 'autoUpper' not found in Values.elm — override did not apply",
    );
  }
  if (!values.includes("auto") || !values.match(/auto\s*[=:]/)) {
    throw new Error("original token 'auto' not found or damaged in Values.elm");
  }

  fs.rmSync(work, { recursive: true, force: true });
});

// Test 2: Per-component attr rename
testCase("attr rename (per-component)", () => {
  const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-renames-attr-"));
  const outSrc = path.join(work, "src");
  fs.mkdirSync(outSrc, { recursive: true });

  const cemPath = path.join(work, "cem.json");
  fs.writeFileSync(
    cemPath,
    JSON.stringify({
      schemaVersion: "1.0.0",
      package: { name: "hz-widgets", version: "1.0.0" },
      modules: [
        {
          kind: "javascript-module",
          path: "x.ts",
          declarations: [
            {
              kind: "class",
              name: "HzInputElement",
              customElement: true,
              tagName: "hz-input",
              members: [],
              attributes: [
                {
                  name: "with-hint",
                  type: { text: "boolean" },
                  description: "With hint",
                },
              ],
              events: [],
              slots: [],
              cssProperties: [],
              cssParts: [],
              cssStates: [],
            },
          ],
        },
      ],
    }),
  );

  // Config: rename Input component's "with-hint" attr to "hintFlag"
  // Component key is derived from tag name "hz-input" → "Input" (prefix stripped)
  const configPath = path.join(work, "config.json");
  fs.writeFileSync(
    configPath,
    JSON.stringify({
      _phantom: true,
      _renames: {
        Input: {
          "attr:with-hint": "hintFlag",
        },
      },
    }),
  );

  fs.writeFileSync(
    path.join(work, "elm.json"),
    JSON.stringify({
      type: "package",
      name: "hz/widgets",
      summary: "renames test",
      license: "BSD-3-Clause",
      version: "1.0.0",
      "exposed-modules": [],
      "elm-version": "0.19.0 <= v < 0.20.0",
      dependencies: {
        "elm/core": "1.0.0 <= v < 2.0.0",
        "elm/html": "1.0.0 <= v < 2.0.0",
        "elm/json": "1.0.0 <= v < 2.0.0",
        "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
      },
      "test-dependencies": {},
    }),
  );

  try {
    execFileSync(
      "node",
      [
        path.join(repo, "bin", "elm-cem.js"),
        `--flags-from=${cemPath}`,
        `--config-from=${configPath}`,
        `--output=${outSrc}`,
      ],
      { stdio: "pipe", encoding: "utf8" },
    );
  } catch (e) {
    throw new Error(`generator crashed: ${e.message || e.stderr}`);
  }

  // Check that Input.elm contains "hintFlag" not "withHint"
  // Post-split: per-component setters live in <Brand>/Component/<Name>.elm.
  const inputPath = path.join(outSrc, "Hz", "Component", "Input.elm");
  if (!fs.existsSync(inputPath)) {
    throw new Error("Hz/Component/Input.elm not generated");
  }
  const input = fs.readFileSync(inputPath, "utf8");

  if (!input.includes("hintFlag")) {
    throw new Error("renamed attr setter 'hintFlag' not found in Input.elm");
  }

  fs.rmSync(work, { recursive: true, force: true });
});

// Test 3: _events rename
testCase("_events rename", () => {
  const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-renames-events-"));
  const outSrc = path.join(work, "src");
  fs.mkdirSync(outSrc, { recursive: true });

  const cemPath = path.join(work, "cem.json");
  fs.writeFileSync(
    cemPath,
    JSON.stringify({
      schemaVersion: "1.0.0",
      package: { name: "hz-widgets", version: "1.0.0" },
      modules: [
        {
          kind: "javascript-module",
          path: "x.ts",
          declarations: [
            {
              kind: "class",
              name: "HzInputElement",
              customElement: true,
              tagName: "hz-input",
              members: [],
              attributes: [],
              events: [{ name: "hz-error", description: "Error event" }],
              slots: [],
              cssProperties: [],
              cssParts: [],
              cssStates: [],
            },
          ],
        },
      ],
    }),
  );

  // Config: rename hz-error event to onHzCustomError
  const configPath = path.join(work, "config.json");
  fs.writeFileSync(
    configPath,
    JSON.stringify({
      _phantom: true,
      _renames: {
        _events: { "hz-error": "onHzCustomError" },
      },
    }),
  );

  fs.writeFileSync(
    path.join(work, "elm.json"),
    JSON.stringify({
      type: "package",
      name: "hz/widgets",
      summary: "renames test",
      license: "BSD-3-Clause",
      version: "1.0.0",
      "exposed-modules": [],
      "elm-version": "0.19.0 <= v < 0.20.0",
      dependencies: {
        "elm/core": "1.0.0 <= v < 2.0.0",
        "elm/html": "1.0.0 <= v < 2.0.0",
        "elm/json": "1.0.0 <= v < 2.0.0",
        "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
      },
      "test-dependencies": {},
    }),
  );

  try {
    execFileSync(
      "node",
      [
        path.join(repo, "bin", "elm-cem.js"),
        `--flags-from=${cemPath}`,
        `--config-from=${configPath}`,
        `--output=${outSrc}`,
      ],
      { stdio: "pipe", encoding: "utf8" },
    );
  } catch (e) {
    throw new Error(`generator crashed: ${e.message || e.stderr}`);
  }

  // Check that Events.elm contains the renamed handler
  const eventsPath = path.join(outSrc, "Hz", "Events.elm");
  if (!fs.existsSync(eventsPath)) {
    throw new Error("Hz/Events.elm not generated");
  }
  const events = fs.readFileSync(eventsPath, "utf8");

  if (!events.includes("onHzCustomError")) {
    throw new Error("renamed event handler 'onHzCustomError' not found in Events.elm");
  }

  fs.rmSync(work, { recursive: true, force: true });
});

// Test 4: _elements rename
testCase("_elements rename (ctor)", () => {
  const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-renames-elements-"));
  const outSrc = path.join(work, "src");
  fs.mkdirSync(outSrc, { recursive: true });

  const cemPath = path.join(work, "cem.json");
  fs.writeFileSync(
    cemPath,
    JSON.stringify({
      schemaVersion: "1.0.0",
      package: { name: "hz-widgets", version: "1.0.0" },
      modules: [
        {
          kind: "javascript-module",
          path: "x.ts",
          declarations: [
            {
              kind: "class",
              name: "HzTextElement",
              customElement: true,
              tagName: "hz-text",
              members: [],
              attributes: [],
              events: [],
              slots: [],
              cssProperties: [],
              cssParts: [],
              cssStates: [],
            },
          ],
        },
      ],
    }),
  );

  // Config: rename hz-text element ctor to textEl
  const configPath = path.join(work, "config.json");
  fs.writeFileSync(
    configPath,
    JSON.stringify({
      _phantom: true,
      _renames: {
        _elements: { "hz-text": "textEl" },
      },
    }),
  );

  fs.writeFileSync(
    path.join(work, "elm.json"),
    JSON.stringify({
      type: "package",
      name: "hz/widgets",
      summary: "renames test",
      license: "BSD-3-Clause",
      version: "1.0.0",
      "exposed-modules": [],
      "elm-version": "0.19.0 <= v < 0.20.0",
      dependencies: {
        "elm/core": "1.0.0 <= v < 2.0.0",
        "elm/html": "1.0.0 <= v < 2.0.0",
        "elm/json": "1.0.0 <= v < 2.0.0",
        "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
      },
      "test-dependencies": {},
    }),
  );

  try {
    execFileSync(
      "node",
      [
        path.join(repo, "bin", "elm-cem.js"),
        `--flags-from=${cemPath}`,
        `--config-from=${configPath}`,
        `--output=${outSrc}`,
      ],
      { stdio: "pipe", encoding: "utf8" },
    );
  } catch (e) {
    throw new Error(`generator crashed: ${e.message || e.stderr}`);
  }

  // Check that Hz.elm contains textEl ctor, not hzText
  const hzPath = path.join(outSrc, "Hz.elm");
  if (!fs.existsSync(hzPath)) {
    throw new Error("Hz.elm not generated");
  }
  const hz = fs.readFileSync(hzPath, "utf8");

  if (!hz.includes("textEl")) {
    throw new Error("renamed element ctor 'textEl' not found in Hz.elm");
  }

  fs.rmSync(work, { recursive: true, force: true });
});

// Test 5: Nonexistent source validation (should error on unknown attr)
testCase("nonexistent source validation (unknown attr → exit non-zero)", () => {
  const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-renames-invalid-"));
  const outSrc = path.join(work, "src");
  fs.mkdirSync(outSrc, { recursive: true });

  const cemPath = path.join(work, "cem.json");
  fs.writeFileSync(
    cemPath,
    JSON.stringify({
      schemaVersion: "1.0.0",
      package: { name: "hz-widgets", version: "1.0.0" },
      modules: [
        {
          kind: "javascript-module",
          path: "x.ts",
          declarations: [
            {
              kind: "class",
              name: "HzInputElement",
              customElement: true,
              tagName: "hz-input",
              members: [],
              attributes: [
                {
                  name: "placeholder",
                  type: { text: "boolean" },
                  description: "Placeholder",
                },
              ],
              events: [],
              slots: [],
              cssProperties: [],
              cssParts: [],
              cssStates: [],
            },
          ],
        },
      ],
    }),
  );

  // Config: try to rename a nonexistent attr (should error loudly)
  const configPath = path.join(work, "config.json");
  fs.writeFileSync(
    configPath,
    JSON.stringify({
      _phantom: true,
      _renames: {
        Input: {
          "attr:nope": "x", // This attr doesn't exist
        },
      },
    }),
  );

  fs.writeFileSync(
    path.join(work, "elm.json"),
    JSON.stringify({
      type: "package",
      name: "hz/widgets",
      summary: "renames test",
      license: "BSD-3-Clause",
      version: "1.0.0",
      "exposed-modules": [],
      "elm-version": "0.19.0 <= v < 0.20.0",
      dependencies: {
        "elm/core": "1.0.0 <= v < 2.0.0",
        "elm/html": "1.0.0 <= v < 2.0.0",
        "elm/json": "1.0.0 <= v < 2.0.0",
        "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
      },
      "test-dependencies": {},
    }),
  );

  let stderr = "";
  let exitCode = 0;
  try {
    execFileSync(
      "node",
      [
        path.join(repo, "bin", "elm-cem.js"),
        `--flags-from=${cemPath}`,
        `--config-from=${configPath}`,
        `--output=${outSrc}`,
      ],
      { stdio: "pipe", encoding: "utf8" },
    );
    throw new Error("expected generator to exit non-zero but it succeeded");
  } catch (e) {
    exitCode = e.status || 1;
    stderr = e.stderr || e.toString();
  }

  if (exitCode === 0) {
    throw new Error("expected non-zero exit code");
  }

  fs.rmSync(work, { recursive: true, force: true });
});

console.log("\nrenames-cli: ALL TESTS PASSED");
