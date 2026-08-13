#!/usr/bin/env node
// check-drift.test.mjs — TDD negative test for tools/check-drift.mjs.
//
// A drift gate without a proven negative test is worthless: this proves the
// gate actually bites when a consumer's committed bundle copy goes stale,
// and stays green on an untouched tree. The staleness injection happens on a
// COPY in a scratch directory — the real tracked tree is never mutated.

import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";
import { checkConsumerBundleDrift, comparePagesElmIgnoringTimestamp } from "./lib/check-drift-core.mjs";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const elmM3e = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");
const realCommittedCemFacts = path.join(repoRoot, "packages", "m3e-okf", "data", "cem-facts.json");

test("check-drift core: GREEN on the real, untouched committed bundle copy", () => {
    const { ok, failures } = checkConsumerBundleDrift({
        repoRoot,
        elmM3e,
        label: "m3e-okf (clean)",
        files: [{ committedPath: realCommittedCemFacts, bundleFile: "cem-facts.json" }],
    });
    assert.equal(ok, true, `expected clean tree to be green, got: ${failures.join(" | ")}`);
});

test("check-drift core: RED when a COPY of the committed bundle has one field staled", () => {
    const work = fs.mkdtempSync(path.join(os.tmpdir(), "check-drift-negative-test-"));
    try {
        const staleCopyPath = path.join(work, "cem-facts.json");
        const original = JSON.parse(fs.readFileSync(realCommittedCemFacts, "utf8"));

        // One-field staleness: flip a single component's `tag`, a real field
        // this gate is meant to catch (a renamed/drifted tag would show up
        // exactly this way).
        assert.ok(Array.isArray(original.components) && original.components.length > 0, "fixture must have components to stale");
        original.components[0].tag = `${original.components[0].tag}-STALE-INJECTED`;
        fs.writeFileSync(staleCopyPath, JSON.stringify(original, null, 2));

        const { ok, failures } = checkConsumerBundleDrift({
            repoRoot,
            elmM3e,
            label: "m3e-okf (staled copy)",
            files: [{ committedPath: staleCopyPath, bundleFile: "cem-facts.json" }],
        });

        assert.equal(ok, false, "expected the staled copy to be flagged as drifted");
        assert.ok(failures.length > 0 && failures[0].includes("DRIFTED"), `expected a DRIFTED failure, got: ${JSON.stringify(failures)}`);

        // The real tracked file must be untouched by this test.
        const untouched = fs.readFileSync(realCommittedCemFacts, "utf8");
        assert.equal(JSON.parse(untouched).components[0].tag, original.components[0].tag.replace("-STALE-INJECTED", ""));
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
});

test("check-drift core (R-008): Pages.elm timestamp-only difference is treated as clean", () => {
    const before = `module Pages exposing (builtAt)\n\nbuiltAt : Time.Posix\nbuiltAt =\n    Time.millisToPosix 1000000000000\n`;
    const after = `module Pages exposing (builtAt)\n\nbuiltAt : Time.Posix\nbuiltAt =\n    Time.millisToPosix 1999999999999\n`;
    const result = comparePagesElmIgnoringTimestamp(after, before);
    assert.equal(result.ok, true);
    assert.equal(result.onlyTimestampDiffers, true);
});

test("check-drift core (R-008): a real content change beyond the timestamp still fails", () => {
    const before = `module Pages exposing (builtAt)\n\nbuiltAt : Time.Posix\nbuiltAt =\n    Time.millisToPosix 1000000000000\n`;
    const after = `module Pages exposing (builtAt, extra)\n\nbuiltAt : Time.Posix\nbuiltAt =\n    Time.millisToPosix 1999999999999\n`;
    const result = comparePagesElmIgnoringTimestamp(after, before);
    assert.equal(result.ok, false);
});

test("check-drift CLI: GREEN on the real, untouched workspace tree", () => {
    execFileSync(process.execPath, [path.join(repoRoot, "tools", "check-drift.mjs")], { cwd: repoRoot, stdio: "pipe" });
});
