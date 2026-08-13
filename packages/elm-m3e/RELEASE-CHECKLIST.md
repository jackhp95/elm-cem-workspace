# Release checklist — jackhp95/elm-m3e (OWNER-ONLY)

The governance and docs blockers from the release-readiness audit
([#136](https://github.com/jackhp95/elm-m3e/issues/136)) are handled in the repo
(CHANGELOG, CONTRIBUTING, SECURITY, LICENSE reconciled to BSD-3-Clause, README
fixed + verified, consumer-facing root README).

The steps below are **irreversible or require owner privileges** and are
deliberately **not** done by automation. Run them yourself, in order.

## 0. Structure — RESOLVED

Elm publishes a package from the **repo root** — the package `elm.json` must be at
the root of `github.com/jackhp95/elm-m3e`. This is now the case: the package was
flattened to the root (`elm.json` + `src/`), the generator/docs/tests live in
subdirectories (`elm-cem/`, `docs/`, `docs/kit/`, `tests/`), and `.gitattributes`
`export-ignore`s everything but the package. No split, no second repo.

Verify (green today):

```bash
elm make src/M3e.elm --output=/dev/null   # from the repo root
```

## 1. Confirm license (already reconciled — verify only)

Root `LICENSE` (BSD-3-Clause), root `elm.json` (`"license": "BSD-3-Clause"`), and
root `package.json` all agree on **BSD-3-Clause**.

## 2. Tag and push `1.0.0`

On the release commit, from the repo root:

```bash
git tag 1.0.0
git push origin 1.0.0
```

Elm requires an exact `MAJOR.MINOR.PATCH` tag matching `elm.json`'s `version`.

> **Not yet.** The library is deliberately prerelease ("breaking changes are
> embraced"). Only tag when you're ready to freeze the `1.0.0` API — Elm versions
> are permanent.

## 3. Publish to the Elm registry

```bash
elm publish        # run from the repo root
```

`elm publish` validates the license, that every exposed value is documented, and
that the tag exists. Publishing is **permanent** — a version cannot be unpublished
or overwritten.

## 4. Repo is already public

`jackhp95/elm-m3e` (and the `elm-cem` generator and `elm-review-cem` rules) are
already public, with description + topics + homepage set. Nothing to do here.

## 5. Enable repo security & protection (optional hardening)

```bash
# Secret scanning + push protection
gh api -X PATCH repos/jackhp95/elm-m3e \
  -f security_and_analysis[secret_scanning][status]=enabled \
  -f security_and_analysis[secret_scanning_push_protection][status]=enabled

# Private vulnerability reporting (backs SECURITY.md)
gh api -X PUT repos/jackhp95/elm-m3e/private-vulnerability-reporting

# Branch protection on main (require the CI checks + PRs)
gh api -X PUT repos/jackhp95/elm-m3e/branches/main/protection \
  --input protection.json   # required_status_checks (library/docs/harness), required PR reviews
```

> **Secret-scan false positives are already allowlisted.** GitHub secret scanning
> and any `gitleaks` step both flag Material Design token / component references
> (`M3e.Token.large`, `M3e.Heading.emphasized`) in the doc-examples and
> `config/examples.*.json` corpus as `generic-api-key` hits. The repo's
> [`.gitleaks.toml`](.gitleaks.toml) allowlist suppresses these (findings → 0);
> a CI `gitleaks detect` step picks it up automatically. There are no real secrets
> in the tree.

## 6. After publishing

- Point the repo homepage at the package.elm-lang.org page (currently the docs site).
