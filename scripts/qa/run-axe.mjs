#!/usr/bin/env node
// axe-core WCAG 2.1 AA 자동 검사 — 한/영 페이지 동시
// PRD §5: WCAG 2.1 AA — 키보드 네비/대비/스크린리더
// 출력: reports/qa-xim22-{date}/axe/{pageId}.json + _summary.tsv

import { chromium } from 'playwright';
import AxeBuilder from '@axe-core/playwright';
import { readFileSync, writeFileSync, mkdirSync, appendFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..', '..');
const PAGES_JSON = resolve(ROOT, 'scripts/qa/pages.json');
const cfg = JSON.parse(readFileSync(PAGES_JSON, 'utf8'));

const DATE = process.env.QA_DATE ?? new Date().toISOString().slice(0, 10).replaceAll('-', '');
const REPORTS_DIR = process.env.QA_REPORTS_DIR ?? resolve(ROOT, '..', 'reports', `qa-xim22-${DATE}`);
const AXE_DIR = join(REPORTS_DIR, 'axe');
mkdirSync(AXE_DIR, { recursive: true });

const summaryTsv = join(AXE_DIR, '_summary.tsv');
writeFileSync(summaryTsv, ['id', 'url', 'violations', 'serious', 'critical', 'incomplete', 'passes'].join('\t') + '\n');

console.log(`▶ axe-core WCAG 2.1 AA 검사 시작 (base=${cfg.baseUrl})`);
console.log(`  결과: ${AXE_DIR}\n`);

// 시스템 Chrome 사용 (Playwright Chromium 별도 설치 불필요)
const browser = await chromium.launch({ headless: true, channel: 'chrome' });
const ctx = await browser.newContext({ locale: 'ko-KR', viewport: { width: 1440, height: 900 } });

let totalViolations = 0;
let totalCritical = 0;
let totalSerious = 0;
const perPageBugs = [];

for (const page of cfg.pages) {
  const url = cfg.baseUrl + page.path;
  process.stdout.write(`  · ${page.id}  (${page.path})  ... `);

  const pg = await ctx.newPage();
  try {
    await pg.goto(url, { waitUntil: 'networkidle', timeout: 25_000 });
  } catch (err) {
    console.log(`navigation 실패: ${err.message}`);
    await pg.close();
    continue;
  }

  // WCAG 2.1 AA 룰셋만
  const results = await new AxeBuilder({ page: pg })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
    .analyze();

  const violations = results.violations;
  const critical = violations.filter((v) => v.impact === 'critical');
  const serious = violations.filter((v) => v.impact === 'serious');

  const out = {
    page: page,
    url,
    timestamp: new Date().toISOString(),
    summary: {
      violations: violations.length,
      critical: critical.length,
      serious: serious.length,
      incomplete: results.incomplete.length,
      passes: results.passes.length,
    },
    violations: violations.map((v) => ({
      id: v.id,
      impact: v.impact,
      help: v.help,
      helpUrl: v.helpUrl,
      tags: v.tags,
      nodeCount: v.nodes.length,
      sampleTargets: v.nodes.slice(0, 3).map((n) => n.target).flat(),
      sampleHtml: v.nodes.slice(0, 3).map((n) => (n.html || '').slice(0, 200)),
    })),
    incomplete: results.incomplete.map((v) => ({
      id: v.id, impact: v.impact, help: v.help, nodeCount: v.nodes.length,
    })),
  };

  writeFileSync(join(AXE_DIR, `${page.id}.json`), JSON.stringify(out, null, 2));
  appendFileSync(
    summaryTsv,
    [page.id, page.path, violations.length, serious.length, critical.length, results.incomplete.length, results.passes.length].join('\t') + '\n'
  );

  totalViolations += violations.length;
  totalCritical += critical.length;
  totalSerious += serious.length;
  if (violations.length) {
    perPageBugs.push({ id: page.id, violations: violations.map((v) => `${v.id}(${v.impact}, n=${v.nodes.length})`) });
  }

  console.log(`violations=${violations.length}  critical=${critical.length}  serious=${serious.length}`);
  await pg.close();
}

await browser.close();

console.log('\n▶ axe-core 완료');
console.log(`  총 위반: ${totalViolations}  critical=${totalCritical}  serious=${totalSerious}`);
console.log(`  요약: ${summaryTsv}`);

// 콘솔에 위반 페이지만 묶어서 출력 — FIX_BUG 이슈 만들 때 그대로 활용
if (perPageBugs.length) {
  console.log('\n— 위반 요약 (페이지별) —');
  for (const p of perPageBugs) console.log(`  · ${p.id}: ${p.violations.join(', ')}`);
}
