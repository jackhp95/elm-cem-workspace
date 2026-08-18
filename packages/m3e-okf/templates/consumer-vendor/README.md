# Consumer vendoring templates — committed-copy M3e with anti-drift guard

Template scripts an **external Elm consumer** copies in to vendor the unpublished
`elm-m3e` / `elm-cem` family as a **committed copy**, pinned to a source commit,
with a two-layer anti-drift guard. Designed in the rollout plan
`planning/2026-08-18-elm-m3e-consumer-rollout.md` §5.1b / §5.2; decision **D1**
(committed-copy, not symlink — CI can't reliably follow symlinks).

These are **templates**: they live here as the source of truth, and are copied
verbatim into each consumer's `scripts/`. They are also self-testing against the
workspace's own packages (see "Self-test" below).

## Files

| File | Role |
|---|---|
| `revendor-m3e.mjs` | The **sole writer** of a consumer's `vendor/`. Extracts canonical trees at a pinned commit and writes the trees + manifest + provenance. |
| `check-vendor.mjs` | **Layer 1** anti-drift gate (the gate of record). Deterministic, language-agnostic, CI-portable. Fails on any drift from canonical@pin. Imports the copy logic from `revendor-m3e.mjs` — never reimplements it. |

Both files must be copied **together** (check-vendor imports revendor).

The companion **Layer 2** guard is the elm-review rule
`NoHandEditedGeneratedM3e` (in `jackhp95/elm-review-cem`); add it to the
consumer's `review/src/ReviewConfig.elm`. It is the ergonomic, in-editor
early-warning complement — see "Two layers" below.

## What gets vendored

By default, three canonical trees (the minimum to compile `M3e.*`):

| Vendored at (committed) | ← copied from `elm-cem-workspace` |
|---|---|
| `vendor/elm-m3e/` | `packages/elm-m3e/src` |
| `vendor/elm-html-ir/` | `packages/elm-html-intermediate-representation/src` |
| `vendor/cem-facts/` | `packages/elm-cem/facts/src` |

A consumer that doesn't wire facts into `review/` can drop `cem-facts` with
`--trees elm-m3e,elm-html-ir`.

## Adoption (per consumer)

1. Copy `revendor-m3e.mjs` + `check-vendor.mjs` into the consumer's `scripts/`.
2. Add npm scripts:
   ```jsonc
   {
     "scripts": {
       "revendor:m3e": "node scripts/revendor-m3e.mjs",
       "check:vendor": "node scripts/check-vendor.mjs"
     }
   }
   ```
3. First vendor, pinned to a **reviewed** source commit:
   ```sh
   npm run revendor:m3e -- --commit <40-hex-sha>
   ```
   Add `vendor/**` to the consumer's `elm.json` `source-directories`, review the
   diff, and commit the whole `vendor/` tree (including `vendor/m3e-manifest.json`
   and `vendor/VENDORED_FROM.json`).
4. Wire `check:vendor` into the consumer's pre-push / CI gate.
5. Add `NoHandEditedGeneratedM3e.rule` to `review/src/ReviewConfig.elm`.

**Upgrading** = re-run `revendor:m3e -- --commit <new-sha>`, review the `vendor/`
diff, commit. That is the *only* sanctioned way `vendor/` changes.

## Source resolution (CI-portable, no monorepo leak)

`revendor-m3e.mjs` resolves canonical source in this order:

1. A co-located `elm-cem-workspace` checkout — `--workspace <path>`,
   `$ELM_CEM_WORKSPACE`, or `~/Documents/code/elm-cem-workspace`. The pinned
   commit is fetched if not already present.
2. Fallback — a shallow fetch of the pinned commit from the published mirror
   `https://github.com/jackhp95/elm-cem-workspace.git` (override with
   `$ELM_CEM_WORKSPACE_GIT_URL`), cached under the system temp dir.

Trees are read with `git archive <commit>:<srcPath>`, so the copy reflects
**exactly** the pinned commit regardless of the working tree's state. CI needs
neither a co-located workspace nor symlink support — just git + network for the
mirror fetch (or a co-located workspace).

## Two layers, and why

- **Layer 1 — `check-vendor.mjs` (gate of record).** Re-extracts canonical@pin
  and byte-compares (sha256) the committed `vendor/` against it, in two
  directions: (A) committed files vs the committed manifest (honesty), and
  (B) committed manifest vs a fresh extraction at the pin (currency). Any
  difference fails, distinguishing hand-edit / added / deleted. Deterministic,
  language-agnostic (also covers non-Elm vendored bits), runs in CI.
- **Layer 2 — `NoHandEditedGeneratedM3e` (elm-review).** Reads the manifest via
  `withExtraFilesProjectVisitor` and flags a vendored file that is added /
  missing / length-changed **in-editor, on save**, before pre-push. It compares
  content **length**, not bytes — parity-safe across the JS/Elm boundary with no
  sha256 in Elm (elm-review runs on Node, so `String.length` equals the
  manifest's `len` by construction). Byte-exactness (a same-length edit) is
  Layer 1's job. Layer 2 also generalizes to the sibling brand libs.

Neither alone suffices; together they cover prevention-by-detection at both the
toolchain and the CI boundary.

## Manifest format — `vendor/m3e-manifest.json`

Written by `revendor-m3e.mjs`; read by both guard layers. **Never hand-edit.**

```jsonc
{
  "schema": "m3e-vendor-manifest/1",
  "algo": "sha256",
  "source": {
    "repo": "jackhp95/elm-cem-workspace",
    "commit": "<40-hex-sha>",       // the pinned source commit — a REVIEWED bump
    "vendoredVia": "local" | "mirror",
    "vendoredAt": "<ISO-8601>",
    "trees": [ { "name", "srcPath", "dest" }, ... ]
  },
  "files": {
    // key = consumer-root-relative path (so the elm-review rule, which globs
    // vendor/** relative to elm.json, compares by direct lookup).
    "vendor/elm-m3e/M3e/Attributes.elm": { "sha256": "<hex>", "len": 1234 },
    ...
  }
}
```

`vendor/VENDORED_FROM.json` is the human-readable pin record (repo + commit +
trees), the structured successor to the old `VENDORED_FROM.txt`.

## Self-test

The templates self-test against the workspace's own packages (no consumer needed):

```sh
FIX=$(mktemp -d)
node revendor-m3e.mjs --consumer "$FIX" --workspace /path/to/elm-cem-workspace --commit "$(git -C /path/to/elm-cem-workspace rev-parse HEAD)"
node check-vendor.mjs --consumer "$FIX" --workspace /path/to/elm-cem-workspace   # PASS
echo "// tamper" >> "$FIX"/vendor/cem-facts/Cem/Facts.elm
node check-vendor.mjs --consumer "$FIX" --workspace /path/to/elm-cem-workspace   # FAIL (hand-edit)
```

## CLI reference — `revendor-m3e.mjs`

```
node revendor-m3e.mjs --commit <sha> [options]
  --commit <sha>       source commit to pin to (defaults to workspace HEAD with a warning)
  --consumer <path>    consumer repo root (default: cwd) — where vendor/ lives
  --workspace <path>   co-located elm-cem-workspace checkout (else env/default/mirror)
  --trees a,b,c        subset of {elm-m3e,elm-html-ir,cem-facts} (default: all three)
```

## CLI reference — `check-vendor.mjs`

```
node check-vendor.mjs [options]
  --consumer <path>    consumer repo root (default: cwd)
  --workspace <path>   co-located elm-cem-workspace checkout (else env/default/mirror)
  --check-stale        additionally report (non-fatally) if canonical HEAD is ahead of the pin
                       (no-op in mirror mode — only fires with a co-located workspace)
```

## Caveats

- **Line endings.** The manifest records byte-derived `sha256` and UTF-8-string
  `len`, both computed from LF-normalized `git archive` output. A consumer on a
  Windows checkout with `core.autocrlf=true` would see CRLF in its committed
  `vendor/` and get false drift. Force LF on the vendored tree with a
  `.gitattributes` entry (`vendor/** text eol=lf`) if any consumer is on Windows.
  (The workspace and current consumers are unix/macOS, so this is pre-emptive.)
- **Non-GitHub mirror.** The CI mirror-fetch fetches a specific commit SHA, which
  relies on the host allowing reachable-SHA1-in-want (GitHub does). A non-GitHub
  `$ELM_CEM_WORKSPACE_GIT_URL` may need a branch fetch instead.
