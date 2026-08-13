import { describe, it, expect } from "vitest";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { converter, wcagContrast } from "culori";

/*
 * Headless WCAG-contrast smoke test for the default seed (#8, #5).
 *
 * We don't run a browser; we approximate the CSS cascade in JS:
 *   1. ref palette tone = oklch(<L from tone table> <chroma> <hue>) where
 *      chroma/hue come from the seed (rich profile) or are collapsed (neutral).
 *   2. sys roles pick a tone per scheme via light-dark(), some with a
 *      `calc(l ± n)` nudge — mirrored from src/sys/color.css.
 *   3. assert wcagContrast(fg, bg) meets the relevant threshold.
 *
 * This is an approximation of the browser's relative-color math (same approach
 * as palette-resolve.test.mjs) — treat the thresholds as guard-rails, not
 * pixel-exact spec values.
 */

const SRC = join(dirname(fileURLToPath(import.meta.url)), "..", "src");
const toOklch = converter("oklch");

const SEED_PRIMARY = "#6750a4";
const SEED_ERROR = "#b3261e";

let toneTable;
async function L(tone, profile = "rich") {
  toneTable ??= await readFile(join(SRC, "ref/_tone-table.css"), "utf8");
  const m = toneTable.match(new RegExp(`--_m3e-tone-${tone}-${profile}:\\s*([\\d.]+)%`));
  return parseFloat(m[1]) / 100;
}

/** Rich palette tone (primary/error): seed chroma + hue, tone-table L. */
async function rich(seed, tone) {
  const s = toOklch(seed);
  return { mode: "oklch", l: await L(tone, "rich"), c: s.c, h: s.h };
}
/** Neutral palette tone: chroma collapsed to 0.01, neutral-profile L. */
async function neutral(seed, tone, chroma = 0.01) {
  const s = toOklch(seed);
  return { mode: "oklch", l: await L(tone, "neutral"), c: chroma, h: s.h };
}
/** Apply a `calc(l ± delta)` nudge (delta in 0–1 L units). */
const nudge = (color, delta) => ({ ...color, l: color.l + delta });

describe("WCAG contrast under the default seed", () => {
  it("primary text pairs meet 4.5:1 (light + dark)", async () => {
    // Light: primary=40 / on-primary=100 ; Dark: primary=80 / on-primary=20.
    const lightBg = await rich(SEED_PRIMARY, 40);
    const lightFg = await rich(SEED_PRIMARY, 100);
    const darkBg = await rich(SEED_PRIMARY, 80);
    const darkFg = await rich(SEED_PRIMARY, 20);
    expect(wcagContrast(lightFg, lightBg), "light primary/on-primary").toBeGreaterThanOrEqual(4.5);
    expect(wcagContrast(darkFg, darkBg), "dark primary/on-primary").toBeGreaterThanOrEqual(4.5);
  });

  it("error text pairs meet 4.5:1 (light + dark)", async () => {
    const lightBg = await rich(SEED_ERROR, 40);
    const lightFg = await rich(SEED_ERROR, 100);
    const darkBg = await rich(SEED_ERROR, 80);
    const darkFg = await rich(SEED_ERROR, 20);
    expect(wcagContrast(lightFg, lightBg), "light error/on-error").toBeGreaterThanOrEqual(4.5);
    expect(wcagContrast(darkFg, darkBg), "dark error/on-error").toBeGreaterThanOrEqual(4.5);
  });

  it("body text on surface meets 4.5:1 (light + dark)", async () => {
    // --surface light = neutral-99 (l-0.01); dark = neutral-10 (l-0.04).
    // --on-surface light = neutral-10 ; dark = neutral-90.
    const lightSurface = nudge(await neutral(SEED_PRIMARY, 99), -0.01);
    const lightOn = await neutral(SEED_PRIMARY, 10);
    const darkSurface = nudge(await neutral(SEED_PRIMARY, 10), -0.04);
    const darkOn = await neutral(SEED_PRIMARY, 90);
    expect(wcagContrast(lightOn, lightSurface), "light on-surface/surface").toBeGreaterThanOrEqual(4.5);
    expect(wcagContrast(darkOn, darkSurface), "dark on-surface/surface").toBeGreaterThanOrEqual(4.5);
  });

  it("on-surface-variant meets 4.5:1 against surface-container (light + dark)", async () => {
    // on-surface-variant: light = neutral-variant-30, dark = neutral-variant-80 (chroma 0.025).
    // surface-container: light = neutral-95 (l-0.01), dark = neutral-10 (l+0.02).
    const lightFg = await neutral(SEED_PRIMARY, 30, 0.025);
    const lightBg = nudge(await neutral(SEED_PRIMARY, 95), -0.01);
    const darkFg = await neutral(SEED_PRIMARY, 80, 0.025);
    const darkBg = nudge(await neutral(SEED_PRIMARY, 10), 0.02);
    expect(wcagContrast(lightFg, lightBg), "light on-surface-variant/surface-container").toBeGreaterThanOrEqual(4.5);
    expect(wcagContrast(darkFg, darkBg), "dark on-surface-variant/surface-container").toBeGreaterThanOrEqual(4.5);
  });
});
