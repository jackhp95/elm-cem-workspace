import { test } from "node:test";
import assert from "node:assert/strict";
import { generate, resolveIcon } from "./icons-to-js.mjs";

// A minimal fake icon set — no network, no dependency on real Iconify content.
const sets = {
  fake: {
    prefix: "fake",
    width: 24,
    height: 24,
    icons: {
      ok: { body: '<path d="M4 4h16v16H4z"/>' },
      multi: { body: '<path d="M0 0h1v1H0z"/><circle cx="5" cy="5" r="2"/>' },
      twopaths: { body: '<path d="M0 0h1v1H0z"/><path d="M2 2h1v1H2z"/>' },
      badchars: { body: '<path d="M0 0 L1e2 5"/>' },
    },
  },
};

test("resolves a single-path icon to viewBox + path", () => {
  assert.deepEqual(resolveIcon(sets, "fake:ok"), { viewBox: "0 0 24 24", path: "M4 4h16v16H4z" });
});

test("rejects a body with a non-path element, naming the icon and id", () => {
  assert.throws(() => resolveIcon(sets, "fake:multi"), /fake:multi.*single path/is);
});

test("rejects a body with two paths rather than silently keeping the first", () => {
  assert.throws(() => resolveIcon(sets, "fake:twopaths"), /fake:twopaths.*single path/is);
});

test("rejects path data m3e's allowlist would reject at runtime", () => {
  // `e` (scientific notation) is not in PATH_DATA_PATTERN, so addIcon would throw
  // in the browser. Catch it at build time instead.
  assert.throws(() => resolveIcon(sets, "fake:badchars"), /fake:badchars.*path data/is);
});

test("rejects an unknown id", () => {
  assert.throws(() => resolveIcon(sets, "fake:nope"), /fake:nope/);
});

// Regression guard for a silent, browser-only failure. `@m3e/web/all` inlines its
// OWN copy of IconRegistry; `@m3e/web/icon` ships a second, independent copy. Since
// docs/index.ts loads `@m3e/web/all`, that is the registry the live <m3e-icon>
// element reads. Importing registerIcon from "@m3e/web/icon" writes to the other
// instance, so the icon registers "successfully" and still renders the text
// fallback. Verified in a browser: it showed the literal word "github".
test("imports registerIcon from @m3e/web/all, the registry the live element reads", () => {
  const out = generate({ ok: "fake:ok" }, sets);
  assert.match(out, /import \{ registerIcon \} from "@m3e\/web\/all";/);
  assert.doesNotMatch(out, /"@m3e\/web\/icon"/);
});

test("emits the object form with an explicit viewBox for every variant", () => {
  const out = generate({ ok: "fake:ok" }, sets);
  assert.match(out, /"viewBox":"0 0 24 24"/);
  assert.match(out, /\["outlined","rounded","sharp"\]/);
  assert.match(out, /registerIcon\("ok", variant, \{ outlined: data, filled: data \}\)/);
});
