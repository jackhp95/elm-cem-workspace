#!/usr/bin/env node
// Config-forced ENUM override gate (`attrTypes` list form + token→value map form).
//
// An `attrTypes` enum override is a promise: this attribute admits exactly these
// values. The generator broke that promise for BOTH override forms, and shipped
// broken, because nothing tested it.
//
//   `Attr.fromOverride` classified every enum override — list form and map form
//   alike — to `Attr.AEnumMap`, with a comment claiming "the simple-list and
//   token→value map forms share one emission path". They did once: the retired
//   5-form pipeline in `Generate.elm` matched `AEnumMap` and emitted a `Value`
//   setter for it. That pipeline went away; the phantom emitters that replaced it
//   only ever learned `AEnum`. `AEnumMap` was matched at ZERO sites in
//   `Generate/Phantom/Emit.elm` and `Generate/Phantom/Model.elm`, so it fell
//   through every `case` to the `_ ->` default:
//
//     * `Model` minted no `EnumSpec`, so `Brand.unions` had no entry — no union
//       row in `<Lib>.Values`, and none of the attribute's tokens either;
//     * `Emit` fell to the plain-scalar path — `<attr> : String -> Attr`.
//
//   An author who deliberately narrowed an attribute to three values got exactly
//   the surface they would have got by writing no override at all, with no error,
//   no warning, and nothing in the emitted output to notice. A downstream brand's
//   `disable-pagination` shipped that way for a whole release line.
//
// The fix has two halves and this gate pins both:
//
//   LIST form — every pair is `token == value`, which IS an `AEnum`, so
//     `fromOverride` normalizes it to the variant the pipeline already understood.
//     This is the half that fixes every override any config in the family writes.
//   MAP form  — at least one pair differs (`{"always": "true"}`), so it stays
//     `AEnumMap` and the pipeline carries the token/value split all the way down:
//     the TOKEN becomes the Elm identifier and the phantom row field, the VALUE
//     becomes what `Ir.token` writes to the DOM.
//
// Both halves are asserted on emitted TEXT (the signature and the `Ir.token`
// payload) and then COMPILED: `src/Good.elm` must build against the emitted brand,
// and every `bad/*.elm` must fail. Grepping alone would not catch a row that is
// spelled right and does not type-check; compiling alone would not catch a setter
// that is `String -> Attr` (which compiles fine — that is exactly the bug).
//
// Run standalone: `node tests/enum-override.test.mjs`. Wired into `npm test`.

import { execFileSync, spawnSync } from "node:child_process";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, "..");
const elm = path.join(repo, "node_modules", ".bin", "elm");
const elmFormat = path.join(repo, "node_modules", ".bin", "elm-format");
// The IR substrate lives beside this repo; the phantom gate resolves it the same way.
const irSrc = path.resolve(repo, "..", "elm-html-intermediate-representation", "src");
const fixture = path.join(here, "enum-override");

let failures = 0;
const check = (ok, msg) => {
  if (ok) console.log(`  PASS  ${msg}`);
  else {
    console.error(`  FAIL  ${msg}`);
    failures += 1;
  }
};

const work = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-enum-override-"));
const outSrc = path.join(work, "src");
fs.mkdirSync(outSrc, { recursive: true });

try {
  execFileSync(
    "node",
    [
      path.join(repo, "bin", "elm-cem.js"),
      `--flags-from=${path.join(fixture, "probe.cem.json")}`,
      `--config-from=${path.join(fixture, "probe.config.json")}`,
      `--output=${outSrc}`,
    ],
    { stdio: "pipe" },
  );
} catch (e) {
  console.error(`enum-override: FAIL — generator crashed: ${e.stdout || ""}${e.stderr || ""}${e.message}`);
  process.exit(1);
}

// elm-format so the assertions match the normalized (committed) form.
execFileSync(elmFormat, [outSrc, "--yes"], { stdio: "pipe" });

const read = (rel) => {
  const full = path.join(outSrc, rel);
  if (!fs.existsSync(full)) {
    console.error(`enum-override: FAIL — generator emitted no ${rel}`);
    process.exit(1);
  }
  return fs.readFileSync(full, "utf8");
};

const attrs = read(path.join("Eo", "Attributes.elm"));
const values = read(path.join("Eo", "Values.elm"));
const bar = read(path.join("Eo", "Component", "Bar.elm"));
const gate = read(path.join("Eo", "Component", "Gate.elm"));

// ── LIST form: `"disable-pagination": ["true", "false", "auto"]` ───────────────
//
// The exact shape that shipped broken. The negative assertion is the load-bearing
// one: `String -> Attr` is what the bug emitted, and it compiles, so only naming it
// keeps the regression out.
check(
  attrs.includes("disablePagination : Value Eo.Values.DisablePagination -> Attr { c | disablePagination : Supported } msg"),
  "LIST form: the shared setter takes `Value <Lib>.Values.DisablePagination`",
);
check(
  !/^disablePagination : String ->/m.test(attrs),
  "LIST form: the shared setter is NOT `String -> Attr` (the regression)",
);
check(
  attrs.includes('disablePagination value_ =\n    Ir.attribute "disable-pagination" (HtmlIr.Value.toString value_)'),
  "LIST form: the setter body writes the token's string to the kebab HTML attribute",
);
check(
  values.includes("type alias DisablePagination =\n    { auto : Supported\n    , false : Supported\n    , true : Supported\n    }"),
  "LIST form: `<Lib>.Values` carries a `DisablePagination` row over all three tokens",
);
for (const [ident, payload] of [
  ["true", "true"],
  ["false", "false"],
]) {
  check(
    values.includes(`${ident} : Value { v | ${ident} : Supported }\n${ident} =\n    Ir.token "${payload}"`),
    `LIST form: token \`${ident}\` is minted in <Lib>.Values as Ir.token "${payload}"`,
  );
}
check(
  bar.includes("disablePagination : Value DisablePagination -> Attr { c | disablePagination : Supported } msg"),
  "LIST form: the per-component setter narrows to the component's own row alias",
);

// ── MAP form: `"strict": { "always": "true", "never": "false", "auto": "auto" }` ─
//
// Same `Value` surface, plus the thing only this form can get wrong: the TOKEN is
// the Elm identifier and the VALUE is what reaches the DOM.
check(
  attrs.includes("strict : Value Eo.Values.Strict -> Attr { c | strict : Supported } msg"),
  "MAP form: the shared setter takes `Value <Lib>.Values.Strict`",
);
check(!/^strict : String ->/m.test(attrs), "MAP form: the shared setter is NOT `String -> Attr`");
check(
  values.includes("type alias Strict =\n    { always : Supported\n    , auto : Supported\n    , never : Supported\n    }"),
  "MAP form: the `Strict` row is over the TOKEN names, not the strings they write",
);
for (const [ident, payload] of [
  ["always", "true"],
  ["never", "false"],
]) {
  check(
    values.includes(`${ident} : Value { v | ${ident} : Supported }\n${ident} =\n    Ir.token "${payload}"`),
    `MAP form: token \`${ident}\` writes "${payload}" — the pair's VALUE, not its name`,
  );
}
check(
  !values.includes('Ir.token "always"') && !values.includes('Ir.token "never"'),
  "MAP form: no token writes its own NAME when the override gave it a different value",
);
// The docs have to say so too: a caller reading `always` with no further information
// would reasonably conclude it writes `always`.
check(
  values.includes("{-| The `always` token. Writes `\"true\"`. -}") ||
    /\{-\| The `always` token\. Writes `"true"`\.\s*-\}/.test(values),
  "MAP form: the token's docs name the string it writes",
);
check(
  gate.includes("strict : Value Strict -> Attr { c | strict : Supported } msg"),
  "MAP form: the per-component setter narrows to the component's own row alias",
);

// ── Token POOLING across both forms plus the CEM enum ─────────────────────────
//
// `auto` is minted by the `mode` CEM enum and asked for by BOTH overrides. It must be
// reused. A duplicate identifier in `<Lib>.Values` is a hard COLLISION error the
// generator raises on purpose, so a pooling regression would fail the run above rather
// than reach this assertion — which is the point of counting it here anyway.
check(
  (values.match(/^auto : Value \{ v \| auto : Supported \}$/gm) || []).length === 1,
  "pooling: the `auto` token is declared exactly ONCE, shared by the CEM enum and both overrides",
);
check(values.includes('auto =\n    Ir.token "auto"'), "pooling: the shared `auto` token still writes \"auto\"");

// ── AEnumNum (`number | 'all'`) — the documented degradation ──────────────────
//
// NOT a bug being pinned in place: `HtmlIr.Value`'s phantom row is over string TOKENS
// and has no numeric member, so "the literal rows plus a number row" is not a type this
// substrate can spell. `String` is the only thing that can write BOTH a number and the
// keyword, exactly as the `weight` / `weightAsNumber` fixture argues. Pinned so that
// teaching `AEnumNum` a `Value` row is a deliberate decision with a failing test in
// front of it, rather than something that quietly happens.
check(
  attrs.includes("maxVisible : String -> Attr { c | maxVisible : Supported } msg"),
  "AEnumNum: `number | 'all'` emits a plain `String` setter (see Attr.AttrType)",
);
check(!values.includes("type alias MaxVisible"), "AEnumNum: mints no union row (there is no numeric Value row to mint)");
check(!values.includes('Ir.token "all"'), "AEnumNum: mints no tokens, so nothing half-typed leaks into <Lib>.Values");

// ── Compile: Good must build, every bad/*.elm must fail ───────────────────────
const acid = fs.mkdtempSync(path.join(os.tmpdir(), "elm-cem-enum-override-acid-"));
for (const d of ["src", "bad"]) {
  fs.cpSync(path.join(fixture, d), path.join(acid, d), { recursive: true });
}
const elmJson = JSON.parse(fs.readFileSync(path.join(fixture, "elm.json"), "utf8"));
elmJson["source-directories"] = ["src", "bad", outSrc, irSrc];
fs.writeFileSync(path.join(acid, "elm.json"), JSON.stringify(elmJson, null, 4));

const compile = (file) => spawnSync(elm, ["make", file, "--output=/dev/null"], { cwd: acid, encoding: "utf8" });

const good = compile("src/Good.elm");
check(good.status === 0, `acid: Good.elm compiles against the emitted brand${good.status === 0 ? "" : `\n${(good.stderr || good.stdout || "").slice(0, 2500)}`}`);

for (const f of fs.readdirSync(path.join(fixture, "bad")).filter((f) => f.endsWith(".elm"))) {
  check(compile(path.join("bad", f)).status !== 0, `acid: bad/${f} is REJECTED`);
}

// ── Token-payload COLLISION: one token name, two strings, must FAIL the run ────
//
// The other side of pooling. Sharing the pool is what makes `auto` reusable; it also
// means a MAP override can ask a pooled token to write a DIFFERENT string, and
// `<Lib>.Values` mints only one `Ir.token` per identifier. Picking a winner would
// corrupt the loser silently — a legal `Value` row writing the wrong string, with
// nothing for a type checker to object to — so the generator must refuse.
{
  const out = path.join(work, "collision-never-created");
  const r = spawnSync(
    "node",
    [
      path.join(repo, "bin", "elm-cem.js"),
      `--flags-from=${path.join(fixture, "probe.cem.json")}`,
      `--config-from=${path.join(fixture, "collision.config.json")}`,
      `--output=${out}`,
    ],
    { encoding: "utf8" },
  );
  const text = (r.stdout || "") + (r.stderr || "");
  check(r.status !== 0, "collision: one token name asked to write two strings FAILS the run");
  check(!fs.existsSync(out), "collision: nothing is emitted");
  // A failing run that says the wrong thing teaches nothing, so pin the diagnostic.
  for (const needle of ["COLLISION", "Eo.Values", "'auto'", '"auto"', '"automatic"', "attrTypes"]) {
    check(text.includes(needle), `collision: the error names ${JSON.stringify(needle)}`);
  }
}

// ── An EMPTY enum override must FAIL the run, not emit dead code ───────────────
//
// `[]` / `{}` admits nothing, so it cannot be a real constraint. Two things had to be
// true for this to be rejected rather than swallowed, and both are asserted here:
// the config decoder returns an `Err`, and `Generate.elm` PROPAGATES it. That second
// half used to answer any config decode error by falling back to the raw manifest
// declarations — discarding `_exclude`, every `attrTypes` override and every synthetic
// attr from one typo, with a zero exit code and nothing on stderr.
{
  const out = path.join(work, "empty-enum-never-created");
  const r = spawnSync(
    "node",
    [
      path.join(repo, "bin", "elm-cem.js"),
      `--flags-from=${path.join(fixture, "probe.cem.json")}`,
      `--config-from=${path.join(fixture, "empty-enum.config.json")}`,
      `--output=${out}`,
    ],
    { encoding: "utf8" },
  );
  check(r.status !== 0, "empty enum: an `attrTypes` override with no values FAILS the run");
  check(!fs.existsSync(out), "empty enum: nothing is emitted (the config error is not swallowed)");
  check(
    ((r.stdout || "") + (r.stderr || "")).includes("at least one value"),
    "empty enum: the error says an enum override needs at least one value",
  );
}

console.log(
  failures === 0
    ? "\nenum-override: OK — both `attrTypes` enum override forms emit real `Value` setters, rows and tokens."
    : `\nenum-override: ${failures} failure(s)`,
);
process.exit(failures === 0 ? 0 : 1);
