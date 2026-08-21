// tools/check-m3e-5pkg.mjs — assert brands/m3e/generated/package/elm-m3e/packages.json is the D-037
// 5-package concern-separated split (core / elements / build / icons / facts),
// with M3e.Build.* split OUT of elements into elm-m3e-build. Exit 0 iff so.
// Used as the M8.b loop's discriminating verify-check.
import { readFileSync } from "node:fs";
const p = JSON.parse(readFileSync(new URL("../brands/m3e/generated/package/elm-m3e/packages.json", import.meta.url))).packages;
const names = p.map((x) => x.name);
const need = ["jackhp95/elm-m3e-core", "jackhp95/elm-m3e-elements", "jackhp95/elm-m3e-build", "jackhp95/elm-m3e-icons", "jackhp95/elm-m3e-facts"];
const build = p.find((x) => x.name === "jackhp95/elm-m3e-build");
const buildHasBuild = build && build.buckets.some((k) => k.exact === "M3e.Build" || k.prefix === "M3e.Build.");
const elements = p.find((x) => x.name === "jackhp95/elm-m3e-elements");
const elementsHasBuild = elements && elements.buckets.some((k) => k.exact === "M3e.Build" || (k.prefix || "").startsWith("M3e.Build"));
const problems = [];
if (p.length !== 5) problems.push(`expected 5 packages, got ${p.length}`);
for (const nm of need) if (!names.includes(nm)) problems.push(`missing package ${nm}`);
if (!buildHasBuild) problems.push("elm-m3e-build must own the M3e.Build / M3e.Build.* buckets");
if (elementsHasBuild) problems.push("elm-m3e-elements must NOT contain any M3e.Build bucket (split it out)");
if (problems.length) { console.error("check-m3e-5pkg: NOT the 5-package shape:\n  " + problems.join("\n  ")); process.exit(1); }
console.log("check-m3e-5pkg: OK — 5-package split (core/elements/build/icons/facts), Build split out.");
