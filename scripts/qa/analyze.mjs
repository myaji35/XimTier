#!/usr/bin/env node
// XIM-22 결과 분석기 — Lighthouse + axe 결과를 임계치와 비교하여
// PASS/FAIL 판정 + FIX_BUG 이슈 후보 목록 출력.

import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..', '..');
const cfg = JSON.parse(readFileSync(join(ROOT, 'scripts/qa/pages.json'), 'utf8'));
const TH = cfg.thresholds;

const DATE = process.env.QA_DATE ?? new Date().toISOString().slice(0, 10).replaceAll('-', '');
const REPORTS = resolve(ROOT, '..', 'reports', `qa-xim22-${DATE}`);
const LH = join(REPORTS, 'lighthouse');
const AX = join(REPORTS, 'axe');

const lhRows = [];
const axRows = [];
const bugs = [];

// Lighthouse
for (const p of cfg.pages) {
  const j = join(LH, `${p.id}.report.json`);
  let r;
  try { r = JSON.parse(readFileSync(j, 'utf8')); }
  catch { lhRows.push({ id: p.id, missing: true }); continue; }
  const a = r.audits;
  const ms = (k) => a[k]?.numericValue ?? null;
  const score = (k) => r.categories[k]?.score ?? null;
  const row = {
    id: p.id, path: p.path,
    lcp: ms('largest-contentful-paint'),
    cls: ms('cumulative-layout-shift'),
    tbt: ms('total-blocking-time'),
    fcp: ms('first-contentful-paint'),
    si:  ms('speed-index'),
    perf: score('performance'),
    a11y: score('accessibility'),
  };
  const fails = [];
  if (row.lcp != null && row.lcp > TH.lcp_ms) fails.push(`LCP=${Math.round(row.lcp)}ms (>${TH.lcp_ms})`);
  if (row.cls != null && row.cls > TH.cls)    fails.push(`CLS=${row.cls.toFixed(3)} (>${TH.cls})`);
  if (row.tbt != null && row.tbt > TH.tbt_ms) fails.push(`TBT=${Math.round(row.tbt)}ms (>${TH.tbt_ms})`);
  if (row.perf != null && row.perf < TH.perf_score) fails.push(`perf=${row.perf.toFixed(2)} (<${TH.perf_score})`);
  if (row.a11y != null && row.a11y < TH.a11y_score) fails.push(`a11y=${row.a11y.toFixed(2)} (<${TH.a11y_score})`);
  row.fails = fails;
  lhRows.push(row);
  if (fails.length) bugs.push({ kind: 'perf', page: p, summary: fails.join(', '), source: `lighthouse/${p.id}.report.html` });
}

// axe
for (const p of cfg.pages) {
  const j = join(AX, `${p.id}.json`);
  let r;
  try { r = JSON.parse(readFileSync(j, 'utf8')); }
  catch { axRows.push({ id: p.id, missing: true }); continue; }
  const row = {
    id: p.id, path: p.path,
    violations: r.summary.violations,
    critical: r.summary.critical,
    serious: r.summary.serious,
    incomplete: r.summary.incomplete,
  };
  axRows.push(row);
  if (r.violations.length) {
    for (const v of r.violations) {
      bugs.push({
        kind: 'a11y', page: p,
        rule: v.id, impact: v.impact, help: v.help, nodes: v.nodeCount,
        targets: v.sampleTargets, helpUrl: v.helpUrl,
        source: `axe/${p.id}.json`,
      });
    }
  }
}

// 리포트 작성
const out = [];
out.push(`# XIM-22 QA 결과 (${DATE})`);
out.push('');
out.push(`Base: \`${cfg.baseUrl}\`  ·  대상: 한/영 총 ${cfg.pages.length}페이지`);
out.push(`임계치: LCP<${TH.lcp_ms}ms, CLS<${TH.cls}, TBT<${TH.tbt_ms}ms, perf≥${TH.perf_score}, a11y≥${TH.a11y_score}`);
out.push('');
out.push('## 1. Core Web Vitals (Lighthouse — Lab)');
out.push('');
out.push('| id | path | perf | a11y | LCP(ms) | CLS | TBT(ms) | FCP(ms) | SI(ms) | FAIL |');
out.push('|---|---|---|---|---|---|---|---|---|---|');
for (const r of lhRows) {
  if (r.missing) { out.push(`| ${r.id} | — | — | — | — | — | — | — | — | (no report) |`); continue; }
  const f = r.fails.length ? '⚠ ' + r.fails.join('; ') : '✅';
  out.push(`| ${r.id} | \`${r.path}\` | ${r.perf?.toFixed(2)} | ${r.a11y?.toFixed(2)} | ${Math.round(r.lcp ?? 0)} | ${(r.cls ?? 0).toFixed(3)} | ${Math.round(r.tbt ?? 0)} | ${Math.round(r.fcp ?? 0)} | ${Math.round(r.si ?? 0)} | ${f} |`);
}
out.push('');
out.push('## 2. WCAG 2.1 AA (axe-core)');
out.push('');
out.push('| id | path | violations | critical | serious | incomplete |');
out.push('|---|---|---|---|---|---|');
for (const r of axRows) {
  if (r.missing) { out.push(`| ${r.id} | — | — | — | — | — |`); continue; }
  out.push(`| ${r.id} | \`${r.path}\` | ${r.violations} | ${r.critical} | ${r.serious} | ${r.incomplete} |`);
}

// rule별 집계
const ruleAgg = new Map();
for (const b of bugs.filter((x) => x.kind === 'a11y')) {
  const k = b.rule;
  if (!ruleAgg.has(k)) ruleAgg.set(k, { rule: k, impact: b.impact, help: b.help, helpUrl: b.helpUrl, pages: new Set(), nodes: 0 });
  const e = ruleAgg.get(k);
  e.pages.add(b.page.id);
  e.nodes += b.nodes;
}
out.push('');
out.push('## 3. WCAG 위반 규칙별 집계');
out.push('');
if (!ruleAgg.size) {
  out.push('_위반 없음 ✅_');
} else {
  out.push('| rule | impact | pages | total nodes | help |');
  out.push('|---|---|---|---|---|');
  for (const e of [...ruleAgg.values()].sort((a, b) => b.nodes - a.nodes)) {
    out.push(`| \`${e.rule}\` | ${e.impact} | ${e.pages.size} | ${e.nodes} | [${e.help}](${e.helpUrl}) |`);
  }
}

// FIX_BUG 후보
out.push('');
out.push('## 4. FIX_BUG 이슈 후보');
out.push('');
const ranked = [];
for (const e of ruleAgg.values()) {
  const pr = e.impact === 'critical' ? 'P0' : e.impact === 'serious' ? 'P1' : 'P2';
  ranked.push({
    priority: pr,
    title: `[a11y] ${e.rule} — ${e.help} (${e.pages.size}p, ${e.nodes}n)`,
    impact: e.impact, rule: e.rule, pages: [...e.pages], help: e.help, helpUrl: e.helpUrl,
  });
}
for (const r of lhRows.filter((x) => x.fails?.length)) {
  ranked.push({
    priority: r.fails.some(f => f.startsWith('LCP')) || r.fails.some(f => f.startsWith('CLS')) ? 'P1' : 'P2',
    title: `[perf] ${r.id} — ${r.fails.join('; ')}`,
    impact: 'perf', rule: 'core-web-vitals', pages: [r.id], help: r.fails.join('; '), helpUrl: null,
  });
}
ranked.sort((a, b) => a.priority.localeCompare(b.priority));
if (!ranked.length) {
  out.push('_생성 대상 없음 ✅ — 모든 임계치 통과_');
} else {
  for (const b of ranked) {
    out.push(`- **${b.priority}** ${b.title}`);
    out.push(`  - 영향 페이지: ${b.pages.join(', ')}`);
    if (b.helpUrl) out.push(`  - 참고: ${b.helpUrl}`);
  }
}

const reportPath = join(REPORTS, 'REPORT.md');
writeFileSync(reportPath, out.join('\n') + '\n');
console.log(`📄 ${reportPath}`);

// JSON도 별도 출력 (이슈 생성 스크립트가 그대로 먹기 좋게)
writeFileSync(join(REPORTS, 'fix-bug-candidates.json'), JSON.stringify(ranked, null, 2));
console.log(`📄 ${join(REPORTS, 'fix-bug-candidates.json')}`);
console.log(`\n총 후보 ${ranked.length}건  (P0: ${ranked.filter(x => x.priority==='P0').length} / P1: ${ranked.filter(x => x.priority==='P1').length} / P2: ${ranked.filter(x => x.priority==='P2').length})`);
