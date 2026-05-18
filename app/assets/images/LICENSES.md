# Image Licenses & Sources

This file tracks the license and source for every image in `app/assets/images/`.
**Never add an image without recording its source here.**

## Convention

```
- filename.ext — Source: <URL or org> · License: <CC0 / Unsplash / public domain / self-authored> · Author: <name if applicable>
```

## industry/

Real-world industry photography. All images **must** be either Unsplash License,
Pexels License, CC0, or public domain. No stock illustrations, no AI-generated images.
All photos are rendered with a grayscale CSS filter (brand-dna v0.5.0 Airbnb tone).

- (entries added as images are committed)

## charts/

Data visualizations. Two acceptable kinds:

1. **Self-authored SVG** that cites a third-party statistic in its caption
   (e.g., "Source: Gartner 2024 Report on LLM POC outcomes").
2. **Public-domain charts** from government / international organizations
   (EU, OECD, IMF, KOSIS, etc.).

**Never embed copyrighted chart screenshots** from Gartner, IDC, Forrester, etc.
Cite their numbers in self-authored SVGs instead.

- (entries added as charts are committed)

## brand/

XimTier brand assets (logo variants, og-image, favicons).

- (entries added as assets are committed)

---

**Audit policy**: Before every deploy, a CI script should verify that every file
under `app/assets/images/` has a matching entry in this file.
