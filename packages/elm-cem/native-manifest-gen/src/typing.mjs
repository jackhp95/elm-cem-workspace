// Classify a WHATWG "Value" cell into an AttrType descriptor + the CEM type.text string
// the elm-cem generator (codegen/Attr.elm classifyText) understands.
//
// Emission contract (verified against Attr.elm:classifyText):
//   enum   -> "'a' | 'b'"   (single-quoted literals -> AEnum union)
//   bool   -> "boolean"      (-> ABool)
//   float  -> "number"       (-> ANumber -> Float -> Attr)
//   int    -> "integer"      (-> AInt    -> Int   -> Attr)
//   string -> "string"       (-> AString)  [url/idref/tokens/text all land here, but tagged]

const quoted = v => [...v.matchAll(/"([^"]*)"/g)].map(m => m[1]);

// Known closed enum sets not spelled inline in the index (recovered from other sources).
export const INJECTED_ENUMS = {
  // input[type] — 22 keywords from BCD html.elements.input type_* sub-entries.
  'type@input': ['button','checkbox','color','date','datetime-local','email','file','hidden',
    'image','month','number','password','radio','range','reset','search','submit','tel','text',
    'time','url','week'],
};

// Value cells that are an OPEN name-or-keyword set — honestly a String, not a fake enum.
const OPEN_KEYWORD = /navigable target name or keyword/i;

export function classifyValue(valueCell, { attr, element } = {}) {
  const v = valueCell.replace(/\*+/g, '').trim();

  // Injected closed enum wins (element-scoped).
  const inj = INJECTED_ENUMS[`${attr}@${element}`];
  if (inj) return { kind: 'enum', keywords: inj, reason: 'injected' };

  // Inline enum: leading quoted literal, one-or-more ";"-separated quoted keywords.
  // "the empty string" appears as a bare phrase; map it to the empty keyword.
  if (/^\s*"/.test(v)) {
    const kws = quoted(v);
    if (/the empty string/i.test(v) && !kws.includes('')) kws.push('');
    if (kws.length) return { kind: 'enum', keywords: kws, reason: 'inline' };
  }

  if (/^Boolean attribute/i.test(v)) return { kind: 'bool' };

  // A numeric-LOOKING cell whose value space is not a single number.
  //
  // The `float`/`int` patterns below match a SUBSTRING, and `typeText` collapses both
  // to `'number'`. Three real WHATWG cells therefore shipped as `Float -> Attr` with
  // their legal values unexpressible — and one of them shipped a silent regression:
  //
  //   coords   (area) 'Valid list of floating-point numbers'
  //   step     (input) 'Valid floating-point number greater than zero, or "any"'
  //   datetime (time)  'Valid month string, …, valid non-negative integer, or valid
  //                     duration string'
  //
  // `datetime` is the one that bit: <ins>/<del> declare it 'Valid date string with
  // optional time' (a string), and in elm-typed-html all three elements share the
  // `Text` home module, which emits ONE setter per attribute name — so <time>'s
  // spurious `number` won and `<ins datetime="2024-01-01">` became unwritable.
  //
  // These have to be decided BEFORE the numeric patterns, because each cell genuinely
  // does contain a number phrase; what disqualifies it is what sits NEXT to the number.
  const numericPhrase =
    /floating-point number|non-negative integer|Valid integer|integer greater|integer between/i;
  if (numericPhrase.test(v)) {
    // A LIST of numbers is authored as a delimited string ("0,0,82,126").
    if (/^Valid list of/i.test(v)) return { kind: 'string', tag: 'numberlist' };
    // A quoted KEYWORD alternative ('… or "any"') that no numeric type can express.
    if (/"/.test(v)) return { kind: 'string', tag: 'numberorkeyword' };
    // The number is only ONE of several accepted formats and the others are strings.
    if (/\bvalid [a-z- ]*string\b/i.test(v)) return { kind: 'string', tag: 'datetime' };
  }

  if (/floating-point number/i.test(v)) return { kind: 'float' };
  if (/non-negative integer|Valid integer|integer greater|integer between/i.test(v)) return { kind: 'int' };
  if (/URL/i.test(v)) return { kind: 'string', tag: 'url' };
  if (/^ID\b|hash-name reference/i.test(v)) return { kind: 'string', tag: 'idref' };
  if (/tokens/i.test(v)) return { kind: 'string', tag: 'tokens' };
  if (OPEN_KEYWORD.test(v)) return { kind: 'string', tag: 'target' };
  if (/^Text/i.test(v)) return { kind: 'string', tag: 'text' };

  // Specialised string subtypes we knowingly leave as String (typing-gap "soft" bucket).
  const soft = [
    [/BCP 47/i, 'bcp47'], [/MIME type/i, 'mime'], [/media query/i, 'mediaquery'],
    [/CSS </i, 'csscolor'], [/CSS declarations/i, 'cssdecl'], [/date string|month string|time/i, 'datetime'],
    [/Referrer policy/i, 'referrerpolicy'], [/source size list/i, 'sizes'],
    [/image candidate strings/i, 'srcset'], [/permissions policy/i, 'permissionspolicy'],
    [/Regular expression/i, 'regex'], [/Autofill field/i, 'autofill'],
    [/Preload destination/i, 'preload'], [/custom element name/i, 'customelement'],
    [/^Varies/i, 'varies'], [/UTF-8/i, 'charset'],
  ];
  for (const [re, tag] of soft) if (re.test(v)) return { kind: 'string', tag };

  return { kind: 'string', tag: 'unclassified' };
}

// AttrType descriptor -> CEM type.text string
//
// `int` and `float` are SEPARATE spellings, and used to be one.
//
// `classifyValue` above already tells them apart correctly — "Valid non-negative
// integer" is the WHATWG index's own words — but this function collapsed both to
// `'number'`, because `Attr.classifyText` had no integer spelling to collapse into:
// its only route to `AInt` was an integer-LITERAL union (`1 | 2 | 3`). So every
// derived integer attribute emitted `Float -> Attr` and serialized through
// `String.fromFloat`, whose range includes `"NaN"`, `"Infinity"`, `"1e+21"` and
// `"2.5"` — four strings HTML's integer parsers reject outright, at which point the
// attribute falls back to its default and `colspan="2.5"` silently renders as
// `colspan=1`. That was eleven attributes over 31 element/attribute pairs in
// `elm-typed-html`, all of which `elm/html` types `Int`.
//
// Both halves of the fix are load-bearing and neither works alone: without the
// `integer` spelling in `Attr.classifyText` this string classifies as `AString`
// (strictly worse), and without this line the spelling never reaches a manifest.
// Do not re-merge these two cases.
export function typeText(desc) {
  switch (desc.kind) {
    case 'bool': return 'boolean';
    case 'int': return 'integer';
    case 'float': return 'number';
    case 'enum':
      return desc.keywords.map(k => `'${k.replace(/'/g, "\\'")}'`).join(' | ');
    default: return 'string';
  }
}
