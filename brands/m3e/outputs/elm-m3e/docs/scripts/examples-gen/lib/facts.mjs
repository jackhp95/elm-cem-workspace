// facts.mjs — load elm-cem's Face C (`elm-api-facts.json`) for engine A.
//
// Phase 1 (L5 revive): engine A's component-API layer (module / entry / form /
// setter / enum token / slot fn / action) is now sourced from the ONE facts
// bundle — Face C — exactly as engine B (cem-figma-connect) is, so the two can
// never drift again (VISION "one facts bundle"). Face C is emitted by the
// elm-cem producer FROM elm-m3e's OWN config, so we generate it here rather than
// reaching cross-package into a consumer's committed copy (the dependency arrow
// stays one-way: elm-cem → elm-m3e/docs). Generation is ~0.75s and memoized for
// the process, so calling this from the driver and the unit tests is cheap.
//
// A keeps its own DOM-structural oracle (slot kinds, childSlotByKind, idWiring,
// requiredFields/Slots, aria/universal routing) — those are DOM concerns Face C
// does not (and should not) carry (see the L4 coverage audit). This module ONLY
// supplies the component-API facts.

import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, resolve, join } from "node:path";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
// docs/scripts/examples-gen/lib/facts.mjs -> elm-m3e root is four levels up.
const M3E_ROOT = resolve(HERE, "..", "..", "..", "..");
const ELM_CEM_CLI =
  process.env.ELM_CEM_BIN || resolve(M3E_ROOT, "..", "..", "..", "..", "core", "elm-cem", "bin", "elm-cem.js");

// The config/flags argv for an elm-cem run against elm-m3e's own config — the
// same set tools/lib/regen.mjs's GEN_CONFIG_ARGS uses (kept in step by hand; a
// mismatch would only change which components Face C carries, which the compile
// gate would then surface as skips, never a silent bad name).
const GEN_CONFIG_ARGS = [
  "--flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json",
  "--config-from=config/slots.json",
  "--config-from=config/native-mdn.json",
  "--config-from=config/examples.generated.json",
];

let cached = null;

/**
 * Generate Face C from elm-m3e's config and return it parsed:
 *   { components: { <cemTag>: comp }, byTag(tag) -> comp|undefined, raw }
 * Memoized per process. Throws (with elm-cem's output) if generation fails.
 */
export function loadFacts() {
  if (cached) return cached;
  const work = mkdtempSync(join(tmpdir(), "examples-gen-facts-"));
  try {
    const res = spawnSync(
      process.execPath,
      [
        ELM_CEM_CLI,
        ...GEN_CONFIG_ARGS,
        `--facts-bundle=${work}`,
        `--output=${join(work, "out")}`,
      ],
      {
        cwd: M3E_ROOT,
        encoding: "utf8",
        env: {
          ...process.env,
          PATH: `${join(M3E_ROOT, "node_modules", ".bin")}:${process.env.PATH}`,
        },
      },
    );
    if (res.status !== 0) {
      throw new Error(
        `facts.mjs: elm-cem failed to emit Face C (exit ${res.status}):\n` +
          `${res.stdout || ""}\n${res.stderr || ""}`,
      );
    }
    const faceC = JSON.parse(
      readFileSync(join(work, "elm-api-facts.json"), "utf8"),
    );
    const components = faceC.components || {};
    cached = {
      raw: faceC,
      components,
      byTag: (tag) => components[tag],
    };
    return cached;
  } finally {
    rmSync(work, { recursive: true, force: true });
  }
}
