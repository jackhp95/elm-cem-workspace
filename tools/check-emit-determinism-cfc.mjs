#!/usr/bin/env node
// check-emit-determinism-cfc.mjs — proves cem-figma-connect's `gen:emit` is
// byte-deterministic: two independent runs of the REAL m3-kit profile
// produce byte-identical output. Required by M3.a since the Elm emitter's
// purity contract ("no network, no env, no clock, no randomness" —
// profiles/m3-kit/emitters/elm.mjs's own PURITY doc comment) is now
// anchored on a bundle read from disk (profiles/m3-kit/facts/) rather than a
// single committed elm-facts.json, and a determinism regression here would
// silently break every downstream `check:drift`/publish gate.
//
// `src/cli.mjs emit --profile <name>` always writes to `generated/<name>/**`
// relative to the package root — there is no arbitrary --output flag, and a
// synthetic throwaway profile (copying only profile.json + correspondence.json,
// the way test/emitter-api.test.mjs's makeThrowawayM3KitProfile does) is
// NOT equivalent to the real one: it lacks examples.json/set-attrs.json/
// manual-correspondence.json, and an unfiltered (no --page) emit against it
// hits an unhandled html-label prop shape those side files exist to resolve
// (verified: emitter-api.test.mjs only ever narrows a throwaway profile with
// --page for exactly this reason). So "two separate locations" here means
// running the REAL m3-kit profile twice and snapshotting `generated/m3-kit`
// into a fresh temp dir after each run, rather than faking a second profile.
//
// This DOES overwrite the committed generated/m3-kit/** tree with itself,
// same as running `pnpm run gen:emit` normally — that is the correct,
// expected side effect (regenerating IS how a legitimate change lands), not
// a workaround.
//
// Usage: node tools/check-emit-determinism-cfc.mjs
// Exits nonzero on any byte difference between the two runs.

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { listFilesRecursive } from "./lib/check-drift-core.mjs";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const pkgDir = path.join(repoRoot, "pipeline", "elm-cem-figma-connect");
const cli = path.join(pkgDir, "src", "cli.mjs");
const generatedDir = path.join(pkgDir, "generated", "m3-kit");

function runEmit() {
    const result = spawnSync(process.execPath, [cli, "emit", "--profile", "m3-kit"], {
        cwd: pkgDir,
        encoding: "utf8",
    });
    if (result.status !== 0) {
        throw new Error(`gen:emit failed (exit ${result.status}):\n${result.stdout}\n${result.stderr}`);
    }
}

function snapshot(label) {
    const dest = fs.mkdtempSync(path.join(os.tmpdir(), `cfc-emit-determinism-${label}-`));
    fs.cpSync(generatedDir, dest, { recursive: true });
    return dest;
}

function main() {
    console.log("check-emit-determinism-cfc: run A");
    runEmit();
    const outA = snapshot("a");

    console.log("check-emit-determinism-cfc: run B");
    runEmit();
    const outB = snapshot("b");

    try {
        const filesA = listFilesRecursive(outA);
        const filesB = listFilesRecursive(outB);

        const problems = [];

        if (filesA.length === 0) {
            problems.push("run A emitted ZERO files — a gate that passed on nothing proves nothing");
        }

        const onlyInA = filesA.filter((f) => !filesB.includes(f));
        const onlyInB = filesB.filter((f) => !filesA.includes(f));
        if (onlyInA.length > 0) problems.push(`files only in run A: ${onlyInA.join(", ")}`);
        if (onlyInB.length > 0) problems.push(`files only in run B: ${onlyInB.join(", ")}`);

        const diffs = [];
        for (const f of filesA) {
            if (!filesB.includes(f)) continue;
            const bufA = fs.readFileSync(path.join(outA, f));
            const bufB = fs.readFileSync(path.join(outB, f));
            if (!bufA.equals(bufB)) diffs.push(f);
        }
        if (diffs.length > 0) {
            problems.push(
                `${diffs.length} file(s) differ byte-for-byte between run A and run B: ${diffs.slice(0, 10).join(", ")}${diffs.length > 10 ? ` … (+${diffs.length - 10} more)` : ""}`
            );
        }

        if (problems.length > 0) {
            console.error("check-emit-determinism-cfc: FAILED");
            for (const p of problems) console.error(`  - ${p}`);
            process.exit(1);
        }

        console.log(
            `check-emit-determinism-cfc: OK — ${filesA.length} file(s) byte-identical across two independent gen:emit runs`
        );
    } finally {
        fs.rmSync(outA, { recursive: true, force: true });
        fs.rmSync(outB, { recursive: true, force: true });
    }
}

main();
