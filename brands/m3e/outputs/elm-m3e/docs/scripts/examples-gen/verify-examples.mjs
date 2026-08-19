// verify-examples.mjs — compile-verify generated Elm example expressions
// against the REAL M3e.* / Kit / Native API.
//
// "Examples can't lie": the deterministic mapper emits typed Elm, but nothing
// has actually type-checked it. This harness builds a scratch Elm *application*
// whose source-directories point at the real library sources, emits every
// example as a top-level binding (no annotation — inference does the work),
// runs `elm make ... --report=json` ONCE, and maps each failing binding back
// to its (module, idx, title). Callers use this to DROP non-compiling examples.
//
// The scratch-app writer + elm dep pins + reference walker are shared with the
// gen-barrel / gen-record-build / verify-rule-roundtrip harness scripts via
// lib/scratch-harness.mjs; the compile-error attribution below is unique to this
// module. It also owns `compilingNames`, the { name -> code } -> Set-of-compiling
// primitive those three scripts use to accept/reject a rewritten corpus.
//
// Usage as a module:
//   import { verifyExamples } from "./verify-examples.mjs";
//   const { failures, ok } = verifyExamples(generated);
// Usage from CLI:
//   node scripts/verify-examples.mjs [config/examples.generated.json]
//   -> prints the failing (module, idx, title, firstErrorLine) set.

import { readFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  referencedModules,
  moduleResolves as moduleResolvesIn,
  bindingName,
  mkScratchDir,
  writeCorpusApp,
} from "./lib/scratch-harness.mjs";

// docs/scripts/examples-gen/verify-examples.mjs -> elm-m3e root is three up.
const M3E_ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..", "..", "..");
const LIB_SRC = `${M3E_ROOT}/src`;
const ELM_BIN = `${M3E_ROOT}/docs/node_modules/.bin/elm`;
// Phantom substrate: HtmlIr.* and TypedHtml.* live in UNPUBLISHED sibling repos,
// so their source is vendored (committed) into docs/vendor/elm-foundation — the
// same single source-directory docs/elm.json points at. Use the vendored copy so
// example verification runs against a self-contained tree (`pnpm run build:vendor`
// re-syncs it; see vendor/elm-foundation/VENDORED_FROM.txt).
//
// Phase 1 (L5 revive): the former `docs/kit` seam (Kit.*/Native.*) was DELETED in
// the concern-separated-packages refactor. Engine A now targets the current
// userland seam directly — `M3e.text` / `TypedHtml.*` / the `M3e.Unsafe.*` +
// `TypedHtml.Unsafe.*` escapes — all of which live in LIB_SRC (M3e.*) and
// FOUNDATION_SRC (TypedHtml.*). So SRC_DIRS points only at substrate that EXISTS
// and compiles; the deleted docs/kit is gone from the list (it FATAL'd the
// harness — a non-existent source-directory).
const DOCS_DIR = `${M3E_ROOT}/docs`;
const FOUNDATION_SRC = resolve(DOCS_DIR, "vendor/elm-foundation");
const SRC_DIRS = [LIB_SRC, FOUNDATION_SRC];

// Re-export the reference walker unchanged, and a 1-arg `moduleResolves` bound to
// this project's library source dirs. verify-roundtrip.mjs and
// roundtrip/gen-harness-route.mjs import these two names from here.
export { referencedModules };
export function moduleResolves(mod) {
  return moduleResolvesIn(mod, SRC_DIRS);
}

/**
 * Flatten the generated config into a list of { module, idx, title, code }.
 * `idx` is the index within that module's examples array.
 */
export function flattenExamples(generated) {
  const items = [];
  for (const module of Object.keys(generated)) {
    const examples = generated[module].examples || [];
    examples.forEach((ex, idx) => {
      items.push({ module, idx, title: ex.title, code: ex.code });
    });
  }
  return items;
}

/**
 * Run elm make and parse the JSON report. Returns a Map from binding name to
 * an array of { line, message } (first error line + rendered message).
 */
function compileAndCollectErrors(scratchDir) {
  let stdout = "";
  try {
    execFileSync(
      ELM_BIN,
      ["make", "src/Verify.elm", "--output=/dev/null", "--report=json"],
      {
        cwd: scratchDir,
        encoding: "utf8",
        stdio: ["ignore", "pipe", "pipe"],
        // The JSON error report for a whole-corpus compile can far exceed the
        // 1 MB execFileSync default; a truncated buffer makes JSON.parse throw
        // and the harness FATALs on a phantom "not JSON" error, masking the real
        // per-example failures. Give it generous headroom (64 MB).
        maxBuffer: 64 * 1024 * 1024,
      },
    );
    return { report: null, byBinding: new Map() }; // clean compile
  } catch (err) {
    stdout = (err.stdout || "") + "";
    const stderr = (err.stderr || "") + "";
    let report;
    try {
      report = JSON.parse(stdout || stderr);
    } catch {
      // Not JSON -> something structural is wrong (bad elm.json, elm crashed).
      return {
        report: null,
        fatal: (stdout || stderr || String(err)).slice(0, 4000),
        byBinding: new Map(),
      };
    }
    const { byBinding, structuralFatal } = mapReportToBindings(report, scratchDir);
    if (structuralFatal) {
      return { report, byBinding, fatal: structuralFatal };
    }
    return { report, byBinding };
  }
}

/** Render a `message` array (elm's rich chunks) into plain text. */
function renderMessage(message) {
  if (typeof message === "string") return message;
  if (!Array.isArray(message)) return String(message);
  return message
    .map((chunk) => (typeof chunk === "string" ? chunk : chunk.string || ""))
    .join("");
}

/** basename of the one file we compile — anything else is external/unattributable. */
function isScratchPath(path) {
  if (!path) return false;
  return path.replace(/\\/g, "/").split("/").pop() === "Verify.elm";
}

/**
 * Map an elm --report=json compile error report to bindings.
 * Two report shapes: { type:"compile-errors", errors:[...] } (type/name errors)
 * and { type:"error", ... } (single structural error, e.g. bad import/parse).
 *
 * Returns { byBinding, structuralFatal }. `structuralFatal` (a string) is set
 * when an error can NOT be attributed to a single example binding in our scratch
 * `Verify.elm` — i.e. it lives in an external/library source file, or it is a
 * structural (`type:"error"`) failure whose region doesn't land inside any
 * binding. Such an error would otherwise be dropped as "<unattributed>", leaving
 * ALL bindings error-free and thus GLOBAL-PASSING every example — the exact
 * silent false-pass that masked a real MODULE-NOT-FOUND during the IR-core
 * refactor. We surface it as fatal so verification fails loudly instead.
 */
function mapReportToBindings(report, scratchDir) {
  const byBinding = new Map();
  let structuralFatal = null;
  const noteFatal = (msg) => {
    if (!structuralFatal) structuralFatal = msg;
  };
  const src = readFileSync(resolve(scratchDir, "src", "Verify.elm"), "utf8");
  const srcLines = src.split("\n");

  // Precompute binding start lines so we can attribute an error region (line
  // number) to the nearest preceding binding definition.
  const bindingAt = []; // [{ name, line }]
  srcLines.forEach((l, i) => {
    const m = /^([A-Za-z_][A-Za-z0-9_]*) =$/.exec(l);
    if (m) bindingAt.push({ name: m[1], line: i + 1 });
  });
  const bindingForLine = (line) => {
    let found = null;
    for (const b of bindingAt) {
      if (b.line <= line) found = b.name;
      else break;
    }
    return found;
  };

  const push = (name, entry) => {
    if (!name) name = "<unattributed>";
    if (!byBinding.has(name)) byBinding.set(name, []);
    byBinding.get(name).push(entry);
  };

  if (report.type === "compile-errors") {
    for (const fileErr of report.errors || []) {
      // An error whose FILE isn't our scratch Verify.elm is structural and
      // unattributable to any example (e.g. a MODULE-NOT-FOUND surfaced inside a
      // library source). It must be fatal, not silently dropped.
      if (!isScratchPath(fileErr.path)) {
        const first = (fileErr.problems || [])[0];
        noteFatal(
          `compile error in external file ${fileErr.path || "<unknown>"}` +
            (first ? `:\n${renderMessage(first.message)}` : ""),
        );
        continue;
      }
      for (const problem of fileErr.problems || []) {
        const line = problem.region?.start?.line ?? 0;
        const name =
          bindingForLine(line) ??
          // fall back: some name errors reference the binding by name in text
          nameFromMessage(renderMessage(problem.message), bindingAt);
        if (!name) {
          // An error inside Verify.elm we cannot pin to a binding (e.g. the
          // import block) is structural — fail rather than global-pass.
          noteFatal(
            `unattributable compile error in Verify.elm (line ${line}):\n` +
              renderMessage(problem.message),
          );
          continue;
        }
        push(name, { line, message: renderMessage(problem.message) });
      }
    }
  } else if (report.type === "error") {
    // Structural (single) error — e.g. a bad import / parse failure. If it lands
    // in an external file OR doesn't resolve to a binding, it is unattributable
    // and must be fatal (never a silent all-pass).
    const line = report.region?.start?.line ?? 0;
    const name = isScratchPath(report.path) ? bindingForLine(line) : null;
    if (!name) {
      noteFatal(
        `structural compile error` +
          (report.path ? ` in ${report.path}` : "") +
          `:\n${renderMessage(report.message)}`,
      );
    } else {
      push(name, {
        line,
        message: renderMessage(report.message),
        structural: true,
      });
    }
  }
  return { byBinding, structuralFatal };
}

function nameFromMessage(text, bindingAt) {
  for (const b of bindingAt) {
    if (text.includes(b.name)) return b.name;
  }
  return null;
}

/**
 * ONE compile pass over `items` ({module,idx,title,code}[]). Returns the
 * per-item pass/fail split plus any errors elm couldn't attribute to a binding.
 */
function verifyOnce(items, scratchDir) {
  // Emit every example as a top-level binding. ONLY modules that resolve to a
  // real source file (or stdlib) are imported — a bad `import` aborts the whole
  // compile before type-checking, which would hide every real error and falsely
  // pass all bindings. A reference to a non-existent module is left un-imported,
  // so elm reports a "cannot find variable" naming error at the usage site,
  // attributable to that one binding, which then correctly fails.
  const bindings = items.map((it) => ({ name: bindingName(it.module, it.idx), code: it.code }));
  writeCorpusApp(scratchDir, bindings, SRC_DIRS);
  const { report, byBinding, fatal } = compileAndCollectErrors(scratchDir);
  if (fatal) return { fatal };

  const ok = [];
  const failures = [];
  for (const it of items) {
    const name = bindingName(it.module, it.idx);
    const errs = byBinding.get(name);
    if (errs && errs.length) {
      const first = errs[0];
      const firstErrorLine =
        renderMessage(first.message)
          .split("\n")
          .map((s) => s.trim())
          .find((s) => s.length > 0) || "compile error";
      failures.push({
        module: it.module,
        idx: it.idx,
        title: it.title,
        firstErrorLine,
      });
    } else {
      ok.push({ module: it.module, idx: it.idx, title: it.title });
    }
  }
  const unattributed = byBinding.get("<unattributed>") || [];
  return { ok, failures, unattributed, report };
}

/**
 * Verify every example in `generated`, iterating to a FIXPOINT. Returns:
 *   { ok: [{module,idx,title}], failures: [{module,idx,title,firstErrorLine}],
 *     fatal?: string }
 *
 * Why iterate: elm's type checker attributes only the errors it reaches. A
 * naming error (e.g. a reference to a non-existent module member) in binding A
 * can stop elm before it fully type-checks binding B, so a single pass
 * under-reports. We drop the failures found this pass, recompile the survivors,
 * and repeat until a pass finds NO new failures — at which point every
 * surviving example provably compiles together.
 *
 * A `fatal` string means the scratch app didn't build for structural reasons
 * (report not JSON / bad elm.json) — caller should treat that as a harness bug.
 */
export function verifyExamples(generated, { verbose = false } = {}) {
  let items = flattenExamples(generated);
  if (items.length === 0) return { ok: [], failures: [] };

  const scratchDir = mkScratchDir("verify-examples");
  const allFailures = []; // accumulated across passes (first error wins)
  const failedKeys = new Set();
  let lastUnattributed = [];

  for (let pass = 1; ; pass++) {
    const res = verifyOnce(items, scratchDir);
    if (res.fatal) return { ok: [], failures: allFailures, fatal: res.fatal };
    lastUnattributed = res.unattributed;

    if (verbose) {
      console.error(
        `verify pass ${pass}: ${res.ok.length} ok, ${res.failures.length} failed` +
          (res.unattributed.length
            ? `, ${res.unattributed.length} unattributed`
            : ""),
      );
    }

    if (res.failures.length === 0) {
      // Fixpoint: every remaining item compiles together.
      return { ok: res.ok, failures: allFailures, unattributed: res.unattributed };
    }

    // Record this pass's failures and drop them for the next pass.
    for (const f of res.failures) {
      const key = `${f.module}#${f.idx}`;
      if (!failedKeys.has(key)) {
        failedKeys.add(key);
        allFailures.push(f);
      }
    }
    items = items.filter(
      (it) => !failedKeys.has(`${it.module}#${it.idx}`),
    );
    if (items.length === 0) {
      return { ok: [], failures: allFailures, unattributed: lastUnattributed };
    }
  }
}

/**
 * Compile-verify a { name -> code } map (one binding per key). Returns the Set of
 * names that compile as a set. The three harness scripts use this to keep only
 * rewritten examples that still type-check.
 */
export function compilingNames(codeByName) {
  const shadow = { V: { examples: [] } };
  const order = [];
  for (const [name, code] of Object.entries(codeByName)) {
    shadow.V.examples.push({ title: name, code });
    order.push(name);
  }
  const { failures, fatal } = verifyExamples(shadow);
  if (fatal) throw new Error("verify fatal:\n" + fatal);
  const failed = new Set(failures.map((f) => order[f.idx]));
  return new Set(order.filter((n) => !failed.has(n)));
}

// -------------------------- CLI -------------------------------------------
function isMain() {
  return (
    process.argv[1] &&
    process.argv[1].endsWith("verify-examples.mjs")
  );
}

if (isMain()) {
  const path =
    process.argv[2] || `${M3E_ROOT}/config/examples.generated.json`;
  const generated = JSON.parse(readFileSync(path, "utf8"));
  const { ok, failures, fatal, unattributed } = verifyExamples(generated, {
    verbose: true,
  });
  if (fatal) {
    console.error("FATAL — scratch app did not build:\n" + fatal);
    process.exit(2);
  }
  console.log(`compiled OK: ${ok.length}`);
  console.log(`FAILED: ${failures.length}`);
  for (const f of failures) {
    console.log(`  ${f.module} [#${f.idx}] "${f.title}" :: ${f.firstErrorLine}`);
  }
  if (unattributed && unattributed.length) {
    console.log(`unattributed errors: ${unattributed.length}`);
  }
}
