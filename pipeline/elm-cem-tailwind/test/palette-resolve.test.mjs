import { describe, it, expect } from "vitest";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { converter, formatHex } from "culori";

const ROOT = dirname(fileURLToPath(import.meta.url));
const SRC = join(ROOT, "..", "src");

/* Resolve --md-ref-palette-primary-N for the M3 default seed by computing
   oklch(<L> c h) where L comes from the calibrated table and (c, h) come
   from the seed itself. We don't run a browser — we approximate the
   relative-color expansion in JS. */
async function resolvePrimaryHex(tone) {
  const toneTable = await readFile(join(SRC, "ref/_tone-table.css"), "utf8");
  const L = parseFloat(toneTable.match(new RegExp(`--_md-tone-${tone}-rich:\\s*([\\d.]+)%`))[1]);
  const seed = "#6750a4";
  const oklch = converter("oklch")(seed);
  const out = converter("oklch")({ mode: "oklch", l: L / 100, c: oklch.c, h: oklch.h });
  return formatHex({ ...out, mode: "oklch" });
}

describe("ref palette resolution under default seed", () => {
  it("primary-40 lies in the violet/indigo range", async () => {
    const hex = await resolvePrimaryHex(40);
    // M3 default seed #6750a4 is violet. Tone 40 should be a darker violet.
    // We assert R ≈ G < B (violet has elevated blue) and brightness ~40%.
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    expect(b).toBeGreaterThan(r);
    expect(b).toBeGreaterThan(g);
    const brightness = (r + g + b) / (3 * 255);
    expect(brightness).toBeGreaterThan(0.2);
    expect(brightness).toBeLessThan(0.55);
  });

  it("primary-95 is much lighter than primary-40", async () => {
    const dark = await resolvePrimaryHex(40);
    const light = await resolvePrimaryHex(95);
    const luma = (hex) => {
      const r = parseInt(hex.slice(1, 3), 16);
      const g = parseInt(hex.slice(3, 5), 16);
      const b = parseInt(hex.slice(5, 7), 16);
      return r + g + b;
    };
    expect(luma(light)).toBeGreaterThan(luma(dark) + 300);
  });
});
