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

Please report suspected vulnerabilities **privately** — do not open a public issue.

- Use GitHub's **private vulnerability reporting** (the repo's *Security* tab →
  *Report a vulnerability*), or
- email the maintainer at the address in the repo profile.

You'll get an acknowledgement within a few days. Because elm-cem is a build-time code
generator (it runs on a developer's machine / CI, not in production), the relevant
threat surface is mostly untrusted CEM/config input and the npm dependency chain —
please include the manifest/config that triggers the issue where applicable.
