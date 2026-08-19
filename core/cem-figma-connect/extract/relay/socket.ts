#!/usr/bin/env bun
/**
 * socket.ts — WebSocket relay server for the cem-figma-connect extraction bridge.
 *
 * Adapted from avetta/akg-synapse VSD plugin, itself adapted from cursor-talk-to-figma-mcp (sonnylazuardi, MIT).
 * Source: figma-ws/socket.ts
 * https://github.com/sonnylazuardi/cursor-talk-to-figma-mcp
 *
 * Channels-based relay: any client that joins a channel can receive messages
 * broadcast by other clients on the same channel.
 *
 * Figma side:  extract/plugin/ — "Start WS Bridge" (self-hosted, no community
 *              plugin needed; see extract/plugin/ui.html)
 * Script side: extract/export.mjs (via extract/lib/ws-query.mjs)
 *
 * REQUIRES BUN — Bun.serve() has no Node equivalent used here. Start with:
 *   mise use -g bun
 *   bun extract/relay/socket.ts
 */

import { Server, ServerWebSocket } from "bun";

// Store clients by channel
const channels = new Map<string, Set<ServerWebSocket<any>>>();

// Bridge registry — auto-pairing support.
// A "bridge" is a plugin instance (role:"bridge"); a "client" is a caller
// (export.mjs). We keep at most ONE live bridge per channel (single-bridge-
// per-channel lock) so a caller's command can never race a stale/duplicate
// plugin instance. Callers discover writable bridges via the `list_bridges`
// query and pick the one with editorType==="figma" (see
// extract/lib/bridge-select.mjs).
interface BridgeMeta {
  channel: string;
  editorType: string;   // "figma" = Design Mode (writable) · "dev" = read-only
  fileName: string;
  lastSeen: number;     // epoch ms; refreshed on every message from the bridge
}
const bridgeByChannel = new Map<string, ServerWebSocket<any>>();
const bridgeMeta = new Map<ServerWebSocket<any>, BridgeMeta>();

function touchBridge(ws: ServerWebSocket<any>) {
  const meta = bridgeMeta.get(ws);
  if (meta) meta.lastSeen = Date.now();
}

function dropBridge(ws: ServerWebSocket<any>) {
  const meta = bridgeMeta.get(ws);
  if (!meta) return;
  bridgeMeta.delete(ws);
  if (bridgeByChannel.get(meta.channel) === ws) {
    bridgeByChannel.delete(meta.channel);
    console.log(`✗ Bridge left channel "${meta.channel}" (lock released)`);
  }
}

function handleConnection(ws: ServerWebSocket<any>) {
  // Don't add to clients immediately - wait for channel join
  console.log("New client connected");

  // Send welcome message to the new client
  ws.send(JSON.stringify({
    type: "system",
    message: "Please join a channel to start chatting",
  }));

  ws.close = () => {
    console.log("Client disconnected");

    // Remove client from their channel
    channels.forEach((clients, channelName) => {
      if (clients.has(ws)) {
        clients.delete(ws);

        // Notify other clients in same channel
        clients.forEach((client) => {
          if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify({
              type: "system",
              message: "A user has left the channel",
              channel: channelName
            }));
          }
        });
      }
    });
  };
}

// Port is configurable so you can run several relays at once (one per
// bridge): bun socket.ts → :3055 (default), FIGMA_WS_PORT=3056 bun socket.ts.
// The plugin manifest currently allow-lists only 3055 (extract/plugin/manifest.json)
// — bump it there too if you need a second port.
const PORT = Number(process.env.FIGMA_WS_PORT) || 3055;

const server = Bun.serve({
  port: PORT,
  hostname: "0.0.0.0",  // bind IPv4 explicitly (Figma desktop may connect via 127.0.0.1)
  fetch(req: Request, server: Server) {
    // Private Network Access preflight — Chrome sends this before allowing
    // a web-origin (e.g. Figma plugin iframe) to connect to localhost.
    // Must respond with Access-Control-Allow-Private-Network: true.
    const pnaHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization",
      "Access-Control-Allow-Private-Network": "true",
    };

    if (req.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: pnaHeaders });
    }

    // Handle WebSocket upgrade — include PNA header in the 101 response
    const success = server.upgrade(req, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Private-Network": "true",
      },
    });

    if (success) {
      return; // Upgraded to WebSocket
    }

    // Regular HTTP response (health check / non-WS)
    return new Response("cem-figma-connect extraction relay running", { headers: pnaHeaders });
  },
  websocket: {
    open: handleConnection,
    message(ws: ServerWebSocket<any>, message: string | Buffer) {
      try {
        const data = JSON.parse(message as string);

        if (data.type === "join") {
          const channelName = data.channel;
          if (!channelName || typeof channelName !== "string") {
            ws.send(JSON.stringify({
              type: "error",
              message: "Channel name is required"
            }));
            return;
          }

          // Role-aware join. The plugin announces role:"bridge" +
          // meta{editorType,fileName}; export.mjs omits role (treated as
          // "client"). At most ONE live bridge per channel.
          const role = data.role === "bridge" ? "bridge" : "client";
          if (role === "bridge") {
            const existing = bridgeByChannel.get(channelName);
            if (existing && existing !== ws && existing.readyState === WebSocket.OPEN) {
              console.log(`⚠️  Rejecting duplicate bridge on channel "${channelName}" (already locked)`);
              ws.send(JSON.stringify({
                type: "channel_busy",
                message: `Channel "${channelName}" already has a live bridge. Pick another channel.`,
                channel: channelName,
                id: data.id,
              }));
              return;
            }
            const meta = data.meta || {};
            bridgeByChannel.set(channelName, ws);
            bridgeMeta.set(ws, {
              channel: channelName,
              editorType: typeof meta.editorType === "string" ? meta.editorType : "unknown",
              fileName: typeof meta.fileName === "string" ? meta.fileName : "",
              lastSeen: Date.now(),
            });
            console.log(`🔒 Bridge locked channel "${channelName}" (editorType=${meta.editorType}, file="${meta.fileName}")`);
          }

          // Create channel if it doesn't exist
          if (!channels.has(channelName)) {
            channels.set(channelName, new Set());
          }

          // Add client to channel
          const channelClients = channels.get(channelName)!;
          channelClients.add(ws);

          console.log(`✓ Client joined channel "${channelName}" (${channelClients.size} total clients, role=${role})`);

          // Notify client they joined successfully
          ws.send(JSON.stringify({
            type: "system",
            message: `Joined channel: ${channelName}`,
            channel: channelName
          }));

          // Notify other clients in channel
          channelClients.forEach((client) => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
              client.send(JSON.stringify({
                type: "system",
                message: "A new user has joined the channel",
                channel: channelName
              }));
            }
          });
          return;
        }

        // Discovery query — a caller asks for the live bridge registry so it
        // can auto-select the writable one. Works without joining any channel.
        if (data.type === "list_bridges") {
          const list: BridgeMeta[] = [];
          bridgeByChannel.forEach((sock, ch) => {
            if (sock.readyState !== WebSocket.OPEN) return;
            const meta = bridgeMeta.get(sock);
            if (meta) list.push({ ...meta });
          });
          ws.send(JSON.stringify({ type: "bridges", id: data.id, bridges: list }));
          return;
        }

        // Handle regular messages
        if (data.type === "message") {
          const channelName = data.channel;
          if (!channelName || typeof channelName !== "string") {
            ws.send(JSON.stringify({
              type: "error",
              message: "Channel name is required"
            }));
            return;
          }

          const channelClients = channels.get(channelName);
          if (!channelClients || !channelClients.has(ws)) {
            ws.send(JSON.stringify({
              type: "error",
              message: "You must join the channel first"
            }));
            return;
          }

          // A message from the locked bridge proves it's alive — refresh lastSeen.
          touchBridge(ws);

          // Broadcast to all OTHER clients in the channel (not the sender)
          // This prevents echo and ensures proper request-response flow
          let broadcastCount = 0;
          channelClients.forEach((client) => {
            if (client !== ws && client.readyState === WebSocket.OPEN) {
              broadcastCount++;
              client.send(JSON.stringify({
                type: "broadcast",
                message: data.message,
                sender: "peer",
                channel: channelName
              }));
            }
          });

          if (broadcastCount === 0) {
            console.log(`⚠️  No other clients in channel "${channelName}" to receive message!`);
          }
        }
      } catch (err) {
        console.error("Error handling message:", err);
      }
    },
    close(ws: ServerWebSocket<any>) {
      // Release the bridge lock if this socket held one
      dropBridge(ws);
      // Remove client from their channel
      channels.forEach((clients) => {
        clients.delete(ws);
      });
    }
  }
});

console.log(`cem-figma-connect extraction relay running on port ${server.port}`);
