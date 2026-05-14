#!/usr/bin/env bash
# Lighthouse CI — Core Web Vitals (LCP/CLS/TBT) + Performance + A11y
# PRD §5: LCP<2.5s, CLS<0.1, FID<100ms (Lab은 TBT<200ms로 대체)
# 한/영 페이지 동시 측정 → reports/qa-xim22-{date}/lighthouse/

set -euo pipefail

cd "$(dirname "$0")/../.."  # xaisimtier 루트

DATE="${QA_DATE:-$(date +%Y%m%d)}"
REPORTS_DIR="${QA_REPORTS_DIR:-../reports/qa-xim22-${DATE}}"
LH_DIR="${REPORTS_DIR}/lighthouse"
mkdir -p "${LH_DIR}"

PAGES_JSON="scripts/qa/pages.json"
SUMMARY_TSV="${LH_DIR}/_summary.tsv"

# Chrome.app 직접 경로 (lighthouse가 자동 탐지 못 할 때)
export CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

BASE_URL="$(node -e "console.log(require('./${PAGES_JSON}').baseUrl)")"

echo "▶ Lighthouse CI 시작 (base=${BASE_URL})"
echo "  결과: ${LH_DIR}"
echo ""
printf "id\turl\tperf\ta11y\tLCP_ms\tCLS\tTBT_ms\tFCP_ms\tSI_ms\n" > "${SUMMARY_TSV}"

# pages 배열을 stdout 한 줄씩 id|path|locale 형태로
PAGES_LIST=$(node -e "
  const j = require('./${PAGES_JSON}');
  for (const p of j.pages) {
    console.log([p.id, p.path, p.locale, p.name].join('|'));
  }
")

PASS=0
FAIL=0

while IFS='|' read -r ID PATH_ LOCALE NAME; do
  [ -z "${ID}" ] && continue
  URL="${BASE_URL}${PATH_}"
  # Lighthouse가 --output 다중 지정 + --output-path "X" 사용 시 X.report.json / X.report.html 생성
  OUT_BASE="${LH_DIR}/${ID}"
  OUT_JSON="${OUT_BASE}.report.json"
  OUT_HTML="${OUT_BASE}.report.html"

  echo "  · ${ID}  (${URL})"

  # 로컬 설치된 lighthouse 사용 (npx -y 경고가 stderr 오염 안 시키게)
  ./node_modules/.bin/lighthouse "${URL}" \
    --quiet --no-update-notifier \
    --preset=desktop \
    --chrome-flags="--headless=new --no-sandbox --disable-gpu" \
    --only-categories=performance,accessibility \
    --output=json --output=html \
    --output-path="${OUT_BASE}" \
    >/dev/null 2>&1 || { echo "    ⚠ lighthouse 실행 실패 (${ID})"; FAIL=$((FAIL+1)); continue; }

  # 지표 추출
  node -e "
    const fs = require('fs');
    const r = JSON.parse(fs.readFileSync('${OUT_JSON}', 'utf8'));
    const a = r.audits;
    const ms = (k) => a[k] && typeof a[k].numericValue === 'number' ? Math.round(a[k].numericValue) : 'n/a';
    const num = (k, d=3) => a[k] && typeof a[k].numericValue === 'number' ? a[k].numericValue.toFixed(d) : 'n/a';
    const cat = (k) => r.categories[k] ? r.categories[k].score : 'n/a';
    const row = [
      '${ID}',
      '${PATH_}',
      cat('performance'),
      cat('accessibility'),
      ms('largest-contentful-paint'),
      num('cumulative-layout-shift'),
      ms('total-blocking-time'),
      ms('first-contentful-paint'),
      ms('speed-index')
    ].join('\t');
    fs.appendFileSync('${SUMMARY_TSV}', row + '\n');
    console.log('    LCP=' + ms('largest-contentful-paint') + 'ms  CLS=' + num('cumulative-layout-shift') + '  TBT=' + ms('total-blocking-time') + 'ms  perf=' + cat('performance') + '  a11y=' + cat('accessibility'));
  " && PASS=$((PASS+1)) || FAIL=$((FAIL+1))

done <<< "${PAGES_LIST}"

echo ""
echo "▶ Lighthouse 완료: PASS=${PASS}  FAIL=${FAIL}"
echo "  요약 TSV: ${SUMMARY_TSV}"
