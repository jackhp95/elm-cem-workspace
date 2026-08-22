#!/usr/bin/env node
// check-svg-spec-coverage.test.mjs — the honesty proof for the SVG coverage gate.
//
// A coverage gate that can't go red proves nothing. This is the mutation test:
//   1. GREEN on the real, untouched spec-index + coverage-map.
//   2. RED when a fake spec element is injected with NO exception (the gate
//      must catch a genuinely un-accounted-for gap).
//   3. GREEN again once that same fake element is given an exception (proving
//      the exception path is what turned it green — not that the gate is inert).
//   4. RED when a STALE exception is added for an element the package actually
//      models (the reverse-direction honesty: a dishonest ledger fails too).
//
// All mutations happen on SCRATCH COPIES pointed at via env (SVG_SPEC_INDEX /
// SVG_COVERAGE_MAP); the real docs/svg-audit/*.json are never touched.

import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const GATE = path.join(repoRoot, "tools", "check-svg-spec-coverage.mjs");
const SPEC = path.join(repoRoot, "docs", "svg-audit", "spec-index.json");
const MAP = path.join(repoRoot, "docs", "svg-audit", "coverage-map.json");

/** Run the gate, optionally with scratch spec / map overrides. Returns {code, out}. */
function runGate({ spec, map } = {}) {
    const env = { ...process.env };
    if (spec) env.SVG_SPEC_INDEX = spec;
    if (map) env.SVG_COVERAGE_MAP = map;
    try {
        const out = execFileSync(process.execPath, [GATE], { env, encoding: "utf8", stdio: "pipe" });
        return { code: 0, out };
    } catch (err) {
        return { code: err.status ?? 1, out: `${err.stdout ?? ""}${err.stderr ?? ""}` };
    }
}

function scratch(prefix) {
    return fs.mkdtempSync(path.join(os.tmpdir(), prefix));
}

test("GREEN on the real committed spec-index + coverage-map", () => {
    const { code, out } = runGate();
    assert.equal(code, 0, `expected green, got exit ${code}\n${out}`);
    assert.match(out, /check-svg-spec-coverage: OK/);
});

test("RED when a fake spec element has no exception", () => {
    const dir = scratch("svg-cov-fake-el-");
    const specPath = path.join(dir, "spec-index.json");
    const spec = JSON.parse(fs.readFileSync(SPEC, "utf8"));
    spec.elements.push({
        name: "fakeGizmo",
        family: "static-render",
        specHref: "test-only#fakeGizmo",
        inMdnReference: false,
    });
    fs.writeFileSync(specPath, JSON.stringify(spec));

    const { code, out } = runGate({ spec: specPath });
    assert.equal(code, 1, `expected RED, got exit ${code}\n${out}`);
    assert.match(out, /UN-ACCOUNTED spec element "fakeGizmo"/);
    fs.rmSync(dir, { recursive: true, force: true });
});

test("GREEN again once that fake element gets an exception", () => {
    const dir = scratch("svg-cov-fake-el-ok-");
    const specPath = path.join(dir, "spec-index.json");
    const mapPath = path.join(dir, "coverage-map.json");

    const spec = JSON.parse(fs.readFileSync(SPEC, "utf8"));
    spec.elements.push({
        name: "fakeGizmo",
        family: "smil-animation",
        specHref: "test-only#fakeGizmo",
        inMdnReference: false,
    });
    fs.writeFileSync(specPath, JSON.stringify(spec));

    const map = JSON.parse(fs.readFileSync(MAP, "utf8"));
    map.exceptions.push({
        kind: "element",
        name: "fakeGizmo",
        reason: "smil-deferred",
        note: "Injected by the mutation test to prove the exception path turns the gate green.",
    });
    fs.writeFileSync(mapPath, JSON.stringify(map));

    const { code, out } = runGate({ spec: specPath, map: mapPath });
    assert.equal(code, 0, `expected GREEN with exception, got exit ${code}\n${out}`);
    assert.match(out, /check-svg-spec-coverage: OK/);
    fs.rmSync(dir, { recursive: true, force: true });
});

test("RED when a stale exception names an element the package models", () => {
    const dir = scratch("svg-cov-stale-");
    const mapPath = path.join(dir, "coverage-map.json");
    const map = JSON.parse(fs.readFileSync(MAP, "utf8"));
    // `circle` is unambiguously modeled — an exception for it is dishonest.
    map.exceptions.push({
        kind: "element",
        name: "circle",
        reason: "smil-deferred",
        note: "Dishonest exception injected by the mutation test — circle is modeled.",
    });
    fs.writeFileSync(mapPath, JSON.stringify(map));

    const { code, out } = runGate({ map: mapPath });
    assert.equal(code, 1, `expected RED for stale exception, got exit ${code}\n${out}`);
    assert.match(out, /element "circle" IS modeled/);
    fs.rmSync(dir, { recursive: true, force: true });
});
