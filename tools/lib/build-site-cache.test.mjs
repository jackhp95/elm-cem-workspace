import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";
import { cachedBuildSite } from "./build-site-cache.mjs";

test("cache miss runs the build command and populates the cache", () => {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "build-site-cache-"));
    const inputFile = path.join(tmp, "input.txt");
    fs.writeFileSync(inputFile, "v1");
    const distDir = path.join(tmp, "dist");
    const cacheDir = path.join(tmp, "cache");
    let buildRuns = 0;

    const result = cachedBuildSite({
        inputs: [inputFile],
        buildCommand: () => {
            buildRuns++;
            fs.mkdirSync(distDir, { recursive: true });
            fs.writeFileSync(path.join(distDir, "out.txt"), "built");
        },
        distDir,
        cacheDir,
    });

    assert.equal(buildRuns, 1);
    assert.equal(result.cacheHit, false);
    assert.ok(fs.existsSync(path.join(distDir, "out.txt")));
});

test("cache hit restores dist without re-running the build command", () => {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "build-site-cache-"));
    const inputFile = path.join(tmp, "input.txt");
    fs.writeFileSync(inputFile, "v1");
    const distDir = path.join(tmp, "dist");
    const cacheDir = path.join(tmp, "cache");
    let buildRuns = 0;
    const build = () => {
        buildRuns++;
        fs.mkdirSync(distDir, { recursive: true });
        fs.writeFileSync(path.join(distDir, "out.txt"), "built");
    };

    cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });
    fs.rmSync(distDir, { recursive: true, force: true }); // simulate a fresh checkout

    const result = cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });

    assert.equal(buildRuns, 1, "second call should hit cache, not re-invoke buildCommand");
    assert.equal(result.cacheHit, true);
    assert.ok(fs.existsSync(path.join(distDir, "out.txt")), "dist must be restored from cache");
});

test("changing an input file forces a cache miss — never a false green", () => {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "build-site-cache-"));
    const inputFile = path.join(tmp, "input.txt");
    fs.writeFileSync(inputFile, "v1");
    const distDir = path.join(tmp, "dist");
    const cacheDir = path.join(tmp, "cache");
    let buildRuns = 0;
    const build = () => {
        buildRuns++;
        fs.mkdirSync(distDir, { recursive: true });
        fs.writeFileSync(path.join(distDir, "out.txt"), `built-${buildRuns}`);
    };

    cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });
    fs.writeFileSync(inputFile, "v2"); // input changed
    const result = cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });

    assert.equal(buildRuns, 2, "changed input must force a rebuild, never trust a stale hash");
    assert.equal(result.cacheHit, false);
    assert.equal(fs.readFileSync(path.join(distDir, "out.txt"), "utf8"), "built-2");
});

test("removing a listed input file changes the hash instead of being silently ignored", () => {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "build-site-cache-"));
    const inputFile = path.join(tmp, "input.txt");
    fs.writeFileSync(inputFile, "v1");
    const distDir = path.join(tmp, "dist");
    const cacheDir = path.join(tmp, "cache");
    let buildRuns = 0;
    const build = () => {
        buildRuns++;
        fs.mkdirSync(distDir, { recursive: true });
        fs.writeFileSync(path.join(distDir, "out.txt"), `built-${buildRuns}`);
    };

    cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });
    fs.rmSync(inputFile);
    const result = cachedBuildSite({ inputs: [inputFile], buildCommand: build, distDir, cacheDir });

    assert.equal(buildRuns, 2, "a missing input must not be treated as unchanged");
    assert.equal(result.cacheHit, false);
});
