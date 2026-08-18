#!/usr/bin/env node
// bump.mjs — M4.a: `pnpm run bump -- <version>`, the ONE gated command that
// re-pins @m3e/web to an exact version everywhere, regenerates the facts
// bundle exactly once from the producer, fans it out to every consumer,
// runs the full workspace gate sweep, and writes a human-readable diff
// report — without ever pushing, publishing, tagging, or touching anything
// outside this workspace.
//
// Usage: pnpm run bump -- <exact-version>
//
// `bump` to the CURRENT pinned version is a required, tested invariant: a
// byte-stable no-op (nothing in the tree changes). That is what proves this
// command is safe to run "just to check" — see tools/check-drift.test.mjs's
// sibling reference-bar commands.
//
// Zero dependencies (plain Node ESM). Uses tools/lib/regen.mjs (R-014) for
// the one shared regeneration definition — this is the only caller that
// needed a new one.

import { spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { generateBundleToTemp } from "./lib/regen.mjs";
import { comparePagesElmIgnoringTimestamp } from "./lib/check-drift-core.mjs";
import { classifyDelta, readBaseSources } from "../packages/cem-figma-connect/src/tokens/classify-delta.mjs";
import { changesFromVerdict, runGate } from "../packages/cem-figma-connect/src/tokens/token-change-report.mjs";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const EXACT_VERSION = /^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$/;
const DEP_FIELDS = ["dependencies", "devDependencies", "peerDependencies", "optionalDependencies"];
const REPORT_PATH = path.join(repoRoot, "docs", "facts-bundle", "m4-bump-report.md");
const ELM_M3E = path.join(repoRoot, "packages", "elm-m3e");
const PAGES_ELM_REL = "packages/elm-m3e/docs/.elm-pages/Pages.elm";

// Consumers, in a fixed (arbitrary — none depends on another) order, so the
// fan-out is deterministic run to run.
const CONSUMERS = [
    {
        pkgName: "cem-figma-connect",
        committed: [
            { path: path.join(repoRoot, "packages", "cem-figma-connect", "profiles", "m3-kit", "facts", "cem-facts.json"), bundleFile: "cem-facts.json" },
            { path: path.join(repoRoot, "packages", "cem-figma-connect", "profiles", "m3-kit", "facts", "elm-api-facts.json"), bundleFile: "elm-api-facts.json" },
        ],
    },
    {
        pkgName: "m3e-docs",
        committed: [{ path: path.join(repoRoot, "packages", "m3e-okf", "data", "cem-facts.json"), bundleFile: "cem-facts.json" }],
    },
    {
        pkgName: "tailwind-m3e-web",
        committed: [{ path: path.join(repoRoot, "packages", "tailwind-m3e-web", "data", "cem-facts.json"), bundleFile: "cem-facts.json" }],
    },
];

// Finding 1.6 (docs/reviews/2026-08-17-thermonuclear-workspace-review.md):
// bump used to rewrite every package.json, regenerate every consumer bundle,
// THEN run gate-all — a gate failure exited 1 leaving a half-applied
// migration in the working tree with no rollback. `rollbackArmed` flips true
// only once `ensureCleanTree` has verified the tree, so ANY failure from that
// point on (repin, pnpm install, a consumer's gen:facts, or gate-all itself)
// restores the pre-mutation state instead of leaving a partial migration.
let rollbackArmed = false;

// Requiring a clean tree up front is what makes the rollback below safe and
// precise: every uncommitted change present at failure time is then
// GUARANTEED to be something this run itself created, so reverting all
// tracked modifications can never discard pre-existing, unrelated work.
function ensureCleanTree() {
    const status = spawnSync("git", ["status", "--porcelain"], { cwd: repoRoot, encoding: "utf8" });
    if (status.stdout.trim()) {
        fail(
            "the working tree is not clean. bump mutates package.json/lockfile/consumer bundle files " +
                "across the workspace and rolls itself back to the pre-mutation state on any failure " +
                "(finding 1.6) — that rollback is only safe against a KNOWN starting point. Commit or " +
                "stash your changes first, then re-run.\n\n" +
                status.stdout,
        );
    }
}

// Restores every tracked file bump may have touched back to its pre-mutation
// (HEAD) content. `keepPath` (relative to repoRoot), when given, is excluded
// from the revert — used for the m4-bump-report.md diagnostic, which should
// survive a rollback so a human can see WHY it rolled back.
function rollback(keepPath) {
    console.error("\nbump: ROLLING BACK to the pre-mutation state (finding 1.6)...");
    const args = ["checkout", "--", "."];
    if (keepPath) args.push(`:(exclude)${keepPath}`);
    const r = spawnSync("git", args, { cwd: repoRoot, stdio: "inherit" });
    if (r.status !== 0) {
        console.error(
            "bump: WARNING — the rollback `git checkout` itself failed; the tree may be left half-mutated. " +
                "Run `git status` and restore manually.",
        );
        return;
    }
    console.error(
        "bump: rollback complete — package.json/lockfile/consumer bundles restored to their pre-bump state." +
            (keepPath ? ` (${keepPath} was left in place.)` : ""),
    );
}

function fail(msg) {
    console.error(`bump: FAIL — ${msg}`);
    if (rollbackArmed) {
        rollbackArmed = false; // avoid double-rollback if fail() is somehow reached twice
        rollback();
    }
    process.exit(1);
}

// Closes a gap independent review found in finding 1.6: `fail()` above only
// catches EXPECTED failures — the ones this file itself detects and routes
// through a `fail(...)` call. An unexpected raw JS exception after
// `rollbackArmed` flips true (malformed JSON from a consumer's bundle file,
// a throw inside generateBundleToTemp(), bad `pnpm ls -r --json` output) does
// NOT go through `fail()` — it propagates straight past every rollback site
// and would leave the tree half-mutated with no rollback, exactly the
// failure mode 1.6 exists to prevent. This is the catch-all for that case.
// Every function bump.mjs calls here is synchronous (spawnSync throughout,
// no promises) so a plain try/catch around `main()` catches 100% of the
// realistic cases; the process-level handlers below are a pure backstop in
// case async code is ever added later, not load-bearing today.
let rolledBackOnCrash = false;
function rollbackOnCrash(err) {
    console.error(`\nbump: UNCAUGHT ERROR — ${err && err.stack ? err.stack : err}`);
    if (rollbackArmed && !rolledBackOnCrash) {
        rolledBackOnCrash = true;
        rollbackArmed = false;
        rollback();
    }
    process.exit(1);
}
process.on("uncaughtException", rollbackOnCrash);
process.on("unhandledRejection", rollbackOnCrash);

function run(name, command, args, options = {}) {
    console.log(`\n${"─".repeat(72)}\n▶ ${name}\n$ ${command} ${args.join(" ")}`);
    const result = spawnSync(command, args, { stdio: "inherit", cwd: repoRoot, ...options });
    if (result.error) fail(`${name} failed to spawn: ${result.error.message}`);
    return result.status === 0;
}

// ── step 1: re-pin @m3e/web to the exact requested version everywhere ──────
function discoverWorkspaceDirs() {
    const listed = spawnSync("pnpm", ["ls", "-r", "--depth", "-1", "--json"], { cwd: repoRoot, encoding: "utf8" });
    if (listed.status !== 0 || !listed.stdout) fail("`pnpm ls -r --depth -1 --json` failed; cannot enumerate the workspace.");
    return JSON.parse(listed.stdout).map((p) => p.path);
}

function repin(version) {
    const dirs = discoverWorkspaceDirs();
    const touched = [];
    for (const dir of dirs) {
        const pkgPath = path.join(dir, "package.json");
        const raw = fs.readFileSync(pkgPath, "utf8");
        const pkg = JSON.parse(raw);
        let changed = false;
        for (const field of DEP_FIELDS) {
            if (pkg[field]?.["@m3e/web"] && pkg[field]["@m3e/web"] !== version) {
                pkg[field]["@m3e/web"] = version;
                changed = true;
            }
        }
        if (changed) {
            // Preserve the file's trailing newline convention; JSON.stringify + "\n" matches every package.json in this workspace.
            fs.writeFileSync(pkgPath, `${JSON.stringify(pkg, null, 2)}\n`);
            touched.push(path.relative(repoRoot, pkgPath));
        }
    }
    return touched;
}

// ── step 6: R-008 — a docs build run inside `gate-all` may rewrite
// Pages.elm's build timestamp. If that is the ONLY change, restore it so the
// idempotence gate (`git diff --exit-code`) stays honest: a meaningless
// timestamp is not "the tree changed". A real content change is left alone.
function restorePagesElmIfOnlyTimestampChanged() {
    const abs = path.join(repoRoot, PAGES_ELM_REL);
    if (!fs.existsSync(abs)) return;
    const status = spawnSync("git", ["status", "--porcelain", "--", PAGES_ELM_REL], { cwd: repoRoot, encoding: "utf8" });
    if (!status.stdout.trim()) return;
    const head = spawnSync("git", ["show", `HEAD:${PAGES_ELM_REL}`], { cwd: repoRoot, encoding: "utf8" });
    if (head.status !== 0) return;
    const { ok, onlyTimestampDiffers } = comparePagesElmIgnoringTimestamp(fs.readFileSync(abs, "utf8"), head.stdout);
    if (ok && onlyTimestampDiffers) {
        spawnSync("git", ["checkout", "--", PAGES_ELM_REL], { cwd: repoRoot });
        console.log(`bump: restored ${PAGES_ELM_REL} — only its build timestamp had changed (R-008).`);
    }
}

// ── report: new/removed components, changed enums/attributes ───────────────
function indexByTag(components) {
    const map = new Map();
    for (const c of components || []) map.set(c.tag, c);
    return map;
}

function diffBundles(before, after) {
    const beforeMap = indexByTag(before.components);
    const afterMap = indexByTag(after.components);
    const added = [...afterMap.keys()].filter((t) => !beforeMap.has(t)).sort();
    const removed = [...beforeMap.keys()].filter((t) => !afterMap.has(t)).sort();
    const changed = [];
    for (const tag of [...afterMap.keys()].sort()) {
        if (!beforeMap.has(tag)) continue;
        const b = beforeMap.get(tag);
        const a = afterMap.get(tag);
        const bAttrs = new Map((b.attributes || []).map((x) => [x.name, x]));
        const aAttrs = new Map((a.attributes || []).map((x) => [x.name, x]));
        const attrAdded = [...aAttrs.keys()].filter((n) => !bAttrs.has(n)).sort();
        const attrRemoved = [...bAttrs.keys()].filter((n) => !aAttrs.has(n)).sort();
        const enumChanges = [];
        for (const [name, aAttr] of aAttrs) {
            const bAttr = bAttrs.get(name);
            if (!bAttr) continue;
            if (JSON.stringify(bAttr.enum) !== JSON.stringify(aAttr.enum)) {
                enumChanges.push({ name, before: bAttr.enum, after: aAttr.enum });
            }
        }
        if (attrAdded.length || attrRemoved.length || enumChanges.length) {
            changed.push({ tag, attrAdded, attrRemoved, enumChanges });
        }
    }
    return { added, removed, changed };
}

// ── Phase 4 (L7): classify the token delta this bump introduces and render a
// NON-BLOCKING section (Decision 3). The only token INPUT a bump changes is the
// facts bundle's cssProperties (from @m3e/web); the repo's own CSS token
// sources (seed/palette/sys/theme) are held constant. A new/renamed component
// var → required-code-change naming utilities.css; nothing → a pure re-theme.
function tokenChangeSection(before, after) {
    let verdict;
    try {
        const baseSources = readBaseSources();
        verdict = classifyDelta({ ...baseSources, cemFacts: before }, { ...baseSources, cemFacts: after });
    } catch (e) {
        return { lines: ["## Token-tier change (Phase 4)", "", `_Skipped — classifier error: ${e.message}_`, ""], blocking: false };
    }
    const changes = changesFromVerdict(verdict);
    const gate = runGate(changes, { strict: false }); // v1: warn, never block a bump
    const lines = ["## Token-tier change (Phase 4)", ""];
    if (verdict.kind === "retheme") {
        lines.push("Pure re-theme — no covered emitter output or token name/edge changed; no code change forced.", "");
    } else {
        lines.push(
            `**Required code change** — tier **${verdict.tier}**, reason **${verdict.reason}**. ${verdict.detail}`,
            "",
            verdict.outputs.length ? `Affected emitter outputs: ${verdict.outputs.map((o) => `\`${o.surface}\``).join(", ")}.` : "Caught by the token-graph name/edge axis (no emitter-output byte diff).",
            "",
            "> Gate policy: NON-BLOCKING in v1 (Decision 3) — surfaced here as a warning; the bump is not failed on it.",
            "",
        );
    }
    return { lines, blocking: gate.blockingChanges.length > 0 };
}

function renderReport({ fromVersion, toVersion, repinned, diff, gateAllOk, gateAllSummary, tokenSectionLines = [] }) {
    const lines = [];
    lines.push(`# m4 bump report — @m3e/web ${fromVersion} → ${toVersion}`);
    lines.push("");
    lines.push(repinned.length ? `Re-pinned in: ${repinned.join(", ")}.` : "No re-pin was needed — the workspace already declared this exact version everywhere.");
    lines.push("");
    lines.push("## Component surface diff (facts bundle Face B)");
    lines.push("");
    if (diff.added.length === 0 && diff.removed.length === 0 && diff.changed.length === 0) {
        lines.push("No component, attribute, or enum changes — this bump left the facts bundle byte-identical.");
    } else {
        if (diff.added.length) {
            lines.push(`### New components (${diff.added.length})`, "", ...diff.added.map((t) => `- \`${t}\``), "");
        }
        if (diff.removed.length) {
            lines.push(`### Removed components (${diff.removed.length})`, "", ...diff.removed.map((t) => `- \`${t}\``), "");
        }
        if (diff.changed.length) {
            lines.push(`### Changed components (${diff.changed.length})`, "");
            for (const c of diff.changed) {
                lines.push(`- \`${c.tag}\``);
                if (c.attrAdded.length) lines.push(`  - added attributes: ${c.attrAdded.map((n) => `\`${n}\``).join(", ")}`);
                if (c.attrRemoved.length) lines.push(`  - removed attributes: ${c.attrRemoved.map((n) => `\`${n}\``).join(", ")}`);
                for (const e of c.enumChanges) {
                    lines.push(`  - \`${e.name}\` enum: ${JSON.stringify(e.before)} → ${JSON.stringify(e.after)}`);
                }
            }
            lines.push("");
        }
    }
    if (tokenSectionLines.length) lines.push(...tokenSectionLines);
    lines.push("## Gate sweep (`tools/gate-all.mjs`)");
    lines.push("");
    lines.push(gateAllOk ? "GATE-ALL GREEN — every item passed." : "GATE-ALL RED — see failures below.");
    if (!gateAllOk) {
        lines.push("", ...gateAllSummary.filter((r) => !r.ok).map((r) => `- FAIL: ${r.name}${r.detail ? ` — ${r.detail}` : ""}`));
    }
    lines.push("");
    return lines.join("\n");
}

function main() {
    // `pnpm run bump -- 2.7.3` forwards the literal `--` separator into argv
    // (unlike `npm run`), so strip it before reading the version.
    const args = process.argv.slice(2).filter((a) => a !== "--");
    const version = args[0];
    if (!version) fail("usage: pnpm run bump -- <exact-version>");
    if (!EXACT_VERSION.test(version)) fail(`"${version}" is not an exact version (no ranges/prefixes allowed).`);

    // Finding 1.6: verify a known-clean starting point, then arm the rollback
    // — every `fail()` call from here on restores this exact state instead of
    // leaving a half-applied migration.
    ensureCleanTree();
    rollbackArmed = true;

    // Snapshot the "before" bundle for the report, before anything changes.
    const beforeSnapshotPath = CONSUMERS[1].committed[0].path; // m3e-okf's data/cem-facts.json
    const fromVersionPkg = JSON.parse(fs.readFileSync(path.join(repoRoot, "packages", "tailwind-m3e-web", "package.json"), "utf8"));
    const fromVersion = fromVersionPkg.devDependencies?.["@m3e/web"] || "unknown";
    const before = fs.existsSync(beforeSnapshotPath) ? JSON.parse(fs.readFileSync(beforeSnapshotPath, "utf8")) : { components: [] };

    console.log(`bump: re-pinning @m3e/web to ${version}...`);
    const repinned = repin(version);
    console.log(repinned.length ? `bump: re-pinned in ${repinned.join(", ")}` : "bump: no re-pin needed (already at this exact version everywhere).");

    if (!run("pnpm install", "pnpm", ["install"])) fail("pnpm install failed.");

    console.log("\nbump: regenerating the facts bundle ONCE from the producer (elm-m3e's own config)...");
    const work = fs.mkdtempSync(path.join(os.tmpdir(), "bump-facts-"));
    let bundleDir;
    let outputDir;
    try {
        ({ outputDir, bundleDir } = generateBundleToTemp({ repoRoot, elmM3e: ELM_M3E, workDir: work }));

        console.log("\nbump: fanning out the SAME bundle to every consumer, in order...");
        for (const { pkgName, committed } of CONSUMERS) {
            const ok = run(`gen:facts (${pkgName})`, "pnpm", ["--filter", pkgName, "run", "gen:facts"], {
                // PREGENERATED_OUTPUT_DIR lets cem-figma-connect derive its
                // opaque-`Name` icon catalog from the same one-shot Face-A output.
                env: { ...process.env, PREGENERATED_BUNDLE_DIR: bundleDir, PREGENERATED_OUTPUT_DIR: outputDir },
            });
            if (!ok) fail(`gen:facts failed for ${pkgName}.`);
            for (const { path: committedPath } of committed) {
                if (!fs.existsSync(committedPath)) fail(`${pkgName} did not write ${committedPath}`);
            }
        }

        const after = JSON.parse(fs.readFileSync(beforeSnapshotPath, "utf8"));
        const diff = diffBundles(before, after);
        const tokenSection = tokenChangeSection(before, after);
        if (tokenSection.blocking) {
            console.warn(
                "\nbump: WARNING — this bump introduces an unfiled BLOCKING token-tier required-code-change " +
                    "(surfaced in the report). NON-BLOCKING in v1 (Decision 3): the bump is not failed on it.",
            );
        }

        console.log("\nbump: running the full gate sweep (tools/gate-all.mjs)...");
        const gateAll = spawnSync(process.execPath, [path.join(repoRoot, "tools", "gate-all.mjs")], {
            stdio: ["inherit", "pipe", "inherit"],
            cwd: repoRoot,
            encoding: "utf8",
        });
        if (gateAll.stdout) process.stdout.write(gateAll.stdout);
        const gateAllOk = gateAll.status === 0;

        restorePagesElmIfOnlyTimestampChanged();

        const report = renderReport({
            fromVersion,
            toVersion: version,
            repinned,
            diff,
            gateAllOk,
            gateAllSummary: [], // gate-all.mjs prints its own summary above; the report references pass/fail only.
            tokenSectionLines: tokenSection.lines,
        });
        fs.mkdirSync(path.dirname(REPORT_PATH), { recursive: true });
        fs.writeFileSync(REPORT_PATH, report);
        console.log(`\nbump: wrote ${path.relative(repoRoot, REPORT_PATH)}`);

        if (!gateAllOk) {
            // Roll back everything EXCEPT the report just written above — a
            // rolled-back bump should still leave behind the diagnostic that
            // explains why (finding 1.6). fail()'s own blanket rollback would
            // revert that too, so do it here and disarm before calling fail().
            rollback(path.relative(repoRoot, REPORT_PATH));
            rollbackArmed = false;
            fail("gate-all reported failures — see the report and the gate-all output above (tree rolled back to its pre-bump state).");
        }
        console.log(`\nbump: DONE — @m3e/web is ${version} everywhere, all gates green.`);
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
}

try {
    main();
} catch (err) {
    rollbackOnCrash(err);
}
