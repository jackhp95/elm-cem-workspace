// esbuild wrapper: bundles a profile's declared harness entry
// (profiles/<profile>/harness.json -> {"entry": "@m3e/web/all"}) into a
// self-contained ESM file, content-hash keyed into the gitignored
// render-cache/bundle/ dir so kit version bumps invalidate automatically —
// no manual cache-busting logic needed, since the hash IS the output content.
import { build } from "esbuild";
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";
import fs from "node:fs/promises";
import path from "node:path";

const harnessDir = path.dirname(fileURLToPath(import.meta.url));
export const repoRoot = path.join(harnessDir, "..", "..", "..");

/**
 * @param {string} profileName e.g. "m3-kit"
 * @returns {Promise<{ entry: string }>}
 */
export async function loadHarnessConfig(profileName) {
  const configPath = path.join(repoRoot, "profiles", profileName, "harness.json");
  const raw = await fs.readFile(configPath, "utf8");
  const config = JSON.parse(raw);
  if (!config.entry) {
    throw new Error(`harness.json for profile "${profileName}" is missing required "entry" field: ${configPath}`);
  }
  return config;
}

/**
 * Bundles the profile's declared entry with esbuild, in memory, then writes
 * it to render-cache/bundle/<sha256-of-output>.js iff that exact file isn't
 * already cached. Returns the cached file's path + code.
 *
 * @param {string} profileName e.g. "m3-kit"
 * @returns {Promise<{ path: string, hash: string, code: string }>}
 */
export async function buildBundle(profileName) {
  const { entry } = await loadHarnessConfig(profileName);

  const result = await build({
    stdin: {
      contents: `import ${JSON.stringify(entry)};`,
      resolveDir: repoRoot,
      loader: "js",
    },
    absWorkingDir: repoRoot,
    bundle: true,
    format: "esm",
    write: false,
    logLevel: "silent",
  });

  const code = result.outputFiles[0].text;
  const hash = createHash("sha256").update(code).digest("hex").slice(0, 16);

  const cacheDir = path.join(repoRoot, "render-cache", "bundle");
  await fs.mkdir(cacheDir, { recursive: true });
  const outPath = path.join(cacheDir, `${hash}.js`);

  try {
    await fs.access(outPath);
  } catch {
    await fs.writeFile(outPath, code);
  }

  return { path: outPath, hash, code };
}

// Standalone mode: `node bundle.mjs m3-kit` builds and prints the cache path.
if (import.meta.url === `file://${process.argv[1]}`) {
  const profileName = process.argv[2] ?? "m3-kit";
  const { path: outPath, hash } = await buildBundle(profileName);
  console.log(`profile "${profileName}" -> ${outPath} (hash ${hash})`);
}
