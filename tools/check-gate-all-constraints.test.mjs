// tools/check-gate-all-constraints.test.mjs — stress-tests the tag-based
// mutual-exclusion set gate-all.mjs's scheduler relies on (spec §2, plan
// Phase 1 Task 4). Reads the REAL step list via `--list-steps-full` so it
// exercises the actual construction code, not a hand-copied fixture.
import assert from "node:assert/strict";
import { test } from "node:test";
import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(fileURLToPath(import.meta.url));
const gateAll = path.join(repoRoot, "gate-all.mjs");

function listStepsFull() {
    return JSON.parse(execFileSync(process.execPath, [gateAll, "--list-steps-full"], { encoding: "utf8" }));
}

test("exactly the steps that touch docs/dist carry the docs-dist tag", () => {
    const steps = listStepsFull();
    const docsDistTagged = steps
        .filter((s) => s.exclusiveWith.includes("docs-dist"))
        .map((s) => s.name)
        .sort();
    assert.deepEqual(docsDistTagged, [
        "elm-m3e: test",
        "workspace: check-drift (M4.b cross-cutting drift gate)",
        "workspace: copy-fidelity elm-m3e",
    ]);
});

test("gate-out-probe tag is held only by the root gate step", () => {
    const steps = listStepsFull();
    const tagged = steps.filter((s) => s.exclusiveWith.includes("gate-out-probe"));
    assert.equal(tagged.length, 1);
    assert.equal(tagged[0].name, "workspace: root gate");
});

test("no step carries an unrecognized exclusiveWith tag (typo guard)", () => {
    const KNOWN_TAGS = new Set(["docs-dist", "gate-out-probe"]);
    const steps = listStepsFull();
    for (const s of steps) {
        for (const tag of s.exclusiveWith) {
            assert.ok(KNOWN_TAGS.has(tag), `unrecognized tag "${tag}" on step "${s.name}"`);
        }
    }
});
