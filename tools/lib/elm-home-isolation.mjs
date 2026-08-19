// tools/lib/elm-home-isolation.mjs — per-step scratch ELM_HOME so concurrent
// Elm-toolchain invocations (elm, elm-review, elm-test-rs) under the
// gate-scheduler pool never share a mutable package cache.
//
// Constraint this closes (spec §2 constraint 3): Elm 0.19 resolves packages
// out of a single global ELM_HOME by default; elm-review-cem's
// stage-facts-elm-home.mjs writes into
// ~/.elm/0.19.1/packages/jackhp95/elm-cem-facts/, a location every other
// concurrent elm/elm-review/elm-test-rs invocation reads from. Once the
// scheduler runs more than one Elm-toolchain step at a time, that write is an
// unverified race unless each step gets its own copy.
//
// Each scratch ELM_HOME is seeded via HARDLINKS (cp -al semantics), not a
// real copy, from the real ~/.elm — so isolation costs disk/time
// proportional to directory-tree size, not package-bytes size, and a step's
// own writes (which replace a hardlinked file rather than mutating it
// in-place) land only in its own scratch copy, never back in the shared
// real one.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

/**
 * Produce a per-step scratch ELM_HOME, seeded from the real one via
 * hardlinks (or, on macOS/APFS, copy-on-write clones — faster still, same
 * "no shared mutable inode" guarantee) so concurrent steps don't share a
 * mutable package cache but also don't pay to recopy or recompile ~/.elm's
 * contents. Measured on the real ~/.elm (232M, 3545 files): `cp -Rc`
 * (macOS clonefile) seeds in <1s vs. ~1.4s for the pure-JS hardlink walk
 * below, and both are far cheaper than a real copy or a from-scratch
 * `elm-test-rs`/`elm-review` package download.
 *
 * @param {string} stepName - used only to make the scratch dir name legible for debugging
 * @param {{realElmHome?: string}} [opts]
 * @returns {string} path to the seeded scratch ELM_HOME
 */
export function isolatedElmHome(stepName, { realElmHome = path.join(os.homedir(), ".elm") } = {}) {
    const slug = stepName.replace(/[^a-z0-9]+/gi, "-").toLowerCase();
    const parent = fs.mkdtempSync(path.join(os.tmpdir(), `gate-all-elm-home-${slug}-`));
    // `scratch` itself must NOT exist yet when we shell out to `cp`: BSD/GNU
    // cp both copy SRC's *contents* into DEST when DEST doesn't exist, but
    // nest SRC *inside* DEST (as DEST/basename(SRC)) when DEST already
    // exists — so we reserve a unique parent dir above and let cp create
    // the leaf itself.
    const scratch = path.join(parent, "elm-home");
    if (!fs.existsSync(realElmHome)) {
        fs.mkdirSync(scratch, { recursive: true });
        return scratch;
    }

    if (process.platform === "darwin") {
        try {
            // -R recursive, -c clonefile (APFS copy-on-write: instant,
            // metadata-only, writes to the clone never touch the source).
            execFileSync("cp", ["-Rc", realElmHome, scratch], { stdio: "pipe" });
            return scratch;
        } catch {
            // Fall through to the portable hardlink walk below (e.g. cp
            // lacks -c support, or scratch isn't on an APFS volume).
            fs.rmSync(scratch, { recursive: true, force: true });
        }
    }
    fs.mkdirSync(scratch, { recursive: true });
    hardlinkTree(realElmHome, scratch);
    return scratch;
}

function hardlinkTree(src, dest) {
    for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
        const s = path.join(src, entry.name);
        const d = path.join(dest, entry.name);
        if (entry.isDirectory()) {
            fs.mkdirSync(d, { recursive: true });
            hardlinkTree(s, d);
        } else if (entry.isFile()) {
            try {
                fs.linkSync(s, d);
            } catch (e) {
                // Cross-device or otherwise unlinkable (rare under a single
                // homedir filesystem) — fall back to a real copy rather than
                // losing the file from the scratch tree.
                if (e.code === "EXDEV") fs.copyFileSync(s, d);
                else throw e;
            }
        }
        // symlinks: skip — none expected under ~/.elm's package cache structure.
    }
}
