# XAISimTier · 프로젝트 Wiki

XimTier 보고서·전략 문서 통합 인덱스. 모든 IR 자료·전략 보고서·적용사례·규제 대응 문서는 본 wiki에서 검색·열람한다.

- **위치**: `xaisimtier/docs/wiki/`
- **최종 업데이트**: 2026-05-15
- **관리자**: 강승식 (CTO) / XimTier 전략팀

---

## 📑 보고서 목록

### 🎯 전략 · B2C 확장 (Strategy · B2C Expansion)

| 문서 | 일자 | 페이지 | 한 줄 요약 |
|---|---|---|---|
| [거꾸로 계산기 — 28 적용사례 + 매출 시뮬 + 시장 인식 전환 전략](./거꾸로계산기_28적용사례_260515.pdf) | 2026-05-15 | 21쪽 | 가정용 Reverse What-If 앱 「거꾸로 계산기」(글로벌 Goalculator B2C · Backmath B2B). 28 시나리오 · 무료/유료 티어 · 히트맵 · Y5 글로벌 1,240억 · **B2C→B2B 트로이의 목마 전략** · §7.4 매출 패스/보수 분리 · §8.6 인증 로드맵 |
| [거꾸로 계산기 — 인증 로드맵 + 매출 현실화 분석](./거꾸로계산기_인증로드맵_260515.pdf) | 2026-05-15 | 4쪽 | **인증 패스 전략 단일 보고서**. B2C 필수 6건 / 사전 준비 4건 / B2B 연기 9건. Y1~5 누적 매출 패스 669억 vs 보수 296억 (+373억). Series A 1.5~2배 + 지분 10%p 보존. IR + 영업 + 법무 공용 |
| [Slide 13 — B2C as B2B Trojan Horse (피치덱 v2 신규 슬라이드)](./Slide13_TrojanHorse_260515.pdf) · [초안 노트](./Slide13_TrojanHorse_초안_260515.md) | 2026-05-15 | 1쪽 | 피치덱 v2에 추가할 단일 슬라이드. **"가정 100만 가구가 매일 사용하면, 기업은 거부할 수 없다."** Slack·Notion·Figma·Linear 선례 인용. A4 가로 |
| [Slide 14 — Capital Efficiency · Certification-Pass](./Slide14_CapitalEfficiency_260515.pdf) · [초안 노트](./Slide14_CapitalEfficiency_초안_260515.md) | 2026-05-15 | 1쪽 | 피치덱 v2 Slide 14. **"인증 패스 12개월 = Y5 시가총액 2배. 자본 효율은 시간에서 나온다."** 누적 매출 막대 비교 669 vs 296억. Slide 13과 한 세트 |

### 💼 IR · 투자 유치 (Investor Relations)

| 문서 | 일자 | 한 줄 요약 |
|---|---|---|
| [XimTier IR 컨택패키지](../../../reports/XimTier_IR_컨택패키지_260514.pdf) | 2026-05-14 | Pre-Seed 투자자 컨택용 통합 자료 |
| [Palantir vs XimTier 비교보고서](../../../reports/Palantir_vs_XimTier_비교보고서_260514.pdf) | 2026-05-14 | 글로벌 의사결정 플랫폼 비교 분석 |
| [후발주자 검토 보고서](../../../reports/XimTier_후발주자_검토보고서_260514.pdf) | 2026-05-14 | 후발주자 리스크 · 경쟁사 분석 |

### ⚖️ 규제 · 인증 (Regulation · Compliance)

| 문서 | 일자 | 한 줄 요약 |
|---|---|---|
| [규제당국 대응 통합보고서](../../../reports/XimTier_규제당국_대응통합보고서_260514.pdf) | 2026-05-14 | 한국 AI 기본법 · EU AI Act · 의료기기 SaMD 등 통합 대응 |
| [TTA CAT 제출서류 초안](../../../reports/XimTier_TTA_CAT_제출서류_초안보고서_260514.pdf) | 2026-05-14 | TTA Conformity Assessment Test 인증 자료 |

### 🧪 QA · 테스트 (Quality)

| 문서 | 일자 | 한 줄 요약 |
|---|---|---|
| [QA xim22 (2026-05-14)](../../../reports/qa-xim22-20260514/) | 2026-05-14 | 통합 QA 결과 폴더 |

---

## 🗂️ 관련 핵심 문서 (보고서 외)

| 문서 | 위치 | 용도 |
|---|---|---|
| [Architecture](../architecture.md) | `docs/architecture.md` | 시스템 아키텍처 + 본 wiki 링크 |
| [GraphRAG Principles](../graphrag-principles.md) | `docs/graphrag-principles.md` | GraphRAG 설계 원칙 |
| [ADR](../adr/) | `docs/adr/` | Architecture Decision Records |
| [Brand DNA](../brand/) | `docs/brand/` | 브랜드 정체성 + 디자인 토큰 |
| [PRD](../../../prd.md) | 루트 `prd.md` | 공식 홈페이지 PRD |
| [Pitch Deck v2](../../../XAISimTier_PitchDeck_v2.md) | 루트 | 피치덱 v2 (Pre-Seed IR) |

---

## 🧭 보고서 작성·등록 규칙

1. **신규 보고서는 `xaisimtier/docs/wiki/`에 PDF 직접 저장** (또는 `reports/` 경유 후 wiki에 링크).
2. **본 INDEX.md에 한 줄 요약 + 일자 + 페이지 + 링크 추가**.
3. **카테고리 분류**: 전략 / IR / 규제 / QA / 기타. 신규 카테고리 필요 시 본 인덱스 상단에 추가.
4. **파일명 규칙**: `{주제}_{서브주제}_{YYMMDD}.pdf` (예: `거꾸로계산기_28적용사례_260515.pdf`).
5. **세션 종료 전** 본 인덱스를 갱신했는지 확인.

---

## 🔗 빠른 검색

- **거꾸로 계산기 / Goalculator / Backmath** → 2026-05-15 적용사례 보고서
- **Reverse What-If** → 거꾸로 계산기 보고서 + 피치덱 v2
- **마이데이터 / 헬스커넥트** → 거꾸로 계산기 8.1 데이터 수집 전략
- **B2C → B2B 트로이의 목마** → 거꾸로 계산기 9장 + [Slide 13](./Slide13_TrojanHorse_260515.pdf)
- **피치덱 신규 슬라이드 / IR 발표 자료** → [Slide 13](./Slide13_TrojanHorse_260515.pdf) · [Slide 14](./Slide14_CapitalEfficiency_260515.pdf) (한 세트)
- **인증 / 규제 / TTA CAT / ISMS-P / 마이데이터 / SaMD / AI 기본법** → [인증 로드맵](./거꾸로계산기_인증로드맵_260515.pdf) + 28적용사례 §8.6
- **자본 효율 / Series A / 지분 희석 / Y1 매출** → [Slide 14](./Slide14_CapitalEfficiency_260515.pdf) + [인증 로드맵](./거꾸로계산기_인증로드맵_260515.pdf) §2
- **Y5 매출 시뮬** → 거꾸로 계산기 7장 (한국 373억 + 해외 867억)
- **활동 히트맵 / Calendar Heatmap** → 거꾸로 계산기 5장
