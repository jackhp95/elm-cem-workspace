// aria.mjs — the ARIA attribute surface: `role` + every `aria-*` state/property.
//
// Source: aria-query 5.3.2 (`aria` = ARIA props/states with `.type`; `roles` =
// the ARIA role taxonomy, from which we derive the closed `role` value set).
//
// Contract: export `ariaAttributes()` -> [{ name, type:{text}, description }].
// Typing maps aria-query metadata onto the elm-cem type contract via typeText:
//   boolean            -> "boolean"
//   tristate           -> enum 'true' | 'false' | 'mixed'
//   token/tokenlist w/ fixed .values -> enum of those values
//   integer / number   -> "number"
//   id / idlist / string / (valueless token) -> "string"
// `role` -> enum of the 127 CONCRETE role names (abstract roles are excluded:
//   ARIA forbids authors from using abstract roles as attribute values —
//   WAI-ARIA 1.2 §5.4 "Abstract Roles").
//
// Descriptions are concise hand-written one-liners grounded in the WAI-ARIA
// spec definitions (aria-query carries no prose). They are intentionally real,
// not "The X attribute." placeholders.
import { createRequire } from 'node:module';
import { typeText } from './typing.mjs';

const require = createRequire(import.meta.url);
const aq = require('aria-query');

// aria-query token/tokenlist `.values` may contain JS booleans (true/false) for
// tokens like aria-current/aria-invalid — normalise every value to its ARIA
// string keyword so the emitted enum literals are valid vocabulary tokens.
const kw = v => (v === true ? 'true' : v === false ? 'false' : String(v));

// Concise, spec-grounded one-liners (WAI-ARIA 1.2 property/state definitions).
const ARIA_PROSE = {
  'aria-activedescendant': 'Identifies the currently active descendant of a composite widget.',
  'aria-atomic': 'Whether assistive technologies present the entire changed live region as a whole.',
  'aria-autocomplete': 'What kind of user-input completion suggestions the widget provides.',
  'aria-braillelabel': 'A braille label overriding the accessible name for braille displays.',
  'aria-brailleroledescription': 'A human-readable braille description of the element role.',
  'aria-busy': 'Whether an element and its subtree are currently being updated.',
  'aria-checked': 'The checked state of checkboxes, radio buttons and other toggle widgets.',
  'aria-colcount': 'The total number of columns in a table, grid or treegrid.',
  'aria-colindex': "The column index of an element relative to the total number of columns.",
  'aria-colindextext': 'A human-readable text alternative for aria-colindex.',
  'aria-colspan': 'The number of columns spanned by a cell or gridcell.',
  'aria-controls': 'Identifies the element(s) whose contents or presence this element controls.',
  'aria-current': 'The current item within a set of related elements.',
  'aria-describedby': 'Identifies the element(s) that describe this element.',
  'aria-description': 'A string value that describes or annotates the current element.',
  'aria-details': 'Identifies the element that provides a detailed, extended description.',
  'aria-disabled': 'Whether the element is perceivable but disabled and not editable or operable.',
  'aria-dropeffect': 'What functions can be performed when a dragged object is released (deprecated).',
  'aria-errormessage': 'Identifies the element that provides an error message for this element.',
  'aria-expanded': 'Whether a grouping element owned or controlled by this element is expanded.',
  'aria-flowto': 'The next element(s) in an alternate reading order of content.',
  'aria-grabbed': 'The grabbed state of an element in a drag-and-drop operation (deprecated).',
  'aria-haspopup': 'Whether the element has a popup, and the type of popup it triggers.',
  'aria-hidden': 'Whether the element is exposed to the accessibility API.',
  'aria-invalid': 'Whether the entered value does not conform to the expected format.',
  'aria-keyshortcuts': 'Keyboard shortcuts that activate or focus the element.',
  'aria-label': 'A string value that labels the current element.',
  'aria-labelledby': 'Identifies the element(s) that label this element.',
  'aria-level': 'The hierarchical level of an element within a structure.',
  'aria-live': 'How assistive technologies should announce updates to a live region.',
  'aria-modal': 'Whether an element is modal when displayed.',
  'aria-multiline': 'Whether a text box accepts multiple lines of input.',
  'aria-multiselectable': 'Whether the user may select more than one item from the current selectable descendants.',
  'aria-orientation': "Whether the element's orientation is horizontal, vertical or unknown.",
  'aria-owns': 'Identifies child element(s) to define a parent/child relationship the DOM cannot.',
  'aria-placeholder': 'A short hint intended to aid the user with data entry when the control has no value.',
  'aria-posinset': "An element's number or position in the current set of listitems or treeitems.",
  'aria-pressed': 'The pressed state of a toggle button.',
  'aria-readonly': 'Whether the element is not editable but is otherwise operable.',
  'aria-relevant': 'What notifications the user agent triggers when a live region changes.',
  'aria-required': 'Whether user input is required on the element before form submission.',
  'aria-roledescription': 'A human-readable, author-localized description for the role of an element.',
  'aria-rowcount': 'The total number of rows in a table, grid or treegrid.',
  'aria-rowindex': 'The row index of an element relative to the total number of rows.',
  'aria-rowindextext': 'A human-readable text alternative for aria-rowindex.',
  'aria-rowspan': 'The number of rows spanned by a cell or gridcell.',
  'aria-selected': 'The selected state of a selectable element.',
  'aria-setsize': 'The number of items in the current set of listitems or treeitems.',
  'aria-sort': 'Whether items in a table or grid are sorted in ascending or descending order.',
  'aria-valuemax': 'The maximum allowed value for a range widget.',
  'aria-valuemin': 'The minimum allowed value for a range widget.',
  'aria-valuenow': 'The current value for a range widget.',
  'aria-valuetext': 'A human-readable text alternative of the current value of a range widget.',
  role: 'The WAI-ARIA role that defines the type of this element for assistive technologies.',
};

// Map one aria-query metadata entry -> an AttrType descriptor for typeText.
function ariaTypeDesc(meta) {
  switch (meta.type) {
    case 'boolean':
      return { kind: 'bool' };
    case 'tristate':
      return { kind: 'enum', keywords: ['true', 'false', 'mixed'] };
    case 'integer':
    case 'number':
      return { kind: meta.type === 'integer' ? 'int' : 'float' };
    case 'token':
    case 'tokenlist':
      if (Array.isArray(meta.values) && meta.values.length) {
        return { kind: 'enum', keywords: [...new Set(meta.values.map(kw))] };
      }
      return { kind: 'string', tag: 'token' };
    // id / idlist / string -> String (IDREFs and free text are not enumerable).
    default:
      return { kind: 'string', tag: meta.type };
  }
}

// The closed `role` value set = concrete (non-abstract) ARIA roles.
export function concreteRoles() {
  const out = [];
  for (const [name, meta] of aq.roles.entries()) {
    if (!meta.abstract) out.push(name);
  }
  return out.sort();
}

export function ariaAttributes() {
  const out = [];

  // role — a real enum over the concrete role vocabulary.
  const roles = concreteRoles();
  out.push({
    name: 'role',
    type: { text: typeText({ kind: 'enum', keywords: roles }) },
    description: ARIA_PROSE.role,
  });

  // every aria-* property / state
  for (const [name, meta] of aq.aria.entries()) {
    const desc = ariaTypeDesc(meta);
    out.push({
      name,
      type: { text: typeText(desc) },
      description: ARIA_PROSE[name] || `The ${name} ARIA attribute.`,
    });
  }
  return out;
}

// ---- self-test ---------------------------------------------------------------
if (import.meta.url === `file://${process.argv[1]}`) {
  const attrs = ariaAttributes();
  const roles = concreteRoles();
  console.log(`aria: ${attrs.length} attributes (role + ${attrs.length - 1} aria-*)`);
  const totalRoles = [...aq.roles.keys()].length;
  console.log(`role enum arity: ${roles.length} concrete roles (${totalRoles - roles.length} abstract excluded)`);

  const byType = {};
  for (const a of attrs) {
    const t = a.type.text === 'boolean' ? 'boolean'
      : a.type.text === 'number' ? 'number'
      : a.type.text === 'string' ? 'string' : 'enum';
    byType[t] = (byType[t] || 0) + 1;
  }
  console.log('type breakdown:', JSON.stringify(byType));

  const samples = ['role', 'aria-checked', 'aria-live', 'aria-hidden', 'aria-colcount', 'aria-label', 'aria-current'];
  console.log('sample typed attrs:');
  for (const name of samples) {
    const a = attrs.find(x => x.name === name);
    console.log(`  ${name} :: ${a.type.text.length > 60 ? a.type.text.slice(0, 57) + '…' : a.type.text}`);
  }
  const placeholder = attrs.filter(a => /^The .* ARIA attribute\.$/.test(a.description));
  console.log('placeholder descriptions remaining:', placeholder.length, placeholder.map(a => a.name));
}
