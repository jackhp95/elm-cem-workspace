// tools/lib/gate-scheduler.mjs — tag-aware bounded worker-pool scheduler for
// gate-all.mjs. Replaces spawnSync + two serial `for` loops with async
// `spawn` under a concurrency cap, while respecting `exclusiveWith` tags so
// steps that touch shared mutable state (docs/dist, port 1239,
// .gate-out/probe.js) never run at the same moment.
//
// Design: docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md §3
// Plan:   docs/superpowers/plans/2026-08-18-gate-all-parallelization-plan.md Phase 1 Task 1
//
// This is a conflict-TAG model, not a dependency DAG (see spec §3.1) — a step
// is eligible to start iff none of its `exclusiveWith` tags are currently
// held by an in-flight step. Every step runs exactly once, even if others
// fail (spec §3.2 point 5) — nothing here treats a failure as a reason to
// stop scheduling the rest.
//
// Output is buffered per-step (never interleaved live) so failure
// attribution stays unambiguous under concurrency — `onResult` receives the
// full stdout/stderr for a step only once that step has finished.

import { spawn } from "node:child_process";

/**
 * @typedef {object} StepDescriptor
 * @property {string} name
 * @property {string} command
 * @property {string[]} args
 * @property {string} [cwd]
 * @property {string[]} [exclusiveWith] - opaque tags this step cannot run alongside
 * @property {Record<string,string>} [env] - merged over process.env for this step only
 */

/**
 * Run a list of step descriptors under a bounded worker pool that respects
 * tag-based mutual exclusion (`exclusiveWith`).
 *
 * @param {StepDescriptor[]} steps
 * @param {{concurrency:number, onResult:(r:{name:string,status:'pass'|'fail',detail:string,stdout:string,stderr:string,durationMs:number})=>void}} options
 * @returns {Promise<void>} resolves once every step has completed
 */
export function runScheduled(steps, { concurrency, onResult }) {
    const pending = [...steps];
    const heldTags = new Set();
    let running = 0;
    let settled = 0;

    return new Promise((resolve) => {
        if (steps.length === 0) return resolve();

        function pump() {
            if (settled === steps.length) return resolve();
            if (running >= concurrency) return;

            const idx = pending.findIndex((s) => !(s.exclusiveWith || []).some((tag) => heldTags.has(tag)));
            if (idx === -1) return; // nothing eligible right now — wait for a release

            const [step] = pending.splice(idx, 1);
            const tags = step.exclusiveWith || [];
            for (const t of tags) heldTags.add(t);
            running++;

            let stdout = "";
            let stderr = "";
            let done = false;
            // Wall-clock around the actual spawned process, not the pool-dispatch
            // bookkeeping around it — this is the number gate-all.mjs's SUMMARY
            // table and live per-step line report as each step's duration.
            const startedAt = Date.now();
            const child = spawn(step.command, step.args, {
                cwd: step.cwd,
                env: { ...process.env, ...(step.env || {}) },
            });
            child.stdout?.on("data", (d) => (stdout += d));
            child.stderr?.on("data", (d) => (stderr += d));
            child.on("error", (err) => {
                finish(1, `failed to spawn: ${err.message}`);
            });
            child.on("close", (code) => finish(code, null));

            function finish(code, spawnError) {
                if (done) return; // 'error' and 'close' can both fire for the same child
                done = true;
                for (const t of tags) heldTags.delete(t);
                running--;
                settled++;
                const ok = spawnError === null && code === 0;
                onResult({
                    name: step.name,
                    status: ok ? "pass" : "fail",
                    detail: ok ? "" : spawnError || `exit code ${code}`,
                    stdout,
                    stderr,
                    durationMs: Date.now() - startedAt,
                });
                pump();
                pump(); // a release may have unblocked more than one waiter
            }
        }

        // Kick off as many eligible steps as the pool allows.
        for (let i = 0; i < concurrency; i++) pump();
    });
}
