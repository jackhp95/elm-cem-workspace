// One-shot a11y transform: give every icon-only `m3e-icon-button` example an
// accessible name.
//
// WHY: icon-button examples render an unlabelled `<m3e-icon-button>` around a
// bare `<m3e-icon>`, so assistive tech announces nothing — the exact nameless
// pattern the Guide says you cannot ship (#186). This walks the committed
// example corpus and adds an accessible name derived from the button's own icon
// glyph, on every surface, using each surface's aria convention
// (mirrored from the AppBar examples that already ship labels):
//   html    -> aria-label="Back"
//   top     -> TypedHtml.Aria.label "Back"   (head of the attr list)
//   record  -> TypedHtml.Aria.label "Back"   (prepended to the trailing attr list)
//   build   -> TypedHtml.Aria.label "Back"   (head of the attr list)
//
// SOURCES it edits, kept in lock-step:
//   - config/examples.rich.json    (committed corpus source: html + top)
//   - docs/data/examples.json       (what `npm run build:ci` renders verbatim)
//
// Idempotent: a button that already has an accessible name is skipped. Only the
// `html` surface is rendered live by the build; the Elm surfaces are shown as
// copy-paste code, so labelling them keeps the taught pattern honest.
//
// Run:  node docs/scripts/a11y-icon-button-labels.mjs

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, "../..");
const RICH = path.resolve(REPO, "config/examples.rich.json");
const DATA = path.resolve(HERE, "../data/examples.json");

/** Humanise a Material Symbols glyph name into an accessible label. */
function humanize(name) {
  const words = name.replace(/_/g, " ").trim();
  return words.charAt(0).toUpperCase() + words.slice(1);
}

/** Escape a label for an HTML double-quoted attribute value. */
function attrEscape(s) {
  return s.replace(/&/g, "&amp;").replace(/"/g, "&quot;");
}

/** Escape a label for an Elm string literal. */
function elmEscape(s) {
  return s.replace(/\\/g, "\\\\").replace(/"/g, '\\"');
}

/** Index of the `]` / `}` matching the opener at `open`, or -1. */
function matchDelim(s, open) {
  const pairs = { "[": "]", "{": "}", "(": ")" };
  const closeCh = pairs[s[open]];
  let depth = 0;
  for (let k = open; k < s.length; k++) {
    if (s[k] === s[open]) depth++;
    else if (s[k] === closeCh) {
      depth--;
      if (depth === 0) return k;
    }
  }
  return -1;
}

/**
 * The accessible name for one icon-button, from its primary glyph: the first
 * child `<m3e-icon>` that is NOT the `slot="selected"` toggle face (that one is
 * the pressed state, not the button's name). Null if there is no glyph to name
 * from (leave those to a human).
 */
function labelForIconButtonInner(inner) {
  const icons = [...inner.matchAll(/<m3e-icon\b([^>]*)>/g)].map((m) => m[1]);
  const primary =
    icons.find((a) => !/\bslot\s*=\s*["']selected["']/.test(a)) ?? icons[0];
  if (!primary) return null;
  const nameMatch = primary.match(/\bname\s*=\s*["']([^"']+)["']/);
  return nameMatch ? humanize(nameMatch[1]) : null;
}

/** Add `aria-label` to every nameless `<m3e-icon-button>` in a raw-HTML block. */
function labelHtml(html) {
  if (!html || !html.includes("<m3e-icon-button")) return html;
  return html.replace(
    /<m3e-icon-button\b([^>]*)>([\s\S]*?)<\/m3e-icon-button>/g,
    (full, attrs, inner) => {
      if (/\baria-label\s*=/.test(attrs)) return full;
      const label = labelForIconButtonInner(inner);
      if (!label) return full;
      return `<m3e-icon-button aria-label="${attrEscape(label)}"${attrs}>${inner}</m3e-icon-button>`;
    },
  );
}

/** The accessible name from an Elm content list: its first icon `name "..."`. */
function labelForElmContent(content) {
  // e.g. `M3e.Icon.name "check"` / `M3e.Icon.withName "x"`.
  const m = content.match(/\b(?:attrName|name|withName)\s+"([^"]+)"/);
  return m ? humanize(m[1]) : null;
}

/**
 * Surfaces where the icon-button is `<ctor> [ <attrs> ] [ <content> ]` and the
 * accessible name goes at the head of the attr list (top / build).
 * `ariaExpr` is the surface's aria setter (`TypedHtml.Aria.label`).
 */
function labelAttrListSurface(code, ctor, ariaExpr) {
  if (!code || !code.includes(ctor)) return code;
  let out = "";
  let i = 0;
  while (i < code.length) {
    const at = code.indexOf(ctor, i);
    if (at < 0) {
      out += code.slice(i);
      break;
    }
    out += code.slice(i, at);
    const attrOpen = code.indexOf("[", at + ctor.length);
    const attrClose = attrOpen >= 0 ? matchDelim(code, attrOpen) : -1;
    if (attrClose < 0) {
      out += ctor;
      i = at + ctor.length;
      continue;
    }
    const contentOpen = code.indexOf("[", attrClose + 1);
    const contentClose = contentOpen >= 0 ? matchDelim(code, contentOpen) : -1;
    const content =
      contentOpen >= 0 && contentClose >= 0
        ? code.slice(contentOpen, contentClose + 1)
        : "";
    const attrs = code.slice(attrOpen, attrClose + 1);
    const label = labelForElmContent(content);
    if (/ariaLabel|Aria\.label/.test(attrs) || !label) {
      out += code.slice(at, attrClose + 1);
      i = attrClose + 1;
      continue;
    }
    const inner = code.slice(attrOpen + 1, attrClose).trim();
    const labelExpr = `${ariaExpr} "${elmEscape(label)}"`;
    const newAttrs =
      inner === "" ? `[ ${labelExpr} ]` : `[ ${labelExpr}, ${inner} ]`;
    out += code.slice(at, attrOpen) + newAttrs;
    i = attrClose + 1;
  }
  return out;
}

/**
 * `M3e.IconButton.el { content = …, action = … } [ <attrs> ] [ … ]`.
 * The name is drawn from the record's `content` glyph and prepended to the
 * attr list that trails the record.
 */
function labelRecordSurface(code) {
  const ctor = "M3e.IconButton.el";
  if (!code || !code.includes(ctor)) return code;
  let out = "";
  let i = 0;
  while (i < code.length) {
    const at = code.indexOf(ctor, i);
    if (at < 0) {
      out += code.slice(i);
      break;
    }
    out += code.slice(i, at);
    const recOpen = code.indexOf("{", at + ctor.length);
    const recClose = recOpen >= 0 ? matchDelim(code, recOpen) : -1;
    if (recClose < 0) {
      out += ctor;
      i = at + ctor.length;
      continue;
    }
    const record = code.slice(recOpen, recClose + 1);
    const attrOpen = code.indexOf("[", recClose + 1);
    const attrClose = attrOpen >= 0 ? matchDelim(code, attrOpen) : -1;
    if (attrClose < 0) {
      out += code.slice(at, recClose + 1);
      i = recClose + 1;
      continue;
    }
    const attrs = code.slice(attrOpen, attrClose + 1);
    const label = labelForElmContent(record);
    if (/Aria\.label|ariaLabel/.test(attrs) || !label) {
      out += code.slice(at, attrClose + 1);
      i = attrClose + 1;
      continue;
    }
    const inner = code.slice(attrOpen + 1, attrClose).trim();
    const labelExpr = `TypedHtml.Aria.label "${elmEscape(label)}"`;
    const newAttrs =
      inner === "" ? `[ ${labelExpr} ]` : `[ ${labelExpr}, ${inner} ]`;
    out += code.slice(at, attrOpen) + newAttrs;
    i = attrClose + 1;
  }
  return out;
}

function transformExample(ex) {
  const next = { ...ex };
  const aria = "TypedHtml.Aria.label";
  const labelView = (code) =>
    labelAttrListSurface(code, "M3e.IconButton.view", aria);
  if (typeof ex.html === "string") next.html = labelHtml(ex.html);
  if (typeof ex.top === "string") next.top = labelView(ex.top);
  // Record surface may render icon-button either as the required-record `el`
  // form or as a plain `view`; label whichever is present.
  if (typeof ex.record === "string")
    next.record = labelView(labelRecordSurface(ex.record));
  if (typeof ex.build === "string") next.build = labelView(ex.build);
  return next;
}

function transformFile(p, dataShape) {
  const json = JSON.parse(fs.readFileSync(p, "utf8"));
  let count = 0;
  for (const key of Object.keys(json)) {
    const examples = dataShape ? json[key].examples : json[key];
    if (!Array.isArray(examples)) continue;
    for (let n = 0; n < examples.length; n++) {
      const before = JSON.stringify(examples[n]);
      const after = transformExample(examples[n]);
      if (JSON.stringify(after) !== before) count++;
      examples[n] = after;
    }
  }
  fs.writeFileSync(p, JSON.stringify(json, null, 2) + "\n");
  console.log(`${path.relative(REPO, p)}: ${count} example(s) labelled`);
}

transformFile(RICH, false);
transformFile(DATA, true);
