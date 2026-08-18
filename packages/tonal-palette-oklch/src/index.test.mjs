import { test } from "node:test";
import assert from "node:assert/strict";
import { lForToneAtHue, averageLPerTone } from "./index.mjs";

const TONES = [10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100];
const HUES = [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330];

test("lForToneAtHue returns a percentage in [0, 100]", () => {
  for (const hue of HUES) {
    const l = lForToneAtHue(hue, 40, 50);
    assert.ok(l >= 0 && l <= 100, `hue ${hue} gave L=${l}`);
  }
});

test("averageLPerTone returns one entry per requested tone", () => {
  const out = averageLPerTone(40, { tones: TONES, hues: HUES });
  assert.deepEqual(Object.keys(out).map(Number), TONES);
});

test("averaged L is monotonic ascending in tone (darker tone -> lower L)", () => {
  const out = averageLPerTone(40, { tones: TONES, hues: HUES });
  for (let i = 1; i < TONES.length; i++) {
    assert.ok(
      out[TONES[i]] > out[TONES[i - 1]],
      `tone ${TONES[i]} (${out[TONES[i]]}) should exceed tone ${TONES[i - 1]} (${out[TONES[i - 1]]})`,
    );
  }
});

test("averaging over a single hue matches lForToneAtHue directly", () => {
  const out = averageLPerTone(40, { tones: [50], hues: [180] });
  assert.equal(out[50], +lForToneAtHue(180, 40, 50).toFixed(2));
});
