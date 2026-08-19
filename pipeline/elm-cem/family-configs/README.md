# family-configs

One JSON file per brand *family* — the "eject" brand registry (`bin/eject.js`)
and the consumer-only family-package extension (`bin/family-deps.js`'s
`FAMILY_PACKAGES`) are both DERIVED from these files, never hardcoded per-brand
in JS (finding 2.3 of the 2026-08-17 thermonuclear review: `eject.js`'s
`BRANDS` had exactly one entry despite being advertised as a generic registry,
and `family-deps.js:69-96` hardcoded the same M3E package list a second time).

`bin/family-deps.js` reads every `*.json` file here at load time (sorted by
filename, so multi-brand ordering is deterministic) and builds:

- the eject `BRANDS` registry (`key`/`namespace`/`package`/`repo`/`webPackage`)
- the `FAMILY_PACKAGES` array's brand-specific tail — the generic
  `FAMILY_DEPS` entries (IR + facts, elm-cem's own substrate, shared by every
  brand) always come first; each brand file's `consumerPackages` are appended
  after, in file order.

Adding a second brand (e.g. Carbon) is a data change: drop a
`carbon.json` here with the same shape as `m3e.json` below — no JS edit
required, and `elm-cem eject --help` picks up the new brand automatically.

## Shape

```json
{
  "key": "m3e",
  "namespace": "M3e",
  "package": "jackhp95/elm-m3e",
  "repo": "jackhp95/elm-m3e",
  "webPackage": "@m3e/web",
  "consumerPackages": [
    {
      "package": "jackhp95/elm-typed-html",
      "range": "1.0.0 <= v < 2.0.0",
      "moduleRoots": ["TypedHtml"]
    }
  ]
}
```

- `key` — the `eject <brand>` CLI argument.
- `namespace` — the brand's top-level Elm module namespace (e.g. `M3e`).
- `package` / `repo` — the published primitives package eject removes, and the
  GitHub repo `--write` pulls `src/` from.
- `webPackage` — the runtime npm package eject can pin a version for.
- `consumerPackages` — family packages a VENDORED (ejected) consumer tree may
  need, beyond the generic IR/facts pair — detected by import scan, never
  assumed. Each entry:
  - `package` / `range` — same shape as `FAMILY_DEPS`.
  - `moduleRoots` — module namespace roots that require this package (matches
    the root itself or `Root.*`).
  - `extraModules` (optional) — bare module names outside any root (e.g.
    elm-review-cem's rule modules that aren't nested under `Cem.*`).

This directory is distinct from `../cem-configs/` (CEM-analyzer inputs for
future bindings, not yet read by anything) — these files ARE read, at every
`family-deps.js` module load.
