#!/usr/bin/env node
// admits set-subtraction primitive (D-FAM2) — codegen unit test.
//
// Task 2 of docs/plans/2026-08-21-families-a11y-composition-plan.md adds `!@set`
// (exclude a whole category) and `!kind` (exclude a single kind) tokens to the
// `admits.kinds` grammar. The emitter (`Generate.Phantom.Model.resolveSlot`)
// flattens them to (union of includes) − (union of excludes), so the generated
// `slotKinds` fact stays a FLAT allow-list and `Cem.ValidSlotKind` needs zero
// change — it still just checks membership.
//
// This test runs the REAL generator on a self-contained fixture and asserts the
// subtraction on the emitted `<Lib>/Review/Facts.elm` `slotKinds`:
//
//   Subtract:    kinds ["@phrasing", "!@interactive"]   → phrasing MINUS the
//                interactive members (button/anchor/textInput ABSENT, span PRESENT).
//   PlainPhrasing: kinds ["@phrasing"]                  → the CONTROL: proves the
//                interactive members WOULD be present without the primitive, so a
//                no-op emitter (ignoring the `!@` token) would make the two blocks
//                identical and fail this test — the test can catch a real regression.
//   SubtractKind: kinds ["@phrasing", "!anchor"]        → single-kind `!kind`
//                exclusion drops only anchor.
//
// The "wrong inclusion FAILS" direction is enforced structurally: if `button`
// (or any interactive member) leaks into the Subtract allow-list, `checkAbsent`
// fails. A deliberately-wrong emitter that kept `button` in the resolved set
// would trip exactly this assertion.
//
// Run standalone: `node tests/admits-subtraction.test.mjs`. Wired into `npm test`.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { repo } from "./lib/harness.mjs";

let failures = 0;
const check = (cond, msg, extra = "") => {
  if (cond) {
    console.log(`  PASS  ${msg}`);
  } else {
    failures += 1;
    console.error(`  FAIL  ${msg}${extra ? "\n" + extra : ""}`);
  }
};

// ── Fixture: a minimal CEM with a non-interactive atom (span) and three
//    interactive elements (button, anchor, textInput), plus three container
//    elements exercising the include-only, `!@set`, and `!kind` cases.
const el = (name, tag) => ({
  kind: "class",
  name,
  tagName: tag,
  customElement: true,
  description: `${name} fixture element.`,
  members: [],
  events: [],
  cssProperties: [],
  cssParts: [],
  cssStates: [],
  slots: [{ name: "unnamed", description: "content." }],
  attributes: [],
});

const cem = {
  schemaVersion: "1.0.0",
  package: { name: "subtraction-fixture", version: "1.0.0" },
  modules: [
    {
      kind: "javascript-module",
      path: "src/index.js",
      declarations: [
        el("Span", "sx-span"),
        el("Button", "sx-button"),
        el("Anchor", "sx-anchor"),
        el("TextInput", "sx-text-input"),
        el("Subtract", "sx-subtract"),
        el("PlainPhrasing", "sx-plain-phrasing"),
        el("SubtractKind", "sx-subtract-kind"),
      ],
    },
  ],
};

// `_sets.phrasing` deliberately INCLUDES the interactive members (this is the
// exact html defect: `_sets.phrasing` contains button/a/input). `_sets.interactive`
// is the subtrahend. Kind tokens are component ctor names lowercased (brand kinds).
const config = {
  _phantom: true,
  _sets: {
    phrasing: ["span", "button", "anchor", "textInput"],
    interactive: ["button", "anchor", "textInput"],
  },
  Subtract: {
    admits: { unnamed: { kinds: ["@phrasing", "!@interactive"], multi: true } },
  },
  PlainPhrasing: {
    admits: { unnamed: { kinds: ["@phrasing"], multi: true } },
  },
  SubtractKind: {
    admits: { unnamed: { kinds: ["@phrasing", "!anchor"], multi: true } },
  },
};

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-subtraction-"));
const cemPath = path.join(work, "fixture.cem.json");
const configPath = path.join(work, "config.json");
const outSrc = path.join(work, "src");
fs.mkdirSync(outSrc, { recursive: true });
fs.writeFileSync(cemPath, JSON.stringify(cem, null, 2));
fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

try {
  execFileSync(
    "node",
    [
      path.join(repo, "bin", "elm-cem.js"),
      `--flags-from=${cemPath}`,
      `--config-from=${configPath}`,
      `--output=${outSrc}`,
    ],
    { stdio: "inherit" },
  );
} catch (e) {
  console.error(`admits-subtraction: FAIL — generator crashed: ${e.message}`);
  process.exit(1);
}

// ── Read the emitted Review/Facts.elm and pull each component's `unnamed`
//    slotKinds allow-list.
const factsFile = (() => {
  const walk = (dir) =>
    fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
      const full = path.join(dir, e.name);
      return e.isDirectory() ? walk(full) : full.endsWith(".elm") ? [full] : [];
    });
  return walk(outSrc).find((f) => f.endsWith(path.join("Review", "Facts.elm")));
})();

if (!factsFile) {
  console.error("admits-subtraction: FAIL — no Review/Facts.elm emitted");
  process.exit(1);
}
const facts = fs.readFileSync(factsFile, "utf8");

// Facts blocks look like:
//   { component = "subtract"
//     ...
//     , slotKinds = [ ( "unnamed", [ "span" ] ) ]
// Grab the block for `component`, then the kind list inside its `unnamed` pair.
function unnamedKinds(component) {
  const blockRe = new RegExp(
    `component = "${component}"[\\s\\S]*?slotKinds = (\\[[\\s\\S]*?\\])\\n`,
    "m",
  );
  const m = facts.match(blockRe);
  if (!m) return null;
  const slotKinds = m[1];
  const pairRe = /\(\s*"unnamed"\s*,\s*\[([^\]]*)\]\s*\)/;
  const pm = slotKinds.match(pairRe);
  if (!pm) return [];
  return pm[1]
    .split(",")
    .map((s) => s.trim().replace(/^"|"$/g, ""))
    .filter(Boolean);
}

const subtract = unnamedKinds("subtract");
const plain = unnamedKinds("plainPhrasing");
const subtractKind = unnamedKinds("subtractKind");

const has = (arr, k) => Array.isArray(arr) && arr.includes(k);
const show = (arr) => (arr === null ? "<no block>" : `[ ${arr.join(", ")} ]`);

// ── Control: PlainPhrasing must carry the FULL phrasing set (proves the members
//    are real and the subtraction test isn't trivially passing).
check(
  has(plain, "span") &&
    has(plain, "button") &&
    has(plain, "anchor") &&
    has(plain, "textInput"),
  `control PlainPhrasing @phrasing keeps ALL members (span+button+anchor+textInput)`,
  `got ${show(plain)}`,
);

// ── Subtraction: the interactive members are GONE, the non-interactive one stays.
const checkAbsent = (k) =>
  check(
    !has(subtract, k),
    `Subtract @phrasing − !@interactive EXCLUDES ${k}`,
    `got ${show(subtract)}`,
  );
checkAbsent("button");
checkAbsent("anchor");
checkAbsent("textInput");
check(
  has(subtract, "span"),
  `Subtract @phrasing − !@interactive KEEPS non-interactive span`,
  `got ${show(subtract)}`,
);
// The resolved allow-list is EXACTLY [span] — nothing spurious, nothing left over.
check(
  Array.isArray(subtract) && subtract.length === 1 && subtract[0] === "span",
  `Subtract resolves to a flat allow-list of exactly [ span ]`,
  `got ${show(subtract)}`,
);

// ── Distinguishing power: a no-op emitter (ignoring `!@interactive`) would make
//    Subtract === PlainPhrasing. Assert they DIFFER, so this test provably
//    catches a real regression rather than passing trivially.
check(
  JSON.stringify(subtract) !== JSON.stringify(plain),
  `Subtract differs from the un-subtracted control (the primitive actually fires)`,
  `subtract=${show(subtract)} control=${show(plain)}`,
);

// ── Single-kind `!kind` exclusion: only anchor dropped; button/textInput/span stay.
check(
  has(subtractKind, "span") &&
    has(subtractKind, "button") &&
    has(subtractKind, "textInput") &&
    !has(subtractKind, "anchor"),
  `SubtractKind @phrasing − !anchor drops ONLY anchor`,
  `got ${show(subtractKind)}`,
);

fs.rmSync(work, { recursive: true, force: true });

if (failures > 0) {
  console.error(`\nadmits-subtraction: ${failures} FAILURE(S)`);
  process.exit(1);
}
console.log(
  `\nadmits-subtraction: OK — !@set and !kind flatten to (includes − excludes); ` +
    `ValidSlotKind allow-list stays flat.`,
);
