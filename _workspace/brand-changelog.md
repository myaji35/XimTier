# XimTier Brand Changelog

> brand-dna.json 변경 이력. 모든 `approval_required_for` 키 변경은 본 문서에 기록.

## v0.4.0 — 2026-05-14 (XIM-10: DESIGN brand-dna.json 정의)
- **추가**: top-level `agenda` = "LLM이 못 푸는 수치를, 우리가 증명한다" (PRD §8.1 + PitchDeck v2 line 12)
- **추가**: `emotional_tone` 5종 (신뢰감 / 단호함 / 수치 우선 / 테크 모던 / 조용한 우월감)
- **추가**: `anti_patterns` 14종 (공허한 형용사·이모지 남발·과한 라운드·AI 슬롭·LLM 동급 경쟁 톤·캐주얼 카피 등)
- **추가**: `design_tokens.typography.font_heading` / `font_body` / `font_kr` / `font_en` — Pretendard(KR) + Inter(EN) 분리 명시
- **추가**: `design_tokens.colors.hero` / `text_primary` / `surface` / `surface_alt` / `surface_dark` — 하네스 매핑 표 호환
- **추가**: `design_tokens.personality` (icon_style=feather-outline, density=comfortable, tone=precise)
- **추가**: `design_tokens.motion.hover_effect=lift` / `float_chip` 5.5s
- **추가**: `design_tokens.shape.radius=moderate` + radius_scale 4단계
- **추가**: `design_tokens.gradients.brand_radial` (Hero 배경용)
- **추가**: `ui_rules` (primary_action_per_screen / user_decision_clarity / section_tone_alternation / kpi_format / cta_hierarchy / logo_min_size / image_policy)
- **추가**: `copy_voice` (headline_pattern / kpi_pattern / preferred_words / forbidden_words / tone_examples)
- **추가**: `brand.category` = "Post-LLM Decision Intelligence Platform" / `brand.narrative_anchor` = "ChatGPT가 설명한다면, XimTier는 증명한다"
- **확장**: `_governance.approval_required_for` — `agenda` / `anti_patterns` / `font_heading` / `font_body` 추가
- **확장**: `_governance.frozen_principles` — agenda 한 줄 추가
- **근거**: XIM-10 issue 요구사항 (PRD 8.1 + PitchDeck v2 톤 매칭 + 하네스 brand-dna.json 매핑 표)
- **승인자**: UXDesigner 에이전트 (XIM-10 자동 수행) — 다음 세션 CEO/CTO 검토 대상

## v0.3.0 — 2026-05-13
- **추가**: `_governance` 섹션 (owner / approval_required_for / auto_iterable / frozen_principles)
- **변경**: `brand.product` "XAISimTier" → "XimTier" (브랜드 일원화)
- **변경**: `_source` 주석 갱신
- **근거**: 대표님 결정 — 회사·제품·도메인 모두 XimTier로 통일
- **승인자**: CEO 한일 + CTO 강승식

## v0.2.0 — 2026-05-12
- **초기**: design.md (XimTier Homepage Design Spec) 1차 적용
- 컬러 / 타이포 / 레이아웃 / 그라디언트 / 모션 토큰 정의
- **승인자**: CTO 강승식 (design.md를 받음)

---

## 변경 절차 (lock_until: 2026-09-30 까지)
1. `approval_required_for` 키 변경 시 → 본 문서에 사유 + 승인자 기록
2. `auto_iterable` 키는 자유 변경 가능 (PR description에만 명시)
3. `frozen_principles` 4가지는 lock_until 이후에만 변경 가능
4. 변경 후 `_version` semver 증가 + `_last_updated` 갱신
