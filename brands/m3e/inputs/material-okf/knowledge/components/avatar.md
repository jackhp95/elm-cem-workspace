---
type: concept
title: Avatar
description: A small graphic representing a person or entity, as an image, initials, or icon.
resource: https://m3.material.io/styles/icons/overview
tags: [components, avatar, identity, image, initials]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/styles/icons/overview
    retrieved: 2026-07-11
    note: Iconography conventions an avatar draws on.
---

An avatar is a small graphic that represents a person or entity — a profile photo, initials,
or a fallback icon. It gives identity a compact, recognizable visual anchor in lists, headers,
and comments.

## Anatomy

A small shaped container (often circular) holding an image, a set of initials, or an icon,
with a graceful fallback when no image is available.

## Usage

Use an avatar to identify who or what a row, message, or account belongs to. Provide a
sensible fallback (initials or a generic icon) when no image exists rather than an empty
shape. Keep sizing consistent within a context so avatars line up.

## Do / Don't

**Do**

- Use an avatar to identify who or what a row, message, or account belongs to.
- Provide a graceful fallback (initials or a generic icon) when no image exists.
- Keep avatar sizing and shape consistent within a context so they line up.
- Give an identity-bearing avatar a text alternative naming the person or entity.

**Don't**

- Don't leave an empty shape when an image is missing — show a fallback.
- Don't rely on the avatar's color as the only way to tell entities apart.
  See [color-only state signaling](/anti-patterns/color-only-state-signaling).
- Don't stretch or crop images so faces are distorted or cut off.
- Don't announce a purely decorative avatar that sits beside already-labeled text.

## Accessibility

An avatar that conveys identity carries a text alternative naming the person or entity it
represents; a purely decorative avatar beside already-labeled text is not separately
announced. Do not rely on the avatar's color as the only way to tell entities apart. See
[accessibility](/foundations/accessibility).

For the technology-specific API, see
[/implementations/m3e-web/components/avatar](/implementations/m3e-web/components/avatar).
