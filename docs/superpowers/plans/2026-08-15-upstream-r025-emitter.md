# Plan — upstreaming the R-025 emitter change to `jackhp95/elm-cem` (PLAN ONLY, DO NOT EXECUTE)

**Status:** PLAN ONLY. Pushing to `jackhp95/elm-cem` `origin/main` is an **irreversible** push to a
shared upstream and changes generated-code shape for every brand. **Nothing here is to be run.**
This document scopes the patch, the blast radius, and the Face-A revert — for the human to decide.
**The change:** R-025 option 1 (D-044/D-045) — `M3e.Build.<X>` routes its phantom-type aliases
(`Builder`, `AttrCaps`, `SlotCaps`, `Is`, `Content`, slot aliases, …) through the **exposed**
`M3e.Component.<X>` surface instead of the unexposed `M3e.Internal.Types.<X>`, so `Internal.Types.*`
can stay private and `M3e.Build.*` can be split into its own published package.
**Lives only in-workspace:** `packages/elm-cem/codegen/Generate/Phantom/Emit.elm`, committed at
`5bc2ae4` (the change) + `fbbac5d` (genericity + golden re-bless). Not in upstream `jackhp95/elm-cem`.

---

## 1. Why this is workspace-only today

The workspace `packages/elm-cem` is a **vendored copy** (not a git submodule — no `.gitmodules`).
Its generator forked ahead of pinned upstream main when R-025 landed. Because upstream is a
read-only remote from here and the change was never pushed, **Face A (`ab-elm-cem`) could no longer
compare workspace-generator output against a remote SHA** — so D-046 re-based Face A onto a
**committed bundle** of the workspace generator itself (`tools/snapshots/elm-cem-generator.bundle`,
sha `e5f2b9a8`). That is a deliberate, temporary state: Face A now catches *future accidental*
generator drift but no longer proves "workspace == upstream." Upstreaming this change is what lets
Face A return to a remote-SHA reference (§4).

## 2. The exact patch to upstream (small and clean)

The upstream-relevant delta is **1 emitter file + its golden fixtures** — the ~262 other files in
`5bc2ae4..fbbac5d` are downstream elm-m3e regeneration (`packages/elm-m3e/src/**` + `packages.json`)
and do **not** go upstream (each brand regenerates its own tree from the new generator).

| Upstream-relevant | Path | Size |
|---|---|---|
| The emitter change | `codegen/Generate/Phantom/Emit.elm` | +33 / −3 |
| Re-blessed golden fixtures | `tests/phantom/**/expected/**` across synthetic brands **Hz, Mini, Br, Or** | ~38 files, Component modules gain `Builder`/`AttrCaps`/`SlotCaps` aliases; Build modules reroute imports |

The two emitter edits (from D-044, verified in D-045):
1. **`compModule`** (Component emitter): add a `singularSlots` binding and emit three new alias
   decls — `Builder`, `AttrCaps`, and `SlotCaps` (with the same `{}`-vs-`internalRef` conditional
   `compBuildModule` uses, since only the 51 comps with singular slots have an
   `Internal.Types.<X>.SlotCaps`) — and add those three names to `compModule`'s `exposeGroups` type
   group (drives both `exposing` and `@docs`).
2. **`compBuildModule`** (Build emitter): redefine `internalRef n = "Component." ++ n` so all Build
   aliases route through the now-exposed Component surface, and drop the
   `import <lib>.Internal.Types.<comp>` line.

The `fbbac5d` genericity fixup (the Builder-alias docstring uses the **per-brand** lib name, not a
hardcoded `M3e`) is load-bearing for upstreaming: it is what makes the change correct for **every**
brand, not just m3e. The golden fixtures spanning Hz/Mini/Br/Or are the proof of that genericity and
are part of the upstream patch.

**Pre-step — compute the true delta against real upstream.** The pinned-upstream SHA referenced in
the ledger (`ad5d523`) and the read-only sibling snapshot (`/Users/jhp/code/jackhp95/elm-cem` @
`e0e4f1c`, the pre-migration baseline) may both be behind the *current* `origin/main`. Before
authoring the upstream PR, **fetch the live `jackhp95/elm-cem` `origin/main`** and diff
`codegen/Generate/Phantom/Emit.elm` + `tests/phantom/` against it: the workspace copy also carries
non-R-025 commits (`de86b8d` facts-bundle emitter, `bdfa3b0`/`eaacb3d` re-integration) that must
**not** be swept into this push. Isolate exactly the `5bc2ae4` + `fbbac5d` emitter/golden hunks
(cherry-pick or a hand-applied patch), not a wholesale sync of the vendored tree.

## 3. Blast radius

- **Additive to the public API, but a real output change for every brand.** The change *adds* three
  exposed type aliases per component to every `<Brand>.Component.<X>` module (130 for m3e) and
  *reroutes* `<Brand>.Build.<X>` imports. Any brand repo that pins the new generator and regenerates
  will see its committed `src/**` drift and its `docs.json` grow (more exposed aliases = more doc
  entries). Every such brand must **regenerate + re-bless its goldens** — the same work `fbbac5d`
  did for m3e in-workspace.
- **Only Build-separate consumers strictly *need* it; everyone *gets* it.** Upstream main keeps
  Build merged in components, where the `Internal.Types` import is intra-package and legal, so
  upstream does not need this change to build. Pushing it changes generated output for all brands
  regardless of whether they split Build out. That is the core trade to surface: a generator change
  motivated by one consumer's package boundary alters everyone's emitted shape.
- **elm-typed-html is a genuine no-op** (verified D-045): its `TypedHtml.Component.*` are not emitted
  via `compModule` and it has no `Build`/`Internal.Types` modules, so its `check:drift` stays
  byte-identical without regen. Native/home-shaped brands are unaffected; only compModule/Build-split
  brands drift.
- **elm-cem's own test suite** must go green upstream with the re-blessed goldens (the Hz/Mini/Br/Or
  fixtures). This is the acceptance gate for the upstream PR itself.
- **Downstream coordination.** Any other published brand built on elm-cem would need a coordinated
  regenerate-and-republish. Enumerate the brands pinning elm-cem before pushing; m3e is the known one
  and is already migrated in-workspace.

## 4. How Face A reverts to a remote SHA afterward (undoing D-046)

Once the change is on `jackhp95/elm-cem` `origin/main` at a new SHA `<UP>`:

1. Edit `tools/snapshot-refs.json` → `elm-cem` entry back to `{ "repo": "…/elm-cem.git", "sha":
   "<UP>" }`, **dropping the `bundle` field** (and the `_comment_elm_cem` note about the fork).
2. `tools/fetch-snapshots.mjs` already has both branches; with no `bundle` field it clones the remote
   at `<UP>` — no code change needed there, just the ref.
3. Delete `tools/snapshots/elm-cem-generator.bundle` (no longer referenced) and drop its mention from
   the neutrality/copy-fidelity allowlists if present.
4. Re-run `node tools/gate-all.mjs`: Face A (`ab-elm-cem`) now regenerates from the remote `<UP>` and
   must be **byte-identical** to the workspace generator output. If it is, the "workspace ==
   upstream" invariant D-046 had to abandon is **restored**, and Face A once again forces a conscious
   re-baseline against a *remote* SHA on any future generator change (D-041 discipline).
5. Update the ledger: a new decision reverting D-046, noting Face A is back on a remote reference at
   `<UP>`.

**Ordering constraint:** step 1–4 must happen **after** `<UP>` exists and is byte-compatible. If the
push and the workspace generator ever diverge again (a later workspace-only tweak), Face A will
correctly go red — which is the point.

## 5. Irreversibility & risks

- **The push cannot be cleanly undone.** A follow-up revert commit is possible, but the history
  persists and any downstream that pulled `<UP>` already has the new output shape. Treat it as
  one-way.
- **Risk — sweeping unrelated vendored drift upstream.** Mitigated by the §2 pre-step: isolate the
  `5bc2ae4`+`fbbac5d` emitter/golden hunks against *live* `origin/main`, do not push the whole
  vendored `packages/elm-cem` tree (it carries workspace-only integration commits).
- **Risk — a brand regenerates and its `docs.json` crosses the 768,000 B cap** because of the added
  aliases. For m3e the split packages are measured under cap (D-045), but any *other* brand near the
  cap could be pushed over. Enumerate + measure before pushing.
- **Risk — genericity regression.** The per-brand-lib-name fix (`fbbac5d`) must be included; without
  it the Builder docstring hardcodes `M3e` for every brand. The Hz/Mini/Br/Or goldens are the guard.

## 6. Sequenced steps (for review; DO NOT EXECUTE)

1. Fetch live `jackhp95/elm-cem` `origin/main`; compute the true `Emit.elm` + `tests/phantom/` delta
   (§2 pre-step).
2. Enumerate every brand pinning elm-cem; note which are compModule/Build-shaped (will drift) vs
   native (no-op).
3. Open a PR on `jackhp95/elm-cem` with the isolated emitter change + re-blessed goldens; upstream
   test suite green.
4. **Human authorizes the push/merge** — irreversible boundary.
5. For each affected downstream brand: regenerate, re-bless goldens, verify `docs.json` under cap,
   republish as needed (coordinate with the publish runbook).
6. Re-baseline Face A to remote `<UP>` (§4); revert D-046; gate-all green; ledger updated.

## 7. Decision to put to the human (surface, do not decide)

- **Do we upstream this at all, or keep it workspace-only indefinitely?** Keeping it workspace-only
  is a valid stable state — Face A on the bundle (D-046) already protects against drift, and the
  in-workspace m3e split works. Upstreaming buys: (a) other brands can adopt Build-separate, (b) Face
  A returns to a remote reference. It costs: an irreversible push and a coordinated multi-brand
  regenerate. The change is *ready* (generic, golden-proven); the question is whether the upstream
  coordination cost is worth it now or deferred until a second brand wants Build-separate.
