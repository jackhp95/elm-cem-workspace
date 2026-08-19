// Adapted from avetta/akg-synapse VSD plugin, itself adapted from cursor-talk-to-figma-mcp (sonnylazuardi, MIT).
// Source: figma-ws/bridge-select.lib.mjs
//
// bridge-select.mjs — pure selection logic for caller auto-pairing.
//
// The relay keeps a registry of live plugin bridges; this picks the one the
// caller should talk to. Rules, in order:
//   1. drop bridges not seen within maxAgeMs (stale / lingering sockets)
//   2. keep only writable contexts (editorType === "figma"; "dev" is read-only
//      — Dev-Mode bridges are rejected as non-writable here on purpose, see
//      extract/README.md)
//   3. if several remain, pick the most-recently-seen and flag ambiguous
//
// Pure + deterministic so it can be unit-tested without a relay or Figma.

const DEFAULT_MAX_AGE_MS = 15_000;

/**
 * @param {Array<{channel:string, editorType:string, fileName?:string, lastSeen:number}>} bridges
 * @param {{now?:number, maxAgeMs?:number}} [opts]
 * @returns {{ok:true, channel:string, bridge:object, ambiguous:boolean}
 *          | {ok:false, reason:"no_bridges"|"all_stale"|"no_writable"}}
 */
export function selectWritableBridge(bridges, opts = {}) {
  const now = typeof opts.now === "number" ? opts.now : Date.now();
  const maxAgeMs = typeof opts.maxAgeMs === "number" ? opts.maxAgeMs : DEFAULT_MAX_AGE_MS;

  const list = Array.isArray(bridges) ? bridges : [];
  if (list.length === 0) return { ok: false, reason: "no_bridges" };

  const fresh = list.filter((b) => b && typeof b.lastSeen === "number" && now - b.lastSeen <= maxAgeMs);
  if (fresh.length === 0) return { ok: false, reason: "all_stale" };

  const writable = fresh.filter((b) => b.editorType === "figma");
  if (writable.length === 0) return { ok: false, reason: "no_writable" };

  // Most-recently-seen first; that's the bridge the user most likely just launched.
  const sorted = writable.slice().sort((a, b) => b.lastSeen - a.lastSeen);
  return { ok: true, channel: sorted[0].channel, bridge: sorted[0], ambiguous: writable.length > 1 };
}
