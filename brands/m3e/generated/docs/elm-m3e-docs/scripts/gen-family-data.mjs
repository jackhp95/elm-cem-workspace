// gen-family-data.mjs — derive the docs `/family` page data from the SAME
// source the family package itself is generated from: `config/slots.json`'s
// `_families.families` block. Emits `data/families.json`, read at build time by
// `Route.Family` via `BackendTask.File.jsonFile`.
//
// WHY THIS EXISTS
//   `Route.Family` used to hardcode the family/member table as an Elm literal,
//   and its own module comment admitted it "mirrors [slots.json's _families]
//   rather than re-deriving it, so it can only go stale." It HAD gone stale: the
//   Tabs family's `TabPanel` member was labelled `panel`, but the real generated
//   `M3e.Family.Tabs` re-exports it as `tabPanel` (a reader following the docs
//   would write `M3e.Family.Tabs.panel` and hit a compile error). Deriving the
//   table from the one source removes that whole class of drift.
//
// FAITHFUL TO THE FAMILY GENERATOR
//   The re-export ("element") name a member gets is decided by
//   pipeline/elm-cem/bin/gen-family-package.js: the ROOT member's element label
//   is the FAMILY name (`pushMember(root, family)`), every other member's is its
//   `path` field; the emitted constructor is `lowerFirst(elementLabel)`. This
//   script mirrors that exactly, so `data/families.json` names match the actual
//   `M3e.Family.<F>` constructors 1:1.
//
// Output schema (consumed by Route.Family):
//   [ { "family": "<F>", "members": [ { "component": "<Comp>",
//                                       "label": "<constructor>" } ] } ]
//   sorted alphabetically by family (the page browses alphabetically); members
//   root-first, then config order (matching the generated module's @docs order).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
// The elm-m3e package sibling holds the same committed config the family
// generator reads (config/slots.json is byte-identical to brands/m3e/inputs/).
const REPO = path.resolve(here, "..", "..", "..", "package", "elm-m3e");
const SLOTS = path.resolve(REPO, "config/slots.json");
const OUT = path.resolve(here, "../data/families.json");

const lowerFirst = (s) => (s.length ? s[0].toLowerCase() + s.slice(1) : s);

const slots = JSON.parse(fs.readFileSync(SLOTS, "utf8"));
const families = slots?._families?.families;
if (!families || typeof families !== "object") {
  console.error(`gen-family-data: ${SLOTS} has no _families.families block.`);
  process.exit(1);
}

const out = [];
for (const [family, spec] of Object.entries(families)) {
  const members = [];
  // Root counts as a member whose element label is the FAMILY name
  // (gen-family-package.js: `if (root) pushMember(root, family)`).
  if (spec.root) members.push({ component: spec.root, label: lowerFirst(family) });
  for (const mem of spec.members || []) {
    if (!mem.component || !mem.path) {
      console.error(`gen-family-data: family "${family}" has a malformed member ${JSON.stringify(mem)}.`);
      process.exit(1);
    }
    members.push({ component: mem.component, label: lowerFirst(mem.path) });
  }
  if (members.length === 0) {
    console.error(`gen-family-data: family "${family}" has no root and no members.`);
    process.exit(1);
  }
  out.push({ family, members });
}

out.sort((a, b) => a.family.localeCompare(b.family, "en"));

fs.writeFileSync(OUT, JSON.stringify(out, null, 2) + "\n");
console.log(`gen-family-data: wrote ${out.length} families to ${path.relative(process.cwd(), OUT)}`);
