// tools/install-toolchains.mjs — workspace postinstall toolchain installer.
//
// Each Elm package pins its own elm/elm-format/elm-test-rs in its
// `elm-tooling.json`, and its gates resolve those binaries from that package's
// own `node_modules/.bin`. Two packages — `elm-cem` and `elm-review-cem` —
// deliberately OMIT a `postinstall: elm-tooling install` of their own, because
// they are published to npm and must not force a ~50 MB toolchain download on
// their consumers (see packages/elm-cem/RELEASE-CHECKLIST.md). In a source
// checkout those two got their binaries from a prior standalone
// `elm-tooling install`; in a FRESH clone of this workspace they would have
// none, so `elm-cem: test` and `elm-review-cem: check`/`test` fail on a cold
// solve (they fall back to the root's — wrong — pin). See R-022 / D-034.
//
// This script runs `elm-tooling install` for the ROOT and for every package
// that ships an `elm-tooling.json`, using that location's own pinned
// `elm-tooling` binary. It is idempotent (elm-tooling just re-links) and never
// hard-fails the install: a genuinely broken toolchain is caught by the gates,
// and aborting `pnpm install` here would be worse than a warning.

import { existsSync, readdirSync, readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

// A package that ALREADY runs `elm-tooling install` in its own `postinstall`
// (IR, elm-typed-html) is installed by pnpm directly — running it a SECOND time
// from here races that install and both try to create the same
// node_modules/.bin symlink, which fails EEXIST and aborts `pnpm install`.
// Install only for packages that do NOT self-install (elm-cem, elm-review-cem);
// the root is this very postinstall, so it installs itself once here.
function selfInstalls(dir) {
    try {
        const pkg = JSON.parse(readFileSync(path.join(dir, "package.json"), "utf8"));
        return /elm-tooling\s+install/.test(pkg.scripts?.postinstall || "");
    } catch {
        return false;
    }
}

const dirs = [repoRoot];
const pkgsDir = path.join(repoRoot, "packages");
if (existsSync(pkgsDir)) {
    for (const name of readdirSync(pkgsDir)) {
        const dir = path.join(pkgsDir, name);
        if (existsSync(path.join(dir, "elm-tooling.json")) && !selfInstalls(dir)) dirs.push(dir);
    }
}

function elmToolingBin(dir) {
    // Prefer the location's own pinned elm-tooling, then the root's.
    const local = path.join(dir, "node_modules", ".bin", "elm-tooling");
    if (existsSync(local)) return local;
    const root = path.join(repoRoot, "node_modules", ".bin", "elm-tooling");
    if (existsSync(root)) return root;
    return null;
}

let failures = 0;
for (const dir of dirs) {
    const bin = elmToolingBin(dir);
    const rel = path.relative(repoRoot, dir) || ".";
    if (!bin) {
        console.warn(`install-toolchains: no elm-tooling binary resolvable for ${rel}; skipping`);
        continue;
    }
    const res = spawnSync(bin, ["install"], { cwd: dir, stdio: "inherit" });
    if (res.status !== 0) {
        failures++;
        console.warn(`install-toolchains: elm-tooling install FAILED in ${rel} (exit ${res.status ?? res.signal})`);
    }
}

if (failures > 0) {
    console.warn(`install-toolchains: ${failures} package(s) did not install their toolchain; gates will surface any real breakage.`);
}
// Exit 0 regardless — do not abort `pnpm install` on a toolchain hiccup.
