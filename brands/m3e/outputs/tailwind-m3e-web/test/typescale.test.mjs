import { describe, it, expect } from "vitest";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const SRC = join(dirname(fileURLToPath(import.meta.url)), "..", "src");

/* Extract a --md-sys-typescale-* value from src/sys/typescale.css, ignoring
   any inline comments on the declaration line. */
async function tracking(name) {
  const css = await readFile(join(SRC, "sys/typescale.css"), "utf8");
  const m = css.match(new RegExp(`--md-sys-typescale-${name}:\\s*(-?[\\d.]+)rem`));
  expect(m, `--md-sys-typescale-${name} not found`).toBeTruthy();
  return parseFloat(m[1]);
}

/* Regression guard for a three-source-audited sign-flip: the Figma M3 kit and
   the public M3 spec both give display-large tracking as -0.25px (-0.015625rem).
   The library previously shipped +0.015625rem (sign-flipped). Exact-match token,
   not a perceptual tolerance. */
describe("typescale: display-large tracking sign", () => {
  it("standard display-large tracking is -0.25px (-0.015625rem), not +0.25px", async () => {
    expect(await tracking("display-large-tracking")).toBeCloseTo(-0.015625, 6);
  });

  it("emphasized display-large tracking matches standard (negative)", async () => {
    expect(await tracking("emphasized-display-large-tracking")).toBeCloseTo(-0.015625, 6);
  });
});
