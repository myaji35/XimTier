# XimTier Brand Changelog

> brand-dna.json 변경 이력. 모든 `approval_required_for` 키 변경은 본 문서에 기록.

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
