#!/usr/bin/env node
// tools/check-mirror-drift.mjs — fail loud if a standalone jackhp95/<name>
// mirror repo's live HEAD has moved since this tool last published it.
//
// This is the gate that closes the gap discovered in
// docs/plans/2026-08-17-standalone-repo-realignment.md: elm-cem, elm-m3e,
// and elm-review-cem forked for ~5 days with nothing to catch it. If
// someone (human or agent) commits directly to a mirror repo again instead
// of going through tools/publish-mirror.mjs, this gate turns that from a
// silent, week-long drift into a same-run failure.
//
// Requires `gh` (GitHub CLI, authenticated) on PATH.
//
// Usage: node tools/check-mirror-drift.mjs [--json]

import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { readState } from "./publish-mirror.mjs";

const execFileAsync = promisify(execFile);

async function ghHeadSha(name) {
  const { stdout } = await execFileAsync("gh", ["api", `repos/jackhp95/${name}/commits/main`, "--jq", ".sha"]);
  return stdout.trim();
}

/**
 * Fetch every mirror's live HEAD sha concurrently (Phase 4 of the gate-all
 * parallelization plan — these were a serial `for` loop of independent `gh
 * api` calls, ~3.9s for 3 repos with nothing sequencing them). Exposed for
 * testing with a fake `fetchOne` so the concurrency claim is verifiable
 * without hitting the real network.
 */
export async function fetchAllMirrorStatuses(names, { fetchOne = ghHeadSha, state } = {}) {
  return Promise.all(
    names.map(async (name) => {
      const record = state[name];
      try {
        const liveSha = await fetchOne(name);
        const drifted = liveSha !== record.mirrorCommitSha;
        return {
          name,
          status: drifted ? "DRIFTED" : "clean",
          expected: record.mirrorCommitSha,
          live: liveSha,
          publishedAt: record.publishedAt,
        };
      } catch (err) {
        return { name, status: "error", detail: String(err.message ?? err) };
      }
    }),
  );
}

async function main() {
  const asJson = process.argv.includes("--json");
  const state = readState();
  const names = Object.keys(state);

  if (names.length === 0) {
    console.log(
      "SKIP: check-mirror-drift — no publish records in " +
        "tools/publish-mirror-state.json yet. Run tools/publish-mirror.mjs " +
        "--push for at least one repo first.",
    );
    process.exit(0);
  }

  const results = await fetchAllMirrorStatuses(names, { state });
  const anyDrift = results.some((r) => r.status !== "clean");

  if (asJson) {
    console.log(JSON.stringify(results, null, 2));
  } else {
    for (const r of results) {
      if (r.status === "clean") {
        console.log(`OK    ${r.name} — matches last publish (${r.expected.slice(0, 8)})`);
      } else if (r.status === "DRIFTED") {
        console.log(
          `DRIFT ${r.name} — expected ${r.expected.slice(0, 8)} (published ${r.publishedAt}), ` +
            `live main is at ${r.live.slice(0, 8)}. Someone/something committed directly to ` +
            `jackhp95/${r.name} outside tools/publish-mirror.mjs. Investigate before publishing again.`,
        );
      } else {
        console.log(`ERROR ${r.name} — ${r.detail}`);
      }
    }
  }

  process.exit(anyDrift ? 1 : 0);
}

main();
