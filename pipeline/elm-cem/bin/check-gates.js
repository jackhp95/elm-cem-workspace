// elm-cem check-gates — asserts that no check can be silently switched off.
//
// Why this exists: `check` was once `run-p "check:!(review)"`, which excluded
// elm-review from every gate. A commit then destroyed `review/src/ReviewConfig.elm`
// — removing every import and the `config` definition — and `npm run gate` still
// reported exit 0, because the config was never compiled. Fifteen real errors,
// including an accessibility defect in a live docs sample, sat invisible behind a
// green gate.
//
// A gate that can quietly drop one of its checks is worse than no gate: it produces
// confident false assurance. This script makes every omission declare itself.
//
// None of the above matters unless something actually RUNS this script on every
// push — and that enforcement lives entirely in hooks/pre-push, wired in only via
// `core.hooksPath` (see package.json `hooks:install` / `postinstall`). If
// postinstall never ran, or the config was later unset, every rule below still
// reports OK on every commit, because nothing ever asks the question. Rule 4 makes
// that silence loud too.
//
// Rules enforced:
//   1. Every `check:*` / `test:*` script must be reachable from `gate`.
//   2. No `run-p`/`run-s` pattern may use a `!(…)` glob exclusion.
//   3. No gate-reachable command may pass a `--skip-*` flag.
//   4. `core.hooksPath` must point at this repo's own hooks/ directory, so
//      rules 1–3 are actually enforced by `git push`.
//
// Any of these may be waived, but only by an entry in gate-waivers.json carrying a
// reason — so the omission is greppable, reviewable, and survives in git history.

"use strict";

const { readFileSync, existsSync, realpathSync } = require("node:fs");
const { join, isAbsolute, resolve } = require("node:path");
const { spawnSync } = require("node:child_process");

// Run from the brand repo root, like every other elm-cem gate subcommand.
function run() {
  const root = process.cwd();
const pkg = JSON.parse(readFileSync(join(root, "package.json"), "utf8"));
const scripts = pkg.scripts ?? {};

const waiverPath = join(root, "gate-waivers.json");
const waivers = existsSync(waiverPath)
  ? JSON.parse(readFileSync(waiverPath, "utf8"))
  : {};

const problems = [];
const waived = [];

/** Script names a `run-p`/`run-s` invocation expands to. */
function expand(command) {
  const out = new Set();
  for (const raw of command.match(/"[^"]+"|\S+/g) ?? []) {
    const pat = raw.replace(/^"|"$/g, "");
    if (!/^[a-z]/i.test(pat)) continue; // flags, not patterns
    if (pat.includes("!(")) continue; // exclusions handled separately
    if (pat.includes("*")) {
      const re = new RegExp("^" + pat.replace(/[.+?^${}()|[\]\\]/g, "\\$&").replace(/\*/g, ".*") + "$");
      for (const name of Object.keys(scripts)) if (re.test(name)) out.add(name);
    } else if (scripts[pat]) {
      out.add(pat);
    }
  }
  return out;
}

/** Everything `gate` transitively runs. */
function reachable(entry) {
  const seen = new Set();
  const walk = (name) => {
    if (seen.has(name) || !scripts[name]) return;
    seen.add(name);
    const cmd = scripts[name];
    if (/\brun-[ps]\b/.test(cmd)) for (const child of expand(cmd)) walk(child);
    // `gate` is often a plain `npm run check` rather than a run-p/run-s fan-out.
    // Follow those too, or every check looks unreachable. Only same-package runs:
    // `npm --prefix <dir> run X` targets a DIFFERENT package.json, whose scripts
    // are not ours to reason about.
    for (const m of cmd.matchAll(/\bnpm(?!\s+--prefix)\s+run\s+([\w:@.-]+)/g)) walk(m[1]);
  };
  walk(entry);
  return seen;
}

function check(id, message) {
  if (waivers[id]) {
    if (!String(waivers[id]).trim()) problems.push(`${id} — waiver present but has no reason`);
    else waived.push(`${id} — waived: ${waivers[id]}`);
    return;
  }
  problems.push(message);
}

if (!scripts.gate) {
  problems.push("no `gate` script — nothing to verify");
} else {
  const run = reachable("gate");

  // 1. every check:*/test:* is actually reached
  for (const name of Object.keys(scripts)) {
    if (!/^(check|test):/.test(name)) continue;
    if (run.has(name)) continue;
    check(name, `\`${name}\` is never run by \`gate\` — it is defined but unreachable`);
  }

  // 2. no glob exclusions
  for (const [name, cmd] of Object.entries(scripts)) {
    if (!/\brun-[ps]\b/.test(cmd) || !cmd.includes("!(")) continue;
    const excluded = cmd.match(/!\(([^)]*)\)/)?.[1] ?? "?";
    check(
      `${name}#exclusion`,
      `\`${name}\` uses a glob exclusion \`!(${excluded})\` — the excluded check silently never runs`
    );
  }

  // 3. no --skip-* inside anything the gate runs
  for (const name of run) {
    const skip = scripts[name]?.match(/--skip-[a-z-]+/g);
    if (!skip) continue;
    check(`${name}#${skip[0]}`, `\`${name}\` passes \`${skip.join(" ")}\` — that stage never runs in the gate`);
  }
}

// 4. core.hooksPath must resolve to this repo's own hooks/ directory, or none of
// the rules above are ever run by `git push` in the first place (hooks/pre-push
// is what actually invokes the gate). No hooks/ dir → nothing to install → this
// rule does not fire. Not a git repo, or git unavailable → also does not fire;
// check-gates must never crash or hang, so every git call here is a checked
// spawnSync, never an execSync that can throw uncaught.
const hooksDir = join(root, "hooks");
if (existsSync(hooksDir)) {
  const real = (p) => {
    try {
      return realpathSync(p);
    } catch {
      // A configured path that doesn't exist can't be realpath'd; fall back to a
      // resolved-but-unverified path so the comparison below still degrades to a
      // (correct) mismatch instead of throwing.
      return resolve(p);
    }
  };
  const top = spawnSync("git", ["rev-parse", "--show-toplevel"], { cwd: root, encoding: "utf8" });
  if (!top.error && top.status === 0) {
    const expected = real(hooksDir);
    const cfg = spawnSync("git", ["config", "core.hooksPath"], { cwd: root, encoding: "utf8" });
    if (!cfg.error) {
      const value = cfg.stdout.trim();
      if (cfg.status !== 0 || !value) {
        check(
          "hooks#core.hooksPath",
          "core.hooksPath is not set — the gate above is not enforced by `git push` at all " +
            "(hooks/pre-push never runs). Fix with `npm run hooks:install` (`git config core.hooksPath hooks`)."
        );
      } else {
        // Git resolves a RELATIVE core.hooksPath against the top level of the
        // working tree — in a worktree that is the WORKTREE's own root, so the
        // conventional value `hooks` needs no special-casing here to be correct.
        const configured = real(isAbsolute(value) ? value : join(top.stdout.trim(), value));
        if (configured !== expected) {
          check(
            "hooks#core.hooksPath",
            `core.hooksPath is \`${value}\` (resolves to ${configured}), not this repo's hooks/ ` +
              `directory (${expected}) — the gate above is not enforced by \`git push\`. Fix with ` +
              "`npm run hooks:install`."
          );
        }
      }
    }
  }
}

for (const w of waived) console.log(`check-gates: ${w}`);

if (problems.length) {
  console.error("check-gates: FAIL — a gate can silently skip work:\n");
  for (const p of problems) console.error(`  - ${p}`);
  console.error(
    "\nEither wire the check into `gate`, or add an entry to gate-waivers.json\n" +
      "keyed by the id above with a reason string explaining why it is safe to skip."
  );
  process.exit(1);
}

console.log(
  `check-gates: OK — every check:*/test:* is reachable from \`gate\`, none can be silently ` +
    `skipped, and the gate is wired to actually run (core.hooksPath)` +
    (waived.length ? `, ${waived.length} declared waiver(s)` : "") +
    "."
);
}

module.exports = { run };

// Direct invocation must do the same work as `elm-cem <subcommand>`. Without this
// guard the file loads, exports `run`, calls nothing, prints nothing and exits 0 —
// a gate reporting success without doing its work, which is precisely the failure
// these scripts exist to prevent. It nearly banked a false "verified" once: an
// agent checking elm-review-cem's neutrality gate ran this file directly, got a
// clean exit 0, and only doubted it because an expected log line never printed.
if (require.main === module) run(process.argv.slice(2));
