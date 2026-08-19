import { test } from "node:test";
import assert from "node:assert/strict";
import { plateTransform, renderFavicon, renderOgSvg, rasterise } from "./brand-images.mjs";

test("places an Iconify-normalised 0 0 24 24 glyph in the plate", () => {
  // scale = 26/24; y in [0,24] -> [0,26], inset 11 -> translate(11 11).
  assert.equal(plateTransform("0 0 24 24", { plate: 48, glyph: 26 }), "translate(11 11) scale(1.0833333)");
});

test("places a raw 0 -960 960 960 glyph in the same plate", () => {
  // scale = 26/960; y in [-960,0] -> [-26,0], so ty = 11 + 26 = 37.
  assert.equal(plateTransform("0 -960 960 960", { plate: 48, glyph: 26 }), "translate(11 37) scale(0.0270833)");
});

test("rejects a non-square viewBox rather than distorting the glyph", () => {
  assert.throws(() => plateTransform("0 0 24 48", { plate: 48, glyph: 26 }), /square/i);
});

test("renders the favicon as a bare currentColor glyph on transparency", () => {
  const svg = renderFavicon({ viewBox: "0 0 24 24", path: "M12 3Z" });
  assert.match(svg, /viewBox="0 0 24 24"/);
  assert.match(svg, /role="img"/);
  assert.match(svg, /aria-label="elm-m3e"/);
  assert.match(svg, /<path fill="currentColor" d="M12 3Z"\/>/);
  // No plate: nothing paints a background.
  assert.doesNotMatch(svg, /<defs/);
  assert.doesNotMatch(svg, /linearGradient/);
  assert.doesNotMatch(svg, /<rect/);
  assert.doesNotMatch(svg, /#FFFFFF/i);
});

test("names a colour only for dark mode, leaving light mode as currentColor", () => {
  // A tab icon renders in an isolated document, so currentColor falls back to
  // black — invisible on dark chrome. The override is scoped to that one case.
  const svg = renderFavicon({ viewBox: "0 0 24 24", path: "M12 3Z" });
  assert.match(svg, /@media \(prefers-color-scheme: dark\) \{ path \{ fill: #E6E0E9 \} \}/);
  // The fill attribute itself is untouched, so light mode inherits as asked.
  assert.match(svg, /fill="currentColor"/);
});

test("carries the glyph's own viewBox through rather than hard-coding a grid", () => {
  // Iconify normalises to 0 0 24 24, but raw Google data is 0 -960 960 960. The
  // favicon needs no transform precisely because it adopts whichever grid the
  // source declares — hard-coding one would push the other off-canvas.
  const svg = renderFavicon({ viewBox: "0 -960 960 960", path: "M12 3Z" });
  assert.match(svg, /viewBox="0 -960 960 960"/);
  assert.doesNotMatch(svg, /transform=/);
});

test("renders the OG card at 1200x630 with a centred glyph and no text", () => {
  const svg = renderOgSvg({ viewBox: "0 0 24 24", path: "M12 3Z" });
  assert.match(svg, /viewBox="0 0 1200 630"/);
  assert.match(svg, /d="M12 3Z"/);
  // Glyph-only: no wordmark, no tagline.
  assert.doesNotMatch(svg, /<text/);
  // 252-unit glyph (40% of 630) centred: tx = (1200-252)/2 = 474, ty = (630-252)/2 = 189.
  assert.match(svg, /transform="translate\(474 189\) scale\(10\.5\)"/);
});

// The OG card is the only artifact still rasterised: the favicon is currentColor,
// which a raster has no CSS context to resolve, so no .ico is generated from it.
test("rasterises the OG SVG to a real PNG of the requested size", () => {
  const png = rasterise(renderOgSvg({ viewBox: "0 0 24 24", path: "M12 3h4v4h-4z" }), 32);
  // PNG magic number.
  assert.deepEqual([...png.subarray(0, 4)], [0x89, 0x50, 0x4e, 0x47]);
  // IHDR width/height are big-endian uint32 at offsets 16 and 20. `fitTo` is
  // width-driven, so the height follows the 1200x630 aspect: 32 * 630/1200 = 17.
  assert.equal(png.readUInt32BE(16), 32);
  assert.equal(png.readUInt32BE(20), 17);
});
