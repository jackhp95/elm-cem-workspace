// Layer 1: statically scan a converted-Elm string for escape hatches.
//   Seam.*   — the sanctioned type-hole.
//   Native.* — raw-HTML fallback.

/**
 * Read one balanced (...) or [...] group starting exactly at an open-bracket
 * index. Returns the inner text, its length, and the index just past the
 * closing bracket. This is the single primitive all balanced-scanning here
 * is built from.
 *
 * String-literal aware: brackets living inside an Elm "..." string are not
 * counted toward depth, and a backslash escapes the next char (so `\"` does
 * not close the string).
 */
function readBalancedGroup(code, openIndex) {
  const open = code[openIndex];
  const close = open === "(" ? ")" : "]";
  let depth = 0;
  let inString = false;
  const start = openIndex + 1;
  let i = openIndex;
  for (; i < code.length; i++) {
    const ch = code[i];
    if (inString) {
      if (ch === "\\") {
        i++; // skip the escaped char
        continue;
      }
      if (ch === '"') inString = false;
      continue;
    }
    if (ch === '"') {
      inString = true;
      continue;
    }
    if (ch === open) depth++;
    else if (ch === close) {
      depth--;
      if (depth === 0) return { inner: code.slice(start, i), len: i - start, end: i + 1 };
    }
  }
  return { inner: code.slice(start), len: code.length - start, end: code.length };
}

/**
 * Elm calls look like `Prefix.fn arg1 arg2 ...` where each arg is its own
 * bracket/paren group (e.g. `Native.div [] [ ... ]` has an attrs list AND a
 * children list). Walk consecutive whitespace-separated groups immediately
 * after the identifier and concatenate them, so structure hiding in later
 * args (like a Native children list) isn't missed. Returns the combined inner
 * text, its char span, and the index just past the last consumed group.
 */
function collectArgsAfter(code, fromIndex) {
  let i = fromIndex;
  let inner = "";
  let charsInside = 0;
  while (i < code.length) {
    while (i < code.length && /\s/.test(code[i])) i++;
    if (i >= code.length || (code[i] !== "(" && code[i] !== "[")) break;
    const group = readBalancedGroup(code, i);
    inner += group.inner;
    charsInside += group.len;
    i = group.end;
  }
  return { inner, charsInside, end: i };
}

/** Every call site of `prefix.*` as an interval [start, end) plus its span. */
function collectSites(code, prefix) {
  const re = new RegExp("\\b" + prefix + "\\.[A-Za-z][A-Za-z0-9_]*", "g");
  let m;
  const sites = [];
  while ((m = re.exec(code)) !== null) {
    const { inner, charsInside, end } = collectArgsAfter(code, m.index + m[0].length);
    sites.push({ mechanism: prefix, start: m.index, end, span: charsInside, inner });
  }
  return sites;
}

export function scanEscapes(code) {
  if (typeof code !== "string" || code.length === 0) {
    return { converted: false, seam: { count: 0, charsInside: 0 }, native: { count: 0, charsInside: 0 }, charsInside: 0, benign: true };
  }

  const seamSites = collectSites(code, "Seam");
  const nativeSites = collectSites(code, "Native");
  const all = [...seamSites, ...nativeSites];

  // A site is "outermost" when no OTHER escape interval fully contains it.
  // Char metrics count only outermost spans, so a Seam nested inside a Native
  // (the standard idiom) is charged once, to the Native — never to both.
  const isContained = (s) =>
    all.some((o) => o !== s && o.start <= s.start && s.end <= o.end);
  const outerSpan = (sites) =>
    sites.reduce((sum, s) => sum + (isContained(s) ? 0 : s.span), 0);

  // Counts always include every site (nested ones too): `benign` leans on
  // seam.count to catch a Seam buried inside a Native, since the regex below
  // only inspects Native inner regions.
  const seamCharsInside = outerSpan(seamSites);
  const nativeCharsInside = outerSpan(nativeSites);
  const nativeBenign = nativeSites.every((s) => !/M3e\.|Native\.|Html\./.test(s.inner));
  const benign = seamSites.length === 0 && nativeBenign;

  return {
    converted: true,
    seam: { count: seamSites.length, charsInside: seamCharsInside },
    native: { count: nativeSites.length, charsInside: nativeCharsInside },
    charsInside: seamCharsInside + nativeCharsInside,
    benign,
  };
}
