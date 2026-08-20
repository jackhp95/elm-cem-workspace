// Minimal static file server for the pre-rendered elm-pages production build
// (`dist/`). Used as the Playwright contract-harness target in CI.
//
// Why not `elm-pages dev`? The dev server cold-compiles the whole 125-route
// app on first request (slow on a 2-core CI runner, blowing the webServer
// boot timeout) and holds a long-lived `/stream` SSE connection open for
// live-reload (so `networkidle` never settles). The production build instead
// pre-renders every route to static HTML that hydrates the same `@m3e/web`
// custom elements — it serves instantly, is deterministic, and is the actual
// artifact we ship, which is exactly what a "runtime contract" harness should
// assert against. No external dependencies: Node's built-in http/fs only.
import http from "node:http";
import { readFile, stat } from "node:fs/promises";
import { extname, join, normalize } from "node:path";
import { resolveWorktreePort } from "./worktree-port.mjs";

const root = process.argv[2] || "dist";
// Falls back to this worktree's derived port (scripts/worktree-port.mjs),
// not a hardcoded one — a fixed fallback here is exactly what let two
// different worktrees' `npm run serve` collide on the same port before.
const port = Number(process.argv[3] || process.env.PORT || resolveWorktreePort());

const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".dat": "application/octet-stream",
  ".woff2": "font/woff2",
  ".woff": "font/woff",
  ".ttf": "font/ttf",
  ".ico": "image/x-icon",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp",
};

async function resolveFile(p) {
  try {
    const s = await stat(p);
    if (s.isFile()) return p;
    if (s.isDirectory()) return resolveFile(join(p, "index.html"));
  } catch {
    /* fall through */
  }
  return null;
}

const server = http.createServer(async (req, res) => {
  const pathname = decodeURIComponent((req.url || "/").split("?")[0]);
  // Prevent path traversal.
  const safe = normalize(pathname).replace(/^(\.\.[/\\])+/, "");
  let file = await resolveFile(join(root, safe));
  // elm-pages routes are pre-rendered as <route>/index.html.
  if (!file) file = await resolveFile(join(root, safe, "index.html"));
  // SPA fallback so client-side routing still resolves.
  if (!file) file = join(root, "index.html");
  try {
    const body = await readFile(file);
    res.writeHead(200, {
      "content-type": TYPES[extname(file)] || "application/octet-stream",
    });
    res.end(body);
  } catch {
    res.writeHead(404, { "content-type": "text/plain" });
    res.end("not found");
  }
});

// A real bind failure here means something ELSE already holds this
// worktree's derived port (a leftover process, or — vanishingly rarely — a
// hash collision with a sibling worktree, see worktree-port.mjs). Fail loud
// instead of the old behaviour of silently reusing/attaching to whatever was
// already there: that silent reuse was the root cause this port-derivation
// scheme replaces.
server.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    console.error(
      `serve-dist: port ${port} (this worktree's derived port) is already in use by another process.\n` +
        `If that process is a stale leftover, the pretest:browser hook (scripts/kill-stale-server.mjs) should have freed it — check what's holding it: lsof -i:${port}\n` +
        `If it's a genuine hash collision with a sibling worktree, set WORKTREE_PORT_SALT=<n> in one of the two worktrees and retry.`,
    );
    process.exit(1);
  }
  throw err;
});

server.listen(port, () => {
  console.log(`static server on http://localhost:${port} serving ${root}/`);
});
