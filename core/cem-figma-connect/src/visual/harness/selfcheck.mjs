// Determinism self-check for the render harness (task C1's verify step).
//
// Renders m3e-button (filled) and m3e-switch (checked) 3x EACH IN SEPARATE
// PROCESSES (a fresh `node capture.mjs` child per sample -> fresh chromium
// launch each time, matching the 2026-07-10 spike's methodology of 3 fully
// separate `playwright test` invocations) and sha256-compares each trio.
//
// Prints "button: stable (3/3)" / "switch: stable (3/3)" and exits 0 when
// every sample in a trio is byte-identical; prints a mismatch report and
// exits nonzero otherwise. Determinism is the whole point of this harness —
// a mismatch is a real bug to investigate, not something to paper over.
import { createHash } from "node:crypto";
import { fileURLToPath } from "node:url";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";

const execFileAsync = promisify(execFile);
const harnessDir = path.dirname(fileURLToPath(import.meta.url));
const captureScript = path.join(harnessDir, "capture.mjs");

const SAMPLES = [
  {
    name: "button",
    args: ["--profile=m3-kit", "--tag=m3e-button", "--attr.variant=filled", "--text=Label"],
  },
  {
    // m3e-switch's on/off attribute is `checked` (CheckedMixin), NOT `selected`
    // as in Material Web's md-switch — see research/evidence/07-render-harness-notes.md
    // gotcha #5. `selected` is silently ignored (renders unselected).
    name: "switch",
    args: ["--profile=m3-kit", "--tag=m3e-switch", "--attr.checked="],
  },
];

async function renderOnceInSubprocess(sample, runIndex, tmpDir) {
  const outPath = path.join(tmpDir, `${sample.name}-run${runIndex}.png`);
  await execFileAsync(process.execPath, [captureScript, ...sample.args, `--out=${outPath}`]);
  const buffer = await fs.readFile(outPath);
  return createHash("sha256").update(buffer).digest("hex");
}

async function checkSample(sample, tmpDir) {
  const hashes = [];
  for (let i = 1; i <= 3; i++) {
    hashes.push(await renderOnceInSubprocess(sample, i, tmpDir));
  }
  const stable = hashes.every((h) => h === hashes[0]);
  return { name: sample.name, hashes, stable };
}

async function main() {
  const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), "cem-figma-connect-selfcheck-"));
  let allStable = true;
  try {
    for (const sample of SAMPLES) {
      const result = await checkSample(sample, tmpDir);
      if (result.stable) {
        console.log(`${result.name}: stable (3/3)`);
      } else {
        allStable = false;
        console.error(`${result.name}: UNSTABLE — hashes differ across runs:`);
        result.hashes.forEach((h, i) => console.error(`  run${i + 1}: ${h}`));
      }
    }
  } finally {
    await fs.rm(tmpDir, { recursive: true, force: true });
  }
  process.exit(allStable ? 0 : 1);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
