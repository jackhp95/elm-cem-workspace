// scripts/check-facts.mjs — provenance staleness gate (Phase 1.2,
// plans/2026-08-17-figma-elm-config-integration-design.md).
//
// Two kinds of coverage: synthetic tmp-dir fixtures for the failure modes
// (cheap, deterministic), and one sanity check against the REAL committed
// m3-kit profile (this task's whole point is catching a real bundle drift,
// so the gate must actually pass against real data today).

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { checkFacts } from "../scripts/check-facts.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const pkgDir = path.dirname(here);

function makeProfile(dir, { profile, cemFacts, elmFacts }) {
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, "profile.json"), JSON.stringify(profile), "utf8");
  const factsDir = path.join(dir, "facts");
  fs.mkdirSync(factsDir, { recursive: true });
  if (cemFacts) fs.writeFileSync(path.join(factsDir, "cem-facts.json"), JSON.stringify(cemFacts), "utf8");
  if (elmFacts) fs.writeFileSync(path.join(factsDir, "elm-api-facts.json"), JSON.stringify(elmFacts), "utf8");
}

function withTmpDir(fn) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "check-facts-test-"));
  try {
    return fn(dir);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
}

test("checkFacts: matching provenance across cem + elm bundles is ok", () => {
  withTmpDir((dir) => {
    makeProfile(dir, {
      profile: { cem: { package: "@m3e/web", version: "2.7.3" }, elm: { expectedBrand: "elm-m3e" } },
      cemFacts: { provenance: { source: { package: "@m3e/web", version: "2.7.3" } } },
      elmFacts: {
        provenance: { source: { package: "@m3e/web", version: "2.7.3" }, brand: { name: "elm-m3e" } },
      },
    });
    const result = checkFacts(dir);
    assert.equal(result.ok, true);
    assert.deepEqual(result.issues, []);
  });
});

test("checkFacts: stale cem-facts version fails loud with a specific issue", () => {
  withTmpDir((dir) => {
    makeProfile(dir, {
      profile: { cem: { package: "@m3e/web", version: "2.7.3" } },
      cemFacts: { provenance: { source: { package: "@m3e/web", version: "2.5.14" } } },
    });
    const result = checkFacts(dir);
    assert.equal(result.ok, false);
    assert.equal(result.issues.length, 1);
    assert.match(result.issues[0], /cem-facts\.json provenance\.source\.version/);
  });
});

test("checkFacts: wrong brand on elm-api-facts fails loud", () => {
  withTmpDir((dir) => {
    makeProfile(dir, {
      profile: { cem: { package: "@m3e/web", version: "2.7.3" }, elm: { expectedBrand: "elm-m3e" } },
      cemFacts: { provenance: { source: { package: "@m3e/web", version: "2.7.3" } } },
      elmFacts: {
        provenance: { source: { package: "@m3e/web", version: "2.7.3" }, brand: { name: "avetta-ui" } },
      },
    });
    const result = checkFacts(dir);
    assert.equal(result.ok, false);
    assert.equal(result.issues.length, 1);
    assert.match(result.issues[0], /provenance\.brand\.name/);
  });
});

test("checkFacts: missing elm-api-facts.json is fine (no Elm emitter for this profile)", () => {
  withTmpDir((dir) => {
    makeProfile(dir, {
      profile: { cem: { package: "@m3e/web", version: "2.7.3" } },
      cemFacts: { provenance: { source: { package: "@m3e/web", version: "2.7.3" } } },
    });
    const result = checkFacts(dir);
    assert.equal(result.ok, true);
  });
});

test("checkFacts: missing expectedBrand skips the brand assertion (backward-compatible)", () => {
  withTmpDir((dir) => {
    makeProfile(dir, {
      profile: { cem: { package: "@m3e/web", version: "2.7.3" } },
      cemFacts: { provenance: { source: { package: "@m3e/web", version: "2.7.3" } } },
      elmFacts: {
        provenance: { source: { package: "@m3e/web", version: "2.7.3" }, brand: { name: "whatever" } },
      },
    });
    const result = checkFacts(dir);
    assert.equal(result.ok, true);
  });
});

test("checkFacts: missing cem-facts.json is reported, not thrown", () => {
  withTmpDir((dir) => {
    makeProfile(dir, { profile: { cem: { package: "@m3e/web", version: "2.7.3" } } });
    const result = checkFacts(dir);
    assert.equal(result.ok, false);
    assert.match(result.issues[0], /missing/);
  });
});

test("checkFacts: the REAL committed m3-kit profile passes today", () => {
  const realProfileDir = path.join(pkgDir, "profiles", "m3-kit");
  const result = checkFacts(realProfileDir);
  assert.deepEqual(result.issues, []);
  assert.equal(result.ok, true);
});
