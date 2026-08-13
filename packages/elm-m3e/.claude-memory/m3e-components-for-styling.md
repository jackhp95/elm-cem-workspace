---
name: m3e-components-for-styling
description: "Jack's rule — Tailwind for LAYOUT only; ALWAYS use m3e components for STYLING (Eddie + m3e frontends)"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: b46daacd-8f68-4e6c-9c1e-55d9c32bc876
---

In Eddie (`~/dev/personal-memory-system/eddie`) and Jack's m3e-based frontends generally: use **Tailwind ONLY for layout** (flex/grid/gap/spacing/positioning). **ALL styling** — surface, color, elevation, shape, typography, emphasis — **MUST come from m3e components** (`M3e.Card`, `M3e.Chip`/`M3e.SuggestionChip`, `M3e.Divider`, `M3e.ListItem`, `M3e.Icon`, …). Do NOT hand-roll Material styling with Tailwind M3 tokens (`bg-surface-container-high`, `rounded-lg`, `text-on-surface`, tonal pills, etc.) — that's the anti-pattern Jack called out 2026-07-21.

**Why:** m3e is the single source of Material-styling truth; hand-rolled Tailwind styling drifts from the design system and duplicates what the components already encode.

**How to apply:** any surface/container/emphasis/chip/card → an m3e component; only the layout *around* them → Tailwind. Markdown.elm renders `Html`, so embed m3e via `toHtml (M3e.X.view attrs children)` (the `toHtml : Markup.Element … -> Html` bridge in Main.elm) and `Seam.html`/`Seam.text` to drop raw text/Html into m3e children.

**Known gaps (m3e has no component):** inline `code` and links/anchors (m3e ships `TextHighlight`/`TextOverflow` but no `Code` or `Link`). Flag these to Jack for direction rather than hand-rolling Tailwind styling.

**Retrofit DONE (`a174cf0`, on main 2026-07-21):** frontmatter card → `M3e.Card.view` (outlined) + `M3e.SuggestionChip` for sensitivity; citations → followable `<a href="#/source/<ULID>">` (the `sum://<ULID>` ULID is a viewable source); wiki/citation/footnote links → Material link guidance = **primary color + underline** (`text-primary underline`, where `text-primary` maps to the m3e `--md-sys-color-primary` token — the sanctioned exception since m3e has no Link component). **Inline `code` kept hand-rolled** (Jack ruled it a fine exception — no m3e code component). The inline anchor-viewer in `Main.elm` (AnchorView/ResolveAnchor) is now BYPASSED by citation navigation — retire it separately if desired. See [[eddie-ui-enhancements]].
