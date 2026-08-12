// Shared fixture-suite table for the phantom golden harness.
//
// Extracted so `gate.mjs` (verify) and `bless.mjs` (regenerate) cannot drift
// apart. Three suites deliberately SHARE `expected/`, partitioned by
// `filterPrefix` — so anything touching that directory must respect the prefix
// or it will clobber a sibling suite's goldens.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const here = path.dirname(fileURLToPath(import.meta.url));
export const repo = path.resolve(here, "..", "..");
export const elm = path.join(repo, "node_modules", ".bin", "elm");
export const elmFormat = path.join(repo, "node_modules", ".bin", "elm-format");
export const irSrc = path.resolve(repo, "..", "elm-html-intermediate-representation", "src");

export const SUITES = [
  {
    name: "mini",
    cem: path.join(here, "fixtures", "mini.cem.json"),
    config: path.join(here, "fixtures", "config.json"),
    expected: path.join(here, "expected"),
    acid: path.join(here, "acid"),
    filterPrefix: "Mini",
  },
  {
    name: "native",
    cem: path.join(here, "native", "fixtures", "nano.cem.json"),
    config: path.join(here, "native", "fixtures", "config.json"),
    expected: path.join(here, "native", "expected"),
    acid: path.join(here, "native", "acid"),
    filterPrefix: "TypedHtml",
  },
  {
    name: "hostile",
    cem: path.join(here, "fixtures", "hostile.cem.json"),
    config: path.join(here, "fixtures", "hostile-config.json"),
    expected: path.join(here, "expected"),
    acid: path.join(here, "acid", "hostile"),
    filterPrefix: "Hz",
    // The KERNEL-BLOCKED report. `hz-blocked` declares five attributes
    // `elm/virtual-dom` cannot express, and the generator OMITS each rather than
    // failing the run — the manifest is right, and it is the kernel that cannot
    // express them, so no manifest or config edit could clear a failure. Omitting
    // is therefore correct, and SILENTLY omitting is not: the goldens cannot tell
    // "dropped on purpose" from "never declared", so the info note is the only
    // evidence. Each needle names the attribute AND the kernel function
    // responsible, because a report that does not say why invites the next reader
    // to add the setter back.
    expectInfoContains: [
      ["omitted attr 'formaction' on Blocked", "_VirtualDom_noOnOrFormAction", "data-formaction"],
      // The `^on` half of `/^(on|formAction$)/i` — future-proofing, so a manifest
      // refresh that adds a real `on*` content attribute cannot ship a dead setter.
      ["omitted attr 'onbeforetoggle' on Blocked", "_VirtualDom_noOnOrFormAction"],
      // …and the same regex catching an INNOCENT name, because `^on` has no word
      // boundary. `once` really does render as `data-once`; the kernel over-reaches
      // and the honest response is to report it, not to emit a setter that lies.
      ["omitted attr 'once' on Blocked", "data-once"],
      // Not a rewrite at all: `_VirtualDom_render` calls `createElement(tag)` with
      // no options argument, so a customized built-in is never upgraded.
      ["omitted attr 'is' on Blocked", "createElement(vNode.__tag)"],
      // The PROPERTY guard, reached only because config `attrForm` selects the
      // property form for `innerhtml` (whose `fieldName` is `innerHTML`).
      ["omitted attr 'innerhtml' on Blocked", "_VirtualDom_noInnerHtmlOrFormAction"],
    ],
  },
  {
    name: "barren",
    cem: path.join(here, "fixtures", "barren.cem.json"),
    config: path.join(here, "fixtures", "barren-config.json"),
    expected: path.join(here, "expected"),
    acid: path.join(here, "acid", "barren"),
    filterPrefix: "Br",
  },
  {
    // The `row` axis on `_globals`. Its own `expected/` dir rather than a prefix
    // partition of the shared one: this suite exists to prove the OTHER suites'
    // goldens do not move, so it must not be able to write into their directory.
    name: "openrow",
    cem: path.join(here, "fixtures", "openrow.cem.json"),
    config: path.join(here, "fixtures", "openrow-config.json"),
    expected: path.join(here, "openrow", "expected"),
    acid: path.join(here, "acid", "openrow"),
  },
  {
    name: "error-case",
    cem: path.join(here, "fixtures", "error-case.cem.json"),
    config: path.join(here, "fixtures", "error-case-config.json"),
    expectError: true,
    expectErrorContains: [
      // Family 1: _top / top / top_ collision (in the position enum).
      ["top_", "top"],
      // Family 2: AUTO / auto collision (in the mode enum).
      ["AUTO", "auto"],
      // …and the ready-to-paste resolution hint.
      "_renames",
    ],
  },
  {
    // Two elements sharing a `home` module declare one attribute at two SCALAR
    // types. One Elm module cannot expose one setter at two types, so the run must
    // FAIL — this is the elm-typed-html `datetime` regression, where <ins>/<del>
    // (`string`) and <time> (`number`) all live in the `Text` home and the home
    // module's dedupe silently published <time>'s `Float` for all three.
    name: "attr-conflict",
    cem: path.join(here, "fixtures", "attr-conflict.cem.json"),
    config: path.join(here, "fixtures", "attr-conflict-config.json"),
    expectError: true,
    expectErrorContains: [
      // Names the module, the attribute, and BOTH sides with their types — a report
      // that named only the survivor would leave the dropped side invisible again.
      ["TYPE CONFLICT", "Cf.Prose", "'datetime'", "Ins : String", "Time : Float"],
      // …and every escape hatch, so the message is actionable without reading source.
      ["attrTypes", "_renames", "home"],
    ],
  },
  {
    // RC5: `shared:<role>` is a CLOSED vocabulary. An unlisted role mints a field
    // no other brand will ever name — a private kind wearing a cross-library name,
    // which is the `"html"` defect itself. EVERY entry point must be guarded: the
    // slot side (`kinds`), the producer side (`kind`), the atom side (`_atoms`) and
    // the crossing side (`_coerce[].to`).
    name: "atom-vocab",
    cem: path.join(here, "fixtures", "atom-vocab.cem.json"),
    config: path.join(here, "fixtures", "atom-vocab-config.json"),
    expectError: true,
    expectErrorContains: [
      // The SLOT side, located precisely enough to fix without grepping.
      ["Card.body", "shared:phrasng"],
      // The PRODUCER side (`kind`), reported separately rather than short-circuiting.
      ["Label.kind", "shared:caption"],
      // The ATOM side — `_atoms` mints the leaf constructor AND its `shared<Role>`
      // field, so a typo here ships a `txet` constructor nothing can consume.
      ["_atoms", "shared:txet"],
      // The CROSSING side. A `shared:` target in `_coerce` was unvalidated AND
      // unresolved: the emitter wrote the config string straight into a type
      // annotation. Named by its `name`, because a brand may declare many.
      ["_coerce 'asPhrasing'", "shared:phrasin"],
      // The whole legal vocabulary, so the fix needs no source dive…
      ["shared:flow", "shared:icon", "shared:link", "shared:phrasing", "shared:text"],
      // …and WHY it is closed, so nobody "fixes" it by widening the list.
      "unifies across packages",
    ],
  },
];

/** Every .elm file under `dir`, as paths relative to `base`. */
export const walk = (dir, base = dir) =>
  fs.existsSync(dir)
    ? fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
        const full = path.join(dir, e.name);
        if (e.isDirectory()) return walk(full, base);
        return e.name.endsWith(".elm") ? [path.relative(base, full)] : [];
      })
    : [];

/** The subset of `files` that belongs to `suite`, honouring the shared-dir prefix. */
export const ownedBy = (suite, files) =>
  suite.filterPrefix
    ? files.filter((f) => f.startsWith(suite.filterPrefix) || f === suite.filterPrefix + ".elm")
    : files;
