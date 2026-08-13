# Retarget feedback (round 3) — user gate session

Source: user re-shared verbally (retarget action discarded the notes). Intrinsic
width/height are LOW priority (per-usage custom, don't chase). CONTENT mismatch
is the priority. Systemic > one-off patches.

- **badge**: too big — find a size variant to shrink to match Figma. (size)
- **dialog**: mostly correct; size wrong — add a max-size matching Figma dialog box. (size)
- **expandable-list-item**: mostly correct; width wrong — match Figma width. (width)
- **rich-tooltip**: content differs; actions differ — should be TWO actions, LEFT-aligned. Screenshot just the tooltip element (not the anchor). (content + harness screenshot)
- **search-view**: mostly correct; many ways to render search items — pick the render matching the Figma example (see matraic.github.io/m3e/#/components/search.html). (content)
- **snackbar**: looks great; content wrong — match Figma content. (content)
- **split-button**: good; using OUTLINED icon, should be FILLED. (icon fill)
- **tooltip**: good; screenshot just the tooltip element (not anchor); content "Tooltip" → "supporting text". (content + harness screenshot)

## Systemic directive (verbatim intent)
The recurring failures — wrong icon (literal), filled-vs-outlined, wrong content —
are SYSTEM-LEVEL, not one-off patches. Dig into the harness: understand what the
Figma primitives are, how to SELECT the right one, and fit it to the shape we need.
The point of Code Connect is EXTRACTING content consistently, not hard-coding it —
"we are the translation layer." Width/height faithfulness is NOT required.
