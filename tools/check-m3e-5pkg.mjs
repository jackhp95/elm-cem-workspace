// tools/check-m3e-5pkg.mjs — assert brands/m3e/generated/package/elm-m3e/packages.json is the D-037
// 5-package concern-separated split (html / components / builder / icons / facts),
// with M3e.Build.* split OUT of components into elm-m3e-builder. Exit 0 iff so.
// Used as the M8.b loop's discriminating verify-check.
import { readFileSync } from "node:fs";
const p = JSON.parse(readFileSync(new URL("../brands/m3e/generated/package/elm-m3e/packages.json", import.meta.url))).packages;
const names = p.map((x) => x.name);
const need = ["jackhp95/elm-m3e-html", "jackhp95/elm-m3e-components", "jackhp95/elm-m3e-builder", "jackhp95/elm-m3e-icons", "jackhp95/elm-m3e-facts"];
const builder = p.find((x) => x.name === "jackhp95/elm-m3e-builder");
const builderHasBuild = builder && builder.buckets.some((k) => k.exact === "M3e.Build" || k.prefix === "M3e.Build.");
const comp = p.find((x) => x.name === "jackhp95/elm-m3e-components");
const compHasBuild = comp && comp.buckets.some((k) => k.exact === "M3e.Build" || (k.prefix || "").startsWith("M3e.Build"));
const problems = [];
if (p.length !== 5) problems.push(`expected 5 packages, got ${p.length}`);
for (const nm of need) if (!names.includes(nm)) problems.push(`missing package ${nm}`);
if (!builderHasBuild) problems.push("elm-m3e-builder must own the M3e.Build / M3e.Build.* buckets");
if (compHasBuild) problems.push("elm-m3e-components must NOT contain any M3e.Build bucket (split it out)");
if (problems.length) { console.error("check-m3e-5pkg: NOT the 5-package shape:\n  " + problems.join("\n  ")); process.exit(1); }
console.log("check-m3e-5pkg: OK — 5-package split (html/components/builder/icons/facts), Build split out.");
