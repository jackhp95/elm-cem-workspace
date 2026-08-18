// elm-shape.mjs — the ONE canonical Face-C→Elm-syntax engine (elm-cem-workspace
// VISION Phase 1). Every consumer that turns Face C facts + already-resolved leaf
// strings into Elm syntax imports THIS module, so the "how m3e components spell as
// Elm" grammar lives in exactly one place and can never silently drift between
// consumers again.
//
// Two layers:
//   Layer 2 (this file, below) — the SHAPE RENDERER: pure string composition over
//     already-resolved Elm expression strings. It never re-parses an expr, so a
//     consumer may hand it a resolved token ("M3e.Values.rounded") OR a Code-Connect
//     template hole ("${size}") interchangeably — the renderer is agnostic. This is
//     what lets one engine serve both a plain-Elm consumer (elm-m3e docs, engine A)
//     and a Code-Connect-template consumer (cem-figma-connect, engine B).
//   Layer 1 (added in L2) — the Face-C RESOLVERS (attr→setter, enum→token,
//     slot→fn, icon→Name, surface→entry/form) returning a discriminated result so
//     each consumer maps `err` to its own fail mode (B throws; A skips the example).
//
// Home: `packages/elm-cem/src/` — elm-cem already EMITS Face C and owns "what the
// generated Elm API looks like," so it owns "how those facts spell as Elm." The
// dependency arrow stays one-way: elm-cem → { elm-m3e/docs, cem-figma-connect }.
//
// Extraction provenance: Layer 2 is B's `renderExample`
// (profiles/m3-kit/emitters/elm.mjs) generalized so it ALSO serves B's nested-child
// per-form branch and A's top-level component emission. The multiline/inline layout
// split is a parameter (`multiline`) rather than two copies. L1's golden test proves
// `renderComponentCall` reproduces B's `renderExample` output byte-for-byte.

// ── Layer 2: the shape renderer (string composition only) ──────────────────

// renderList(exprs, { multiline }) -> an Elm list literal.
//   multiline:true  reproduces renderExample's child/attr list:
//     "[ e1\n    , e2\n    ]"   (empty -> "[]")
//   multiline:false reproduces the nested renderChildElement inline list:
//     "[ e1, e2 ]"              (empty -> "[]")
export function renderList(exprs, { multiline = false } = {}) {
  if (!exprs || exprs.length === 0) return "[]";
  if (multiline) return "[ " + exprs.join("\n    , ") + "\n    ]";
  return "[ " + exprs.join(", ") + " ]";
}

// renderAttrList(module, setters, { multiline }) -> the attribute list literal,
// each line `<module>.<setter> <expr>`. `setters` = [{ setter, expr }].
// multiline:true reproduces renderExample's attrList EXACTLY (note the trailing
// space after "[ " and before "\n    ]" when there are zero setters — this is B's
// current byte output and is preserved deliberately for the L3 no-op proof).
export function renderAttrList(module, setters, { multiline = true } = {}) {
  const lines = (setters ?? []).map((l) => `${module}.${l.setter} ${l.expr}`);
  if (multiline) {
    return "[ " + lines.join("\n    , ") + "\n    ]";
  }
  return lines.length ? `[ ${lines.join(", ")} ]` : "[]";
}

// renderSlot(module, slotFn, childExpr) -> `<module>.<slotFn> (<childExpr>)`.
// The single canonical slot-placement spelling (both consumers wrap a slotted
// child this way: `M3e.Card.header ( <child> )`).
export function renderSlot(module, slotFn, childExpr) {
  return `${module}.${slotFn} (${childExpr})`;
}

// renderTextSeam(textSeam, text) -> `<seam>.text "<escaped>"`. `text` is the RAW
// string; it is JSON-escaped for the Elm string literal (Elm string escaping is a
// superset-compatible subset of JSON's for the characters that occur here — the
// same `JSON.stringify` B already uses).
export function renderTextSeam(textSeam, text) {
  return `${textSeam}.text ${JSON.stringify(text ?? "")}`;
}

// renderNativeAttr(attrSeam, name, value, fn) -> `<seam>.<fn> "n" "v"`. `fn`
// defaults to "attribute" (the historical spelling; keeps existing callers and
// the golden test stable) but is configurable so a consumer whose custom-attr
// helper is named differently — e.g. TypedHtml's `customAttribute` — can spell
// it correctly (`TypedHtml.Unsafe.Attributes.customAttribute "n" "v"`).
export function renderNativeAttr(attrSeam, name, value, fn = "attribute") {
  return `${attrSeam}.${fn} ${JSON.stringify(name)} ${JSON.stringify(value)}`;
}

// renderTypedHtml(htmlSeam, tag, attrExprs, childExprs) -> a plain-HTML carrier:
// `<htmlSeam>.<tag> [ a1, a2 ] [ c1, c2 ]` (inline lists, empty -> "[]"). Mirrors
// B's renderChildElement HTML-carrier branch.
export function renderTypedHtml(htmlSeam, tag, attrExprs, childExprs) {
  const attrList = attrExprs && attrExprs.length ? `[ ${attrExprs.join(", ")} ]` : "[]";
  const childList = childExprs && childExprs.length ? `[ ${childExprs.join(", ")} ]` : "[]";
  return `${htmlSeam}.${tag} ${attrList} ${childList}`;
}

// renderComponentCall(parts) -> the `figma.code` / example body for a component
// call, in the shape dictated by its surface `form`. A pure generalization of B's
// `renderExample`: every piece is an already-resolved string, so it is agnostic to
// whether an `expr` is a real token or a template hole.
//
// parts:
//   module      "M3e.Button"
//   entry       "component"
//   form        "double-list" | "record-double-list" | "pipeline"
//   finalizer   string | null                (pipeline only; e.g. "toElement")
//   setters     [{ setter, expr }]           ordered setter lines
//   content     string | null               a single content Element expr
//   children    string[] | null             a child list; TAKES PRECEDENCE over `content`
//   actionNone  string | null               "<ActionModule>.none" (record/pipeline)
//   label       string                       surface label for error messages
//   multiline   boolean (default true)       top-level (true) vs nested inline (false)
//
// Layout note: `multiline:true` reproduces B's `renderExample` (the top-level, the
// L1 golden). `multiline:false` reproduces B's nested `renderChildElement` per-form
// branch (single-line). Both are the same grammar; only whitespace differs.
export function renderComponentCall(parts) {
  const {
    module,
    entry,
    form,
    finalizer = null,
    setters = [],
    content = null,
    children = null,
    actionNone = null,
    label = entry,
    multiline = true,
  } = parts;

  if (multiline) return renderComponentCallMultiline(parts);

  // ── nested / inline shape (renderChildElement) ──
  const attrList = renderAttrList(module, setters, { multiline: false });
  if (form === "double-list") {
    const childList = renderList(children ?? [], { multiline: false });
    return `${module}.${entry} ${attrList} ${childList}`;
  }
  if (form === "record-double-list") {
    if (actionNone == null) {
      throw new Error(`elm-shape: ${label} (record form) requires actionNone.`);
    }
    // content :: children — first child folds into the record `content`, the rest
    // trail. When `children` is provided it drives; else fall back to `content`.
    let recordContent;
    let rest;
    if (children !== null && children.length > 0) {
      recordContent = children[0];
      rest = children.slice(1);
    } else {
      if (content == null) {
        throw new Error(`elm-shape: ${label} (record form) requires a content element.`);
      }
      recordContent = content;
      rest = [];
    }
    const restList = renderList(rest, { multiline: false });
    return `${module}.${entry} { content = ${recordContent}, action = ${actionNone} } ${attrList} ${restList}`;
  }
  throw new Error(
    `elm-shape: ${label} — inline renderer supports only double-list / record-double-list, got "${form}".`
  );
}

function renderComponentCallMultiline(parts) {
  const {
    module,
    entry,
    form,
    finalizer = null,
    setters = [],
    content = null,
    children = null,
    actionNone = null,
    label = entry,
  } = parts;

  const attrList = renderAttrList(module, setters, { multiline: true });
  const childrenList = children === null ? null : renderList(children, { multiline: true });

  switch (form) {
    case "double-list": {
      const body =
        childrenList !== null ? childrenList : content === null ? "[]" : `[ ${content} ]`;
      return `${module}.${entry}\n    ${attrList}\n    ${body}`;
    }
    case "record-double-list": {
      let recordContent;
      let recordChildren;
      if (children !== null && children.length > 0) {
        recordContent = children[0];
        const rest = children.slice(1);
        recordChildren = renderList(rest, { multiline: true });
      } else {
        if (content === null) {
          throw new Error(
            `elm-shape: surface ${label} (record form) requires a content element — ` +
              `a no-content ([]) entry cannot be rendered here.`
          );
        }
        recordContent = content;
        recordChildren = "[]";
      }
      if (actionNone == null) {
        throw new Error(`elm-shape: surface ${label} (record form) requires actionNone.`);
      }
      return (
        `${module}.${entry}\n` +
        `    { content = ${recordContent}\n` +
        `    , action = ${actionNone}\n` +
        `    }\n` +
        `    ${attrList}\n` +
        `    ${recordChildren}`
      );
    }
    case "pipeline": {
      if (content === null) {
        throw new Error(
          `elm-shape: surface ${label} (pipeline form) requires a content element — ` +
            `a no-content ([]) entry cannot be rendered here.`
        );
      }
      if (actionNone == null) {
        throw new Error(`elm-shape: surface ${label} (pipeline form) requires actionNone.`);
      }
      const pipe = setters.map((l) => `    |> ${module}.${l.setter} ${l.expr}`).join("\n");
      const fin = finalizer ? `\n    |> ${module}.${finalizer}` : "";
      return (
        `${module}.${entry}\n` +
        `    { content = ${content}\n` +
        `    , action = ${actionNone}\n` +
        `    }\n` +
        `${pipe}${fin}`
      );
    }
    default:
      throw new Error(`elm-shape: unknown surface form "${form}"`);
  }
}

// ── Layer 1: the Face-C resolvers (discriminated result) ───────────────────
//
// Each resolver returns a DISCRIMINATED result — `{ ok: true, value }` or
// `{ ok: false, reason }` — rather than throwing. This is the one policy knob the
// two consumers legitimately differ on: B (cem-figma-connect) maps `err` to a
// THROW (a binding must never guess a name), A (elm-m3e docs) maps `err` to a
// SkipError (never emit non-compiling Elm). Same code path, both contracts.
//
// The `reason` strings are the CORE of B's current error messages (everything
// after `elm emitter: ${ctxLabel} — `). B's L3 wrappers re-add the
// `elm emitter: ${ctxLabel} — ` prefix, so B's thrown messages stay byte-identical.
//
// Extraction provenance: B's `canon`/`setterOf`/`resolveToken`/`resolveSetAttrExpr`/
// `resolveChildAttrExpr`/`slotSetterOf`/`slotAttr`/`actionNoneOf`/`iconNameExpr`
// (profiles/m3-kit/emitters/elm.mjs).

export const ok = (value) => ({ ok: true, value });
export const err = (reason) => ({ ok: false, reason });

// canonical comparison key bridging CEM kebab values and Elm camel values.
export function canon(value) {
  return String(value).toLowerCase().replace(/[^a-z0-9]/g, "");
}

// setterOf(comp, attr) -> ok(setterName) | err. `comp.setters[attr]` is `null`
// (not merely absent) when the producer measured the name but could NOT verify it
// is exposed by the component's module — the falsy check covers both.
export function setterOf(comp, attr) {
  const setter = comp.setters[attr];
  if (!setter) {
    return err(
      `attribute "${attr}" is not a known/verified setter for component ` +
        `"${comp.component}" (setters: ${Object.keys(comp.setters).join(", ")}).`
    );
  }
  return ok(setter);
}

// resolveEnumToken(comp, setter, cemValue) -> ok("M3e.Values.<ctor>") | err.
// Elm identifiers cannot start with a digit, so the producer prefixes digit-leading
// enum values with "value" (CEM "4-sided-cookie" -> Elm ctor "value4SidedCookie",
// keyed "value4sidedcookie"). canon() strips to "4sidedcookie", so fall back to the
// value-prefixed key when the value is digit-leading.
export function resolveEnumToken(comp, setter, cemValue) {
  const enumFact = comp.enums[setter];
  if (!enumFact) {
    return err(
      `no enum "${setter}" in elm-facts for component "${comp.component}" ` +
        `(setters: ${Object.keys(comp.enums).join(", ")}). ` +
        `Cannot resolve a token name; refusing to guess.`
    );
  }
  const key = canon(cemValue);
  let hit = enumFact.values.find((v) => v.key === key);
  if (!hit && /^[0-9]/.test(key)) hit = enumFact.values.find((v) => v.key === `value${key}`);
  if (!hit) {
    return err(
      `CEM value "${cemValue}" (key "${key}") has no matching Elm enum value in ` +
        `"${setter}" (available: ${enumFact.values.map((v) => v.elm).join(", ")}). ` +
        `Refusing to guess a token name.`
    );
  }
  if (!hit.token) {
    return err(
      `Elm enum value "${hit.elm}" is not exposed in the token module ` +
        `(elm-facts recorded token:null). Refusing to emit an unexposed token name.`
    );
  }
  return ok(hit.token);
}

// resolveAttrExpr(comp, attr, value, { boolPresentTrue }) -> ok(elmExpr) | err.
// Resolution chain: enum setter -> token; float/int setter -> bare number literal
// (numeric-validated); "true"/"false" -> Bool literal; else JSON-quoted string.
// `boolPresentTrue` (the child path): an empty-string value on a Bool setter is
// boolean-PRESENT -> True (the CEM/WC `selected=""` convention).
export function resolveAttrExpr(comp, attr, value, { boolPresentTrue = false } = {}) {
  const s = setterOf(comp, attr);
  if (!s.ok) return s;
  const setter = s.value;
  if (boolPresentTrue && comp.setterArgTypes?.[setter] === "bool" && value === "") {
    return ok("True");
  }
  const enumFact = comp.enums[setter];
  if (enumFact) return resolveEnumToken(comp, setter, value);
  const argType = comp.setterArgTypes?.[setter];
  if (argType === "float" || argType === "int") {
    if (!/^-?[0-9]+(\.[0-9]+)?$/.test(String(value))) {
      return err(
        `value "${value}" is not numeric, but setter "${setter}" takes ` +
          `${argType === "float" ? "Float" : "Int"} (facts setterArgTypes). ` +
          `Refusing to emit a malformed literal.`
      );
    }
    return ok(String(value));
  }
  if (value === "true") return ok("True");
  if (value === "false") return ok("False");
  return ok(JSON.stringify(value));
}

// slotFnOf(comp, slotName) -> ok(slotFn) | err. Matched by exact name or canonical
// key (WC slot "selected-icon" canon-matches the elm slot fn "selectedIcon").
export function slotFnOf(comp, slotName) {
  const slots = comp.slotSetters ?? [];
  if (slots.includes(slotName)) return ok(slotName);
  const c = canon(slotName);
  const hit = slots.find((s) => canon(s) === c);
  if (!hit) {
    return err(
      `slot "${slotName}" is not a known slot function of ${comp.module} ` +
        `(slots: ${slots.join(", ") || "none"}). Refusing to guess a slot name.`
    );
  }
  return ok(hit);
}

// slotAttrOf(comp, attr) -> the matching slot-setter name when a CEM attr maps to
// an Elm SLOT (not a settable attr) on this component, else null. Used to DROP
// slot-typed attrs from the setter lines (emitting `M3e.Button.selected True` would
// not type-check against a slot function). NOT a discriminated result — a null is a
// legitimate "this attr is not a slot," not an error.
export function slotAttrOf(comp, attr) {
  const slots = comp.slotSetters ?? [];
  if (slots.includes(attr)) return attr;
  const c = canon(attr);
  return slots.find((s) => canon(s) === c) ?? null;
}

// actionNoneOf(comp) -> ok("<ActionModule>.none") | err. comp.actionModule is null
// when the producer could not verify "none" in the action module's exposing list.
export function actionNoneOf(comp) {
  if (!comp.actionModule) {
    return err(
      `no verified action module for component "${comp.component}" ` +
        `(elm-facts recorded actionModule:null — Action.none is not exposed, or the action module ` +
        `could not be parsed). Refusing to emit an unverified ".none" call.`
    );
  }
  return ok(`${comp.actionModule}.none`);
}

// entryOf(comp, surfaceKey) -> ok({ module, entry, form, finalizer }) | err.
export function entryOf(comp, surfaceKey) {
  const surfaceDef = comp.surfaces?.[surfaceKey];
  if (!surfaceDef) {
    return err(
      `component "${comp.component}" does not emit at surface "${surfaceKey}" ` +
        `(available: ${Object.keys(comp.surfaces ?? {}).join(", ")}).`
    );
  }
  return ok({
    module: surfaceDef.module,
    entry: surfaceDef.entry,
    form: surfaceDef.form,
    finalizer: surfaceDef.finalizer ?? null,
  });
}

// iconNameExpr(symbol, catalog) -> the Elm opaque-`Name` expression for a ligature
// (R-026): `<module>.<constant>` when the ligature has an exposed Name constant,
// else the escape hatch `<module>.<customFn> "<ligature>"`. `catalog` = the
// icon-names.json shape ({ module, customFn, names }). Pure (a ligature with no
// exposed constant uses the documented `custom` escape, never a guessed identifier),
// so it returns a bare string, not a discriminated result.
export function iconNameExpr(symbol, catalog) {
  const constant = catalog.names[symbol];
  if (constant) return `${catalog.module}.${constant}`;
  return `${catalog.module}.${catalog.customFn} ${JSON.stringify(symbol)}`;
}
