# XIM-22 수동 WCAG 2.1 AA 체크리스트 — 키보드/대비/스크린리더

> 자동 검사(axe-core)가 잡지 못하는 항목 — 휴먼 검증 필수.
> 각 항목 PASS/FAIL + 증거(스크린샷 또는 메모) 기록.
> 대상: `http://ximtier.158.247.235.31.nip.io/{ko,en}` 모든 핵심 페이지.

## A. 키보드 네비게이션 (WCAG 2.1.1, 2.1.2, 2.4.3, 2.4.7)

- [ ] **Tab 진입 순서가 시각 흐름과 일치** — Skip-link → Nav → Main → Footer
- [ ] **Skip to main content 링크**가 최초 Tab에서 즉시 보이고 동작 (`#main`)
- [ ] **포커스 표시(outline)**가 모든 interactive에 보이며 대비 3:1 이상
- [ ] **Hero CTA, Reverse What-If 슬라이더, SHAP 탭** 모두 키보드만으로 조작
- [ ] **모달/드롭다운 트랩 없음** — Esc로 닫기, 닫힌 뒤 트리거 요소로 포커스 복귀
- [ ] **데모/문의 폼** Tab/Shift+Tab 양방향 + Enter 제출 가능
- [ ] **언어 스위치(ko↔en)** 키보드만으로 전환 가능

## B. 색 대비 (WCAG 1.4.3 / 1.4.11)

- [ ] **본문 텍스트 4.5:1 이상** (axe-core가 1차로 잡지만 그라데이션/이미지 위 텍스트 별도 확인)
- [ ] **CTA 버튼** background ↔ label 4.5:1 이상
- [ ] **포커스 indicator** ↔ 인접 색상 3:1 이상
- [ ] **에러/경고/필수 표시** 색만으로 의미 전달 X (아이콘/텍스트 병기)
- [ ] **chip/badge/SHAP 막대** dark/light bg 모두 대비 통과

## C. 스크린리더 (WCAG 1.3.1, 2.4.6, 4.1.2)

검증 도구: macOS VoiceOver (Cmd+F5)

- [ ] **랜드마크 구조**: `<header>`, `<nav>`, `<main>`, `<footer>` 모두 존재 + 1개씩
- [ ] **헤딩 계층**: h1 단일, h2 → h3 건너뛰지 않음 (VO로 H 키 탐색)
- [ ] **이미지 alt**: 의미 있는 이미지에 한국어/영어 적절한 alt, 장식 이미지 alt="" 또는 role=presentation
- [ ] **폼 라벨**: 모든 input에 `<label for>` 또는 `aria-label` — placeholder만 라벨로 쓰지 않음
- [ ] **에러 메시지**: `aria-live="polite"` + 필드와 `aria-describedby` 연결
- [ ] **Reverse What-If 슬라이더**: `role="slider"` + `aria-valuemin/max/now/text` 모두 노출
- [ ] **SHAP 탭**: `role="tablist"` + `aria-selected` 토글 + arrow key 이동
- [ ] **언어 변경**: 페이지 `<html lang>` 한↔영 전환 시 정확히 바뀜
- [ ] **외부 링크/PDF 다운로드**: 어떤 형식인지 SR이 안내 (`download` 속성 또는 텍스트)

## D. 모션 감수성 (WCAG 2.3.3)

- [ ] **`prefers-reduced-motion: reduce`** 활성 시
  - Hero floating chips 모션 OFF
  - SHAP 슬라이더 트랜지션 OFF
  - 카운트업 애니메이션 즉시 종료값으로 표시

## E. 반응형/줌 (WCAG 1.4.4, 1.4.10)

- [ ] **200% 줌** 시 본문 가독 + 좌우 스크롤 없음
- [ ] **320px 모바일** 핵심 CTA/네비 노출, overflow 없음
- [ ] **세로 모드 회전** 시 콘텐츠 손실 없음

---

## 실행 기록

| 일시 | 검증자 | PASS | FAIL | 증거 폴더 |
|------|--------|------|------|----------|
|      |        |      |      |          |

## FAIL → 후속 액션

FAIL 항목 발견 시 다음 형식으로 `.claude/issue-db/registry.json`에 `FIX_BUG` 이슈 추가:

```json
{
  "id": "ISS-XXX",
  "type": "FIX_BUG",
  "title": "[a11y] {페이지}: {위반 항목 1줄}",
  "description": "WCAG {2.x.x}. {재현 절차}. 증거: reports/qa-xim22-{date}/{...}",
  "agent": "agent-harness",
  "priority": "P1",
  "status": "READY",
  "scope": ["{관련 view/component 파일}"],
  "success_criteria": "axe-core PASS + 수동 체크리스트 PASS",
  "tags": ["a11y", "wcag-2.1-aa"]
}
```
