# elm-m3e Family — First-Publish Runbook

**Date:** 2026-08-12
**Audience:** Jack (this is a **DO-IT-YOURSELF** runbook — every outward-facing command below is
staged for Jack to run; the agent that wrote this published nothing, pushed no tags, created no
repos, modified no repo).
**Status of the code:** all family repos landed + pushed to `origin`; **zero tags anywhere; nothing
has ever been on the Elm registry.** Every publish below is a **first publish at `1.0.0`**.
**Companions:** `2026-08-12-publish-readiness.md`, `2026-08-12-split-fix-design.md`,
`2026-08-12-publish-readiness-fixes-worklog.md`. Memory: `[[elm-m3e-api-ergonomics-overnight]]`.

> ⛔ **HARD RULE for this doc:** commands in fenced blocks are marked `# DO NOT RUN — Jack executes`.
> They are copy-paste targets, not instructions the writing agent may run. No repo was created,
> tagged, pushed, or published to produce this runbook.

---

## 0. Verified current state (read-only checks, 2026-08-12)

| Repo (local dir) | Pushed HEAD | Own git repo? | GitHub repo | Tags | Toolchain |
|---|---|---|---|---|---|
| `elm-html-intermediate-representation/` | `843562f` | yes, own `origin` | `jackhp95/elm-html-intermediate-representation` ✅ | 0 | `elm publish` |
| `elm-cem/` (codegen **tool**, not a package) | `ad5d523` | yes, own `origin` | `jackhp95/elm-cem` ✅ | 0 | n/a (npm tool) |
| `elm-cem/facts/` → pkg `jackhp95/elm-cem-facts` | *(subtree of elm-cem)* | **NO — nested** | `jackhp95/elm-cem-facts` ✅ (separate mirror repo) | 0 | `elm publish` |
| `elm-review-cem/` | `a899186` | yes, own `origin` | `jackhp95/elm-review-cem` ✅ | 0 | `elm publish` |
| `elm-m3e/` (root = monolith) | `bfdaabc6` | yes, own `origin` | `jackhp95/elm-m3e` ✅ | 0 | `elm publish` |
| `elm-m3e/dist-packages/elm-m3e-core/` | *(generated subtree)* | **NO — nested** | `jackhp95/elm-m3e-core` ❌ **MISSING** | — | `elm publish` |
| `elm-m3e/dist-packages/elm-m3e-components/` | *(generated subtree)* | **NO — nested** | `jackhp95/elm-m3e-components` ❌ **MISSING** | — | `elm publish` |
| `elm-m3e/dist-packages/elm-m3e-review-facts/` | *(generated subtree)* | **NO — nested** | `jackhp95/elm-m3e-review-facts` ❌ **MISSING** | — | `elm publish` |
| `elm-m3e/elm-m3e-icons/` (canonical) + `dist-packages/elm-m3e-icons/` | *(nested subtree)* | **NO — nested** | `jackhp95/elm-m3e-icons` ❌ **MISSING** | — | `elm publish` |
| `elm-typed-html/` | `89c13d0` | yes, own `origin` | `jackhp95/elm-typed-html` ✅ | 0 | `elm publish` |

Toolchain confirmed: **Elm `0.19.1`**, plain `type: package` packages → **`elm publish`** (NOT
`lamdera publish`; none of these declare lamdera). All package `elm.json` versions read `1.0.0`.

### Verified dependency graph (from real `elm.json` files — NOT assumed)

```
elm/* (registry)          elm/core (registry)        jfmengels/elm-review + stil4m/elm-syntax
   │                          │                                   │
   ▼                          ▼                                   ▼
IR (elm-html-intermediate-  elm-cem-facts                 elm-review-cem      ← ALL THREE are
representation)  1.0.0        1.0.0                           1.0.0             dependency-order
   │  \                        │  \                          (VENDORS Cem.Facts   LEAVES
   │   \                       │   \                          as source — declares  (no jackhp95
   │    \                      │    \                         NO jackhp95 dep)       deps)
   ▼     ▼                     ▼     ▼
elm-m3e-core   elm-m3e-icons   elm-m3e-review-facts   elm-typed-html (IR + facts)
   │            (IR only)                                elm-m3e ROOT/monolith (IR + facts)
   ▼
elm-m3e-components (IR + elm-m3e-core)   ← the only TIER-2 package
```

> **CORRECTION to a common assumption:** `elm-review-cem` does **not** depend on
> `jackhp95/elm-cem-facts`. Its `elm.json` dependencies are only `elm/core`,
> `jfmengels/elm-review`, `stil4m/elm-syntax`. It **vendors** `Cem.Facts` as a source file
> (kept byte-identical by the `facts-sync` gate). So it publishes independently — it is a
> dependency leaf, not a dependent of facts.

> **`jackhp95/elm-cem` is the codegen tool (an npm/Node CLI), NOT an Elm-registry package.**
> Do not `elm publish` it. Only its nested `facts/` subtree (`jackhp95/elm-cem-facts`) is a
> registry package.

---

## 1. The decision: Arch-R monolith vs 4-package family

Two **mutually non-colliding** shapes exist in the tree today. The old name-collision
(root and 3P-core both claiming `jackhp95/elm-m3e`) is **resolved** — the monolith owns
`jackhp95/elm-m3e`; the family uses `jackhp95/elm-m3e-{core,components,review-facts,icons}`.
Because the names are disjoint, **you can publish either shape, or both.**

| | **Arch-R monolith** | **4-package family** |
|---|---|---|
| Packages | `jackhp95/elm-m3e` (138 exposed) + `jackhp95/elm-m3e-icons` (independent) | `elm-m3e-core` (9) → `elm-m3e-components` (262, builder folded in) + `elm-m3e-review-facts` (1) + `elm-m3e-icons` (1) |
| First-publish friction | **Lowest** — root repo already exists & is pushed; only `elm-m3e-icons` needs a new repo | **Higher** — 4 new mirror repos, populated from generated subtrees, published in DAG order |
| Consumer install | one `elm install jackhp95/elm-m3e` pulls the whole surface | pick pieces: `elm-m3e-core` for foundation, `-components` for the UI surface, `-icons`/`-review-facts` à la carte |
| Consumer upgrade blast radius | any change bumps the one big package | changes localize to the affected package; smaller diffs for consumers |
| Maintenance cost | one repo, one release | 4 repos to tag/publish every release; must publish in DAG order each time |
| Registry-faithful `elm make --docs` | **green** (root + icons), per 2026-08-12 gate | **green** for all 4, per `verify:split` on the 2026-08-12 gate |

**Recommendation (non-binding — this is Jack's call):**

1. **Publish Arch-R monolith first.** It is the lowest-friction first publish: `jackhp95/elm-m3e`
   already exists and is pushed, and the root tree is the CI-verified path. Only one new repo
   (`elm-m3e-icons`) is required. This gets the library usable on the registry fastest.
2. **Publish the 4-package family later, if/when the modular story earns its keep.** It is fully
   valid and registry-check-green today, but it costs 4 repos + a DAG-ordered release each time.
   Nothing is lost by deferring — the names don't collide with the monolith.
3. **`elm-m3e-icons` is shared by both shapes** (IR-only, 1 module `M3e.Icon`, same package name).
   Publish it once; it serves monolith consumers and family consumers alike.

**Publishing both = a superset**, not a conflict: `jackhp95/elm-m3e` (monolith) and
`jackhp95/elm-m3e-components` (family) are independent registry names. A consumer picks one shape
or the other; they are not meant to be installed together (they expose overlapping module names
like `M3e.Button`). Document that clearly in each README if you publish both.

---

## 2. How Elm publishing works (prerequisites)

`elm publish` (Elm 0.19.1) succeeds only when **all** of these hold for a package:

1. **The package lives at the git repo root** whose remote `origin` is
   `github.com/<elm.json name>.git`. `elm publish` reads the `name` field and expects the current
   directory's git `origin` to match. *(This is why nested subtrees can't be published in place.)*
2. **`elm.json` `version` matches a git tag pushed to that GitHub repo.** First publish must be
   **exactly `1.0.0`** (all our packages are already `1.0.0` — verified).
3. **`elm make --docs docs.json` is clean** — the package compiles registry-faithfully and every
   exposed module has doc comments. Docs must be under the 700 KB registry cap (all are).
4. **Every dependency is already on the registry.** `elm publish` resolves deps from the registry,
   not from local sibling dirs — hence the **strict topological order** below. Publish a package
   only after all its `jackhp95/*` deps are live.
5. `LICENSE` present (all trees have `BSD-3-Clause` LICENSE + README — verified).

**The two-run ritual.** `elm publish` is run twice:
- **Run 1** validates docs/deps and, if no matching tag exists, prints the exact
  `git tag`/`git push` step and stops.
- Jack tags + pushes.
- **Run 2** sees the tag on GitHub and completes registration.

### The nested-package problem (elm-cem-facts + the 4 split packages)

Five packages do **not** have their own top-level git repo — their source is a **subtree** of a
parent repo:

| Package | Source subtree (in this workspace) | Parent repo it's nested inside |
|---|---|---|
| `jackhp95/elm-cem-facts` | `elm-cem/facts/` | `jackhp95/elm-cem` |
| `jackhp95/elm-m3e-core` | `elm-m3e/dist-packages/elm-m3e-core/` | `jackhp95/elm-m3e` |
| `jackhp95/elm-m3e-components` | `elm-m3e/dist-packages/elm-m3e-components/` | `jackhp95/elm-m3e` |
| `jackhp95/elm-m3e-review-facts` | `elm-m3e/dist-packages/elm-m3e-review-facts/` | `jackhp95/elm-m3e` |
| `jackhp95/elm-m3e-icons` | `elm-m3e/elm-m3e-icons/` *(canonical)* — mirrored to `dist-packages/elm-m3e-icons/` by `split.js` | `jackhp95/elm-m3e` |

Because prerequisite #1 requires the package at a **repo root with a matching remote**, each of
these needs its **own** GitHub repo whose root content **==** the subtree. **There is no
automated mirror-push script** — the old `mirror-release.mjs` is dead (thermo-nuclear B15), and
`split.js` only *generates* the trees into `dist-packages/`, it does not push them. So the mirror
step is **manual**: populate a standalone clone from the subtree, commit, push, tag, publish.

The `jackhp95/elm-cem-facts` GitHub repo **already exists** and has a root `elm.json` (last pushed
`2026-07-26`), but it is a **separate repo from the local `elm-cem/facts/` subtree** and may be
**stale** — the local subtree carries the `1.0.0` + api-consolidation work done since. **Re-sync
it from the current `elm-cem/facts/` before tagging** (§3, Tier-0 block).

The generated split trees under `dist-packages/` are produced by `npm run split` in `elm-m3e`
(`elm-cem split --packages=packages.json --src=src --out=dist-packages`) and verified by
`npm run verify:split`. **Regenerate them fresh** (`cd elm-m3e && npm run split`) right before
populating the mirror repos, so the published tree matches current `src/`.

---

## 3. Ordered publish sequences (DO NOT RUN — Jack executes)

Reusable helper for a **nested** package (populate a standalone repo from a subtree, then publish):

```sh
# DO NOT RUN — Jack executes.  Publish a NESTED package from its subtree.
# args: <github-name> <path-to-subtree> <version>
publish_nested () {
  name="$1"; tree="$2"; ver="$3"
  gh repo create "jackhp95/$name" --public --description "elm-m3e family package" 2>/dev/null || true
  work="/tmp/publish-$name"
  rm -rf "$work"
  git clone "https://github.com/jackhp95/$name.git" "$work" 2>/dev/null || { mkdir -p "$work"; (cd "$work" && git init && git remote add origin "https://github.com/jackhp95/$name.git"); }
  rsync -a --delete --exclude '.git' --exclude 'elm-stuff' --exclude 'node_modules' "$tree"/ "$work"/
  cd "$work"
  git add -A && git commit -m "release $ver" && git branch -M main && git push -u origin main
  elm publish                                   # run 1: validates, prints the tag step
  git tag -a "$ver" -m "$ver" && git push origin "$ver"
  elm publish                                   # run 2: completes registration
  cd -
}
```

Reusable pattern for an **own-repo** package (already pushed; publish from its dir):

```sh
# DO NOT RUN — Jack executes.  Publish an OWN-REPO package (version already 1.0.0, main pushed).
publish_owndir () {
  dir="$1"; ver="$2"
  cd "$dir"
  elm publish                                   # run 1
  git tag -a "$ver" -m "$ver" && git push origin "$ver"
  elm publish                                   # run 2
  cd -
}
```

> `elm` below = the workspace Elm 0.19.1. If `elm` isn't on `PATH`, use
> `elm-m3e/node_modules/.bin/elm` (verified present, `0.19.1`).

### Shape A — Arch-R monolith (recommended first publish)

```sh
# DO NOT RUN — Jack executes.  Topological order; each package's deps must be live first.

# ── TIER 0 — dependency leaves (no jackhp95 deps) ────────────────────────────
# 1. jackhp95/elm-cem-facts  (nested in elm-cem repo; RE-SYNC the existing mirror repo first)
publish_nested elm-cem-facts /Users/jack/Documents/code/elm-cem/facts 1.0.0

# 2. jackhp95/elm-html-intermediate-representation  (own repo; already 1.0.0 + pushed)
publish_owndir /Users/jack/Documents/code/elm-html-intermediate-representation 1.0.0

# 3. jackhp95/elm-review-cem  (own repo; INDEPENDENT — vendors Cem.Facts, no jackhp95 dep)
publish_owndir /Users/jack/Documents/code/elm-review-cem 1.0.0

# ── TIER 1 — depend on Tier 0 ────────────────────────────────────────────────
# 4. jackhp95/elm-m3e  (ROOT monolith, 138 exp; deps: IR + elm-cem-facts — both now live)
publish_owndir /Users/jack/Documents/code/elm-m3e 1.0.0

# 5. jackhp95/elm-m3e-icons  (nested; dep: IR only; independent of the monolith)
#    Canonical tree is elm-m3e/elm-m3e-icons/ (generator-native). Confirm it equals
#    dist-packages/elm-m3e-icons/ (diff) before publishing.
publish_nested elm-m3e-icons /Users/jack/Documents/code/elm-m3e/elm-m3e-icons 1.0.0

# (Optional) jackhp95/elm-typed-html  (own repo; deps: IR + elm-cem-facts — both live after Tier 0)
#   Only if you want it on the registry. Run its own `elm make --docs` first (unverified this session).
# publish_owndir /Users/jack/Documents/code/elm-typed-html 1.0.0
```

### Shape B — 4-package family

Shares Tier 0 (elm-cem-facts, IR, elm-review-cem) with Shape A — **publish those once**. If you
already ran Shape A Tier 0, skip straight to the family tiers.

```sh
# DO NOT RUN — Jack executes.

# ── TIER 0 — shared leaves (skip any already published in Shape A) ───────────
publish_nested elm-cem-facts /Users/jack/Documents/code/elm-cem/facts 1.0.0
publish_owndir /Users/jack/Documents/code/elm-html-intermediate-representation 1.0.0
publish_owndir /Users/jack/Documents/code/elm-review-cem 1.0.0

# ── Regenerate the split trees so the mirrors match current src/ ─────────────
cd /Users/jack/Documents/code/elm-m3e && npm run split && npm run verify:split && cd -

# ── TIER 1 — family foundation + independents (all deps in Tier 0) ───────────
# elm-m3e-core (9 exp; dep: IR)  — MUST precede elm-m3e-components
publish_nested elm-m3e-core         /Users/jack/Documents/code/elm-m3e/dist-packages/elm-m3e-core         1.0.0
# elm-m3e-review-facts (1 exp; dep: elm-cem-facts)
publish_nested elm-m3e-review-facts /Users/jack/Documents/code/elm-m3e/dist-packages/elm-m3e-review-facts 1.0.0
# elm-m3e-icons (1 exp; dep: IR)  — same package as Shape A #5; publish once
publish_nested elm-m3e-icons        /Users/jack/Documents/code/elm-m3e/elm-m3e-icons                       1.0.0

# ── TIER 2 — depends on elm-m3e-core (must be live) ──────────────────────────
# elm-m3e-components (262 exp; deps: IR + elm-m3e-core; builder API M3e.Build.* folded in)
publish_nested elm-m3e-components   /Users/jack/Documents/code/elm-m3e/dist-packages/elm-m3e-components    1.0.0
```

---

## 4. Per-package readiness table

| Package | GitHub repo? | Version | LICENSE/README | `elm make --docs` | Deps published-first | Remaining blocker before publish |
|---|---|---|---|---|---|---|
| `elm-html-intermediate-representation` | ✅ own | `1.0.0` ✅ | ✅ / ✅ | green (gate 2026-08-12) | none (elm/* only) | none — ready |
| `elm-cem-facts` | ✅ mirror (may be **stale**) | `1.0.0` ✅ | ✅ / ✅ | green | none (elm/core only) | **re-sync mirror repo** from `elm-cem/facts/`; nested-publish |
| `elm-review-cem` | ✅ own | `1.0.0` ✅ | ✅ / ✅ | green (311 tests) | none (external only; vendors facts) | none — ready |
| `elm-m3e` (monolith, 138) | ✅ own | `1.0.0` ✅ | ✅ / ✅ | green (registry-check) | IR, elm-cem-facts | publish after Tier 0 |
| `elm-m3e-icons` (1) | ❌ **missing** | `1.0.0` ✅ | ✅ / ✅ | green | IR | **create repo**; nested-publish; diff canonical vs dist tree |
| `elm-m3e-core` (9) | ❌ **missing** | `1.0.0` ✅ | ✅ / ✅ | green (`verify:split`) | IR | **create repo**; nested-publish (family only) |
| `elm-m3e-review-facts` (1) | ❌ **missing** | `1.0.0` ✅ | ✅ / ✅ | green (`verify:split`) | elm-cem-facts | **create repo**; nested-publish (family only) |
| `elm-m3e-components` (262) | ❌ **missing** | `1.0.0` ✅ | ✅ / ✅ | green (`verify:split`) | IR, **elm-m3e-core** | **create repo**; publish LAST (Tier 2); family only |
| `elm-typed-html` (25) | ✅ own | `1.0.0` ✅ | ✅ / ? | **unverified this session** | IR, elm-cem-facts | optional; run its own `elm make --docs` first; confirm README |

> "green (gate 2026-08-12)" = docs compiled clean in the `npm run gate` / `verify:split` evidence
> captured on the p1-split-fix work now merged into the pushed mains (`bfdaabc6` etc.). **This
> session did not re-run the full registry-check** (it needs staged unpublished deps and is slow);
> the green claims carry from that gate, not from a fresh run here. Re-run `npm run gate` (elm-m3e)
> and `elm make --docs` (each own-repo package) immediately before publishing to confirm.

---

## 5. Open blockers & decisions (honest status — what is NOT yet ready)

**Decisions only Jack can make:**

1. **Which shape(s) to publish** — Arch-R monolith, the 4-package family, or both. Recommendation:
   monolith first (lowest friction), family later if the modular story earns it. Not guessed.
2. **Publish `elm-typed-html`?** It is mechanically `1.0.0` with its own repo, but its docs were
   **not** compiled this session. Decide in/out; if in, run its `elm make --docs` first.

**Blockers that gate a real publish (must be cleared, in order):**

3. **4 mirror repos do not exist** — `jackhp95/elm-m3e-core`, `-components`, `-review-facts`,
   `-icons`. Required for Shape B; `-icons` is also required for Shape A. `gh repo create` steps
   are in the §3 helper.
4. **`elm-cem-facts` mirror is likely stale.** The GitHub repo exists (root `elm.json`, pushed
   `2026-07-26`) but is a **separate repo** from the local `elm-cem/facts/` subtree, which has since
   moved to `1.0.0` + api-consolidation. **Re-sync before tagging**, or the registry will publish an
   out-of-date `Cem.Facts`. (Diff the mirror against `elm-cem/facts/` first.)
5. **No automated mirror mechanism.** `mirror-release.mjs` is dead (thermo-nuclear B15); `split.js`
   generates but does not push. Every nested publish is the manual `publish_nested` flow. If you
   publish the family repeatedly, consider reviving a mirror-push script (follow-up, not a blocker).
6. **Split trees must be regenerated before family publish.** `dist-packages/*` is generated output;
   run `cd elm-m3e && npm run split && npm run verify:split` so the mirrors match current `src/`.
   (Shape A does not need this — the monolith publishes from `elm-m3e/` root.)
7. **`elm-m3e-icons` has two trees** — canonical `elm-m3e/elm-m3e-icons/` (generator-native,
   drift-gated) and `dist-packages/elm-m3e-icons/` (split emission). Both are 1-module / IR-only.
   `diff -r` them and publish the canonical one; they should be identical.
8. **Irreversibility.** A registry name + version is **permanent**. Once `jackhp95/elm-m3e@1.0.0`
   (monolith) is published you cannot repurpose that name for a family core, and vice-versa — but
   the names are already disjoint, so this only means: **get the shape decision right before Tier 1.**
   Tier 0 (IR, facts, review-cem) is shape-independent and safe to publish under either choice.

**Not blockers, but confirm at publish time:**

- Re-run `npm run gate` (elm-m3e) and `elm make --docs` (each own-repo package) from a clean
  checkout right before publishing — the green status here is inherited from the 2026-08-12 gate,
  not re-verified this session.
- `elm publish` requires a GitHub auth token in the environment the first time; ensure `gh auth`
  / `~/.elm` credentials are set.

---

## Appendix — commands used to verify this runbook (read-only)

- `git -C <repo> log/remote/tag/branch/status` for every repo → HEADs, remotes, **0 tags** everywhere.
- `elm.json` reads → names, versions (`1.0.0`), exposed-module counts, dependency maps.
- `gh repo view` / `gh api repos/<name>/tags` → repo existence + tag counts (all 0).
- `gh api repos/jackhp95/elm-cem-facts/contents` → confirmed the mirror has a root `elm.json`,
  pushed `2026-07-26`.
- `ls` of `elm-m3e/dist-packages/*`, `packages.json`, `src/M3e/Forge/Internal.elm` → split trees +
  forge rename present on the pushed main.
- `node_modules/.bin/elm --version` → `0.19.1`; grep for `lamdera` in the package `elm.json`s →
  none (→ `elm publish`).

**Not re-run this session** (slow / needs staged unpublished deps): full `npm run gate`,
`npm run verify:split`, per-package `elm make --docs`. Their green status is carried from the
2026-08-12 gate evidence in the companion docs and must be re-confirmed before publishing.
