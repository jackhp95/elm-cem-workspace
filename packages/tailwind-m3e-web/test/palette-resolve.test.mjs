import { describe, it, expect } from "vitest";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { converter, formatHex, differenceCiede2000 } from "culori";

const ROOT = dirname(fileURLToPath(import.meta.url));
const SRC = join(ROOT, "..", "src");

/* Resolve --md-ref-palette-primary-N for the M3 default seed by computing
   oklch(<L> c h) where L comes from the calibrated table and (c, h) come
   from the seed itself. We don't run a browser — we approximate the
   relative-color expansion in JS. */
async function resolvePrimaryHex(tone) {
  const toneTable = await readFile(join(SRC, "ref/_tone-table.css"), "utf8");
  const L = parseFloat(toneTable.match(new RegExp(`--_m3e-tone-${tone}-rich:\\s*([\\d.]+)%`))[1]);
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

/* ── Regression guard: on-*-container light-mode tone assignment ──
   M3's revised spec (and @m3e/web's own baked fallback) put the light-mode
   `on-*-container` roles at tonal-palette tone 30, NOT tone 10. A three-source
   audit (Figma M3 kit vs this library's OKLCH output vs @m3e/web fallback)
   measured a ~15 ciede2000 deltaE regression when these resolved to tone 10.
   These tests lock the correct tone-30 assignment in `src/sys/color.css`. */

/* Resolve --md-ref-palette-<palette>-<tone> for the default seeds, applying the
   same chroma/hue derivation that src/ref/palette.css uses per palette. */
async function resolveRoleHex(palette, tone) {
  const toneTable = await readFile(join(SRC, "ref/_tone-table.css"), "utf8");
  const L = parseFloat(toneTable.match(new RegExp(`--_m3e-tone-${tone}-rich:\\s*([\\d.]+)%`))[1]);
  // Seeds from src/seed.css.
  const SEED_PRIMARY = "#6750a4";
  const SEED_ERROR = "#b3261e";
  const seed = palette === "error" ? SEED_ERROR : SEED_PRIMARY;
  const oklch = converter("oklch")(seed);
  // Per-palette derivation, mirroring src/ref/palette.css.
  const chromaMul = palette === "secondary" ? 0.33 : 1;
  const hueAdd = palette === "tertiary" ? 60 : 0;
  const out = converter("oklch")({
    mode: "oklch",
    l: L / 100,
    c: oklch.c * chromaMul,
    h: (oklch.h ?? 0) + hueAdd,
  });
  return formatHex({ ...out, mode: "oklch" });
}

describe("sys color: on-*-container light-mode tone assignment", () => {
  const PALETTES = ["primary", "secondary", "tertiary", "error"];
  // Figma M3 kit Light-mode reference hexes (design intent).
  const KIT_LIGHT = {
    primary: "#4F378A",
    secondary: "#4A4459",
    tertiary: "#633B48",
    error: "#852221",
  };

  it("references tone 30 (not tone 10) for the light value of every on-*-container role", async () => {
    const css = await readFile(join(SRC, "sys/color.css"), "utf8");
    for (const p of PALETTES) {
      // Capture the light-dark(<light>, <dark>) declaration for this role.
      const re = new RegExp(
        `--md-sys-color-on-${p}-container:\\s*light-dark\\(\\s*var\\(--md-ref-palette-${p}-(\\d+)\\)`,
      );
      const m = css.match(re);
      expect(m, `on-${p}-container declaration not found`).toBeTruthy();
      expect(m[1], `on-${p}-container light tone`).toBe("30");
    }
  });

  it("tone 30 is measurably closer to the Figma M3 kit than tone 10 (ciede2000)", async () => {
    const de = differenceCiede2000();
    for (const p of PALETTES) {
      const t30 = await resolveRoleHex(p, 30);
      const t10 = await resolveRoleHex(p, 10);
      const kit = KIT_LIGHT[p];
      expect(de(t30, kit), `${p}: tone30 vs kit should beat tone10`).toBeLessThan(de(t10, kit));
    }
  });

  it("tone 30 matches the kit within tolerance for the un-diverged palettes (primary, secondary)", async () => {
    const de = differenceCiede2000();
    // tertiary/error carry a separate, documented derivation-model divergence,
    // so only primary/secondary are asserted against a tight perceptual bound.
    for (const p of ["primary", "secondary"]) {
      const t30 = await resolveRoleHex(p, 30);
      expect(de(t30, KIT_LIGHT[p]), `${p}-30 vs kit`).toBeLessThan(3);
    }
  });
});
