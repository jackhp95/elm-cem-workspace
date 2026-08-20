// Faithful JS port of elm-cem/codegen/Naming.elm.
// The Elm module is the source of truth; keep these rules in sync.

const RESERVED = new Set([
  "number",
  "numbered",
  "abs",
  "acos",
  "asin",
  "atan",
  "atan2",
  "ceiling",
  "cos",
  "degrees",
  "e",
  "floor",
  "logBase",
  "pi",
  "radians",
  "round",
  "sin",
  "sqrt",
  "tan",
  "truncate",
  "compare",
  "max",
  "min",
  "children",
  "attributes",
  "component",
]);

const SYMS = [
  ["+", " plus "],
  ["%", " percent "],
  ["&", " and "],
  ["=", " equals "],
  ["?", " question "],
  ["#", " hash "],
  ["@", " at "],
];

function splitWords(raw) {
  let s = String(raw);
  for (const [from, to] of SYMS) s = s.split(from).join(to);
  s = [...s].map((c) => (/[a-zA-Z0-9]/.test(c) ? c : " ")).join("");
  return s.split(" ").filter(Boolean);
}

const cap = (w) => (w ? w[0].toUpperCase() + w.slice(1) : w);

function ensureLeadingAlpha(s, fallback) {
  if (s === "") return fallback;
  if (/[0-9]/.test(s[0])) return fallback + s;
  return s;
}

export function camel(raw) {
  const ws = splitWords(raw);
  const body = ws.map((w, i) => (i === 0 ? w.toLowerCase() : cap(w))).join("");
  return ensureLeadingAlpha(body, "value");
}

export function pascal(raw) {
  return ensureLeadingAlpha(splitWords(raw).map(cap).join(""), "V");
}

export const constructor = pascal;

export function avoidConflicts(name, taken) {
  return RESERVED.has(name) || taken.has(name) ? name + "Attr" : name;
}

// Elm reserved keywords. A field/attr setter that would collide with one is
// escaped with a trailing "_" (`type` -> `type_`). Faithful port of
// elm-cem/codegen/Generate.elm `elmKeywords` + `safeField`, which the library
// generator uses to name attribute setters (e.g. `Native.input`'s `type_`).
export const elmKeywords = new Set([
  "type",
  "module",
  "where",
  "import",
  "as",
  "exposing",
  "port",
  "let",
  "in",
  "if",
  "then",
  "else",
  "case",
  "of",
  "infix",
  "alias",
  "effect",
  "command",
  "subscription",
]);

export function safeField(name) {
  return elmKeywords.has(name) ? name + "_" : name;
}
