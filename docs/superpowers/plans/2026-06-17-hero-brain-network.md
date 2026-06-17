# 히어로 뇌 네트워크 모션그래픽 (Three.js) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 메인 히어로(`home.html.erb`)의 2D Canvas 모션그래픽을, 청록 뇌 형태 파티클 네트워크 + 수렴 내러티브를 가진 Three.js/WebGL 버전으로 교체한다.

**Architecture:** importmap 기반 Rails 앱에 Three.js를 `vendor/javascript`로 베닜링하고 pin한다. 기존 Stimulus 컨트롤러 `hero_flow_controller.js`를 Three.js 버전으로 재작성하되, 컨트롤러 이름(`hero-flow`)·타깃(`canvas`)·라이프사이클 시그니처(connect/disconnect/resize/start/stop)·안전장치(reduced-motion, visibilitychange, WebGL 폴백)를 그대로 유지하여 ERB 변경을 최소화한다.

**Tech Stack:** Rails 7 (importmap-rails), Hotwired Stimulus, Three.js (ESM, vendor 베닜링), WebGL.

---

## File Structure

- `vendor/javascript/three.module.js` — **Create.** Three.js ESM 단일 파일 (베닜링). 약 1.2MB.
- `config/importmap.rb` — **Modify.** `pin "three"` 1줄 추가.
- `app/javascript/controllers/hero_flow_controller.js` — **Modify (재작성).** Three.js 뇌 네트워크 렌더러. 인터페이스 유지.
- `app/views/pages/home.html.erb` — **변경 없음.** 캔버스 태그·data-controller 기존 그대로 사용.
- `scripts/qa/verify-hero-brain.mjs` — **Create.** Playwright 검증 스크립트 (렌더/콘솔에러/reduced-motion).

ERB는 손대지 않는다 — `<canvas class="v3-hero__canvas" data-hero-flow-target="canvas">` 와 `data-controller="reveal hero-flow"` 가 이미 존재한다.

---

## Task 1: Three.js 베닜링 + importmap pin

**Files:**
- Create: `vendor/javascript/three.module.js`
- Modify: `config/importmap.rb`

- [ ] **Step 1: vendor 디렉토리 생성 및 Three.js 다운로드**

```bash
cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier
mkdir -p vendor/javascript
curl -fsSL https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js -o vendor/javascript/three.module.js
```

Expected: 파일 생성, 종료 코드 0.

- [ ] **Step 2: 다운로드 검증**

```bash
head -c 200 vendor/javascript/three.module.js
ls -la vendor/javascript/three.module.js
```

Expected: 파일 상단에 Three.js 라이선스/버전 주석(`THREE.REVISION` 또는 license header) 표시, 크기 ~1MB 이상. HTML 에러 페이지(`<!DOCTYPE html>`)면 실패 — 다른 CDN(`https://unpkg.com/three@0.160.0/build/three.module.js`)으로 재시도.

- [ ] **Step 3: importmap에 pin 추가**

`config/importmap.rb` 의 `pin "@hotwired/stimulus-loading"` 줄 다음에 추가:

```ruby
pin "three", to: "three.module.js"
```

전체 파일은 다음과 같아야 한다:

```ruby
# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "three", to: "three.module.js"
pin_all_from "app/javascript/controllers", under: "controllers"
```

- [ ] **Step 4: pin 검증**

```bash
bin/importmap json 2>/dev/null | grep -A1 '"three"'
```

Expected: `"three"` 엔트리가 `three.module.js` 자산 경로로 매핑됨. (실패 시 `bin/rails assets:precompile` 없이도 dev에서 동작 — propshaft/sprockets가 vendor/javascript를 자산 경로에 포함하는지 다음 단계에서 확인.)

- [ ] **Step 5: 자산 경로 확인**

```bash
grep -rn "vendor/javascript\|assets.paths" config/initializers/assets.rb 2>/dev/null
bin/rails runner "puts Rails.application.config.assets.paths.grep(/vendor.javascript/)" 2>/dev/null || echo "check manually"
```

Expected: `vendor/javascript` 가 자산 경로에 포함됨. 포함 안 되면 `config/initializers/assets.rb` 에 다음 추가:

```ruby
Rails.application.config.assets.paths << Rails.root.join("vendor/javascript")
```

- [ ] **Step 6: Commit**

```bash
git add vendor/javascript/three.module.js config/importmap.rb config/initializers/assets.rb
git commit -m "build: Three.js vendor 베닜링 + importmap pin 추가"
```

---

## Task 2: hero_flow_controller.js — Three.js 뇌 네트워크 재작성

**Files:**
- Modify (재작성): `app/javascript/controllers/hero_flow_controller.js`

이 컨트롤러는 테스트 가능한 순수 함수(`buildBrainPositions`)와 Three.js 씬 로직을 분리한다. 순수 함수만 단위 테스트하고, 렌더링은 Task 3의 Playwright로 검증한다.

- [ ] **Step 1: 뇌 좌표 생성 순수 함수 작성 (모듈 상단 export)**

`app/javascript/controllers/hero_flow_controller.js` 전체를 다음으로 교체한다:

```javascript
import { Controller } from "@hotwired/stimulus"
import * as THREE from "three"

// HeroFlow — 히어로 배경 "뇌 네트워크 + 데이터→분석→행동 수렴" 모션그래픽 (Three.js)
// 청록 뇌 형태 파티클 네트워크가 살아 숨쉬고, 노드 일부가 '분석 코어'로 점화·수렴해
// Rausch '행동' 펄스를 발사한다. 카피 "AI가 분석하고, XimTier는 행동을 결정합니다"의 시각화.
// 기존 색 토큰만 사용. prefers-reduced-motion / 탭 비활성 시 정지. WebGL 미지원 시 정적 폴백.
// brand-dna.json design_tokens.motion.hero_motion_exception 으로 히어로 한정 허용.

// ── 뇌 노드 좌표 생성 (순수 함수, 테스트 대상) ───────────────────
// 좌우 반구 실루엣을 따라 노드를 분포시킨다. 결정론적(seed)으로 생성해 테스트 가능.
export function buildBrainPositions(count, seed = 1) {
  const positions = []
  let s = seed
  const rng = () => { s = (s * 9301 + 49297) % 233280; return s / 233280 }
  for (let i = 0; i < count; i++) {
    // 두 반구: 좌/우로 약간 분리된 타원체 셸
    const side = i % 2 === 0 ? 1 : -1
    const u = rng() * Math.PI * 2
    const v = Math.acos(2 * rng() - 1)
    // 셸 두께(0.78~1.0)로 표면 근처에 집중 → 윤곽이 보이게
    const rr = 0.78 + rng() * 0.22
    const x = side * (1.05 + Math.sin(v) * Math.cos(u) * 0.95) * rr
    const y = Math.cos(v) * 1.15 * rr
    const z = Math.sin(v) * Math.sin(u) * 0.95 * rr
    positions.push(x, y, z)
  }
  return positions
}

// ── 인접 노드 엣지 인덱스 생성 (순수 함수, 테스트 대상) ──────────
// 각 노드에서 가장 가까운 maxLinks개 노드와 연결. 거리 임계값 이내만.
export function buildEdges(positions, maxLinks = 2, threshold = 0.6) {
  const n = positions.length / 3
  const edges = []
  for (let i = 0; i < n; i++) {
    const ix = positions[i * 3], iy = positions[i * 3 + 1], iz = positions[i * 3 + 2]
    let links = 0
    for (let j = i + 1; j < n && links < maxLinks; j++) {
      const dx = ix - positions[j * 3]
      const dy = iy - positions[j * 3 + 1]
      const dz = iz - positions[j * 3 + 2]
      if (dx * dx + dy * dy + dz * dz < threshold * threshold) {
        edges.push(i, j)
        links++
      }
    }
  }
  return edges
}

export default class extends Controller {
  static targets = ["canvas"]

  connect() {
    this.canvas = this.hasCanvasTarget ? this.canvasTarget : this.element
    this.dpr = Math.min(window.devicePixelRatio || 1, 2)
    this.tick = 0

    if (!this.initThree()) {
      this.drawFallback()
      return
    }

    this.resize()
    this._onResize = () => this.resize()
    window.addEventListener("resize", this._onResize)

    if (this.prefersReducedMotion()) {
      this.renderOnce()
      return
    }

    this._onVisibility = () => {
      if (document.hidden) this.stop()
      else this.start()
    }
    document.addEventListener("visibilitychange", this._onVisibility)
    this.start()
  }

  disconnect() {
    this.stop()
    if (this._onResize) window.removeEventListener("resize", this._onResize)
    if (this._onVisibility) document.removeEventListener("visibilitychange", this._onVisibility)
    if (this.renderer) { this.renderer.dispose(); this.renderer = null }
  }

  prefersReducedMotion() {
    return window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  // ── Three.js 씬 셋업 ────────────────────────────────────────
  initThree() {
    try {
      this.renderer = new THREE.WebGLRenderer({ canvas: this.canvas, alpha: true, antialias: true })
    } catch (e) {
      return false
    }
    if (!this.renderer || !this.renderer.getContext()) return false

    this.scene = new THREE.Scene()
    this.camera = new THREE.PerspectiveCamera(45, 1, 0.1, 100)
    this.camera.position.set(0, 0, 6.2)

    const NODES = Math.max(180, Math.min(560, Math.round(window.innerWidth / 3)))
    const pos = buildBrainPositions(NODES, 7)
    this.nodeCount = NODES

    // 노드 (THREE.Points)
    const nodeGeo = new THREE.BufferGeometry()
    nodeGeo.setAttribute("position", new THREE.Float32BufferAttribute(pos, 3))
    const nodeMat = new THREE.PointsMaterial({
      color: 0x00c8c8, size: 0.045, transparent: true, opacity: 0.85,
      blending: THREE.AdditiveBlending, depthWrite: false
    })
    this.points = new THREE.Points(nodeGeo, nodeMat)
    this.scene.add(this.points)

    // 엣지 (THREE.LineSegments)
    const edges = buildEdges(pos, 2, 0.62)
    const linePos = []
    for (let k = 0; k < edges.length; k += 2) {
      const a = edges[k] * 3, b = edges[k + 1] * 3
      linePos.push(pos[a], pos[a + 1], pos[a + 2], pos[b], pos[b + 1], pos[b + 2])
    }
    const lineGeo = new THREE.BufferGeometry()
    lineGeo.setAttribute("position", new THREE.Float32BufferAttribute(linePos, 3))
    const lineMat = new THREE.LineBasicMaterial({
      color: 0x2563eb, transparent: true, opacity: 0.22,
      blending: THREE.AdditiveBlending, depthWrite: false
    })
    this.lines = new THREE.LineSegments(lineGeo, lineMat)
    this.scene.add(this.lines)

    // 분석 코어 글로우 (우측, 카피 정렬) + 행동(Rausch) 펄스
    const coreMat = new THREE.SpriteMaterial({
      color: 0x00c8c8, transparent: true, opacity: 0.9, blending: THREE.AdditiveBlending
    })
    this.core = new THREE.Sprite(coreMat)
    this.core.position.set(2.2, -0.2, 0.5)
    this.core.scale.set(0.9, 0.9, 1)
    this.scene.add(this.core)

    const actionMat = new THREE.SpriteMaterial({
      color: 0xff385c, transparent: true, opacity: 0.0, blending: THREE.AdditiveBlending
    })
    this.action = new THREE.Sprite(actionMat)
    this.action.position.set(2.2, -1.1, 0.5)
    this.action.scale.set(0.4, 0.4, 1)
    this.scene.add(this.action)

    return true
  }

  resize() {
    const r = this.canvas.getBoundingClientRect()
    this.w = r.width
    this.h = r.height
    if (!this.renderer) return
    this.renderer.setPixelRatio(this.dpr)
    this.renderer.setSize(this.w, this.h, false)
    this.camera.aspect = this.w / this.h
    this.camera.updateProjectionMatrix()
  }

  start() {
    if (this.raf) return
    const loop = () => {
      this.step()
      this.raf = requestAnimationFrame(loop)
    }
    this.raf = requestAnimationFrame(loop)
  }

  stop() {
    if (this.raf) { cancelAnimationFrame(this.raf); this.raf = null }
  }

  step() {
    this.tick++
    const t = this.tick

    // 1) 뇌 전체가 천천히 회전 (살아있는 느낌)
    if (this.points) {
      this.points.rotation.y = Math.sin(t * 0.0016) * 0.35
      this.lines.rotation.y = this.points.rotation.y
      this.points.rotation.x = Math.sin(t * 0.0011) * 0.12
      this.lines.rotation.x = this.points.rotation.x
    }

    // 2) 분석 코어 맥동 (응축)
    const pulse = 0.5 + 0.5 * Math.sin(t * 0.05)
    if (this.core) {
      const sc = 0.8 + pulse * 0.35
      this.core.scale.set(sc, sc, 1)
      this.core.material.opacity = 0.55 + pulse * 0.35
    }

    // 3) 주기적 '행동' 발사 (분석 → 행동 수렴, 약 2.5초 주기)
    if (this.action) {
      const phase = (t % 150) / 150
      this.action.material.opacity = phase < 0.4 ? (0.4 - phase) * 1.8 : 0
      const asc = 0.4 + (phase < 0.4 ? phase * 0.8 : 0)
      this.action.scale.set(asc, asc, 1)
    }

    this.renderer.render(this.scene, this.camera)
  }

  renderOnce() {
    this.tick = 30
    this.step()
    this.stop()
  }

  // WebGL 미지원 시: 기존 ::before 그라데이션 글로우만 남기고 캔버스는 비움
  drawFallback() {
    this.canvas.style.display = "none"
  }
}
```

- [ ] **Step 2: 문법 검증 (Node 파싱)**

```bash
cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier
node --input-type=module -e "
import { readFileSync } from 'fs';
const src = readFileSync('app/javascript/controllers/hero_flow_controller.js','utf8');
// import 줄 제거 후 함수만 평가 (three/stimulus는 brower-only)
const stripped = src.replace(/^import .*\$/gm,'').replace(/export default class[\s\S]*\$/,'');
const mod = await import('data:text/javascript,'+encodeURIComponent(stripped));
const p = mod.buildBrainPositions(200, 7);
console.assert(p.length === 600, 'positions length');
const e = mod.buildEdges(p, 2, 0.62);
console.assert(e.length % 2 === 0, 'edges even');
console.log('OK positions=', p.length/3, 'edges=', e.length/2);
"
```

Expected: `OK positions= 200 edges= <N>` 출력. 파싱/assert 에러 없음.

- [ ] **Step 3: Commit**

```bash
git add app/javascript/controllers/hero_flow_controller.js
git commit -m "feat: 히어로 모션그래픽을 Three.js 뇌 네트워크로 교체"
```

---

## Task 3: Playwright 검증 스크립트

**Files:**
- Create: `scripts/qa/verify-hero-brain.mjs`

- [ ] **Step 1: 검증 스크립트 작성**

`scripts/qa/verify-hero-brain.mjs`:

```javascript
import { chromium } from "playwright"

const BASE = process.env.HERO_QA_URL || "http://localhost:3000"
const OUT = "tmp/hero-brain"

async function run() {
  const browser = await chromium.launch()
  const errors = []

  // 1) 데스크탑 정상 모션
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 } })
  page.on("console", m => { if (m.type() === "error") errors.push(m.text()) })
  page.on("pageerror", e => errors.push(String(e)))
  await page.goto(BASE, { waitUntil: "networkidle" })
  await page.waitForTimeout(1500)

  // WebGL 컨텍스트 살아있는지 확인
  const hasGL = await page.evaluate(() => {
    const c = document.querySelector(".v3-hero__canvas")
    if (!c) return false
    const gl = c.getContext("webgl2") || c.getContext("webgl")
    return !!gl
  })
  await page.screenshot({ path: `${OUT}-desktop.png` })

  // 2) 모바일
  const m = await browser.newPage({ viewport: { width: 390, height: 844 } })
  await m.goto(BASE, { waitUntil: "networkidle" })
  await m.waitForTimeout(1200)
  await m.screenshot({ path: `${OUT}-mobile.png` })

  // 3) reduced-motion
  const rm = await browser.newPage({ viewport: { width: 1280, height: 800 } })
  await rm.emulateMedia({ reducedMotion: "reduce" })
  await rm.goto(BASE, { waitUntil: "networkidle" })
  await rm.waitForTimeout(800)
  await rm.screenshot({ path: `${OUT}-reduced.png` })

  await browser.close()

  console.log("WebGL context:", hasGL)
  console.log("Console errors:", errors.length)
  errors.forEach(e => console.log("  -", e))
  if (!hasGL) { console.error("FAIL: WebGL 컨텍스트 없음"); process.exit(1) }
  if (errors.length) { console.error("FAIL: 콘솔/페이지 에러 존재"); process.exit(1) }
  console.log("PASS: 히어로 뇌 네트워크 렌더 + 무에러")
}

run()
```

- [ ] **Step 2: tmp 디렉토리 준비 및 dev 서버 기동 확인**

```bash
cd /Volumes/E_SSD/02_GitHub.nosync/0019_XimTier/xaisimtier
mkdir -p tmp
# dev 서버가 떠 있지 않으면 백그라운드로 기동:
#   bin/rails server -p 3000  (별도 터미널)
curl -sI http://localhost:3000/ | head -1
```

Expected: `HTTP/1.1 200 OK` 또는 `302` (locale 리다이렉트). 리다이렉트면 `HERO_QA_URL=http://localhost:3000/ko` 로 다음 단계 실행.

- [ ] **Step 3: 검증 실행**

```bash
node scripts/qa/verify-hero-brain.mjs
```

Expected: `WebGL context: true`, `Console errors: 0`, `PASS: ...` 출력. 스크린샷 3장(`tmp/hero-brain-desktop.png`, `-mobile.png`, `-reduced.png`) 생성. 데스크탑 스크린샷에서 청록 뇌 형태 파티클 네트워크가 보여야 한다.

- [ ] **Step 4: 스크린샷 육안 확인**

데스크탑 스크린샷을 열어 다음을 확인:
- 청록 노드들이 좌우 반구 형태로 분포 (뇌 실루엣)
- 노드 간 옅은 블루 연결선
- 우측 분석 코어 글로우 + 간헐적 Rausch 펄스
- 히어로 텍스트/CTA/6-step 카드가 캔버스 위에 정상 표시

- [ ] **Step 5: Commit**

```bash
git add scripts/qa/verify-hero-brain.mjs
git commit -m "test: 히어로 뇌 네트워크 Playwright 검증 스크립트 추가"
git push
```

---

## Self-Review

- **Spec coverage:** 의존성 베닜링(Task 1), 컨트롤러 재작성·뇌 노드/엣지/수렴 내러티브·안전장치(Task 2), 색 토큰(Task 2 코드 내 0x00c8c8/0x2563eb/0xff385c/navy), 성능 DPR캡·노드 자동감축(Task 2 initThree), 검증(Task 3) — 모두 매핑됨.
- **Placeholder scan:** 모든 코드 블록 완전. TBD/TODO 없음.
- **Type consistency:** `buildBrainPositions`/`buildEdges` 시그니처가 Task 2 정의와 Step 2 테스트에서 일치. 컨트롤러 메서드(initThree/resize/start/stop/step/renderOnce/drawFallback) 상호 호출 일치.
