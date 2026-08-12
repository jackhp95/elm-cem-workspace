// enums.mjs — enum-recovery OVERLAY for WHATWG "Value" cells that
// src/typing.mjs:classifyValue currently leaves as String (the "Other"/token
// soft bucket) but which are actually CLOSED keyword sets recoverable from the
// spec.
//
// Contract: export `recover(attr, valueCell, element)` -> an AttrType descriptor
//   { kind:'enum', keywords:[...] }  OR  null (leave classifyValue's result).
//
// Every keyword set below is copied verbatim from a primary spec source (cited
// per-entry). We do NOT invent keywords. Genuinely OPEN sets (navigable target
// names, MIME types, media queries, BCP-47 tags, IDREF token lists, custom
// command keywords, link relation types, autofill field names) return null.
//
// The descriptors are shaped for src/typing.mjs:typeText — the caller does
//   const d = recover(attr, cell, el); if (d) type.text = typeText(d);

const e = (...keywords) => ({ kind: 'enum', keywords, reason: 'recovered' });

// --- closed keyword sets, keyed by attribute name ----------------------------
// Where an attribute's value set is element-invariant we key by name only.
const BY_ATTR = {
  // referrerpolicy — the Referrer Policy tokens.
  // Source: Referrer Policy §3 "referrer-policy" grammar
  //   (https://w3c.github.io/webappsec-referrer-policy/#referrer-policy).
  //   "" (empty string) is a valid value on the referrerpolicy content attribute
  //   meaning "no policy specified" (WHATWG references the empty token).
  referrerpolicy: e(
    '', 'no-referrer', 'no-referrer-when-downgrade', 'origin',
    'origin-when-cross-origin', 'same-origin', 'strict-origin',
    'strict-origin-when-cross-origin', 'unsafe-url',
  ),

  // hreftranslate — same referrer-policy? No: hreftranslate is a BCP-47 tag → open. (not listed)

  // sandbox — iframe sandboxing flag tokens (space-separated set; each token is
  // from this closed vocabulary). Source: WHATWG HTML §4.8.5 "the iframe element",
  // sandbox attribute allowed keywords (verbatim from the indices Value cell too).
  sandbox: e(
    'allow-downloads', 'allow-forms', 'allow-modals', 'allow-orientation-lock',
    'allow-pointer-lock', 'allow-popups', 'allow-popups-to-escape-sandbox',
    'allow-presentation', 'allow-same-origin', 'allow-scripts',
    'allow-top-navigation', 'allow-top-navigation-by-user-activation',
    'allow-top-navigation-to-custom-protocols',
  ),

  // blocking — render-blocking tokens. Source: WHATWG HTML §"Blocking attributes"
  //   (https://html.spec.whatwg.org/multipage/urls-and-fetching.html#blocking-attributes):
  //   the only defined possible blocking token is "render".
  blocking: e('render'),

  // fetchpriority — fetch priority hint. Source: WHATWG HTML §"fetchpriority"
  //   (also inline in the indices Value cell: "auto"; "high"; "low").
  fetchpriority: e('auto', 'high', 'low'),

  // as — preload/modulepreload destination. Source: WHATWG HTML link `as`
  //   attribute — the request destinations valid for rel=preload / modulepreload
  //   (https://html.spec.whatwg.org/multipage/links.html#attr-link-as), which are
  //   the potential-destination keywords minus the empty/script-embedded ones.
  //   Verbatim destination set (Fetch §"destination"): the values a preload link
  //   may name.
  as: e(
    'fetch', 'audio', 'document', 'embed', 'font', 'image', 'object',
    'script', 'style', 'track', 'video', 'worker',
  ),
};

// Value-cell text patterns that confirm we're looking at the right cell before
// overriding (guards against a same-named attr with a genuinely different value
// column in some future spec revision).
const CELL_GUARD = {
  referrerpolicy: /Referrer policy/i,
  sandbox: /allow-scripts/i,
  blocking: /space-separated tokens/i,
  fetchpriority: /auto|high|low/i,
  as: /Preload destination|preload/i,
};

export function recover(attr, valueCell, element) {
  const desc = BY_ATTR[attr];
  if (!desc) return null;
  const guard = CELL_GUARD[attr];
  // If we have the value cell, require it to match the expected shape; if the
  // caller passes no cell (e.g. attr known only from BCD), trust the attr name.
  if (guard && valueCell && !guard.test(String(valueCell))) return null;
  return { ...desc, keywords: [...desc.keywords] };
}

// The set of attribute names this overlay can recover (for reporting).
export const RECOVERABLE = Object.keys(BY_ATTR);

// ---- self-test ---------------------------------------------------------------
if (import.meta.url === `file://${process.argv[1]}`) {
  const { createRequire } = await import('node:module');
  const require = createRequire(import.meta.url);
  const { classifyValue, typeText } = await import('./typing.mjs');
  const d = require('../data/whatwg-attributes.json');

  const cellOf = attr => (d.rows.find(r => r.attr === attr) || {}).value || null;

  console.log('enum recovery overlay — recovered attrs:');
  for (const attr of RECOVERABLE) {
    const cell = cellOf(attr);
    const rec = recover(attr, cell, undefined);
    const before = cell ? classifyValue(cell, { attr }) : { kind: 'string', tag: 'no-cell' };
    console.log(
      `  ${attr}: before=${before.kind}${before.tag ? '('+before.tag+')' : ''} -> ${rec.keywords.length} keywords`,
    );
    console.log(`      ${typeText(rec)}`);
  }

  // Negative: an open-set attr must stay null.
  console.log('\nnegative checks (must be null):');
  for (const attr of ['target', 'accept', 'type', 'rel', 'command', 'max']) {
    const cell = cellOf(attr);
    console.log(`  ${attr}: ${recover(attr, cell, undefined) === null ? 'null OK' : 'RECOVERED (unexpected!)'}`);
  }
}
