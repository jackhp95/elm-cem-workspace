#!/usr/bin/env node
// check-coverage-map.mjs — the internal-consistency gate for the facts-bundle
// coverage audit (docs/facts-bundle/).
//
// It proves three things and nothing more:
//   1. docs/facts-bundle/coverage-map.json is well-formed, non-empty, and every
//      entry obeys the mapped/exception contract.
//   2. All four consumers appear.
//   3. Every `bundleField` named in the map resolves to a real property path in
//      docs/facts-bundle/schema.json, which itself is valid JSON and carries the
//      provenance stamp.
//
// It CANNOT prove the audit is true — that a cited line really reads that field,
// or that a mapping is honest. That is the reviewer's job. A green run only means
// the evidence file and the schema agree with each other.
//
// bundleField path syntax:
//   a.b.c        -> properties.a -> properties.b -> properties.c
//   a[].b        -> properties.a -> items -> properties.b        (array)
//   a{}.b        -> properties.a -> additionalProperties -> properties.b  (map)
// `$ref`s to `#/definitions/X` are followed transparently.
//
// Zero dependencies. Exits 0 on success, 1 on any failure.

import { readFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const MAP_PATH = join(repoRoot, "docs", "facts-bundle", "coverage-map.json");
const SCHEMA_PATH = join(repoRoot, "docs", "facts-bundle", "schema.json");

const REQUIRED_CONSUMERS = [
    "m3e-okf",
    "tailwind-m3e-web",
    "cem-figma-connect-matcher",
    "cem-figma-connect-elm-emitter",
];

const VALID_FACES = ["B", "C"];

// The provenance stamp the design spec requires: the @m3e/web version/SHA Face B
// was generated from, and (for Face C) the elm-cem / brand generation commits.
const REQUIRED_PROVENANCE_PATHS = [
    "faceB.provenance.generator.version",
    "faceB.provenance.source.package",
    "faceB.provenance.source.version",
    "faceB.provenance.source.sha",
    "faceC.provenance.producer.elmCem.version",
    "faceC.provenance.producer.elmCem.commit",
    "faceC.provenance.brand.commit",
    "faceC.provenance.source.version",
    "faceC.provenance.source.sha",
];

const errors = [];
function fail(msg) {
    errors.push(msg);
}

// Declared up front because report() may run early (on an unreadable input) and
// must not trip over a not-yet-initialised binding.
let entries = [];
let mappedCount = 0;
let exceptionCount = 0;
const perConsumer = new Map();

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

// -- schema path resolution --------------------------------------------------

function deref(node, schema, trail) {
    let cur = node;
    const seen = new Set();
    while (cur && typeof cur === "object" && typeof cur.$ref === "string") {
        const ref = cur.$ref;
        if (seen.has(ref)) {
            fail(`schema.json: cyclic $ref chain at ${ref} (resolving ${trail})`);
            return null;
        }
        seen.add(ref);
        if (!ref.startsWith("#/")) {
            fail(`schema.json: only local "#/..." $refs are supported, got ${ref} (resolving ${trail})`);
            return null;
        }
        let target = schema;
        for (const seg of ref.slice(2).split("/")) {
            if (!target || typeof target !== "object" || !(seg in target)) {
                fail(`schema.json: unresolvable $ref ${ref} (resolving ${trail})`);
                return null;
            }
            target = target[seg];
        }
        cur = target;
    }
    return cur;
}

// Resolve a dotted bundleField path against the schema. Returns the resolved
// subschema, or null (having recorded an error) when it does not exist.
function resolveBundleField(path, schema, whereLabel) {
    if (typeof path !== "string" || path.trim() === "") {
        fail(`${whereLabel}: bundleField is empty`);
        return null;
    }
    let node = deref(schema, schema, path);
    const segments = path.split(".");
    let walked = "";
    for (const rawSeg of segments) {
        const m = /^([A-Za-z_$][\w$]*)((?:\[\]|\{\})*)$/.exec(rawSeg);
        if (!m) {
            fail(`${whereLabel}: bundleField "${path}" has an unparseable segment "${rawSeg}"`);
            return null;
        }
        const [, name, suffixes] = m;
        walked = walked ? `${walked}.${rawSeg}` : rawSeg;

        node = deref(node, schema, path);
        if (!node || typeof node !== "object") {
            fail(`${whereLabel}: bundleField "${path}" — nothing to descend into at "${walked}"`);
            return null;
        }
        const props = node.properties;
        if (!props || typeof props !== "object" || !Object.prototype.hasOwnProperty.call(props, name)) {
            fail(
                `${whereLabel}: bundleField "${path}" does not exist in schema.json — ` +
                `no property "${name}" at "${walked}"`,
            );
            return null;
        }
        node = props[name];

        for (const suffix of suffixes.match(/\[\]|\{\}/g) ?? []) {
            node = deref(node, schema, path);
            if (!node || typeof node !== "object") {
                fail(`${whereLabel}: bundleField "${path}" — cannot apply "${suffix}" at "${walked}"`);
                return null;
            }
            if (suffix === "[]") {
                if (!node.items) {
                    fail(
                        `${whereLabel}: bundleField "${path}" uses "[]" at "${walked}" but that ` +
                        `schema node declares no "items" (it is not an array)`,
                    );
                    return null;
                }
                node = node.items;
            } else {
                if (!node.additionalProperties || typeof node.additionalProperties !== "object") {
                    fail(
                        `${whereLabel}: bundleField "${path}" uses "{}" at "${walked}" but that ` +
                        `schema node declares no object-valued "additionalProperties" (it is not a map)`,
                    );
                    return null;
                }
                node = node.additionalProperties;
            }
        }
    }
    return deref(node, schema, path);
}

// -- main -------------------------------------------------------------------

const map = readJson(MAP_PATH, "coverage-map.json");
const schema = readJson(SCHEMA_PATH, "schema.json");

if (errors.length) {
    report();
}

// Schema shape + provenance stamp.
if (schema) {
    if (typeof schema !== "object" || Array.isArray(schema)) {
        fail("schema.json: top level must be a JSON Schema object");
    } else {
        for (const path of REQUIRED_PROVENANCE_PATHS) {
            resolveBundleField(path, schema, "schema.json provenance stamp");
        }
    }
}

// Coverage-map shape.
if (map) {
    if (typeof map !== "object" || Array.isArray(map)) {
        fail("coverage-map.json: top level must be an object");
    } else if (!Array.isArray(map.entries)) {
        fail("coverage-map.json: `entries` is missing or not an array");
    } else if (map.entries.length === 0) {
        fail("coverage-map.json: `entries` is empty — an audit with no evidence proves nothing");
    } else {
        entries = map.entries;
    }
}

entries.forEach((entry, i) => {
    const where = `coverage-map.json entries[${i}]`;
    if (typeof entry !== "object" || entry === null || Array.isArray(entry)) {
        fail(`${where}: entry must be an object`);
        return;
    }
    const label =
        `${where} (${entry.consumer ?? "?"} ${entry.sourceFile ?? "?"}:${entry.sourceLine ?? "?"})`;

    if (typeof entry.consumer !== "string" || !REQUIRED_CONSUMERS.includes(entry.consumer)) {
        fail(
            `${label}: \`consumer\` must be one of ${REQUIRED_CONSUMERS.join(", ")} — got ` +
            `${JSON.stringify(entry.consumer)}`,
        );
    } else {
        const bucket = perConsumer.get(entry.consumer) ?? { mapped: 0, exception: 0 };
        if (entry.status === "mapped") bucket.mapped += 1;
        else if (entry.status === "exception") bucket.exception += 1;
        perConsumer.set(entry.consumer, bucket);
    }

    if (typeof entry.sourceFile !== "string" || entry.sourceFile.trim() === "") {
        fail(`${label}: \`sourceFile\` must be a non-empty repo-relative path`);
    }
    if (!Number.isInteger(entry.sourceLine) || entry.sourceLine < 1) {
        fail(`${label}: \`sourceLine\` must be a positive integer`);
    }
    if (typeof entry.field !== "string" || entry.field.trim() === "") {
        fail(`${label}: \`field\` must be a non-empty description of what is read`);
    }

    if (entry.status === "mapped") {
        mappedCount += 1;
        if (entry.face === null || entry.face === undefined) {
            fail(`${label}: status "mapped" requires a \`face\`, got ${JSON.stringify(entry.face)}`);
        } else if (!VALID_FACES.includes(entry.face)) {
            fail(`${label}: \`face\` must be one of ${VALID_FACES.join(", ")} — got ${JSON.stringify(entry.face)}`);
        }
        if (typeof entry.bundleField !== "string" || entry.bundleField.trim() === "") {
            fail(`${label}: status "mapped" requires a non-empty \`bundleField\``);
        } else if (schema) {
            resolveBundleField(entry.bundleField, schema, label);
        }
    } else if (entry.status === "exception") {
        exceptionCount += 1;
        if (entry.face !== null) {
            fail(`${label}: status "exception" requires \`face: null\`, got ${JSON.stringify(entry.face)}`);
        }
        if (entry.bundleField !== null && entry.bundleField !== undefined) {
            fail(
                `${label}: status "exception" must not name a \`bundleField\` — got ` +
                `${JSON.stringify(entry.bundleField)}`,
            );
        }
        if (typeof entry.note !== "string" || entry.note.trim().length < 20) {
            fail(
                `${label}: status "exception" requires a substantive \`note\` justifying why the field ` +
                `stays outside the bundle (at least 20 characters)`,
            );
        }
    } else {
        fail(`${label}: \`status\` must be "mapped" or "exception" — got ${JSON.stringify(entry.status)}`);
    }
});

for (const consumer of REQUIRED_CONSUMERS) {
    if (!perConsumer.has(consumer)) {
        fail(`coverage-map.json: consumer "${consumer}" has no entries — every consumer must be audited`);
    }
}

report();

function report() {
    if (entries.length) {
        console.log("coverage-map.json");
        console.log(`  entries total : ${entries.length}`);
        console.log(`  mapped        : ${mappedCount}`);
        console.log(`  exception     : ${exceptionCount}`);
        console.log("  per consumer  :");
        for (const consumer of REQUIRED_CONSUMERS) {
            const b = perConsumer.get(consumer);
            const total = b ? b.mapped + b.exception : 0;
            console.log(
                `    ${consumer.padEnd(30)} ${String(total).padStart(3)} ` +
                `(${b ? b.mapped : 0} mapped, ${b ? b.exception : 0} exception)`,
            );
        }
        const extra = [...perConsumer.keys()].filter((c) => !REQUIRED_CONSUMERS.includes(c));
        for (const consumer of extra) {
            const b = perConsumer.get(consumer);
            console.log(`    ${consumer.padEnd(30)} ${String(b.mapped + b.exception).padStart(3)} (UNKNOWN CONSUMER)`);
        }
    }

    if (errors.length) {
        console.error(`\ncheck-coverage-map: FAIL — ${errors.length} problem(s):`);
        for (const e of errors) console.error(`  - ${e}`);
        process.exit(1);
    }
    console.log("\ncheck-coverage-map: OK — every mapped bundleField resolves in schema.json.");
    process.exit(0);
}
