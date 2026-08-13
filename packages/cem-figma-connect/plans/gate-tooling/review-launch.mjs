// Launches the REAL review UI (src/visual/review/ui.html + server.mjs's exported
// resolveArtifactPath/approve/reject/retarget), but feeds /api/queue the directly-
// built code/Figma/diff records for the 11 representative-example sets (which the
// stock buildQueue excludes by design). Writes go to a SCRATCH overrides copy so
// nothing touches the committed profiles/m3-kit/overrides.json.
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

const REPO = "/Users/jhp/code/jackhp95/cem-figma-connect";
const OUT = path.join(REPO, "render-cache/coverage-review-all");
const UI_HTML = path.join(REPO, "src/visual/review/ui.html");
const CACHE_ROOT = path.join(REPO, "render-cache");
const SCRATCH_OVERRIDES = path.join(path.dirname(new URL(import.meta.url).pathname), "overrides-review-scratch.json");

const { resolveArtifactPath, approve, reject, retarget } = await import(path.join(REPO, "src/visual/review/server.mjs"));

// Sandbox: start the scratch overrides from a copy of the real file so
// approve/reject merges behave realistically without mutating the committed one.
// GUARD: only seed from committed when the scratch does NOT already exist — otherwise a
// server restart wipes accumulated review decisions (learned the hard way). Delete the
// scratch file to force a fresh seed.
if (!fs.existsSync(SCRATCH_OVERRIDES)) fs.copyFileSync(path.join(REPO, "profiles/m3-kit/overrides.json"), SCRATCH_OVERRIDES);

const queue = JSON.parse(fs.readFileSync(path.join(OUT, "items.json"), "utf8"));
// Only surface items still needing review — drop anything already approved / example-verified in
// the (persisted) scratch overrides, so a restart never re-shows sets you've already cleared.
const cleared = new Set(
  JSON.parse(fs.readFileSync(SCRATCH_OVERRIDES, "utf8"))
    .filter((o) => o.gate === "approved" || o.gate === "example-verified")
    .map((o) => o.cemTag)
);
queue.items = queue.items.filter((i) => !cleared.has(i.cemTag));
const actionFor = { approve, reject, retarget };

function sendJson(res, code, body) {
  const t = JSON.stringify(body);
  res.writeHead(code, { "content-type": "application/json; charset=utf-8", "content-length": Buffer.byteLength(t) });
  res.end(t);
}
function readBody(req) {
  return new Promise((resolve) => {
    let d = ""; req.on("data", (c) => (d += c)); req.on("end", () => { try { resolve(d.trim() ? JSON.parse(d) : {}); } catch { resolve({}); } });
  });
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, "http://localhost");
  try {
    if (req.method === "GET" && url.pathname === "/") {
      // Serve the shipped ui.html, but override the checkerboard image background
      // with solid white — the Figma PNGs are transparent, and the checker makes
      // the code-vs-Figma comparison hard to read (per review feedback). Injected
      // here (not in the committed ui.html) so the shipped tool is untouched.
      const html = fs.readFileSync(UI_HTML, "utf8") +
        "\n<style>.images img { background: #fff !important; }</style>\n";
      res.writeHead(200, { "content-type": "text/html; charset=utf-8" });
      res.end(html);
      return;
    }
    if (req.method === "GET" && url.pathname === "/api/queue") { sendJson(res, 200, queue); return; }
    if (req.method === "GET" && url.pathname === "/api/image") {
      const requested = url.searchParams.get("path");
      const resolved = requested ? resolveArtifactPath(CACHE_ROOT, requested) : null;
      if (!resolved || !fs.existsSync(resolved) || !fs.statSync(resolved).isFile()) { res.writeHead(404).end("not found"); return; }
      res.writeHead(200, { "content-type": "image/png", "cache-control": "no-store" });
      fs.createReadStream(resolved).pipe(res);
      return;
    }
    const m = /^\/api\/(approve|reject|retarget)$/.exec(url.pathname);
    if (req.method === "POST" && m) {
      const body = await readBody(req);
      if (!body.cemTag) { sendJson(res, 400, { error: "cemTag is required" }); return; }
      const result = actionFor[m[1]]({ overridesPath: SCRATCH_OVERRIDES, cemTag: body.cemTag, note: body.note });
      sendJson(res, 200, { ...result, queue }); // decisions land in the SCRATCH overrides only
      return;
    }
    res.writeHead(404).end("not found");
  } catch (e) { sendJson(res, 500, { error: e.message }); }
});

server.listen(4747, "127.0.0.1", () => {
  console.log(`REVIEW UI (real ui.html) at http://127.0.0.1:4747`);
  console.log(`  ${queue.items.length} sets · code/Figma/diff · decisions sandboxed to ${SCRATCH_OVERRIDES}`);
});
