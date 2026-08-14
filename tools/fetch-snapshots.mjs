// tools/fetch-snapshots.mjs — materialize the pinned upstream snapshots the A/B +
// copy-fidelity gates compare against, into .cache/snapshots/<name> (gitignored).
// Idempotent: a checkout already at the pinned SHA is left alone. See D-041.
import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const refs = JSON.parse(readFileSync(path.join(repoRoot, "tools", "snapshot-refs.json"), "utf8"));
const cacheRoot = path.join(repoRoot, ".cache", "snapshots");
mkdirSync(cacheRoot, { recursive: true });

const git = (args, cwd) => spawnSync("git", args, { cwd, encoding: "utf8" });
let failures = 0;
for (const [name, { repo, sha }] of Object.entries(refs)) {
    if (name.startsWith("_")) continue;
    const dir = path.join(cacheRoot, name);
    const at = existsSync(dir) ? (git(["rev-parse", "HEAD"], dir).stdout || "").trim() : "";
    if (at === sha) { console.log(`fetch-snapshots: ${name} already at ${sha.slice(0, 8)}`); continue; }
    console.log(`fetch-snapshots: materializing ${name}@${sha.slice(0, 8)} ...`);
    if (!existsSync(dir)) {
        // Prefer a local mirror if the same repo is cloned nearby (fast, offline); else the remote.
        const local = path.join("/tmp/latest", `${name}-full`);
        const src = existsSync(path.join(local, ".git")) ? local : repo;
        if (git(["clone", "--quiet", src, dir]).status !== 0) { console.error(`  clone failed (${src})`); failures++; continue; }
        if (src !== repo) git(["remote", "set-url", "origin", repo], dir);
    }
    if (git(["fetch", "--quiet", "origin", sha], dir).status !== 0) git(["fetch", "--quiet", "origin"], dir);
    if (git(["checkout", "--quiet", sha], dir).status !== 0) { console.error(`  checkout ${sha} failed`); failures++; continue; }
    console.log(`  ok: ${name} at ${sha.slice(0, 8)}`);
}
if (failures) { console.error(`fetch-snapshots: ${failures} snapshot(s) failed`); process.exit(1); }
