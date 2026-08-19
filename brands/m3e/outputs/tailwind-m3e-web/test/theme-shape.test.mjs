import { describe, it, expect } from "vitest";
import { readFile } from "node:fs/promises";
import { readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const SRC = join(dirname(fileURLToPath(import.meta.url)), "..", "src");

const SPEC_ROLES = [
  "primary", "on-primary", "primary-container", "on-primary-container",
  "secondary", "on-secondary", "secondary-container", "on-secondary-container",
  "tertiary", "on-tertiary", "tertiary-container", "on-tertiary-container",
  "error", "on-error", "error-container", "on-error-container",
  "surface", "on-surface", "surface-variant", "on-surface-variant",
  "surface-dim", "surface-bright", "surface-tint",
  "surface-container-lowest", "surface-container-low", "surface-container",
  "surface-container-high", "surface-container-highest",
  "outline", "outline-variant",
  "inverse-surface", "inverse-on-surface", "inverse-primary",
  "background", "on-background", "shadow", "scrim",
];

const SPEC_PALETTES = ["primary", "secondary", "tertiary", "error", "neutral", "neutral-variant"];
const SPEC_TONES = [10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100];

const EXTENDED_ROLES = ["success", "info", "warning"];

describe("theme.css references every sys var", () => {
  it("every --md-sys-* declared in sys/*.css appears as a var() reference in theme.css", async () => {
    const themeCss = await readFile(join(SRC, "theme.css"), "utf8");
    const sysFiles = readdirSync(join(SRC, "sys")).filter((f) => f.endsWith(".css"));

    // Vars deliberately not surfaced as theme keys (documented in theme.css):
    const SKIP = new Set([
      // density + state — see NOTE comment in theme.css
      "--md-sys-density-scale",
      "--md-sys-density-size",
      "--md-sys-state-focus-state-layer-opacity",
      "--md-sys-state-hover-state-layer-opacity",
      "--md-sys-state-pressed-state-layer-opacity",
      // shape `corner-value-*` are internal canonical inputs (referenced via the public corner-* names):
      // matched below by name prefix
    ]);

    for (const file of sysFiles) {
      const css = await readFile(join(SRC, "sys", file), "utf8");
      // Match left-hand-side declarations: lines like `  --md-sys-color-primary: ...`.
      const declared = [...css.matchAll(/^[ \t]*(--md-sys-[a-z0-9\-]+)\s*:/gm)].map((m) => m[1]);
      for (const v of declared) {
        if (SKIP.has(v)) continue;
        if (/^--md-sys-shape-corner-value-/.test(v)) continue; // canonical inputs
        expect(themeCss, `${file}: ${v}`).toContain(`var(${v})`);
      }
    }
  });
});

describe("theme.css strict M3 surface", () => {
  it("declares every spec semantic role exactly once", async () => {
    const css = await readFile(join(SRC, "theme.css"), "utf8");
    for (const role of SPEC_ROLES) {
      const re = new RegExp(`--color-${role}\\s*:`, "g");
      const matches = css.match(re) || [];
      expect(matches.length, `--color-${role}`).toBe(1);
    }
  });

  it("declares every spec palette × tone combination", async () => {
    const css = await readFile(join(SRC, "theme.css"), "utf8");
    for (const palette of SPEC_PALETTES) {
      for (const tone of SPEC_TONES) {
        const re = new RegExp(`--color-${palette}-${tone}\\s*:`);
        expect(css, `${palette}-${tone}`).toMatch(re);
      }
    }
  });

  it("does NOT declare extended roles (success/info/warning) — those go in roles-extended.css", async () => {
    const css = await readFile(join(SRC, "theme.css"), "utf8");
    expect(css).not.toMatch(/--color-success\b/);
    expect(css).not.toMatch(/--color-info\b/);
    expect(css).not.toMatch(/--color-warning\b/);
  });
});

describe("roles-extended.css opt-in surface", () => {
  it("declares success/info/warning roles + tonal namespaces", async () => {
    const css = await readFile(join(SRC, "roles-extended.css"), "utf8");
    for (const role of EXTENDED_ROLES) {
      expect(css).toMatch(new RegExp(`--color-${role}\\s*:`));
      expect(css).toMatch(new RegExp(`--color-on-${role}\\s*:`));
      expect(css).toMatch(new RegExp(`--color-${role}-container\\s*:`));
      expect(css).toMatch(new RegExp(`--color-${role}-40\\s*:`));
      expect(css).toMatch(new RegExp(`--color-${role}-95\\s*:`));
    }
  });
});
