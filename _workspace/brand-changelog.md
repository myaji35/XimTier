# XimTier Brand Changelog

> brand-dna.json 변경 이력. 모든 `approval_required_for` 키 변경은 본 문서에 기록.

## v0.5.0 — 2026-05-18 (REBRAND: Airbnb-시스템 전면 차용)

**의사결정**: 2026-05-18 대표님 결정 — 새 design.md (Airbnb 시스템 1:1 차용본) 적용. 이전 v0.4.0의 딥 네이비 + 블루+티얼 듀얼톤 시스템은 폐기.

**근거 / source**:
- `_design_ref/design.md` — Airbnb 시스템 명세 (2026-05-18 갱신)
- T2 DIRECTION 컨펌 — 대표님 명시 "Airbnb 스타일로 전면 리브랜딩"

### Approval-required 키 변경

| 키 | v0.4.0 | v0.5.0 |
|---|---|---|
| `design_tokens.colors` 구조 | xim_blue/teal_mint/deep_navy 듀얼톤 | primary(#ff385c Rausch) 단색 + canvas/ink/hairline 시스템 |
| `design_tokens.colors.hero` | #2563EB (xim_blue) | (제거) — Hero는 canvas 위 28px h1 |
| `design_tokens.colors.surface_dark` | #0B132D (deep navy) | (제거) — section-dark 폐기 |
| `design_tokens.gradients.brand` | linear-gradient(135deg, #2563EB→#00C8C8) | null (정책: 그라데이션 사용 안 함) |
| `design_tokens.typography.font_heading` | Pretendard + Inter | Airbnb Cereal VF + Circular + Inter + Pretendard fallback |
| `design_tokens.typography.scale` | clamp 기반 h_display 40~78px | 18단계 fixed-px scale (rating_display 64px ~ uppercase_tag 8px) |
| `anti_patterns` | 14종 (XimTier 고유) | 15종 (Rausch 단일 voltage 규칙·shadow 단일 tier·pure black 금지 추가) |

### 추가

- `_governance.overridden_at_v05` — frozen_principles 오버라이드 사유와 후속 이슈(ISS-012, ISS-013) 기록
- `design_tokens.colors.primary` (#ff385c "Rausch") + `primary_active` (#e00b41) + `primary_disabled` (#ffd1da) + 서브브랜드 `luxe` / `plus`
- `design_tokens.colors.canvas/surface_soft/surface_strong` 화이트 시스템
- `design_tokens.colors.hairline/hairline_soft/border_strong` — 경계선 3단계
- `design_tokens.colors.ink/body/muted/muted_soft` — 텍스트 4단계 (pure black 금지)
- `design_tokens.colors.scrim` — modal backdrop
- `design_tokens.typography.scale` — 18단계 명시 토큰 (rating_display ~ uppercase_tag)
- `design_tokens.radius.full` — 9999px pill
- `design_tokens.spacing` — 8px base 9단계 토큰 (xxs ~ section)
- `design_tokens.layout.max_width` 1280px / `max_width_listing` 1080px / `max_width_wide` 1440px
- `ui_rules.touch_target_min_px` 48
- `ui_rules.elevation_policy` (flat 기본 + 단일 tier)
- `ui_rules.color_voltage_policy` (Rausch는 화면당 1~2 moment)
- `emotional_tone[3]` — "테크 모던 (Palantir·Stripe 톤)" → "정밀한 모던 (Airbnb-tier 화이트 캔버스 + 단일 액센트의 절제)"
- `anti_patterns[2]` — "Rausch(#ff385c) 외 액센트 색 추가 금지 — 단일 voltage 원칙"
- `anti_patterns[14]` — "여러 단계 shadow tier — 단일 tier(card hover)만 사용"
- `anti_patterns[15]` — "Pure black(#000) 사용 — ink(#222222)만"

### 제거

- `design_tokens.colors.xim_blue/xim_blue_deep/xim_blue_soft` — 블루 듀얼톤 폐기
- `design_tokens.colors.teal_mint` — 티얼 액센트 폐기
- `design_tokens.colors.deep_navy/deep_navy_2/near_black` — 다크 베이스 폐기
- `design_tokens.gradients.brand/brand_radial/x_top_left/x_top_right` — 그라데이션 정책상 폐기
- `design_tokens.shadow.card_hover/demo_shell/cta_grad/cta_grad_hover` 다중 tier — 단일 `card_hover` + `scrim`만 유지
- `design_tokens.motion.float_chip 5.5s ease-in-out infinite` → `none` (Airbnb는 float 모션 없음)
- `design_tokens.personality.icon_style` `feather-outline` → `hand_illustrated`
- frozen_principles의 "X 심볼 4-blade 구조" / "Blue→Teal 135deg 그라디언트 방향" — 오버라이드

### 후속 이슈

- **ISS-012 [REBRAND P1]** — UI 컴포넌트 리스킨 (Hero deep-navy → canvas, brand-grad → Rausch, application.css 토큰 매핑)
- **ISS-013 [REBRAND-PHASE-2 P2]** — IconComponent feather → hand_illustrated 점검, ISS-010 moat triangle 색 재검토, 캐릭터 저니 재검증

### 충돌 / 주의

- ISS-010 (moat triangle 인터랙티브) 색이 #2563EB blue + #00C8C8 teal로 박혀 있음 → ISS-013에서 Rausch 단색으로 재맵핑 필요
- ISS-002 (SHAP SVG) 양/음 teal/blue 분기 → Rausch 단색 시스템에선 양/음 구분 방식 재설계 필요 (ink fill + outline 또는 다른 의미적 분리)
- Hero floating chips (ISS-003) — Airbnb 시스템엔 float 모션 없음. 정책 충돌 → ISS-013에서 정지 또는 유지 결정
- production ximtier.com 9차 배포본은 v0.4.0 시스템 상태. ISS-012 완료 + 10차 배포 전까지 외부 노출 톤은 그대로 유지됨 (IR/투자자 노출 타이밍 협의 필요)

---

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
