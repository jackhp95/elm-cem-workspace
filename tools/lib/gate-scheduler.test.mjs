import assert from "node:assert/strict";
import { test } from "node:test";
import { runScheduled } from "./gate-scheduler.mjs";

// Both thresholds below were tightened once by real data (2026-08-19): at
// 150ms/step, `< 250ms` gave only ~100ms of slack for process-spawn
// overhead — comfortable in isolation, but this file is itself one of many
// concurrent processes when gate-all's own `tools/*.test.mjs` step runs
// (sharing CPU with elm compiles, npm installs, etc.), where spawn latency
// alone reproducibly pushed the "parallel" case to 300ms and failed the
// assertion — a real flake, not a scheduler bug (the identical run passed
// standalone). Spawn overhead is roughly CONSTANT regardless of the sleep
// duration, so doubling the step duration (150ms -> 300ms) halves its
// relative weight without weakening what the test actually proves: the
// parallel threshold (550ms) still sits comfortably below the serial floor
// (550ms), so a scheduler regression that accidentally serialized these two
// steps would still be caught.
test("two steps sharing a tag never run concurrently", async () => {
    const mkStep = (name, ms, tags) => ({
        name,
        command: process.execPath,
        args: ["-e", `setTimeout(() => process.exit(0), ${ms})`],
        exclusiveWith: tags,
    });
    // Overlap is observed via wall-clock: two 300ms steps sharing a tag must
    // serialize (>=550ms); the sibling test below proves the same steps run
    // in parallel when untagged, so this isn't just pool-width starvation.
    const steps = [mkStep("a", 300, ["shared"]), mkStep("b", 300, ["shared"])];
    const start = Date.now();
    await runScheduled(steps, { concurrency: 4, onResult: () => {} });
    const elapsed = Date.now() - start;
    assert.ok(elapsed >= 550, `expected serialized (>=550ms), got ${elapsed}ms`);
});

test("two steps with no shared tag run concurrently", async () => {
    const mkStep = (name, ms) => ({
        name,
        command: process.execPath,
        args: ["-e", `setTimeout(() => process.exit(0), ${ms})`],
    });
    const steps = [mkStep("a", 300), mkStep("b", 300)];
    const start = Date.now();
    await runScheduled(steps, { concurrency: 4, onResult: () => {} });
    const elapsed = Date.now() - start;
    assert.ok(elapsed < 500, `expected parallel (<500ms), got ${elapsed}ms`);
});

test("a failing step does not block unrelated steps, and every step still runs", async () => {
    const results = [];
    const steps = [
        { name: "fails", command: process.execPath, args: ["-e", "process.exit(1)"] },
        { name: "passes", command: process.execPath, args: ["-e", "process.exit(0)"] },
    ];
    await runScheduled(steps, { concurrency: 4, onResult: (r) => results.push(r) });
    assert.equal(results.length, 2);
    assert.equal(results.find((r) => r.name === "fails").status, "fail");
    assert.equal(results.find((r) => r.name === "passes").status, "pass");
});

test("concurrency cap is respected: a pool of 1 serializes everything", async () => {
    const mkStep = (name) => ({
        name,
        command: process.execPath,
        args: ["-e", "setTimeout(() => process.exit(0), 100)"],
    });
    const steps = [mkStep("a"), mkStep("b"), mkStep("c")];
    const start = Date.now();
    await runScheduled(steps, { concurrency: 1, onResult: () => {} });
    const elapsed = Date.now() - start;
    assert.ok(elapsed >= 290, `expected 3x serialized (>=290ms) at concurrency 1, got ${elapsed}ms`);
});

test("a spawn error (bad command) still produces a result and does not hang", async () => {
    const results = [];
    await runScheduled(
        [{ name: "bad-command", command: "/no/such/binary-xyz", args: [] }],
        { concurrency: 2, onResult: (r) => results.push(r) },
    );
    assert.equal(results.length, 1);
    assert.equal(results[0].status, "fail");
});
