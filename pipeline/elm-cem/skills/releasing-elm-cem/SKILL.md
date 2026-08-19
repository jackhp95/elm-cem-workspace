---
name: releasing-elm-cem
description: >-
  Cuts a release of the elm-cem npm package. Use when maintaining elm-cem and the user
  wants to release, publish, tag, or ship a new version, bump the version, or run the
  release checklist. Covers the version bump + CHANGELOG rename, the `npm pack
  --dry-run` contents audit, the trusted-publishing (OIDC) tag-triggered flow, the
  two-public-surfaces semver policy (the npm CLI surface AND the generated-code
  contract), and the mandatory downstream zero-diff regen gate that must pass BEFORE
  tagging. Maintainer-only and side-effecting: this skill is not model-invoked; the
  human runs it deliberately.
disable-model-invocation: true
---

# Releasing elm-cem

Owner-only and irreversible past the publish step. The canonical ordered steps live in
[`RELEASE-CHECKLIST.md`](../../RELEASE-CHECKLIST.md); this skill is the operational
companion — the *why* and the gates. Read both.

## Two public surfaces — decide the bump against BOTH

elm-cem's SemVer covers **two** surfaces; a breaking change to **either** is a major bump:

1. **The npm/CLI surface** — the CLI flags (`--flags-from` / `--output` / `--config-from`)
   and the exposed Elm modules `Cem` and `Generate`. Changing a flag's meaning or a
   record-alias field / signature here is breaking.
2. **The generated-output contract** — the emitted module names, function names, and
   phantom-row field names. Downstream packages compile against these, so a rename or
   type change is breaking **even though it lives in another repo**. This is the one
   that's easy to under-count. The `elm-test-rs` suites under `tests/src/` pin it, so a
   generated-surface change surfaces as a reviewed test diff, not a silent break.

Additive-only (new component/setter/key, nothing renamed/retyped) ⇒ minor. Fixes with no
surface change ⇒ patch.

## The release sequence

### 1. Confirm green + neutrality

```bash
npm test                       # elm-test-rs + compile-gate + exclude-cli
npm run format -- --validate   # elm-format hard gate
bash .github/neutrality-check.sh
```

### 2. Downstream zero-diff regen gate — BEFORE tagging (mandatory)

The single most important gate: regenerate the **downstream generated-atoms consumer**
(the ecosystem's generated-bindings package named in `RELEASE-CHECKLIST.md`) with the
release candidate, and confirm **zero golden drift** — then `elm make` it:

```bash
node bin/elm-cem.js \
  --flags-from=<consumer>/custom-elements.json \
  --config-from=<consumer>/<config>.json \
  --output=<consumer>/src
# in the consumer:
elm make src/<Lib>.elm --output=/dev/null
```

An **unexpected** diff in the regenerated tree is a breaking generated-output change: stop,
reclassify the bump (bump to major and document it), or fix the regression. Do **not** tag
over silent downstream breakage. An expected additive diff is fine — it just confirms the
minor bump.

### 3. Version + CHANGELOG

- Bump `package.json`'s `version` (use `npm version <level>`, which creates the `v*` tag).
- Rename the CHANGELOG's `## Unreleased` section to `## <version> — <date>`, and confirm
  the stability-policy section still describes both surfaces.

### 4. Audit the packed contents

```bash
npm pack --dry-run
```

Verify the tarball includes exactly the `files` allowlist — `codegen/`, `data/`,
`bin/`, `cem-configs/`, `LICENSE`, `README.md`, `CHANGELOG.md` — and **excludes**
`codegen/elm-stuff`. A missing `data/` ships a package without the bundled
hand-curated native-attr table (`data/native-attrs.json`; the CLI warns at generate
time, but catch it here). Confirm `bin` and `engines` are correct.

### 5. Tag → trusted publishing (OIDC) does the publish

Publishing runs through **trusted publishing**, not a stored `NPM_TOKEN`. The
`.github/workflows/npm-release.yml` workflow fires **only** on a pushed `v*` tag (or
manual dispatch) — never on ordinary pushes/PRs. On the tag it re-runs `npm test` + the
neutrality gate, then `npm publish --access public` with OIDC provenance:

```bash
git push origin v<version>     # the tag npm version created; this triggers the workflow
```

Prereq (one-time): the repo + this workflow are configured as a Trusted Publisher for the
`elm-cem` package on npmjs.com. No `--provenance` flag or auth token is needed;
provenance is automatic for public packages on modern npm.

### 6. Post-publish

Flip the repo public (if not already), set description + topics, and enable the hardening
in `RELEASE-CHECKLIST.md` (secret scanning + push protection, private vulnerability
reporting, branch protection requiring CI). Confirm `LICENSE` year/holder and that
`package.json`'s `license` matches (`BSD-3-Clause`).

## Do NOT

- Do **not** tag before the downstream zero-diff regen gate passes.
- Do **not** hand-run `npm publish` locally with a token — the OIDC workflow is the
  publish path (keeps provenance and avoids stored secrets).
- Do **not** rename/retype an existing generated symbol in a minor/patch — that's a major.

---
Validated against elm-cem 1.0.0, 2026-07.
