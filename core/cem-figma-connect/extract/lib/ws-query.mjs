// Adapted from avetta/akg-synapse VSD plugin, itself adapted from cursor-talk-to-figma-mcp (sonnylazuardi, MIT).
// Source: figma-ws/ws-query.lib.mjs
//
// ws-query.mjs — reusable client for the cem-figma-connect extraction bridge.
//
// Architecture:
//   [export.mjs] <-> WS:3055 (extract/relay/socket.ts) <-> ui.html <-> code.js (figma.* Plugin API)
//
// Uses Node's built-in global WebSocket (stable since Node 22) — no "ws" npm
// dependency, keeping extract/ dependency-free like core.

import crypto from "node:crypto";
// resolveLiveChannel is imported lazily inside resolveChannel() to avoid a
// static import cycle (bridge-health.mjs imports wsQuery from this module).

const DEFAULT_WS_URL = process.env.FIGMA_WS_URL || "ws://localhost:3055";
const DEFAULT_TIMEOUT_MS = parseInt(process.env.FIGMA_WS_TIMEOUT || "30000", 10);

function generateId() {
  return crypto.randomUUID();
}

// Memo the auto-resolved channel so a multi-command run (export.mjs makes
// several calls) discovers once, not per call. Short TTL so a plugin
// relaunch (new random channel) is picked up on the next command.
const CHANNEL_TTL_MS = 15000;
let _channelMemo = { channel: null, at: 0 };

async function resolveChannel(opts) {
  // Explicit channel / FIGMA_CHANNEL / export.mjs --channel always wins and
  // is not memoized.
  const explicit = opts.channel || process.env.FIGMA_CHANNEL;
  if (explicit) return explicit;
  const now = Date.now();
  if (_channelMemo.channel && now - _channelMemo.at < CHANNEL_TTL_MS) return _channelMemo.channel;
  // Ping-verified resolution: pick a bridge that actually answers a live
  // ping, not one that merely has a recent `lastSeen` timestamp (which goes
  // stale on an idle bridge).
  const { resolveLiveChannel } = await import("./bridge-health.mjs");
  const channel = await resolveLiveChannel({ wsUrl: opts.wsUrl || DEFAULT_WS_URL });
  _channelMemo = { channel, at: now };
  return channel;
}

/**
 * Send one command to the plugin over the relay and resolve with its result.
 * Rejects on timeout, socket error, or a plugin-side `error` payload.
 */
export async function wsQuery(command, params = {}, opts = {}) {
  const wsUrl = opts.wsUrl || DEFAULT_WS_URL;
  const timeoutMs = opts.timeoutMs || DEFAULT_TIMEOUT_MS;
  // Auto-pairing: discover + pick the writable bridge's channel unless one is given.
  const channel = await resolveChannel({ wsUrl, channel: opts.channel });

  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUrl);
    const timeout = setTimeout(() => {
      ws.close();
      reject(new Error(`Timeout after ${timeoutMs}ms waiting for response to '${command}'`));
    }, timeoutMs);

    let joined = false;
    const pendingId = generateId();

    const sendCommand = () => {
      joined = true;
      process.stderr.write(`[ws] joined channel '${channel}', sending: ${command}\n`);
      ws.send(JSON.stringify({
        type: "message",
        channel,
        id: pendingId,
        message: { id: pendingId, command, params },
      }));
    };

    ws.onopen = () => {
      ws.send(JSON.stringify({ type: "join", channel, id: generateId() }));
    };

    ws.onmessage = (event) => {
      let msg;
      try { msg = JSON.parse(event.data.toString()); } catch (e) { return; }

      // Join confirmation (two observed shapes), then send the command.
      if (!joined && msg.type === "system" &&
          ((typeof msg.message === "string" && msg.message.startsWith("Joined")) ||
            (msg.message && msg.message.result))) {
        sendCommand();
        return;
      }

      // Final result (skip progress updates).
      if (msg.type === "broadcast" && msg.message) {
        const payload = msg.message;
        if (payload.type === "command_progress" || payload.commandType || payload.status) return;
        if (payload.id === pendingId || payload.result !== undefined || payload.error !== undefined) {
          clearTimeout(timeout);
          ws.close();
          if (payload.error) reject(new Error(payload.error));
          else resolve(payload.result !== undefined ? payload.result : payload);
        }
      }
    };

    ws.onerror = () => {
      clearTimeout(timeout);
      reject(new Error(`WebSocket error. Is the bridge running? (bun extract/relay/socket.ts + plugin "Start WS Bridge")`));
    };

    ws.onclose = () => clearTimeout(timeout);
  });
}

/**
 * Reachability probe for source selection. Sends a real cheap command
 * (get_document_info) and resolves true ONLY if the PLUGIN answers within
 * `timeoutMs`. Joining the relay is not enough — the relay (socket.ts) can
 * be up with no plugin panel attached, which would make the caller pick WS
 * and then hang on the first real command.
 */
export async function wsIsRunning(opts = {}) {
  const timeoutMs = opts.timeoutMs || 5000;
  try {
    await wsQuery("get_document_info", {}, { ...opts, timeoutMs });
    return true;
  } catch (e) {
    return false;
  }
}
