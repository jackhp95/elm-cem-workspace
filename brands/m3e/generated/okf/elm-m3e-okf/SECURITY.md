# Security Policy

This repository is a build pipeline and a static knowledge base (Markdown + JSON); it
ships no runtime code to end users. The realistic security surface is the Node build
scripts and their dependencies. Reports are still welcome.

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Report privately via one of:

- GitHub's [private vulnerability reporting](https://docs.github.com/code-security/security-advisories/guidance-on-reporting-and-writing-information-about-vulnerabilities/privately-reporting-a-security-vulnerability)
  (Settings → Security → enable), **or**
- email **claude@jackhpeterson.com**.

Include: the affected file/script, a description, and a reproduction if you have one.
Expect an acknowledgement within a few business days.

## Supported versions

There are no releases; the repository tracks a pinned `@m3e/web` SHA in
`data/sources.json`. Only the current `main` branch is supported.

| Version | Supported |
|---------|-----------|
| `main`  | ✅ |
| any older commit | ❌ |

## Disclosure

We'll coordinate a fix and a disclosure timeline with you before any public
announcement, and credit you in the advisory unless you prefer otherwise.
