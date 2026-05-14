#!/usr/bin/env bash
# 누락된 페이지만 보충 측정 — pages.json - 기존 *.report.json 차집합
set -euo pipefail
cd "$(dirname "$0")/../.."

DATE="${QA_DATE:-$(date +%Y%m%d)}"
LH_DIR="../reports/qa-xim22-${DATE}/lighthouse"
SUMMARY_TSV="${LH_DIR}/_summary.tsv"
PAGES_JSON="scripts/qa/pages.json"

BASE_URL="$(node -e "console.log(require('./${PAGES_JSON}').baseUrl)")"

MISSING=$(node -e "
  const fs = require('fs');
  const j = require('./${PAGES_JSON}');
  for (const p of j.pages) {
    const f = '${LH_DIR}/' + p.id + '.report.json';
    if (!fs.existsSync(f)) console.log([p.id, p.path].join('|'));
  }
")

if [ -z "${MISSING}" ]; then
  echo "▶ 누락 페이지 없음 ✅"
  exit 0
fi

echo "▶ 누락 페이지 측정"
echo "${MISSING}" | while IFS='|' read -r ID PATH_; do
  [ -z "${ID}" ] && continue
  URL="${BASE_URL}${PATH_}"
  OUT_BASE="${LH_DIR}/${ID}"
  echo "  · ${ID}  (${URL})"
  ./node_modules/.bin/lighthouse "${URL}" \
    --quiet --no-update-notifier \
    --preset=desktop \
    --chrome-flags="--headless=new --no-sandbox --disable-gpu" \
    --only-categories=performance,accessibility \
    --output=json --output=html \
    --output-path="${OUT_BASE}" \
    >/dev/null 2>&1 || { echo "    ⚠ 실패 (${ID})"; continue; }
  node -e "
    const fs = require('fs');
    const r = JSON.parse(fs.readFileSync('${OUT_BASE}.report.json', 'utf8'));
    const a = r.audits, c = r.categories;
    const ms = (k) => a[k] && typeof a[k].numericValue === 'number' ? Math.round(a[k].numericValue) : 'n/a';
    const num = (k, d=3) => a[k] && typeof a[k].numericValue === 'number' ? a[k].numericValue.toFixed(d) : 'n/a';
    const row = ['${ID}', '${PATH_}', c.performance.score, c.accessibility.score, ms('largest-contentful-paint'), num('cumulative-layout-shift'), ms('total-blocking-time'), ms('first-contentful-paint'), ms('speed-index')].join('\t');
    fs.appendFileSync('${SUMMARY_TSV}', row + '\n');
    console.log('    LCP=' + ms('largest-contentful-paint') + 'ms  CLS=' + num('cumulative-layout-shift') + '  perf=' + c.performance.score + '  a11y=' + c.accessibility.score);
  "
done

echo "▶ 완료"
