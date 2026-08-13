// Adapted from avetta/akg-synapse VSD plugin, itself adapted from cursor-talk-to-figma-mcp (sonnylazuardi, MIT).
// Source: figma-ws/bridge-discovery.lib.mjs
//
// bridge-discovery.mjs — caller-side auto-pairing for the cem-figma-connect
// extraction bridge.
//
// Solves the "which channel?" problem created by random per-launch channels
// (extract/plugin/code.js self-assigns "cem-<hex>" on every run):
//   1. discoverBridges() asks the relay (list_bridges) for its live bridge registry
//   2. selectWritableBridge() picks the writable (editorType:"figma"), newest one
//   3. resolveBridgeChannel() returns that channel — or an actionable error
//
// An explicit channel (opts.channel or FIGMA_CHANNEL, or export.mjs's
// --channel flag) always wins, so manual targeting works too.
//
// Uses Node's built-in global WebSocket (stable since Node 22 — this repo's
// package.json already requires node>=22) instead of the "ws" npm package,
// so extract/ stays dependency-free like core.
//
// Architecture: [caller] <-> WS relay (extract/relay/socket.ts) <-registry- bridges (plugin)

import crypto from "node:crypto";
import { selectWritableBridge } from "./bridge-select.mjs";

const DEFAULT_WS_URL = process.env.FIGMA_WS_URL || "ws://localhost:3055";

/**
 * Ask the relay for its live bridge registry. Resolves with an array of
 * {channel, editorType, fileName, lastSeen}. Requires only the relay (not a
 * channel join), so it works before we know which channel to use.
 */
export function discoverBridges(opts = {}) {
  const wsUrl = opts.wsUrl || DEFAULT_WS_URL;
  const timeoutMs = opts.timeoutMs || 5000;
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUrl);
    const id = crypto.randomUUID();
    const timeout = setTimeout(() => {
      ws.close();
      reject(new Error(`Timeout after ${timeoutMs}ms waiting for list_bridges`));
    }, timeoutMs);

    ws.onopen = () => ws.send(JSON.stringify({ type: "list_bridges", id }));
    ws.onmessage = (event) => {
      let msg;
      try { msg = JSON.parse(event.data.toString()); } catch (e) { return; }
      if (msg.type === "bridges") {
        clearTimeout(timeout);
        ws.close();
        resolve(Array.isArray(msg.bridges) ? msg.bridges : []);
      }
    };
    ws.onerror = () => {
      clearTimeout(timeout);
      reject(new Error(`WebSocket error. Is the relay running? (bun extract/relay/socket.ts)`));
    };
    ws.onclose = () => clearTimeout(timeout);
  });
}

const SELECT_HINTS = {
  no_bridges: 'No plugin bridge is connected. Run "Start WS Bridge" in Figma (Plugins → Development → cem-figma-connect Extract Bridge).',
  no_writable: "Only read-only (Dev Mode) bridge(s) found. Switch the Figma file to Design Mode (toggle off Dev Mode / Shift+D) and relaunch the plugin.",
  all_stale: 'Bridge(s) found but none responded recently. Relaunch "Start WS Bridge" in Figma.',
};

/**
 * Resolve the channel the caller should talk on.
 *   - opts.channel / FIGMA_CHANNEL → returned verbatim (manual override, e.g.
 *     export.mjs's --channel flag)
 *   - otherwise discover + select the writable bridge
 * Throws an actionable Error when no writable bridge can be found.
 *
 * `opts.discover` is injectable for testing.
 */
export async function resolveBridgeChannel(opts = {}) {
  const override = opts.channel || process.env.FIGMA_CHANNEL;
  if (override) return override;

  const discover = opts.discover || discoverBridges;
  const bridges = await discover(opts);
  const sel = selectWritableBridge(bridges, { now: opts.now, maxAgeMs: opts.maxAgeMs });
  if (!sel.ok) {
    const hint = SELECT_HINTS[sel.reason] || sel.reason;
    throw new Error(`Cannot auto-select a Figma bridge (${sel.reason}): ${hint}`);
  }
  if (sel.ambiguous) {
    process.stderr.write(`[ws] multiple writable bridges live; picked newest → channel '${sel.channel}' (file "${sel.bridge.fileName}")\n`);
  }
  return sel.channel;
}
