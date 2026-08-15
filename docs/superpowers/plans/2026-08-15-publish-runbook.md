# Runbook — publishing the elm-m3e 5-package split (PLAN ONLY, DO NOT EXECUTE)

**Status:** PLAN ONLY. Publishing is the irreversible boundary the whole effort has stopped at.
This document is a runbook + a list of open decisions for the human. **Nothing here is to be run**:
no `elm publish`, no `gh repo create`, no `git tag`, no `git push`, no branch. The human decides
versioning/remotes and clears the icons blocker first.
**Primary source:** `elm/compiler@0.19.1` `terminal/src/Publish.hs` and
`elm/package.elm-lang.org` `src/backend/Package/Register.hs`, both read in
[`../spikes/2026-08-13-elm-package-boundary-spike.md`](../spikes/2026-08-13-elm-package-boundary-spike.md) §5/§2.
**Current split:** [`../../packages/elm-m3e/packages.json`](../../packages/elm-m3e/packages.json)
(5 packages; superseded the spike's 3-package shape).

---

## 1. What is being published

Five Elm packages, re-cut in Move 2 (D-045), plus the two substrate packages they depend on that
are **also not yet on the registry**. `elm publish` requires every dependency to already be
resolvable from the registry (`Publish.hs` `verifyBuild`), so this forces a **topological publish
order**:

```
jackhp95/elm-html-intermediate-representation   (substrate — exposes HtmlIr.*)
jackhp95/elm-cem-facts                           (substrate — exposes Cem.Facts)
   ├── jackhp95/elm-m3e-html      (deps: IR)                         docs.json 269,345 B  ✅ under
   ├── jackhp95/elm-m3e-facts     (deps: elm-cem-facts)             docs.json tiny        ✅ under
   ├── jackhp95/elm-m3e-icons     (deps: IR)                         docs.json 1,075,308 B ❌ 140% OVER
   ├── jackhp95/elm-m3e-components(deps: IR, html)                   docs.json 568,132 B  ✅ under
   └── jackhp95/elm-m3e-builder   (deps: IR, html, components)       docs.json 586,177 B  ✅ under
```

Hard registry cap = **768,000 B uncompressed `docs.json`** (`Register.hs`; gzip does not help).
Sizes are manager-measured (D-045). **`elm-m3e-icons` is the one hard publish blocker** (§4).

Note: `elm-typed-html` is a docs-app dependency, **not** a dependency of any of the five m3e
packages, so it is out of this publish scope. The DAG above is the complete set.

## 2. `elm publish` requirements (execution order, from `Publish.hs`)

| # | Requirement | Status for this repo |
|---|---|---|
| 1 | cwd `elm.json` is `type: package`, non-empty `exposed-modules` | ✅ all five (registry-faithful, D-003) |
| 2 | `summary` non-empty, not the placeholder | ✅ set in `packages.json`, emitted by `split.js` |
| 3 | `README.md` at package root, **≥ 300 bytes** | ⚠️ `split.js` emits one — **must verify ≥300 B** (§5, open check O-4) |
| 4 | `LICENSE` at package root (existence only) | ✅ `split.js` emits BSD-3 from `packages.json` `licenseText` |
| 5 | builds; all exposed modules produce docs; **deps already on registry** | ⚠️ forces topological order; substrate pkgs first |
| 6 | `version` is a legal semver step from what's published | ❓ **human decision** — nothing published yet, so first is `1.0.0` (§3, O-1) |
| 7 | `git` on PATH | ✅ |
| 8 | local git tag named **exactly** the version (`1.0.0`, not `v1.0.0`) | ❌ 0 tags in this repo; supplied by the mirror step |
| 9 | public GitHub repo whose `owner/name` == elm.json `name`, tag pushed | ❌ these 5 (and 2 substrate) repos **do not exist yet** (§3, O-2) |
| 10 | working tree identical to the tagged commit | ✅ satisfied inside the fresh mirror checkout |
| 11 | `github.com/<name>/zipball/<version>` downloads and **rebuilds from scratch** | ⚠️ requires `elm.json` at the **zipball root** — forces a mirror repo (§3) |
| 12 | `docs.json` ≤ 768,000 B, README ≤ 512,000 B, elm.json ≤ 128,000 B | ❌ **icons over docs cap** (§4); others ✅ |

**Two facts that shape everything (spike §5.1):**
- `elm publish` **never inspects `origin`.** It resolves GitHub from the *name* in `elm.json`
  (`jackhp95/elm-m3e-html` → `github.com/jackhp95/elm-m3e-html`). The git checks (#8, #10) are
  purely local, but the commit SHA it verifies (#10) comes from GitHub (#9), so the local mirror
  must share history with the named GitHub repo.
- There is **no subdirectory/`--path` flag.** A tag on this monorepo (whose root has no `elm.json`)
  produces a zipball `Details.load` rejects (#11). Publishing **must** go through a per-package
  mirror repo whose *root* is the package.

## 3. The mirror-repo mechanism (forced by #8–#11)

`split.js` already assembles each package's publishable tree (`elm.json` + `src/` + `README.md` +
`LICENSE`) into `dist-packages/<short>/` (gitignored). That is exactly the tree a mirror repo root
needs — so the assembly problem the spike flagged (§5.2: split dirs had no README/LICENSE) is
**solved by tooling now**; `dist-packages/<short>/` is release-ready content, modulo the O-4 README
check.

Per published package (`$PKG` = elm.json `name`, `$DIR` = `dist-packages/<short>`, `$VSN` = version)
the sequence WOULD be (DO NOT RUN — shown for review):

```bash
# one-time: create the public GitHub repo at the coordinate elm.json names
gh repo create "$PKG" --public --description "$(jq -r .summary "$DIR/elm.json")"
# fresh mirror checkout OUTSIDE the monorepo
git clone "git@github.com:$PKG.git" "/tmp/mirror/$PKG"
# copy the assembled, release-ready tree to the mirror ROOT
rsync -a --delete --exclude .git "$DIR/" "/tmp/mirror/$PKG/"
# commit + tag with the EXACT version string (no `v`)
cd "/tmp/mirror/$PKG" && git add -A && git commit -m "release $VSN" && git tag "$VSN"
git push origin HEAD:main --follow-tags
# publish FROM the mirror root, using the workspace-pinned elm
/path/to/elm-cem-workspace/node_modules/.bin/elm publish
```

Publish order (forced by #5): `elm-html-intermediate-representation` → `elm-cem-facts` →
`elm-m3e-html` → `elm-m3e-facts` → `elm-m3e-components` → `elm-m3e-builder`, with
`elm-m3e-icons` inserted after `elm-m3e-html`… **once the icons cap is resolved.** Everything
after a failed package stalls (its dependents can't resolve it).

**A dry run exists by design:** `packages/_probe/elm-probe-pkg/` is scaffolded for a throwaway
`jackhp95/elm-probe-pkg` end-to-end publish to observe #8–#12 against the *real* registry before
touching the real coordinates (spike §7 open-question 2). Recommend doing this first.

## 4. The hard blocker — `elm-m3e-icons` is 140% over the docs cap (R-026)

`M3e.Icon` exposes ~4083 typed Material-Symbols helper functions (a 40,869-line generated module),
one `docs.json` entry each → **1,075,308 B vs the 768,000 B cap.** This is **pre-existing**
(unchanged by the R-025 emitter change; `M3e.Icon` imports only IR) and gate-all does **not** gate
on it, so the tree is green while this stays unpublishable. It is a **product decision for the
human** — options, each trading the typed-icon ergonomics against the cap:

- **(a) Split `M3e.Icon` into N sub-packages** (`elm-m3e-icons-a…`, by name range), each under cap —
  mirrors the components/builder split. Cleanest for the cap; multiplies the icon package count and
  the import a consumer writes. `1,075,308 / 768,000 = 1.4` → **2 packages suffice by arithmetic**,
  but the split must be validated by measuring each half's `docs.json`, not by function count (doc
  entry sizes are non-uniform; cf. spike §4.3).
- **(b) Leaner per-function docs / grouped helpers** — shrink the docstring each of the 4083 entries
  carries, or expose grouped helpers instead of one-per-symbol. Keeps one package; changes the API
  ergonomics and the generator (`gen-icon-module.js`).
- **(c) A different typed-name representation** that doesn't expand 4083 names into 4083 doc
  entries (e.g. one polymorphic constructor + a name type). Biggest API change; ties to D-036 (the
  human's "new Material Symbols name set, typesafe").

This is a generator/config change (generated code is the spec — never hand-edit `M3e/Icon.elm`),
and whichever option is chosen must re-run the split + `elm-cem validate` size measurement to prove
every resulting icons package lands under 768,000 B. **Until this is decided and landed, the icons
package cannot publish and its dependents are unaffected (nothing depends on icons).** The other
four packages could technically publish without it, but see O-1/O-2 before treating that as a plan.

## 5. Open decisions to put to the human (surface, do not decide)

- **O-1 — Versioning.** The human said "nothing is published, no versioning." Every `packages.json`
  entry says `1.0.0`, but that is a placeholder, not a decision. Needs: is the first published
  version `1.0.0` for all five? Are the two substrate packages (`IR`, `elm-cem-facts`) also `1.0.0`
  first-publishes, or do they already have an intended version line? A published version is
  permanent and its semver successors are constrained (#6) — this is a one-way door.
- **O-2 — Remotes/coordinates.** Seven new public GitHub repos would be created at the exact
  `owner/name` coordinates (`jackhp95/elm-m3e-html`, `-facts`, `-icons`, `-components`, `-builder`,
  plus `jackhp95/elm-html-intermediate-representation`, `jackhp95/elm-cem-facts`). Confirm the org
  (`jackhp95`), the names, public visibility, and that none already exist / collide. Creating them
  and pushing tags is irreversible-ish (a published package name cannot be reused for something else).
- **O-3 — Icons cap (R-026).** Which of §4 (a)/(b)/(c). Blocks the icons package; does not block a
  decision to publish the other four first if O-1/O-2 allow a partial release.
- **O-4 — README ≥ 300 B.** `split.js` emits a README with a copy-only banner + summary; verify each
  of the five is ≥ 300 bytes (requirement #3) — the tiny `elm-m3e-facts` summary is the one at risk.
  If short, enrich the README template in `split.js`/`packages.json` (generator change, regenerate).
- **O-5 — Substrate ownership.** `elm-html-intermediate-representation` and `elm-cem-facts` live as
  in-workspace packages here but are their own upstream repos. Decide whether they publish from this
  monorepo's mirror step or from their own source repos, and at what version — they gate everything
  downstream.
- **O-6 — Dry run.** Approve a `jackhp95/elm-probe-pkg` throwaway publish first (the probe package is
  already scaffolded) to observe the real registry's #8–#12 behavior — especially the cap 400 and
  the zipball rebuild — before spending a real coordinate.

## 6. Pre-publish checklist (all must be green before the human authorizes any publish)

- [ ] O-1…O-6 answered by the human.
- [ ] `elm-m3e-icons` under 768,000 B (R-026 resolved + re-measured), OR an explicit decision to
      publish the other four without icons.
- [ ] `pnpm --filter elm-m3e run verify:split` green (all packages compile registry-faithfully).
- [ ] `elm-cem validate` size check green for all five (< 700,000 B soft gate / < 768,000 B hard).
- [ ] Each `dist-packages/<short>/README.md` ≥ 300 B; `LICENSE` present.
- [ ] Substrate packages (`IR`, `elm-cem-facts`) published (or a plan for them) — deps resolve.
- [ ] `elm-probe-pkg` dry run completed and understood.
- [ ] `node tools/gate-all.mjs` GREEN at the commit being released.
- [ ] Human explicit go — this is the irreversible boundary.

## 7. What publishing does NOT require (corrections to common assumptions)

- It does **not** need any monorepo layout change — the mirror step is forced regardless of folder
  depth (spike §5.3); `dist-packages/` already produces the right shape.
- It does **not** inspect `origin` — the workspace having `origin =
  jackhp95/elm-cem-workspace` is irrelevant; each package resolves GitHub from its own `elm.json`
  name (§2).
- It does **not** care about gzip size — the cap is on the uncompressed `docs.json` (§4).
