// Adapted from avetta/akg-synapse VSD plugin, itself adapted from cursor-talk-to-figma-mcp (sonnylazuardi, MIT).
// Source: figma-ws/bridge-health.lib.mjs
//
// bridge-health.mjs — ping-verified reachability for the cem-figma-connect
// extraction bridge.
//
// Why this exists: the relay's `list_bridges` registry only proves a bridge
// socket is OPEN, and `selectWritableBridge` then rejects any whose
// `lastSeen` timestamp is stale (>15s). But the relay only refreshes
// `lastSeen` when the bridge answers a command — so a live-but-idle bridge
// looks dead and auto-resolution returns `all_stale` even though a real
// command would answer instantly. The fix: make a cheap real `ping`
// round-trip the liveness authority instead of the timestamp.
//
//   classifyHealth(input)   — PURE. Probe inputs → structured verdict + actionable hint.
//   checkBridge(opts)       — thin I/O. discover → ping the best candidate → classify.
//   resolveLiveChannel(opts)— thin I/O. Returns the channel of a ping-reachable bridge
//                              (prefers writable), or throws an actionable error.
//
// `discover` and `ping` are injectable so the logic is unit-testable without a relay.

import { discoverBridges } from "./bridge-discovery.mjs";
import { wsQuery } from "./ws-query.mjs";

const HINTS = {
  no_relay: "Relay not reachable. Start it: bun extract/relay/socket.ts",
  no_bridges: 'No plugin bridge connected. In Figma: Plugins → Development → cem-figma-connect Extract Bridge → "Start WS Bridge".',
  relay_only: 'Bridge registered but not responding (detached/zombie panel). Relaunch "Start WS Bridge" in Figma.',
  read_only: "Bridge is in Dev Mode (read-only). Some reads (e.g. per-id variable getters) throw there — open the file in Design Mode (Shift+D) and relaunch the plugin.",
  reachable: "Bridge reachable and readable.",
};

/**
 * PURE. Turn probe inputs into a verdict.
 * @param {{relayReachable:boolean, bridges:Array|null, ping:object|null, channel:string|null, error?:string}} input
 * @returns {{status:string, reachable:boolean, writable:boolean, channel:string|null,
 *            editorType:string|null, fileName:string|null, hint:string, error?:string}}
 */
export function classifyHealth(input) {
  const { relayReachable, bridges, ping, channel } = input;
  const base = { channel: channel || null, editorType: null, fileName: null, error: input.error };

  if (!relayReachable) {
    return { ...base, status: "no_relay", reachable: false, writable: false, hint: HINTS.no_relay };
  }
  if (!Array.isArray(bridges) || bridges.length === 0) {
    return { ...base, status: "no_bridges", reachable: false, writable: false, hint: HINTS.no_bridges };
  }
  if (!ping) {
    return { ...base, status: "relay_only", reachable: false, writable: false, hint: HINTS.relay_only };
  }
  const editorType = ping.editorType || null;
  const writable = editorType === "figma";
  const status = writable ? "reachable" : "read_only";
  return {
    ...base,
    status,
    reachable: true,
    writable,
    editorType,
    fileName: ping.fileName || null,
    currentPage: ping.currentPage || null,
    rttMs: ping.rttMs != null ? ping.rttMs : null,
    hint: HINTS[status],
  };
}

// Order candidates writable-first so a live Design-Mode bridge wins over a read-only one.
function orderCandidates(bridges) {
  return bridges.slice().sort((a, b) => (b.editorType === "figma" ? 1 : 0) - (a.editorType === "figma" ? 1 : 0));
}

/**
 * Thin I/O. Discover bridges, ping candidates in writable-first order until
 * one answers, then classify. Returns a verdict (never throws for transport
 * problems — those become a verdict the caller can render).
 */
export async function checkBridge(opts = {}) {
  const discover = opts.discover || discoverBridges;
  const rawPing = opts.ping || ((channel) => wsQuery("ping", {}, { channel, timeoutMs: opts.pingTimeoutMs || 4000, wsUrl: opts.wsUrl }));
  // The plugin returns {error:"unknown command: ping"} as a RESOLVED result
  // (not a rejection) on a pre-`ping` plugin build. Treat anything without
  // ok:true as a failed ping so an un-reimported/old bridge reports
  // relay_only ("relaunch"), not read_only.
  const pingFn = async (channel) => {
    const r = await rawPing(channel);
    if (!r || r.ok !== true) throw new Error(r && r.error ? r.error : "ping did not return ok");
    return r;
  };
  const explicit = opts.channel || process.env.FIGMA_CHANNEL || null;

  let bridges;
  try {
    bridges = await discover({ wsUrl: opts.wsUrl });
  } catch (e) {
    return classifyHealth({ relayReachable: false, bridges: null, ping: null, channel: explicit, error: e.message });
  }

  // Explicit channel: ping it directly, skip discovery candidate selection.
  if (explicit) {
    let ping = null, error;
    const t0 = Date.now();
    try { ping = await pingFn(explicit); if (ping && ping.rttMs == null) ping.rttMs = Date.now() - t0; }
    catch (e) { error = e.message; }
    // A pinged explicit channel proves reachability even if it isn't in the registry.
    const bridgeList = (Array.isArray(bridges) && bridges.length) ? bridges : [{ channel: explicit }];
    return classifyHealth({ relayReachable: true, bridges: bridgeList, ping, channel: explicit, error });
  }

  if (!Array.isArray(bridges) || bridges.length === 0) {
    return classifyHealth({ relayReachable: true, bridges: [], ping: null, channel: null });
  }

  const ordered = orderCandidates(bridges);
  let ping = null, channel = ordered[0].channel, error;
  for (const b of ordered) {
    const t0 = Date.now();
    try { ping = await pingFn(b.channel); if (ping && ping.rttMs == null) ping.rttMs = Date.now() - t0; channel = b.channel; break; }
    catch (e) { error = e.message; }
  }
  return classifyHealth({ relayReachable: true, bridges, ping, channel, error });
}

/**
 * Thin I/O. Resolve the channel a caller should talk on, verified by a live
 * ping. Explicit channel/FIGMA_CHANNEL wins verbatim. Otherwise discovers +
 * pings, preferring a writable bridge. Throws an actionable Error when
 * nothing answers.
 */
export async function resolveLiveChannel(opts = {}) {
  const explicit = opts.channel || process.env.FIGMA_CHANNEL;
  if (explicit) return explicit;
  const v = await checkBridge(opts);
  if (!v.reachable) {
    throw new Error(`No reachable Figma bridge (${v.status}): ${v.hint}`);
  }
  return v.channel;
}
