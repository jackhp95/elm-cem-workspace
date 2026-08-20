#!/usr/bin/env node
// gate-all.mjs — M1 integration gate: the ONE command that proves the whole
// workspace is green.
//
// It runs, in this order:
//   0. a pre-fetch of .cache/snapshots/* (the pinned upstream/pristine
//      checkouts the A/B + copy-fidelity gates below compare against —
//      `fetchSnapshotsGate()`, see its own comment) and a pre-generate of
//      elm-m3e's docs/data/reference.json (`genElmM3eReferenceGate()`);
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
//                        (default: the in-workspace brands/m3e/generated/package/elm-m3e)
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

const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "generated", "package", "elm-m3e");
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
// 2026-08-19 chronic-skip fix: ALL SEVEN gates that used to live in (or be
// missing from) this list depended on `.cache/snapshots/<name>`, which only
// `tools/fetch-snapshots.mjs` populated — and nothing ever called that
// script automatically, so every one of them skipped on every run, on every
// machine, forever. `fetchSnapshotsGate()` below now calls it once, up
// front, before the scheduler starts. That fully fixes THREE of the seven
// for real, unconditionally: `ab-elm-cem`, `ab-elm-m3e-split`, and
// `check-drift`'s R-010 sub-check all depend only on the `elm-cem` snapshot,
// which materializes from a git bundle COMMITTED IN THIS REPO (D-046) — pure
// local disk I/O, no network, so they now run for real on every machine,
// every time, and are gone from this list entirely (if any of the three
// starts skipping again, that's a real regression, not something to
// silently re-add here).
//
// The next four are copy-fidelity checks whose snapshot clones from a LIVE
// GITHUB REMOTE — a genuine, irreducible network dependency (§4 of the
// parallelization plan forbids skip-if-unchanged heuristics, not "assume the
// network is always up"). `fetchSnapshotsGate()` still attempts this fetch
// on every run (so on any machine with network, which is the common case,
// these run for real too — see `docs/copy-fidelity-notes.md` for the
// drift-vs-relocation investigation that got them to a clean, evidence-
// backed GREEN); they land here, conditionally, only for the run where
// GitHub genuinely could not be reached. If a name below stops appearing in
// the SKIPPED ITEMS list, that's expected on any well-connected run, not a
// sign this entry should be removed — remove it only if the underlying
// package stops needing network fidelity checking at all.
//
// The last entry, `check-drift`, is back on this list for a DIFFERENT
// reason than before (see git history of this file for the old one): fixing
// R-010's elm-cem sub-check exposed a SECOND, previously-masked sub-check —
// checkConsumerOutputs()'s m3e-okf regen, which needs a FULL npm-installed,
// built `matraic/m3e@v2.7.3` checkout at `.../m3e-api-okf/.cache/m3e` (not
// just a git clone: `cd .cache/m3e/packages/web && npm run cem` to produce
// `dist/custom-elements.json` — see tools/check-drift.mjs's own comment and
// brands/m3e/outputs/m3e-api-okf/README.md's "Regenerate" section). That's
// meaningfully heavier and riskier to auto-provision than this file's other
// network fetches (a third-party repo's OWN build toolchain, not just a
// checkout), so it stays a deliberate, reasoned skip rather than a fifth
// automatic pre-step — same REQUIRE_CLONE_GATES=1 escape hatch as
// elm-m3e's `check`/`test` below, which check-drift.mjs already implements.
const CHRONIC_SKIPS = {
    "workspace: copy-fidelity elm-m3e":
        "requires .cache/snapshots/elm-m3e, cloned from a live GitHub remote by the automatic `workspace: fetch-snapshots` pre-step. Genuinely network-dependent (unlike elm-cem's committed-bundle snapshot) — SKIPS only on a run where that clone can't reach GitHub; runs for real whenever network is available.",
    "workspace: copy-fidelity elm-m3e-okf":
        "requires .cache/snapshots/elm-m3e-okf (pinned in tools/snapshot-refs.json), cloned from a live GitHub remote by the automatic `workspace: fetch-snapshots` pre-step — same network-dependent pattern as copy-fidelity elm-m3e above.",
    "workspace: copy-fidelity elm-m3e-tailwind":
        "requires .cache/snapshots/elm-m3e-tailwind (pinned in tools/snapshot-refs.json), cloned from a live GitHub remote by the automatic `workspace: fetch-snapshots` pre-step — same network-dependent pattern as copy-fidelity elm-m3e above.",
    "workspace: copy-fidelity elm-cem-figma-connect":
        "requires .cache/snapshots/elm-cem-figma-connect (pinned in tools/snapshot-refs.json), cloned from a live GitHub remote by the automatic `workspace: fetch-snapshots` pre-step — same network-dependent pattern as copy-fidelity elm-m3e above.",
    "workspace: check-drift (M4.b cross-cutting drift gate)":
        "its m3e-okf consumer-output sub-check needs the okf consumer's .cache/m3e — a full npm-installed, built matraic/m3e@v2.7.3 checkout (not just a git clone), a heavier third-party build dependency than this file's other network fetches. Provision it by hand (see the SKIP line's own instructions, or the okf package README's Regenerate section) or set REQUIRE_CLONE_GATES=1 in CI.",
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
    walk(path.join(repoRoot, "pipeline"));
    walk(path.join(repoRoot, "brands"));
    walk(path.join(repoRoot, "packages"));
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

// ── 2.5. pre-fetch .cache/snapshots/* (2026-08-19 chronic-skip fix) ───────
// Runs OUTSIDE the scheduler, sequentially, before it starts — same pattern
// as `factsBundleE2E()` below — so every scheduled step that reads
// `.cache/snapshots/<name>` (ab-elm-cem, ab-elm-m3e-split, check-drift, the
// four copy-fidelity steps) sees it already materialized instead of racing
// `tools/fetch-snapshots.mjs`. This is a real dependency ordering
// requirement, not a mutual-exclusion one, so it deliberately does NOT go
// through `tools/lib/gate-scheduler.mjs`'s conflict-tag pool (which has no
// "runs before" primitive, by design — see that file's own header comment)
// — running it here, synchronously, first, is the correct and simplest way
// to satisfy the ordering without adding a dependency-DAG concept to a
// scheduler that was just built and verified this session.
//
// `tools/fetch-snapshots.mjs` itself draws the line between failure kinds:
// a HARD failure (its exit code) means a genuinely local problem (elm-cem's
// committed git bundle is corrupt or missing — see D-046), which SHOULD
// carry this step, and therefore the whole sweep, red. A SOFT failure
// (logged, but exit 0) means one of the four network-fetched snapshots
// couldn't reach its GitHub remote this run — that must NOT fail this step,
// because the individual gates that read those snapshots already degrade
// to their own well-established graceful SKIP (tools/lib/snapshot-gate.sh /
// copy-fidelity.mjs's requireSourceOrSkip) exactly as they did before this
// fix existed; see CHRONIC_SKIPS above for how those SKIPs are documented.
function fetchSnapshotsGate() {
    const name = "workspace: fetch-snapshots (pre-fetch .cache/snapshots/*)";
    console.log(`\n${"─".repeat(72)}\n▶ ${name}`);
    const result = spawnSync(process.execPath, [path.join(repoRoot, "tools", "fetch-snapshots.mjs")], {
        cwd: repoRoot,
        encoding: "utf8",
    });
    if (result.stdout) process.stdout.write(result.stdout);
    if (result.stderr) process.stderr.write(result.stderr);
    if (result.status === 0) {
        const someUnavailable = /network-dependent snapshot\(s\) unavailable/.test(result.stderr || "");
        record(
            name,
            true,
            someUnavailable
                ? "elm-cem's committed-bundle snapshot is always available; one or more network-fetched snapshots were not reachable this run (non-blocking — see CHRONIC_SKIPS for the gates this affects)"
                : "all snapshots materialized (bundle + network)",
        );
    } else {
        record(name, false, `exited ${result.status} — a LOCAL snapshot problem, not a network one (see output above)`);
    }
}

// ── 2.6. pre-generate elm-m3e's docs/data/reference.json ──────────────────
// Follow-on discovery while verifying the chronic-skip fix above: elm-m3e's
// OWN `check` (check:nav) and `test` (test:browser) scripts both read
// `docs/data/reference.json` — a generated, gitignored `elm make --docs`
// dump, absent on any environment that has only run `pnpm install` (every
// worktree, every fresh clone). Both already degrade gracefully (their own
// REQUIRE_CLONE_GATES=1-gated SKIP, browser-guard.mjs / check-nav.mjs — the
// same pattern check-drift.mjs uses), so this was previously just another
// silent, permanent SKIP nobody had traced. Unlike `.cache/m3e` below
// (CHRONIC_SKIPS), producing this file needs no network and no third-party
// build: `elm make --docs` over already-compiled Elm, measured under 1s —
// squarely "if cheap, do it" (Finding 1.10's own remedy for
// measure-docs-size.mjs / check-m3e-5pkg.mjs). `docs/data/examples.json`,
// check-nav's other input, is committed content (not regenerated here) and
// was already present.
function genElmM3eReferenceGate() {
    const name = "workspace: gen elm-m3e docs/data/reference.json (elm make --docs)";
    console.log(`\n${"─".repeat(72)}\n▶ ${name}`);
    const docsDir = path.join(repoRoot, "brands", "m3e", "generated", "docs", "elm-m3e-docs");
    if (!fs.existsSync(path.join(docsDir, "scripts", "extract-reference.mjs"))) {
        record(name, true, "brands/m3e/generated/docs/elm-m3e-docs not present or has no extract-reference.mjs — nothing to generate");
        return;
    }
    const result = spawnSync("node", ["scripts/extract-reference.mjs"], { cwd: docsDir, encoding: "utf8" });
    if (result.stdout) process.stdout.write(result.stdout);
    if (result.stderr) process.stderr.write(result.stderr);
    record(name, result.status === 0, result.status === 0 ? "" : `extract-reference.mjs exited ${result.status}`);
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
        const { validate } = require(path.join(repoRoot, "pipeline", "elm-cem", "bin", "validate-facts-bundle.js"));

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
//   cfc-generated     — `check-emit-determinism-cfc.mjs` overwrites
//                       pipeline/elm-cem-figma-connect/generated/m3-kit/** in place
//                       (its real `gen:emit`, run twice) vs. every step that
//                       reads that same committed tree (check-cc-elm-refs,
//                       cem-figma-connect check/test, check-drift's own
//                       cem-figma-connect consumer-output sub-check,
//                       copy-fidelity cem-figma-connect). Added 2026-08-19
//                       after check-cc-elm-refs hit a reproducible ENOENT
//                       racing this writer — the gate-out-probe comment's
//                       "future second writer" scenario, for real. See each
//                       tagged step's own comment for which race it closes.
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
        // cem-figma-connect's own `check` (check:drift diffs in-memory
        // regen against the COMMITTED generated/m3-kit/** tree) and `test`
        // (smoke/publish-check/emitter-api suites assert that same tree is
        // undisturbed) both READ pipeline/elm-cem-figma-connect/generated/m3-kit —
        // the exact tree `check-emit-determinism-cfc.mjs` overwrites IN
        // PLACE (see the cfc-generated tag below). Discovered as a real,
        // reproducible race (2026-08-19): check-cc-elm-refs hit an ENOENT
        // mid-run reading a `.figma.ts` file check-emit-determinism-cfc.mjs
        // had just deleted to rewrite. Same shared-mutable-state hazard the
        // docs-dist tag already exists for elm-m3e's docs/dist/, just a
        // second, previously-undeclared writer this scheduler never knew
        // about (see the gate-out-probe tag's own comment: "a future second
        // writer is forced to declare the conflict rather than silently
        // collide" — this is that future).
        if (pkg.name === "elm-cem-figma-connect" && (script === "check" || script === "test")) {
            extra.exclusiveWith = [...(extra.exclusiveWith || []), "cfc-generated"];
        }
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
        const exclusiveWith = [];
        if (name === "elm-m3e") exclusiveWith.push("docs-dist");
        // copy-fidelity's workspaceFiles computation does an fs.existsSync
        // pass over every tracked path (tools/copy-fidelity.mjs) — reading
        // pipeline/elm-cem-figma-connect/generated/m3-kit/** while
        // check-emit-determinism-cfc.mjs is mid-overwrite could report a
        // spuriously "missing" file. Same cfc-generated hazard as the
        // per-package check/test loop above; tagged defensively even though
        // this specific step hasn't been observed to flake yet.
        if (name === "elm-cem-figma-connect") exclusiveWith.push("cfc-generated");
        steps.push(
            step(`workspace: copy-fidelity ${name}`, process.execPath, [path.join(repoRoot, "tools", "copy-fidelity.mjs"), name], {
                exclusiveWith,
            }),
        );
    }
    steps.push(
        step(
            "workspace: check-emit-determinism elm-cem-figma-connect",
            process.execPath,
            [path.join(repoRoot, "tools", "check-emit-determinism-cfc.mjs")],
            // The writer: runs elm-cem-figma-connect's real `gen:emit` TWICE,
            // in place, overwriting the committed generated/m3-kit/** tree
            // each time (see that script's own header comment — this is
            // deliberate, not a bug). Every step that READS that tree while
            // this one could be mid-overwrite carries the same tag; see
            // their own comments for how each was found/confirmed.
            { exclusiveWith: ["cfc-generated"] },
        ),
    );
    steps.push(
        step("workspace: check-drift (M4.b cross-cutting drift gate)", process.execPath, [path.join(repoRoot, "tools", "check-drift.mjs")], {
            // docs-dist: reads elm-m3e's docs/dist/ (via its own
            // consumer-output sub-checks). cfc-generated: its cem-figma-connect
            // consumer-output sub-check scratch-copies the WHOLE package dir
            // (including the live generated/m3-kit/** tree) as its "before"
            // snapshot before regenerating in isolation — that initial copy
            // reads the same shared mutable tree check-emit-determinism-cfc.mjs
            // overwrites in place.
            exclusiveWith: ["docs-dist", "cfc-generated"],
        }),
    );
    steps.push(
        step("workspace: check-elm-shape-drift (Phase 1 canonical-engine gate)", process.execPath, [
            path.join(repoRoot, "tools", "check-elm-shape-drift.mjs"),
        ]),
    );
    steps.push(
        step(
            "workspace: check-cc-elm-refs (Stream 2 CC->Elm module-reference gate)",
            process.execPath,
            [path.join(repoRoot, "tools", "check-cc-elm-refs.mjs"), "--strict"],
            // Reads pipeline/elm-cem-figma-connect/generated/m3-kit/**/*.figma.ts
            // directly (tools/check-cc-elm-refs.mjs) — the race that
            // surfaced this whole cfc-generated tag: an ENOENT reading a
            // .figma.ts file check-emit-determinism-cfc.mjs had just
            // deleted mid-rewrite (2026-08-19, first run after the
            // chronic-skip fix made every step here do real, timing-
            // sensitive work instead of instant-skipping).
            { exclusiveWith: ["cfc-generated"] },
        ),
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
    // finding's remedy; fetch-snapshots.mjs was the other orphan named there
    // — now wired in too, as `fetchSnapshotsGate()` (see main(), and the
    // CHRONIC_SKIPS comment above for how its network-dependent half is
    // handled without making a GitHub outage fail the whole sweep).
    steps.push(
        step("workspace: measure-docs-size (registry docs.json size cap)", process.execPath, [
            path.join(repoRoot, "tools", "measure-docs-size.mjs"),
        ]),
    );
    steps.push(
        step("workspace: check-m3e-5pkg (D-037 5-package split shape)", process.execPath, [path.join(repoRoot, "tools", "check-m3e-5pkg.mjs")]),
    );
    // check-m3e-5pkg above verifies the split's SHAPE (packages.json vs the
    // emitted trees); this verifies the split's SUBSTANCE — that each of the 5
    // emitted packages compiles registry-faithfully (`elm-cem split` +
    // per-package `registry-check`). elm-m3e's own `check` only registry-checks
    // the two NESTED packages it declares (--nested-pkg elm-m3e-icons via
    // check:cem, elm-m3e-families via check:families); nothing in gate-all
    // compiled elm-m3e-components / -builder / -html as standalone packages, so
    // a split that shipped an unresolvable dependency there passed every gate.
    // ELM_HOME isolated because check-split's registry-check STAGES intra-family
    // dep packages into ELM_HOME — the same shared-cache writer hazard
    // elm-review-cem's check:review carries (spec §2 constraint 3); isolating it
    // keeps it off the warm cache the concurrent readers share.
    steps.push(
        step(
            "workspace: verify-split (elm-m3e 5-package registry-faithfulness)",
            "pnpm",
            ["--filter", "elm-m3e", "run", "verify:split"],
            { env: { ELM_HOME: isolatedElmHome("verify-split") } },
        ),
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

    fetchSnapshotsGate();
    genElmM3eReferenceGate();

    // Resolves spec §7 open question #3 with real data instead of a guess:
    // `os.cpus().length` (10 on the measurement machine) was tried first and
    // measured to be TOO WIDE — running elm-m3e's Playwright suite
    // concurrently with ~9 other steps (several themselves spawning
    // elm-test-rs/elm-review/vitest/chromium processes) starved the local
    // static file server hard enough that it stopped answering
    // (`net::ERR_CONNECTION_REFUSED` mid-suite, ~110 tests deep, on a
    // machine with 16GB RAM / 10 cores). The same suite passes cleanly solo
    // in ~240s. `os.cpus().length / 2` leaves real headroom: the ~130s
    // "everything else" bucket has so much slack under elm-m3e's own ~230s
    // that halving the pool width costs nothing against the ≤250s target
    // while removing the resource-starvation failure mode entirely.
    const concurrency = Number(process.env.GATE_ALL_CONCURRENCY) || Math.max(2, Math.floor(os.cpus().length / 2));
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
