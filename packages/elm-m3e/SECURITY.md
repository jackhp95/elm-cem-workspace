# Security Policy

## Supported versions

This project is pre-`1.0.0` release. Until the first tagged release, security fixes
are applied to `main` only. After `1.0.0`, the latest published `1.x` release is
supported.

| Version | Supported |
| --- | --- |
| `main` (unreleased) | ✅ |
| `< 1.0.0` | ❌ (none published) |

## Reporting a vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, report privately via GitHub's
[private vulnerability reporting](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability):
open the repository's **Security** tab and choose **Report a vulnerability** to
open a draft security advisory.

If you cannot use that channel, contact the maintainer directly at
**claude@jackhpeterson.com**.

Please include:

- a description of the vulnerability and its impact,
- steps to reproduce (a minimal Elm snippet or repo is ideal),
- affected version(s) or commit,
- any suggested remediation.

## What to expect

- We aim to acknowledge a report within **5 business days**.
- We will confirm the issue, keep you updated on remediation progress, and
  coordinate a disclosure timeline with you.
- With your consent, we will credit you in the advisory and `CHANGELOG.md`.

## Scope note

`elm-m3e` generates the **Elm** side of the `<m3e-*>` custom elements; the runtime
behavior of the elements themselves lives in
[`@m3e/web`](https://github.com/matraic/m3e). Vulnerabilities in the web-component
runtime should be reported to that project; report issues in the generated Elm
bindings, the generator, or the `elm-review` layer here.
