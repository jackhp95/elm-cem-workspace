import { describe, it, expect } from "vitest";
import { findPrivateVars, verifyAgainstM3e, resolveM3eDist } from "../bin/check-privates.mjs";
import { existsSync } from "node:fs";
import { join } from "node:path";

describe("check-privates", () => {
  it("findPrivateVars extracts --_* vars from a CSS block", () => {
    const css = `
      @utility m3e-_foo-* { --_foo: --value([color]); }
      @utility m3e-_bar-* { --_bar: --value([length]); }
      @utility m3e-button-* { --m3e-button-x: --value([color]); }  /* public, skipped */
    `;
    expect(findPrivateVars(css)).toEqual(["--_bar", "--_foo"]);
  });

  it("verifyAgainstM3e reports missing privates", () => {
    const declared = ["--_does-not-exist", "--_also-missing"];
    const installedSource = "/* m3e source */ .foo { --_real-private: 1px; }";
    const missing = verifyAgainstM3e(declared, installedSource);
    expect(missing).toEqual(["--_does-not-exist", "--_also-missing"]);
  });

  it("verifyAgainstM3e returns empty when all declared privates exist upstream", () => {
    const declared = ["--_foo"];
    const installedSource = ".x { --_foo: red; }";
    expect(verifyAgainstM3e(declared, installedSource)).toEqual([]);
  });

  it("resolveM3eDist locates @m3e/web's dist via the module resolver (hoist-agnostic)", () => {
    // Regression for #1: the old code hardcoded
    //   <package>/node_modules/@m3e/web/dist
    // which does not exist when @m3e/web is hoisted to the consumer's top-level
    // node_modules (or under pnpm's virtual store). resolveM3eDist() must find
    // the real dist dir wherever the resolver puts it, and it must contain the
    // manifest the bin reads.
    const dist = resolveM3eDist();
    expect(dist).toBeTruthy();
    expect(existsSync(join(dist, "core.js"))).toBe(true);
    expect(existsSync(join(dist, "custom-elements.json"))).toBe(true);
    // Must NOT be the naive nested path that breaks under hoisting.
    expect(dist).not.toMatch(/node_modules[/\\]tailwind-m3e-web[/\\]node_modules/);
  });
});
