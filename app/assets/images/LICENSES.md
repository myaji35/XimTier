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

All photos below are served under the **Unsplash License**
(https://unsplash.com/license) — free to use, attribution is appreciated and
recorded here. Photo IDs are the canonical Unsplash identifier.

- manufacturing.jpg — Source: unsplash.com/photos/1565194481104-39d1ee1b8bcc · License: Unsplash · Subject: factory / production line
- hospital.jpg     — Source: unsplash.com/photos/1538108149393-fbbd81895907 · License: Unsplash · Subject: hospital corridor / clinical
- finance.jpg      — Source: unsplash.com/photos/1554224155-6726b3ff858f · License: Unsplash · Subject: trading floor / financial markets
- retail.jpg       — Source: unsplash.com/photos/1481437156560-3205f6a55735 · License: Unsplash · Subject: retail aisle / commerce
- logistics.jpg    — Source: unsplash.com/photos/1494412651409-8963ce7935a7 · License: Unsplash · Subject: shipping containers / port
- energy.jpg       — Source: unsplash.com/photos/1466611653911-95081537e5b7 · License: Unsplash · Subject: power infrastructure / grid
- smart_city.jpg   — Source: unsplash.com/photos/1480714378408-67cf0d13bc1b · License: Unsplash · Subject: urban skyline / smart infra
- public.jpg       — Source: unsplash.com/photos/1541872703-74c5e44368f9 · License: Unsplash · Subject: public institution / civic

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
