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

import { execFileSync } from "node:child_process";
import { readState } from "./publish-mirror.mjs";

function ghHeadSha(name) {
  const out = execFileSync(
    "gh",
    ["api", `repos/jackhp95/${name}/commits/main`, "--jq", ".sha"],
    { encoding: "utf8" },
  );
  return out.trim();
}

function main() {
  const asJson = process.argv.includes("--json");
  const state = readState();
  const names = Object.keys(state);

  if (names.length === 0) {
    console.log(
      "No publish records in tools/publish-mirror-state.json yet — nothing to " +
        "check. Run tools/publish-mirror.mjs --push for at least one repo first.",
    );
    process.exit(0);
  }

  const results = [];
  let anyDrift = false;

  for (const name of names) {
    const record = state[name];
    let liveSha;
    try {
      liveSha = ghHeadSha(name);
    } catch (err) {
      results.push({ name, status: "error", detail: String(err.message ?? err) });
      anyDrift = true;
      continue;
    }
    const drifted = liveSha !== record.mirrorCommitSha;
    if (drifted) anyDrift = true;
    results.push({
      name,
      status: drifted ? "DRIFTED" : "clean",
      expected: record.mirrorCommitSha,
      live: liveSha,
      publishedAt: record.publishedAt,
    });
  }

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
