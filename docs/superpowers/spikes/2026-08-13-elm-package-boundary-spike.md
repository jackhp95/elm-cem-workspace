# Spike — the elm-m3e package boundary: is there a size ceiling?

Date: 2026-08-13 · Status: measured, decided · Scope: measurement only, nothing under `packages/` changed.

---

## 1. Verdict

**Claim A is correct: a hard size ceiling exists and this surface blows through it.** The Elm
registry rejects any `docs.json` larger than **768,000 bytes** — a literal in
`elm/package.elm-lang.org`, `src/backend/Package/Register.hs`. A monolith exposing the combined
surface produces a `docs.json` of **1,450,795 bytes — 189% of the cap.** A monolith is not
publishable, so the 2026-08-12 liaison's "monolith is registry-faithful today" is **wrong on the
number**.

**But Claim A does not vindicate the current split, and the split is not "the size fix" either.**
Measured the same way, `jackhp95/elm-m3e-builder` alone emits **810,420 bytes — 105.5% of the cap.**
It is over on its own. And two of the three split packages **do not compile at all**: the
"split" declares a DAG (`core ← components ← builder`) that the source contradicts with two
back-edges, so it is a labelling of one mutually-recursive module graph, not a partition.

**Net:** neither shape is publishable today. The split must be *re-cut*, not merely retained.
A boundary that does fit exists and is measured below (§4.3): `core + M3e.Component.*` in one
package is **640,376 bytes (83.4% of cap)**; the `M3e.Build.*` surface must then be split again.

---

## 2. The constraint — where the number comes from

### 2.1 The cap is server-side, in the registry backend

`elm publish` POSTs a multipart form to `package.elm-lang.org/register`. Each part is bounded
before it is stored. From
[`elm/package.elm-lang.org`, `src/backend/Package/Register.hs`](https://github.com/elm/package.elm-lang.org/blob/master/src/backend/Package/Register.hs):

```haskell
handlePart :: Pkg.Name -> V.Version -> FilePath -> Snap.PartInfo -> SC.InputStream BS.ByteString -> IO (Either String FilePath)
handlePart pkg vsn dir info stream =
  case Snap.partFieldName info of
    "README.md"    -> boundedGzipAndWrite 512000 dir "README.md" stream
    "elm.json"     -> boundedGzipAndWrite 128000 dir "elm.json"  stream
    "docs.json"    -> boundedGzipAndWrite 768000 dir "docs.json" stream
    "github-hash"  -> boundedWriteEndpoint pkg vsn dir stream
    path           -> return $ Left $ "Did not recognize " ++ show path ++ " part in form-data"

boundedGzipAndWrite :: Int64 -> FilePath -> FilePath -> SC.InputStream BS.ByteString -> IO (Either String FilePath)
boundedGzipAndWrite maxBytes dir path input =
  Ex.handle (exceededMaxBytes maxBytes path) $
  SF.withFileAsOutput (dir </> path <.> "gz") $ \output ->
    do  boundedInput <- SB.throwIfProducesMoreThan maxBytes input
        gzipper <- SZ.gzip (SZ.CompressionLevel 9) output
        SC.connect boundedInput gzipper
        return (Right path)

exceededMaxBytes maxBytes path _ =
  return $ Left $
    "Your " ++ path ++ " is too big. Must be less than " ++ show (div maxBytes 1000) ++ "kb.
Let us know if this limit is too low!"
```

Three facts that matter:

| Artifact | Cap (bytes) | Notes |
|---|---|---|
| `docs.json` | **768,000** | the binding constraint here |
| `README.md` | 512,000 | also must be **≥ 300 bytes** (compiler side, §5.1) |
| `elm.json` | 128,000 | our largest is 9,636 B — not close |

- The bound is applied to the **uncompressed** stream: `throwIfProducesMoreThan` wraps `input`,
  and `gzip` is connected *downstream* of it. Gzipping your docs does not help. (For reference,
  the 1,450,795-byte monolith `docs.json` gzips to 102,973 bytes — irrelevant to the check.)
- The limit is a **plain integer literal in the backend**, not configurable per package, and
  there is no client-side pre-check. You discover it as an HTTP 400 at the very last step of
  `elm publish`, after the git tag is already pushed.
- The error text is friendly ("Let us know if this limit is too low!"), i.e. it is a soft-ish
  policy limit that has been raised before — but it is 768,000 today and nothing in the
  compiler or registry lets a publisher exceed it.

### 2.2 `elm make --docs` produces the exact bytes that get uploaded

This is what makes the measurement valid rather than a proxy. Both paths use the same encoder:

- `elm publish` → `terminal/src/Publish.hs`:
  `Http.jsonPart "docs.json" "docs.json" (Docs.encode docs)`, and
  `builder/src/Http.hs`: `jsonPart … = Multi.RequestBodyLBS $ B.toLazyByteString $ Encode.encodeUgly value`.
- `elm make --docs FILE` → `builder/src/Build.hs`:
  `WriteDocs path -> E.writeUgly path $ Docs.encode $ Map.mapMaybe toDocs results`.

Same `Docs.encode`, same ugly (no-whitespace) encoder. **The byte size of the file written by
`elm make --docs docs.json` is the byte size the server bounds at 768,000.**

`elm publish`'s own build step is literally the same call:
`Build.fromExposed Reporting.silent root details Build.KeepDocs exposed` (`verifyBuild`).

### 2.3 There is no file-count, compile-time, or memory ceiling

Verified by reading `Publish.hs` end to end: no check on module count, source size, or build
duration. And empirically none is near: the 409-module monolith compiles in **0.67 s wall**.
Peak RSS is a red herring — `elm --version` alone reports 1,384,742,912 B maximum resident set
size on this machine, so the ~1.5 GB figures below are a fixed GHC RTS reservation with roughly
120 MB of actual work on top.

**`docs.json` bytes is the only wall.**

---

## 3. Method (re-runnable)

Toolchain: workspace-pinned `node_modules/.bin/elm` → `/Users/jhp/.elm/elm-tooling/elm/0.19.1/elm`,
`elm --version` = `0.19.1`. Host: MacBookPro18,2, 10 cores, 64 GiB, macOS 15.7.3.

For each variant, in a fresh `/tmp` directory (never inside `packages/`):

1. Copy the relevant `src/` trees into one `src/`.
2. Also copy `packages/elm-html-intermediate-representation/src` and
   `packages/elm-cem/facts/src` into that `src/`. These two workspace dependencies are not on
   the registry yet, so they are vendored as **unexposed** modules. Because `elm make --docs`
   only emits docs for `exposed-modules`, they contribute **zero bytes** to `docs.json`; they
   only remove the need for a registry that does not have them.
3. Write an `elm.json` of `type: package` whose `exposed-modules` is the surface under test and
   whose `dependencies` are the four `elm/*` packages.
4. Run `elm make --docs docs.json --output=/dev/null` under `/usr/bin/time -l`.
5. Record exit code, wall-clock, peak RSS, `docs.json` bytes, and the module count inside it.

The harness used is reproduced verbatim in Appendix A. The headline monolith number was also
reproduced by hand, independently of the harness (Appendix B), and is deterministic across three
cold runs (`1450795`, `1450795`, `1450795`).

Reading the numbers: `docs.json` here is *raw file size*, the same quantity the server bounds.
Cap = 768,000 B.

---

## 4. Measurements

### 4.1 The monolith

| Variant | Exposed modules | Modules compiled | Exit | Wall | Peak RSS | `docs.json` | % of 768,000 cap |
|---|---:|---:|---:|---:|---:|---:|---:|
| **M1 — union of the three split surfaces, built from the split `src/` trees** | 270 | 409 | 0 | 0.67 s | 1.51 GB | **1,450,795 B** | **189.0 % — OVER** |
| M2 — the surface declared by `packages/elm-m3e/elm.json`, built from `packages/elm-m3e/src/` | 139 | 409 | 0 | 0.61 s | 1.43 GB | **802,819 B** | **104.5 % — OVER** |
| M3 — the union surface, built from `packages/elm-m3e/src/` | 270 | 409 | 0 | 0.73 s | 1.47 GB | **1,230,242 B** | **160.2 % — OVER** |

M1 is the decisive figure: it is the exact registry content of the three published packages,
collapsed into one. It compiles cleanly — **the monolith is not a compiler problem, it is a
registry-policy problem**, and it misses by 682,795 bytes.

M2 is the *currently committed root* `packages/elm-m3e/elm.json`. It too is over the cap, by
34,819 bytes. Whatever that file is intended to be, it cannot publish as written.

M3 vs M1 (1,230,242 vs 1,450,795 for the identical 270-module surface) quantifies a drift finding:
see §4.4.

### 4.2 The current split, measured the same way

| Package | Exposed | Compiled | Exit | Wall | `docs.json` | % of cap | Verdict |
|---|---:|---:|---:|---:|---:|---:|---|
| `jackhp95/elm-m3e` (as committed) | 8 | — | **1** | 0.59 s | — | — | **does not compile** |
| `jackhp95/elm-m3e` minus the `M3e` barrel | 7 | 16 | 0 | 0.45 s | 160,754 B | 20.9 % | under |
| `jackhp95/elm-m3e-components` (as committed) | 131 | — | **1** | 0.72 s | — | — | **does not compile** |
| `jackhp95/elm-m3e-builder` | 131 | 409 | 0 | 0.59 s | **810,420 B** | **105.5 % — OVER** | **would be rejected** |

**Only one of the three even builds, and that one is over the cap.**

#### The two compile failures are package-level dependency cycles

Declared dependency direction, from the `elm.json` files:
`elm-m3e` ← `elm-m3e-components` ← `elm-m3e-builder`.

The source contains two back-edges against that DAG:

| Back-edge | Count | Evidence |
|---|---:|---|
| `elm-m3e`'s `src/M3e.elm` (the barrel, **exposed**) imports `M3e.Component.*` — which live in the downstream `elm-m3e-components` | 130 imports | `rg -c '^import M3e\.Component' packages/elm-m3e/elm-m3e/src/M3e.elm` → 130 |
| `elm-m3e-components`' `src/M3e/Internal/Types/*.elm` import `M3e.Build.Internal` — which lives in the downstream `elm-m3e-builder` | 130 files | `rg -l '^import M3e\.Build\.Internal' packages/elm-m3e/elm-m3e-components/src \| wc -l` → 130 |

Verbatim, first error of each:

```
-- MODULE NOT FOUND ------------------------------------------------ src/M3e.elm

You are trying to import a `M3e.Component.Accordion` module:

27| import M3e.Component.Accordion
           ^^^^^^^^^^^^^^^^^^^^^^^
I checked the "dependencies" and "source-directories" listed in your elm.json,
but I cannot find it! …
```

```
-- MODULE NOT FOUND ----------------------- src/M3e/Internal/Types/Accordion.elm

You are trying to import a `M3e.Build.Internal` module:

9| import M3e.Build.Internal as B
          ^^^^^^^^^^^^^^^^^^
I checked the "dependencies" and "source-directories" listed in your elm.json,
but I cannot find it! …
```

Two independent reasons the second one can never be fixed by reordering the DAG:
`M3e.Build.Internal` is **not in `elm-m3e-builder`'s `exposed-modules`** (an Elm package cannot
import a dependency's unexposed module), and reversing the edge would just invert the cycle.

So the three directories are **not a partition of the surface**. They are three overlapping views
of one mutually-recursive module graph, and the only configuration that compiles is all 402 files
together. `elm-m3e-builder` "passes" solely because its build sees every source in the family.

### 4.3 Where the bytes are, and what boundary would actually fit

Per-module `docs.json` entry sizes, computed from the M1 `docs.json` (compact re-encode; within
~1 % of Elm's own encoding — cross-check: this method estimates the builder group at 816,795 B
against a measured 810,420 B):

| Group | Modules | Bytes | Share |
|---|---:|---:|---:|
| `M3e.Build.*` | 131 | 816,795 | 56.3 % |
| `M3e.Component.*` | 130 | 433,586 | 29.9 % |
| primitives (`M3e`, `M3e.Action`, `M3e.Attributes`, `M3e.Events`, `M3e.Kind`, `M3e.Unsafe`, `M3e.Unsafe.Attributes`, `M3e.Values`) | 8 | 207,387 | 14.3 % |
| `M3e.Review.Facts` | 1 | 997 | 0.1 % |

Ten largest single modules — the primitives dominate, not the components:

| Module | Bytes |
|---|---:|
| `M3e.Values` | 94,865 |
| `M3e.Attributes` | 48,601 |
| `M3e` (barrel) | 45,951 |
| `M3e.Build` (barrel) | 27,522 |
| `M3e.Build.SearchView` | 13,605 |
| `M3e.Build.Button` | 12,835 |
| `M3e.Build.Step` | 11,776 |
| `M3e.Build.Paginator` | 11,553 |
| `M3e.Build.Datepicker` | 10,882 |
| `M3e.Build.IconButton` | 10,830 |

**Measured** candidate boundaries (all built from the full 402-file source tree, so the compile
always succeeds and only the exposed surface varies — this isolates the cap question from the
cycle question):

| Candidate surface | Exposed | Exit | Wall | `docs.json` | % of cap |
|---|---:|---:|---:|---:|---:|
| **primitives + `M3e.Component.*`** (one package) | 139 | 0 | 0.81 s | **640,376 B** | **83.4 % — fits** |
| `M3e.Build.*` only | 131 | 0 | 0.64 s | **810,420 B** | **105.5 % — over** |
| primitives only | 8 | 0 | 0.56 s | **206,685 B** | 26.9 % — fits |

Consequences for any re-cut:

- **Minimum package count is 2 by arithmetic** (1,450,795 / 768,000 = 1.89) but **2 is not
  reachable with a clean module grouping**: the only 2-way cut along the natural seam is
  {primitives + components} = 640,376 and {builders} = 810,420, and the second is over by
  42,420 B (5.5 %). Making 2 work would mean relocating ~50 KB of `M3e.Build.*` modules into the
  components package — an arbitrary cut through a homogeneous family.
- **The natural fit is 3 packages**: primitives · `M3e.Component.*` · `M3e.Build.*`-split-in-two;
  or primitives+components · `M3e.Build.*` A–M · `M3e.Build.*` N–Z. Either way the *current* 3-way
  boundary is the wrong 3-way boundary, because it puts all 131 builders in one package.
- Trimming doc comments is a real lever but a bad one: M3 vs M1 shows stripping prose from the
  `M3e.Build.*` docstrings buys 220,553 B (15 %) at the cost of the documentation itself — and
  even then the union is 160 % of cap.

### 4.4 Incidental finding — `packages/elm-m3e/src/` has drifted from the split directories

`packages/elm-m3e/src/` and the union of the three split `src/` trees contain **exactly the same
402 file paths**, but **278 of the 402 files differ in content**. The dominant difference is
documentation: the split copies carry full prose docstrings, the root copy carries stubs.

```
--- packages/elm-m3e/src/M3e/Build/Badge.elm
+++ packages/elm-m3e/elm-m3e-builder/src/M3e/Build/Badge.elm
-{-|
+{-| The builder module for `m3e-badge` — seed, pipe, and close.
+
+This module provides everything you need to BUILD with `Badge` …
-{-| -}
+{-| The kind this element produces — a `Brand` that marks the phantom row.
+-}
```

There are also cosmetic diffs (import ordering, `elm-format` line breaks, a parameter renamed
`tag` → `tagName` in `M3e/Html.elm`). This is why M1 (1,450,795 B) and M3 (1,230,242 B) differ for
an identical 270-module surface. **Two sources of truth for the same generated code is a hazard
independent of the boundary question**, and it means "the size of the surface" is currently
ambiguous by 15 %. Flagged, not fixed — out of spike scope.

### 4.5 Two `elm.json` files claim `jackhp95/elm-m3e` version 1.0.0

`packages/elm-m3e/elm.json` (139 exposed: 130 `M3e.Build.*` + `M3e.Build` + `M3e.Html` +
primitives) and `packages/elm-m3e/elm-m3e/elm.json` (8 exposed: the primitives + the `M3e`
barrel) both declare `"name": "jackhp95/elm-m3e"`, `"version": "1.0.0"`. They are **different
surfaces under the same registry coordinate**; at most one can ever be published as 1.0.0. This
is the "different shape from the split" noted in the spike brief: the root file is not the
monolith and not a member of the split — it is a third, currently-unpublishable candidate.

### 4.6 `elm-m3e-icons` does not exist in this workspace

Searched: no `elm-m3e-icons` directory, no `elm.json` with that name, no source tree.

```
$ find . -name elm.json -not -path './node_modules/*' | xargs -I{} sh -c 'echo "{}: $(jq -r .name {})"'
```
returns these Elm packages only: `jackhp95/elm-review-cem`, `jackhp95/elm-typed-html`,
`jackhp95/elm-m3e` (×2), `jackhp95/elm-html-intermediate-representation`,
`jackhp95/elm-m3e-components`, `jackhp95/elm-m3e-builder`, `jackhp95/elm-probe-pkg`,
`jackhp95/elm-cem-facts`.

The only mention of `elm-m3e-icons` anywhere is aspirational, in
`docs/superpowers/specs/2026-08-12-elm-cem-workspace-spine-design.md:187`, which lists it among
packages that "publish to the Elm registry" at Phase 5. There is icon *config*
(`packages/elm-m3e/config/icons.json`) and docs-site icon tooling, but no icons package.

Implication for layout (§6): the reported upstream icons split has **not** landed here. Any
layout recommendation must not assume it, and if icons are later extracted they add a *fourth*
published package — which strengthens the case for a layout that scales to N packages rather
than one that hardcodes three.

---

## 5. Publishing from a monorepo

### 5.1 What `elm publish` actually requires

Read from `elm/compiler@0.19.1`, `terminal/src/Publish.hs`. In execution order:

| # | Requirement | Enforced by |
|---|---|---|
| 1 | cwd's `elm.json` is `type: package` with a non-empty `exposed-modules` | `Outline.App _ -> PublishApplication`; `noExposed` |
| 2 | `summary` is non-empty and not the default placeholder | `badSummary` |
| 3 | `README.md` exists at the package root and is **≥ 300 bytes** | `verifyReadme`: `if size < 300 then PublishShortReadme` |
| 4 | `LICENSE` exists at the package root (existence only; content unchecked) | `verifyLicense` |
| 5 | The package builds and all exposed modules produce docs | `verifyBuild` → `Build.fromExposed … KeepDocs` |
| 6 | `version` is a legal semver step from what's already published | `verifyVersion` |
| 7 | `git` is on `PATH` | `getGit` |
| 8 | A **local git tag named exactly the version** — `1.0.0`, not `v1.0.0` | `git show --name-only 1.0.0 --` must exit 0 |
| 9 | A **public GitHub repo whose `owner/name` equals the `elm.json` `name`**, with that tag pushed | `GET https://api.github.com/repos/<author>/<project>/git/refs/tags/<version>` |
| 10 | Working tree identical to the tagged commit | `git diff-index --quiet <sha> --` |
| 11 | `https://github.com/<author>/<project>/zipball/<version>/` downloads, and **rebuilds from scratch** in `elm-stuff/prepublish/` | `verifyZip` → `verifyZipBuild` |
| 12 | `docs.json` ≤ 768,000 B, `README.md` ≤ 512,000 B, `elm.json` ≤ 128,000 B | registry `/register` (§2.1) |

Two things worth correcting against common assumption:

- **`elm publish` never inspects your `origin` remote.** It resolves GitHub from the *name* in
  `elm.json`. The git checks (#8, #10) are purely local. The coupling is indirect but total:
  the commit SHA comes from GitHub and must be the one your working tree matches, so the local
  repo must share history with the named GitHub repo.
- Requirement #11 is the one the monorepo layout genuinely constrains: the **GitHub zipball must
  have `elm.json` at its top level**. A tag on a monorepo whose `elm.json` sits at
  `packages/elm-m3e/elm-m3e/elm.json` produces a zipball that `Details.load` rejects. There is
  no `--path` / subdirectory flag anywhere in `Publish.hs`.

Also implied by #5: **dependencies must already be on the registry.** That forces a topological
publish order.

### 5.2 Therefore: a mirror repo per published package

`git subtree split` alone is **not sufficient**, for a reason specific to this repo: it only
carries files under the prefix, and none of the three split directories contains a `README.md`
or a `LICENSE` —

```
$ ls packages/elm-m3e/elm-m3e packages/elm-m3e/elm-m3e-components packages/elm-m3e/elm-m3e-builder
elm.json  src        (×3 — that is the whole content)
```

so a subtree-split mirror fails at requirement #3 before it ever reaches the size cap. The
release step must **assemble** the mirror tree, not just extract it.

Concrete sequence, per published package (`$PKG` = the elm.json `name`, `$DIR` = its source
directory in this repo, `$VSN` = its `version`):

```bash
# 0. one-time, per package
gh repo create "$PKG" --public --description "$(jq -r .summary "$DIR/elm.json")"

# 1. fresh mirror checkout, OUTSIDE the monorepo
git clone "git@github.com:$PKG.git" "/tmp/mirror/$PKG"

# 2. assemble the publishable tree at the mirror ROOT
rsync -a --delete --exclude .git "$DIR/"  "/tmp/mirror/$PKG/"   # elm.json + src/
cp packages/elm-m3e/README.md  "/tmp/mirror/$PKG/README.md"     # ≥300 B, ≤512,000 B
cp packages/elm-m3e/LICENSE    "/tmp/mirror/$PKG/LICENSE"

# 3. commit and tag with the EXACT version string — no `v` prefix
cd "/tmp/mirror/$PKG"
git add -A && git commit -m "release $VSN"
git tag "$VSN"
git push origin HEAD:main --follow-tags

# 4. publish FROM the mirror root
/path/to/elm-cem-workspace/node_modules/.bin/elm publish
```

Publish order is forced by requirement #5 (deps must be resolvable from the registry):

```
jackhp95/elm-html-intermediate-representation
jackhp95/elm-cem-facts
  → jackhp95/elm-m3e
      → jackhp95/elm-m3e-components
          → jackhp95/elm-m3e-builder
```

A monolith collapses that tail to a single step after the two substrate packages.

### 5.3 Does layout change the publish work? No.

**The mirror step is forced either way.** It is forced by requirements #8–#11 — package at a
repo root, matching GitHub coordinate, tag, buildable zipball — none of which mention folder
depth. A monolith living at `packages/elm-m3e/` is exactly as un-publishable in place as
`packages/elm-m3e/elm-m3e-builder/` is; both are subdirectories of a repo whose root has no
`elm.json`.

What *does* scale with the split is the **count**: one mirror repo, one tag, one `elm publish`
per published package, plus a topological ordering constraint that a monolith does not have.
That is release-pipeline cost, not a layout property. Moving the folders around changes neither.

### 5.4 What the current workspace layout blocks

Registry-faithfulness of the `elm.json` files **still holds** — verified, this is the Phase-0
invariant intact:

| Package | `type` | `name` | Deps | `source-directories`? |
|---|---|---|---|---|
| `elm-m3e/elm-m3e` | package | `jackhp95/elm-m3e` | 6, all semver ranges | none (correct for a package) |
| `elm-m3e/elm-m3e-components` | package | `jackhp95/elm-m3e-components` | 7, all semver ranges | none |
| `elm-m3e/elm-m3e-builder` | package | `jackhp95/elm-m3e-builder` | 7, all semver ranges | none |
| `elm-m3e` (root) | package | `jackhp95/elm-m3e` | 6, all semver ranges | none |

No local paths, no `workspace:*`, no rewritten names. Nothing in the `elm.json` files needs
undoing before release.

Blockers that are real, in the order `elm publish` would hit them:

1. **No `README.md`, no `LICENSE`** in any of the three split directories (§5.2) — fails #3/#4.
2. **`jackhp95/elm-m3e` and `jackhp95/elm-m3e-components` do not compile** (§4.2) — fails #5.
3. **No git remotes and no tags** in this repo (`git remote -v` → empty, `git tag | wc -l` → 0)
   — fails #8/#9. Expected for a pre-release monorepo; the mirror step supplies both.
4. **`jackhp95/elm-m3e-builder`'s `docs.json` is 810,420 B** — fails #12, as would any monolith.
5. **Two `elm.json` files claim `jackhp95/elm-m3e` 1.0.0** (§4.5) — ambiguous release target.

---

## 6. Recommendation on dev-folder layout

Separating the two kinds of claim, as asked.

### 6.1 What the measurement forces

- **The published surface must be split across ≥ 2 packages, and realistically 3.** 1,450,795 B
  against a 768,000 B cap is not a judgement call. Collapsing to a monolith is off the table
  until the surface shrinks by 47 %.
- **The current 3-way cut is not one of the valid cuts.** `elm-m3e-builder` at 810,420 B is over
  on its own, and the cut is not a partition at all (§4.2). Retaining the split "because of the
  size limit" retains something that does not solve the size limit.
- **A valid cut exists and is measured**: primitives + `M3e.Component.*` = 640,376 B (83.4 %),
  leaving `M3e.Build.*` (810,420 B) to be divided in two. Any re-cut must be validated by
  re-running the harness, not by module counting — the bytes are wildly non-uniform
  (`M3e.Values` alone is 94,865 B, 45× the median).
- **The measurement forces nothing about dev-folder layout.** Every requirement in §5.1 is
  satisfied by the mirror step, which is forced regardless (§5.3). No folder arrangement in this
  repo makes any package more or less publishable.

### 6.2 What is ergonomics (and my recommendation)

Given that the layout is unconstrained by the measurement, pick on other grounds — and here the
grounds point one way: **one folder per published package, and stop keeping a fourth merged tree.**

- The 402-file drift between `packages/elm-m3e/src/` and the split trees (§4.4) is a direct cost
  of having two layouts for the same generated code. One tree per published artifact removes the
  ambiguity, and the generator should own exactly one output shape.
- The boundary is going to move anyway (§6.1). Folders that *are* the packages make a re-cut a
  file move plus one harness run; a merged tree with a facet-selecting `elm.json` makes it an
  edit to a 270-entry list with no compile-time check that the facets are disjoint or acyclic.
- Both cycles in §4.2 are exactly the class of bug a merged tree hides and per-package folders
  surface — as this spike found, by compiling each folder in isolation. A per-package layout with
  a CI step that builds each package alone would have caught them at the commit that introduced
  them.
- If `elm-m3e-icons` lands (§4.6), it is a fourth package. A layout that generalises to N is
  worth more than one tuned to today's three.
- Cost of the recommendation, stated honestly: more directories, and shared `README`/`LICENSE`
  must be templated into each at release time — which the mirror step already has to do (§5.2),
  so it is not new work.

Concretely: keep `packages/elm-m3e/<pkg-name>/` as the unit, give each a real `README.md` and
`LICENSE`, retire `packages/elm-m3e/src` + `packages/elm-m3e/elm.json` as a publishable
candidate (or clearly demote them to generator scratch), and gate every package on
`docs.json ≤ 768000` plus a standalone compile.

The project's existing self-imposed **700,000-byte gate** is now grounded: it is a sane ~8.9 %
margin under the real 768,000 cap. Keep it as the gate; cite `Register.hs` as its provenance.

---

## 7. Open questions — not determined

Stated plainly rather than guessed:

1. **Is 768,000 stable?** The error text ("Let us know if this limit is too low!") implies the
   Elm team raises it on request. I did not find a changelog of past values, and I did not
   contact anyone. Treat 768,000 as today's number, not a permanent one. It is read from
   `master` of `elm/package.elm-lang.org`; whether the deployed registry runs exactly `master`
   is unverified.
2. **No end-to-end publish was performed.** Requirements #8–#11 were established by reading
   `Publish.hs`, not by pushing a real package to a real GitHub repo and hitting `/register`.
   The 400-response behaviour at the cap is inferred from the server source, not observed.
   Recommend a throwaway `jackhp95/elm-probe-pkg` dry run before Phase 5 — the workspace already
   has that package scaffolded at `packages/_probe/elm-probe-pkg/`.
3. **Which source tree is canonical** — `packages/elm-m3e/src/` or the split trees (§4.4) — is
   not something this spike can decide. It changes the monolith figure by 220,553 B (15 %) and
   should be settled before any re-cut is measured.
4. **Which of the two `jackhp95/elm-m3e` `elm.json` files is the intended package** (§4.5) is
   undetermined. Both are over cap or non-compiling today, so it is not urgent, but the re-cut
   cannot proceed without an answer.
5. **Whether the two cycles are intentional coupling or codegen bugs** was not investigated —
   only that they exist and that they make two packages unbuildable.
6. **Peak memory under a genuinely larger surface** is unknown; at this size the signal is buried
   in a fixed ~1.38 GB RTS reservation, so no headroom estimate is offered.

---

## Appendix A — the harness

Saved at `/tmp/m3e-spike/measure.mjs` during the spike (scratch; reproduced here in full so it
can be re-created). Run with `node measure.mjs [variant|all]`; writes JSON to stdout.

```js
#!/usr/bin/env node
// measure.mjs — SPIKE harness for the elm-m3e package-boundary question.
//
// For each variant: assemble a self-contained Elm PACKAGE in a fresh /tmp dir,
// run `elm make --docs docs.json --output=/dev/null` (exactly what `elm publish`
// runs via Build.fromExposed + WriteDocs), and record:
//   exit code, wall-clock ms, peak RSS bytes, docs.json byte size, module count.
//
// Nothing under packages/ is written to. Sources are COPIED out.

import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import { spawnSync } from "node:child_process";

const WS = "/Users/jhp/code/jackhp95/elm-cem-workspace";
const M3E = path.join(WS, "packages/elm-m3e");
const ELM = path.join(WS, "node_modules/.bin/elm");
const IR_SRC = path.join(WS, "packages/elm-html-intermediate-representation/src");
const FACTS_SRC = path.join(WS, "packages/elm-cem/facts/src");

// Registry hard cap on docs.json, from elm/package.elm-lang.org
// src/backend/Package/Register.hs -> handlePart: boundedGzipAndWrite 768000 dir "docs.json"
const HARD_CAP = 768000;

const copyElm = (src, dst) => {
  for (const e of fs.readdirSync(src, { withFileTypes: true })) {
    const s = path.join(src, e.name);
    const d = path.join(dst, e.name);
    if (e.isDirectory()) { fs.mkdirSync(d, { recursive: true }); copyElm(s, d); }
    else if (e.name.endsWith(".elm")) fs.copyFileSync(s, d);
  }
};

const exposedOf = (p) => JSON.parse(fs.readFileSync(p, "utf8"))["exposed-modules"];

function measure(label, { srcDirs, exposed, vendorFacts = true }) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "m3e-measure-"));
  const src = path.join(dir, "src");
  fs.mkdirSync(src, { recursive: true });
  for (const s of srcDirs) copyElm(s, src);
  // Vendor the two unpublished workspace deps as UNEXPOSED modules. They are not
  // in `exposed-modules`, so they contribute ZERO bytes to docs.json; this only
  // removes the need for a registry that does not have them yet.
  copyElm(IR_SRC, src);
  if (vendorFacts) copyElm(FACTS_SRC, src);

  fs.writeFileSync(path.join(dir, "elm.json"), JSON.stringify({
    type: "package",
    name: "jackhp95/elm-m3e-spike",
    summary: "docs.json size measurement for the elm-m3e package-boundary spike",
    license: "BSD-3-Clause",
    version: "1.0.0",
    "exposed-modules": [...exposed].sort(),
    "elm-version": "0.19.0 <= v < 0.20.0",
    dependencies: {
      "elm/core": "1.0.0 <= v < 2.0.0",
      "elm/html": "1.0.0 <= v < 2.0.0",
      "elm/json": "1.0.0 <= v < 2.0.0",
      "elm/virtual-dom": "1.0.0 <= v < 2.0.0",
    },
    "test-dependencies": {},
  }, null, 4) + "\n");

  const docs = path.join(dir, "docs.json");
  const t0 = process.hrtime.bigint();
  // /usr/bin/time -l reports peak RSS ("maximum resident set size") on macOS.
  const r = spawnSync("/usr/bin/time", ["-l", ELM, "make", "--docs", docs, "--output=/dev/null"],
    { cwd: dir, encoding: "utf8", timeout: 900000 });
  const ms = Number((process.hrtime.bigint() - t0) / 1000000n);

  const err = (r.stderr || "") + (r.stdout || "");
  const rssM = err.match(/(\d+)\s+maximum resident set size/);
  const ok = fs.existsSync(docs);
  const out = {
    label, dir, exposed: exposed.length, elmFiles: countElm(src),
    exit: r.status, ms, peakRssBytes: rssM ? Number(rssM[1]) : null,
    docsBytes: ok ? fs.statSync(docs).size : null,
    docsModules: ok ? JSON.parse(fs.readFileSync(docs, "utf8")).length : null,
    error: ok ? null : err.replace(/^\s*\d+\.\d+ real.*$/ms, "").trim().slice(0, 4000),
  };
  if (ok) fs.rmSync(dir, { recursive: true, force: true });
  return out;
}

function countElm(d) {
  let n = 0;
  for (const e of fs.readdirSync(d, { withFileTypes: true }))
    n += e.isDirectory() ? countElm(path.join(d, e.name)) : (e.name.endsWith(".elm") ? 1 : 0);
  return n;
}

const P = {
  core: path.join(M3E, "elm-m3e"),
  comp: path.join(M3E, "elm-m3e-components"),
  build: path.join(M3E, "elm-m3e-builder"),
};
const exp = {
  core: exposedOf(path.join(P.core, "elm.json")),
  comp: exposedOf(path.join(P.comp, "elm.json")),
  build: exposedOf(path.join(P.build, "elm.json")),
  root: exposedOf(path.join(M3E, "elm.json")),
};
const splitSrcs = [P.core, P.comp, P.build].map((p) => path.join(p, "src"));
const union = [...new Set([...exp.core, ...exp.comp, ...exp.build])];

const which = process.argv[2] || "all";
const VARIANTS = {
  "S1-core":       () => measure("S1 split: jackhp95/elm-m3e (as committed)", { srcDirs: [path.join(P.core, "src")], exposed: exp.core }),
  // S1b: same package with the `M3e` barrel dropped from exposed-modules. The barrel
  // imports 130 M3e.Component.* modules that live in the DOWNSTREAM package, so S1 as
  // committed is a package-level dependency cycle and cannot compile standalone.
  "S1b-core-nobarrel": () => measure("S1b split: jackhp95/elm-m3e minus the `M3e` barrel",
    { srcDirs: [path.join(P.core, "src")], exposed: exp.core.filter((m) => m !== "M3e") }),
  "S2-components": () => measure("S2 split: jackhp95/elm-m3e-components", { srcDirs: [path.join(P.core, "src"), path.join(P.comp, "src")], exposed: exp.comp }),
  "S3-builder":    () => measure("S3 split: jackhp95/elm-m3e-builder",    { srcDirs: splitSrcs, exposed: exp.build }),
  "M1-monolith":   () => measure("M1 monolith: union of split exposed (split sources)", { srcDirs: splitSrcs, exposed: union }),
  "M2-root":       () => measure("M2 monolith: root elm.json surface (root src/)",      { srcDirs: [path.join(M3E, "src")], exposed: exp.root }),
  "M3-rootall":    () => measure("M3 monolith: root src/, union surface (root src/)",   { srcDirs: [path.join(M3E, "src")], exposed: union }),
};

const results = [];
for (const [k, f] of Object.entries(VARIANTS)) {
  if (which !== "all" && which !== k) continue;
  process.stderr.write(`... ${k}\n`);
  const r = f();
  results.push({ key: k, ...r });
  process.stderr.write(`    exit=${r.exit} docs=${r.docsBytes} modules=${r.docsModules} ms=${r.ms}\n`);
}
console.log(JSON.stringify({ hardCap: HARD_CAP, results }, null, 2));
```

Harness output (stderr progress):

```
... S1-core
    exit=1 docs=null modules=null ms=587
... S1b-core-nobarrel
    exit=0 docs=160754 modules=7 ms=454
... S2-components
    exit=1 docs=null modules=null ms=721
... S3-builder
    exit=0 docs=810420 modules=131 ms=593
... M1-monolith
    exit=0 docs=1450795 modules=270 ms=697
... M2-root
    exit=0 docs=802819 modules=139 ms=610
... M3-rootall
    exit=0 docs=1230242 modules=270 ms=725
```

## Appendix B — independent hand reproduction of M1

Run without the harness, to rule out a harness bug in the headline number:

```bash
WS=/Users/jhp/code/jackhp95/elm-cem-workspace
M=/tmp/m3e-spike/manual-monolith
rm -rf "$M"; mkdir -p "$M/src"
for p in elm-m3e elm-m3e-components elm-m3e-builder; do
  (cd "$WS/packages/elm-m3e/$p/src" && tar cf - .) | (cd "$M/src" && tar xf -)
done
(cd "$WS/packages/elm-html-intermediate-representation/src" && tar cf - .) | (cd "$M/src" && tar xf -)
(cd "$WS/packages/elm-cem/facts/src" && tar cf - .) | (cd "$M/src" && tar xf -)
# elm.json: type=package, exposed-modules = union of the three split surfaces (270)
cd "$M" && time "$WS/node_modules/.bin/elm" make --docs docs.json --output=/dev/null
wc -c docs.json
```

Output:

```
exposed: 270
elm files:      409
Success! Compiled 409 modules.
elm make --docs docs.json --output=/dev/null  0.49s user 0.51s system 148% cpu 0.674 total
--- exit=0
 1450795 docs.json
modules in docs.json: 270
```

Three cold repeats (`rm -rf elm-stuff docs.json` between each), under `/usr/bin/time -l`:

```
0.89 real  0.49 user  0.51 sys  1506541568  maximum resident set size   bytes=1450795
0.62 real  0.46 user  0.47 sys  1506263040  maximum resident set size   bytes=1450795
0.68 real  0.48 user  0.43 sys  1507147776  maximum resident set size   bytes=1450795
```

RSS control (`elm --version` does no work at all):

```
0.39 real  0.00 user  0.12 sys  1384742912  maximum resident set size
```

## Appendix C — spike hygiene

```
$ git diff --stat HEAD -- packages
$ echo $?
0
$ node tools/check-single-cem-facts.mjs
check-single-cem-facts: OK — exactly one Cem.Facts in every compiled graph.
$ echo $?
0
```

Nothing under `packages/` was written. All experiments ran in `/tmp/m3e-spike/` and per-run
`mkdtemp` directories. No commit, branch, push, or tag was created. No repo outside this
workspace was modified.
