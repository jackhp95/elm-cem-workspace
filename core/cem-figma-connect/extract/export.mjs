#!/usr/bin/env node
// Adapted from avetta/akg-synapse VSD plugin, itself adapted from
// cursor-talk-to-figma-mcp (sonnylazuardi, MIT). Specifically: the CLI
// orchestration technique of figma-ws/figma-ws-client.mjs.
//
// extract/export.mjs — one-command Figma extraction over the WS bridge.
//
// Orchestrates: get_document_info -> get_local_components ->
// get_component_properties (for every COMPONENT_SET) -> get_variables ->
// get_styles, assembles the Task-A2 figma-export.json schema
// (src/ingest/figma-export.schema.json — THE contract; see
// src/ingest/figma.mjs), stamps `meta` from CLI args only (never computed —
// determinism, D9), validates, and writes the result.
//
// Usage:
//   node extract/export.mjs --file-label m3-kit --file-key <k> \
//     --kit-version <tag> --out <path> [--channel <name>] [--dry]
//
// --dry stubs the bridge entirely (no relay, no Figma) and emits
// fixture-shaped, schema-valid output — useful for pipeline development and
// CI without a live Figma session. See extract/README.md for the full
// runbook, including the deferred HUMAN Figma acceptance run.
//
// Setup (real run, not --dry):
//   1. mise use -g bun ; bun extract/relay/socket.ts        (keep running)
//   2. In Figma (Design mode): Plugins → Development →
//      cem-figma-connect Extract Bridge → "Start WS Bridge"
//   3. node extract/export.mjs --file-label ... --file-key ... \
//        --kit-version ... --out ...
//
// Channel auto-discovery per extract/lib/bridge-health.mjs (list_bridges +
// a verified ping); pass --channel to target a specific bridge directly
// when more than one is live.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { wsQuery } from "./lib/ws-query.mjs";
import { validate } from "../src/lib/validate.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.join(here, "..");
const SCHEMA_PATH = path.join(repoRoot, "src", "ingest", "figma-export.schema.json");

// ─── CLI args ──────────────────────────────────────────────────────────────────

function parseArgs(argv) {
  const args = { dry: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--dry") { args.dry = true; continue; }
    if (a === "--file-label") { args.fileLabel = argv[++i]; continue; }
    if (a === "--file-key") { args.fileKey = argv[++i]; continue; }
    if (a === "--kit-version") { args.kitVersion = argv[++i]; continue; }
    if (a === "--out") { args.out = argv[++i]; continue; }
    if (a === "--channel") { args.channel = argv[++i]; continue; }
    if (a === "--extracted-at") { args.extractedAt = argv[++i]; continue; }
    if (a === "--allow-file-mismatch") { args.allowFileMismatch = true; continue; }
    if (a === "--reuse-tokens-on-failure") { args.reuseTokensOnFailure = true; continue; }
    if (a === "--help" || a === "-h") { args.help = true; continue; }
    throw new Error(`Unknown argument: ${a}`);
  }
  return args;
}

function usage() {
  return [
    "Usage: node extract/export.mjs --file-label <label> --file-key <key> --kit-version <tag> --out <path> [--channel <name>] [--dry]",
    "",
    "  --file-label   Human label for logging (e.g. m3-kit). Not stored in the schema.",
    "  --file-key     Figma file key -> meta.fileKey (stamped verbatim, never computed).",
    "  --kit-version  Version tag -> meta.kitVersionTag (stamped verbatim, never computed).",
    "  --out          Output path for the assembled figma-export.json.",
    "  --channel      Explicit relay channel (skips auto-discovery).",
    "  --extracted-at Override meta.extractedAt (default: current time, ISO 8601).",
    "  --dry          Stub the bridge; emit fixture-shaped schema-valid output. No relay/Figma needed.",
    "  --allow-file-mismatch",
    "                 Escape hatch: skip the file-identity guard (name/fileKey vs --file-key)",
    "                 that runs before the bulk get_component_properties loop.",
    "  --reuse-tokens-on-failure",
    "                 If get_variables/get_styles fail (e.g. the team-library token",
    "                 service hangs on a large kit), carry over variables+styles from the",
    "                 existing --out dump instead of aborting. Refreshes component structure",
    "                 (setProperties/components — the capture-critical path) while keeping",
    "                 the prior tokens. Loud WARNING; off by default (strict/deterministic).",
  ].join("\n");
}

// ─── Bridge interfaces ─────────────────────────────────────────────────────────
// runExport() below is transport-agnostic: it only depends on this five-method
// shape. That is what lets --dry and the real WS bridge share one assembly
// path — "the schema is the contract, not the transport" (task brief).

function createWsBridge(opts) {
  const wsOpts = { channel: opts.channel };
  return {
    async getDocumentInfo() { return wsQuery("get_document_info", {}, wsOpts); },
    async getLocalComponents() { return wsQuery("get_local_components", {}, wsOpts); },
    async getComponentProperties(nodeId) { return wsQuery("get_component_properties", { nodeId }, wsOpts); },
    // Variables + styles are single calls that serialize the WHOLE kit's token
    // set / style library in one response — for a large kit (M3 Community has
    // thousands of variables) that exceeds the 30s default. Give them a 180s
    // ceiling; the bulk get_component_properties loop keeps the fast-fail default.
    async getVariables() { return wsQuery("get_variables", {}, { ...wsOpts, timeoutMs: 180000 }); },
    async getStyles() { return wsQuery("get_styles", {}, { ...wsOpts, timeoutMs: 180000 }); },
  };
}

// Fixture-shaped fake bridge for --dry: enough structure (a COMPONENT_SET
// with two variants, a standalone, a variable collection with two modes, one
// paint/text/effect style) to exercise every branch of the assembly logic
// and loadFigmaExport() downstream, without a relay or Figma running.
function createDryBridge() {
  const SET_ID = "1:100";
  return {
    async getDocumentInfo() {
      return {
        name: "Dry-run fixture file",
        editorType: "figma",
        pages: [{ id: "0:1", name: "Page 1" }],
        currentPage: { id: "0:1", name: "Page 1" },
      };
    },
    async getLocalComponents() {
      return [
        { id: SET_ID, name: "Example Component", type: "COMPONENT_SET", key: "0".repeat(40), description: "", page: "Page 1" },
        { id: "1:101", name: "Type=Filled, State=Enabled", type: "COMPONENT", key: "1".repeat(40), description: "", page: "Page 1" },
        { id: "1:102", name: "Type=Filled, State=Disabled", type: "COMPONENT", key: "2".repeat(40), description: "", page: "Page 1" },
        { id: "1:103", name: "Standalone Icon", type: "COMPONENT", key: "3".repeat(40), description: "A standalone component", page: "Page 1" },
      ];
    },
    async getComponentProperties(nodeId) {
      if (nodeId !== SET_ID) return { id: nodeId, name: "unexpected", type: "COMPONENT" };
      return {
        id: SET_ID,
        name: "Example Component",
        type: "COMPONENT_SET",
        variantCount: 2,
        properties: [
          { name: "Type", type: "VARIANT", defaultValue: "Filled", variantOptions: ["Filled", "Outlined"] },
          { name: "State", type: "VARIANT", defaultValue: "Enabled", variantOptions: ["Enabled", "Disabled"] },
          { name: "Label text#1:1", type: "TEXT", defaultValue: "Label" },
        ],
      };
    },
    async getVariables() {
      return {
        collections: [
          { id: "VariableCollectionId:1:1", name: "Example", defaultModeId: "1:0", modes: [{ modeId: "1:0", name: "Light" }, { modeId: "1:1", name: "Dark" }], variableCount: 1 },
        ],
        variables: [
          { id: "VariableID:1:1", name: "color/example", resolvedType: "COLOR", collectionId: "VariableCollectionId:1:1", valuesByMode: { "1:0": { r: 1, g: 1, b: 1, a: 1 }, "1:1": { r: 0, g: 0, b: 0, a: 1 } }, scopes: ["ALL_SCOPES"], codeSyntax: {} },
        ],
        libraryCollections: [],
        warnings: [],
      };
    },
    async getStyles() {
      return {
        paintStyles: [{ id: "S:1", name: "Example/Paint", paints: [] }],
        textStyles: [{ id: "S:2", name: "Example/Text", fontName: { family: "Inter", style: "Regular" }, fontSize: 14 }],
        effectStyles: [{ id: "S:3", name: "Example/Effect", effects: [] }],
      };
    },
  };
}

// ─── Assembly ──────────────────────────────────────────────────────────────────

function assembleVariables(raw) {
  return {
    collections: raw.collections.map((c) => ({
      id: c.id,
      name: c.name,
      modes: c.modes.map((m) => ({ id: m.modeId != null ? m.modeId : m.id, name: m.name })),
    })),
    variables: raw.variables.map((v) => ({
      id: v.id,
      name: v.name,
      resolvedType: v.resolvedType,
      collectionId: v.collectionId,
      valuesByMode: v.valuesByMode,
      codeSyntax: v.codeSyntax,
      scopes: v.scopes,
    })),
  };
}

function assembleComponent(c) {
  return { id: c.id, name: c.name, type: c.type, key: c.key, description: c.description || "", page: c.page };
}

/**
 * Transport-agnostic orchestration: pulls everything the schema needs off
 * `bridge`, assembles + validates figma-export.json, and returns it (does not
 * write — the caller decides where/whether to persist it).
 */
export async function runExport(bridge, args) {
  process.stderr.write(`[export] file-label=${args.fileLabel} file-key=${args.fileKey}\n`);

  process.stderr.write("[export] get_document_info...\n");
  const docInfo = await bridge.getDocumentInfo();

  // Early, visible file-identity signal — printed immediately after the
  // first round-trip, before any further calls fire. (Incident: a prior run
  // fired the 171-call get_component_properties loop at an unrelated live
  // document with nothing checking this first.)
  process.stderr.write(
    `[export] connected document: name="${docInfo.name}" fileKey=${docInfo.fileKey ? docInfo.fileKey : "(unavailable)"}\n`
  );

  // File-identity guard — BEFORE the bulk get_component_properties loop.
  // fileKey (when the plugin can read it) is the reliable signal; document
  // name is a best-effort fallback that only warns, since names collide and
  // this function has no way to know what "obviously corresponds" means for
  // an arbitrary kit file.
  if (args.allowFileMismatch) {
    process.stderr.write("[export] --allow-file-mismatch set; skipping file-identity guard.\n");
  } else if (docInfo.fileKey) {
    if (docInfo.fileKey !== args.fileKey) {
      throw new Error(
        `File-identity guard: connected file key "${docInfo.fileKey}" (name="${docInfo.name}") does not match ` +
        `--file-key "${args.fileKey}". Aborting BEFORE the bulk get_component_properties loop to avoid reading ` +
        `an unintended file. Pass --allow-file-mismatch if you are certain this is correct.`
      );
    }
  } else if (docInfo.name) {
    process.stderr.write(
      `[export] WARNING: plugin returned no fileKey (older Figma sandbox or permissions); cannot verify document ` +
      `"${docInfo.name}" is the intended --file-key "${args.fileKey}" file. Proceeding on trust — pass ` +
      `--allow-file-mismatch to silence this warning.\n`
    );
  }

  process.stderr.write("[export] get_local_components...\n");
  const rawComponents = await bridge.getLocalComponents();
  const components = rawComponents.map(assembleComponent);
  const setIds = rawComponents.filter((c) => c.type === "COMPONENT_SET").map((c) => c.id);

  process.stderr.write(`[export] get_component_properties for ${setIds.length} COMPONENT_SET(s)...\n`);
  const setProperties = {};
  for (const id of setIds) {
    const props = await bridge.getComponentProperties(id);
    if (props && Array.isArray(props.properties)) setProperties[id] = props.properties;
  }

  // Token extraction (variables + styles) is the emit-mapping path, NOT the
  // capture-critical path (that's components + setProperties, already gathered).
  // On a large kit the team-library variable service can hang (get_variables
  // exceeded even a 180s ceiling on M3 Community). With --reuse-tokens-on-failure
  // a hang/error carries the prior --out dump's tokens forward instead of
  // aborting the whole re-extraction. Default (flag off): strict — rethrow.
  const priorDump = args.reuseTokensOnFailure && args.out && fs.existsSync(args.out)
    ? JSON.parse(fs.readFileSync(args.out, "utf8"))
    : null;

  process.stderr.write("[export] get_variables...\n");
  let variables;
  try {
    variables = assembleVariables(await bridge.getVariables());
  } catch (e) {
    if (!priorDump || !priorDump.variables) throw e;
    process.stderr.write(`[export] WARNING: get_variables failed (${e.message}); REUSING variables from prior dump ${args.out} (stale tokens; component structure IS fresh)\n`);
    variables = priorDump.variables;
  }

  process.stderr.write("[export] get_styles...\n");
  let styles;
  try {
    const rawStyles = await bridge.getStyles();
    styles = {
      paintStyles: rawStyles.paintStyles,
      textStyles: rawStyles.textStyles,
      effectStyles: rawStyles.effectStyles,
    };
  } catch (e) {
    if (!priorDump || !priorDump.styles) throw e;
    process.stderr.write(`[export] WARNING: get_styles failed (${e.message}); REUSING styles from prior dump ${args.out}\n`);
    styles = priorDump.styles;
  }

  // meta is stamped from CLI args ONLY — never computed here beyond a
  // straight pass-through of --extracted-at (or the current time if the flag
  // is omitted). Determinism (D9) means re-running with the SAME args
  // against the SAME file should be reproducible; that's the caller's job
  // (pass --extracted-at explicitly) not this function's.
  const meta = {
    fileKey: args.fileKey,
    fileName: docInfo.name,
    extractedAt: args.extractedAt || new Date().toISOString(),
    kitVersionTag: args.kitVersion,
  };

  const result = { meta, components, setProperties, variables, styles };

  const schema = JSON.parse(fs.readFileSync(SCHEMA_PATH, "utf8"));
  const { valid, errors } = validate(schema, result);
  if (!valid) {
    throw new Error(`Assembled export failed schema validation:\n${errors.join("\n")}`);
  }

  return result;
}

// ─── CLI entry ─────────────────────────────────────────────────────────────────

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) { console.log(usage()); return; }
  for (const required of ["fileLabel", "fileKey", "kitVersion", "out"]) {
    if (!args[required]) {
      console.error(`Missing required --${required.replace(/[A-Z]/g, (c) => "-" + c.toLowerCase())}\n`);
      console.error(usage());
      process.exitCode = 1;
      return;
    }
  }

  const bridge = args.dry ? createDryBridge() : createWsBridge(args);
  const result = await runExport(bridge, args);

  fs.mkdirSync(path.dirname(path.resolve(args.out)), { recursive: true });
  fs.writeFileSync(args.out, `${JSON.stringify(result, null, 2)}\n`);
  process.stderr.write(`[export] wrote ${args.out}\n`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((e) => {
    console.error(`[export] ERROR: ${e.message}`);
    process.exitCode = 1;
  });
}
