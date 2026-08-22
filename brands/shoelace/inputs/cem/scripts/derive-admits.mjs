#!/usr/bin/env node
// Shoelace admits pre-pass — Task 4 (§4) of
// docs/plans/2026-08-21-families-a11y-composition-plan.md.
//
// Expands the brand's role-map (inputs/cem/roles.json) x the brand-agnostic ARIA
// composition foundation (docs/a11y-foundation/composition-rules.json) into a
// per-component `admits` block for each of Shoelace's 58 custom elements, written
// into inputs/cem/config/slots.json in the SAME shape html authors by hand:
//   <CemName>: { admits: { <slotName>: { kinds: [...], multi: bool } } }
// plus a `_sets` block of the category tokens the admits reference.
//
// The emitter (Generate.Phantom.Model.resolveSlot) then flattens those admits ->
// slotKinds exactly as it does for html; Cem.ValidSlotKind is untouched.
//
// Deterministic + idempotent: it regenerates the component entries and `_sets`
// from roles.json every run, preserving the phantom scaffold keys
// (`_phantom`, `_brand`, `_atoms`). Run before regenerating shoelace:
//   node brands/shoelace/inputs/cem/scripts/derive-admits.mjs
//
// DERIVATION RULES (grounded in the Task-1 foundation):
//   1. An entry with an explicit `admits` override -> use it verbatim. This is
//      how every relational CONTAINER pins its required-owned child set in
//      shoelace's own vocabulary (menu owns menuItem, tabGroup's `nav` owns tab
//      + default owns tabPanel, select owns option, tree owns treeItem, ...),
//      and how the tab-group nav/default slot split is expressed.
//   2. role in ariaPresentationalChildren.roles (button, checkbox, img, option,
//      radio, switch, tab, progressbar, separator, slider, ...) -> the component
//      must have NO focusable/interactive descendant. If it has a default slot,
//      admit phrasing-like content minus interactive; else no slots.
//   3. role === "none" (no clean ARIA role: card, divider, formatters,
//      observers, ...) -> permissive `@any`, minus `!@interactive` when the
//      component is itself an interactive control (sets.interactive), so an
//      interactive control cannot nest another interactive control.
//   4. any other role (dialog, drawer, group, alert, navigation, tabpanel,
//      dialog-like containers) -> permissive flow content (`@any`): these
//      legitimately hold arbitrary content.
//
// Whether a component HAS a default/other slot is read from the real CEM
// (custom-elements.json) so we never invent a slot the element doesn't expose.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const cemDir = path.resolve(here, ".."); // inputs/cem
const repoRoot = path.resolve(here, "../../../../.."); // -> workspace root

const rolesPath = path.join(cemDir, "roles.json");
const cemPath = path.join(cemDir, "custom-elements.json");
const configPath = path.join(cemDir, "config", "slots.json");
const foundationPath = path.join(
  repoRoot,
  "docs",
  "a11y-foundation",
  "composition-rules.json",
);

const roles = JSON.parse(fs.readFileSync(rolesPath, "utf8"));
const cem = JSON.parse(fs.readFileSync(cemPath, "utf8"));
const foundation = JSON.parse(fs.readFileSync(foundationPath, "utf8"));
const config = JSON.parse(fs.readFileSync(configPath, "utf8"));

const presentationalRoles = new Set(
  foundation.ariaPresentationalChildren.roles,
);

// The config is keyed by the name the CODEGEN sees for each component, which is
// the tag with the brand prefix (`sl-`) stripped, PascalCased — NOT the raw CEM
// `name` (`SlMenu`). Generate.elm's `rename`/`componentModuleName` rewrites
// `SlMenu` -> `Menu` before Model.resolve, and `Dict.get d.name raw.components`
// then looks the config up under `Menu`. Keying under `SlMenu` would silently
// attach to nothing (the exact bug this pre-pass hit on its first run).
const moduleNameOf = (tag) =>
  tag
    .replace(/^sl-/, "")
    .split("-")
    .map((p) => p[0].toUpperCase() + p.slice(1))
    .join("");

// The kind token (ctor) is the same, decapitalized: sl-menu-item -> menuItem.
const ctorOf = (tag) => {
  const mod = moduleNameOf(tag);
  return mod[0].toLowerCase() + mod.slice(1);
};

// tag -> { name (codegen module name, the config key), slots: [slotName...] }.
const elements = new Map();
for (const m of cem.modules ?? []) {
  for (const dec of m.declarations ?? []) {
    if (!dec.tagName) continue;
    const slots = (dec.slots ?? []).map((s) => s.name || "unnamed");
    elements.set(dec.tagName, { name: moduleNameOf(dec.tagName), slots });
  }
}

const interactiveSet = new Set(roles.sets.interactive ?? []);

const errors = [];
const derivedComponents = {};
const summary = [];

for (const [tag, entry] of Object.entries(roles.roles)) {
  const el = elements.get(tag);
  if (!el) {
    errors.push(`roles.json: '${tag}' is not a component in the CEM`);
    continue;
  }
  const { name, slots } = el;
  const role = entry.role;
  const ctor = ctorOf(tag);
  const isInteractive = interactiveSet.has(ctor);

  // Base admits from the role (Rules 2-4) — only ever authors the DEFAULT slot;
  // affordance slots (prefix/suffix/icon slots) are left unconstrained by omission.
  let admits = {};
  let strategy;
  if (slots.length === 0) {
    strategy = role === "none" ? "none/no-slots" : `${role}/no-slots`;
  } else if (presentationalRoles.has(role)) {
    // Rule 2 — presentational children: label content only, no interactive
    // descendant. `shared:text` is the label-text atom (Sl.text) every such
    // control needs, alongside the inline display atoms in @phrasingLike —
    // mirrors html's button admitting `shared:text` beside its phrasing set.
    strategy = `presentational(${role})`;
    if (slots.includes("unnamed"))
      admits.unnamed = { kinds: ["shared:text", "@phrasingLike"], multi: true };
  } else if (role === "none") {
    // Rule 3 — no clean role: permissive, minus interactive if itself a control.
    strategy = "none/permissive";
    const kinds = isInteractive ? ["any", "!@interactive"] : ["any"];
    if (slots.includes("unnamed")) admits.unnamed = { kinds, multi: true };
  } else {
    // Rule 4 — other roles (containers that legitimately hold arbitrary flow).
    strategy = `${role}/flow`;
    if (slots.includes("unnamed")) admits.unnamed = { kinds: ["any"], multi: true };
  }

  // Rule 1 — overlay explicit relational overrides on top of the role base
  // (per slot). This pins container child-sets / slot splits (menu owns
  // menuItem, tab-group's nav owns tab, menu-item's submenu owns menu) WITHOUT
  // clobbering the role-derived default-slot content model where the override
  // does not name the default slot.
  if (entry.admits) {
    strategy = strategy + "+override";
    for (const [slotName, block] of Object.entries(entry.admits)) {
      const cemSlot = slotName === "unnamed" ? "unnamed" : slotName;
      if (!slots.includes(cemSlot)) {
        errors.push(
          `${tag}: admits override names slot '${slotName}' the CEM does not expose (has: ${slots.join(", ") || "none"})`,
        );
        continue;
      }
      admits[slotName] = block;
    }
  }

  derivedComponents[name] = { admits };
  const kindsStr = Object.keys(admits).length
    ? Object.entries(admits)
        .map(([s, v]) => `${s}=[${v.kinds.join(",")}]`)
        .join(" ")
    : "(no slots)";
  summary.push({
    tag,
    name,
    role,
    strategy,
    slotKinds: kindsStr,
    hasSlotKinds: Object.keys(admits).length > 0,
  });
}

// Every CEM component must be covered by roles.json.
for (const [tag, el] of elements) {
  if (!roles.roles[tag]) {
    errors.push(`CEM component '${tag}' (${el.name}) is missing from roles.json`);
  }
}

if (errors.length) {
  console.error("derive-admits: FAILED\n  " + errors.join("\n  "));
  process.exit(1);
}

// ── Rewrite slots.json: keep the phantom scaffold keys, replace `_sets` +
//    per-component entries from the derivation. Underscore keys other than
//    `_sets` (i.e. `_phantom`, `_brand`, `_atoms`) are preserved as-is.
const next = {};
for (const [k, v] of Object.entries(config)) {
  if (k === "_sets") continue;
  if (!k.startsWith("_")) continue; // drop stale component entries; re-derive below
  next[k] = v;
}
next._sets = roles.sets;
for (const [name, block] of Object.entries(derivedComponents)) {
  next[name] = block;
}

fs.writeFileSync(configPath, JSON.stringify(next, null, 2) + "\n");

// ── Report.
const withKinds = summary.filter((s) => s.hasSlotKinds).length;
const noSlots = summary.filter((s) => !s.hasSlotKinds);
console.log(
  `derive-admits: wrote ${summary.length} component admits blocks to ${path.relative(repoRoot, configPath)}`,
);
console.log(
  `  ${withKinds}/${summary.length} components carry a content model (slotKinds); ${noSlots.length} expose no slots.`,
);
console.log("\n  Relational / notable derivations:");
for (const s of summary.filter(
  (s) => s.strategy.includes("override") || s.strategy.startsWith("presentational"),
)) {
  console.log(`    ${s.tag.padEnd(20)} role=${(s.role + "").padEnd(11)} ${s.slotKinds}`);
}
console.log("\n  Components exposing no slots (empty content model, by design):");
console.log("    " + noSlots.map((s) => s.tag).join(", "));
