# XimTier PPTX 충실 홈페이지 시안 (별도 URL) — 설계 명세

작성일: 2026-06-01
작성자: 강승식 대표 / Claude (Gagahoho, Inc.)
상태: 설계 확정, 구현 대기

---

## 1. 배경 & 목적

한일 대표가 작성한 PPTX(「XimTier 메뉴구성과 구현 화면」, 76장)의 **문구·구조·의도를 최대한 충실히 반영한 홈페이지 시안**을 만든다.

- **현재 운영 중인 `ximtier.com` 홈(`pages#home`)은 일절 건드리지 않는다.**
- 별도 URL 경로에 띄워 **파트너가 "PPTX대로 만든 모습"을 비교 확인**할 수 있게 한다.
- 한 대표의 의도: *"내가 표기한 문구·그림·메뉴 구성이 그대로 반영되기를 원한다."*

## 2. 핵심 결정 (브레인스토밍 확정)

| 항목 | 결정 | 근거 |
|---|---|---|
| 구현 방식 | **C안 — 완전 웹 재구성** | PPTX 문구·구조·의도 유지, 외형은 웹 컴포넌트로 새로 디자인 |
| 정보 구조 | **PPTX 메뉴 구성 = 사이트맵** | Contents 슬라이드의 5챕터 메뉴 트리를 그대로 사이트 구조로 |
| 네비게이션 | **원페이지 스크롤 + 상단 5대메뉴 앵커** | 5챕터를 한 페이지에 순서대로, 메뉴 클릭 시 해당 챕터로 스크롤 |
| 디자인 톤 | **하이브리드** | Hero·아키텍처·로드맵 등 강조부는 다크 네이비, 메뉴 상세 본문은 화이트 캔버스 |

## 3. 사이트맵 (PPTX Contents 슬라이드 그대로)

상단 네비 = 5개 대메뉴. 각 대메뉴 클릭 시 해당 챕터 섹션으로 스크롤. 하위 항목 = 챕터 내 서브섹션.

```
XimTier — Explainable AI Simulation frontier
│
├─ 01 메뉴 구성 개요 (#overview)
│   ├─ 주요 메뉴 구성 개요
│   ├─ XimTier 특징 요약
│   ├─ XimTier 핵심 기술력
│   ├─ 메뉴 요약
│   ├─ 기술 구조와 서비스 방식 (3단 아키텍처)
│   ├─ XimTier 최적화 로드맵 (5단계)
│   └─ XimTier 활용과 효과
│
├─ 02 데이터 탐색 (#data-exploration)
│   ├─ 데이터 탐색
│   ├─ WhatDataAI 분석
│   ├─ 주소 XY 정제
│   ├─ AI 탐색 차트
│   ├─ AI 텍스트 탐색 분석
│   ├─ 주제도 분석
│   ├─ AI 종합 인사이트 리포트
│   └─ AI Target YX 최적화
│
├─ 03 AI 통계분석 솔루션 (#analysis)
│   ├─ AI 분석 파이프라인 (5단계)
│   ├─ AI 분석 종류와 방법 (회귀·판별·다중분류·시계열)
│   └─ Xim4Reporting
│
├─ 04 AI One-Stop 솔루션 (#solutions)
│   ├─ AI 스마트 Meeting 분석
│   ├─ AI 스마트 설문 분석
│   ├─ AI 스마트 SNS 분석
│   ├─ AI 축제/행사 YX 최적화
│   ├─ AI 전통시장/상권 YX 최적화
│   ├─ AI 소상공인/매장 YX 최적화
│   ├─ AI 광고형 병의원 YX 최적화
│   ├─ AI 설비고장/예지보전 YX 최적화
│   ├─ AI SNS 기반 제품 기능 개발 YX 최적화
│   └─ AI 설문 기반 제품 기능 개발 YX 최적화
│
└─ 05 업무 활용 방안 (#usage)
    ├─ AX 활용성 강화 방안
    ├─ 데이터 기반의 AI 의사결정 플랫폼
    ├─ 분야별 활용과 기대효과
    └─ 맞춤형 서비스 방안
```

## 4. 기술 구현 방식

### 4.1 라우팅 (현 홈과 격리)
- 새 액션 `pages#deck` (가칭) 추가. 경로: `/(:locale)/deck` (예: `/ko/deck`, `/en/deck`).
  - `config/routes.rb`의 기존 `scope "(:locale)"` 블록 안에 `get "/deck", to: "pages#deck", as: :deck` 1줄 추가.
  - 기존 `home` 라우트·뷰·로케일 키와 **완전히 분리**. home 관련 파일 수정 금지.
- 최종 URL 예: `https://ximtier.com/ko/deck` (배포 시).

### 4.2 뷰 구조 (단일 책임 단위로 분리)
- `app/views/pages/deck.html.erb` — 컨테이너 (상단 앵커 네비 + 5개 챕터 섹션 렌더)
- 5개 챕터는 파셜로 분리하여 각각 독립적으로 이해·수정 가능:
  - `app/views/pages/deck/_chapter_overview.html.erb` (01)
  - `app/views/pages/deck/_chapter_data.html.erb` (02)
  - `app/views/pages/deck/_chapter_analysis.html.erb` (03)
  - `app/views/pages/deck/_chapter_solutions.html.erb` (04)
  - `app/views/pages/deck/_chapter_usage.html.erb` (05)
- 상단 네비 파셜: `app/views/pages/deck/_nav.html.erb`

### 4.3 콘텐츠(텍스트)
- PPTX 76장에서 추출한 **실제 문구를 그대로** 사용. 요약·재해석 최소화.
- 한/영 i18n: `config/locales/ko/deck.yml`, `config/locales/en/deck.yml` 신규 생성. (기존 site.yml 등 수정 안 함)
- 영문은 ko 우선 작성 후 번역. (PPTX가 한글 기준이므로 ko가 원본)

### 4.4 디자인 (하이브리드 톤)
- **강조 섹션(다크 네이비 `#0a1124`/`#16325C` + 청록 `#00C8C8` 그라데이션)**: Hero, 3단 아키텍처, 5단계 로드맵, 경쟁사 비교, CTA.
- **본문 섹션(화이트 캔버스 `#ffffff` + 회색 텍스트)**: 메뉴 상세(데이터 탐색 8종, 솔루션 10종 등).
- 기존 `application.html.erb` 레이아웃 재사용 가능하나, deck 전용 CSS는 `<style>` 인라인 또는 별도 partial로 격리하여 기존 스타일 오염 방지.
- 브랜드 표기: 항상 **XimTier** (XAISimTier 변형 금지).

### 4.5 도표/그림 처리
- PPTX의 복잡한 도식(3단 아키텍처, 5단계 파이프라인, 로드맵)은 **HTML/CSS로 재구성**(C안 원칙).
- 단, 재구성이 과한 슬라이드(예: 실제 제품 화면 캡처가 핵심인 메뉴 상세)는 **PPTX 슬라이드 이미지(`/tmp/ximtier_pptx/img/slide-NN.png` → `app/assets/images/deck/`로 복사)**를 보조로 삽입 가능. 텍스트 우선, 이미지는 근거 보강용.

## 5. 범위 (Scope)

### 포함
- `/deck` 라우트 1개 + 컨트롤러 액션 1개
- deck 뷰 + 6개 파셜(nav + 5챕터)
- ko/en deck.yml i18n
- 하이브리드 디자인 (deck 전용, 격리)
- 상단 앵커 네비 (스크롤 이동)
- PPTX 5챕터 전체 콘텐츠

### 제외 (YAGNI)
- 현 `ximtier.com` 홈 수정 (절대 안 함)
- 새 백엔드 로직·DB·폼 (정적 콘텐츠 페이지)
- 프로덕션 배포 (별도 작업 — 현재 KAMAL_REGISTRY_PASSWORD 시크릿 이슈로 막힘. 우선 로컬/staging에서 확인)
- 검색·필터·동적 기능

## 6. 성공 기준

1. `/ko/deck` 접속 시 HTTP 200, 5챕터가 PPTX 순서대로 렌더.
2. 상단 5대메뉴 클릭 시 해당 챕터로 스크롤 이동.
3. PPTX의 핵심 문구(의사결정 최적화, Reverse What-If, 10종 솔루션명 등)가 그대로 노출.
4. 현 `/ko`(홈) 페이지는 변경 전과 100% 동일 (회귀 없음).
5. 브라우저 실제 조작(스크롤·앵커) 스크린샷으로 검증.

## 7. 검증 방법

- Rails 서버 기동 → `/ko/deck` 200 확인.
- Playwright로 상단 메뉴 클릭 → 스크롤 이동 → 챕터별 스크린샷.
- `/ko`(기존 홈) 회귀 확인 (변경 없음).
