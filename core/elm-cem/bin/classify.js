// elm-cem classify — the general/component split of a generated brand tree.
//
// Salvaged from the retired decay ladder (bin/decay.js): the ONE reusable part.
// The distribution model (docs/distribution-model.md) publishes a brand's
// PRIMITIVES (the general/-html layer) to the registry and ejects the rest, so
// the emitter needs to know which modules are general vs component.
//
// Classification is structural, not a name allowlist: the barrel (`module <Lib>`)
// re-exports exactly the per-component constructors, so its own `import <Lib>.X`
// lines enumerate the *component* modules — minus reserved shared-vocab modules
// (VOCAB_SUFFIXES) it also re-exports, and minus `<Lib>.Review.*`. Everything else
// under `<Lib>.` is the general layer (the reserved vocab PLUS any behavioural
// module the barrel does not import, e.g. `<Lib>.Action`).

"use strict";

const fs = require("fs");
const path = require("path");
const family = require("./family-deps");

// Reserved general/vocab module suffixes — names no web component ever produces,
// so a barrel that re-exports one (e.g. `<Lib>.Values`) doesn't misclassify it as
// a component.
const VOCAB_SUFFIXES = [
  "Html",
  "Attributes",
  "Values",
  "Events",
  "Kind",
  "Build",
  "Build.Internal",
  "Unsafe",
];

function classifyModules(modules, lib) {
  const names = Object.keys(modules);
  const barrel = names.includes(lib) ? lib : null;

  const isReview = (m) => /(^|\.)Review(\.|$)/.test(m.slice(lib.length));
  const review = names.filter((m) => m !== lib && m.startsWith(lib + ".") && isReview(m));

  const vocab = new Set(VOCAB_SUFFIXES.map((s) => `${lib}.${s}`));

  // The barrel's `import <Lib>.*` lines enumerate the component candidates; strip
  // any reserved-vocab or review module the barrel happens to re-export.
  const components = new Set();
  if (barrel) {
    const src = fs.readFileSync(modules[lib], "utf8");
    const re = /^import\s+([A-Za-z0-9_.]+)/gm;
    let m;
    while ((m = re.exec(src)) !== null) {
      const name = m[1];
      if (
        name !== lib &&
        name.startsWith(lib + ".") &&
        names.includes(name) &&
        !vocab.has(name) &&
        !review.includes(name)
      ) {
        components.add(name);
      }
    }
  }

  const general = names.filter(
    (m) => m !== lib && m.startsWith(lib + ".") && !review.includes(m) && !components.has(m)
  );

  return { barrel, general: general.sort(), components: [...components].sort(), review: review.sort() };
}

// The modules a brand's PRIMITIVES registry package exposes: the general layer,
// minus `*.Internal` (never publish forging primitives across the package
// boundary) and minus `Review.*` (the review facts describe components, which
// live in the EJECTED full brand, not the primitives package). Returns null if
// there is no barrel to classify against.
function primitivesExposed(srcDir, lib) {
  const modules = family.discoverModules(srcDir);
  if (!modules[lib]) return null;
  const { general } = classifyModules(modules, lib);
  return general
    .filter((m) => !/(^|\.)Internal(\.|$)/.test(m))
    .filter((m) => !/(^|\.)Review(\.|$)/.test(m))
    .sort();
}

module.exports = { VOCAB_SUFFIXES, classifyModules, primitivesExposed };
