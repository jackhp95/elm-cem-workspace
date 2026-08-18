// html-label emitter (task B1; plans/01-architecture.md §5, "Web Components"
// label) — the built-in emitter every CEM+Figma consumer gets. Turns ONE
// confirmed correspondence entry (src/correspond/schema.json) into one
// `.figma.ts` Code Connect template PER FUSED FIGMA SET, reproducing the
// exact template form that was proven to publish live on 2026-07-10:
//   research/spikes/01-publish-gate/M3eButton.figma.ts
//   (copied unmodified into profiles/m3-kit/fixtures/M3eButton.webcomponents.figma.ts)
//
// Form (evidence #1-#2, plans/00-mission-and-decisions.md):
//   // url=<node URL>
//   import figma from "figma"
//   const instance = figma.selectedInstance
//   const <attr> = instance.getEnum("<FigmaProp>", { <FigmaKey>: "<cemValue>", ... })   (mapped variant axes)
//   const <var> = instance.getString("<Figma Prop>")                                    (text props)
//   const <var> = instance.getBoolean("<Figma Prop>")                                   (boolean props)
//   export default { example: figma.code`<tag attr="${..}">${..}</tag>`, imports, id, metadata: { nestable: true } }
//
// PURE function: no fs, no network, no process.env — this mirrors the
// emitter-api.mjs contract Task B2 formalizes (`emit(entry, ctx) -> [{path,
// contents}]`) ahead of that task existing. Callers (src/cli.mjs, tests) own
// reading/writing.
//
// Footguns enforced here (VOLT-2003 lineage, verified still real):
//   - node URLs are MAIN-FILE form only — throws on any "/branch/" segment.
//   - getEnum keys are the Figma variant option's VERBATIM, case-sensitive
//     string ("XSmall", not "xsmall") — the value side comes from
//     axes[].valueMap, which the matcher already stores un-lowercased.
//   - a BOOLEAN prop bound to a slot (binding "slot:icon") uses the
//     conditional-line idiom lifted from VOLT-2003's generator
//     (code-connect/generate.mjs in ui.VOLT-2003, `disabledLine` pattern):
//     `const xLine = x ? figma.code`...` : figma.code``` — the slotted
//     element only appears when the Figma boolean is on.
//   - a prop with `unmapped` set (e.g. "Show focus indicator": no CEM
//     counterpart) is NEVER silently dropped: it gets a visible header
//     comment line, never a fabricated binding.
//   - a MAPPED prop (binding present, not `unmapped`) whose shape isn't one
//     of the two this emitter knows how to render — kind:"text" bound to
//     "content", or kind:"boolean" bound to "slot:*" (optionally paired with
//     a same-slot mapped instanceSwap) — is NEVER silently dropped either:
//     `emitEntry` throws, naming the prop/kind/binding, rather than produce
//     output that's silently missing that prop's data.
//
// ICON GLYPH RESOLUTION (was a KNOWN OPEN QUESTION; RESOLVED 2026-07-14,
// approach A): a mapped INSTANCE_SWAP glyph is resolved by a per-file
// `getEnum(prop, { <figmaName>: 'name="<symbol>"[ filled]', … })` keyed by the
// swap instance's figmaName (from the profile's iconTable), whose value is the
// whole attribute fragment, inserted BARE into `<m3e-icon slot="…" ${glyph}>`.
// The parent OWNS the slotted tag because Code Connect 1.4.9 cannot inject a
// `slot=` onto a nested child (verified against connect/intrinsics.js,
// html/parser.js, connect/raw_templates.js — see buildSlotBooleanBlock). This
// form is CC-parser-validated (`figma connect publish --dry-run` → "All Code
// Connect files are valid"). The `getPropertyValue(prop)` path survives only as
// a fallback for a profile with no iconTable. STILL PENDING: a live
// `get_code_connect_map` pass confirming getEnum's key == the runtime swap
// instance's figmaName (blocked on a Code-Connect-entitled Figma account).
//
// TASK B2 UPDATE: `emitEntry`/`emitConfirmed` below are UNCHANGED (byte-for-
// byte same behavior, same `(entry, config)` signature) — the golden-
// equivalence tests in test/html-label.test.mjs must stay green, and they
// call these two functions directly with the old flat `config` shape. What
// changed: the small string-mechanics helpers this module used to define
// locally (`figmaFileSlug`, `assertMainFileUrl`, `buildNodeUrl`, and the
// kebab-case slugifier) now live in ./emitter-api.mjs, shared with every
// other emitter (B3's Elm emitter included) instead of being re-derived
// per-emitter — imported back under their original local names below, so
// `_internal` still exposes the same functions under the same names; only
// their definition moved; behavior is identical (same source, just one
// copy instead of duplicated ones).
//
// Also new: the `emitter` export at the bottom of this file — the
// `{name, label, emit(entry, ctx)}` object emitter-api.mjs's interface
// describes, and what `src/emit/run.mjs`'s built-in registry dispatches to.
// It is a thin adapter over `emitEntry`'s own skip rules (iconTable /
// code-only entries -> `[]`, matching what `emitConfirmed` already did),
// translating the new `ctx` shape into the old flat `config` shape — not a
// reimplementation.

import {
  figmaFileSlug,
  assertMainFileUrl,
  buildNodeUrl,
  slugify as kebab,
} from "./emitter-api.mjs";
import { renderChildrenHtml } from "./example-content.mjs";

const IDENT_RE = /^[A-Za-z_$][A-Za-z0-9_$]*$/;

function objKey(key) {
  return IDENT_RE.test(key) ? key : JSON.stringify(key);
}

// iconTable -> the getEnum() body rows for a glyph lookup, keyed by
// figmaName, valued by the `name="<symbol>"[ filled]` attribute fragment.
// Three call sites (buildSlotBooleanBlock, buildDefaultSlotIconBlock,
// buildVisibilityAxisSlotBlock) built this byte-for-byte identically before
// being deduped here (thermonuclear audit, Theme 6 "other structural
// findings"): dedupe by figmaName (the kit repeats some icon names across
// nodes, e.g. "alarm" at two node ids — those collapse to one row), fail
// loud on a genuinely CONFLICTING dup (same figmaName, different glyph —
// a data bug, never silently pick one), then sort by figmaName for
// byte-stable output.
function iconGetEnumRows(iconTable) {
  const byName = new Map();
  for (const icon of iconTable) {
    const fragment = `name="${icon.symbolName}"${icon.filled ? " filled" : ""}`;
    const prior = byName.get(icon.figmaName);
    if (prior !== undefined && prior !== fragment) {
      throw new Error(
        `html-label emitter: iconTable has conflicting rows for figmaName "${icon.figmaName}" — ` +
          `${JSON.stringify(prior)} vs ${JSON.stringify(fragment)}; cannot build a getEnum with a duplicate key`
      );
    }
    byName.set(icon.figmaName, fragment);
  }
  return [...byName.entries()]
    .sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0))
    .map(([figmaName, fragment]) => `  ${objKey(figmaName)}: ${JSON.stringify(fragment)},`)
    .join("\n");
}

// camelCase of an arbitrary Figma display name ("Label text" -> "labelText",
// "Show icon" -> "showIcon").
function camel(name) {
  const parts = name
    .split(/[^A-Za-z0-9]+/)
    .filter(Boolean)
    .map((w) => w[0].toUpperCase() + w.slice(1).toLowerCase());
  if (parts.length === 0) return "value";
  return parts[0][0].toLowerCase() + parts[0].slice(1) + parts.slice(1).join("");
}

// Variable name for a TEXT prop bound to `content`: camelCase, then drop a
// redundant trailing "Text" (a common Figma property-naming convention —
// "Label text", "Header text", "Supporting text" — the CEM-facing slot is
// just the label/header/etc., not "…Text"). Reproduces the golden fixture's
// `const label = instance.getString("Label text")` exactly.
function contentVarName(prop) {
  const v = camel(prop.figmaProp);
  return prop.kind === "text" && v !== "text" && /Text$/.test(v) ? v.slice(0, -4) : v;
}

// setSlugOf(figmaSet, figmaAxisNames?) -> the id suffix distinguishing this fused set.
// Prefers the fused attr VALUE (e.g. "outlined" for the "Button - outline"
// set, whose fixedAttrs.variant is "outlined" — the CEM value, not Figma's
// raw set-name suffix "outline") since that's the value that actually
// differs between generated files; falls back to a kebab of the set name for
// non-fused (single-set) entries, whose fixedAttrs is `{}`.
//
// `figmaAxisNames` is an optional Set<string> of Figma VARIANT axis names
// (entry.axes[].figmaProp). Keys in that set are axis-pin entries (not CEM
// attrs) and must be excluded from the slug — only CEM-attr fixedAttrs keys
// (fusion bindings like `variant`, `shape`) drive the slug.
function setSlugOf(figmaSet, figmaAxisNames = new Set()) {
  const cemAttrs = Object.entries(figmaSet.fixedAttrs ?? {})
    .filter(([k]) => !figmaAxisNames.has(k))
    .map(([, v]) => kebab(v));
  if (cemAttrs.length > 0) return cemAttrs.join("-");
  return kebab(figmaSet.setName);
}

// One `getEnum` block per MAPPED variant axis. Keys are the Figma option's
// VERBATIM string (case-sensitive footgun); bare (unquoted) when a valid JS
// identifier, quoted otherwise — matches the golden fixture's style exactly
// for this kit's option names (XSmall, Round, ...).
//
// MULTI-ATTR axis (kind:"multi-boolean"): one getEnum call per sub-attr, each
// yielding a boolean. The var-name for sub-attr `checked` is `typeChecked`
// (axis name camelCase + attr capitalized) to avoid naming collisions when
// multiple attrs derive from the same axis.
function buildAxisBlock(axis) {
  if (axis.kind === "multi-boolean") {
    // Produce one block per sub-attr. Each block gets its own variable named
    // <axisNameCamel><AttrNameCapitalized> (e.g. axis "Type", attr "checked"
    // → variable "typeChecked"). The value maps to true/false (booleans).
    const axisVarBase = camel(axis.figmaProp);
    const subBlocks = axis.attrs.map(({ attr, valueMap }) => {
      const varName = axisVarBase + attr[0].toUpperCase() + attr.slice(1);
      const lines = Object.entries(valueMap)
        .map(([figmaKey, boolStr]) => `  ${objKey(figmaKey)}: ${boolStr === "true"},`)
        .join("\n");
      return {
        varName,
        attr,
        code: `const ${varName} = instance.getEnum(${JSON.stringify(axis.figmaProp)}, {\n${lines}\n})`,
      };
    });
    return { kind: "multi-boolean", subBlocks };
  }
  // A single mapped axis whose valueMap is purely true/false targets a BOOLEAN
  // CEM attr (Selected->selected, Modal->modal, …). Emitting attr="${x}" is a
  // bug: in HTML a boolean attribute with ANY value (even "false") is PRESENT,
  // so `checked="false"` renders checked=true. Map to JS booleans and render
  // bare-or-omit (`${checked ? "checked" : ""}`), the same idiom multi-boolean
  // axes already use.
  const boolean = isBooleanAxis(axis);
  const lines = Object.entries(axis.valueMap)
    .map(([figmaKey, cemValue]) => `  ${objKey(figmaKey)}: ${boolean ? cemValue === "true" : JSON.stringify(cemValue)},`)
    .join("\n");
  return {
    varName: axis.attr,
    boolean,
    code: `const ${axis.attr} = instance.getEnum(${JSON.stringify(axis.figmaProp)}, {\n${lines}\n})`,
  };
}

// A single-attr axis is boolean iff every mapped value is the literal "true"/"false".
// (Non-boolean axes — size/shape/variant — map to enum strings like "extra-small".)
function isBooleanAxis(axis) {
  const vals = Object.values(axis.valueMap ?? {});
  return vals.length > 0 && vals.every((v) => v === "true" || v === "false");
}

// A Figma-only, unmapped axis/prop is never silently dropped: it earns a
// visible header comment line instead of a binding (the schema's own
// `unmapped` reason string, verbatim).
function unmappedNote(kindLabel, item) {
  return ` * ${kindLabel} (unmapped): ${item.figmaProp} — ${item.unmapped}`;
}

// The icon tag placed inside a boolean-bound icon slot. Every m3e-* icon slot
// (icon / trailing-icon / selected-icon, per ButtonElement.d.ts @slot docs)
// is filled by an `<m3e-icon>` element carrying the HOST's `slot="…"`
// attribute — the tag itself is always m3e-icon regardless of which slot.
const ICON_TAG = "m3e-icon";

// buildSlotBooleanBlock(prop, entry, config) -> { condVar, lineVar, code, swapProp }
//
// The VOLT-2003 conditional-line idiom (code-connect/generate.mjs's
// `disabledLine` pattern in ui.VOLT-2003): a boolean prop bound to a slot
// renders its slotted element ONLY when the Figma boolean is on; when off,
// the interpolation contributes an empty string, never an empty/broken tag.
//
// `swapProp` (possibly undefined) is returned so the caller can mark that
// mapped INSTANCE_SWAP prop as "consumed" by this shape — it is the only
// context in which a mapped instanceSwap prop is handled at all; one that
// isn't paired with a slot-boolean this way is an unhandled shape (see
// emitEntry's unhandled-mapped-prop guard).
function buildSlotBooleanBlock(prop, entry, config) {
  const condVar = camel(prop.figmaProp);
  const slotName = prop.binding.slice("slot:".length);
  const lines = [`const ${condVar} = instance.getBoolean(${JSON.stringify(prop.figmaProp)})`];

  // A mapped INSTANCE_SWAP prop bound to the SAME slot supplies the glyph;
  // otherwise a profile-configured placeholder literal is baked in. See the
  // module header's "KNOWN OPEN QUESTION" note re: getPropertyValue.
  const swapProp = entry.props.find(
    (p) => p.kind === "instanceSwap" && p.binding === prop.binding && !p.unmapped
  );

  // The <m3e-icon>'s attribute fragment (everything after slot="…"). Code
  // Connect cannot place a nested child into a NAMED slot — verified against
  // @figma/code-connect 1.4.9: figma.slot/figma.instance render a child at a
  // CONTENT position via __render__() (connect/intrinsics.js) with no
  // attribute injection, JSDOM rejects duplicate attrs (html/parser.js), and
  // templates may import only "figma" so a shared icon-map is impossible
  // (connect/raw_templates.js). So the PARENT owns the <m3e-icon slot="…">
  // tag and resolves the glyph itself.
  let iconAttrs;
  if (swapProp && config.iconTable && config.iconTable.length > 0) {
    // Approach A: a per-file getEnum keyed by the swap instance's figmaName,
    // whose value is the whole `name="<symbol>"[ filled]` attribute fragment
    // (symbolName from the iconTable; ` filled` on a filled row). The rows
    // inline per icon-bearing file — generated + deterministic, the only shape
    // CC 1.4.9 allows (no shared import to dedupe them). Rows sorted by
    // figmaName for byte-stable output.
    const glyphVar = `${condVar}Glyph`;
    const rows = iconGetEnumRows(config.iconTable);
    lines.push(`const ${glyphVar} = instance.getEnum(${JSON.stringify(swapProp.figmaProp)}, {\n${rows}\n})`);
    iconAttrs = "${" + glyphVar + "}";
  } else if (swapProp) {
    // Fallback when no iconTable is configured: the raw INSTANCE_SWAP value —
    // NOT a Material Symbols ligature, a best-effort so a profile lacking an
    // iconTable still emits something. Prefer approach A above.
    const glyphVar = `${condVar}Glyph`;
    lines.push(`const ${glyphVar} = instance.getPropertyValue(${JSON.stringify(swapProp.figmaProp)})`);
    iconAttrs = `name="\${${glyphVar}}"`;
  } else {
    if (!config.iconPlaceholder) {
      throw new Error(
        `html-label emitter: "${prop.figmaProp}" is a slot-bound boolean with no mapped ` +
          `INSTANCE_SWAP prop and no config.iconPlaceholder — nothing to render when true`
      );
    }
    iconAttrs = `name="${config.iconPlaceholder}"`;
  }

  const lineVar = `${condVar}Line`;
  lines.push(
    `const ${lineVar} = ${condVar} ? figma.code\`\\n  <${ICON_TAG} slot="${slotName}" ${iconAttrs}></${ICON_TAG}>\` : figma.code\`\``
  );

  return { condVar, lineVar, code: lines.join("\n"), swapProp };
}

// buildDefaultSlotIconBlock(prop, config) -> { glyphVar, code }
//
// RC2: an INSTANCE_SWAP icon prop bound to the DEFAULT (unnamed) slot
// (binding "slot:") renders the icon UNCONDITIONALLY — there is no
// boolean guard (icon-button always has an icon; the glyph is always
// driven). Output: `<m3e-icon ${glyph}></m3e-icon>` (NO slot attr;
// the empty-name slot IS the default slot per the Web Components spec).
//
// Glyph resolution follows approach A exactly (same iconTable getEnum
// path as buildSlotBooleanBlock) — only the slot placement differs.
function buildDefaultSlotIconBlock(prop, config) {
  const glyphVar = camel(prop.figmaProp) + "Glyph";
  let glyphCode;
  if (config.iconTable && config.iconTable.length > 0) {
    const rows = iconGetEnumRows(config.iconTable);
    glyphCode = `const ${glyphVar} = instance.getEnum(${JSON.stringify(prop.figmaProp)}, {\n${rows}\n})`;
  } else {
    glyphCode = `const ${glyphVar} = instance.getPropertyValue(${JSON.stringify(prop.figmaProp)})`;
  }
  return { glyphVar, code: glyphCode };
}

// axisOptionsOf(axis) -> string[] — ALL Figma option values for a variant axis.
//
// Mapped axes carry their options as `valueMap` keys (the exact Figma strings,
// verbatim). Unmapped axes embed the options in the `unmapped` reason string
// using the format "... (options: A, B, C)" — extract them with a regex.
// Returns [] when neither structure is available (shouldn't happen for a
// well-formed entry, but never throw here — callers decide what to do).
function axisOptionsOf(axis) {
  if (axis.valueMap !== undefined) {
    return Object.keys(axis.valueMap);
  }
  const m = typeof axis.unmapped === "string" && axis.unmapped.match(/\(options:\s*([^)]+)\)/);
  if (!m) return [];
  return m[1].split(",").map((s) => s.trim()).filter(Boolean);
}

// buildLiteralIconSlotBlock(prop) -> { iconTag, code } | { condVar, lineVar, code }
//
// RC5 / search-bar: a prop with kind:"literalIcon" carries a STATIC iconName
// (not runtime-resolved — the icon is baked at codegen time, not Figma-driven).
// The binding is "slot:<name>" (e.g. "slot:leading", "slot:trailing").
//
// Two sub-cases:
//   A. UNCONDITIONAL (no boolean gate): the prop lacks a paired boolean guard.
//      Emit a bare static tag in the example: no code-block variable.
//      Returns { kind:"unconditional", slotName, iconName }.
//
//   B. CONDITIONAL (has a `booleanGate` prop name on the literalIcon entry —
//      currently unused by search-bar but reserved for future shapes): emits
//      the conditional-line idiom (getBoolean + ternary figma.code).
//      Returns { kind:"conditional", condVar, lineVar, code }.
//
// The caller decides how to place the result in the example template.
function buildLiteralIconSlotBlock(prop, entry) {
  const slotName = prop.binding.slice("slot:".length);
  const iconName = prop.iconName;

  // Check for a paired boolean gate: a kind:"boolean" prop whose figmaProp
  // matches prop.booleanGate (if present). Search-bar does not use this path —
  // its Show-leading-icon and Show-1st-trailing-icon are unconditional.
  const gatePropName = prop.booleanGate;
  const gateProp = gatePropName
    ? entry.props.find((p) => p.kind === "boolean" && p.figmaProp === gatePropName)
    : undefined;

  if (gateProp) {
    const condVar = camel(gateProp.figmaProp);
    const lineVar = `${condVar}Line`;
    const lines = [
      `const ${condVar} = instance.getBoolean(${JSON.stringify(gateProp.figmaProp)})`,
      `const ${lineVar} = ${condVar} ? figma.code\`\\n  <${ICON_TAG} slot="${slotName}" name="${iconName}"></${ICON_TAG}>\` : figma.code\`\``,
    ];
    return { kind: "conditional", condVar, lineVar, gateProp, code: lines.join("\n") };
  }

  // Unconditional: no code block needed; the static tag goes directly in the
  // example. Return slotName + iconName for the template-assembly step.
  return { kind: "unconditional", slotName, iconName };
}

// buildNamedInputSlotBlock(prop) -> { varName, code }
//
// RC5 / search-bar: a prop with kind:"text" and binding:"slot:<name>"
// (binding !== "content") where the schema additionally carries a `slotTag`
// (e.g. "input"). Emits:
//   const <var> = instance.getString("<figmaProp>")
// and places `<input slot="<name>" placeholder="${<var>}"></input>` into the
// example. Distinct from the existing text→"content" path (default-slot label).
function buildNamedInputSlotBlock(prop) {
  const varName = camel(prop.figmaProp);
  const code = `const ${varName} = instance.getString(${JSON.stringify(prop.figmaProp)})`;
  return { varName, slotName: prop.binding.slice("slot:".length), slotTag: prop.slotTag ?? "input", code };
}

// buildVisibilityAxisSlotBlock(prop, entry, config) -> { condVar, lineVar, code } | null
//
// RC2 / chip family: an INSTANCE_SWAP prop bound to a NAMED slot (binding
// "slot:<name>") WITHOUT a boolean gate, but with a `visibilityAxis` +
// `visibleWhen` annotation. The slot is shown ONLY when the visibilityAxis
// Figma prop's current value is in `visibleWhen[]`; all other values hide it.
//
// Emits:
//   const <base>Shown = instance.getEnum("<visibilityAxis>", {
//     "<visibleWhen[0]>": true, ..., "<other values>": false
//   })
//   const <base>Glyph = instance.getEnum("<figmaProp>", { <iconTable rows> })
//   const <base>Line = <base>Shown ? figma.code`\n  <m3e-icon slot="<slot>" ${<base>Glyph}></m3e-icon>` : figma.code``
//
// where `<base>` = camel(prop.figmaProp).
//
// GRACEFUL OMIT (decision #1): if the iconTable is empty/absent (e.g. a
// branded/favicon icon not in the Material Symbols table), return null — the
// caller skips this prop rather than throwing. A missing iconTable is NOT an
// error; it means the icon cannot be represented in generated code.
//
// All axis options (visibleWhen = true, remainder = false) come from
// axisOptionsOf(); if neither a valueMap nor a parseable unmapped string is
// present, a partial map (visibleWhen only → true, no false entries) is
// emitted — better than a throw.
function buildVisibilityAxisSlotBlock(prop, entry, config) {
  // Graceful omit when no iconTable available for this named-slot instanceSwap.
  if (!config.iconTable || config.iconTable.length === 0) {
    return null;
  }

  const base = camel(prop.figmaProp);
  const slotName = prop.binding.slice("slot:".length);
  const visibilityAxis = prop.visibilityAxis;
  const visibleWhen = new Set(prop.visibleWhen ?? []);
  const lines = [];

  // --- visibility condition (getEnum on the visibilityAxis) ---
  const condVar = `${base}Shown`;
  const axisEntry = (entry.axes ?? []).find((a) => a.figmaProp === visibilityAxis);
  let allOptions = axisEntry ? axisOptionsOf(axisEntry) : [];
  // Ensure all visibleWhen values appear, even if not in allOptions (paranoid guard).
  for (const v of visibleWhen) {
    if (!allOptions.includes(v)) allOptions = [...allOptions, v];
  }
  const visibilityRows = allOptions
    .map((opt) => `  ${objKey(opt)}: ${visibleWhen.has(opt)},`)
    .join("\n");
  lines.push(`const ${condVar} = instance.getEnum(${JSON.stringify(visibilityAxis)}, {\n${visibilityRows}\n})`);

  // --- glyph resolution (approach A — same iconTable getEnum as buildSlotBooleanBlock) ---
  const glyphVar = `${base}Glyph`;
  const glyphRows = iconGetEnumRows(config.iconTable);
  lines.push(`const ${glyphVar} = instance.getEnum(${JSON.stringify(prop.figmaProp)}, {\n${glyphRows}\n})`);

  // --- conditional line ---
  const lineVar = `${base}Line`;
  lines.push(
    `const ${lineVar} = ${condVar} ? figma.code\`\\n  <${ICON_TAG} slot="${slotName}" \${${glyphVar}}></${ICON_TAG}>\` : figma.code\`\``
  );

  return { condVar, glyphVar, lineVar, code: lines.join("\n") };
}

// emitIconTableEntry(entry, config) -> [{ path, contents, id }]
//
// iconTable-specific emit: when `entry.kind === "iconTable"`, emit ONE file
// per icon row (141 for m3e-icon). Each row maps a real Figma icon node →
// `<m3e-icon name="<symbolName>"[ filled]>`.
//
// COLLISION HANDLING: the table has 18 duplicate (symbolName, filled) pairs —
// different Figma nodes, same symbol. All 141 rows get a binding (no binding
// is dropped). When a (symbolName, filled) filename would repeat, the second
// occurrence gets a `-2` suffix, the third `-3`, etc. (deterministic by the
// icons-array order — first occurrence is unsuffixed). A truly unhandled
// collision (unreachable by this suffix scheme) throws loudly.
//
// Filename / id: `m3e-icon-<kebab(symbolName)>[-filled][-N]`
// (kebab turns underscores → dashes for tidy filenames; symbolName itself
// already consists of word-chars so no other transformation needed).
//
// PURE: no fs, no network — same contract as emitEntry.
function emitIconTableEntry(entry, config) {
  const files = [];
  // Track how many times each base filename has been used, for collision suffix.
  const usedBases = new Map();

  for (const row of entry.icons) {
    const baseName = `m3e-icon-${kebab(row.symbolName)}${row.filled ? "-filled" : ""}`;

    // Collision-safe suffix: first occurrence = no suffix; subsequent = -2, -3, ...
    const priorCount = usedBases.get(baseName) ?? 0;
    const suffix = priorCount === 0 ? "" : `-${priorCount + 1}`;
    usedBases.set(baseName, priorCount + 1);

    const id = `${baseName}${suffix}`;
    const url = buildNodeUrl(config, row.figmaNodeId);
    const filledAttr = row.filled ? " filled" : "";
    const example = `<m3e-icon name="${row.symbolName}"${filledAttr}></m3e-icon>`;

    const importsArr = (config.imports ?? []).map((i) => JSON.stringify(i)).join(", ");

    const contents =
      `// url=${url}\n` +
      `import figma from "figma"\n` +
      `\n` +
      `export default {\n` +
      `  example: figma.code\`${example}\`,\n` +
      `  imports: [${importsArr}],\n` +
      `  id: ${JSON.stringify(id)},\n` +
      `  metadata: {\n` +
      `    nestable: true,\n` +
      `  },\n` +
      `}\n`;

    files.push({ path: `${id}.figma.ts`, contents, id });
  }

  return files;
}

// emitEntry(entry, config) -> [{ path, contents, id }]
//
// `entry` — a correspondence.json component-shape entry (figmaSets/axes/props;
// NOT an iconTable entry — those have no figmaSets and are out of scope here).
// `config` — { fileKey, fileName, url?, imports: string[], iconPlaceholder? }.
//
// One file per figmaSets[] member ("one .figma.ts per (component × fused
// set)"). A code-only entry (figmaSets: []) yields no files.
export function emitEntry(entry, config) {
  // A mapped axis is either single-attr (has valueMap) or multi-attr (kind:"multi-boolean").
  const mappedAxes = entry.axes.filter((a) => a.valueMap !== undefined || a.kind === "multi-boolean");
  const unmappedAxes = entry.axes.filter((a) => a.valueMap === undefined && a.kind !== "multi-boolean");

  const textContentProp = entry.props.find((p) => p.kind === "text" && p.binding === "content");
  // RC5: kind:"text" bound to a NAMED slot (binding "slot:<name>", not "content") —
  // the search-bar's "Placeholder text" bound to "slot:input". Distinct from the
  // default-slot text→content path above.
  const namedInputSlotProps = entry.props.filter(
    (p) =>
      p.kind === "text" &&
      !p.unmapped &&
      typeof p.binding === "string" &&
      p.binding.startsWith("slot:") &&
      p.binding !== "content"
  );
  const slotBooleanProps = entry.props.filter(
    (p) => p.kind === "boolean" && typeof p.binding === "string" && p.binding.startsWith("slot:")
  );
  // RC2: INSTANCE_SWAP props bound to the default slot ("slot:") — icon-button's
  // Icon. These render unconditionally (no boolean gate) as
  // `<m3e-icon ${glyph}></m3e-icon>` (no slot attr). Named-slot instanceSwap
  // props (binding "slot:icon") are consumed by their paired slot-boolean; only
  // the empty-slot binding is a standalone default-slot icon.
  const defaultSlotIconProps = entry.props.filter(
    (p) => p.kind === "instanceSwap" && p.binding === "slot:" && !p.unmapped
  );
  // RC2 / chip family: INSTANCE_SWAP props bound to a NAMED slot ("slot:<name>",
  // binding !== "slot:") WITHOUT a paired boolean prop, but WITH a `visibilityAxis`
  // + `visibleWhen` annotation. These render CONDITIONALLY via a getEnum check on
  // the visibilityAxis — see buildVisibilityAxisSlotBlock. Props where the iconTable
  // cannot resolve a glyph are gracefully omitted (block === null) rather than thrown.
  const visibilityAxisSlotProps = entry.props.filter(
    (p) =>
      p.kind === "instanceSwap" &&
      !p.unmapped &&
      typeof p.binding === "string" &&
      p.binding.startsWith("slot:") &&
      p.binding !== "slot:" &&
      p.visibilityAxis !== undefined
  );
  // RC5 / search-bar: kind:"literalIcon" props bound to a NAMED slot. These carry
  // a static iconName (baked at codegen time) rather than a runtime-resolved glyph.
  const literalIconSlotProps = entry.props.filter(
    (p) =>
      p.kind === "literalIcon" &&
      !p.unmapped &&
      typeof p.binding === "string" &&
      p.binding.startsWith("slot:")
  );
  const unmappedProps = entry.props.filter((p) => p.unmapped !== undefined);

  // exampleChildren is now resolved PER-SET inside the figmaSets.map loop
  // (see below) to support per-set inline examples (appendSets mechanism).
  // This line is kept as a pre-loop fallback reference for the consumed-props
  // guard below — it reflects whether ANY set will use examples mode, which
  // is sufficient for the instanceSwap-consume guard (conservative, not wrong).
  const cemTagExampleChildren = config.examples && config.examples[entry.cemTag];

  // Additional text→content props beyond the first: consumed (so the
  // unhandled-prop guard doesn't fire) but not emitted. A note is added to
  // the file when in non-examples mode. In examples mode the whole
  // prop-content path is bypassed anyway.
  const additionalTextContentProps = entry.props.filter(
    (p) => p.kind === "text" && p.binding === "content" && p !== textContentProp
  );

  const axisBlocks = mappedAxes.map(buildAxisBlock);
  const contentBlock = textContentProp
    ? { varName: contentVarName(textContentProp), code: `const ${contentVarName(textContentProp)} = instance.getString(${JSON.stringify(textContentProp.figmaProp)})` }
    : null;
  const slotBlocks = slotBooleanProps.map((p) => buildSlotBooleanBlock(p, entry, config));
  const defaultSlotIconBlocks = defaultSlotIconProps.map((p) => buildDefaultSlotIconBlock(p, config));
  // visibilityAxisSlotBlocks: one per visibilityAxisSlotProp; null entries (no
  // iconTable → graceful omit) are filtered out — the prop is still consumed
  // (not unhandled) but contributes no code.
  const visibilityAxisSlotBlocksRaw = visibilityAxisSlotProps.map((p) =>
    buildVisibilityAxisSlotBlock(p, entry, config)
  );
  const visibilityAxisSlotBlocks = visibilityAxisSlotBlocksRaw.filter((b) => b !== null);
  // RC5: literalIcon named-slot blocks (one per prop).
  const literalIconSlotBlocks = literalIconSlotProps.map((p) => buildLiteralIconSlotBlock(p, entry));
  // RC5: named-input-slot blocks (one per prop, e.g. Placeholder text → slot:input).
  const namedInputSlotBlocks = namedInputSlotProps.map((p) => buildNamedInputSlotBlock(p));

  // Fail loud on any mapped prop shape this emitter doesn't (yet) know how to
  // render. "Mapped" = has a binding and is not the schema's unmapped shape.
  // The six known shapes are: kind:"text" bound to "content" (textContentProp),
  // kind:"text" bound to "slot:<name>" (namedInputSlotProps — RC5 search-bar),
  // kind:"boolean" bound to "slot:*" (slotBooleanProps, each optionally
  // pairing a same-slot mapped instanceSwap prop as its glyph source — see
  // buildSlotBooleanBlock's `swapProp`), kind:"instanceSwap" bound to "slot:"
  // (defaultSlotIconProps — the unconditional default-slot icon, RC2),
  // kind:"instanceSwap" bound to a NAMED "slot:<name>" WITH visibilityAxis
  // (visibilityAxisSlotProps — the chip family's conditional icon, RC2), and
  // kind:"literalIcon" bound to "slot:<name>" (literalIconSlotProps — RC5 static icon).
  // Any other mapped prop must not be silently dropped; the surface generalizes
  // beyond m3e-button, and a silent drop here is a silent data loss.
  const consumedMappedProps = new Set();
  if (textContentProp) consumedMappedProps.add(textContentProp);
  // Additional text→content props: consumed (silences the unhandled-prop guard)
  // but not emitted. In non-examples mode a note is added to the file header.
  for (const p of additionalTextContentProps) consumedMappedProps.add(p);
  for (const p of namedInputSlotProps) consumedMappedProps.add(p);
  for (const p of slotBooleanProps) consumedMappedProps.add(p);
  for (const block of slotBlocks) {
    if (block.swapProp) consumedMappedProps.add(block.swapProp);
  }
  for (const p of defaultSlotIconProps) consumedMappedProps.add(p);
  // visibilityAxisSlotProps are always consumed (even when gracefully omitted).
  for (const p of visibilityAxisSlotProps) consumedMappedProps.add(p);
  for (const p of literalIconSlotProps) consumedMappedProps.add(p);
  // A conditional literalIcon block's gateProp (a boolean) is also consumed.
  for (const block of literalIconSlotBlocks) {
    if (block.kind === "conditional" && block.gateProp) consumedMappedProps.add(block.gateProp);
  }
  // Examples-mode: an instanceSwap bound to a named slot ("slot:<name>", not
  // "slot:") without a visibilityAxis is a slot-content prop that the
  // exampleChildren replace entirely — consume it so the unhandled-prop guard
  // doesn't fire. Emit no code; the representative children carry the slot.
  // Use cemTagExampleChildren as a conservative check: if any set in this
  // entry uses examples mode (either via per-set inline example OR via the
  // cemTag-level examples.json entry), we consume these props globally. This
  // is correct because the props themselves are entry-level, not per-set.
  if (cemTagExampleChildren) {
    for (const p of entry.props) {
      if (
        p.unmapped === undefined &&
        p.kind === "instanceSwap" &&
        typeof p.binding === "string" &&
        p.binding.startsWith("slot:") &&
        p.binding !== "slot:" &&
        p.visibilityAxis === undefined &&
        !consumedMappedProps.has(p)
      ) {
        consumedMappedProps.add(p);
      }
    }
  }
  const unhandledMappedProp = entry.props.find(
    (p) =>
      p.unmapped === undefined &&
      typeof p.binding === "string" &&
      !consumedMappedProps.has(p)
  );
  if (unhandledMappedProp) {
    throw new Error(
      `html-label emitter: unhandled mapped prop shape for "${unhandledMappedProp.figmaProp}" ` +
        `(kind: ${JSON.stringify(unhandledMappedProp.kind)}, binding: ${JSON.stringify(unhandledMappedProp.binding)}) — ` +
        `this emitter only supports kind:"text" bound to "content", kind:"text" bound to "slot:<name>" (named input slot, RC5), ` +
        `kind:"boolean" bound to "slot:*" ` +
        `(optionally paired with a same-slot mapped instanceSwap prop), kind:"instanceSwap" ` +
        `bound to "slot:" (default-slot icon, RC2), kind:"instanceSwap" bound to a named ` +
        `"slot:<name>" with visibilityAxis (chip conditional icon, RC2), and kind:"literalIcon" ` +
        `bound to "slot:<name>" (static named-slot icon, RC5); extend src/emit/html-label.mjs ` +
        `to handle this shape rather than let it be silently dropped.`
    );
  }

  // Flatten axis blocks: single-attr blocks have {varName, code}; multi-attr
  // blocks have {kind:"multi-boolean", subBlocks:[{varName, attr, code}]}.
  const allAxisCodes = axisBlocks.flatMap((b) =>
    b.kind === "multi-boolean" ? b.subBlocks.map((s) => s.code) : [b.code]
  );

  // The non-axis code blocks (content + slot) are only needed when NOT in
  // examples-mode. Since examples-mode is now resolved per-set (a figmaSet's
  // inline example takes precedence over the cemTag-level examples.json entry),
  // we compute blocks inside the per-set loop. These values are pre-calculated
  // here for use inside that loop.
  const nonAxisBlockCodes = [
    ...(contentBlock ? [contentBlock.code] : []),
    ...slotBlocks.map((b) => b.code),
    ...defaultSlotIconBlocks.map((b) => b.code),
    ...visibilityAxisSlotBlocks.map((b) => b.code),
    // RC5: named-input-slot blocks (e.g. Placeholder text → slot:input).
    ...namedInputSlotBlocks.map((b) => b.code),
    // RC5: conditional literalIcon blocks contribute code; unconditional ones do not.
    ...literalIconSlotBlocks.filter((b) => b.kind === "conditional").map((b) => b.code),
  ];

  const headerLines = [
    ` * GENERATED by cem-figma-connect (src/emit/html-label.mjs) — do not edit by hand.`,
    ...mappedAxes.map((a) =>
      a.kind === "multi-boolean"
        ? ` * axis: ${a.figmaProp} -> [${a.attrs.map((s) => s.attr).join(", ")}] (multi-boolean)`
        : ` * axis: ${a.figmaProp} -> ${a.attr}`
    ),
    ...unmappedAxes.map((a) => unmappedNote("axis", a)),
    ...(textContentProp ? [` * prop: ${textContentProp.figmaProp} -> content`] : []),
    ...namedInputSlotProps.map((p) => ` * prop: ${p.figmaProp} -> ${p.binding} (${p.slotTag ?? "input"})`),
    ...slotBooleanProps.map((p) => ` * prop: ${p.figmaProp} -> ${p.binding}`),
    ...entry.props
      .filter((p) => p.kind === "instanceSwap" && !p.unmapped)
      .map((p) => ` * prop: ${p.figmaProp} -> ${p.binding} (instanceSwap)`),
    ...literalIconSlotProps.map((p) => ` * prop: ${p.figmaProp} -> ${p.binding} (literalIcon: ${p.iconName})`),
    ...unmappedProps.map((p) => unmappedNote("prop", p)),
  ];

  const contentExpr = contentBlock ? "${" + contentBlock.varName + "}" : "";
  const slotExprs =
    slotBlocks.map((b) => "${" + b.lineVar + "}").join("") +
    visibilityAxisSlotBlocks.map((b) => "${" + b.lineVar + "}").join("") +
    // RC5: conditional literalIcon blocks contribute a lineVar interpolation.
    literalIconSlotBlocks
      .filter((b) => b.kind === "conditional")
      .map((b) => "${" + b.lineVar + "}")
      .join("");
  // RC2: default-slot icon renders inline (unconditional; no line-var indirection).
  const defaultSlotIconExprs = defaultSlotIconBlocks
    .map((b) => `\n  <${ICON_TAG} \${${b.glyphVar}}></${ICON_TAG}>`)
    .join("");
  // RC5: unconditional literalIcon static tags — baked directly into the template.
  const literalIconUnconditionalExprs = literalIconSlotBlocks
    .filter((b) => b.kind === "unconditional")
    .map((b) => `\n  <${ICON_TAG} slot="${b.slotName}" name="${b.iconName}"></${ICON_TAG}>`)
    .join("");
  // RC5: named-input-slot exprs (e.g. <input slot="input" placeholder="${placeholderText}"></input>).
  const namedInputSlotExprs = namedInputSlotBlocks
    .map((b) => `\n  <${b.slotTag} slot="${b.slotName}" placeholder="\${${b.varName}}"></${b.slotTag}>`)
    .join("");

  // figmaAxisNames: keys that name a Figma VARIANT axis. fixedAttrs entries
  // with these keys are axis-pin entries (drive.mjs: select a Figma variant
  // for gate comparison) — NOT CEM attributes; they must not appear on the
  // emitted HTML tag or affect the file slug.
  const figmaAxisNames = new Set(entry.axes.map((a) => a.figmaProp));

  // Per-set static attr injection (set-attrs.json). Look up this cemTag's map
  // ONCE before the per-set loop, then validate all setName keys against the
  // entry's actual figmaSets — a typo is a build error, never a silent no-op.
  const setAttrsForTag = (config.setAttrs ?? {})[entry.cemTag] ?? null;
  if (setAttrsForTag !== null) {
    const knownSetNames = new Set(entry.figmaSets.map((s) => s.setName));
    for (const setName of Object.keys(setAttrsForTag)) {
      if (!knownSetNames.has(setName)) {
        throw new Error(
          `set-attrs: unknown setName '${setName}' for '${entry.cemTag}' — ` +
            `not one of this entry's figmaSets (${[...knownSetNames].join(", ")}). ` +
            `Fix the typo in set-attrs.json.`
        );
      }
    }
  }

  return entry.figmaSets.map((figmaSet) => {
    const url = buildNodeUrl(config, figmaSet.nodeId);

    // Per-set inline example (appendSets mechanism) takes precedence over the
    // cemTag-level examples.json entry. A figmaSet WITHOUT an inline example
    // falls back to cemTagExampleChildren (which may itself be undefined/null).
    // The resolved value drives both inner-content rendering and block inclusion.
    const exampleChildren =
      figmaSet.example?.children != null
        ? figmaSet.example
        : cemTagExampleChildren;

    // slugSuffix (appendSets mechanism): when present, it REPLACES the
    // fixedAttrs-derived slug entirely — the appended set controls its filename
    // directly (fixedAttrs still EMIT as attrs, but a boolean like toggle="true"
    // would otherwise slug to "true"). e.g. slugSuffix "toggle-filled" -> m3e-button-toggle-filled.
    const baseSlug = figmaSet.slugSuffix != null ? kebab(figmaSet.slugSuffix) : setSlugOf(figmaSet, figmaAxisNames);
    const id = `${entry.cemTag}-${baseSlug}`;

    // In examples-mode the inner content is fully replaced by exampleChildren,
    // so any code-block const whose variable only appears in the inner-content
    // expression is dead. Axis consts ARE still used (they bind to tag
    // attributes, not inner content), so allAxisCodes is always included.
    // Content/slot blocks are inner-content only — skip them in examples-mode.
    const blocks = [
      ...allAxisCodes,
      ...(exampleChildren ? [] : nonAxisBlockCodes),
    ];

    // Build the attrs string: fixed attrs first (CEM-attr fixedAttrs only —
    // axis-pin keys like Style on m3e-avatar are skipped), then mapped axes.
    // For multi-boolean axes, each sub-attr renders as a conditional boolean
    // presence interpolation: `${typeChecked ? "checked" : ""}` (truthy in
    // CC template context: attr present when true, absent when false).
    const fixedAttrEntries = Object.entries(figmaSet.fixedAttrs ?? {})
      .filter(([k]) => !figmaAxisNames.has(k))
      .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0));

    // Merge per-set static attrs (from set-attrs.json) after fixedAttrs, in
    // sorted order. Throw on key collision with fixedAttrs — the config author
    // must pick one source of truth, never let a silent override hide a bug.
    const perSetAttrs = setAttrsForTag ? (setAttrsForTag[figmaSet.setName] ?? {}) : {};
    if (Object.keys(perSetAttrs).length > 0) {
      const fixedKeys = new Set(fixedAttrEntries.map(([k]) => k));
      for (const k of Object.keys(perSetAttrs)) {
        if (fixedKeys.has(k)) {
          throw new Error(
            `set-attrs: key collision '${k}' already in fixedAttrs for '${entry.cemTag}' ` +
              `set '${figmaSet.setName}'. Remove the key from one source.`
          );
        }
      }
    }

    const attrParts = [
      ...fixedAttrEntries.map(([k, v]) => `${k}="${v}"`),
      ...axisBlocks.flatMap((b) => {
        if (b.kind === "multi-boolean") {
          return b.subBlocks.map((s) => `\${${s.varName} ? "${s.attr}" : ""}`);
        }
        // Boolean-target single axis: bare-or-omit, not attr="${x}" (see buildAxisBlock).
        if (b.boolean) return [`\${${b.varName} ? "${b.varName}" : ""}`];
        return [`${b.varName}="\${${b.varName}}"`];
      }),
      // Per-set static attrs appended last, sorted (deterministic order).
      ...Object.entries(perSetAttrs)
        .sort(([a], [b]) => (a < b ? -1 : a > b ? 1 : 0))
        .map(([k, v]) => `${k}="${v}"`),
    ];
    const attrs = attrParts.join(" ");

    // When an examples entry exists, inner content = rendered representative
    // children. Otherwise use the prop-derived exprs (existing behavior).
    const innerContent = exampleChildren
      ? renderChildrenHtml(exampleChildren.children)
      : `${contentExpr}${slotExprs}${defaultSlotIconExprs}${literalIconUnconditionalExprs}${namedInputSlotExprs}`;
    const example = `<${entry.cemTag}${attrs ? " " + attrs : ""}>${innerContent}</${entry.cemTag}>`;

    // Built directly from the real values (no fragile placeholder-string
    // replace): a "bound to Figma set" line is spliced in right after the
    // GENERATED line. Robust even if setName/nodeId ever contained a literal
    // "SET_NAME"/"NODE_ID" substring — there is no search-and-replace to
    // misfire.
    const boundLine = ` * ${entry.cemTag}, bound to Figma set "${figmaSet.setName}" (${figmaSet.nodeId}).`;
    const header = [headerLines[0], boundLine, ...headerLines.slice(1)].join("\n");

    const importsArr = (config.imports ?? []).map((i) => JSON.stringify(i)).join(", ");

    // When non-examples mode has extra text→content props beyond the first,
    // append a note so they're not silently dropped.
    const multiContentNote =
      !exampleChildren && additionalTextContentProps.length > 0
        ? `\n// note: additional text prop(s) ${additionalTextContentProps.map((p) => p.figmaProp).join(", ")} not emitted — add an examples.json entry\n`
        : "";

    const contents =
      `// url=${url}\n` +
      `import figma from "figma"\n` +
      `\n` +
      `/**\n${header}\n */\n` +
      `\n` +
      `const instance = figma.selectedInstance\n` +
      `\n` +
      (blocks.length ? blocks.join("\n\n") + "\n\n" : "") +
      `export default {\n` +
      `  example: figma.code\`${example}\`,\n` +
      `  imports: [${importsArr}],\n` +
      `  id: ${JSON.stringify(id)},\n` +
      `  metadata: {\n` +
      `    nestable: true,\n` +
      `  },\n` +
      `}` + multiContentNote + `\n`;

    return { path: `${id}.figma.ts`, contents, id };
  });
}

// emitConfirmed(entries, config) -> [{ path, contents, id, cemTag }]
//
// Convenience over emitEntry for the whole confirmed set. Handles both
// figmaSets-based entries and iconTable entries (kind:"iconTable").
// Skips code-only entries (figmaSets: [] with no icons — nothing to bind).
// Still a pure function.
export function emitConfirmed(entries, config) {
  const files = [];
  for (const entry of entries) {
    if (entry.status !== "confirmed") continue;
    if (entry.kind === "iconTable") {
      for (const file of emitIconTableEntry(entry, config)) {
        files.push({ ...file, cemTag: entry.cemTag });
      }
      continue;
    }
    if (!entry.figmaSets || entry.figmaSets.length === 0) continue;
    for (const file of emitEntry(entry, config)) {
      files.push({ ...file, cemTag: entry.cemTag });
    }
  }
  return files;
}

export const _internal = { camel, kebab, contentVarName, setSlugOf, figmaFileSlug, buildNodeUrl, assertMainFileUrl };

// emitter — the emitter-api.mjs (task B2) conformant `{name, label,
// emit(entry, ctx)}` object. `src/emit/run.mjs`'s built-in registry
// dispatches to THIS export (not `emitEntry`/`emitConfirmed` directly).
//
// Skip rules: code-only entries (figmaSets: [] with no icons) produce no
// files. iconTable entries are now EMITTED (one file per icon row) when
// confirmed — emitIconTableEntry handles them. Non-iconTable entries without
// figmaSets (code-only) still produce no files.
export const emitter = {
  name: "html-label",
  label: "Web Components",
  emit(entry, ctx) {
    if (entry.kind === "iconTable") {
      const config = {
        fileKey: ctx.profile.fileKey,
        fileName: ctx.figma.data.meta.fileName,
        imports: ctx.profile.htmlLabel?.imports ?? [],
      };
      return emitIconTableEntry(entry, config).map(({ path, contents }) => ({ path, contents }));
    }
    if (!entry.figmaSets || entry.figmaSets.length === 0) return [];

    const config = {
      fileKey: ctx.profile.fileKey,
      fileName: ctx.figma.data.meta.fileName,
      imports: ctx.profile.htmlLabel?.imports ?? [],
      iconPlaceholder: ctx.profile.htmlLabel?.iconPlaceholder,
      iconTable: ctx.iconTable ?? [],
      examples: ctx.examples ?? {},
      setAttrs: ctx.setAttrs ?? {},
    };

    return emitEntry(entry, config).map(({ path, contents }) => ({ path, contents }));
  },
};
