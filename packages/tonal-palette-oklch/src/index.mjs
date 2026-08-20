// index.mjs — HCT tonal palette (MCU) -> OKLCH lightness sampling.
//
// Promoted out of `tailwind-m3e-web/bin/calibrate-tones.mjs` per the
// thermonuclear audit (Theme 6, trapped-generic-modules #3): the color-space
// math here (sample MCU's TonalPalette at a hue/chroma/tone, convert to
// OKLCH, average over hues) has zero Material-3-brand or m3e coupling — any
// caller picks its own hues/tones/chroma buckets. What stayed behind in
// `calibrate-tones.mjs` is genuinely package-specific: the M3-spec chroma
// buckets ("rich"/"neutral"), the fixed 12-hue/12-tone sample grid, and the
// `--_md-tone-*` CSS variable names in its emitted output.
//
// This needed its own package rather than tools/lib/ because it has real npm
// dependencies (@material/material-color-utilities, culori) — every existing
// tools/lib/ module is deliberately zero-dependency plain Node ESM.

import { TonalPalette, hexFromArgb } from "@material/material-color-utilities";
import { converter, parse } from "culori";

const toOklch = converter("oklch");

/** OKLCH lightness (0-100) of MCU's HCT tone `tone` at `hue`/`chroma`. */
export function lForToneAtHue(hue, chroma, tone) {
  const palette = TonalPalette.fromHueAndChroma(hue, chroma);
  const argb = palette.tone(tone);
  const hex = hexFromArgb(argb);
  const oklch = toOklch(parse(hex));
  return oklch.l * 100; // culori returns L in [0,1]; we want percent
}

/**
 * Average OKLCH L (rounded to 2dp) at fixed `chroma`, for each of `tones`,
 * averaged over `hues`. Returns `{ [tone]: number }`.
 */
export function averageLPerTone(chroma, { tones, hues }) {
  const out = {};
  for (const tone of tones) {
    let sum = 0;
    for (const hue of hues) {
      sum += lForToneAtHue(hue, chroma, tone);
    }
    out[tone] = +(sum / hues.length).toFixed(2);
  }
  return out;
}
