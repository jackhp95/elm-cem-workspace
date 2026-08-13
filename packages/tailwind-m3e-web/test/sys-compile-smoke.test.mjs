import { describe, it, expect } from "vitest";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const SRC = join(dirname(fileURLToPath(import.meta.url)), "..", "src");

describe("sys layer files", () => {
  for (const layer of ["color", "typescale", "motion", "shape", "elevation", "state", "density"]) {
    it(`${layer}.css contains at least one --md-sys-${layer === "color" ? "color" : layer}- var`, async () => {
      const css = await readFile(join(SRC, "sys", `${layer}.css`), "utf8");
      const expected = layer === "color" ? "--md-sys-color-" : `--md-sys-${layer}-`;
      expect(css).toContain(expected);
    });
  }

  it("no file references Avetta selectors", async () => {
    for (const layer of ["color", "typescale", "motion", "shape", "elevation", "state", "density"]) {
      const css = await readFile(join(SRC, "sys", `${layer}.css`), "utf8");
      expect(css).not.toMatch(/avt-|avetta|data-avt|theme-[a-z]/i);
    }
  });

  it("emphasized-title-medium line-height is not the upstream 3.5rem typo — #2", async () => {
    // @m3e/web ships 3.5rem here (3.5x leading on a 1rem font); we diverge to
    // 1.5rem, matching the standard title-medium and the M3 spec (24px).
    const css = await readFile(join(SRC, "sys", "typescale.css"), "utf8");
    const decl = (name) => css.match(new RegExp(`^[ \\t]*${name}\\s*:\\s*([^;]+);`, "m"))?.[1].trim();
    expect(decl("--md-sys-typescale-emphasized-title-medium-line-height")).toBe("1.5rem");
  });

  it("shadow and scrim are opaque (no baked-in alpha) — #8", async () => {
    // M3 / @m3e/web define shadow + scrim as opaque black; alpha is applied at
    // the usage site. A baked rgba() alpha here double-applies against
    // elevation's color-mix and breaks the Tailwind /opacity modifier.
    const css = await readFile(join(SRC, "sys", "color.css"), "utf8");
    const decl = (name) => css.match(new RegExp(`^[ \\t]*${name}\\s*:\\s*([^;]+);`, "m"))?.[1].trim();
    for (const name of ["--shadow", "--scrim"]) {
      expect(decl(name), name).toBe("#000000");
    }
  });
});
