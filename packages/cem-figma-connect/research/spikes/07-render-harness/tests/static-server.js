// Minimal static file server for the harness dir. No deps.
// Needed because Chromium blocks <script type="module"> under file:// (opaque-origin CORS).
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".woff2": "font/woff2",
  ".css": "text/css; charset=utf-8",
  ".png": "image/png",
};

export function startServer(rootDir) {
  const server = http.createServer((req, res) => {
    const urlPath = decodeURIComponent(new URL(req.url, "http://x").pathname);
    const filePath = path.join(rootDir, path.normalize(urlPath).replace(/^(\.\.[/\\])+/, ""));
    if (!filePath.startsWith(rootDir) || !fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
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
