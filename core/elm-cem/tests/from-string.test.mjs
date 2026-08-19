#!/usr/bin/env node
// `fromString` wire-string + dedup gate.
//
// `fromString` must case on the string the token WRITES, not its Elm identifier.
// They differ under an `attrTypes` MAP override: `{"always": "true"}` mints
// `always = Ir.token "true"`. Casing on the identifier makes `fromString`
// disagree with `toString` for exactly those tokens, silently and in one
// direction only — the round trip fails for the values an author deliberately
// renamed, and for no others, which is the hardest possible shape to notice.
//
// And two DISTINCT tokens in one union may share a wire string. `tokenValues`
// (Model.elm) guards token -> one string; `guardValuesModule` guards two raw
// tokens -> one identifier. NEITHER guards string -> one token, so the map form
// permits `{"always": "true", "yes": "true"}`. Both mint `Ir.token "true"` —
// the same `Value` — so dropping one is lossless, but emitting both produces a
// duplicate `case` branch and a duplicated `<enum>Values` entry.
//
// The fixture (tests/phantom/fixtures/from-string{.cem,-config}.json) carries
// both hazards on one brand. The assertions below are on emitted TEXT, then the
// whole chain is COMPILED: a row that is spelled right and does not type-check
// would pass the greps, and a `String -> Maybe (Value <openRow>)` would compile
// while quietly discarding the closure.
//
// Run standalone: `node tests/from-string.test.mjs`. Wired into `npm test`.

import { execFileSync, spawnSync } from "node:child_process";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { repo } from "./lib/harness.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const elm = path.join(repo, "node_modules", ".bin", "elm");
const elmFormat = path.join(repo, "node_modules", ".bin", "elm-format");
// The IR substrate lives beside this repo; the phantom gate resolves it the same way.
const irSrc = path.resolve(repo, "..", "elm-html-intermediate-representation", "src");
const fixtures = path.join(here, "phantom", "fixtures");

let failures = 0;
const check = (name, fn) => {
  try {
    fn();
    console.log(`  PASS  ${name}`);
  } catch (e) {
    console.error(`  FAIL  ${name}\n        ${e.message.split("\n").join("\n        ")}`);
    failures += 1;
  }
};

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-from-string-"));
const out = path.join(work, "src");
fs.mkdirSync(out, { recursive: true });

try {
  execFileSync(
    "node",
    [
      path.join(repo, "bin", "elm-cem.js"),
      `--flags-from=${path.join(fixtures, "from-string.cem.json")}`,
      `--config-from=${path.join(fixtures, "from-string-config.json")}`,
      `--output=${out}`,
    ],
    { stdio: "pipe" },
  );
} catch (e) {
  console.error(`from-string: FAIL — generator crashed: ${e.stdout || ""}${e.stderr || ""}${e.message}`);
  process.exit(1);
}

// elm-format so the assertions match the normalized (committed) form.
execFileSync(elmFormat, [out, "--yes"], { stdio: "pipe" });

const valuesPath = path.join(out, "Fx", "Values.elm");
if (!fs.existsSync(valuesPath)) {
  console.error("from-string: FAIL — generator emitted no Fx/Values.elm");
  process.exit(1);
}
const values = fs.readFileSync(valuesPath, "utf8");

// ── MAP form: the case branch is the WIRE string, the identifier is preserved ──
check("MAP form: `presenceFromString` returns the CLOSED `Presence` row", () => {
  assert.match(values, /presenceFromString : String -> Maybe \(Value Presence\)/);
});
check('MAP form: the branch for `always` is its wire string "true"', () => {
  assert.match(values, /"true" ->\n\s+Just always/);
});
check("MAP form: NO branch cases on an Elm identifier", () => {
  assert.doesNotMatch(values, /"always" ->/, "cased on the identifier, not the wire string");
  assert.doesNotMatch(values, /"never" ->/, "cased on the identifier, not the wire string");
  assert.doesNotMatch(values, /"yes" ->/, "cased on the identifier, not the wire string");
  assert.doesNotMatch(values, /"off" ->/, "cased on the identifier, not the wire string");
});

// ── DEDUP: one branch per wire string, not one per token ───────────────────────
check("dedup: exactly one `\"true\"` branch per union (presence, fallback)", () => {
  const trueBranches = (values.match(/"true" ->/g) || []).length;
  assert.equal(trueBranches, 2, `expected 2 'true' branches (one per union), got ${trueBranches}`);
});
check("dedup: `fallbackValues` carries no duplicate entry", () => {
  const m = values.match(/fallbackValues =\n\s+\[ ([^\]]*)\]/);
  assert.ok(m, "no single-line `fallbackValues` list found");
  const entries = m[1].split(",").map((s) => s.trim());
  // Two checks, because the interesting duplicate is NOT a repeated identifier.
  // A wire-string fan-in keeps the identifiers distinct (`always`, `yes`) while
  // making the VALUES identical — both are `Ir.token "true"` — so a list that is
  // free of repeated names can still offer the same option to a UI twice.
  assert.equal(new Set(entries).size, entries.length, `duplicate identifier in fallbackValues: ${m[1]}`);
  const written = entries.map((ident) => {
    const t = values.match(new RegExp(`^${ident} =\\n    Ir\\.token "([^"]*)"$`, "m"));
    assert.ok(t, `\`${ident}\` is listed in fallbackValues but mints no Ir.token`);
    return t[1];
  });
  assert.equal(
    new Set(written).size,
    written.length,
    `two entries in fallbackValues are the same Value: ${entries.join(", ")} write ${written.join(", ")}`,
  );
});

// ── ROUND TRIP: every token of every union parses back to a Value ─────────────
//
// Derived from the emitted text rather than hard-coded, so it holds for whatever
// the fixture grows into. `toString v` IS the `Ir.token` payload, so the token
// table below is the emitted `toString`.
const tokenWire = new Map(
  [...values.matchAll(/^(\w+) =\n    Ir\.token "([^"]*)"$/gm)].map((m) => [m[1], m[2]]),
);
const unionRows = new Map(
  [...values.matchAll(/^type alias (\w+) =\n    \{ ([\s\S]*?)^    \}$/gm)].map((m) => [
    m[1],
    [...m[2].matchAll(/(\w+) : Supported/g)].map((f) => f[1]),
  ]),
);
const enums = [...values.matchAll(/^(\w+)Values : List \(Value (\w+)\)$/gm)].map((m) => ({
  name: m[1],
  alias: m[2],
}));

check("round trip: the fixture actually declares both unions", () => {
  assert.deepEqual(
    enums.map((e) => e.name).sort(),
    ["fallback", "presence"],
    "fixture drifted — the wire-string and dedup hazards are no longer both covered",
  );
});

for (const { name, alias } of enums) {
  const listMatch = values.match(new RegExp(`^${name}Values =\\n    \\[ ([^\\]]*)\\]$`, "m"));
  const listEntries = listMatch ? listMatch[1].split(",").map((s) => s.trim()) : null;

  const caseMatch = values.match(
    new RegExp(`^${name}FromString s =\\n    case s of\\n([\\s\\S]*?)^        _ ->$`, "m"),
  );
  const branches = caseMatch
    ? new Map([...caseMatch[1].matchAll(/^        "([^"]*)" ->\n            Just (\w+)$/gm)].map((m) => [m[1], m[2]]))
    : null;

  check(`round trip [${name}]: both declarations parse`, () => {
    assert.ok(listEntries, `no single-line \`${name}Values\` list`);
    assert.ok(branches, `no \`${name}FromString\` case expression`);
  });
  if (!listEntries || !branches) continue;

  check(`round trip [${name}]: every union token has a branch for the string it WRITES`, () => {
    for (const ident of unionRows.get(alias) ?? []) {
      const wire = tokenWire.get(ident);
      assert.ok(wire !== undefined, `token \`${ident}\` is in row \`${alias}\` but mints no Ir.token`);
      assert.ok(branches.has(wire), `\`${name}FromString\` has no branch for ${JSON.stringify(wire)} (token \`${ident}\`)`);
    }
  });

  check(`round trip [${name}]: every branch returns a token that writes that same string`, () => {
    for (const [wire, ident] of branches) {
      assert.equal(
        tokenWire.get(ident),
        wire,
        `branch ${JSON.stringify(wire)} returns \`${ident}\`, which writes ${JSON.stringify(tokenWire.get(ident))}`,
      );
    }
  });

  check(`round trip [${name}]: \`${name}Values\` and the branch targets are the same set`, () => {
    assert.deepEqual([...listEntries].sort(), [...branches.values()].sort());
  });

  check(`round trip [${name}]: every listed value round-trips through toString`, () => {
    for (const ident of listEntries) {
      const wire = tokenWire.get(ident);
      assert.equal(branches.get(wire), ident, `toString ${ident} = ${JSON.stringify(wire)} does not parse back to \`${ident}\``);
    }
  });
}

// ── COMPILE: the round trip type-checks against the CLOSED union row ──────────
//
// Greps prove the spelling. Only the compiler proves that the row `<enum>Values`
// carries, the row `toString` accepts and the row `<enum>FromString` returns are
// the SAME row — and that it is the union's closed row rather than an open one.
{
  const acid = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-from-string-acid-"));
  fs.mkdirSync(path.join(acid, "src"));
  fs.writeFileSync(
    path.join(acid, "src", "RoundTrip.elm"),
    `module RoundTrip exposing (fallbackRoundTrip, presenceRoundTrip)

{-| The round trip at the TYPE level: \`toString\` accepts a \`Value\` from the
union's closed row and the union's own \`fromString\` hands that same row back.
-}

import Fx.Values as V


presenceRoundTrip : List (Maybe (V.Value V.Presence))
presenceRoundTrip =
    V.presenceValues |> List.map (V.toString >> V.presenceFromString)


fallbackRoundTrip : List (Maybe (V.Value V.Fallback))
fallbackRoundTrip =
    V.fallbackValues |> List.map (V.toString >> V.fallbackFromString)
`,
  );
  fs.writeFileSync(
    path.join(acid, "elm.json"),
    JSON.stringify(
      {
        type: "application",
        "source-directories": ["src", out, irSrc],
        "elm-version": "0.19.1",
        dependencies: {
          direct: { "elm/core": "1.0.5", "elm/html": "1.0.0", "elm/json": "1.1.4", "elm/virtual-dom": "1.0.3" },
          indirect: {},
        },
        "test-dependencies": { direct: {}, indirect: {} },
      },
      null,
      4,
    ),
  );
  const r = spawnSync(elm, ["make", "src/RoundTrip.elm", "--output=/dev/null"], {
    cwd: acid,
    encoding: "utf8",
  });
  check("compile: the round trip type-checks against the closed union rows", () => {
    assert.equal(r.status, 0, (r.stderr || r.stdout || "").slice(0, 2500));
  });
}

console.log(
  failures === 0
    ? "\nfrom-string: OK — `fromString` cases on the wire string and dedups the fan-in."
    : `\nfrom-string: ${failures} failure(s)`,
);
process.exit(failures === 0 ? 0 : 1);
