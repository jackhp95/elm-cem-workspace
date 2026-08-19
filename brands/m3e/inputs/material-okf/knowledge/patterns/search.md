---
type: pattern
title: Search
description: Presenting search entry, suggestions, and results — from a search bar to a full-screen search view.
resource: https://m3.material.io/components/search/overview
tags: [pattern, search, suggestions, results, adaptive]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://m3.material.io/components/search/overview
    retrieved: 2026-07-11
    note: Search bar and search view anatomy.
  - url: https://m3.material.io/components/search/guidelines
    retrieved: 2026-07-11
    note: When to surface search and how suggestions behave.
---

Search lets a user find content by query rather than by navigating to it. The pattern
spans three moments — the resting entry point, the active input-and-suggestions state,
and the results — and the surface changes as the user moves through them.

## Entry point

A resting **search bar** signals that search is available and invites a tap. Place it
where the user expects to find things (often near the top of a browsing surface). If
search is secondary, a search icon that expands into a bar keeps the resting UI quiet.

## Active state and suggestions

Focusing search opens a **search view**: the query field plus a list of suggestions that
update as the user types — recent queries, completions, or matching items. Suggestions
shorten the path to a result and should be scannable and clearly ranked. On compact
width the search view typically takes the full screen; on wider widths it can float over
the surface.

## Results

Present results in the layout that fits their content — often a [feed](/patterns/feed) or
a [list-detail](/patterns/list-detail) view. Show a clear empty state when nothing matches,
and tell the user what was searched so a zero-result screen is not a dead end.

## Guidance

Keep the query visible while results show, so the user can refine without retyping.
Distinguish suggestions from executed results. Make the whole flow keyboard-operable and
announce result counts and empty states to assistive technology; see
[accessibility](/foundations/accessibility) and [content design](/foundations/content-design).
