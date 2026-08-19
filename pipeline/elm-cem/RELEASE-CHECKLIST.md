# Release checklist — elm-cem

The **operational release flow** (the ordered, gated steps: confirm-green → downstream
zero-diff regen gate → version + CHANGELOG rename → `npm pack` audit → tag → OIDC
trusted-publish → post-publish) lives in the [`releasing-elm-cem`](skills/releasing-elm-cem/)
skill. Do not duplicate it here — **run that skill to publish.**

This file records the **owner-only decisions and one-time setup** that sit outside the
mechanical flow.

## Decisions to make before the first release

1. **First-release version.** `package.json` is currently `0.3.1`. The first *public*
   release should be `1.0.0` (or a consciously documented pre-1.0 policy). The owner
   picks the bump; the skill's version step (`npm version <level>`) applies it and creates
   the `v*` tag. Recommendation: **`1.0.0`**.

2. **License year/holder.** `LICENSE` is BSD-3-Clause. Confirm the year/holder and that
   `package.json`'s `license` field matches (`BSD-3-Clause`).

## Prerequisites (verified — no action unless regressed)

These were release blockers in the original audit and are now resolved; re-verify only if
something changed:

- **Consumer install works.** There is no `prepare`/`postinstall` lifecycle hook — the
  toolchain install is the opt-in `setup` script (`elm-tooling install`), run only by
  contributors. `npm install elm-cem` no longer breaks for a consumer.
- **Packed contents are clean.** The `files` allowlist ships `codegen/`, `bin/`,
  `cem-configs/`, `data/`, `LICENSE`, `README.md`, `CHANGELOG.md` (and excludes
  `codegen/elm-stuff`). The `native-manifest-gen/` dev harness was REMOVED in the Phase-0 deep clean (see docs/facts-bundle/m6-deep-clean.md); nothing to exclude from the pack any more.
  local path and large scraped data — is **not** shipped. The skill's `npm pack --dry-run`
  step re-checks this before every publish.
- **README passes the no-dig test.** Install, an end-to-end example, the CEM input story,
  the `--output` deletion footgun, the config primitives, recipes, and both elm-codegen
  version lines (CLI `elm-codegen ^0.6.3`; generator app `mdgriffith/elm-codegen 6.0.3`)
  are all documented.
- **CI exists.** `.github/workflows/ci.yml` runs the test + format + neutrality gates on
  push/PR; `.github/workflows/npm-release.yml` is the tag-triggered OIDC publish workflow.

## One-time setup (before / at first publish)

- **Trusted publishing.** Configure the repo + `npm-release.yml` as a Trusted Publisher for
  the `elm-cem` package on npmjs.com (OIDC — no stored `NPM_TOKEN`).
- **Flip the repo public** once the secret scan is clean:
  `gh repo edit jackhp95/elm-cem --visibility public --accept-visibility-change-consequences`;
  set description + topics.
- **Hardening.** Enable secret scanning + push protection, private vulnerability reporting,
  and branch protection on `main` (require the CI check).
