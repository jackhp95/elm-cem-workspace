// manifest-gen — merge webref + BCD + WHATWG into a full-HTML-surface CEM manifest
// (markup/manifest.json shape) plus coverage & typing-gap reports.
//
// Sources (see PHASE-0-FINDINGS.md):
//   @webref/elements  -> element existence + obsolete flag  (the spine)
//   @mdn/browser-compat-data -> element->attr membership, deprecation, globals, input type_* enum
//   WHATWG attributes index (cached) -> attribute value TYPES + enum keyword sets
import { createRequire } from 'node:module';
import { loadWhatwgAttributes } from './whatwg.mjs';
import { classifyValue, typeText, INJECTED_ENUMS } from './typing.mjs';
import { recover as recoverEnum } from './enums.mjs';
import { ariaAttributes } from './aria.mjs';

const require = createRequire(import.meta.url);
const bcd = require('@mdn/browser-compat-data');

// Complete prose (WB): real element summaries + attr descriptions for the whole
// surface (data/prose.json — WHATWG Description columns + MDN for its richer 16).
const PROSE = require('../data/prose.json');

// Prose provenance counters (honesty: sourced prose vs generic fallback).
const prose = { elemProse: 0, elemGeneric: 0, attrProse: 0, attrWhatwg: 0, attrGeneric: 0 };

function elementSummary(tag) {
  if (PROSE.elements?.[tag]) { prose.elemProse++; return PROSE.elements[tag]; }
  prose.elemGeneric++;
  return `The \`<${tag}>\` HTML element.`;
}
function attrDescription(name, whatwgDesc) {
  if (PROSE.attributes?.[name]) { prose.attrProse++; return PROSE.attributes[name]; }
  if (whatwgDesc) { prose.attrWhatwg++; return whatwgDesc; }
  prose.attrGeneric++;
  return `The \`${name}\` attribute.`;
}

const VENDOR = /^(moz|webkit|ms|o)-/i;
// BCD keys that are sub-feature notes, not real content attributes.
const isNoise = k => k.includes('_') || VENDOR.test(k) || k.length > 40;

const pascal = tag => tag.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('');

// The twelve ENUMERATED global attributes. Unlike the plain-string / bool / int
// globals (which stay on the hand-written universal rail as open-capability
// setters), these have closed keyword sets, so they are emitted as a normal
// per-element attribute on EVERY element (below) and flow through the manifest →
// shared-attr vocab → portmanteau-token path (like a design system's `variant`): one
// typed `<Lib>.Html.Shared.dir` setter + barrel constants `dirLtr`/`dirRtl`/`dirAuto`.
// This makes a bad value (`dir "sideways"`) a compile error instead of a silent
// String. See planning/execution/2026-07-13-markup-categories-typed-globals-design.md §1.
const ENUM_GLOBALS = [
  'dir', 'draggable', 'autocapitalize', 'enterkeyhint', 'inputmode',
  'contenteditable', 'spellcheck', 'translate', 'popover', 'autocorrect',
  'writingsuggestions', 'hidden',
];

// ---- element existence spine (webref html-spec, minus obsolete) --------------
export async function liveElements() {
  const { listAll } = await import('@webref/elements');
  const all = await listAll();
  const html = (all.html?.elements || []);
  const live = html.filter(e => !e.obsolete).map(e => e.name);
  const obsolete = html.filter(e => e.obsolete).map(e => e.name);
  return { live: live.sort(), obsolete: obsolete.sort() };
}

// ---- BCD attribute membership + deprecation, pruned + type-de-exploded ------
function bcdAttrsFor(tag) {
  const el = bcd.html.elements[tag];
  if (!el) return { present: [], attrs: [], pruned: [], hasTypeEnum: false };
  const keys = Object.keys(el).filter(k => k !== '__compat');
  const hasTypeEnum = keys.some(k => k.startsWith('type_'));
  const pruned = [];
  const attrs = [];
  for (const k of keys) {
    if (k.startsWith('type_')) continue;            // harvested into `type` enum below
    if (isNoise(k)) { pruned.push(k); continue; }
    const status = el[k].__compat?.status || {};
    attrs.push({ name: k, deprecated: !!status.deprecated, experimental: !!status.experimental });
  }
  if (hasTypeEnum && !attrs.some(a => a.name === 'type')) {
    attrs.push({ name: 'type', deprecated: false, experimental: false });
  }
  return { attrs: attrs.sort((a, b) => a.name.localeCompare(b.name)), pruned, hasTypeEnum };
}

// ---- WHATWG value-type lookup, element-scoped -------------------------------
function whatwgIndex(rows) {
  // map attr -> [{elements, value}]; lookups prefer an element-scoped match.
  const byAttr = new Map();
  for (const r of rows) {
    if (!byAttr.has(r.attr)) byAttr.set(r.attr, []);
    byAttr.get(r.attr).push(r);
  }
  return {
    lookup(attr, element) {
      const cands = byAttr.get(attr);
      if (!cands) return null;
      const scoped = cands.find(c => c.elements.includes(element));
      const chosen = scoped || cands[0];
      return { value: chosen.value, description: chosen.description, scoped: !!scoped };
    },
  };
}

// ---- global attributes, factored ONCE ---------------------------------------
export function globalAttrs() {
  const g = bcd.html.global_attributes || {};
  return Object.keys(g)
    .filter(k => k !== '__compat' && !isNoise(k))
    .sort();
}

// ---- build one CEM declaration per live element -----------------------------
export async function build() {
  const { live, obsolete } = await liveElements();
  const { rows } = await loadWhatwgAttributes();
  const whatwg = whatwgIndex(rows);
  const globals = new Set(globalAttrs());

  const declarations = [];
  const coverage = { elements: live.length, obsolete: obsolete.length, attrsTotal: 0, prunedTotal: 0 };
  const typing = { enum: 0, bool: 0, int: 0, float: 0, string: 0, noWhatwgRow: 0, byTag: {} };
  const typingGap = []; // attrs that fell back to String

  // Compute the twelve ENUMERATED globals ONCE, using the element-invariant global
  // value cell ('HTML elements'), so every element gets the SAME typed union (e.g.
  // `dir` → "'ltr' | 'rtl' | 'auto'" everywhere). `""` — HTML's synonym for the
  // primary keyword (§1.4) — is dropped: it is redundant with the primary token and
  // `codegen/Naming.elm:safeValue` does not sanitize an empty token name. Each is
  // appended to EVERY element's attribute list (below), where the shared-attr
  // dedupe (`canonicalSharedSpecs`) collapses the per-element repetition into one
  // shared enum setter + barrel portmanteau tokens.
  const enumGlobalAttrs = ENUM_GLOBALS.map(name => {
    const w = whatwg.lookup(name, 'HTML elements');
    const desc = recoverEnum(name, w?.value || '', 'HTML elements')
      || (w ? classifyValue(w.value, { attr: name, element: 'HTML elements' }) : { kind: 'string', tag: 'global' });
    // Drop the empty-string synonym keyword from enum globals (§1.4).
    const cleaned = desc.kind === 'enum'
      ? { ...desc, keywords: desc.keywords.filter(k => k !== '') }
      : desc;
    return {
      name,
      kind: cleaned.kind,
      attr: {
        name,
        type: { text: typeText(cleaned) },
        description: attrDescription(name, (w?.description || '').trim()),
        // Provenance flag: an enumerated HTML global stamped onto EVERY element.
        // The generator keeps it in each element's capability row but emits its
        // setter ONCE in the shared vocab (never per-element — that tripled size).
        global: true,
      },
    };
  });

  for (const tag of live) {
    const { attrs, pruned } = bcdAttrsFor(tag);
    coverage.prunedTotal += pruned.length;
    const cemAttrs = [];
    for (const a of attrs) {
      if (globals.has(a.name)) continue;            // globals factored out (below)
      const w = whatwg.lookup(a.name, tag);
      let desc;
      const recovered = recoverEnum(a.name, w?.value || '', tag);   // WB enum-recovery overlay
      if (recovered) {
        desc = recovered;
      } else if (w) {
        desc = classifyValue(w.value, { attr: a.name, element: tag });
      } else if (INJECTED_ENUMS[`${a.name}@${tag}`]) {
        desc = { kind: 'enum', keywords: INJECTED_ENUMS[`${a.name}@${tag}`], reason: 'injected' };
      } else {
        desc = { kind: 'string', tag: 'no-whatwg-row' };
        typing.noWhatwgRow++;
      }
      typing[desc.kind]++;
      if (desc.kind === 'string') typingGap.push({ element: tag, attr: a.name, whatwg: w?.value || null, why: desc.tag });
      cemAttrs.push({
        name: a.name,
        type: { text: typeText(desc) },
        description: attrDescription(a.name, (w?.description || '').trim()),
        ...(a.deprecated ? { deprecated: true } : {}),
      });
    }
    // Emit the twelve enumerated globals on EVERY element (skip any a BCD element
    // already listed, so we never duplicate a field name). They carry the same
    // element-invariant union computed above; the shared-attr dedupe folds the
    // per-element repetition into one setter + portmanteau tokens.
    const present = new Set(cemAttrs.map(a => a.name));
    for (const g of enumGlobalAttrs) {
      if (present.has(g.name)) continue;
      typing[g.kind] = (typing[g.kind] || 0) + 1;
      cemAttrs.push(g.attr);
    }
    cemAttrs.sort((a, b) => a.name.localeCompare(b.name));
    coverage.attrsTotal += cemAttrs.length;
    typing.byTag[tag] = cemAttrs.length;
    declarations.push({
      kind: 'class',
      customElement: true,
      tagName: `markup-${tag}`,
      name: `Markup${pascal(tag)}`,
      summary: elementSummary(tag),
      description: `Native HTML \`<${tag}>\` element (full-coverage prototype surface).`,
      slots: [],
      attributes: cemAttrs,
      members: [], events: [], cssProperties: [], cssParts: [], cssStates: [], dependencies: [],
    });
  }

  // Universal attributes — globals + ARIA + event handlers — are NOT per-element
  // CEM declarations (a customElement:false decl generates nothing). They are handled
  // by the generator/runtime universal mechanism: `<Lib>.Attributes` (globals+events)
  // and `<Lib>.Aria` (ARIA) hand-written runtime templates + the `universalAttrs`
  // barrel list. This artifact (out/universal-attrs.json) is the TYPED source list the
  // generator slice consumes. Type each global via WHATWG value + enum-recovery overlay.
  const typedGlobal = name => {
    const w = whatwg.lookup(name, 'HTML elements');
    const desc = recoverEnum(name, w?.value || '', 'HTML elements')
      || (w ? classifyValue(w.value, { attr: name, element: 'HTML elements' }) : { kind: 'string', tag: 'global' });
    return { name, kind: desc.kind, type: { text: typeText(desc) }, description: attrDescription(name, (w?.description || '').trim()) };
  };
  // Event handlers (on*) are OMITTED: elm/virtual-dom neutralizes any attribute whose
  // name starts with "on", so String event content-attrs are dead in Elm. Typed
  // msg-producing handlers already exist per-component (<Lib>.Html.Shared, `onClick`).
  // The twelve ENUMERATED globals have moved off the universal rail onto every
  // element (emitted above), so they are excluded from the universal globals list
  // — they are no longer open-capability String setters but typed per-library tokens.
  const enumGlobalSet = new Set(ENUM_GLOBALS);
  const universal = {
    globals: [...globals].filter(name => !enumGlobalSet.has(name)).map(typedGlobal),
    aria: ariaAttributes(),
  };

  const manifest = {
    schemaVersion: '1.0.0',
    package: {
      name: 'jackhp95/markup',
      description: 'Type-safe HTML surface for elm-cem generated component libraries.',
      version: '1.0.0',
      license: 'BSD-3-Clause',
    },
    modules: [
      { kind: 'javascript-module', path: 'markup-elements.js', declarations, exports: null },
    ],
  };

  const typedTotal = typing.enum + typing.bool + typing.int + typing.float;
  const grandTotal = typedTotal + typing.string;
  const reports = {
    coverage: {
      ...coverage,
      globals: globals.size,
      aria: universal.aria.length,
      universalTotal: universal.globals.length + universal.aria.length,
    },
    prose,
    typing: {
      ...typing,
      typedTotal,
      stringFallback: typing.string,
      typedRatio: grandTotal ? +(100 * typedTotal / grandTotal).toFixed(1) : 0,
    },
    typingGap,
    obsoleteExcluded: obsolete,
  };
  return { manifest, reports, universal };
}
