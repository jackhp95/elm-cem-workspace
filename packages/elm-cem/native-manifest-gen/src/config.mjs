// config.mjs — STRUCTURAL COMPOSITION config for full-HTML-coverage markup.
//
// Emits the closed structural parent/child slot declarations (the Build-facet
// driver) in the shape of the retired markup prototype's config/slots.json (deleted in the
// phantom migration; kept here as the historical shape reference), derived from the WHATWG
// content model (src/composition.mjs). This object is designed to be
// DEEP-MERGED with the hand-authored editorial config/slots.json — it never
// overwrites; it only adds structural entries the editorial file does not carry
// (and re-affirms the four v1 structural entries Select/Option/Ul/Li with the
// same shape).
//
// Scope: CLOSED STRUCTURAL FAMILIES ONLY. We do NOT model content-category
// nesting (flow vs phrasing). Category-only containers (div, span, section,
// article, p-as-flow-container, ...) are OMITTED here — omission lets the
// generator apply its default (arbitrary) slot. See CATEGORY-CONTAINER note.
//
// Kind-string convention (matches v1): the kind string is the child element's
// lowercase tag name — v1 uses "option" and "li". So table's tr slot is
// kinds:["tr"], select's is kinds:["option","optgroup", ...], etc.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { loadContentModelCached, structuralFamilies } from './composition.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// markup-<tag> config key format: strip prefix, PascalCase the tag.
// (CF-11: keys must match componentModuleName; short PascalCase, no "Markup." prefix.)
const configKey = tag =>
  tag.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('');

// ---------------------------------------------------------------------------
// EDITORIAL REFINEMENTS over the raw WHATWG structural families.
//
// The raw content model carries a few children that are NOT part of the clean
// closed structural family we want to enforce. These are resolved here, each
// with a cited rationale, so the config stays faithful-but-focused.
// ---------------------------------------------------------------------------

// Parents to DROP entirely (present in raw families but not a closed structural
// family per the confirmed set — they are text/phrasing containers).
const DROP_PARENTS = new Set([
  // <option> children are text/phrasing/div — a text container, not a closed
  // structural family. Confirmed family list does not include option as parent.
  'option',
]);

// Per-parent child overrides. Value = the exact child-tag list to keep, in
// author order. Used where WHATWG's customizable-<select> additions introduce
// children that are not part of the intended closed family.
const CHILD_OVERRIDES = {
  // Customizable-select (2024+) lets <select> also contain hr/div/button in
  // addition to option/optgroup. Confirmed: KEEP these — "+ newer hr/div/button".
  select: ['option', 'optgroup', 'hr', 'div', 'button'],
  // Customizable-select also injects div/legend into <optgroup>. Confirmed
  // family is optgroup -> option only; drop the customizable-select extras so
  // the closed slot stays meaningful (optgroup groups options).
  optgroup: ['option'],
};

// Per-child multiplicity overrides (name -> {multi, required}) keyed by parent.
// picture's img is "one img" (exactly one) in raw data already; no override
// needed. Kept as an extension point.
const MULTI_OVERRIDES = {};

// Human-facing family grouping, only for the generated "//" doc comment.
const FAMILY_OF = {
  table: 'table', caption: 'table', colgroup: 'table', col: 'table',
  thead: 'table', tbody: 'table', tfoot: 'table', tr: 'table', th: 'table', td: 'table',
  ul: 'list', ol: 'list', menu: 'list', li: 'list', dl: 'list', dt: 'list', dd: 'list',
  select: 'select', optgroup: 'select', option: 'select', datalist: 'select',
  audio: 'media', video: 'media', picture: 'media', source: 'media', track: 'media', img: 'media',
  details: 'misc', summary: 'misc', figure: 'misc', figcaption: 'misc',
  fieldset: 'misc', legend: 'misc', ruby: 'misc', rt: 'misc', rp: 'misc',
  map: 'misc', area: 'misc', hgroup: 'misc', html: 'misc', head: 'misc', body: 'misc',
  h1: 'misc', h2: 'misc', h3: 'misc', h4: 'misc', h5: 'misc', h6: 'misc', p: 'misc',
  hr: 'select', div: 'select', button: 'select',
};

// Child tags that are themselves ALSO closed structural parents (nesting chains).
// Derived below; used only to annotate the doc comment.

// ---------------------------------------------------------------------------
// CONTENT-CATEGORY nesting (Part 2 of the categories/typed-globals design).
//
// Categories live on the CONTAINER side: a category is a closed extensible-record
// alias (`<Lib>.Category.<Name>`) whitelisting the OUTPUT markers of its member
// elements; a container's slot references the alias. We model exactly the four
// categories ever used as a container child-constraint in the WHATWG data:
// flow, phrasing, heading content, metadata content (LOCKED decision).
// ---------------------------------------------------------------------------

// WHATWG category token (from the Children column / Categories column) → the Elm
// alias type name. Anything not here is NOT a modeled child-constraint (skipped).
const CATEGORY_ALIAS = {
  phrasing: 'Phrasing',
  'phrasing content': 'Phrasing',
  flow: 'Flow',
  'flow content': 'Flow',
  'heading content': 'Heading',
  heading: 'Heading',
  'metadata content': 'Metadata',
  metadata: 'Metadata',
};

// Category tokens that are deliberately NOT modeled as a child constraint (families,
// void, text, deferred transparency) — a container whose ONLY category child is one
// of these is left to its structural family / arbitrary default (decisions 4 & 5).
const NON_CONSTRAINT_CATEGORIES = new Set([
  'script-supporting elements', 'script-supporting', 'empty', 'text',
  'transparent', 'varies', 'none',
]);

// The role-tier elements (editorial, mirroring config/slots.json's `tier: {role:…}`):
// as MEMBERS of a category they contribute their `shared:<role>` cross-library kind
// string (marker Markup.Kind.Shared), not their bare tag. Every other element
// contributes its bare tag (marker <Lib>.Kind.Brand). Keep in sync with slots.json.
const ROLE_KIND = { a: 'shared:link', span: 'shared:text', p: 'shared:text', label: 'shared:label' };

// Data gap: the WHATWG index table lists h1–h6 in ONE combined row ("h1, h2, h3,
// h4, h5, h6"), which our loader drops (space in the name). They exist as real
// components and are heading + flow content, so seed them editorially so the
// `Heading` category (and legend/summary's phrasing∪heading union) is faithful.
const HEADING_ELEMENTS = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

// The kind string an element contributes as a category MEMBER.
const memberKind = tag => ROLE_KIND[tag] || tag;

// Parse an element's `categories` column into bare category tokens (drop the
// conditional `*` — `phrasing*` counts as phrasing for the direct-child whitelist;
// the descendant `*` rule is out of scope, in the review layer).
const categoriesOf = e => (e.categories || '')
  .split(/[;,]/).map(s => s.trim().replace(/\*$/, '')).filter(Boolean);

// Derive, from the content model:
//   • `members`     — per modeled category, the ORDERED, de-duplicated list of member
//                     kind strings (role atoms as `shared:<role>`, else bare tag).
//                     `Flow` lists only its BLOCK-ONLY members (flow ∖ phrasing by
//                     field); the emitted alias composes `Phrasing`.
//   • `containers`  — per element that constrains its children to a modeled category,
//                     the category slot shape { category, extras?, unionCategory? }.
//                     `extras` = the element's specific dual-mode element children;
//                     `unionCategory` = a second modeled category the element also
//                     accepts (phrasing ∪ heading for legend/summary).
function deriveCategories(byEl) {
  // -- membership --
  const rawMembers = { Phrasing: [], Flow: [], Heading: [...HEADING_ELEMENTS], Metadata: [] };
  for (const [name, e] of Object.entries(byEl)) {
    if (name.includes(' ')) continue; // "MathML math", combined "h1, h2, …"
    const cs = categoriesOf(e);
    if (cs.includes('phrasing')) rawMembers.Phrasing.push(name);
    if (cs.includes('flow')) rawMembers.Flow.push(name);
    if (cs.includes('metadata')) rawMembers.Metadata.push(name);
  }
  rawMembers.Flow.push(...HEADING_ELEMENTS); // headings are flow content

  // to kind strings, de-duplicated by the kind string (a `shared:X` from two role
  // elements collapses; `shared:link`(<a>) and `link`(<link> element) stay distinct
  // — different strings AND, post-§2.4.1, different fields).
  const dedup = names => [...new Set(names.map(memberKind))];
  const phrasingKinds = dedup(rawMembers.Phrasing);
  const phrasingSet = new Set(phrasingKinds);
  const members = {
    Phrasing: phrasingKinds,
    // Flow lists only flow-not-phrasing members (the alias composes Phrasing).
    Flow: dedup(rawMembers.Flow).filter(k => !phrasingSet.has(k)),
    Heading: dedup(rawMembers.Heading),
    Metadata: dedup(rawMembers.Metadata),
  };

  // -- containers --
  const containers = {};
  const addHeadingContainer = tag => {
    // h1–h6 constrain their children to phrasing (data gap → editorial).
    containers[tag] = { category: 'Phrasing', extras: [] };
  };
  for (const [name, e] of Object.entries(byEl)) {
    if (name.includes(' ')) continue;
    const catChildren = (e.categoryChildren || []).map(c => c.name);
    const modeled = [...new Set(
      catChildren.map(c => CATEGORY_ALIAS[c] || CATEGORY_ALIAS[c.replace(/s$/, '')]).filter(Boolean),
    )];
    if (modeled.length === 0) continue; // no modeled category child → skip
    // Ignore the non-constraint tokens for the "skip" decision already handled by
    // modeled.length; `modeled` only holds the four aliases.
    const extras = (e.elementChildren || [])
      .map(c => c.name)
      .filter(n => !n.includes(' ') && !['script', 'template', 'noscript'].includes(n));
    // Choose the PRIMARY category by lattice breadth (flow ⊃ phrasing ⊃ …); any
    // second modeled category becomes a union (`Phrasing (Heading {})`).
    const order = ['Flow', 'Phrasing', 'Heading', 'Metadata'];
    const sorted = modeled.slice().sort((a, b) => order.indexOf(a) - order.indexOf(b));
    const primary = sorted[0];
    const union = sorted[1]; // undefined when single-category
    const slot = { category: primary, extras };
    if (union) slot.unionCategory = union;
    containers[name] = slot;
  }
  HEADING_ELEMENTS.forEach(addHeadingContainer);

  return { members, containers };
}

export async function structuralConfig() {
  const byEl = await loadContentModelCached();
  const rawFamilies = await structuralFamilies(byEl);
  const { members, containers } = deriveCategories(byEl);

  // Apply editorial refinements.
  const families = {};
  for (const [parent, kids] of Object.entries(rawFamilies)) {
    if (DROP_PARENTS.has(parent)) continue;
    let childNames;
    if (CHILD_OVERRIDES[parent]) {
      childNames = CHILD_OVERRIDES[parent];
      // Rehydrate multiplicity from raw data where available, else default *.
      const rawByName = Object.fromEntries(kids.map(k => [k.name, k]));
      families[parent] = childNames.map(n =>
        rawByName[n] || { name: n, multi: true, required: false });
    } else {
      families[parent] = kids;
    }
  }

  // Which children are themselves closed parents (nesting chain members).
  const parents = new Set(Object.keys(families));

  const out = {
    '//': [
      'slots-structural.json (retired markup prototype shape) — GENERATED from the WHATWG content model',
      '(html.spec.whatwg.org "List of elements", Children column) by native-manifest-gen/src/config.mjs.',
      'TWO kinds of entry, DEEP-MERGED with the hand-authored config/slots.json (this file',
      'never overwrites editorial entries):',
      '  1. CLOSED structural families (tr→{th,td}, select→{…}) — kinds is a child-kind list.',
      '  2. CONTENT-CATEGORY containers (div→flow, p→phrasing, datalist→phrasing+option) —',
      '     kinds is { "category": <Phrasing|Flow|Heading|Metadata>, "extras"?: [...],',
      '     "unionCategory"?: <…> }; the generator points the slot at the <Lib>.Category alias.',
      'The `_categories` block carries each category alias\'s MEMBER kind strings (a role atom',
      'as shared:<role>, else the bare tag), Flow listing only its block-only members (the',
      'alias composes Phrasing). tier defaults to private for every element here.',
    ],
  };

  for (const [parent, kids] of Object.entries(families)) {
    // A dual-mode element (datalist, details, figure, fieldset, ruby) is BOTH a
    // structural family and a content-category container; its category slot (below)
    // subsumes the family list, so skip the plain-family entry for it here.
    if (containers[parent]) continue;

    const key = configKey(parent);
    const family = FAMILY_OF[parent] || 'structural';
    const childList = kids.map(k => k.name);
    const nestingKids = childList.filter(c => parents.has(c));

    // Slot multiplicity: a parent slot is "multi" if ANY child is repeatable,
    // and "required" only if a single-required child ("one X") is the model.
    // We author ONE unnamed slot listing all admissible child kinds.
    const anyRequired = kids.some(k => k.required);
    const allRequiredSingletons = kids.length && kids.every(k => k.required && !k.multi);
    const slotMulti = !allRequiredSingletons; // e.g. picture (source* + one img) stays multi
    const slotRequired = anyRequired;

    const doc =
      `${parent} — ${family} family; generated from WHATWG content model. ` +
      `Closed to child kinds [${childList.join(', ')}]` +
      (nestingKids.length ? `; nests further via [${nestingKids.join(', ')}]` : '') +
      (anyRequired
        ? `; note: ${kids.filter(k => k.required).map(k => k.name).join(', ')} required (exactly one).`
        : '.');

    out[key] = {
      '//': doc,
      tier: 'private',
      slots: {
        unnamed: {
          '//': `Structural children (WHATWG Children column: ${byEl[parent].childrenRaw}).`,
          kinds: childList,
          multi: slotMulti,
          required: slotRequired,
        },
      },
    };
  }

  // CONTENT-CATEGORY containers: one unnamed slot pointing at the category alias
  // (plus any dual-mode extras / union). Emitted AFTER families so a dual-mode
  // element's category slot is authoritative.
  for (const [tag, slot] of Object.entries(containers)) {
    const key = configKey(tag);
    const unionNote = slot.unionCategory ? ` ∪ ${slot.unionCategory}` : '';
    const extrasNote = slot.extras && slot.extras.length ? ` + extras [${slot.extras.join(', ')}]` : '';
    const kinds = { category: slot.category };
    if (slot.extras && slot.extras.length) kinds.extras = slot.extras;
    if (slot.unionCategory) kinds.unionCategory = slot.unionCategory;

    // NOTE: no `tier` here. The category slot must NOT clobber a role-tier curated
    // in config/slots.json (deep-merge is field-level, structural after editorial):
    // <a>/<span>/<p>/<label> keep their `tier: {role: …}`, and every other container
    // takes the generator's private default. Emitting `tier: 'private'` would demote
    // the role-tier atoms and break the shared-atom membership.
    out[key] = {
      '//': `${tag} — content-category container; children constrained to ${slot.category}${unionNote}${extrasNote} (WHATWG content model). tier from config/slots.json (role-tier atoms) or the private default.`,
      slots: {
        unnamed: {
          '//': `Category children (WHATWG Children column: ${byEl[tag] ? byEl[tag].childrenRaw : slot.category}).`,
          kinds,
          multi: true,
          required: false,
        },
      },
    };
  }

  // The category MEMBERSHIP block consumed by the generator's `<Lib>.Category`
  // emitter (§2.9-A/D). Ordered per category; Flow lists only block-only members.
  out._categories = members;

  return out;
}

// ---------------------------------------------------------------------------
// Self-test: `node src/config.mjs`
//   - writes config/slots-structural.json
//   - prints the parent -> kinds map
// ---------------------------------------------------------------------------
if (import.meta.url === `file://${process.argv[1]}`) {
  const cfg = await structuralConfig();
  const outPath = path.join(__dirname, '..', '..', 'config', 'slots-structural.json');
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, JSON.stringify(cfg, null, 4) + '\n');

  console.log('wrote', outPath, '\n');
  console.log('parent -> kinds map:');
  let families = 0, categories = 0;
  for (const [key, entry] of Object.entries(cfg)) {
    if (key === '//' || key === '_categories') continue;
    const s = entry.slots.unnamed;
    const mult = s.required ? 'required' : (s.multi ? 'multi' : 'single');
    if (Array.isArray(s.kinds)) {
      families += 1;
      console.log(`  ${key.padEnd(12)} -> [${s.kinds.join(', ')}]  (${mult})`);
    } else {
      categories += 1;
      const extras = s.kinds.extras && s.kinds.extras.length ? ` + [${s.kinds.extras.join(', ')}]` : '';
      const union = s.kinds.unionCategory ? ` ∪ ${s.kinds.unionCategory}` : '';
      console.log(`  ${key.padEnd(12)} -> category ${s.kinds.category}${union}${extras}  (${mult})`);
    }
  }
  console.log('\n_categories members:');
  for (const [cat, ms] of Object.entries(cfg._categories || {})) {
    console.log(`  ${cat.padEnd(10)} (${ms.length}): ${ms.join(' ')}`);
  }
  console.log(`\n${families} structural family entries + ${categories} category-container entries.`);
}
