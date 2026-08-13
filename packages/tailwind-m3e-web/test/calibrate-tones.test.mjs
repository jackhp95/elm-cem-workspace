import { describe, it, expect } from "vitest";
import { calibrate, emitCss } from "../bin/calibrate-tones.mjs";

describe("calibrate-tones", () => {
  it("produces 12 tones × 2 chroma profiles", () => {
    const result = calibrate();
    // 12 tones from M3 spec: 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100
    expect(Object.keys(result.rich)).toHaveLength(12);
    expect(Object.keys(result.neutral)).toHaveLength(12);
  });

  it("L values are monotonic ascending in tone for both profiles", () => {
    const result = calibrate();
    const tones = [10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100];
    for (const profile of ["rich", "neutral"]) {
      for (let i = 1; i < tones.length; i++) {
        expect(result[profile][tones[i]], `${profile} ${tones[i]} > ${tones[i - 1]}`).toBeGreaterThan(result[profile][tones[i - 1]]);
      }
    }
  });

  // NOTE: The brief specified [8, 18] for tone 10, but HCT tone 10 (L*≈10 in
  // CIELAB) maps to ~22–23% OKLCH L — not 8–18%. OKLCH and CIELAB lightness
  // are not interchangeable; the brief conflated them. The correct range for
  // HCT tone 10 → OKLCH L is approximately [18, 27].
  it("tone 10 falls in [18, 27] L%, tone 90 falls in [85, 95] L%", () => {
    const { rich } = calibrate();
    expect(rich[10]).toBeGreaterThanOrEqual(18);
    expect(rich[10]).toBeLessThanOrEqual(27);
    expect(rich[90]).toBeGreaterThanOrEqual(85);
    expect(rich[90]).toBeLessThanOrEqual(95);
  });

  it("emitCss output matches snapshot", () => {
    const css = emitCss(calibrate());
    expect(css).toMatchSnapshot();
  });
});
