import { describe, it, expect } from "vitest";
import { execFile } from "node:child_process";
import { readFile, mkdtemp } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import { promisify } from "node:util";
import { tmpdir } from "node:os";

const execFileP = promisify(execFile);
const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");

describe("compile smoke test", () => {
  it("tailwindcss CLI compiles the sample and emits expected utilities", async () => {
    const dir = await mkdtemp(join(tmpdir(), "tw-m3e-"));
    const out = join(dir, "out.css");
    const input = join(ROOT, "test", "fixtures", "sample.css");

    await execFileP(
      "pnpm",
      ["exec", "tailwindcss", "-i", input, "-o", out],
      { cwd: ROOT, timeout: 30_000 }
    );

    const css = await readFile(out, "utf8");

    // Spec roles
    expect(css).toMatch(/\.bg-primary\s*\{/);
    expect(css).toMatch(/\.text-on-primary\s*\{/);

    // Extended roles
    expect(css).toMatch(/\.bg-success\s*\{/);
    expect(css).toMatch(/\.bg-info-90\s*\{/);
    expect(css).toMatch(/\.bg-warning\s*\{/);

    // Shape + motion + elevation
    expect(css).toMatch(/\.rounded-md-corner-medium\s*\{/);
    expect(css).toMatch(/\.ease-standard\s*\{/);
    expect(css).toMatch(/\.duration-short-2\s*\{/);
    expect(css).toMatch(/\.shadow-md-level1\s*\{/);

    // Surface
    expect(css).toMatch(/\.bg-surface\s*\{/);
    expect(css).toMatch(/\.text-on-surface\s*\{/);

    // Component utility (--m3e-* setter)
    expect(css).toMatch(/\.m3e-button-container-color-primary\s*\{/);

    // Density scope utility — sets --md-sys-density-scale on a subtree.
    expect(css).toMatch(/\.density-2\s*\{/);
    expect(css).toMatch(/--md-sys-density-scale:\s*-2/);
  }, 60_000);
});
