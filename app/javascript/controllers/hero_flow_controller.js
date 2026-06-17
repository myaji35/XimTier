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
