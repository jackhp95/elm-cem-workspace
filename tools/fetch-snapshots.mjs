// tools/fetch-snapshots.mjs — materialize the pinned upstream snapshots the A/B +
// copy-fidelity gates compare against, into .cache/snapshots/<name> (gitignored).
// Idempotent: a checkout already at the pinned SHA is left alone. See D-041.
//
// Two kinds of ref, two failure severities (2026-08-19 chronic-skip fix —
// gate-all.mjs now calls this automatically before the gates that read
// .cache/snapshots/*, so its exit code decides whether that carries the
// whole sweep red):
//   - `bundle` refs clone from a FILE COMMITTED IN THIS REPO (currently just
//     elm-cem's — see tools/snapshot-refs.json's own comment). Nothing
//     external has to cooperate for this to work, so a failure here is a
//     real local bug (corrupt bundle, wrong pinned sha) — a HARD failure.
//   - `repo`-only refs clone from a live GitHub remote. That can fail for
//     reasons that have nothing to do with this repo's correctness (offline,
//     rate-limited, GitHub down) — a SOFT failure: logged clearly, but never
//     enough on its own to make this script (or the gate-all step wrapping
//     it) exit nonzero. The gates that actually consume a missing snapshot
//     still degrade gracefully on their own (tools/lib/snapshot-gate.sh /
//     copy-fidelity.mjs's requireSourceOrSkip) exactly as before this
//     change — this script's exit code only ever reflects LOCAL problems.
// Set REQUIRE_SNAPSHOT_GATES=1 to promote soft (network) failures to hard
// ones too — the same switch snapshot-gate.sh / copy-fidelity.mjs already
// use to demand a fully-provisioned environment instead of degrading.
import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const refs = JSON.parse(readFileSync(path.join(repoRoot, "tools", "snapshot-refs.json"), "utf8"));
const cacheRoot = path.join(repoRoot, ".cache", "snapshots");
mkdirSync(cacheRoot, { recursive: true });

const REQUIRE = process.env.REQUIRE_SNAPSHOT_GATES === "1";
const git = (args, cwd) => spawnSync("git", args, { cwd, encoding: "utf8" });
const rmrf = (dir) => spawnSync("rm", ["-rf", dir]);
let hardFailures = 0;
let softFailures = 0;

for (const [name, { repo, sha, bundle }] of Object.entries(refs)) {
    if (name.startsWith("_")) continue;
    const dir = path.join(cacheRoot, name);
    const at = existsSync(dir) ? (git(["rev-parse", "HEAD"], dir).stdout || "").trim() : "";
    if (at === sha) { console.log(`fetch-snapshots: ${name} already at ${sha.slice(0, 8)}`); continue; }
    console.log(`fetch-snapshots: materializing ${name}@${sha.slice(0, 8)} ...`);
    if (bundle) {
        // Durable local reference: a committed git bundle of the workspace generator
        // (the elm-cem post-R-025 fork lives only in-workspace, so there is no remote
        // SHA to compare against — D-046). Clone straight from the bundle file.
        const bundlePath = path.resolve(repoRoot, bundle);
        if (!existsSync(bundlePath)) { console.error(`  HARD FAIL: bundle not found: ${bundlePath}`); hardFailures++; continue; }
        rmrf(dir); // re-materialize cleanly (bundle is self-contained; no remote to fetch from)
        if (git(["clone", "--quiet", bundlePath, dir]).status !== 0) { console.error(`  HARD FAIL: clone from bundle failed (${bundlePath})`); hardFailures++; continue; }
        if (git(["checkout", "--quiet", sha], dir).status !== 0) { console.error(`  HARD FAIL: checkout ${sha} failed`); hardFailures++; continue; }
        console.log(`  ok: ${name} at ${sha.slice(0, 8)} (from bundle)`);
        continue;
    }
    // repo-only ref: needs live network. Any failure past this point is SOFT
    // unless REQUIRE_SNAPSHOT_GATES=1 asks for the old hard-fail behavior.
    const fail = (msg) => {
        if (REQUIRE) { console.error(`  HARD FAIL (REQUIRE_SNAPSHOT_GATES=1): ${msg}`); hardFailures++; }
        else { console.error(`  soft fail (network-dependent, non-blocking): ${msg}`); softFailures++; }
    };
    if (!existsSync(dir)) {
        // Prefer a local mirror if the same repo is cloned nearby (fast, offline); else the remote.
        const local = path.join("/tmp/latest", `${name}-full`);
        const src = existsSync(path.join(local, ".git")) ? local : repo;
        if (git(["clone", "--quiet", src, dir]).status !== 0) { fail(`clone failed (${src})`); continue; }
        if (src !== repo) git(["remote", "set-url", "origin", repo], dir);
    }
    if (git(["fetch", "--quiet", "origin", sha], dir).status !== 0) git(["fetch", "--quiet", "origin"], dir);
    if (git(["checkout", "--quiet", sha], dir).status !== 0) { fail(`checkout ${sha} failed`); continue; }
    console.log(`  ok: ${name} at ${sha.slice(0, 8)}`);
}

if (softFailures) {
    console.error(`fetch-snapshots: ${softFailures} network-dependent snapshot(s) unavailable this run — the gates that read them will SKIP, not fail (set REQUIRE_SNAPSHOT_GATES=1 to make this a hard error instead).`);
}
if (hardFailures) {
    console.error(`fetch-snapshots: ${hardFailures} snapshot(s) failed for reasons unrelated to network availability`);
    process.exit(1);
}
