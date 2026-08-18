// Deterministic HTML -> typed M3e.* Elm mapper (engine A).
//
// Phase 1 (L5 revive): A's component-API layer is now sourced from the ONE facts
// bundle — elm-cem's Face C — and rendered through the canonical `elm-shape`
// resolvers/renderers that engine B (cem-figma-connect) also uses, so the two
// engines can never drift again (VISION "one facts bundle"; plan §§2–3).
//
// What Face C + elm-shape own (the shared Face-C→Elm layer):
//   - component call form  (surface entry/form: `component` record-double-list or
//     double-list) — NOT the retired `M3e.<Mod>.view`.
//   - setter names          (setterOf), enum tokens (resolveEnumToken, incl. the
//     digit-leading `value4SidedCookie` value-prefix), slot fns (slotFnOf), the
//     `Action.none` action (actionNoneOf).
// What A keeps local (its DOM-structural frontend — plan §2.3, L4 audit):
//   - slot routing by DOM order + admission kinds, childSlotByKind, idWiring,
//     required-slot presence, aria/universal-attr routing, plain-HTML phrasing vs
//     flow, void/<a>/<img> handling.
//
// The current userland SEAM (the deleted `docs/kit`'s successor):
//   text        -> `M3e.text "…"`                         (renderTextSeam "M3e")
//   plain HTML  -> `TypedHtml.<tag> [attrs] [children]`
//   raw attr    -> `TypedHtml.Unsafe.Attributes.customAttribute "n" "v"`
//   dynamic tag -> `M3e.Unsafe.customElement "tag" [attrs] [children]`
//   <a href>    -> `TypedHtml.a [ …customAttribute "href" … ] [children]`
//
// Component modules: Face C now records them as `M3e.Component.<Name>` directly
// (reconciled at the elm-cem producer 2026-08-17, Stream 2 — Emit.elm's
// `surfacesOf`/`encodeComponent` carry the `.Component.` infix; see
// docs/plans/2026-08-17-stream2-cc-elm-naming-reconciliation.md), matching what
// the library ships. `M3e.Values` / `M3e.Action` stay flat. A therefore uses
// `comp.module` verbatim — the former `M3e.` → `M3e.Component.` rewrite is gone
// (keeping it would double-infix to `M3e.Component.Component.<Name>`).
//
// Anything genuinely unmappable short-circuits the example with { skip: reason }
// (never emit non-compiling Elm; verify-examples.mjs is the compile backstop).
//
// Contract:
//   toElm(htmlString, oracle, facts) -> { code: string } | { skip: reason }
//   `facts` is lib/facts.mjs's loadFacts() result ({ byTag }).

import { parseHTML } from "linkedom";
import { camel } from "./naming.mjs";
import {
  setterOf,
  resolveAttrExpr,
  slotFnOf,
  slotAttrOf,
  actionNoneOf,
  renderSlot,
  renderList,
  renderTextSeam,
} from "../../../../../elm-cem/src/elm-shape.mjs";

// ── the current userland seam (post-docs/kit) ──────────────────────────────
const TEXT_SEAM = "M3e"; // renderTextSeam(TEXT_SEAM, t) => `M3e.text "…"`
const ATTR_ESCAPE = "TypedHtml.Unsafe.Attributes.customAttribute"; // raw attr
const NODE_ESCAPE = "M3e.Unsafe.customElement"; // dynamic/string-tag element
const UNIVERSAL_ATTRIBUTES = "M3e.Attributes"; // open-row id/class universal setters

/** Component module: Face C now carries the real `M3e.Component.<Name>` directly
 * (producer-reconciled, Stream 2), so A uses it verbatim. tokenModule
 * (`M3e.Values`) / actionModule (`M3e.Action`) stay flat and are already correct. */
function componentModule(comp) {
  return comp.module;
}

/** JSON-escaped Elm string literal (Elm's escaping is JSON-compatible here). */
function elmStr(s) {
  return JSON.stringify(s ?? "");
}

/** A shared-text atom: `M3e.text "…"`. */
function textExpr(raw) {
  return renderTextSeam(TEXT_SEAM, raw);
}

const isWhitespaceText = (node) =>
  node.nodeType === 3 && node.textContent.trim() === "";

// Universal accessibility attributes: settable on ANY component via
// `TypedHtml.Aria` (open-row Attr): `label`, `labelledby`, `describedby`.
// `aria-hidden` has no typed setter — it falls through to the raw-attr escape.
const ARIA_SETTER = {
  "aria-label": "label",
  "aria-labelledby": "labelledby",
  "aria-describedby": "describedby",
};

// Universal HTML attributes emitted via `M3e.Attributes` (open-row Attr): the
// setter name equals the HTML attr name. Only `id`/`class` are reliably
// universal on every component's attr row; `style` (a 2-arg setter now) and any
// component-specific `for` fall through to the raw-attr escape below.
const UNIVERSAL_ATTR = new Set(["id", "class"]);

// Void (empty) elements: `br`/`hr`. Ordinary `TypedHtml.<tag>` 2-arg producers
// with no children -> `TypedHtml.br [] []`.
const VOID_TYPED_TAGS = new Set(["br", "hr"]);

// HTML phrasing/text-level tags whose `TypedHtml.<tag>` content row does NOT
// admit an m3e component's branded child. A raw phrasing wrapper directly
// containing an m3e-* child must forge via `M3e.Unsafe.customElement` (open child
// row) instead. (Flow containers div/section/form/… accept m3e children and are
// intentionally absent.)
const PHRASING_CONTENT_TAGS = new Set(
  (
    "abbr b bdi bdo button cite code data dd dfn dl dt em figcaption h1 h2 h3 " +
    "h4 h5 h6 i kbd label legend li mark menu ol p pre q s samp small span " +
    "strong sub summary sup td th time u ul var"
  ).split(" "),
);

// Plain HTML tags with a dedicated `TypedHtml.<tag>` producer (the FULL set
// TypedHtml exposes; `main` -> `main_`). Any tag NOT here falls through to the
// `M3e.Unsafe.customElement "<tag>"` string-tag escape.
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

function typedHtmlProducer(tag) {
  if (tag === "main") return "main_";
  return TYPED_HTML_TAGS.has(tag) ? tag : null;
}

class SkipError extends Error {
  constructor(reason) {
    super(reason);
    this.reason = reason;
  }
}
const skip = (reason) => {
  throw new SkipError(reason);
};

/** Raw HTML attributes on a plain element, via the customAttribute escape. */
function rawAttrExprs(node, { excludeHref = false } = {}) {
  const out = [];
  for (const attr of node.attributes) {
    if (attr.name === "slot") continue;
    if (excludeHref && attr.name === "href") continue;
    out.push(`${ATTR_ESCAPE} ${elmStr(attr.name)} ${elmStr(attr.value)}`);
  }
  return out;
}

/** Map a single node (element or text) to an Elm expression string. */
function nodeToElm(node, oracle, facts) {
  if (node.nodeType === 3) {
    const trimmed = node.textContent.trim();
    if (trimmed === "") skip("internal: whitespace text should be filtered");
    return textExpr(trimmed);
  }
  if (node.nodeType === 1) return elementToElm(node, oracle, facts);
  skip(`unsupported node type ${node.nodeType}`);
}

function childNodesToElm(node, oracle, facts) {
  const out = [];
  for (const child of node.childNodes) {
    if (isWhitespaceText(child)) continue;
    if (child.nodeType === 1 || child.nodeType === 3) {
      out.push(nodeToElm(child, oracle, facts));
    }
  }
  return out;
}

// A slot admits shared text/link content when its accepted kinds include a
// text/link row; `M3e.text` (open `{ s | sharedText }`) unifies with any such
// slot, so a text-only wrapper folds to `M3e.text`.
const admitsTextOrLink = (k) =>
  k === "text" || k === "link" || k === "shared:text" || k === "shared:link";
function slotAdmitsTextOrLink(kinds) {
  return Array.isArray(kinds) && kinds.some(admitsTextOrLink);
}

/** Text/link content for a slot child, or null so the caller falls back. */
function contentSlotChildOrNull(node, oracle, facts) {
  if (node.nodeType === 3) {
    const t = node.textContent.trim();
    return t ? textExpr(t) : null;
  }
  if (node.nodeType !== 1) return null;
  const childTag = node.tagName.toLowerCase();
  if (childTag === "a" && node.getAttribute("href") != null) {
    return plainElementToElm(node, oracle, facts);
  }
  const nonWs = [...node.childNodes].filter((c) => !isWhitespaceText(c));
  // A generic text-only wrapper (<span slot="label">Inbox</span>) folds to text.
  // A custom element the slot admits as an element kind must NOT fold.
  if (
    nonWs.length > 0 &&
    nonWs.every((c) => c.nodeType === 3) &&
    !childTag.startsWith("m3e-")
  ) {
    const text = nonWs.map((c) => c.textContent.trim()).join(" ");
    return textExpr(text);
  }
  return null;
}

/** Render one child element placed into an m3e NAMED slot, choosing a producer
 * that unifies with the slot's admission record. */
function renderSlotChild(child, slotEntry, oracle, facts) {
  const kinds = slotEntry?.kinds || [];
  if (slotAdmitsTextOrLink(kinds)) {
    const c = contentSlotChildOrNull(child, oracle, facts);
    if (c != null) return c;
  }
  if (
    child.nodeType === 1 &&
    kinds.includes("html") &&
    !child.tagName.toLowerCase().startsWith("m3e-") &&
    child.tagName.toLowerCase() !== "a"
  ) {
    const tag = child.tagName.toLowerCase();
    const attrs = rawAttrExprs(child);
    const attrList = renderList(attrs, { multiline: false });
    const kids = childNodesToElm(child, oracle, facts);
    const kidList = renderList(kids, { multiline: false });
    return `${NODE_ESCAPE} ${elmStr(tag)} ${attrList} ${kidList}`;
  }
  return nodeToElm(child, oracle, facts);
}

/** Map a plain (non-m3e) HTML element to Elm. */
function plainElementToElm(node, oracle, facts) {
  const tag = node.tagName.toLowerCase();

  // <a href="URL"> -> TypedHtml.a [ customAttribute "href" "URL", …others ] [kids].
  if (tag === "a") {
    const href = node.getAttribute("href");
    if (href == null) skip("plain <a> without href");
    const attrs = [
      `${ATTR_ESCAPE} ${elmStr("href")} ${elmStr(href)}`,
      ...rawAttrExprs(node, { excludeHref: true }),
    ];
    const children = childNodesToElm(node, oracle, facts);
    return `TypedHtml.a ${renderList(attrs, { multiline: false })} ${renderList(children, { multiline: false })}`;
  }

  // Void elements (`br`/`hr`): 2-arg producer, no children, drop rare attrs.
  if (VOID_TYPED_TAGS.has(tag)) return `TypedHtml.${tag} [] []`;

  const attrs = rawAttrExprs(node);
  const attrList = renderList(attrs, { multiline: false });

  // <img>: 2-arg producer, no children; src/… carried via customAttribute.
  if (tag === "img") return `TypedHtml.img ${attrList} []`;

  const children = childNodesToElm(node, oracle, facts);
  const list = renderList(children, { multiline: false });

  // A phrasing/text-content wrapper directly containing an m3e-* child cannot
  // typecheck as `TypedHtml.<tag>` (its content row rejects the branded child):
  // forge via the open-child-row `M3e.Unsafe.customElement` escape.
  const hasM3eChild = [...node.childNodes].some(
    (c) => c.nodeType === 1 && c.tagName.toLowerCase().startsWith("m3e-"),
  );
  if (hasM3eChild && PHRASING_CONTENT_TAGS.has(tag)) {
    return `${NODE_ESCAPE} ${elmStr(tag)} ${attrList} ${list}`;
  }

  const typedFn = typedHtmlProducer(tag);
  if (typedFn) return `TypedHtml.${typedFn} ${attrList} ${list}`;

  // A tag TypedHtml doesn't model -> the string-tag escape.
  return `${NODE_ESCAPE} ${elmStr(tag)} ${attrList} ${list}`;
}

function elementToElm(node, oracle, facts) {
  const tag = node.tagName.toLowerCase();

  // Non-m3e elements are plain HTML.
  if (!tag.startsWith("m3e-")) return plainElementToElm(node, oracle, facts);

  const entry = oracle[tag]; // DOM-structural facts (slots/kinds/idWiring/…)
  const comp = facts.byTag(tag); // component-API facts (Face C)
  if (!entry) skip(`unknown m3e tag ${tag} (oracle)`);
  if (!comp) skip(`no Face C facts for ${tag}`);

  const mod = componentModule(comp);
  const top = comp.surfaces?.top;
  if (!top) skip(`no top surface for ${tag}`);
  const form = top.form;
  const callEntry = top.entry;

  const attrPairs = [...node.attributes].map((a) => [a.name, a.value]);
  const isRecord = form === "record-double-list";

  // ── Record-form field folding (Face C `requiredSlots`). ──
  // A record-double-list `component` takes `{ <requiredSlot fields…>,
  // <requiredAttr fields…>, action? }`. Each Face C requiredSlot folds ONE child
  // into a named record field and CONSUMES it (it is NOT also placed in the
  // trailing children list):
  //   "unnamed"       -> field `content`, from the FIRST default (no-slot) child
  //                      (a text-only wrapper folds to `M3e.text`).
  //   "<slot>"        -> field camel("<slot>") (e.g. `label`, `leadingButton`,
  //                      `start`), from that slot's `slot="<slot>"` child.
  // A required field with no source child -> skip (cannot render honestly).
  const consumed = new Set();
  const recordFields = [];
  if (isRecord) {
    for (const rs of comp.requiredSlots ?? []) {
      if (rs === "unnamed") {
        const def = [...node.childNodes].find(
          (c) =>
            !isWhitespaceText(c) &&
            (c.nodeType === 3 ||
              (c.nodeType === 1 && !c.getAttribute("slot"))),
        );
        if (!def) {
          skip(`${tag} requires content (record form) but has no default child`);
        }
        consumed.add(def);
        const content =
          contentSlotChildOrNull(def, oracle, facts) ??
          nodeToElm(def, oracle, facts);
        recordFields.push(`content = ${content}`);
      } else {
        const match = [...node.childNodes].find(
          (c) => c.nodeType === 1 && c.getAttribute("slot") === rs,
        );
        if (!match) {
          skip(`${tag} requires slot "${rs}" (record form) but it is absent`);
        }
        consumed.add(match);
        const slotEntry = entry.slots.find((s) => s.rawName === rs);
        recordFields.push(
          `${camel(rs)} = ${renderSlotChild(match, slotEntry, oracle, facts)}`,
        );
      }
    }
  }

  // --- Attributes (skip the structural `slot` attribute). ---
  const setterExprs = [];
  const commentExprs = [];
  const dropComment = (name, value, reason) =>
    commentExprs.push(
      `{- round-trip: dropped ${name}${value ? `=${elmStr(value)}` : ""} on ${tag} — ${reason} -}`,
    );

  // Record-form REQUIRED attributes (Face C `requiredAttrs`, e.g. IconButton's
  // `aria-label`) are folded into the `{ content, … }` record as a named field
  // (`ariaLabel = "…"`), NOT emitted as an attr setter — so consume them here.
  const requiredAttrSet = new Set(isRecord ? (comp.requiredAttrs ?? []) : []);
  const requiredAttrValues = new Map();

  for (const [name, value] of attrPairs) {
    if (name === "slot") continue;

    // Required-record attribute -> captured for the record, not a setter.
    if (requiredAttrSet.has(name)) {
      requiredAttrValues.set(name, value);
      continue;
    }

    // Universal aria-* setters.
    if (ARIA_SETTER[name]) {
      setterExprs.push(`TypedHtml.Aria.${ARIA_SETTER[name]} ${elmStr(value)}`);
      continue;
    }

    // An attribute whose name is a SLOT setter on this component (e.g. Button
    // `selected`/`icon`) is not a settable attribute at the positional surface —
    // the slot child carries it. Drop it (mirrors the generator's slot/attr
    // collision resolution). Per-component via Face C's slotSetters.
    if (slotAttrOf(comp, name)) continue;

    // Typed setter via Face C (authoritative name + value expr).
    const s = setterOf(comp, name);
    if (s.ok) {
      const expr = resolveAttrExpr(comp, name, value, { boolPresentTrue: true });
      if (expr.ok) {
        setterExprs.push(`${mod}.${s.value} ${expr.value}`);
      } else {
        // Invalid enum value / malformed numeric: degrade to a grep-able comment
        // rather than emit a non-existent token that would null the surface.
        dropComment(name, value, expr.reason);
      }
      continue;
    }

    // Universal id/class via M3e.Attributes (open-row).
    if (UNIVERSAL_ATTR.has(name)) {
      setterExprs.push(`${UNIVERSAL_ATTRIBUTES}.${name} ${elmStr(value)}`);
      continue;
    }

    // Anything else (style, non-typed for, data-*, hidden, toc markers, …):
    // preserve via the raw-attribute escape rather than dropping it.
    setterExprs.push(`${ATTR_ESCAPE} ${elmStr(name)} ${elmStr(value)}`);
  }

  // --- Children: emit in ORIGINAL DOM ORDER. ---
  const orderedItems = [];
  const idWiring = entry.idWiring;
  let controlId = null;

  for (const child of node.childNodes) {
    if (isWhitespaceText(child)) continue;
    // A child folded into the record (requiredSlot) is already consumed.
    if (consumed.has(child)) continue;

    if (child.nodeType === 1) {
      const slotName = child.getAttribute("slot");
      // idWiring label slot (FormField `label`): leading `for`-derived String id.
      if (idWiring && slotName != null && slotName === idWiring.label) {
        const forId = child.getAttribute("for") ?? "";
        orderedItems.push({
          kind: "slotted",
          expr: `${mod}.${camel(slotName)} ${elmStr(forId)} (${nodeToElm(child, oracle, facts)})`,
        });
        continue;
      }
      if (slotName != null && slotName !== "") {
        const slotEntry = entry.slots.find((s) => s.rawName === slotName);
        if (!slotEntry && !slotFnOf(comp, slotName).ok) {
          skip(`unknown slot "${slotName}" on ${tag}`);
        }
        const slotFn = resolveSlotFn(comp, entry, slotName);
        const slotChildExpr = renderSlotChild(child, slotEntry, oracle, facts);
        orderedItems.push({
          kind: "slotted",
          expr: renderSlot(mod, slotFn, slotChildExpr),
        });
        continue;
      }
      // Fix C: a no-`slot=` default child routed to a NAMED slot by produced kind.
      const childTag = child.tagName.toLowerCase();
      if (childTag.startsWith("m3e-")) {
        const childKind = oracle[childTag]?.kind;
        const helper = childKind ? entry.childSlotByKind?.[childKind] : null;
        if (helper) {
          orderedItems.push({
            kind: "slotted",
            expr: renderSlot(mod, helper, nodeToElm(child, oracle, facts)),
          });
          continue;
        }
      }
      if (idWiring && idWiring.control && controlId == null) {
        controlId = child.getAttribute("id") ?? "";
      }
      orderedItems.push({ kind: "default", node: child });
      continue;
    }

    if (child.nodeType === 3) {
      orderedItems.push({ kind: "default", node: child });
      continue;
    }
  }

  // Render the default items (deferring for the idWiring control wrap).
  const defaultCount = orderedItems.filter((i) => i.kind === "default").length;
  const wrapControl = idWiring && idWiring.control && defaultCount === 1;
  const renderItem = (item) => {
    if (item.kind === "slotted") return item.expr;
    const expr = nodeToElm(item.node, oracle, facts);
    return wrapControl
      ? `${mod}.control ${elmStr(controlId ?? "")} (${expr})`
      : expr;
  };

  const attrsInner = [commentExprs.join(" "), setterExprs.join(", ")]
    .filter(Boolean)
    .join(" ");
  const attrsList = attrsInner === "" ? "[]" : `[ ${attrsInner} ]`;

  // --- Assemble the component call per Face C surface form. ---
  if (isRecord) {
    // recordFields already carries the requiredSlot fields (folded + consumed
    // above). Add the requiredAttr fields (e.g. IconButton `ariaLabel`) and the
    // `action` field — the latter ONLY when the component `usesAction` (Chip/
    // Heading take a bare `{ content }`, so a spurious `action` fails to
    // type-check). Every non-consumed child trails in the children list.
    for (const ra of comp.requiredAttrs ?? []) {
      if (!requiredAttrValues.has(ra)) {
        skip(`${tag} requires attribute "${ra}" (record field) but it is absent`);
      }
      recordFields.push(`${camel(ra)} = ${elmStr(requiredAttrValues.get(ra))}`);
    }
    if (comp.usesAction) {
      const action = actionNoneOf(comp);
      if (!action.ok) skip(action.reason);
      recordFields.push(`action = ${action.value}`);
    }
    const childList = renderList(orderedItems.map(renderItem), {
      multiline: false,
    });
    return `${mod}.${callEntry} { ${recordFields.join(", ")} } ${attrsList} ${childList}`;
  }

  // double-list (and any non-record top form): a flat content list.
  const contentExprs = orderedItems.map(renderItem);
  const contentList = renderList(contentExprs, { multiline: false });
  return `${mod}.${callEntry} ${attrsList} ${contentList}`;
}

/** The slot-function NAME for a slot: Face C's slotFnOf is authoritative; fall
 * back to the oracle's config-derived helper for config-only slots Face C does
 * not carry (e.g. FormField `label`). */
function resolveSlotFn(comp, entry, rawName) {
  const sf = slotFnOf(comp, rawName);
  if (sf.ok) return sf.value;
  const slotEntry = entry.slots.find((s) => s.rawName === rawName);
  if (slotEntry) return slotEntry.helper;
  return camel(rawName);
}

/**
 * Convert an HTML string to typed M3e.* Elm.
 * @param {string} htmlString
 * @param {object} oracle  buildOracle() result (DOM-structural facts)
 * @param {{ byTag: (tag:string)=>object }} facts  loadFacts() result (Face C)
 * @returns {{ code: string } | { skip: string }}
 */
export function toElm(htmlString, oracle, facts) {
  let document;
  try {
    ({ document } = parseHTML(`<html><body>${htmlString}</body></html>`));
  } catch (err) {
    return { skip: `parse error: ${err.message}` };
  }

  const roots = [...document.body.childNodes].filter(
    (n) => !isWhitespaceText(n) && (n.nodeType === 1 || n.nodeType === 3),
  );
  if (roots.length === 0) return { skip: "empty example" };

  try {
    const codes = roots.map((n) => nodeToElm(n, oracle, facts));
    return { code: codes.join("\n") };
  } catch (err) {
    if (err instanceof SkipError) return { skip: err.reason };
    throw err;
  }
}
