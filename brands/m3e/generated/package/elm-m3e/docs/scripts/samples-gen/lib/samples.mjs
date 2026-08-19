// samples.mjs — the pure half of the guide-sample pipeline: read a route module,
// find the Elm code it *displays*, and turn each displayed sample back into real
// Elm that a compiler and a linter can judge.
//
// Nothing here touches the filesystem beyond what its caller hands it, so every
// function below is directly testable (see samples.test.mjs).
//
// ---------------------------------------------------------------------------
// THE TWO SHAPES A DISPLAYED SAMPLE CAN HAVE
//
//   DERIVED   The page already contains the real, compiled thing and a string
//             that claims to show it. `/guide/seams` is the clearest case:
//             `modelViewer` is a live value rendered by `Doc.showcase`, and
//             `realSeamCode` was a hand-copied paraphrase of it. Those two drifted
//             (the live one gained an `auto-rotate` attribute the displayed one
//             never got; `twoColumn` gained a `gap-4` the displayed one never got).
//             For these, the string is DELETED and regenerated from the
//             declaration's own source text — drift stops being possible rather
//             than being watched for.
//
//   EXTRACTED Everything else: a fragment with no live counterpart. It is lifted
//             into `docs/samples/good/` (or `bad/`) as a real module, compiled,
//             and reviewed.
//
// ---------------------------------------------------------------------------
// MARKERS  (grep: `@sample`)
//
// On the compiled declaration a page derives FROM:
//     -- @sample-source <exportName>
//
// On the `String` declaration a page displays, when the default (must compile,
// must pass review) is not the honest expectation:
//     -- @sample skip: <reason>
//     -- @sample expect-compile-error: <reason>
//     -- @sample expect-review <RuleName>: <reason>
//
// `skip` is the only escape hatch and it must carry a reason. A deliberately
// broken sample should be `expect-compile-error`, not `skip`: a page that shows
// code it says the compiler rejects is making a claim, and the claim is cheap to
// verify. Same for a sample whose whole point is that the linter flags it —
// `expect-review` names the rule, so "the linter catches this" stops being a
// promise and becomes a test.

/** The `Doc.Lang` constructors, so a shell/HTML/compiler-output block is left alone. */
const ELM_LANGS = new Set(["Elm"]);

/**
 * Module aliases the guide teaches and therefore writes unqualified in samples.
 * A sample that introduces its own alias (`import M3e.Theme as Theme`) wins over
 * this table; this is only the fallback for the aliases the pages assume the
 * reader already has in scope.
 */
export const DEFAULT_ALIASES = {
  TA: "TypedHtml.Attributes",
  Aria: "TypedHtml.Aria",
  Value: "M3e.Values",
  Theme: "M3e.Component.Theme",
};

/**
 * Bare (unqualified) names a sample may use, and the module each comes from.
 * `Element`/`Attr`/`Node` are the annotations the guide writes out; the rest are
 * the stubs in `Sample.Support` that stand in for "the app around this fragment".
 */
export const BARE_NAMES = {
  Element: "M3e",
  Attr: "M3e",
  Node: "M3e",
  Toast: "Sample.Support",
  appBody: "Sample.Support",
  children: "Sample.Support",
  confirmButtons: "Sample.Support",
  href: "Sample.Support",
  model: "Sample.Support",
  on: "Sample.Support",
  rows: "Sample.Support",
};

/** Constructors of `Sample.Support.Msg`; any one of them pulls in `Msg(..)`. */
export const SUPPORT_MSG_CTORS = ["Save", "SaveClicked", "CloseDialog"];

// ---------------------------------------------------------------------------
// Reading a route module

/** `app/Route/Guide/Seams.elm` -> `Route.Guide.Seams` */
export function moduleNameOf(source) {
  const m = /^module\s+([A-Za-z0-9_.]+)/m.exec(source);
  return m ? m[1] : null;
}

/**
 * Every top-level `name : String` / `name = """…"""` declaration, with the
 * `@sample` marker (if any) that sits immediately above it.
 * @returns {Map<string, { text: string, marker: object|null }>}
 */
export function stringDeclarations(source) {
  const out = new Map();
  // The marker block is separated from the declaration by the blank lines
  // elm-format inserts around a stand-alone comment (at most the two it uses
  // between top-level entries, so a comment on the PREVIOUS declaration can
  // never be mistaken for this one's marker).
  const re =
    /(^(?:[ \t]*--[^\n]*\n)*(?:[ \t]*\n){0,2})^([a-z][A-Za-z0-9_]*)[ \t]*:[ \t]*String\n\2[ \t]*=\n[ \t]*"""([\s\S]*?)"""/gm;
  for (const m of source.matchAll(re)) {
    out.set(m[2], { text: m[3], marker: parseMarker(m[1]) });
  }
  return out;
}

/**
 * Parse the `-- @sample …` line out of a block of leading line comments.
 * @returns {{ kind: string, rule: string|null, reason: string }|null}
 */
export function parseMarker(commentBlock) {
  const lines = (commentBlock || "").split("\n");
  const at = lines.findIndex((l) => /--\s*@sample(-source)?\b/.test(l));
  if (at === -1 || /@sample-source/.test(lines[at])) return null;

  // A reason is usually a sentence or three, so it wraps across the comment
  // lines beneath the marker. Keep all of it: the manifest is where a reader
  // goes to find out WHY a sample is exempt, and half a sentence is no answer.
  const rest = [];
  for (let i = at + 1; i < lines.length; i += 1) {
    const text = lines[i].trim();
    if (!text.startsWith("--")) break;
    rest.push(text.replace(/^--\s?/, "").trim());
  }

  const body = lines[at].replace(/^.*--\s*@sample\s*/, "").trim();
  const split = body.indexOf(":");
  const head = (split === -1 ? body : body.slice(0, split)).trim();
  const firstLine = split === -1 ? "" : body.slice(split + 1).trim();
  const [kind, rule] = head.split(/\s+/);
  return {
    kind,
    rule: rule || null,
    reason: [firstLine, ...rest].filter(Boolean).join(" ").trim(),
  };
}

/**
 * Declarations marked `-- @sample-source <exportName>`: the compiled counterpart
 * a page derives its displayed code from.
 * @returns {Array<{ exportName: string, declName: string, code: string }>}
 */
export function sampleSources(source) {
  const lines = source.replace(/\r\n/g, "\n").split("\n");
  const out = [];
  const blank = (l) => l.trim() === "";
  const col0 = (l) => !blank(l) && !/^\s/.test(l);

  for (let i = 0; i < lines.length; i++) {
    const marker = /^--[ \t]*@sample-source(-body)?[ \t]+([A-Za-z0-9_]+)[ \t]*$/.exec(lines[i]);
    if (!marker) continue;
    const bodyOnly = Boolean(marker[1]);

    // elm-format surrounds a stand-alone line comment with blank lines.
    let j = i + 1;
    while (j < lines.length && blank(lines[j])) j += 1;

    // Skip the type annotation if there is one. The displayed form drops it: a
    // reader meeting a two-column layout does not need the phantom-row signature,
    // and the guide's own hand-written samples never showed one.
    const annotation = /^([a-z][A-Za-z0-9_]*)[ \t]*:/.exec(lines[j] || "");
    if (annotation) {
      j += 1;
      while (j < lines.length && !col0(lines[j])) j += 1;
    }

    const definition = /^([a-z][A-Za-z0-9_]*)([^\n=]*)=[ \t]*$/.exec(lines[j] || "");
    if (!definition) continue;

    // The body is every line under the definition, up to the next column-0 line.
    const body = [];
    let k = j + 1;
    for (; k < lines.length && !col0(lines[k]); k += 1) body.push(lines[k]);
    while (body.length && blank(body[body.length - 1])) body.pop();

    out.push({
      exportName: marker[2],
      declName: definition[1],
      // `-body` shows the expression alone, dedented — for a page whose block is
      // the value itself rather than a named producer (the `M3e.button …` next to
      // the one the compiler rejects, where a binding name would be noise).
      code: bodyOnly ? dedent(body).join("\n") : `${lines[j]}\n${body.join("\n")}`,
    });
    i = k - 1;
  }
  return out;
}

/**
 * Every `codeBlock <Lang> <arg>` application in a route, in source order.
 * `arg` is an identifier (possibly module-qualified) or the literal `"""` when
 * the block is written inline.
 */
export function codeBlockCalls(source) {
  const out = [];
  const re = /\b(?:Doc\.)?codeBlock\s+(?:Doc\.)?([A-Z][A-Za-z0-9_]*)\s+([A-Za-z0-9_.]+|""")/g;
  for (const m of source.matchAll(re)) out.push({ lang: m[1], arg: m[2] });
  return out;
}

/** Is this `Doc.Lang` constructor the one that means "Elm source"? */
export function isElmLang(lang) {
  return ELM_LANGS.has(lang);
}

// ---------------------------------------------------------------------------
// Turning a displayed block into Elm declarations

/**
 * Split a displayed sample into top-level ITEMS: an import, a declaration, or a
 * bare expression. Guide blocks routinely stack several of these (a `-- GOOD`
 * expression next to a `-- WRONG` one), which is why this cannot just be handed
 * to the compiler whole.
 *
 * The grammar is Elm's own layout rule: an item starts at column 0 and continues
 * through every indented line under it. Two refinements matter — a type
 * annotation keeps the definition that follows it (`f : T` then `f x =`), and a
 * comment block at column 0 attaches to the item beneath it.
 *
 * @returns {Array<{ comments: string[], body: string[] }>} plus a possible final
 * entry with an empty `body` holding trailing comments.
 */
export function splitItems(code) {
  const items = [];
  let comments = [];
  let body = [];
  let pendingAnnotation = null;

  const flush = () => {
    if (body.length) {
      items.push({ comments, body: trimTrailingBlank(body) });
      comments = [];
      body = [];
      pendingAnnotation = null;
    }
  };

  for (const line of code.replace(/\r\n/g, "\n").split("\n")) {
    const trimmed = line.trim();
    const atCol0 = trimmed !== "" && !/^\s/.test(line);
    const isComment = trimmed.startsWith("--");

    if (trimmed === "") {
      if (body.length) flush();
      continue;
    }
    if (atCol0 && isComment) {
      if (body.length) flush();
      comments.push(line);
      continue;
    }
    if (atCol0) {
      const definition = /^([a-z_][A-Za-z0-9_]*)/.exec(line);
      if (body.length) {
        const continuesAnnotation =
          pendingAnnotation && definition && definition[1] === pendingAnnotation;
        if (continuesAnnotation) {
          pendingAnnotation = null;
          body.push(line);
          continue;
        }
        flush();
      }
      const annotation = /^([a-z_][A-Za-z0-9_]*)[ \t]*:(?!=)/.exec(line);
      pendingAnnotation = annotation ? annotation[1] : null;
      body.push(line);
      continue;
    }
    body.push(line);
  }
  flush();
  if (comments.length) items.push({ comments, body: [] });
  return items;
}

/** Remove the common leading indentation from a block of lines. */
function dedent(lines) {
  const widths = lines
    .filter((l) => l.trim() !== "")
    .map((l) => l.length - l.trimStart().length);
  const cut = widths.length ? Math.min(...widths) : 0;
  return lines.map((l) => l.slice(cut));
}

function trimTrailingBlank(lines) {
  const out = [...lines];
  while (out.length && out[out.length - 1].trim() === "") out.pop();
  return out;
}

/** Is this item an `import …` line rather than a declaration or expression? */
export function isImportItem(item) {
  return item.body.length > 0 && /^import\s/.test(item.body[0]);
}

/** Is this item `name … =` (a declaration) rather than a bare expression? */
export function isDeclarationItem(item) {
  return item.body.some((l) => /^[a-z_][A-Za-z0-9_]*[^=]*=\s*$/.test(l) || /^[a-z_][A-Za-z0-9_]*[ \t]*:(?!=)/.test(l));
}

/** Code with comments and string literals blanked out, for reference scanning. */
export function stripNoise(code) {
  return code
    .replace(/"""[\s\S]*?"""/g, '""')
    .replace(/"(?:\\.|[^"\\])*"/g, '""')
    .replace(/--[^\n]*/g, "");
}

/** Qualified module references: `M3e.Button.icon` -> `M3e.Button`, `TA.name` -> `TA`. */
export function referencedModules(code) {
  const mods = new Set();
  const clean = stripNoise(code);
  for (const m of clean.matchAll(/\b([A-Z][A-Za-z0-9_]*(?:\.[A-Z][A-Za-z0-9_]*)*)\.[a-z]/g)) {
    mods.add(m[1]);
  }
  // Qualified TYPE references (`TypedHtml.Grouping.DivIs`, `M3e.Kind.Brand`):
  // everything but the final segment is the module.
  for (const m of clean.matchAll(/\b([A-Z][A-Za-z0-9_]*(?:\.[A-Z][A-Za-z0-9_]*)+)\b/g)) {
    const parts = m[1].split(".");
    if (parts.length >= 2) mods.add(parts.slice(0, -1).join("."));
  }
  return mods;
}

/** Names the sample itself binds (declarations and their parameters). */
export function boundNames(items) {
  const bound = new Set();
  for (const item of items) {
    if (isImportItem(item)) continue;
    for (const line of item.body) {
      const m = /^([a-z_][A-Za-z0-9_]*)((?:[ \t]+[a-z_][A-Za-z0-9_]*)*)[ \t]*=\s*$/.exec(line);
      if (!m) continue;
      bound.add(m[1]);
      for (const arg of m[2].split(/\s+/)) if (arg) bound.add(arg);
    }
  }
  return bound;
}

/**
 * Build a `Sample.*` module for one displayed sample.
 *
 * @param {object} spec
 * @param {string} spec.moduleName   e.g. `Sample.Motion.SnackbarCode`
 * @param {string} spec.code         the displayed text, verbatim
 * @param {string} spec.provenance   where the reader sees it
 * @param {(mod: string) => boolean} spec.resolves  does this module exist?
 * @returns {string} Elm source
 */
export function buildSampleModule({ moduleName, code, provenance, resolves }) {
  const items = splitItems(code.trim());
  const own = items.filter(isImportItem);
  const rest = items.filter((it) => !isImportItem(it));

  /** @type {Map<string, { alias: string|null, exposing: Set<string> }>} */
  const imports = new Map();
  const need = (mod, { alias = null, expose = null } = {}) => {
    if (mod === moduleName) return;
    if (!imports.has(mod)) imports.set(mod, { alias: null, exposing: new Set() });
    const entry = imports.get(mod);
    if (alias) entry.alias = alias;
    if (expose) entry.exposing.add(expose);
  };

  // 1. The sample's own imports come first: an alias it declares beats the
  //    default table, because that alias is part of what the page is teaching.
  const ownAliases = {};
  for (const item of own) {
    const m = /^import\s+([A-Za-z0-9_.]+)(?:\s+as\s+([A-Z][A-Za-z0-9_]*))?(?:\s+exposing\s*\(([^)]*)\))?/.exec(
      item.body[0],
    );
    if (!m) continue;
    const [, mod, alias, exposing] = m;
    need(mod, { alias });
    if (alias) ownAliases[alias] = mod;
    for (const name of (exposing || "").split(",")) {
      if (name.trim()) need(mod, { expose: name.trim() });
    }
  }

  const body = rest.map(renderItem).join("\n\n\n");
  const scanned = stripNoise([...rest.map((it) => it.body.join("\n"))].join("\n"));

  // 2. Qualified references -> real modules, resolving aliases.
  for (const ref of referencedModules(scanned)) {
    const aliased = ownAliases[ref] || DEFAULT_ALIASES[ref];
    if (aliased) need(aliased, { alias: ref });
    else if (resolves(ref)) need(ref);
    // A reference that resolves to nothing is left un-imported ON PURPOSE: a bad
    // `import` aborts the compile before type-checking and would hide every real
    // error behind one line. Left alone, elm reports it at the use site.
  }

  // 3. Bare names the sample leans on (`Element`, and the `Sample.Support` stubs
  //    that stand in for the surrounding app) — minus anything it binds itself,
  //    so `view model =` shadows nothing.
  const declared = boundNames(rest);
  const words = new Set(scanned.match(/\b[A-Za-z_][A-Za-z0-9_]*\b/g) || []);
  for (const [name, mod] of Object.entries(BARE_NAMES)) {
    if (words.has(name) && !declared.has(name)) need(mod, { expose: name });
  }
  if (SUPPORT_MSG_CTORS.some((c) => words.has(c))) {
    need("Sample.Support", { expose: "Msg(..)" });
  }

  const importLines = [...imports.entries()]
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([mod, { alias, exposing }]) => {
      const parts = [`import ${mod}`];
      if (alias) parts.push(`as ${alias}`);
      if (exposing.size) parts.push(`exposing (${[...exposing].sort().join(", ")})`);
      return parts.join(" ");
    });

  return (
    `module ${moduleName} exposing (..)\n\n` +
    `{-| GENERATED by \`npm run gen:samples\` — do not edit.\n\n` +
    `This is the Elm shown at ${provenance}, compiled for real.\n` +
    `Change the sample there; this file follows.\n\n-}\n\n` +
    (importLines.length ? importLines.join("\n") + "\n\n\n" : "") +
    body +
    "\n"
  );
}

let anonymousCount = 0;

function renderItem(item, index) {
  const comments = item.comments.join("\n");
  if (item.body.length === 0) return comments;
  const head = comments ? comments + "\n" : "";
  if (isDeclarationItem(item)) return head + item.body.join("\n");
  // A bare expression: give it a name so it is a declaration the compiler will
  // actually check. `_` suffix keeps it out of the reader's way if it ever leaks.
  anonymousCount += 1;
  const name = `shown${index}_`;
  return `${head}${name} =\n` + item.body.map((l) => "    " + l).join("\n");
}

/** Reset the counter used for anonymous expression names (tests). */
export function resetAnonymousCount() {
  anonymousCount = 0;
}

// ---------------------------------------------------------------------------
// Triple-quoted string literals
//
// `stringDeclarations` hands back the SOURCE text between the `"""` delimiters,
// so a sample containing a lambda reads `\\_ model -> model` there and `\_ …` on
// the page. Compiling the source form would be compiling something no reader ever
// sees, so unescape on the way into a sample module and re-escape on the way back
// into a generated string.

/** Elm `"""…"""` source text -> the characters the page actually renders. */
export function unescapeTripleQuoted(raw) {
  return raw.replace(/\\(u\{([0-9A-Fa-f]+)\}|.)/g, (whole, esc, hex) => {
    if (hex) return String.fromCodePoint(parseInt(hex, 16));
    switch (esc) {
      case "n":
        return "\n";
      case "t":
        return "\t";
      case "r":
        return "\r";
      case "\\":
        return "\\";
      case '"':
        return '"';
      default:
        return whole;
    }
  });
}

/** The characters to render -> Elm `"""…"""` source text. */
export function escapeTripleQuoted(text) {
  return text.replace(/\\/g, "\\\\").replace(/"""/g, '\\"\\"\\"');
}
