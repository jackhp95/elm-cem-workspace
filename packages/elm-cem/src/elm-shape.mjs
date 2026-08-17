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

// renderNativeAttr(attrSeam, name, value) -> `<seam>.attribute "n" "v"`.
export function renderNativeAttr(attrSeam, name, value) {
  return `${attrSeam}.attribute ${JSON.stringify(name)} ${JSON.stringify(value)}`;
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
