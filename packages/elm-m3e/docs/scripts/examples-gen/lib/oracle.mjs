// Mapping oracle: per-tag lookup derived from the Custom Elements Manifest
// (@m3e/web custom-elements.json) + config/slots.json. Feeds the HTML->Elm
// mapper so it can turn `<m3e-button variant="filled">` into typed M3e.* calls.

import { readFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { camel, pascal, safeField } from "./naming.mjs";

// docs/scripts/examples-gen/lib/oracle.mjs -> elm-m3e root is four levels up.
const HERE = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(HERE, "..", "..", "..", "..");

const CEM_PATH = resolve(
  REPO_ROOT,
  "docs/node_modules/@m3e/web/dist/custom-elements.json"
);
const SLOTS_PATH = resolve(REPO_ROOT, "config/slots.json");

function readJson(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

// Kebab-case a config key: insert "-" before each interior uppercase, lowercase
// the whole thing. Already-kebab keys pass through unchanged.
function kebab(key) {
  return String(key)
    .replace(/([a-z0-9])([A-Z])/g, "$1-$2")
    .toLowerCase();
}

// A TS type the codegen has no simple setter for: arrays (`string[]`),
// functions (`=> `), or object literals (`{`). Mirrors the generator's ASkip.
function isComplexType(typeText) {
  return /\[\]|=>|^\s*\{/.test(typeText);
}

// A `string[]` attribute (e.g. BottomSheet/SplitPane `detents`) reflects to a
// space-delimited token string in the HTML attribute and IS author-settable, so
// the generator now emits a plain `String` setter for it. Mirrors the
// generator's `isStringArrayType`; kept distinct from `isComplexType` so these
// carve out of the array skip rather than being dropped.
function isStringArray(typeText) {
  return /^(readonly\s+)?string\[\]$|^(Readonly)?Array<string>$/.test(
    typeText.trim()
  );
}

// Extract quoted string-literal values from a TS union type text.
function enumLiterals(typeText) {
  const out = [];
  const re = /'([^']*)'/g;
  let m;
  while ((m = re.exec(typeText)) !== null) out.push(m[1]);
  return out;
}

// Enum-typed attributes whose CEM entry carries an un-inlined type ALIAS
// (`type.text: "FormSubmitterType"`) with NO `parsedType` union to read literals
// from. The library generator resolved these aliases to `M3e.Token` enums during
// generation, so the top layer's setter takes a `M3e.Token.<token>` — emitting a
// bare string would fail to compile. All other enum aliases in the @m3e/web CEM
// (ButtonVariant, NavBarMode, …) DO carry `parsedType`, so this fallback is only
// needed for the alias(es) that don't. `FormSubmitterType` = the HTML
// `<button type>` set, mapped to the `M3e.Token.{button,reset,submit}` tokens.
const ALIAS_ENUM_LITERALS = {
  FormSubmitterType: ["submit", "reset", "button"],
};

// A component's produced KIND (as used in slots.json `kinds` lists) is its
// module name decapitalized: TabPanel -> "tabPanel", Step -> "step". This is
// NOT `camel`, which folds a separator-free PascalCase word to all-lowercase.
const decapitalize = (s) => (s ? s.charAt(0).toLowerCase() + s.slice(1) : s);

// Is a slot `kinds` entry the shared text/link row? The current config vocab
// spells these `shared:text` / `shared:link` (the `shared:` prefix marks a kind
// several components produce, as opposed to a component-produced kind like
// `treeItem`). An older vocab used bare `text` / `link`; accept both so the
// fold-to-record / unwrap-to-Kit.text logic keys off the same predicate the
// library's `LabelSlot = { sharedText, sharedLink }` type encodes.
const isTextOrLinkKind = (k) =>
  k === "text" || k === "link" || k === "shared:text" || k === "shared:link";

// Fix A — tagName reconciliation. The @m3e/web 2.5.13 CEM carries the SAME
// analyzer defect B1.5b fixed in the library generator: two element classes
// have a WRONG class-level `tagName` that collides with a sibling —
// M3eStepperNextElement.tagName === "m3e-stepper-previous" and
// M3eFabMenuItemElement.tagName === "m3e-menu-item". The
// `custom-element-definition` exports carry the real registration tag
// (`customElements.define(name, class)`), so overwrite each referenced
// declaration's `tagName` from its export BEFORE the oracle keys entries by
// tagName — otherwise m3e-stepper-next / m3e-fab-menu-item are never created
// and degrade with "unknown m3e tag". No-op wherever the analyzer agrees.
function reconcileTagNames(cem) {
  const declByKey = new Map();
  for (const mod of cem.modules ?? []) {
    for (const d of mod.declarations ?? []) {
      if (!d.name) continue;
      declByKey.set(`${mod.path}\0${d.name}`, d);
      if (!declByKey.has(d.name)) declByKey.set(d.name, d);
    }
  }
  for (const mod of cem.modules ?? []) {
    for (const ex of mod.exports ?? []) {
      if (ex.kind !== "custom-element-definition" || !ex.name) continue;
      const ref = ex.declaration ?? {};
      const decl =
        (ref.module != null && declByKey.get(`${ref.module}\0${ref.name}`)) ||
        declByKey.get(ref.name);
      // Only rewrite an actual custom-element declaration whose tag differs. The
      // `customElement` guard mirrors elm-cem/bin/elm-cem.js: it stops a by-name
      // fallback (declByKey.get(ref.name)) from stamping a tagName onto a
      // non-element declaration that happens to share a name in another module.
      // No-op for correct analyzers, keeping logs clean and churn minimal.
      if (decl && decl.customElement && decl.tagName !== ex.name) {
        console.error(
          `oracle: reconciled tagName ${JSON.stringify(decl.tagName)} -> ${JSON.stringify(ex.name)} for ${decl.name}`
        );
        decl.tagName = ex.name;
      }
    }
  }
}

export function buildOracle() {
  const cem = readJson(CEM_PATH);
  reconcileTagNames(cem);
  const slots = readJson(SLOTS_PATH);

  // Variant groups: a `group` config folds several tags into ONE top module
  // with a constructor per variant (e.g. Progress.group = { linear:
  // "m3e-linear-progress-indicator", ... } -> `M3e.Progress.linear`). Build a
  // tag -> { module, variant } map so the TOP mapper targets the group module.
  // Fold a `group` ONLY when its target module is ACTUALLY generated into the
  // library (src/M3e/<Module>.elm). The generator ignores `group` and emits a
  // per-tag module for every element, so a group whose unified module was never
  // generated (e.g. `Progress` — the library ships separate
  // `LinearProgressIndicator`/`CircularProgressIndicator` modules) is stale
  // config: folding into `M3e.Progress.linear` emitted a non-existent variable.
  // Skipping the fold lets each tag map to its real per-tag module.
  const groupByTag = {};
  for (const [module, cfg] of Object.entries(slots)) {
    if (cfg && cfg.group && typeof cfg.group === "object") {
      const groupModuleExists = existsSync(
        resolve(REPO_ROOT, "src", "M3e", `${module}.elm`),
      );
      if (!groupModuleExists) {
        console.error(
          `oracle: skipping stale group "${module}" (no generated src/M3e/${module}.elm); mapping members to per-tag modules`,
        );
        continue;
      }
      for (const [variant, tag] of Object.entries(cfg.group)) {
        groupByTag[tag] = { module, variant };
      }
    }
  }

  const oracle = {};

  for (const mod of cem.modules ?? []) {
    for (const d of mod.declarations ?? []) {
      const tag = d.tagName;
      if (!tag) continue;

      // module: strip library prefix (up to and incl. first "-"), then pascal.
      const rest = tag.slice(tag.indexOf("-") + 1);
      const module = pascal(rest);
      const moduleConfig = slots[module] ?? {};

      // attributes
      const attributes = [];
      for (const attr of d.attributes ?? []) {
        const htmlName = attr.name;
        // Attribute setters use the PLAIN camelCase name — the generator does
        // NOT reserved-bump them (Attr.elm: `elmName = camel attribute.name`),
        // so `min`/`max`/etc. stay as-is. It DOES escape Elm keywords
        // (`type` -> `type_`), mirroring the generator's `safeField`, so a `type`
        // attribute targets the real `M3e.<Mod>.type_` setter (not `.type`).
        // (An attribute whose name COLLIDES with a slot helper — e.g. `selected`,
        // `start`, `end` — is dropped from the top surface after the slot loop
        // below: the positional name belongs to the slot, not the attribute.)
        const setter = safeField(camel(htmlName));

        const typeText = attr.type?.text ?? "";
        const enumSource = attr.parsedType?.text ?? attr.type?.text ?? "";
        // Strip nullable union members (`| null` / `| undefined`) the way the
        // generator does, so `number | null` still classifies as a number.
        const bare = typeText
          .replace(/\s*\|\s*(null|undefined)\b/g, "")
          .trim();
        let kind;
        let enumValues = [];
        const lits = enumLiterals(enumSource);
        const aliasLits = ALIAS_ENUM_LITERALS[bare] ?? null;
        if (bare === "boolean") {
          kind = "bool";
        } else if (bare === "number") {
          // Numeric attributes map to a `Float` setter at every layer, so the
          // value is emitted as a bare Elm number literal (no quotes).
          kind = "number";
        } else if (lits.length >= 2) {
          // A `parsedType` string-literal union classifies as an enum EVEN when
          // another arm of the union is a callable/complex type — e.g.
          // Autocomplete `filter: AutocompleteFilterMode | ((…)=>boolean)`, whose
          // `parsedType` is `'none' | 'contains' | … | ((…)=>boolean)`. The
          // literal arm is expressible and the library generator emits a matching
          // enum setter (it drops the non-expressible arm, issue #22), so the
          // converter must TARGET that setter, not skip the attribute because the
          // raw `type.text` happened to contain `=>`. This check must precede the
          // `isComplexType` bail for that reason.
          kind = "enum";
          enumValues = lits;
        } else if (aliasLits) {
          // Un-inlined enum alias (no parsedType union): resolve via the known
          // alias->literals map so the setter targets `M3e.Token.<token>`.
          kind = "enum";
          enumValues = aliasLits;
        } else if (isStringArray(bare)) {
          // `string[]` attributes (e.g. `detents`) reflect to a space-delimited
          // token string and are author-settable; the generator emits a plain
          // String setter, so convert the raw value verbatim (do not skip).
          kind = "string";
        } else if (isComplexType(bare)) {
          // Function/object-typed attributes (e.g. `valueFormatter`) have NO
          // generated setter (the codegen skips them), so the mapper drops them
          // like id/class rather than emitting a non-existent setter.
          kind = "skip";
        } else {
          kind = "string";
        }
        attributes.push({ htmlName, setter, kind, enumValues });
      }
      for (const [setterName, spec] of Object.entries(
        moduleConfig.syntheticAttrs ?? {},
      )) {
        const type = spec.type ?? "bool";
        let kind = "bool";
        let enumValues = [];
        if (Array.isArray(type)) {
          kind = "enum";
          enumValues = Array.isArray(type[1]) ? type[1] : type.slice(1);
        } else if (type === "string") kind = "string";
        else if (type === "int" || type === "float") kind = "number";
        attributes.push({
          // The config key IS the Elm setter/capability name already (the
          // generator uses it verbatim via `elmNameOverride`) — do NOT re-camelize
          // it (that would lowercase `tocIgnore` -> `tocignore`). Only keyword-escape.
          htmlName: spec.htmlName,
          setter: safeField(setterName),
          kind,
          enumValues,
        });
      }

      // requiredFields from slots.json[module].required (field -> kind object)
      const requiredFields = [];
      const requiredConfig = moduleConfig.required;
      if (requiredConfig && typeof requiredConfig === "object") {
        for (const key of Object.keys(requiredConfig)) {
          // An `action:`-kinded required field (Button/IconButton/Fab/... take a
          // required `action` on the ④ Record view) is NOT a required record
          // field at the strict TOP (Standard `M3e.*`) layer: the Standard view
          // has no required record and realizes the action through ordinary
          // `href`/`onClick` Attr setters. Skip it here so an action-bearing
          // element sources its action from `href` (-> `M3e.<mod>.href "…"`)
          // like any other attribute. The ④/⑤ translator rules then lift that
          // `href` into `action = M3e.Action.link { href = … }`.
          if (
            typeof requiredConfig[key] === "string" &&
            requiredConfig[key].startsWith("action:")
          ) {
            continue;
          }
          // Keys may be camelCase (e.g. "ariaLabel"). camel() collapses a
          // separator-free word to lowercase, so kebab first to recover the
          // word boundaries: camel(kebab("ariaLabel")) === "ariaLabel".
          const htmlName = kebab(key);
          requiredFields.push({ field: camel(htmlName), htmlName });
        }
      }

      // slots
      const slotEntries = [];
      // Config key is `admits` (per-slot accepted-kind curation). Reading the
      // wrong key (`slots`) left `slotConfig` empty, so config-defined slots
      // (incl. the config-only FormField `label`) and every slot's
      // kinds/multi/required were lost. See config/slots.json + CONFIG_SCHEMA.md.
      const slotConfig = moduleConfig.admits ?? {};
      // Required NAMED slots (e.g. NavMenuItem/TreeItem `label`) are folded by
      // the codegen into the view's required record as a field (NOT a slot
      // helper). Collect them so the mapper can source that field from the
      // matching `slot="X"` child instead of emitting a non-existent helper.
      const requiredSlots = [];
      for (const slot of d.slots ?? []) {
        const rawName = slot.name;
        let helper;
        if (rawName === "") {
          helper = "child";
        } else {
          // The POSITIONAL slot helper is ALWAYS the bare slot name. When a slot
          // name collides with an attribute setter (e.g. Button/IconButton
          // `selected`, DrawerContainer `start`/`end`, Autocomplete `loading`),
          // the generator resolves the clash on the BUILDER side only
          // (`withSelectedSlot` vs `withSelected`) and keeps the positional
          // helper bare (`selected`). A `+Slot`-bumped positional name
          // (`selectedSlot`) is never exposed, so the previous bump emitted a
          // non-existent variable and degraded every such example.
          helper = camel(rawName);
        }
        // Fix B — the default (anonymous) slot's config lives under the
        // "unnamed" key in config/slots.json (NOT "default"). Reading the wrong
        // key silently dropped required/multi/kinds for the default slot, so
        // `defaultUnionKinds` below was empty and Fix C could misroute a bare
        // union child (e.g. an IconButton's default `icon`) into a named slot.
        const cfg =
          rawName === ""
            ? (slotConfig["unnamed"] ?? slotConfig["default"] ?? {})
            : (slotConfig[rawName] ?? {});
        // `kinds` in slots.json is EITHER a list of accepted element rows
        // (`["text","link"]`) OR a scalar string (`"arbitrary"` / `"any"`) for
        // slots that take anything. Normalize to a list so callers can always
        // `.length`/`.every` without a string leaking through (a bare
        // `"arbitrary"[0]` would otherwise index to the char `"a"`).
        const kinds = Array.isArray(cfg.kinds)
          ? cfg.kinds
          : cfg.kinds != null
            ? [cfg.kinds]
            : [];
        const kind = kinds[0] ?? "any";
        // A required, single-value default slot is folded by the codegen into
        // the view's required record as a `content` field (not a `child`
        // helper). The mapper needs required/multi to reproduce that.
        const required = cfg.required === true;
        const multi = cfg.multi === true;
        slotEntries.push({ rawName, helper, kind, kinds, required, multi });

        // A required, single-value NAMED slot -> required record field named
        // after the slot (camelCased), sourced from the `slot="X"` child.
        // `kinds` records what element rows the field accepts (e.g.
        // ["text","link"]) so the mapper can unwrap a text-only wrapper into a
        // compatible `Kit.text` / `Kit.link` rather than an incompatible
        // `Native.<tag>` (which carries an `html` row).
        // The generated view folds a required single NAMED slot into its
        // required record ONLY when the slot's accepted kinds are text/link
        // (e.g. NavMenuItem/TreeItem `label`). Required slots with element
        // kinds (e.g. SplitButton `leading-button`, SearchBar `input`) stay
        // ordinary slot HELPERS in the library — required-ness is enforced by
        // elm-review, not the record. Mirror that here so the mapper emits a
        // helper (not a phantom record field) for non-text/link required slots.
        const foldsToRecord = kinds.length > 0 && kinds.every(isTextOrLinkKind);
        if (rawName !== "" && required && !multi && foldsToRecord) {
          requiredSlots.push({
            field: camel(rawName),
            rawName,
            kinds,
          });
        }
      }

      // Config-only slots: slots declared in config/slots.json that the CEM does
      // NOT list (e.g. FormField `label`, StepPanel `actions`, SearchBar
      // `clear-icon`). The GENERATOR emits real helpers for these (from the same
      // config), so the oracle must know them or the TOP mapper skips the whole
      // example with "unknown slot". Merge any config key not already covered by
      // a CEM slot. ("unnamed"/"default" both denote the anonymous default slot.)
      const seenRaw = new Set(slotEntries.map((s) => s.rawName));
      for (const cfgKey of Object.keys(slotConfig)) {
        const rawName =
          cfgKey === "unnamed" || cfgKey === "default" ? "" : cfgKey;
        if (seenRaw.has(rawName)) continue;
        const cfg = slotConfig[cfgKey] ?? {};
        // Positional slot helper is always the bare slot name (see the CEM-slot
        // loop above): the generator bumps only the builder, never the helper.
        const helper = rawName === "" ? "child" : camel(rawName);
        const kinds = Array.isArray(cfg.kinds)
          ? cfg.kinds
          : cfg.kinds != null
            ? [cfg.kinds]
            : [];
        const kind = kinds[0] ?? "any";
        const required = cfg.required === true;
        const multi = cfg.multi === true;
        slotEntries.push({ rawName, helper, kind, kinds, required, multi });
        seenRaw.add(rawName);
        const foldsToRecord = kinds.length > 0 && kinds.every(isTextOrLinkKind);
        if (rawName !== "" && required && !multi && foldsToRecord) {
          requiredSlots.push({ field: camel(rawName), rawName, kinds });
        }
      }

      // Fix C — per-container child routing by produced kind. A default-slot
      // child with NO `slot=` attr is distinguished only by tag (e.g.
      // <m3e-tab-panel> vs <m3e-tab>). Route it to the NAMED slot whose accepted
      // kind matches the child's produced kind, so a composite's heterogeneous
      // default children (panels vs tabs, steps vs step-panels) each reach their
      // typed slot helper instead of one mis-typed `M3e.<mod>.children [...]`.
      // EXCLUDE kinds already in the default (unnamed) children union so
      // union-row composites (Menu/MenuItemGroup/NavMenu/FabMenu) keep routing
      // their children through `children`; exclude required text/link NAMED
      // slots (sourced from their `slot="X"` child via the requiredSlots path);
      // and exclude any kind accepted by more than one named slot (ambiguous).
      const defaultUnionKinds = new Set(
        slotEntries.find((s) => s.rawName === "")?.kinds ?? [],
      );
      const requiredSlotNames = new Set(requiredSlots.map((r) => r.rawName));
      const kindOwners = {};
      for (const s of slotEntries) {
        if (s.rawName === "" || requiredSlotNames.has(s.rawName)) continue;
        for (const k of s.kinds) {
          if (defaultUnionKinds.has(k)) continue;
          (kindOwners[k] ??= new Set()).add(s.helper);
        }
      }
      const childSlotByKind = {};
      for (const [k, helpers] of Object.entries(kindOwners)) {
        if (helpers.size === 1) childSlotByKind[k] = [...helpers][0];
      }

      // Attribute↔slot name collision: when an attribute setter shares its name
      // with a slot helper (e.g. DrawerContainer `start`/`end`, Button/IconButton
      // `selected`), the generator gives the POSITIONAL name to the SLOT (an
      // `Element -> Element` helper) and exposes the attribute ONLY as a `withX`
      // builder — there is NO positional attribute setter. Emitting
      // `M3e.<mod>.start True` would therefore apply the slot helper to a Bool.
      // Drop these attributes: at the strict positional TOP surface the boolean
      // is unsettable, so it degrades as a dropped attr rather than nulling the
      // whole example; the slot child still renders via the bare slot helper.
      const slotHelperNames = new Set(
        slotEntries.filter((s) => s.rawName !== "").map((s) => s.helper),
      );
      const attributesTop = attributes.filter(
        (a) => !slotHelperNames.has(a.setter),
      );

      oracle[tag] = {
        tag,
        module,
        // Produced kind (this element's kind as a child of another container).
        kind: decapitalize(module),
        childSlotByKind,
        attributes: attributesTop,
        requiredFields,
        requiredSlots,
        slots: slotEntries,
        // id↔control wiring (FormField): a `label`/`control` slot whose helper
        // takes a leading `id`/`for` String argument (docs/DESIGN.md §4). null unless
        // config/slots.json declares `idWiring` for this module.
        idWiring: moduleConfig.idWiring ?? null,
        // Present only for variant-group members; the TOP mapper folds them
        // into `M3e.<group.module>.<group.variant>`.
        group: groupByTag[tag] ?? null,
      };
    }
  }

  return oracle;
}
