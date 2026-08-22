#!/usr/bin/env node
// check-svg-spec-coverage.mjs — the permanent SVG API-vs-spec coverage gate.
//
// It diffs the machine-readable SVG-2 spec vocabulary
// (docs/svg-audit/spec-index.json) against what the elm-typed-svg package
// ACTUALLY generates right now (extracted live by
// tools/lib/svg-modeled-extract.mjs from the committed manifest + config +
// Values.elm), on the two mechanically-diffable axes the audit tracks:
//
//   1. ELEMENTS               — every spec element must be modeled OR excepted.
//   2. PRESENTATION PROPERTIES — every spec presentation / filter-presentation
//      property must be modeled (as a config `_global` OR a per-element
//      manifest attribute) OR excepted.
//
// A gap is allowed only if docs/svg-audit/coverage-map.json carries an explicit
// `exception` for it with a reason drawn from the map's own `buckets`. This is
// the same mapped/exception contract tools/check-coverage-map.mjs uses for the
// facts-bundle. And, mirroring it, the gate is HONEST about what green means:
// it proves the coverage map and the spec index agree with each other and with
// the generated package — that every un-modeled spec entry is *accounted for*
// and every accounted-for entry is *real*. It does NOT prove a modeled
// attribute is semantically correct or that a deferral is wise; that stays
// reviewer judgment (audit report §2.3).
//
// It bites in BOTH directions:
//   - an un-modeled spec element/property with no exception  -> RED (a real gap
//     opened by a spec-index bump or a package regression);
//   - a stale exception whose target is now modeled, or names no real
//     spec-index entry                                       -> RED (dishonest
//     ledger — the drift protection html never had).
//
// It also re-derives docs/svg-audit/modeled-index.json fresh and fails if the
// committed snapshot has drifted from the live package, so that artifact can
// never silently rot.
//
// Zero dependencies. Exits 0 on success, 1 on any failure.

import { readFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { extractModeled } from "./lib/svg-modeled-extract.mjs";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));
// Paths default to the committed artifacts but may be overridden by env so the
// mutation test (tools/check-svg-spec-coverage.test.mjs) can point the gate at
// a scratch spec-index / coverage-map without ever mutating the real files.
const SPEC_PATH = process.env.SVG_SPEC_INDEX || join(repoRoot, "docs", "svg-audit", "spec-index.json");
const MAP_PATH = process.env.SVG_COVERAGE_MAP || join(repoRoot, "docs", "svg-audit", "coverage-map.json");
const MODELED_INDEX_PATH = join(repoRoot, "docs", "svg-audit", "modeled-index.json");

const VALID_EXCEPTION_KINDS = ["element", "presentation", "attribute", "documentary"];

const errors = [];
const fail = (msg) => errors.push(msg);

function readJson(path, label) {
    let raw;
    try {
        raw = readFileSync(path, "utf8");
    } catch (err) {
        fail(`${label} is missing or unreadable at ${relative(repoRoot, path)}: ${err.message}`);
        return null;
    }
    try {
        return JSON.parse(raw);
    } catch (err) {
        fail(`${label} is not valid JSON (${relative(repoRoot, path)}): ${err.message}`);
        return null;
    }
}

const spec = readJson(SPEC_PATH, "spec-index.json");
const map = readJson(MAP_PATH, "coverage-map.json");

if (errors.length) report();

// ── modeled set (live) ─────────────────────────────────────────────────────
let modeled;
try {
    modeled = extractModeled(repoRoot);
} catch (err) {
    fail(`could not extract the modeled set from the package: ${err.message}`);
    report();
}

const modeledElements = new Set(modeled.elements);
const modeledAttrs = new Set(modeled.modeledAttributeNames);

// A presentation property counts as modeled if it is a config `_global` OR a
// per-element manifest attribute (e.g. stop-color/stop-opacity live on <stop>).
const isPresentationModeled = (name) => modeledAttrs.has(name);

// ── spec shape ─────────────────────────────────────────────────────────────
if (spec) {
    if (!Array.isArray(spec.elements) || spec.elements.length === 0) {
        fail("spec-index.json: `elements` is missing or empty");
    }
    if (!Array.isArray(spec.attributes) || spec.attributes.length === 0) {
        fail("spec-index.json: `attributes` is missing or empty");
    }
}
const specElements = Array.isArray(spec?.elements) ? spec.elements : [];
const specAttributes = Array.isArray(spec?.attributes) ? spec.attributes : [];
const specElementNames = new Set(specElements.map((e) => e.name));
const specAttrNames = new Set(specAttributes.map((a) => a.name));
const specPresentation = specAttributes.filter(
    (a) => a.family === "presentation" || a.family === "filter-presentation",
);
const specPresentationNames = new Set(specPresentation.map((a) => a.name));

// ── coverage-map shape ─────────────────────────────────────────────────────
let buckets = {};
let exceptions = [];
if (map) {
    if (typeof map !== "object" || Array.isArray(map)) {
        fail("coverage-map.json: top level must be an object");
    } else {
        if (!map.buckets || typeof map.buckets !== "object" || Array.isArray(map.buckets)) {
            fail("coverage-map.json: `buckets` must be an object mapping bucket-name -> description");
        } else {
            buckets = map.buckets;
            for (const [name, desc] of Object.entries(buckets)) {
                if (typeof desc !== "string" || desc.trim().length < 20) {
                    fail(`coverage-map.json: bucket "${name}" needs a substantive description (>= 20 chars)`);
                }
            }
        }
        if (!Array.isArray(map.exceptions)) {
            fail("coverage-map.json: `exceptions` is missing or not an array");
        } else {
            exceptions = map.exceptions;
        }
    }
}

// Index the exceptions by kind for the diff below; validate each as we go.
const exceptedElements = new Set();
const exceptedPresentation = new Set();
const exceptedAttributes = new Set();
const seen = new Set();

exceptions.forEach((ex, i) => {
    const where = `coverage-map.json exceptions[${i}]`;
    if (typeof ex !== "object" || ex === null || Array.isArray(ex)) {
        fail(`${where}: entry must be an object`);
        return;
    }
    const label = `${where} (${ex.kind ?? "?"} "${ex.name ?? "?"}")`;

    if (!VALID_EXCEPTION_KINDS.includes(ex.kind)) {
        fail(`${label}: \`kind\` must be one of ${VALID_EXCEPTION_KINDS.join(", ")} — got ${JSON.stringify(ex.kind)}`);
    }
    if (typeof ex.name !== "string" || ex.name.trim() === "") {
        fail(`${label}: \`name\` must be a non-empty string`);
        return;
    }
    if (typeof ex.reason !== "string" || !(ex.reason in buckets)) {
        fail(
            `${label}: \`reason\` "${ex.reason}" is not one of the declared buckets ` +
                `(${Object.keys(buckets).join(", ") || "none"})`,
        );
    }
    if (typeof ex.note !== "string" || ex.note.trim().length < 20) {
        fail(`${label}: needs a substantive \`note\` (>= 20 chars) justifying the deferral/non-goal`);
    }

    const dupKey = `${ex.kind}:${ex.name}`;
    if (seen.has(dupKey)) fail(`${label}: duplicate exception for ${dupKey}`);
    seen.add(dupKey);

    // Kind-specific target validation: an exception must point at something
    // REAL and — for the diff axes — genuinely un-modeled, or it is a stale/
    // dishonest ledger entry.
    if (ex.kind === "element") {
        if (!specElementNames.has(ex.name)) {
            fail(`${label}: names no element in spec-index.json — stale or misspelled exception`);
        } else if (modeledElements.has(ex.name)) {
            fail(`${label}: element "${ex.name}" IS modeled by the package — remove this stale exception`);
        }
        exceptedElements.add(ex.name);
    } else if (ex.kind === "presentation") {
        if (!specPresentationNames.has(ex.name)) {
            fail(`${label}: names no presentation property in spec-index.json — stale or misspelled exception`);
        } else if (isPresentationModeled(ex.name)) {
            fail(`${label}: presentation property "${ex.name}" IS modeled — remove this stale exception`);
        }
        exceptedPresentation.add(ex.name);
    } else if (ex.kind === "attribute") {
        // A named, non-presentation attribute deferral/non-goal (xlink:*,
        // zoomAndPan, …). Must be a real spec-index attribute and not modeled.
        if (!specAttrNames.has(ex.name)) {
            fail(`${label}: names no attribute in spec-index.json — stale or misspelled exception`);
        } else if (modeledAttrs.has(ex.name)) {
            fail(`${label}: attribute "${ex.name}" IS modeled — remove this stale exception`);
        }
        exceptedAttributes.add(ex.name);
    }
    // `documentary` entries (value-grammar non-goals like the path-data DSL,
    // or SVG-1.1-legacy names absent from the SVG-2 index like
    // requiredFeatures) intentionally do NOT have to resolve to an un-modeled
    // spec-index entry — they record a decision about a grammar or a
    // dropped name, and are validated only for bucket + note above.
});

// ── the two diff axes ──────────────────────────────────────────────────────
// Axis 1: elements.
const unaccountedElements = specElements
    .map((e) => e.name)
    .filter((name) => !modeledElements.has(name) && !exceptedElements.has(name));
for (const name of unaccountedElements) {
    const el = specElements.find((e) => e.name === name);
    fail(
        `UN-ACCOUNTED spec element "${name}" [${el?.family ?? "?"}] — neither modeled nor excepted. ` +
            `Model it, or add an exception to coverage-map.json.`,
    );
}

// Axis 2: presentation properties.
const unaccountedPresentation = specPresentation
    .map((a) => a.name)
    .filter((name) => !isPresentationModeled(name) && !exceptedPresentation.has(name));
for (const name of unaccountedPresentation) {
    fail(
        `UN-ACCOUNTED spec presentation property "${name}" — neither modeled (global or per-element) ` +
            `nor excepted. Model it, or add an exception to coverage-map.json.`,
    );
}

// ── modeled-index snapshot freshness ───────────────────────────────────────
// The committed docs/svg-audit/modeled-index.json must reflect the live
// package, so it can never silently rot. Compare the fields the audit relies
// on (element list + counts) against a fresh extraction.
const committedIndex = readJson(MODELED_INDEX_PATH, "modeled-index.json");
if (committedIndex) {
    const liveElements = modeled.elements;
    const committedElements = Array.isArray(committedIndex.elements) ? [...committedIndex.elements].sort() : [];
    if (JSON.stringify(liveElements) !== JSON.stringify(committedElements)) {
        fail(
            `modeled-index.json element list is STALE vs the live package ` +
                `(committed ${committedElements.length}, live ${liveElements.length}). ` +
                `Regenerate it: node tools/gen-svg-modeled-index.mjs`,
        );
    }
    const liveCounts = {
        elements: modeled.elements.length,
        globalAttributes: modeled.globals.length,
        typedGlobalEnums: modeled.globals.filter((g) => g.typed).length,
        valuesEnumTypes: modeled.valuesEnumTypes.length,
    };
    const c = committedIndex.counts || {};
    for (const [k, v] of Object.entries(liveCounts)) {
        if (typeof c[k] === "number" && c[k] !== v) {
            fail(`modeled-index.json counts.${k} is STALE (committed ${c[k]}, live ${v}). Regenerate it.`);
        }
    }
}

report();

function report() {
    const modeledElN = modeled ? modeled.elements.length : 0;
    const specElN = specElements.length;
    const modeledPresN = specPresentation.filter((a) => isPresentationModeled(a.name)).length;

    console.log("check-svg-spec-coverage");
    console.log(`  spec elements            : ${specElN}`);
    console.log(`  modeled elements         : ${modeledElN}`);
    console.log(`  element exceptions       : ${exceptedElements.size}`);
    console.log(`  spec presentation props  : ${specPresentation.length}`);
    console.log(`  modeled presentation     : ${modeledPresN}`);
    console.log(`  presentation exceptions  : ${exceptedPresentation.size}`);
    console.log(`  attribute exceptions     : ${exceptedAttributes.size}`);

    if (errors.length) {
        console.error(`\ncheck-svg-spec-coverage: FAIL — ${errors.length} problem(s):`);
        for (const e of errors) console.error(`  - ${e}`);
        process.exit(1);
    }
    console.log("\ncheck-svg-spec-coverage: OK — every spec element & presentation property is modeled or excepted; every exception is real.");
    process.exit(0);
}
