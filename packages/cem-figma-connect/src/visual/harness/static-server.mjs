// Minimal dep-free static file server for the render harness. No deps beyond
// node:http/fs/path — this is deliberately NOT esbuild/express/etc.
//
// Needed because Chromium blocks `<script type="module">` from file:// pages
// ("origin 'null' … blocked by CORS policy") — see
// research/evidence/07-render-harness-notes.md gotcha #1. A real (if tiny and
// ephemeral, localhost-only) HTTP server is required to serve page.html/page.mjs.
//
// Serves multiple mounted roots so the harness dir (page.html, page.mjs,
// fonts/) and the gitignored render-cache/ bundle dir can both be reached —
// the latter only matters for the manual `?bundle=/render-cache/...` debug
// hook in page.mjs; capture.mjs's programmatic path injects bundle code
// directly via Playwright's addScriptTag and never fetches it over HTTP.
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".woff2": "font/woff2",
  ".css": "text/css; charset=utf-8",
  ".png": "image/png",
};

/**
 * @param {Array<{ mount: string, dir: string }>} roots Longest `mount` prefix wins.
 *   `dir` must be an absolute, resolved directory path.
 */
export function startServer(roots) {
  const sortedRoots = [...roots].sort((a, b) => b.mount.length - a.mount.length);

  const server = http.createServer((req, res) => {
    const urlPath = decodeURIComponent(new URL(req.url, "http://x").pathname);
    const root = sortedRoots.find(
      (r) => urlPath === r.mount || urlPath.startsWith(r.mount.endsWith("/") ? r.mount : `${r.mount}/`),
    );
    if (!root) {
      res.writeHead(404).end("not found");
      return;
    }
    const relPath = urlPath.slice(root.mount.length);
    const filePath = path.join(root.dir, path.normalize(relPath).replace(/^(\.\.[/\\])+/, ""));
    if (!filePath.startsWith(root.dir) || !fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
      res.writeHead(404).end("not found");
      return;
    }
    res.writeHead(200, {
      "content-type": MIME[path.extname(filePath)] ?? "application/octet-stream",
      "cache-control": "no-store",
    });
    fs.createReadStream(filePath).pipe(res);
  });

  return new Promise((resolve) => {
    server.listen(0, "127.0.0.1", () => {
      resolve({
        baseUrl: `http://127.0.0.1:${server.address().port}`,
        close: () => new Promise((r) => server.close(r)),
      });
    });
  });
}

// Standalone debug mode: `node static-server.mjs` serves this dir + repo-root
// render-cache/ and prints the base URL, for manually opening page.html in a
// real browser (e.g. to eyeball a `?bundle=` debug render).
if (import.meta.url === `file://${process.argv[1]}`) {
  const { fileURLToPath } = await import("node:url");
  const harnessDir = path.dirname(fileURLToPath(import.meta.url));
  const repoRoot = path.join(harnessDir, "..", "..", "..");
  const { baseUrl } = await startServer([
    { mount: "/", dir: harnessDir },
    { mount: "/render-cache", dir: path.join(repoRoot, "render-cache") },
  ]);
  console.log(`harness server listening at ${baseUrl}/page.html`);
}
