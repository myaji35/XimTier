# XIM-22 QA 자동화

> **목적**: PRD §5 비기능 요구사항 — Core Web Vitals + WCAG 2.1 AA를 한/영 페이지에 자동 검사.
>
> **관련 이슈**: XIM-22 (Paperclip)

## 구성

```
scripts/qa/
├── pages.json            # 검사 대상 URL + 임계치 (LCP<2.5s, CLS<0.1, TBT<200ms)
├── run-lighthouse.sh     # Lighthouse CLI 자동 실행 (perf + a11y 카테고리)
├── run-axe.mjs           # Playwright + @axe-core/playwright (WCAG 2.1 AA)
├── manual-checklist.md   # 키보드/스크린리더 수동 체크리스트
└── README.md             # 이 파일
```

## 사전 준비

- macOS + Google Chrome.app 설치 (lighthouse CLI가 자동 사용)
- Node.js 20+ (현재 환경 v25)
- 사이트 가동: `http://ximtier.158.247.235.31.nip.io` (또는 `BASE_URL` override)

## 실행

```bash
# Lighthouse
bash scripts/qa/run-lighthouse.sh

# axe-core (한 번에 의존성 자동 설치됨)
npx --yes -p playwright -p @axe-core/playwright node scripts/qa/run-axe.mjs
```

산출물:

```
reports/qa-xim22-YYYYMMDD/
├── lighthouse/
│   ├── {pageId}.report.html
│   ├── {pageId}.report.json
│   └── _summary.tsv         # id, url, perf, a11y, LCP, CLS, TBT, FCP, SI
└── axe/
    ├── {pageId}.json
    └── _summary.tsv         # id, url, violations, serious, critical, incomplete, passes
```

## 임계치 (PRD §5)

| 지표 | 임계 | 비고 |
|------|------|------|
| LCP | < 2.5s | Largest Contentful Paint |
| CLS | < 0.1 | Cumulative Layout Shift |
| FID | < 100ms | RUM 한정. Lab은 **TBT < 200ms**로 대체 측정 |
| WCAG | 2.1 AA | axe-core `wcag2a/2aa/21a/21aa` 태그 + 수동 체크 |
| Perf score | ≥ 0.85 | Lighthouse |
| A11y score | ≥ 0.95 | Lighthouse |

## 위반 처리

- 자동 검사 위반 → `.claude/issue-db/registry.json`에 `FIX_BUG` 이슈 추가 (P0=critical, P1=serious, P2=moderate)
- 수동 체크리스트 FAIL → 같은 형식으로 등록
- `agent-harness`가 자동 픽업하여 수정 → 재검사

## CI 연동 (후속)

GitHub Actions `.github/workflows/qa.yml`에 두 스크립트 추가, `_summary.tsv` 임계 위반 시 빌드 실패. 본 이슈 범위는 로컬 자동화 + 1회 측정까지.
