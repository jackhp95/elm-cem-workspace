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

function fail(msg) {
    console.error(`bump: FAIL — ${msg}`);
    process.exit(1);
}

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

function renderReport({ fromVersion, toVersion, repinned, diff, gateAllOk, gateAllSummary }) {
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
        });
        fs.mkdirSync(path.dirname(REPORT_PATH), { recursive: true });
        fs.writeFileSync(REPORT_PATH, report);
        console.log(`\nbump: wrote ${path.relative(repoRoot, REPORT_PATH)}`);

        if (!gateAllOk) fail("gate-all reported failures — see the report and the gate-all output above.");
        console.log(`\nbump: DONE — @m3e/web is ${version} everywhere, all gates green.`);
    } finally {
        fs.rmSync(work, { recursive: true, force: true });
    }
}

main();
