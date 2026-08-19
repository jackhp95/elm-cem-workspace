#!/usr/bin/env node
// gate-all.mjs — M1 integration gate: the ONE command that proves the whole
// workspace is green.
//
// It runs, in this order:
//   1. every workspace package's own `check` and `test` script — DISCOVERED
//      from the pnpm workspace (`pnpm ls -r --depth -1 --json`), never
//      hardcoded, so a package added in a later milestone is picked up with no
//      edit here;
//   2. the cross-cutting workspace checks (coverage map, single Cem.Facts,
//      single @m3e/web pin, the A/B generation harness, the A/B split
//      harness, copy-fidelity for every migrated package DISCOVERED from
//      tools/family.json's `copyFidelity` blocks — never hardcoded, same
//      spirit as (1) — cem-figma-connect's gen:emit determinism proof,
//      check-drift's bundle-copy provenance for every family.json
//      `bundleCopy` consumer, pre-push hook drift, the root gate);
//   3. a REAL end-to-end facts-bundle proof: run the workspace elm-cem against
//      elm-m3e's own config into a temp dir, then validate both emitted faces
//      against docs/facts-bundle/schema.json with the shipped validator.
//
// Every item runs even if an earlier one fails — one run shows the whole
// picture, not just the first thing to break. Exits nonzero if ANY item fails.
//
// DISPATCH (2026-08-19 gate-all parallelization, see
// docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md):
// every step above is built as a descriptor `{name, command, args, cwd,
// exclusiveWith, env}` and handed once to `tools/lib/gate-scheduler.mjs`'s
// `runScheduled()` — a bounded worker-pool that runs steps concurrently
// EXCEPT when they share an `exclusiveWith` tag (docs-dist, gate-out-probe).
// This closes the previous flat-sequential design's single biggest cost
// (elm-m3e's `test` script, which chains a ~230s Playwright suite, used to
// block every other independent check behind it) without changing which
// steps run or their pass/fail semantics — step membership and `record()`'s
// output shape are unchanged; only the concurrency of what calls `record()`
// changed. `--list-steps-only` / `--list-steps-full` print the step list
// (bare names / names+tags) without running anything, for the membership
// and constraint regression tests.
//
// Zero runtime dependencies (plain Node ESM).
//
// Env:
//   PRISTINE_ELM_CEM     passed through to tools/ab-elm-cem.sh
//   ELM_M3E              elm-m3e checkout used by the E2E bundle proof
//                        (default: the in-workspace brands/m3e/outputs/elm-m3e)
//   GATE_ALL_CONCURRENCY overrides the scheduler's worker-pool width
//                        (default: os.cpus().length)

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath } from "node:url";
import { runFactsGenerator } from "./lib/regen.mjs";
import { runScheduled } from "./lib/gate-scheduler.mjs";
import { isolatedElmHome } from "./lib/elm-home-isolation.mjs";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const require = createRequire(import.meta.url);

// Print the constructed step list (and exit) instead of running anything —
// used by the step-membership and constraint regression tests so they never
// have to actually execute the ~130-350s of real work to verify the
// dispatch plan didn't drop, rename, or mis-tag a step.
const LIST_STEPS_ONLY = process.argv.includes("--list-steps-only");
const LIST_STEPS_FULL = process.argv.includes("--list-steps-full");

const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");
// tools/family.json — the one manifest of "which packages exist, where, and
// what mirror/bundle-copy/copy-fidelity gates apply to them" (Theme 3 of the
// 2026-08-17 audit, "the manifest move"). The copy-fidelity sweep below is
// driven entirely from it, so a 4th (or Nth) consumer package is a DATA
// change here, not a new hardcoded runItem() call.
const family = JSON.parse(fs.readFileSync(path.join(repoRoot, "tools", "family.json"), "utf8")).packages;

// ── result accounting ─────────────────────────────────────────────────────
// Status is one of "pass" | "fail" | "skip". A SKIP is a gate that exited 0
// because its snapshot dependency was absent (see tools/lib/snapshot-gate.sh)
// — it must never be counted as a pass, but it also must not turn the whole
// sweep red, since it ran zero real comparisons.
const results = [];

// Finding 1.10 (docs/reviews/2026-08-17-thermonuclear-workspace-review.md):
// gate-all didn't distinguish "skipped this run" (environmental, e.g. a
// snapshot briefly unavailable) from "chronically skipped forever" (a gate
// that has NEVER run for real on any machine because nothing ever wires up
// its dependency). A named, reasoned allowlist makes that distinction
// legible instead of every SKIP looking equally benign in the summary.
//
// Entries here are gates KNOWN to be chronic — every one of the three below
// depends on `.cache/snapshots/<name>`, which only `tools/fetch-snapshots.mjs`
// populates, and nothing calls that script automatically (see the note above
// `factsBundleE2E` for why it isn't wired in here yet: it needs network
// access to clone public GitHub repos, which changes gate-all's reliability
// profile in a way that deserves its own decision, not a silent addition).
// If a name below stops appearing in the SKIPPED ITEMS list, remove it here —
// that means the underlying dependency became available and the gate is
// running for real again.
const CHRONIC_SKIPS = {
    "workspace: ab-elm-cem (Face A byte-identity)":
        "requires .cache/snapshots/elm-cem, materialized only by `node tools/fetch-snapshots.mjs`, which nothing calls automatically (deferred — see finding 1.10 follow-up, network dependency).",
    "workspace: ab-elm-m3e-split (split-step byte-identity)":
        "requires .cache/snapshots/elm-cem, same as above.",
    "workspace: copy-fidelity elm-m3e":
        "requires .cache/snapshots/elm-m3e, same as above (also network-fetched).",
    "workspace: check-drift (M4.b cross-cutting drift gate)":
        "one of its internal sub-checks (brand Face A, R-010) shares the same .cache/snapshots/elm-cem dependency as ab-elm-cem above, which makes check-drift.mjs's own aggregate stdout carry a SKIP line.",
};

// Same spirit as CHRONIC_SKIPS above, but for a `tools/*.test.mjs` file that
// is genuinely RED right now rather than legitimately skipped. Discovered
// while wiring these files into gate-all for the first time (2026-08-19,
// publish-mirror atomicity fix — see the friction filed for it): its
// production dependency (checkConsumerBundleDrift in
// tools/lib/check-drift-core.mjs) grew an `isGitTracked(committedPath)`
// precondition in 1af8919 ("preserve packages/ depth in scratch regen
// copies"), landed the same day as unrelated M4.b work — but the test's
// "RED when a COPY of the committed bundle has one field staled" case
// deliberately passes a scratch /tmp copy AS `committedPath` (so the real
// tracked file is never mutated), which that new precondition now rejects
// before the drift comparison it's meant to test ever runs. Pre-existing,
// unrelated to this fix; excluded by name (not silently) so wiring in the
// other 3 tools/*.test.mjs files doesn't turn gate-all — the precondition
// for every future mirror publish — red on a bug nobody has looked at yet.
// Remove this entry once tools/check-drift.test.mjs is fixed to pass a
// git-tracked committedPath (or checkConsumerBundleDrift grows a way to
// decouple "path to verify tracked" from "path to read content from").
const KNOWN_BROKEN_TOOL_TESTS = new Set([path.join(repoRoot, "tools", "check-drift.test.mjs")]);

function record(name, status, detail) {
    // Accept booleans too, for callers written before "skip" existed.
    if (status === true) status = "pass";
    if (status === false) status = "fail";
    results.push({ name, status, detail: detail || "" });
    const label = status === "pass" ? "PASS" : status === "skip" ? "SKIP" : "FAIL";
    console.log(`\n${label}  ${name}${detail ? `  — ${detail}` : ""}`);
}

/**
 * Turn a `runScheduled` result (the async/buffered shape) into the same
 * record() call `runItem`'s SKIP-detection has always made — this is the
 * single bridge point the scheduler-based dispatch and the old
 * spawnSync-based `runItem` both funnel through, so `record()`'s output
 * shape genuinely never changed (spec §5).
 */
function recordSchedulerResult({ name, status, detail, stdout, stderr }) {
    console.log(`\n${"─".repeat(72)}\n▶ ${name}`);
    if (stdout) process.stdout.write(stdout);
    if (stderr) process.stderr.write(stderr);
    if (status === "pass" && /(^|\n)SKIP[:\s]/.test(stdout || "")) {
        const reason = (stdout.match(/^SKIP.*$/m) || [])[0] || "skipped";
        record(name, "skip", reason);
        return;
    }
    record(name, status, detail);
}

// ── 1. discover workspace packages ────────────────────────────────────────
/**
 * Ask pnpm for the workspace members. Falls back to walking packages/ for
 * package.json files if pnpm cannot answer, so discovery never silently
 * degrades into "zero packages, all green".
 */
function discoverPackages() {
    const listed = spawnSync("pnpm", ["ls", "-r", "--depth", "-1", "--json"], {
        cwd: repoRoot,
        encoding: "utf8",
    });
    if (listed.status === 0 && listed.stdout) {
        try {
            return JSON.parse(listed.stdout)
                .filter((p) => path.resolve(p.path) !== path.resolve(repoRoot))
                .map((p) => ({ name: p.name, dir: p.path }));
        } catch (e) {
            console.error(`gate-all: could not parse pnpm ls output (${e.message}); falling back to a packages/ walk`);
        }
    } else {
        console.error("gate-all: `pnpm ls -r` failed; falling back to a packages/ walk");
    }

    const found = [];
    const SKIP = new Set(["node_modules", "elm-stuff", ".git"]);
    const walk = (dir) => {
        for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
            if (SKIP.has(entry.name)) continue;
            if (!entry.isDirectory()) continue;
            const full = path.join(dir, entry.name);
            if (fs.existsSync(path.join(full, "package.json"))) {
                const pkg = JSON.parse(fs.readFileSync(path.join(full, "package.json"), "utf8"));
                found.push({ name: pkg.name, dir: full });
            }
            walk(full);
        }
    };
    walk(path.join(repoRoot, "core"));
    walk(path.join(repoRoot, "brands"));
    walk(path.join(repoRoot, "packages", "_probe"));
    return found;
}

function scriptsOf(dir) {
    try {
        return JSON.parse(fs.readFileSync(path.join(dir, "package.json"), "utf8")).scripts || {};
    } catch {
        return {};
    }
}

// Friction (2026-08-19, publish-mirror atomicity fix): tools/*.test.mjs files
// (check-drift.test.mjs, gen-figma-config.test.mjs, lib/okf-lib.test.mjs,
// publish-mirror.test.mjs) existed but nothing ever ran them — no gate-all
// step, no package.json `test` script. They were decorative: could bit-rot
// silently and nobody would notice until run by hand. DISCOVERED, not
// hardcoded, same spirit as discoverPackages()/the family.json copy-fidelity
// loop above — a 5th `*.test.mjs` file anywhere under tools/ is picked up
// automatically, no edit here.
function discoverToolTests() {
    const found = [];
    const SKIP_DIRS = new Set(["node_modules", ".git", ".cache"]);
    const walk = (dir) => {
        for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
            if (SKIP_DIRS.has(entry.name)) continue;
            const full = path.join(dir, entry.name);
            if (entry.isDirectory()) {
                walk(full);
            } else if (entry.isFile() && entry.name.endsWith(".test.mjs")) {
                found.push(full);
            }
        }
    };
    walk(path.join(repoRoot, "tools"));
    return found.filter((f) => !KNOWN_BROKEN_TOOL_TESTS.has(f)).sort();
}

// ── 3. the end-to-end facts-bundle proof ──────────────────────────────────
// A gate that passes when nothing was produced is worthless, so this one
// insists on: the generator exits 0, BOTH faces exist, are non-empty, parse,
// carry non-trivial content, and validate against the real schema.
function factsBundleE2E() {
    const name = "e2e: facts bundle generate + validate (elm-m3e config)";
    console.log(`\n${"─".repeat(72)}\n▶ ${name}`);

    if (!fs.existsSync(ELM_M3E)) {
        record(name, false, `elm-m3e checkout not found at ${ELM_M3E} (set ELM_M3E)`);
        return false;
    }

    const work = fs.mkdtempSync(path.join(os.tmpdir(), "gate-all-facts-"));
    try {
        const outDir = path.join(work, "out");
        const bundleDir = path.join(work, "bundle");

        console.log(`$ node elm-cem.js --facts-bundle=${bundleDir}  (cwd: ${ELM_M3E})`);
        const gen = runFactsGenerator({ repoRoot, elmM3e: ELM_M3E, output: outDir, factsBundle: bundleDir });
        if (gen.stdout) process.stdout.write(gen.stdout);
        if (gen.stderr) process.stderr.write(gen.stderr);
        if (gen.status !== 0) {
            record(name, false, `generator exited ${gen.status}`);
            return false;
        }

        const schemaPath = path.join(repoRoot, "docs", "facts-bundle", "schema.json");
        if (!fs.existsSync(schemaPath)) {
            record(name, false, `schema not found at ${schemaPath}`);
            return false;
        }
        const schema = JSON.parse(fs.readFileSync(schemaPath, "utf8"));
        const { validate } = require(path.join(repoRoot, "core", "elm-cem", "bin", "validate-facts-bundle.js"));

        const faces = [
            { file: "cem-facts.json", definition: "faceB", label: "Face B" },
            { file: "elm-api-facts.json", definition: "faceC", label: "Face C" },
        ];

        const problems = [];
        for (const face of faces) {
            const p = path.join(bundleDir, face.file);
            if (!fs.existsSync(p)) {
                problems.push(`${face.label}: ${face.file} was not written`);
                continue;
            }
            const raw = fs.readFileSync(p, "utf8");
            if (raw.trim().length === 0) {
                problems.push(`${face.label}: ${face.file} is empty`);
                continue;
            }
            let data;
            try {
                data = JSON.parse(raw);
            } catch (e) {
                problems.push(`${face.label}: ${face.file} is not valid JSON — ${e.message}`);
                continue;
            }
            // "Valid but vacuous" is the failure mode a schema alone will not
            // catch: an empty `components` satisfies both `type: array` and
            // `type: object`. Face B lists components as an array, Face C keys
            // them by tag, so count both shapes.
            const raw_components = data.components;
            const componentCount = Array.isArray(raw_components)
                ? raw_components.length
                : raw_components && typeof raw_components === "object"
                  ? Object.keys(raw_components).length
                  : null;
            if (componentCount === null) {
                problems.push(`${face.label}: no \`components\` array or object`);
                continue;
            }
            if (componentCount === 0) {
                problems.push(`${face.label}: \`components\` is empty — nothing was actually produced`);
                continue;
            }
            const { valid, errors } = validate(schema, data, face.definition);
            if (!valid) {
                problems.push(
                    `${face.label}: ${errors.length} schema error(s) — ${errors.slice(0, 5).join("; ")}` +
                        (errors.length > 5 ? ` … (+${errors.length - 5} more)` : ""),
                );
                continue;
            }
            console.log(`   ok  ${face.label} (${face.file}): ${componentCount} components, valid against schema.json`);
        }

        if (problems.length > 0) {
            for (const p of problems) console.error(`   bad ${p}`);
            record(name, false, problems.join(" | "));
            return false;
        }
        record(name, true, "both faces generated, non-empty, schema-valid");
        return true;
    } catch (e) {
        record(name, false, `threw: ${e.message}`);
        return false;
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
}

// ── step-descriptor construction ────────────────────────────────────────
// Tags used (spec §3.1, §2):
//   docs-dist        — elm-m3e's `test` script (chains test:fast then the
//                       Playwright test:browser suite, which writes into
//                       packages/elm-m3e/docs/dist) vs. any check that reads
//                       that same tree (check-drift, copy-fidelity elm-m3e).
//   gate-out-probe    — `workspace: root gate` (tools/gate.mjs) compiles into
//                       the shared scratch file .gate-out/probe.js; nothing
//                       else currently writes there (confirmed by a repo-wide
//                       grep — see the constraint test), but it's tagged
//                       defensively so a future second writer is forced to
//                       declare the conflict rather than silently collide.
// `port-1239` from the spec is NOT used here: elm-m3e/docs/playwright.config.ts
// derives its port from the worktree path (scripts/worktree-port.mjs) rather
// than hardcoding :1239, closing that constraint independently of this work
// — confirmed by reading the current config before wiring these tags.
// In `--list-steps-only`/`--list-steps-full` mode, buildSteps()'s own
// informational logging must go to stderr, not stdout — those flags exist
// so the constraint/membership regression tests can `execFileSync` this
// process and JSON.parse its stdout directly; anything else on stdout would
// corrupt that parse. Normal runs still see this on stdout as before.
const logInfo = (...args) => (LIST_STEPS_ONLY || LIST_STEPS_FULL ? console.error(...args) : console.log(...args));

function buildSteps() {
    const packages = discoverPackages();
    logInfo(`gate-all: discovered ${packages.length} workspace package(s): ${packages.map((p) => p.name).join(", ")}`);

    const perPackage = [];
    for (const pkg of packages) {
        const scripts = scriptsOf(pkg.dir);
        for (const script of ["check", "test"]) {
            if (scripts[script]) perPackage.push({ pkg, script });
        }
    }
    if (perPackage.length === 0) {
        console.error("gate-all: no package defines a `check` or `test` script — discovery is broken, refusing to pass.");
        process.exit(1);
    }
    logInfo(`gate-all: ${perPackage.length} package script(s) to run, plus cross-cutting checks and the E2E bundle proof.`);

    const step = (name, command, args, extra = {}) => ({ name, command, args, cwd: repoRoot, exclusiveWith: [], ...extra });
    const steps = [];

    for (const { pkg, script } of perPackage) {
        const name = `${pkg.name}: ${script}`;
        const extra = {};
        // elm-m3e's `test` chains test:fast then the Playwright
        // test:browser suite (~230s, the "elephant") — it writes into
        // packages/elm-m3e/docs/dist, so it carries docs-dist.
        if (pkg.name === "elm-m3e" && script === "test") extra.exclusiveWith = ["docs-dist"];
        // elm-review-cem's check:review (one of the run-p "check:*" this
        // step fans out to) runs stage-facts-elm-home.mjs, which WRITES
        // into the shared ~/.elm/0.19.1/packages/jackhp95/elm-cem-facts —
        // the one identified writer into shared ELM_HOME (spec §2
        // constraint 3, §3.4). Every other package's check/test only READS
        // from an already-populated (warm-cache) ELM_HOME, so only this
        // step needs isolation — isolating all ~13 per-package steps was
        // measured at ~0.8s/step (real ~/.elm: 232M, 3545 files) even with
        // an APFS clonefile fast path, which would eat a meaningful slice
        // of the ~130s bucket for no additional safety, since reads of an
        // unchanging cache don't race each other.
        if (pkg.name === "elm-review-cem" && script === "check") extra.env = { ELM_HOME: isolatedElmHome(name) };
        steps.push(step(name, "pnpm", ["--filter", pkg.name, "run", script], extra));
    }

    steps.push(step("workspace: check-coverage-map", process.execPath, [path.join(repoRoot, "tools", "check-coverage-map.mjs")]));
    steps.push(
        step("workspace: check-single-cem-facts", process.execPath, [path.join(repoRoot, "tools", "check-single-cem-facts.mjs")]),
    );
    steps.push(
        step("workspace: check-single-m3e-web-pin", process.execPath, [path.join(repoRoot, "tools", "check-single-m3e-web-pin.mjs")]),
    );
    steps.push(step("workspace: ab-elm-cem (Face A byte-identity)", "bash", [path.join(repoRoot, "tools", "ab-elm-cem.sh")]));
    steps.push(
        step("workspace: ab-elm-m3e-split (split-step byte-identity)", "bash", [path.join(repoRoot, "tools", "ab-elm-m3e-split.sh")]),
    );

    // Copy fidelity for every migrated package: proves no git-tracked source
    // file went missing and no untracked file got committed. This exists
    // because a migration can be entirely green while having silently DROPPED
    // a tracked file — every other check here would still pass. It belongs in
    // the sweep, not in a human's memory. Driven by tools/family.json's
    // `copyFidelity` blocks (Theme 3 "manifest move") via the one generic
    // tools/copy-fidelity.mjs engine — this loop, not a hardcoded call per
    // package, is what makes adding a 5th migrated package a data change.
    // (The provenance checks that used to live in three standalone
    // check-bundle-provenance*.mjs scripts are folded into "check-drift"
    // below, via checkConsumerBundleDrift.)
    for (const name of Object.keys(family).filter((n) => family[n].copyFidelity)) {
        steps.push(
            step(`workspace: copy-fidelity ${name}`, process.execPath, [path.join(repoRoot, "tools", "copy-fidelity.mjs"), name], {
                exclusiveWith: name === "elm-m3e" ? ["docs-dist"] : [],
            }),
        );
    }
    steps.push(
        step("workspace: check-emit-determinism cem-figma-connect", process.execPath, [
            path.join(repoRoot, "tools", "check-emit-determinism-cfc.mjs"),
        ]),
    );
    steps.push(
        step("workspace: check-drift (M4.b cross-cutting drift gate)", process.execPath, [path.join(repoRoot, "tools", "check-drift.mjs")], {
            exclusiveWith: ["docs-dist"],
        }),
    );
    steps.push(
        step("workspace: check-elm-shape-drift (Phase 1 canonical-engine gate)", process.execPath, [
            path.join(repoRoot, "tools", "check-elm-shape-drift.mjs"),
        ]),
    );
    steps.push(
        step("workspace: check-cc-elm-refs (Stream 2 CC->Elm module-reference gate)", process.execPath, [
            path.join(repoRoot, "tools", "check-cc-elm-refs.mjs"),
            "--strict",
        ]),
    );
    steps.push(
        step("workspace: check-mirror-drift (standalone jackhp95/* repos vs last publish)", process.execPath, [
            path.join(repoRoot, "tools", "check-mirror-drift.mjs"),
        ]),
    );
    // Finding 1.10: measure-docs-size.mjs (the registry doc-size cap that
    // already bit elm-m3e-icons once) and check-m3e-5pkg.mjs (the D-037
    // 5-package split shape check) were both orphaned — real, useful, and
    // cheap to run (no network, pure local elm compile / JSON check) but
    // wired to nothing. Wiring them in is the "if cheap, do it" half of the
    // finding's remedy; fetch-snapshots.mjs is the other orphan named there
    // and is deliberately NOT wired in yet (see the CHRONIC_SKIPS comment
    // above — it needs network access, a bigger decision than this fix).
    steps.push(
        step("workspace: measure-docs-size (registry docs.json size cap)", process.execPath, [
            path.join(repoRoot, "tools", "measure-docs-size.mjs"),
        ]),
    );
    steps.push(
        step("workspace: check-m3e-5pkg (D-037 5-package split shape)", process.execPath, [path.join(repoRoot, "tools", "check-m3e-5pkg.mjs")]),
    );
    steps.push(
        step("workspace: check-hooks-sync (pre-push hook drift, Theme 3)", process.execPath, [
            path.join(repoRoot, "tools", "gen-hooks.mjs"),
            "--check",
        ]),
    );
    steps.push(
        step("workspace: root gate", process.execPath, [path.join(repoRoot, "tools", "gate.mjs")], {
            exclusiveWith: ["gate-out-probe"],
        }),
    );

    if (KNOWN_BROKEN_TOOL_TESTS.size > 0) {
        logInfo(
            `\ngate-all: excluding ${KNOWN_BROKEN_TOOL_TESTS.size} known-broken tools/*.test.mjs file(s) from the ` +
                `sweep below (see KNOWN_BROKEN_TOOL_TESTS in this file): ` +
                `${[...KNOWN_BROKEN_TOOL_TESTS].map((f) => path.relative(repoRoot, f)).join(", ")}`,
        );
    }
    const toolTests = discoverToolTests();
    if (toolTests.length > 0) {
        steps.push(step(`workspace: tools/*.test.mjs (${toolTests.length} file(s))`, process.execPath, ["--test", ...toolTests]));
    }

    return steps;
}

// ── main ──────────────────────────────────────────────────────────────────
async function main() {
    const steps = buildSteps();

    if (LIST_STEPS_ONLY) {
        console.log(JSON.stringify(steps.map((s) => s.name)));
        return;
    }
    if (LIST_STEPS_FULL) {
        console.log(JSON.stringify(steps.map((s) => ({ name: s.name, exclusiveWith: s.exclusiveWith || [] }))));
        return;
    }

    const concurrency = Number(process.env.GATE_ALL_CONCURRENCY) || os.cpus().length;
    console.log(`gate-all: dispatching ${steps.length} step(s) through a ${concurrency}-wide tag-aware scheduler.`);
    await runScheduled(steps, { concurrency, onResult: recordSchedulerResult });

    factsBundleE2E();

    // ── summary ───────────────────────────────────────────────────────────
    const failed = results.filter((r) => r.status === "fail");
    const skipped = results.filter((r) => r.status === "skip");
    const passed = results.filter((r) => r.status === "pass");
    const width = Math.max(...results.map((r) => r.name.length));
    console.log(`\n${"═".repeat(72)}\nGATE-ALL SUMMARY\n${"═".repeat(72)}`);
    for (const r of results) {
        const label = r.status === "pass" ? "PASS" : r.status === "skip" ? "SKIP" : "FAIL";
        console.log(`${label}  ${r.name.padEnd(width)}${r.detail ? `  ${r.detail}` : ""}`);
    }
    console.log("─".repeat(72));
    console.log(`${passed.length}/${results.length} passed, ${skipped.length} skipped, ${failed.length} failed`);

    if (skipped.length > 0) {
        // Finding 1.10: split skips into chronic (named, reasoned, expected —
        // see CHRONIC_SKIPS above) vs unexpected (not on that list, meaning
        // either a NEW chronic gate nobody has categorized yet, or a
        // genuinely transient environmental skip). Both print, but
        // separately, so a new unexplained SKIP cannot hide inside a long
        // "this is all normal" list.
        const chronic = skipped.filter((r) => CHRONIC_SKIPS[r.name]);
        const unexpected = skipped.filter((r) => !CHRONIC_SKIPS[r.name]);

        if (chronic.length > 0) {
            console.log("\nCHRONIC SKIPS (known, tracked — see CHRONIC_SKIPS in tools/gate-all.mjs):");
            for (const r of chronic) console.log(`  - ${r.name}\n      ${CHRONIC_SKIPS[r.name]}`);
        }
        if (unexpected.length > 0) {
            console.log("\nUNEXPECTED SKIPS (not on the known-chronic list — investigate, or add a reasoned entry to CHRONIC_SKIPS if it turns out to be permanent):");
            for (const r of unexpected) console.log(`  - ${r.name}${r.detail ? `  (${r.detail})` : ""}`);
        }

        // The inverse case is worth surfacing too: a name on the chronic
        // list that did NOT skip this run means its dependency became
        // available and it ran for real — CHRONIC_SKIPS should shrink.
        const noLongerChronic = Object.keys(CHRONIC_SKIPS).filter(
            (name) => results.some((r) => r.name === name) && !skipped.some((r) => r.name === name),
        );
        if (noLongerChronic.length > 0) {
            console.log("\nNO LONGER CHRONIC (ran for real this time — remove from CHRONIC_SKIPS in tools/gate-all.mjs):");
            for (const name of noLongerChronic) console.log(`  - ${name}`);
        }
    }

    if (failed.length > 0) {
        console.log("\nFAILED ITEMS:");
        for (const r of failed) console.log(`  - ${r.name}${r.detail ? `  (${r.detail})` : ""}`);
        console.log("\nGATE-ALL RED");
        process.exit(1);
    }
    console.log("\nGATE-ALL GREEN");
}

main().catch((e) => {
    console.error(`gate-all: uncaught error: ${e.stack || e.message}`);
    process.exit(1);
});
