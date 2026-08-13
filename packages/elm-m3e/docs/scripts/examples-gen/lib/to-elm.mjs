// Deterministic HTML -> typed M3e.* Elm mapper.
//
// Handles:
//   - simple 2-arg M3e components (Button/Icon/Card-style): enum/bool/string
//     attributes, named + default slots, and text.
//   - required-record view form (3-arg): named required fields (e.g.
//     ariaLabel <- aria-label) AND a required single-value default slot folded
//     into the record as a bare `content` field (IconButton/Heading/Chip).
//   - plain (non-m3e) HTML: TypedHtml.<tag> for
//     any tag TypedHtml models, `Native.node "<tag>"` (String tag name) for a
//     tag it doesn't, and <a href> -> Kit.link. v1 drops non-structural
//     attributes (class/id/for) rather than skipping the example.
//
// Anything genuinely unmappable short-circuits the example with { skip: reason }
// (never emit non-compiling Elm; the compile/elm-review gate is the backstop).
//
// Contract:
//   toElm(htmlString, oracle) -> { code: string } | { skip: reason }

import { parseHTML } from "linkedom";
import { camel } from "./naming.mjs";

/** Escape a JS string for embedding inside an Elm string literal ("..."). */
function escapeElmString(s) {
  return s
    .replace(/\\/g, "\\\\")
    .replace(/"/g, '\\"')
    .replace(/\n/g, "\\n")
    .replace(/\r/g, "\\r")
    .replace(/\t/g, "\\t");
}

const isWhitespaceText = (node) =>
  node.nodeType === 3 && node.textContent.trim() === "";

// Universal accessibility attributes: settable on ANY component via
// `TypedHtml.Aria` (open-row `Attr`), which exposes `label`, `labelledby`, and
// `describedby`. `aria-hidden` has no typed setter in `TypedHtml.Aria`; it
// falls through to the `Native.attribute` Seam path.
const ARIA_SETTER = {
  "aria-label": "label",
  "aria-labelledby": "labelledby",
  "aria-describedby": "describedby",
  // aria-hidden: no TypedHtml.Aria setter — falls through to Native.attribute
};

// Universal HTML attributes: like Aria, these are settable on ANY component
// (independent of the phantom rows) via `M3e.Attributes` (open-row
// `Attr capability msg`). The setter name equals the HTML attr name. Only
// emitted when a component exposes NO typed setter for the name (the typed
// lookup runs first), so a component that DOES map e.g. `for` (m3e-app-bar)
// keeps its own typed setter.
const UNIVERSAL_ATTR = new Set(["id", "for", "class", "style"]);

/** Emit a universal HTML-attribute setter (id/for/class/style) qualified by an
 * `Attributes` module. Mirrors the `ARIA_SETTER` universal path.
 * `style` takes the RAW attribute string: `M3e.Attributes.style` is
 * `String -> Attr` (the whole `style="…"` value verbatim), NOT a
 * `List (String, String)`. */
function universalAttrExpr(mod, name, value) {
  return `${mod}.${name} "${escapeElmString(value)}"`;
}

/** Validate + normalize a numeric attribute value to an Elm number literal.
 * Accepts an optional sign, integer, or simple decimal (Elm rejects `.5`/`5.`).
 * A non-numeric value skips (the compile gate would reject it anyway). */
function numberLiteral(value, tag, name) {
  const t = value.trim();
  if (!/^-?\d+(?:\.\d+)?$/.test(t)) {
    skip(`non-numeric value "${value}" for ${name} on ${tag}`);
  }
  return t;
}

// Collected across a single toElm() run for logging/inspection.
let droppedAttrs = [];
// Non-typed attributes preserved via the Seam escape hatch (`Native.attribute`)
// rather than dropped. Tracked for logging/inspection only.
let seamedAttrs = [];

/** Is `value` one of an enum attribute's known CEM tokens? An attr with no
 * collected token set (enumValues empty) is treated as unvalidated -> accept. */
function isValidEnumValue(attr, value) {
  const tokens = attr.enumValues ?? [];
  return tokens.length === 0 || tokens.includes(value);
}

/** Record + loudly log an invalid enum value being dropped (degradation). The
 * bad token would otherwise emit a non-existent `M3e.Token.<x>` and null the
 * surface; dropping it degrades the one attribute instead. */
function recordInvalidEnum(tag, name, value, attr) {
  const reason = `invalid enum value "${value}" for ${name} on ${tag} (expected one of ${(attr.enumValues ?? []).join("|")})`;
  droppedAttrs.push({ tag, name, value, reason });
  console.error(`to-elm: dropped ${reason}`);
}

// Void (empty) elements: `br`/`hr`. These are ordinary
// `TypedHtml.<tag> : List Attr -> List Element -> Element` producers (the elm/html
// call shape), NOT 0-arg values — so they are emitted `TypedHtml.br [] []`. They
// carry no children and drop their rare non-structural attributes.
const VOID_TYPED_TAGS = new Set(["br", "hr"]);

// HTML phrasing / text-level content tags whose `TypedHtml.<tag>` content row
// does NOT admit an m3e component's branded `<Component>.Is` row. A raw wrapper
// of one of these that directly contains an m3e-* child must forge via
// `Native.node` (open child row) instead of `TypedHtml.<tag>`. Derived by
// compiling `TypedHtml.<tag> [] [ M3e.Checkbox.view [] [], Kit.text "x" ]` for
// every TypedHtml tag and recording which REJECT the component child (flow
// containers such as div/section/form/fieldset/figure/details accept it and are
// intentionally absent). Regenerate that probe if TypedHtml changes.
const PHRASING_CONTENT_TAGS = new Set(
  (
    "abbr b bdi bdo button cite code data dd dfn dl dt em figcaption h1 h2 h3 " +
    "h4 h5 h6 i kbd label legend li mark menu ol p pre q s samp small span " +
    "strong sub summary sup td th time u ul var"
  ).split(" "),
);

// Plain HTML tags with a dedicated `TypedHtml.<tag>` producer. This is the FULL
// set of HTML tag names TypedHtml exposes (verified against
// docs/vendor/elm-foundation/TypedHtml.elm's exposing list), using real HTML tag
// names — `main` is exposed as the reserved-name-escaped `main_`, mapped by
// `typedHtmlProducer` below. `a`/`img`/`br`/`hr` also live here but are
// intercepted earlier in plainElementToElm (Kit.link / childless forms).
//
// Any tag TypedHtml does NOT model falls through to the sanctioned `Native.node
// "<tag>"` escape (a STRING tag name, per docs/kit/Native.elm).
const TYPED_HTML_TAGS = new Set(
  (
    "a abbr address area article aside audio b base bdi bdo blockquote body br " +
    "button canvas caption cite code col colgroup data datalist dd del details " +
    "dfn dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 " +
    "h3 h4 h5 h6 head header hgroup hr i iframe img input ins kbd label legend li " +
    "link main map mark menu meta meter nav noscript object ol optgroup option " +
    "output p picture pre progress q rp rt ruby s samp script search section " +
    "select slot small source span strong style sub summary sup table tbody td " +
    "template textarea tfoot th thead time title tr track u ul var video wbr"
  ).split(" "),
);

/** Map a lowercase HTML tag to its `TypedHtml.<producer>` function name, or null
 * if TypedHtml doesn't model the tag. `main` -> `main_` (reserved-name escape). */
function typedHtmlProducer(tag) {
  if (tag === "main") return "main_";
  return TYPED_HTML_TAGS.has(tag) ? tag : null;
}

/**
 * Sentinel thrown internally to short-circuit on the FIRST unmappable thing.
 * Carries the human-readable skip reason.
 */
class SkipError extends Error {
  constructor(reason) {
    super(reason);
    this.reason = reason;
  }
}

const skip = (reason) => {
  throw new SkipError(reason);
};

/** Map a single node (element or text) to an Elm expression string. */
function nodeToElm(node, oracle) {
  // Text node.
  if (node.nodeType === 3) {
    const trimmed = node.textContent.trim();
    if (trimmed === "") {
      // Whitespace-only text is not renderable content; caller filters these.
      skip("internal: whitespace text should be filtered");
    }
    return `Kit.text "${escapeElmString(trimmed)}"`;
  }

  // Element node.
  if (node.nodeType === 1) {
    return elementToElm(node, oracle);
  }

  skip(`unsupported node type ${node.nodeType}`);
}

/**
 * Map the non-whitespace child nodes of an element to a list of Elm exprs.
 * Used for plain-HTML containers, whose children carry no slot semantics.
 */
function childNodesToElm(node, oracle) {
  const out = [];
  for (const child of node.childNodes) {
    if (isWhitespaceText(child)) continue;
    if (child.nodeType === 1 || child.nodeType === 3) {
      out.push(nodeToElm(child, oracle));
    }
    // Comments and other node types are ignored.
  }
  return out;
}

/**
 * Render the child of a required NAMED slot whose accepted `kinds` are
 * text/link (e.g. NavMenuItem/TreeItem `label`). The codegen types this field
 * as `Element { text, link }`, so a generic `TypedHtml.<tag>` wrapper (which
 * carries an `html`-family row) would NOT unify. We therefore unwrap:
 *   - <a href> child            -> Kit.link "href" [ ...text... ]
 *   - text-only wrapper/bare    -> Kit.text "..."   (span/div wrappers folded)
 * Anything richer than text/link genuinely can't be sourced honestly -> skip.
 */
function textLinkSlotChild(node, tag, field, oracle) {
  // Bare text node.
  if (node.nodeType === 3) {
    return `Kit.text "${escapeElmString(node.textContent.trim())}"`;
  }
  if (node.nodeType !== 1) {
    skip(`unsupported ${field} slot child on ${tag}`);
  }
  const childTag = node.tagName.toLowerCase();

  // <a href> -> Kit.link (a link-kinded label).
  if (childTag === "a") {
    return plainElementToElm(node, oracle);
  }

  // A plain wrapper (span/div/etc.) or the m3e element's own text: fold to the
  // inner text if it is text-only; otherwise it isn't a text/link label.
  const nonWhitespace = [...node.childNodes].filter((c) => !isWhitespaceText(c));
  const allText = nonWhitespace.every((c) => c.nodeType === 3);
  if (allText) {
    const text = nonWhitespace.map((c) => c.textContent.trim()).join(" ");
    return `Kit.text "${escapeElmString(text)}"`;
  }

  skip(`unmappable ${field} slot child <${childTag}> on ${tag}`);
}

// A slot is a "content" slot when EVERY accepted kind is a content row —
// text/link (shared or bare) or `html`. Such a slot's helper takes an
// `Element { …sharedText/html… }` whose admission record is BARE, so a plain
// `TypedHtml.<tag>` wrapper — whose `is` is a TAGGED row (`SpanIs {…}`) — never
// unifies. The admissible producers are the Kit
// content builders (`Kit.text`, `Kit.link`, Kit typescales), so a text-only
// `<span>`/`<div>` wrapper (or an `<a href>`) must be UNWRAPPED to `Kit.text` /
// `Kit.link`. Element-admitting slots (iconButton/button/icon/…) are excluded
// and keep their real component/`nodeToElm` child.
// A slot admits Kit text/link content when its accepted kinds include a
// text/link row. `Kit.text : … -> Element { s | sharedText : Shared } …` (open)
// unifies with ANY slot whose admission record carries `sharedText` — even a
// mixed slot that also admits element kinds (e.g. Button `selected` =
// {sharedIcon, sharedText}, List `trailing`, NavMenuItem `badge`). So a
// text-only wrapper folds to `Kit.text` whenever the slot admits text; a
// non-text child (icon/img/component) returns null from the unwrapper and falls
// back to its default emission. `html` is deliberately NOT enough on its own —
// `Kit.text` does not unify with an html-only admission record.
const admitsTextOrLink = (k) =>
  k === "text" || k === "link" || k === "shared:text" || k === "shared:link";
function slotAdmitsTextOrLink(kinds) {
  return Array.isArray(kinds) && kinds.some(admitsTextOrLink);
}

// Non-fatal counterpart to textLinkSlotChild: return a Kit content expr when the
// child is text-only (bare text or a text-only wrapper) or an `<a href>` link,
// else null so the caller falls back to its default emission (and degrades
// honestly if THAT doesn't compile either — richer-than-content children have no
// admissible plain-html producer at the top surface).
function contentSlotChildOrNull(node, oracle) {
  if (node.nodeType === 3) {
    const t = node.textContent.trim();
    return t ? `Kit.text "${escapeElmString(t)}"` : null;
  }
  if (node.nodeType !== 1) return null;
  const childTag = node.tagName.toLowerCase();
  if (childTag === "a" && node.getAttribute("href") != null) {
    return plainElementToElm(node, oracle);
  }
  const nonWs = [...node.childNodes].filter((c) => !isWhitespaceText(c));
  // A text-only GENERIC wrapper (e.g. `<span slot="label">Inbox</span>`) folds to
  // Kit.text. A custom element (`<m3e-heading>Mail</m3e-heading>`, `<m3e-avatar>`)
  // is NOT a wrapper — it is a meaningful component the slot admits as an element
  // kind, so it must NOT fold to text (that dropped the element and misaligned the
  // round-trip DOM-diff for every following sibling). Defer it to nodeToElm, which
  // maps it to `M3e.<Comp>.view` for the slot's admitted element kind.
  if (nonWs.length > 0 && nonWs.every((c) => c.nodeType === 3) && !childTag.startsWith("m3e-")) {
    const text = nonWs.map((c) => c.textContent.trim()).join(" ");
    return `Kit.text "${escapeElmString(text)}"`;
  }
  return null;
}

/**
 * Render one child element placed into an m3e NAMED slot, choosing the producer
 * whose type unifies with the slot's admission record:
 *   1. text-only / <a href> child into a text/link-admitting slot -> Kit.text/Kit.link
 *   2. plain (non-m3e, non-<a>) element into a slot that admits open `html`
 *      -> `Native.node "<tag>"` (a BARE `{ k | html : Brand }` producer). A
 *      `TypedHtml.<tag>`'s tagged `Is` row (e.g. `Img.Is {…}`) does NOT unify
 *      with the slot's bare admission record, so an `<img slot="leading">` must
 *      forge natively rather than via `TypedHtml.img`.
 *   3. otherwise defer to the ordinary node mapper (m3e components -> M3e.*.view).
 */
function renderSlotChild(child, slotEntry, oracle) {
  const kinds = slotEntry.kinds || [];
  if (slotAdmitsTextOrLink(kinds)) {
    const c = contentSlotChildOrNull(child, oracle);
    if (c != null) return c;
  }
  if (
    child.nodeType === 1 &&
    kinds.includes("html") &&
    !child.tagName.toLowerCase().startsWith("m3e-") &&
    child.tagName.toLowerCase() !== "a"
  ) {
    const tag = child.tagName.toLowerCase();
    const attrs = nativeAttrExprs(child);
    const attrList = attrs.length === 0 ? "[]" : `[ ${attrs.join(", ")} ]`;
    const kids = childNodesToElm(child, oracle);
    const kidList = kids.length === 0 ? "[]" : `[ ${kids.join(", ")} ]`;
    return `Native.node "${escapeElmString(tag)}" ${attrList} ${kidList}`;
  }
  return nodeToElm(child, oracle);
}

/**
 * Raw HTML attributes on a plain element, as `Native.attribute "n" "v"` exprs.
 * `Native.attribute` is the sanctioned raw-attribute escape (kit `Native.elm`):
 * `Ir.fromHtmlAttribute (Html.Attributes.attribute name value) : Attr c msg`. Its
 * capability row `c` is fully open, so it unifies into ANY producer's constrained
 * attr row — a `TypedHtml.div`'s `List (Attr DivAttrs msg)` as readily as a
 * `TypedHtml.img`'s `List (Attr Img.Attrs msg)`. This carries functional attrs
 * (`value`/`placeholder`/`type`/`src`/…) that were previously DROPPED, so an
 * `<input value="…">` round-trips. `slot` is excluded — a plain child of an m3e
 * container carries its slot structurally via the parent's slot helper, not as an
 * attribute here. `href` is excluded for the caller that already emits it
 * (`<a>` -> Kit.link).
 */
function nativeAttrExprs(node, { excludeHref = false } = {}) {
  const out = [];
  for (const attr of node.attributes) {
    const name = attr.name;
    if (name === "slot") continue;
    if (excludeHref && name === "href") continue;
    out.push(`Native.attribute "${escapeElmString(name)}" "${escapeElmString(attr.value)}"`);
  }
  return out;
}

/** Map a plain (non-m3e) HTML element to Elm. */
function plainElementToElm(node, oracle) {
  const tag = node.tagName.toLowerCase();

  // <a href="URL"> -> Kit.link "URL" [ children ]. Kit.link has no attribute
  // parameter, so its other attributes cannot be carried here.
  if (tag === "a") {
    const href = node.getAttribute("href");
    if (href == null) {
      skip("plain <a> without href");
    }
    const children = childNodesToElm(node, oracle);
    const list = children.length === 0 ? "[]" : `[ ${children.join(", ")} ]`;
    return `Kit.link "${escapeElmString(href)}" ${list}`;
  }

  // Void elements (`TypedHtml.br`/`TypedHtml.hr`) take the standard 2-arg call
  // shape but have no children; their rare non-structural attrs are dropped (as
  // in v1), so they emit `TypedHtml.br [] []`.
  if (VOID_TYPED_TAGS.has(tag)) {
    return `TypedHtml.${tag} [] []`;
  }

  const attrs = nativeAttrExprs(node);
  const attrList = attrs.length === 0 ? "[]" : `[ ${attrs.join(", ")} ]`;

  // `TypedHtml.img` takes the standard `List Attr -> List Element -> Element`
  // shape; an <img> carries no children, so the child list is always `[]`. Its
  // attrs (`src`/…) ARE carried via the Native.attribute escape.
  if (tag === "img") {
    return `TypedHtml.img ${attrList} []`;
  }

  const children = childNodesToElm(node, oracle);
  const list = children.length === 0 ? "[]" : `[ ${children.join(", ")} ]`;

  // A PHRASING/text-content `TypedHtml.<tag>` (label, span, li, p, h1-6, …) has a
  // content row that admits only HTML phrasing brands — NOT an m3e component's
  // branded `<Component>.Is` row. So a raw phrasing wrapper with a direct m3e-*
  // child (e.g. `<label><m3e-checkbox> Checkbox 1</label>`) fails to typecheck as
  // `TypedHtml.label`; forge it via the `Native.node` escape, whose child row is
  // open (`List (Element s admittedBy msg)`) and accepts mixed component+text
  // content. FLOW containers (div/section/form/…) already admit m3e children on
  // the shared HtmlIr substrate, so they keep their `TypedHtml.<tag>` producer.
  // The set below is HTML phrasing/text-level content — verified against the
  // library by compiling `TypedHtml.<tag> [] [ M3e.Checkbox.view [] [], Kit.text "x" ]`
  // for every TypedHtml tag and collecting the rejects.
  const hasM3eChild = [...node.childNodes].some(
    (c) => c.nodeType === 1 && c.tagName.toLowerCase().startsWith("m3e-"),
  );
  if (hasM3eChild && PHRASING_CONTENT_TAGS.has(tag)) {
    return `Native.node "${escapeElmString(tag)}" ${attrList} ${list}`;
  }

  // Prefer `TypedHtml.<producer>` for any tag TypedHtml
  // models (div/span/label/input/form/…). It gives a closed, element-natural attr
  // row and unifies on the shared HtmlIr substrate with the m3e producers and the
  // `Native.attribute` escape carried above.
  const typedFn = typedHtmlProducer(tag);
  if (typedFn) {
    return `TypedHtml.${typedFn} ${attrList} ${list}`;
  }

  // A tag TypedHtml does not model (dynamic / custom element): forge it via the
  // sanctioned `Native.node` escape, which takes a STRING tag name (Native.elm).
  return `Native.node "${escapeElmString(tag)}" ${attrList} ${list}`;
}

function elementToElm(node, oracle) {
  const tag = node.tagName.toLowerCase();

  // Non-m3e elements are plain HTML.
  if (!tag.startsWith("m3e-")) {
    return plainElementToElm(node, oracle);
  }

  const entry = oracle[tag];
  if (!entry) {
    skip(`unknown m3e tag ${tag}`);
  }

  // Variant-group members fold into the group's TOP module with a per-variant
  // constructor (`M3e.Progress.linear`); everything else is `M3e.<Module>.view`.
  // Setters + content helpers all live on the target module.
  const mod = entry.group ? entry.group.module : entry.module;
  const ctor = entry.group ? entry.group.variant : "view";

  const attrPairs = [...node.attributes].map((a) => [a.name, a.value]);

  // --- Required-record named fields sourced from ATTRIBUTES. ---
  // (e.g. ariaLabel <- aria-label.) These source attributes are consumed here
  // and are NOT emitted as setters.
  const requiredFields = entry.requiredFields ?? [];
  const requiredHtmlNames = new Set(requiredFields.map((f) => f.htmlName));
  const recordFields = [];
  for (const { field, htmlName } of requiredFields) {
    const pair = attrPairs.find(([name]) => name === htmlName);
    if (!pair) {
      skip(`missing required ${field} on ${tag}`);
    }
    recordFields.push(`${field} = "${escapeElmString(pair[1])}"`);
  }

  // --- Required text/link NAMED slots sourced from a `slot="X"` child. ---
  // (e.g. NavMenuItem/TreeItem `label` <- `slot="label"` child.) In the current
  // library these are ordinary Content slot HELPERS (`M3e.TreeItem.label`, a
  // 2-arg `view : List Attr -> List Content`), NOT a folded required-record
  // field — required-ness is enforced by elm-review. We still consume the
  // matching child here (so it is not double-routed by the children loop) and
  // still require its presence, then emit the slot helper into `slottedExprs`.
  const requiredSlots = entry.requiredSlots ?? [];
  const consumedRequiredSlotNames = new Set();
  // Validate presence/uniqueness of each required named slot here, but keep the
  // rendered expr in a by-name MAP so the children loop can emit it in its
  // ORIGINAL DOM position (rather than hoisting all required slots first). The
  // content is a flat `List Element` and required-ness is an elm-review concern,
  // so source order is honest and improves round-trip fidelity.
  const requiredSlotExprByName = new Map();
  for (const { field, rawName, kinds } of requiredSlots) {
    const matches = [...node.childNodes].filter(
      (c) => c.nodeType === 1 && c.getAttribute("slot") === rawName,
    );
    if (matches.length === 0) {
      skip(`missing required ${field} (slot="${rawName}") on ${tag}`);
    }
    if (matches.length > 1) {
      skip(`multiple children for required ${field} slot on ${tag}`);
    }
    // A text/link-kinded slot (e.g. `label`) types as `Element { text, link }`.
    // Render it through the text/link unwrapper so a `<span>`/`<div>` wrapper
    // folds to `Kit.text` rather than an incompatible `TypedHtml.<tag>`.
    const onlyTextLink =
      kinds &&
      kinds.length > 0 &&
      kinds.every(
        (k) =>
          k === "text" ||
          k === "link" ||
          k === "shared:text" ||
          k === "shared:link",
      );
    const expr = onlyTextLink
      ? textLinkSlotChild(matches[0], tag, field, oracle)
      : nodeToElm(matches[0], oracle);
    const slotEntry = entry.slots.find((s) => s.rawName === rawName);
    const helper = slotEntry ? slotEntry.helper : camel(rawName);
    requiredSlotExprByName.set(rawName, `M3e.${mod}.${helper} (${expr})`);
    consumedRequiredSlotNames.add(rawName);
  }

  // --- Attributes (skip the `slot` attribute; it is structural). ---
  const attrExprs = [];
  // Block comments emitted INTO the attr list for TYPED attributes we can't place
  // (invalid enum value; a CEM type with no expressible Elm setter). A leading
  // block comment in an Elm list literal is valid whitespace, so `[ {- … -} a ]`
  // and `[ {- … -} ]` both parse. Non-typed attrs never land here — they Seam.
  const commentExprs = [];
  const dropComment = (name, value, reason) =>
    commentExprs.push(
      `{- round-trip: dropped ${name}${value ? `="${escapeElmString(value)}"` : ""} on ${tag} — ${reason} -}`
    );
  for (const [name, value] of attrPairs) {
    if (name === "slot") continue;
    // Required-record fields were consumed above; they are not setters.
    if (requiredHtmlNames.has(name)) continue;

    // Universal aria-* setters (settable on any component via TypedHtml.Aria).
    if (ARIA_SETTER[name]) {
      attrExprs.push(`TypedHtml.Aria.${ARIA_SETTER[name]} "${escapeElmString(value)}"`);
      continue;
    }

    const attr = entry.attributes.find((a) => a.htmlName === name);
    if (!attr) {
      // Universal HTML-attribute setters (id/for/class/style): settable on ANY
      // component via `M3e.Attributes` (open-row `Attr`), mirroring the Aria
      // path. Reached only when the component exposes no typed setter for the
      // name (the typed lookup above ran first), so a component that DOES map
      // `for` (e.g. m3e-app-bar) keeps its own typed setter.
      if (UNIVERSAL_ATTR.has(name)) {
        attrExprs.push(universalAttrExpr("M3e.Attributes", name, value));
        continue;
      }
      // Non-typed attribute: no CEM setter, not universal, not aria. NEVER drop —
      // preserve fidelity through the sanctioned Seam escape hatch. `Native.attribute`
      // is `Seam.asAttribute (Html.Attributes.attribute name value)` (kit Native.elm):
      // an open-capability-row `Attr` that type-checks in any component's attr list.
      // Covers hidden/autofocus/data-*/toc markers and any other unmodeled global
      // attribute, so hand-authored HTML round-trips instead of silently losing it.
      attrExprs.push(
        `Native.attribute "${escapeElmString(name)}" "${escapeElmString(value)}"`
      );
      seamedAttrs.push({ tag, name, value });
      continue;
    }

    // A TYPED attribute (in the CEM) whose type has no expressible Elm setter
    // (array/function/object). Not silently dropped: leave a comment documenting
    // what was lost and why, so the gap is visible in the generated source.
    if (attr.kind === "skip") {
      dropComment(name, value, "CEM type has no expressible Elm setter (array/function/object)");
      droppedAttrs.push({ tag, name, value });
      continue;
    }

    // An enum attribute whose HTML value is NOT one of the CEM's known tokens
    // (e.g. NavBar mode="extended" — the real set is auto|compact|expanded) has
    // no backing `M3e.Token.<x>` token, so emitting it would fail to compile and
    // null the whole surface. Validate against the collected token set and DROP
    // the attribute (recording a reason + a loud log) so a bad value degrades
    // gracefully instead of silently poisoning the example.
    if (attr.kind === "enum" && !isValidEnumValue(attr, value)) {
      recordInvalidEnum(tag, name, value, attr);
      dropComment(
        name,
        value,
        `not a valid ${name} value (expected ${(attr.enumValues ?? []).join("|")})`
      );
      continue;
    }

    const setterRef = `M3e.${mod}.${attr.setter}`;
    if (attr.kind === "enum") {
      attrExprs.push(`${setterRef} M3e.Values.${camel(value)}`);
    } else if (attr.kind === "bool") {
      // Presence of a boolean attribute means "true".
      attrExprs.push(`${setterRef} True`);
    } else if (attr.kind === "number") {
      // Numeric setter takes a Float; emit the raw value as a number literal.
      attrExprs.push(`${setterRef} ${numberLiteral(value, tag, name)}`);
    } else if (attr.kind === "string") {
      attrExprs.push(`${setterRef} "${escapeElmString(value)}"`);
    } else {
      skip(`unknown attr kind ${attr.kind} for ${name} on ${tag}`);
    }
  }

  // --- Children: emit in ORIGINAL DOM ORDER. ---
  // Each child becomes one ordered item: a "slotted" item is a fully-rendered
  // named-slot / required-slot / Fix-C setter call; a "default" item defers its
  // render so the idWiring single-control wrap can be applied below. Building a
  // single ordered list (instead of separate slotted/default buckets that were
  // concatenated) keeps `tab,tab,panel,panel` as `tab,tab,panel,panel` on the
  // round trip instead of hoisting every slotted child ahead of the defaults.
  const orderedItems = [];
  // id↔control wiring (FormField): the default-slot control's `id=` feeds the
  // `control` helper's leading String argument so `<label for=…>` associates
  // with it (docs/DESIGN.md §4). Captured from the single default-slot element child.
  const idWiring = entry.idWiring;
  let controlId = null;

  for (const child of node.childNodes) {
    if (isWhitespaceText(child)) continue;

    if (child.nodeType === 1) {
      const slotName = child.getAttribute("slot");
      // A required named slot: emit its (already-validated) expr IN POSITION.
      if (slotName != null && consumedRequiredSlotNames.has(slotName)) {
        orderedItems.push({
          kind: "slotted",
          expr: requiredSlotExprByName.get(slotName),
        });
        continue;
      }
      // idWiring label slot (FormField `label`): the helper takes a leading
      // `for`-derived String id, then the label element.
      if (idWiring && slotName != null && slotName === idWiring.label) {
        const forId = child.getAttribute("for") ?? "";
        orderedItems.push({
          kind: "slotted",
          expr: `M3e.${mod}.${camel(slotName)} "${escapeElmString(forId)}" (${nodeToElm(child, oracle)})`,
        });
        continue;
      }
      if (slotName != null && slotName !== "") {
        const slotEntry = entry.slots.find((s) => s.rawName === slotName);
        if (!slotEntry) {
          skip(`unknown slot "${slotName}" on ${tag}`);
        }
        // Choose the slot-child producer that unifies with the slot's admission
        // record (Kit content for text/link, Native.node for plain html, else
        // the ordinary node mapper).
        const slotChildExpr = renderSlotChild(child, slotEntry, oracle);
        orderedItems.push({
          kind: "slotted",
          expr: `M3e.${mod}.${slotEntry.helper} (${slotChildExpr})`,
        });
        continue;
      }
      // Fix C: a no-`slot=` default child distinguished only by TAG routes to
      // the NAMED slot helper whose accepted kind matches the child's produced
      // kind (e.g. <m3e-tab-panel> -> M3e.Tabs.panel, <m3e-step> ->
      // M3e.Stepper.step, <m3e-step-panel> -> M3e.Stepper.panel). Without this a
      // composite's heterogeneous default children collapse into one
      // `M3e.<mod>.children [ ... ]` whose List is not homogeneous and fails to
      // typecheck. The map excludes the container's default-union kinds, so
      // union-row composites (Menu/NavMenu/FabMenu) are unaffected.
      const childTag = child.tagName.toLowerCase();
      if (childTag.startsWith("m3e-")) {
        const childKind = oracle[childTag]?.kind;
        const helper = childKind ? entry.childSlotByKind?.[childKind] : null;
        if (helper) {
          orderedItems.push({
            kind: "slotted",
            expr: `M3e.${mod}.${helper} (${nodeToElm(child, oracle)})`,
          });
          continue;
        }
      }
      // Default-slot element: for an idWiring control, remember its `id=`.
      if (idWiring && idWiring.control && controlId == null) {
        controlId = child.getAttribute("id") ?? "";
      }
      orderedItems.push({ kind: "default", node: child });
      continue;
    }

    if (child.nodeType === 3) {
      // Non-whitespace text -> default-slot content.
      orderedItems.push({ kind: "default", node: child });
      continue;
    }

    // Comments and other node types are ignored.
  }

  // Content is a single flat `List Element`. The retarget dropped the
  // `child`/`children` wrappers: the top-layer `view : List Attr -> List Element`
  // takes RAW default-child elements, and every named-slot setter now returns a
  // free `Element`. So named-slot setter calls sit in the SAME list as the raw
  // default children — no wrapping, no `++` splicing, and IN SOURCE ORDER.
  // FormField is the one exception: its lone default-slot control keeps id↔`for`
  // wiring via the RENAMED `control` setter (was `child`), taking the control
  // element's `id=` as a leading String so a sibling `<label for=…>` associates
  // with it (docs/DESIGN.md §4). Required-ness of default content is an elm-review
  // concern, not a type.
  const defaultCount = orderedItems.filter((i) => i.kind === "default").length;
  const wrapControl =
    idWiring && idWiring.control && defaultCount === 1;
  const contentExprs = orderedItems.map((item) => {
    if (item.kind === "slotted") return item.expr;
    const expr = nodeToElm(item.node, oracle);
    return wrapControl
      ? `M3e.${mod}.control "${escapeElmString(controlId ?? "")}" (${expr})`
      : expr;
  });
  const contentList =
    contentExprs.length === 0 ? "[]" : `[ ${contentExprs.join(", ")} ]`;

  // Prepend any drop comments (leading block comments are valid list whitespace).
  const attrsInner = [commentExprs.join(" "), attrExprs.join(", ")]
    .filter(Boolean)
    .join(" ");
  const attrsList = attrsInner === "" ? "[]" : `[ ${attrsInner} ]`;

  // Required record (named fields and/or folded content) -> 3-arg view form.
  const hasRecord = recordFields.length > 0;
  const recordArg = hasRecord ? `{ ${recordFields.join(", ")} } ` : "";

  return `M3e.${mod}.${ctor} ${recordArg}${attrsList} ${contentList}`;
}

/**
 * Convert an HTML string to typed M3e.* Elm.
 * @returns {{ code: string } | { skip: string }}
 */
export function toElm(htmlString, oracle) {
  droppedAttrs = [];
  seamedAttrs = [];
  let document;
  try {
    ({ document } = parseHTML(`<html><body>${htmlString}</body></html>`));
  } catch (err) {
    return { skip: `parse error: ${err.message}` };
  }

  // Top-level renderable nodes (ignore whitespace-only text).
  const roots = [...document.body.childNodes].filter(
    (n) => !isWhitespaceText(n) && (n.nodeType === 1 || n.nodeType === 3),
  );

  if (roots.length === 0) {
    return { skip: "empty example" };
  }

  try {
    const codes = roots.map((n) => nodeToElm(n, oracle));
    // Single-root examples are the focus of this task; multi-root just joins.
    return { code: codes.join("\n") };
  } catch (err) {
    if (err instanceof SkipError) {
      return { skip: err.reason };
    }
    throw err;
  }
}
