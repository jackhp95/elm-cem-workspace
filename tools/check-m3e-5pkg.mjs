// tools/check-m3e-5pkg.mjs — assert the m3e package split has the post-DAG-rework
// shape: a SPLIT set (core / elements / icons / facts) described by packages.json,
// PLUS two FAMILY-GENERATED sibling packages emitted directly by the generator —
// elm-m3e-components AND elm-m3e-build — that are NOT split.js buckets.
//
// DAG-rework Task 4 (MATERIALIZE): elm-m3e-build stopped being a split.js bucket
// owner of the `M3e.Build.*` modules and became a family-generated package (like
// elm-m3e-components) whose composed builders import `M3e.Component.*`. The whole
// point of the rework is the LINEAR DAG `build → components → elements → core`, so
// the discriminating check is: (1) packages.json no longer carries a Build bucket,
// and (2) elm-m3e-build's emitted elm.json DECLARES jackhp95/elm-m3e-components.
// Exit 0 iff so. Used as the split gate's discriminating verify-check.
import { readFileSync } from "node:fs";

const pkgRoot = new URL("../brands/m3e/generated/package/", import.meta.url);
const packages = JSON.parse(readFileSync(new URL("elm-m3e/packages.json", pkgRoot))).packages;
const names = packages.map((x) => x.name);

const problems = [];

// (1) The split.js set is exactly core / elements / icons / facts — Build is gone.
const wantSplit = [
  "jackhp95/elm-m3e-core",
  "jackhp95/elm-m3e-elements",
  "jackhp95/elm-m3e-icons",
  "jackhp95/elm-m3e-facts",
];
for (const nm of wantSplit) if (!names.includes(nm)) problems.push(`packages.json is missing the split package ${nm}`);
if (names.includes("jackhp95/elm-m3e-build"))
  problems.push("elm-m3e-build must NOT be a split.js package anymore — it is now a family-generated package (like elm-m3e-components)");

// No package may still own a M3e.Build bucket.
for (const p of packages) {
  const hasBuild = (p.buckets || []).some((k) => k.exact === "M3e.Build" || (k.prefix || "").startsWith("M3e.Build"));
  if (hasBuild) problems.push(`${p.name} still owns a M3e.Build bucket — the Build tier is no longer split-bucketed`);
}

// (2) elm-m3e-build is a family-generated package: its emitted elm.json declares
//     jackhp95/elm-m3e-components (the DAG dep the composed builders import) and
//     does NOT declare elm-m3e-elements directly (Build reaches Elements through
//     Components — the linear DAG, not the old parallel-siblings shape).
function elmJson(dir) {
  return JSON.parse(readFileSync(new URL(`${dir}/elm.json`, pkgRoot)));
}
let buildElm;
try {
  buildElm = elmJson("elm-m3e-build");
} catch (e) {
  problems.push(`cannot read elm-m3e-build/elm.json — it must be a generated family package: ${e.message}`);
}
if (buildElm) {
  const deps = buildElm.dependencies || {};
  if (!("jackhp95/elm-m3e-components" in deps))
    problems.push("elm-m3e-build/elm.json must declare jackhp95/elm-m3e-components (Build now consumes Components — the linear DAG)");
  if ("jackhp95/elm-m3e-elements" in deps)
    problems.push("elm-m3e-build/elm.json must NOT declare jackhp95/elm-m3e-elements directly — Build reaches Elements through Components (no parallel-siblings shape)");
  if (!("jackhp95/elm-m3e-core" in deps))
    problems.push("elm-m3e-build/elm.json must declare jackhp95/elm-m3e-core");
}

// elm-m3e-components must also still exist as a family-generated sibling.
try {
  elmJson("elm-m3e-components");
} catch (e) {
  problems.push(`cannot read elm-m3e-components/elm.json — it must be a generated family package: ${e.message}`);
}

if (problems.length) {
  console.error("check-m3e-5pkg: NOT the post-DAG-rework shape:\n  " + problems.join("\n  "));
  process.exit(1);
}
console.log(
  "check-m3e-5pkg: OK — split set core/elements/icons/facts + family-generated components & build; elm-m3e-build declares elm-m3e-components (linear DAG build→components→elements→core)."
);
