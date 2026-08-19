import assert from "node:assert/strict";
import { test } from "node:test";
import { runScheduled } from "./gate-scheduler.mjs";

test("two steps sharing a tag never run concurrently", async () => {
    const mkStep = (name, ms, tags) => ({
        name,
        command: process.execPath,
        args: ["-e", `setTimeout(() => process.exit(0), ${ms})`],
        exclusiveWith: tags,
    });
    // Overlap is observed via wall-clock: two 150ms steps sharing a tag must
    // serialize (>=290ms); the sibling test below proves the same steps run
    // in parallel when untagged, so this isn't just pool-width starvation.
    const steps = [mkStep("a", 150, ["shared"]), mkStep("b", 150, ["shared"])];
    const start = Date.now();
    await runScheduled(steps, { concurrency: 4, onResult: () => {} });
    const elapsed = Date.now() - start;
    assert.ok(elapsed >= 290, `expected serialized (>=290ms), got ${elapsed}ms`);
});

test("two steps with no shared tag run concurrently", async () => {
    const mkStep = (name, ms) => ({
        name,
        command: process.execPath,
        args: ["-e", `setTimeout(() => process.exit(0), ${ms})`],
    });
    const steps = [mkStep("a", 150), mkStep("b", 150)];
    const start = Date.now();
    await runScheduled(steps, { concurrency: 4, onResult: () => {} });
    const elapsed = Date.now() - start;
    assert.ok(elapsed < 250, `expected parallel (<250ms), got ${elapsed}ms`);
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
