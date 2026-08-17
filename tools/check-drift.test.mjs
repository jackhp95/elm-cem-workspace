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
import { checkConsumerOutputDrift, consumerOutputDescriptors } from "./lib/consumer-output-drift.mjs";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const elmM3e = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");
const realCommittedCemFacts = path.join(repoRoot, "packages", "m3e-okf", "data", "cem-facts.json");
const descriptorsByKey = Object.fromEntries(consumerOutputDescriptors(repoRoot).map((d) => [d.key, d]));

/** Copy just the descriptor's committed `paths` into a scratch dir — never touches the real package. */
function copyCommittedPathsToScratch(descriptor) {
    const scratch = fs.mkdtempSync(path.join(os.tmpdir(), `check-drift-output-negative-${descriptor.key}-`));
    for (const rel of descriptor.paths) {
        const src = path.join(descriptor.pkgDir, rel);
        const dest = path.join(scratch, rel);
        fs.mkdirSync(path.dirname(dest), { recursive: true });
        fs.cpSync(src, dest, { recursive: true });
    }
    return scratch;
}

/** Find the first regular file under `root` (relative path), for perturbation. */
function firstFileUnder(root, rel) {
    const abs = path.join(root, rel);
    if (fs.statSync(abs).isFile()) return rel;
    for (const entry of fs.readdirSync(abs, { withFileTypes: true }).sort((a, b) => (a.name < b.name ? -1 : 1))) {
        if (entry.isFile()) return path.join(rel, entry.name);
        if (entry.isDirectory()) {
            const found = firstFileUnder(root, path.join(rel, entry.name));
            if (found) return found;
        }
    }
    return null;
}

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

// ── M4.b (round 2): consumer GENERATED OUTPUT drift ─────────────────────
//
// Prior to this, check-drift covered each consumer's facts-bundle COPY but
// never its downstream generated output — verified by hand: appending a line
// to packages/tailwind-m3e-web/generated/utilities.css left check-drift.mjs
// (and gate-all.mjs) fully green. One GREEN + one RED test per consumer,
// below, proves that hole is closed. Every perturbation happens on a scratch
// COPY (copyCommittedPathsToScratch) — the real tracked tree is never
// mutated by these tests.

// A descriptor that symlinks in an upstream `.cache` checkout (m3e-okf's
// guidance/OKF outputs derive from .cache/m3e — the matraic/m3e@v2.7.3 clone,
// gitignored) cannot be regenerated in a clone that lacks it. The CLI SKIPs it
// (check-drift.mjs, R-020/R-023); the direct-call tests must match that honesty
// rather than fail on a missing external input. Same guard, same reason.
function cacheAbsentSkipReason(descriptor) {
    if ((descriptor.symlinks || []).includes(".cache") && !fs.existsSync(path.join(descriptor.pkgDir, ".cache", "m3e"))) {
        return `${path.relative(repoRoot, path.join(descriptor.pkgDir, ".cache", "m3e"))} absent (upstream matraic/m3e@v2.7.3 checkout) — provision it or run in CI where it is provisioned`;
    }
    return false;
}

for (const key of ["cem-figma-connect", "m3e-okf", "tailwind-m3e-web"]) {
    const descriptor = descriptorsByKey[key];
    const skip = cacheAbsentSkipReason(descriptor);

    test(`check-drift core: GREEN on ${key}'s real, untouched generated output`, { skip }, () => {
        const { ok, failures } = checkConsumerOutputDrift(descriptor);
        assert.equal(ok, true, `expected clean tree to be green, got: ${failures.join(" | ")}`);
    });

    test(`check-drift core: RED when a COPY of ${key}'s committed output is perturbed`, { skip }, () => {
        const scratch = copyCommittedPathsToScratch(descriptor);
        try {
            const targetRel = firstFileUnder(scratch, descriptor.paths[0]);
            assert.ok(targetRel, `fixture must have at least one file under ${descriptor.paths[0]} to perturb`);
            const targetAbs = path.join(scratch, targetRel);
            const original = fs.readFileSync(targetAbs, "utf8");
            fs.writeFileSync(targetAbs, `${original}\n/* STALE-INJECTED-BY-TEST */\n`);

            const { ok, failures } = checkConsumerOutputDrift(descriptor, { committedRoot: scratch });

            assert.equal(ok, false, "expected the perturbed copy to be flagged as drifted");
            assert.ok(
                failures.some((f) => f.includes("DRIFTED")),
                `expected a DRIFTED failure, got: ${JSON.stringify(failures)}`,
            );

            // The real tracked file must be untouched by this test.
            const realAbs = path.join(descriptor.pkgDir, targetRel);
            assert.equal(fs.readFileSync(realAbs, "utf8"), original);
        } finally {
            fs.rmSync(scratch, { recursive: true, force: true });
        }
    });
}

test("check-drift CLI: GREEN on the real, untouched workspace tree", () => {
    execFileSync(process.execPath, [path.join(repoRoot, "tools", "check-drift.mjs")], { cwd: repoRoot, stdio: "pipe" });
});
