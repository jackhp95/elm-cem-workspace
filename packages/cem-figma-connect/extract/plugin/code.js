// Adapted from avetta/akg-synapse VSD plugin, itself adapted from
// cursor-talk-to-figma-mcp (sonnylazuardi, MIT).
//
// cem-figma-connect extraction bridge — Figma sandbox side. Self-hosted plugin
// (install by manifest, no community-plugin dependency) whose ONLY job is to
// open a WebSocket bridge (via ui.html <-> extract/relay/socket.ts) and answer
// a SMALL, read-only set of Plugin API commands over it. See extract/README.md
// for the full runbook.
//
// This is a deliberately narrowed fork of the akg-synapse "VSD Design System
// Dumper" plugin: every write primitive (create_frame, set_fill, delete_node,
// ...) and everything VSD/push-synapse-specific has been dropped. Only the
// read primitives task A3 needs are ported:
//   ping, get_document_info, get_local_components, get_component_properties,
//   get_variables, get_styles, export_node_as_image
//
// Release blocker: this port has NOT yet been through Avetta IP review —
// do not make this repo public until that review is recorded (see
// extract/README.md "Release blocker" section).
//
// ⚠️ PLUGIN VM IS ES2019 — do NOT use the nullish-coalescing operator (two
// question marks back to back) or the optional-chaining operator (a
// question mark immediately followed by a dot) ANYWHERE in this file: the
// Figma plugin JS engine fails to PARSE them, which silently breaks the
// ENTIRE plugin (the bridge never attaches, with no visible error). Use
// `x == null ? a : b` and explicit `if` guards instead. This is an enforced
// verify gate for this file — see extract/README.md for the exact check.
//
// NOTE ON THE HISTORICAL NUL BYTE: the akg-synapse source this was ported
// from contains a stray NUL byte (inside a write-only helper we deliberately
// did not port — font loading for text-node creation). It is not present in
// this file, but always search Figma plugin sources with `grep -a` (not
// plain `grep`), since a NUL byte silently truncates a naive text-tool match.
//
// Plugin code reloads ONLY when the plugin instance is RE-RUN from
// Plugins -> Development (a relay restart alone is not enough) — the tell
// is an unchanged bridge channel id in the console banner below.

var PLUGIN_BUILD = "a3-generalized-extract.8-drop-guard";

// NOTE (AF-14): a per-variant `raceTimeout` guard was tried in `.7` to bound
// slow renders. It was REMOVED because it does nothing for the actual failure
// mode: fill-container components (snackbar, list-item density, text field)
// stall in the temp-frame render path SYNCHRONOUSLY — a setTimeout-based race
// timer never fires while the JS thread is blocked, and one such stall wedges
// the whole plugin until reload. There is no in-isolate way to bound a
// synchronous native stall. Those sets use the gate's LIVE-EXPORT fallback
// instead of offline capture; the 144 definition-path sets capture fine.
console.log("[cem-figma-extract] launch; build =", PLUGIN_BUILD, "; editorType =", figma.editorType);

// ─── Bridge command handlers (read-only) ──────────────────────────────────────
// Each handler is `(params, nodeId, scale) -> result`, matching handleBridgeCmd's
// call convention below. nodeId/scale are convenience pulls off params that most
// node-scoped handlers want; handlers that don't need them just ignore them.

var BRIDGE_COMMANDS = {
  // Cheap liveness probe. A real round-trip proves the plugin is executing
  // figma.* RIGHT NOW — unlike the relay's bridge registry `lastSeen`, which
  // only refreshes on a command reply and so goes stale on an idle-but-live
  // bridge. Used by extract/lib/bridge-health.mjs to verify a discovered
  // bridge before trusting it.
  "ping": async function (p, nodeId, scale) {
    return {
      ok: true,
      build: PLUGIN_BUILD,   // echo the loaded build so a reload can be VERIFIED,
                             // not assumed — a fresh WS channel does NOT prove the
                             // code was re-read from disk (the UI can reconnect
                             // while a stale code.js keeps running). Ping after
                             // every reload and check this equals the source build.
      editorType: figma.editorType,
      fileName: figma.root ? figma.root.name : "",
      currentPage: figma.currentPage ? { id: figma.currentPage.id, name: figma.currentPage.name } : null,
      ts: Date.now(),
    };
  },

  // File name + full page list. First call export.mjs makes — also the
  // cheapest way to confirm you have the right file open (see the
  // "master-file caveat" in extract/README.md). export.mjs uses fileKey
  // (falling back to name) as a file-identity guard BEFORE the bulk
  // get_component_properties loop — see runExport()'s identity check.
  "get_document_info": async function (p, nodeId, scale) {
    // figma.fileKey is not always present (depends on permissions/context);
    // no optional chaining / nullish-coalescing here — ES2019 plugin VM.
    var fileKey = null;
    try {
      if (typeof figma.fileKey !== "undefined" && figma.fileKey) fileKey = figma.fileKey;
    } catch (e) {
      /* reading figma.fileKey can itself throw depending on permissions */
    }
    return {
      name: figma.root ? figma.root.name : "",
      // Primary file-identity signal when available; name is the fallback
      // (see caller-side guard in extract/export.mjs runExport()).
      fileKey: fileKey,
      // editorType: "figma" = Design Mode (writable) · "dev" = Dev Mode (read-only).
      // Surfaced so callers can detect a read-only context before attempting writes
      // (this plugin never writes, but a Dev-Mode bridge is still worth flagging —
      // some read calls, e.g. per-id variable getters, throw there).
      editorType: figma.editorType,
      pages: figma.root.children.map(function (pg) { return { id: pg.id, name: pg.name }; }),
      currentPage: figma.currentPage ? { id: figma.currentPage.id, name: figma.currentPage.name } : null,
    };
  },

  // All local COMPONENT / COMPONENT_SET nodes across every page of the OPEN
  // file. Loads every page first (dynamic-page mode makes unopened pages'
  // children lazy/empty otherwise) — slow (~3-10s) on a large kit file.
  //
  // MASTER-FILE CAVEAT: this only enumerates components DEFINED in the open
  // file. The Plugin API has no team-library component enumeration (its
  // `teamLibrary` API — see get_variables below — exposes variables only,
  // not components/sets). Always confirm the open file is the kit itself,
  // not a file that merely CONSUMES the kit's published library.
  "get_local_components": async function (p, nodeId, scale) {
    try { if (figma.loadAllPagesAsync) await figma.loadAllPagesAsync(); } catch (e) { /* best-effort */ }
    var comps = figma.root.findAllWithCriteria({ types: ["COMPONENT", "COMPONENT_SET"] });
    return comps.map(function (c) {
      var pg = c.parent;
      while (pg && pg.type !== "PAGE") pg = pg.parent;
      return { id: c.id, name: c.name, type: c.type, key: c.key, description: c.description || "", page: pg ? pg.name : null };
    });
  },

  // { nodeId } -> variant axes + their options (for a COMPONENT_SET), or the
  // resolved property values (for a COMPONENT/INSTANCE). export.mjs calls
  // this once per COMPONENT_SET id returned by get_local_components to fill
  // figma-export.json's `setProperties`.
  "get_component_properties": async function (p, nodeId, scale) {
    if (!nodeId) return { error: "nodeId required" };
    var node = await figma.getNodeByIdAsync(nodeId);
    if (!node) return { error: "node not found: " + nodeId };
    var out = { id: node.id, name: node.name, type: node.type };
    if (node.type === "COMPONENT_SET") {
      var defs = node.componentPropertyDefinitions || {};
      out.properties = Object.keys(defs).map(function (k) {
        var d = defs[k];
        var e = { name: k, type: d.type };
        // figma-export.schema.json requires defaultValue on every entry.
        // The live Plugin API always sets it in practice, but never rely on
        // that: fall back to a type-appropriate empty value so an assembled
        // entry can never omit this required field (BOOLEAN -> false;
        // VARIANT/TEXT/INSTANCE_SWAP -> "", matching the string type the
        // live API returns for each).
        if (d.defaultValue != null) {
          e.defaultValue = d.defaultValue;
        } else if (d.type === "BOOLEAN") {
          e.defaultValue = false;
        } else {
          e.defaultValue = "";
        }
        if (d.variantOptions) e.variantOptions = d.variantOptions;
        if (d.preferredValues) e.preferredValues = d.preferredValues;
        return e;
      });
      out.variantCount = node.children ? node.children.length : 0;
    } else if (node.type === "COMPONENT" || node.type === "INSTANCE") {
      try { out.componentProperties = node.componentProperties || {}; } catch (e) { out.componentProperties = {}; }
      if (node.type === "INSTANCE") {
        try { if (node.mainComponent) out.mainComponent = { id: node.mainComponent.id, name: node.mainComponent.name }; } catch (e) { /* detached instance */ }
      }
    } else {
      out.note = "node is not a component / component-set / instance";
    }
    return out;
  },

  // Local paint / text / effect styles (design tokens expressed as styles
  // rather than variables). Whole-file, all pages.
  "get_styles": async function (p, nodeId, scale) {
    var paint = await figma.getLocalPaintStylesAsync();
    var text = await figma.getLocalTextStylesAsync();
    var effect = await figma.getLocalEffectStylesAsync();
    return {
      paintStyles: paint.map(function (s) { return { id: s.id, name: s.name, paints: s.paints }; }),
      textStyles: text.map(function (s) { return { id: s.id, name: s.name, fontName: s.fontName, fontSize: s.fontSize }; }),
      effectStyles: effect.map(function (s) { return { id: s.id, name: s.name, effects: s.effects }; }),
    };
  },

  // Local + published-library variable collections/variables (values-by-mode
  // + codeSyntax + scopes). This is the Plugin-API replacement for the
  // Figma Desktop MCP's `get_variable_defs` — no daily rate-limit, whole-file
  // rather than selection-scoped. NOTE: the variables REST endpoint is
  // Enterprise-only (see extract/README.md "Alternate producers"); this
  // Plugin-API path works on any seat.
  "get_variables": async function (p, nodeId, scale) {
    var warn = [];
    var collections = [], variables = [], libraryCollections = [];
    try {
      var colls = await figma.variables.getLocalVariableCollectionsAsync();
      collections = colls.map(function (c) { return { id: c.id, name: c.name, defaultModeId: c.defaultModeId, modes: c.modes, variableCount: c.variableIds.length }; });
      var vars = await figma.variables.getLocalVariablesAsync();
      variables = vars.map(function (v) { return { id: v.id, name: v.name, resolvedType: v.resolvedType, collectionId: v.variableCollectionId, valuesByMode: v.valuesByMode, scopes: v.scopes, codeSyntax: v.codeSyntax }; });
    } catch (e) { warn.push("variables: " + e.message); }
    try {
      if (figma.teamLibrary && figma.teamLibrary.getAvailableLibraryVariableCollectionsAsync) {
        var libColls = await figma.teamLibrary.getAvailableLibraryVariableCollectionsAsync();
        for (var i = 0; i < libColls.length; i++) {
          var lc = libColls[i];
          var vs = [];
          try {
            var lv = await figma.teamLibrary.getVariablesInLibraryCollectionAsync(lc.key);
            vs = lv.map(function (v) { return { key: v.key, name: v.name, resolvedType: v.resolvedType }; });
          } catch (e2) { warn.push("libVars[" + lc.name + "]: " + e2.message); }
          libraryCollections.push({ key: lc.key, name: lc.name, libraryName: lc.libraryName, variableCount: vs.length, variables: vs });
        }
      }
    } catch (e3) { warn.push("teamLibrary: " + e3.message); }
    return { collections: collections, variables: variables, libraryCollections: libraryCollections, warnings: warn };
  },

  // { nodeId, scale? } -> PNG bytes, base64-encoded. Used for design-truth
  // renders (visual verification gate, see plans/plan/C-visual-gate.md);
  // large frames can produce multi-MB payloads.
  //
  // FILL-CONTAINER FALLBACK: a component whose width is meant to stretch to a
  // parent frame (e.g. the Snackbar) has no intrinsic width when rendered
  // STANDALONE, so exportAsync collapses it to a 1x1 PNG. renderNodeControlled
  // handles this: DEFINITION-FIRST, and only when the definition is degenerate
  // does it render a CONTROLLED off-canvas temp-frame instance (the plugin's one
  // authorized write path, cleaned up via finally). It does NOT search the doc
  // for placed instances — those are often non-representative (see AF-09).
  "export_node_as_image": async function (p, nodeId, scale) {
    if (!nodeId) return { error: "nodeId required" };
    var node = await figma.getNodeByIdAsync(nodeId);
    if (!node) return { error: "node not found: " + nodeId };
    // Figma's ExportSettingsImage scales via `constraint`, NOT a bare `scale`
    // field (which is silently ignored — every scale then exports at 1x). See
    // https://www.figma.com/plugin-docs/api/ExportSettings/
    var settings = { format: "PNG", constraint: { type: "SCALE", value: scale } };
    var r = await renderNodeControlled(node, settings);
    var bytes = r.bytes;
    var exportedId = r.node.id;
    var bin = "";
    for (var i = 0; i < bytes.byteLength; i++) bin += String.fromCharCode(bytes[i]);
    // exportedNodeId names the node actually rendered (the instance, when the
    // fill-container fallback fired) — nodeId still echoes the requested one.
    return { imageData: btoa(bin), mimeType: "image/png", nodeId: nodeId, exportedNodeId: exportedId, scale: scale };
  },

  // { nodeId, scale?, offset?, limit? } -> a PAGE of variant renders + bounds +
  // content tree, plus `total` (the set's full variant count). Pagination exists
  // because a big COMPONENT_SET (m3-kit tops out at 480 variants) returns every
  // variant's base64 PNG in ONE WS response, which exceeds the client timeout.
  // The runner (bridgeCaptureSet) walks offset in chunks and merges client-side.
  // offset defaults to 0 and limit to "all", so an un-paginated call is unchanged.
  // See plans/2026-07-15-comprehensive-figma-capture-design.md.
  "capture_set": async function (p, nodeId, scale) {
    if (!nodeId) return { error: "nodeId required" };
    // Pre-sweep: remove leftover temp frames from any crashed prior run.
    try {
      var junk = figma.currentPage.findAll(function (n) { return n.name === "__cem-capture-temp__"; });
      for (var s = 0; s < junk.length; s++) junk[s].remove();
    } catch (e) { /* best-effort */ }

    var set = await figma.getNodeByIdAsync(nodeId);
    if (!set) return { error: "node not found: " + nodeId };
    var variantNodes = (set.type === "COMPONENT_SET") ? set.children.filter(function (n) { return n.type === "COMPONENT"; }) : [set];
    var total = variantNodes.length;
    var offset = (p && p.offset) ? p.offset : 0;
    var limit = (p && p.limit) ? p.limit : total;
    var page = variantNodes.slice(offset, offset + limit);
    var settings = { format: "PNG", constraint: { type: "SCALE", value: scale } };
    var variants = [];
    for (var i = 0; i < page.length; i++) {
      var vn = page[i];
      try {
        // Fill-container variants (snackbar, list-item density, text field)
        // stall SYNCHRONOUSLY in renderNodeControlled's temp-frame path and can
        // wedge the plugin (AF-14). No in-isolate guard can bound that; such
        // sets fall back to the gate's live export. Definition-path sets (the
        // 144 that capture) return fast here.
        var r = await renderNodeControlled(vn, settings);
        var dims = pngDimensions(r.bytes);
        var bin = "";
        for (var b = 0; b < r.bytes.byteLength; b++) bin += String.fromCharCode(r.bytes[b]);
        variants.push({
          variantNodeId: vn.id,
          props: parseVariantProps(vn.name),
          boundsPx: { w: dims.w, h: dims.h },
          renderVia: r.renderVia,
          contentTree: serializeContentTree(r.node, 4),
          imageData: btoa(bin),
          degenerate: dims.w <= 4 || dims.h <= 4,
        });
      } catch (e) {
        variants.push({ variantNodeId: vn.id, props: parseVariantProps(vn.name), error: (e && e.message) ? e.message : String(e) });
      }
    }
    return { setNodeId: set.id, setName: set.name, variants: variants, total: total, offset: offset };
  },
};

// ─── Fill-container export fallback helpers (read-only) ────────────────────────

// PNG IHDR width/height: big-endian uint32s at byte offsets 16 and 20 (after the
// 8-byte PNG signature + the 4-byte IHDR length + the 4-byte "IHDR" chunk type).
// ES2019-safe (plain arithmetic, no deps). Returns { w, h }.
function pngDimensions(bytes) {
  if (!bytes || bytes.byteLength < 24) return { w: 0, h: 0 };
  var w = ((bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19]) >>> 0;
  var h = ((bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23]) >>> 0;
  return { w: w, h: h };
}

// Render a node with real, non-degenerate bounds. DEFINITION-FIRST: export the
// component/variant definition directly — the clean, canonical render. Only when
// that collapses to a degenerate 1x1 (a FILL-CONTAINER component like the Snackbar,
// which has no intrinsic width standalone) fall back to a CONTROLLED temp-frame:
// instance the component in an off-canvas auto-layout frame at a fixed width,
// export, and remove the frame (guaranteed via finally). This temp-frame is the
// plugin's ONLY write path.
//
// We deliberately do NOT search the document for a placed instance. The largest
// placed instance of a variant is often a NON-REPRESENTATIVE usage (annotated,
// stretched, or sitting in a spec frame): that mis-captured normal components —
// e.g. icon-button "Round/Small/Default" came back 240x104 (a 2.31 aspect-ratio
// outlier) instead of its true ~96x96. Definition-first also removes the old
// per-variant O(all-instances) document scan entirely. See SP1 friction AF-09.
async function renderNodeControlled(node, settings) {
  var direct = await node.exportAsync(settings);
  var d = pngDimensions(direct);
  if (d.w > 4 && d.h > 4) return { bytes: direct, renderVia: "definition", node: node };
  // Degenerate definition. Instance the COMPONENT (a COMPONENT_SET instances its
  // defaultVariant) inside a controlled temp-frame.
  var comp = (node.type === "COMPONENT") ? node
    : (node.type === "COMPONENT_SET" && node.defaultVariant) ? node.defaultVariant : null;
  if (!comp || !comp.createInstance) return { bytes: direct, renderVia: "definition-degenerate", node: node };
  var frame = figma.createFrame();
  frame.name = "__cem-capture-temp__";
  frame.x = -100000; frame.y = -100000;
  frame.layoutMode = "HORIZONTAL"; frame.primaryAxisSizingMode = "AUTO"; frame.counterAxisSizingMode = "AUTO";
  frame.clipsContent = false;
  try {
    var placed = comp.createInstance();
    frame.appendChild(placed);
    // Fill-container children need a concrete width; the harness matches captured
    // bounds regardless, so this only affects content wrapping.
    try { placed.layoutSizingHorizontal = "FIXED"; placed.resize(360, placed.height); } catch (e) { /* not resizable */ }
    var bytes = await placed.exportAsync(settings);
    return { bytes: bytes, renderVia: "temp-frame", node: placed };
  } finally {
    frame.remove();   // GUARANTEED cleanup, even on export throw
  }
}

// Shallow baked-content tree for SP2. Records TEXT (characters), INSTANCE
// (mainComponent id/name), and container structure, depth-bounded. Read-only.
// Reads node.mainComponent synchronously inside a try/catch (a detached or
// dynamic-page-lazy instance just skips the id) so the whole walk stays sync.
function serializeContentTree(node, depth) {
  if (!node || depth < 0) return null;
  var out = { type: node.type, name: node.name };
  if (node.type === "TEXT") { try { out.characters = node.characters; } catch (e) { /* ignore */ } }
  if (node.type === "INSTANCE") {
    try { if (node.mainComponent) out.mainComponent = { id: node.mainComponent.id, name: node.mainComponent.name }; } catch (e) { /* detached */ }
  }
  if (node.children && depth > 0) {
    var kids = [];
    for (var i = 0; i < node.children.length; i++) {
      var k = serializeContentTree(node.children[i], depth - 1);
      if (k) kids.push(k);
    }
    if (kids.length) out.children = kids;
  }
  return out;
}

// Figma variant node name -> { Axis: Value } (names are "Axis=Value, Axis2=Value2").
function parseVariantProps(name) {
  var out = {};
  var parts = String(name).split(",");
  for (var i = 0; i < parts.length; i++) {
    var kv = parts[i].split("=");
    if (kv.length === 2) out[kv[0].trim()] = kv[1].trim();
  }
  return out;
}

async function handleBridgeCmd(command, params) {
  var p = params || {};
  var nodeId = p.nodeId || p.node_id;
  var scale = p.scale || 1;
  var fn = BRIDGE_COMMANDS[command];
  if (!fn) return { error: "unknown command: " + command };
  return await fn(p, nodeId, scale);
}

// ─── WS bridge wiring ──────────────────────────────────────────────────────────

// Rewrite Figma's raw "Can't call X in read-only mode" into an actionable
// message that names the current editorType, so a Dev-Mode launch is
// self-explanatory (none of our ported handlers write, but per-id variable
// getters and similar reads have been observed to throw in Dev Mode — see
// extract/README.md's master-file / Design-mode note).
function friendlyBridgeError(e) {
  var msg = (e && e.message) ? e.message : String(e);
  if (msg.indexOf("read-only") !== -1) {
    return "Figma is read-only here (editorType=" + figma.editorType + "). " +
      (figma.editorType === "dev"
        ? "Leave Dev Mode (toggle off Dev Mode / Shift+D) and relaunch this plugin from the Design-Mode Plugins menu."
        : "You may have view-only access to this file — open an editable file and relaunch.");
  }
  return msg;
}

function runWSBridge() {
  // Self-assign a RANDOM channel per launch (cem-<hex>). Each plugin instance
  // gets its own channel, so a stale zombie panel can never share a channel
  // with a fresh bridge. The relay enforces single-bridge-per-channel; a
  // caller discovers this channel via `list_bridges` and picks the writable
  // one (editorType === "figma") — see extract/lib/bridge-select.mjs.
  var channel = "cem-" + Math.random().toString(16).slice(2, 8);
  // editorType/fileName travel with the join so the caller can pick the
  // writable bridge.
  var meta = {
    editorType: figma.editorType,
    fileName: figma.root ? figma.root.name : "",
  };
  // Set handler BEFORE showUI to avoid the race where postMessage fires
  // before the iframe's onmessage listener is wired up.
  figma.ui.onmessage = async function (msg) {
    if (!msg) return;
    // ui.html signals it's ready — now safe to send the bridge command.
    if (msg.type === "ui-ready") {
      figma.ui.postMessage({ command: "bridge", channel: channel, meta: meta });
      figma.notify("cem-figma-connect WS Bridge — connecting on channel '" + channel + "' (editorType=" + figma.editorType + ")", { timeout: 4000 });
      return;
    }
    if (msg.type === "bridge-cmd") {
      var id = msg.id;
      var command = msg.command;
      var params = msg.params;
      console.log("[cem-figma-extract] -> " + command);
      try {
        var result = await handleBridgeCmd(command, params);
        var tail = (result && result.error) ? " ERROR: " + result.error : " ok";
        console.log("[cem-figma-extract] <- " + command + tail);
        figma.ui.postMessage({ type: "bridge-result", id: id, result: result });
      } catch (e) {
        var friendly = friendlyBridgeError(e);
        console.error("[cem-figma-extract] x " + command + " threw: " + friendly);
        figma.ui.postMessage({ type: "bridge-result", id: id, error: friendly });
      }
    }
  };
  figma.showUI(__html__, { width: 440, height: 200, title: "cem-figma-connect Extract Bridge" });
}

// This plugin has exactly one job: start the bridge. (The upstream VSD
// plugin had a menu of dump/export/push commands; all dropped here — see
// header.)
runWSBridge();
