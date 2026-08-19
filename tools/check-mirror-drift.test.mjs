import assert from "node:assert/strict";
import { test } from "node:test";
import { fetchAllMirrorStatuses } from "./check-mirror-drift.mjs";

test("fetchAllMirrorStatuses issues its gh api calls concurrently", async () => {
    const calls = [];
    const fakeFetch = (repo) =>
        new Promise((resolve) => {
            calls.push({ repo, start: Date.now() });
            setTimeout(() => resolve("abc123"), 100);
        });
    const state = {
        "repo-a": { mirrorCommitSha: "abc123", publishedAt: "t" },
        "repo-b": { mirrorCommitSha: "abc123", publishedAt: "t" },
        "repo-c": { mirrorCommitSha: "abc123", publishedAt: "t" },
    };
    const start = Date.now();
    const results = await fetchAllMirrorStatuses(["repo-a", "repo-b", "repo-c"], { fetchOne: fakeFetch, state });
    const elapsed = Date.now() - start;
    assert.ok(elapsed < 250, `expected concurrent (<250ms for 3x100ms calls), got ${elapsed}ms`);
    assert.equal(calls.length, 3);
    assert.equal(results.length, 3);
    assert.ok(results.every((r) => r.status === "clean"));
});

test("a drifted repo is reported without failing the others", async () => {
    const state = {
        "repo-a": { mirrorCommitSha: "aaa", publishedAt: "t" },
        "repo-b": { mirrorCommitSha: "bbb", publishedAt: "t" },
    };
    const fakeFetch = (repo) => Promise.resolve(repo === "repo-a" ? "aaa" : "DIFFERENT");
    const results = await fetchAllMirrorStatuses(["repo-a", "repo-b"], { fetchOne: fakeFetch, state });
    assert.equal(results.find((r) => r.name === "repo-a").status, "clean");
    assert.equal(results.find((r) => r.name === "repo-b").status, "DRIFTED");
});

test("a fetch error surfaces as status error, not a thrown exception", async () => {
    const state = { "repo-a": { mirrorCommitSha: "aaa", publishedAt: "t" } };
    const fakeFetch = () => Promise.reject(new Error("gh: not authenticated"));
    const results = await fetchAllMirrorStatuses(["repo-a"], { fetchOne: fakeFetch, state });
    assert.equal(results[0].status, "error");
    assert.match(results[0].detail, /not authenticated/);
});
