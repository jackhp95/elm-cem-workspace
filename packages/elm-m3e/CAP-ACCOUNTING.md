# CAP-ACCOUNTING — Task 2b: 3-package docs.json size audit

**Measured:** 2026-08-10, `plan/api-consolidation` worktree
**Cap:** 700,000 B (700 KB) per `elm publish`
**Method:** Exposed-modules-only accounting; `elm make --docs` via the
`measure-docs.cjs` script (vendors all 3 package sources + IR + facts into one
temp dir, writes per-package `elm.json` with only that package's exposed
modules, compiles, produces `docs.json`).

For the builder package, direct `elm make --docs` confirmed the doc-comment
blocker; measurement is by source-size proxy.

---

## Package measurements

### 1. `elm-m3e` (thin core) — 10 exposed modules

| Metric | Value |
|--------|-------|
| Exposed modules | 10 |
| docs.json size | 253,645 B (247.7 KB) |
| % of 700 KB cap | **36.2%** |
| Status | ✅ under cap |

Command output (from `measure-docs.cjs`):
```
modules: 10 exposed, 10 in docs.json
docs.json: 253,645 B (36.2% of cap) ✓ under
```

**Thin core is comfortably small.** Even with headroom for the barrel's 122
constructor re-exports (which still reference per-component modules — it hasn't
been trimmed to generic-only yet), the package is well under cap. Once the
barrel is trimmed in task 2a, this will shrink further.

---

### 2. `elm-m3e-components` (per-component view API) — 131 exposed modules

| Metric | Value |
|--------|-------|
| Exposed modules | 131 |
| docs.json size | 1,114,823 B (1,088.7 KB) |
| % of 700 KB cap | **159.3%** |
| Status | ❌ **OVER CAP** |

Command output (from `measure-docs.cjs`):
```
modules: 131 exposed, 131 in docs.json
docs.json: 1,114,823 B (159.3% of cap) ⚠ OVER
```

**The components package already exceeds the 700 KB cap by 59.3%.** This is the
core finding of task 2b. The plan's §3.1 flagged this risk ("still may need
topological headroom management as upstream grows"); it is not just a future
risk — it is *already over*.

---

### 3. `elm-m3e-builder` (per-component builder modules) — 131 exposed modules

#### 3a. Doc-comment blocker (confirmed)

`elm make --docs` **FAILS** on the builder package. Every per-component builder
module (`M3e/<Component>/Build.elm`) exposes `type alias` re-exports (slot
aliases like `Content`, `BadgeSlot`, `LeadingSlot`, etc.) **without `{-| -}`
doc comments**.

- **First failing module:** `src/M3e/NavMenuItem/Build.elm`
- **First failing alias:** `BadgeSlot` (on module exposing line 3:
  `Builder, AttrCaps, SlotCaps, Is, Content, BadgeSlot, IconSlot, ...`)
- **Scope:** 70+ modules fail with "NO DOCS" errors (all ~130 builder modules
  affected; errors truncated at 100 matches).

Exact error block:
```
-- NO DOCS --------------------------------------- src/M3e/NavMenuItem/Build.elm
The `BadgeSlot` definition does not have a documentation comment.
3|     , Builder, AttrCaps, SlotCaps, Is, Content, BadgeSlot, IconSlot, ...
                                                    ^^^^^^^^^
```

**This is a release-blocker.** The builder package cannot be published until the
generator (`codegen/Generate/Phantom/Emit.elm`) emits `{-| -}` doc comments on
every `type alias` in the builder module's exposing line. This affects all
~130 builder modules × several alias names each (~5–12 per module depending on
slot count).

#### 3b. Source-size proxy measurement

Since `elm make --docs` cannot produce a `docs.json`, measured by source file
size:

| Metric | Value |
|--------|-------|
| Exposed modules | 131 |
| Total `.elm` bytes (`wc -c`) | **794,556 B (776 KB)** |
| Status | ⚠ PROXY (undercounts true docs.json) |

**Note:** The source-size proxy under-counts the true `docs.json` because:
- `docs.json` includes structural metadata, type signatures, and dependency
  graph info for every module — not just source text.
- The aliases are thin one-liners (`type alias Content = ...`), so the source
  is denser than equivalent `docs.json` output.
- However, the builder's thin-alias modules are simple enough that the
  `docs.json` would be *proportionally small* — the true value is likely
  comparable to the source size (unlike complex modules where docs.json is
  much larger).

**Likely true docs.json estimate:** ~600–900 KB (cannot be precise until the
doc-comment blocker is fixed). Even at the high end, this is close to or over
the 700 KB cap — the builder package may also need headroom attention.

---

### 4. Escape-hatch check

`M3e.Build.Internal` is **NOT listed** in `elm-m3e-builder/elm.json`
`exposed-modules`. Confirmed by grep: 0 matches.

✅ Escape hatch functions as designed — the heavy internal types live in a
non-exposed module, invisible to `docs.json` and the cap.

---

## Task 2b judgment: sub-split recommendation

### Does `elm-m3e-components` need topological headroom sub-splitting?

**YES — urgently, not just "in the near term."**

The components package is already at **159.3% of the 700 KB cap**. This is not
a future-growth concern; it is a current release blocker. The 3-package split
(§3.1) successfully shrunk the thin core and isolated the builder, but the
components package inherited the bulk of the original single package's
docs.json.

**Trigger threshold:** Already exceeded. Any additional upstream component
growth (new `@m3e/web` releases) will push it further over.

### Recommended approach

Split `elm-m3e-components` into 2–3 sub-packages on topological/density lines:

1. **`elm-m3e-common`** (or `-atoms`): high-usage shared components (Button,
   Icon, IconButton, Card, Checkbox, Switch, Radio, Chip, List, Menu, Tab,
   Slider, TextField-equivalents…). Probably ~50–60 modules, ~40% cap.

2. **`elm-m3e-surfaces`** (or `-composites`): layout/composite components
   (AppBar, BottomSheet, Card, Dialog, DrawerContainer, NavBar, NavRail,
   Snackbar, Toolbar, Tabs…). ~30–40 modules, ~35–45% cap.

   — or split by feature area (navigation, input, feedback, layout, data).

3. The **`elm-m3e-components`** package itself becomes a convenience barrel
   that re-exports from the sub-packages (or just the remaining medium-density
   set).

### Alternative: wait-and-split

If the immediate path is to fix the builder doc-comment blocker and ship the
current 3-package split with the components package > cap, that is viable as a
**short-term workaround** (internal-only release, not `elm publish` to the
package registry). The Elm package registry enforces the 700 KB cap at publish
time, so publishing `elm-m3e-components` would be blocked. An internal
pre-release used via `elm.json` `"source-directories"` or `"dependency"` path
references would work but defeats the purpose of packaging.

---

## Summary table

| Package | Exposed | docs.json B | % of cap | Status |
|---------|---------|-------------|----------|--------|
| `elm-m3e` (thin core) | 10 | 253,645 | 36.2% | ✅ OK |
| `elm-m3e-components` | 131 | 1,114,823 | **159.3%** | ❌ OVER |
| `elm-m3e-builder` | 131 | ~776 KB proxy | ~110% est. | ⚠ blocked + proxy |

## Blocker summary

1. **PUBLISH-BLOCKER:** Builder package doc-comment defect — all builder
   modules lack `{-| -}` on exposed `type alias` re-exports. Generator fix
   needed in `codegen/Generate/Phantom/Emit.elm` before `elm publish`.

2. **CAP-BLOCKER:** `elm-m3e-components` at 159.3% of 700 KB cap. Requires
   topological sub-split before `elm publish`.

3. **ESCAPE-HATCH:** Confirmed working — `M3e.Build.Internal` absent from
   exposed-modules.