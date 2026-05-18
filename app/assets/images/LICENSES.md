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

**Current status (2026-05-18): no industry photos in production.**
1st selection (8 Unsplash photos picked by AI from photo IDs) was rejected by the
founder for being off-topic / dated / not aligned with each industry's modern
2026 reality. Re-selection is pending and must go through visual approval
before commit. See ISS-015.

## charts/

Data visualizations. Two acceptable kinds:

1. **Self-authored SVG** that cites a third-party statistic in its caption
   (e.g., "Source: Gartner 2024 Report on LLM POC outcomes").
2. **Public-domain charts** from government / international organizations
   (EU, OECD, IMF, KOSIS, etc.).

**Never embed copyrighted chart screenshots** from Gartner, IDC, Forrester, etc.
Cite their numbers in self-authored SVGs instead.

- gartner_llm_poc_failure.svg — Self-authored XimTier · License: self-authored (free to redistribute with attribution to XimTier) · Cites: Gartner 2024 "Generative AI POC Outcomes" (numerical estimate only, no chart screenshot)
- eu_ai_act_timeline.svg     — Self-authored XimTier · License: self-authored · Cites: Regulation (EU) 2024/1689 (Official Journal, public domain) + 인공지능 기본법(법률 제20039호, 한국 법령정보, public domain)
- chatgpt_vs_ximtier_radar.svg — Self-authored XimTier · License: self-authored · Cites: XimTier internal qualitative benchmark 2026-05

## brand/

XimTier brand assets (logo variants, og-image, favicons).

- (entries added as assets are committed)

---

**Audit policy**: Before every deploy, a CI script should verify that every file
under `app/assets/images/` has a matching entry in this file.
