# Support

Thanks for using elm-m3e. This page is about **getting help**; for reporting
defects or requesting coverage, use the [issue tracker](https://github.com/jackhp95/elm-m3e/issues).

## Where to start

- **Docs & examples:** the [README](README.md) and the docs site (component pages
  carry live, verified examples across every API surface).
- **Concepts:** `docs/adr/` for the architecture decisions and the layer model.

## Asking a question vs. filing a bug

- **A usage question** ("how do I…", "which surface should I use") — search
  [existing issues](https://github.com/jackhp95/elm-m3e/issues) first; if unanswered,
  open an issue and it'll be triaged as a question.
- **A bug** (something behaves incorrectly) or **missing coverage** (a `@m3e/web`
  component/attribute/slot not exposed, or exposed wrong) — use the
  [issue templates](https://github.com/jackhp95/elm-m3e/issues/new/choose).
- **A security issue** — do **not** open a public issue; see [SECURITY.md](SECURITY.md).

## Note on generated code

Most of `M3e.*` is generated from the `@m3e/web` Custom Elements Manifest plus
`config/`. If something looks off in `src/M3e/*`, the fix usually
belongs in the generator (`elm-cem/`) or the config — mention that in your issue.
