import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { test } from "node:test";
import { isolatedElmHome } from "./elm-home-isolation.mjs";

test("isolatedElmHome seeds a scratch dir whose content matches the real one", () => {
    const fakeRealElmHome = fs.mkdtempSync(path.join(os.tmpdir(), "fake-elm-home-"));
    fs.mkdirSync(path.join(fakeRealElmHome, "0.19.1", "packages", "elm", "core"), { recursive: true });
    const marker = path.join(fakeRealElmHome, "0.19.1", "packages", "elm", "core", "marker.txt");
    fs.writeFileSync(marker, "hello");

    const scratch = isolatedElmHome("test-step", { realElmHome: fakeRealElmHome });
    const seeded = path.join(scratch, "0.19.1", "packages", "elm", "core", "marker.txt");
    assert.ok(fs.existsSync(seeded), "expected seeded file to exist in scratch ELM_HOME");
    assert.equal(fs.readFileSync(seeded, "utf8"), "hello");

    fs.rmSync(fakeRealElmHome, { recursive: true, force: true });
    fs.rmSync(scratch, { recursive: true, force: true });
});

test("a write into the scratch ELM_HOME never mutates the real one (hardlink replace semantics)", () => {
    const fakeRealElmHome = fs.mkdtempSync(path.join(os.tmpdir(), "fake-elm-home-"));
    const pkgDir = path.join(fakeRealElmHome, "0.19.1", "packages", "jackhp95", "elm-cem-facts");
    fs.mkdirSync(pkgDir, { recursive: true });
    const facts = path.join(pkgDir, "facts.json");
    fs.writeFileSync(facts, "real");

    const scratch = isolatedElmHome("writer-step", { realElmHome: fakeRealElmHome });
    const scratchFacts = path.join(scratch, "0.19.1", "packages", "jackhp95", "elm-cem-facts", "facts.json");

    // Simulate stage-facts-elm-home.mjs's behavior: unlink + rewrite (the
    // standard safe-write pattern), which is what actually breaks the
    // hardlink rather than mutating the shared inode.
    fs.rmSync(scratchFacts);
    fs.writeFileSync(scratchFacts, "staged-by-this-step");

    assert.equal(fs.readFileSync(facts, "utf8"), "real", "the real ELM_HOME's file must be untouched");
    assert.equal(fs.readFileSync(scratchFacts, "utf8"), "staged-by-this-step");

    fs.rmSync(fakeRealElmHome, { recursive: true, force: true });
    fs.rmSync(scratch, { recursive: true, force: true });
});
