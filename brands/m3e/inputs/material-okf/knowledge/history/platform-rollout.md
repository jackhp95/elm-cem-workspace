---
type: history
title: Platform rollout
description: How Material 3 Expressive reached Android, Wear OS, and Jetpack Compose first — and where the web trailed.
resource: https://developer.android.com/jetpack/androidx/releases/compose-material3-adaptive
tags: [history, m3e, rollout, android, wear-os, compose, web]
timestamp: 2026-07-11T00:00:00Z
diataxis: explanation
sources:
  - url: https://blog.google/products-and-platforms/platforms/android/material-3-expressive-android-wearos-launch/
    retrieved: 2026-07-11
    note: Android 16 + Wear OS 6 as the first-party launch platforms.
  - url: https://android-developers.googleblog.com/2025/08/introducing-material-3-expressive-for-wear-os.html
    retrieved: 2026-07-11
    note: M3E for Wear OS via Wear Compose Material 3 libraries.
---

Material 3 Expressive rolled out first where Google controls the whole stack — Android and
its Jetpack toolkits — and reached other platforms unevenly.

## Android and Compose first

M3E arrived with **Android 16** and, for watches, **Wear OS 6**. The developer path was
**Jetpack Compose**: the M3 Expressive components shipped through Compose Material 3 (and
Wear Compose Material 3 / ProtoLayout Material 3 for tiles), with early hands-on access on
Pixel devices. Because Google builds and ships these libraries directly, Compose got the
new motion, shape, and typography systems as first-class, maintained APIs.

## The web is a different story

The web has no single Google-shipped, actively maintained M3 (let alone M3E) component
library in the same way Compose does. Google's official web components package,
`@material/web`, entered **maintenance mode in 2024** — before M3E existed — which left the
web without a first-party, actively developed home for the newest Material system. That gap
is the reason a cluster of **community custom-element implementations** emerged to carry
M3/M3E to the web. See [web implementation gap](/history/web-implementation-gap).

## Why this bundle separates neutral from implementation

The uneven rollout is exactly why this knowledge bundle keeps
**technology-neutral** design guidance (this `knowledge/` tree) separate from any single
**implementation** (under `/implementations/m3e-web`). The design system is one thing; the
toolkit that renders it on a given platform is another, and on the web that toolkit is
community-maintained rather than first-party.
