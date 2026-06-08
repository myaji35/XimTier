import { Controller } from "@hotwired/stimulus"

// HeroFlow — 히어로 배경 "데이터 → 분석 → 행동 수렴" 모션그래픽 (지속 루프)
// 카피 "AI가 분석하고, XimTier는 행동을 결정합니다 / 데이터·AGI·에이전트·로봇을 연결"의 시각화.
// 데이터 입자가 사방에서 흘러 들어와 '분석 코어'로 빨려들고,
// 코어가 응축한 신호가 하나의 '행동(Action) 타겟'(Rausch)으로 수렴·발사한다.
// canvas 2D. 기존 색 토큰만 사용. prefers-reduced-motion / 탭 비활성 시 정지.
// brand-dna.json design_tokens.motion.hero_motion_exception 으로 히어로 한정 허용.
export default class extends Controller {
  static targets = ["canvas"]

  connect() {
    this.canvas = this.hasCanvasTarget ? this.canvasTarget : this.element
    this.ctx = this.canvas.getContext("2d")
    this.dpr = Math.min(window.devicePixelRatio || 1, 2)
    this.particles = []
    this.signals = []
    this.tick = 0

    this.resize()
    this._onResize = () => this.resize()
    window.addEventListener("resize", this._onResize)

    if (this.prefersReducedMotion()) {
      this.seed(true)
      this.drawStaticFrame()
      return
    }

    this.seed(false)
    this._onVisibility = () => {
      if (document.hidden) this.stop()
      else this.start()
    }
    document.addEventListener("visibilitychange", this._onVisibility)
    this.start()
  }

  disconnect() {
    this.stop()
    window.removeEventListener("resize", this._onResize)
    if (this._onVisibility) document.removeEventListener("visibilitychange", this._onVisibility)
  }

  prefersReducedMotion() {
    return window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  // ── 좌표 / 색 ──────────────────────────────────────────────
  resize() {
    const r = this.canvas.getBoundingClientRect()
    this.w = r.width
    this.h = r.height
    this.canvas.width = this.w * this.dpr
    this.canvas.height = this.h * this.dpr
    this.ctx.setTransform(this.dpr, 0, 0, this.dpr, 0, 0)
    // 분석 코어: 우상단 (그라데이션 글로우와 정렬)
    this.core = { x: this.w * 0.74, y: this.h * 0.42 }
    // 행동 타겟: 코어 아래쪽으로 수렴 발사 지점
    this.target = { x: this.w * 0.74, y: this.h * 0.72 }
  }

  colors() {
    return ["rgba(0,200,200,", "rgba(37,99,235,", "rgba(120,180,255,"]
  }

  rand(a, b) { return a + (this.tick * 9301 + this.particles.length * 49297) % 233280 / 233280 * (b - a) }

  seed(reduced) {
    const n = reduced ? 26 : Math.round(Math.min(64, this.w / 16))
    const cols = this.colors()
    for (let i = 0; i < n; i++) {
      this.particles.push(this.makeParticle(cols, i, reduced))
    }
  }

  makeParticle(cols, i, fixed) {
    // 화면 가장자리 어딘가에서 출발 → 코어로 향함
    const edge = (i * 0.137) % 1
    const px = edge < 0.5 ? this.w * (edge * 1.6) : this.w * (edge - 0.3)
    const py = i % 2 === 0 ? this.h * ((i % 7) / 7) : this.h * (0.2 + (i % 5) / 7)
    return {
      x: px, y: py,
      sx: px, sy: py,
      c: cols[i % cols.length],
      r: 1 + (i % 3) * 0.7,
      // 0→1 진행도. 코어 도달 후 리셋. fixed면 중간값 고정(정적 프레임용)
      t: fixed ? (i % 10) / 10 : (i % 10) / 10,
      speed: 0.0016 + (i % 5) * 0.0006,
      drift: (i % 2 ? 1 : -1) * (8 + (i % 4) * 6)
    }
  }

  // ── 루프 ───────────────────────────────────────────────────
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
    const ctx = this.ctx
    ctx.clearRect(0, 0, this.w, this.h)

    // 1) 입자: 출발점 → 코어로 곡선 수렴 (데이터가 분석으로 빨려듦)
    for (const p of this.particles) {
      p.t += p.speed
      if (p.t >= 1) {
        // 코어 도달 → 신호 발생(행동 타겟으로 발사) + 입자 리셋
        if (this.signals.length < 40) this.spawnSignal()
        p.t = 0
        p.x = p.sx; p.y = p.sy
        continue
      }
      const ease = p.t * p.t * (3 - 2 * p.t)
      // 곡선: 출발 → 코어, 약간의 drift로 흐르는 느낌
      const cx = (p.sx + this.core.x) / 2 + p.drift
      const cy = (p.sy + this.core.y) / 2 - p.drift
      const mt = 1 - ease
      p.x = mt * mt * p.sx + 2 * mt * ease * cx + ease * ease * this.core.x
      p.y = mt * mt * p.sy + 2 * mt * ease * cy + ease * ease * this.core.y

      const alpha = 0.12 + ease * 0.5
      ctx.beginPath()
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2)
      ctx.fillStyle = p.c + alpha + ")"
      ctx.fill()
      // 코어 근처 연결선(분석으로 합류)
      if (ease > 0.55) {
        ctx.beginPath()
        ctx.moveTo(p.x, p.y)
        ctx.lineTo(this.core.x, this.core.y)
        ctx.strokeStyle = p.c + (ease - 0.55) * 0.4 + ")"
        ctx.lineWidth = 0.6
        ctx.stroke()
      }
    }

    // 2) 분석 코어: 맥동하는 빛 (응축)
    const pulse = 0.5 + 0.5 * Math.sin(this.tick * 0.05)
    const coreR = 6 + pulse * 4
    const g = ctx.createRadialGradient(this.core.x, this.core.y, 0, this.core.x, this.core.y, coreR * 3)
    g.addColorStop(0, "rgba(0,200,200," + (0.5 + pulse * 0.3) + ")")
    g.addColorStop(1, "rgba(0,200,200,0)")
    ctx.fillStyle = g
    ctx.beginPath()
    ctx.arc(this.core.x, this.core.y, coreR * 3, 0, Math.PI * 2)
    ctx.fill()

    // 3) 신호: 코어 → 행동 타겟으로 발사 (분석 결과가 '행동'으로 수렴)
    for (let i = this.signals.length - 1; i >= 0; i--) {
      const s = this.signals[i]
      s.t += 0.022
      if (s.t >= 1) { this.signals.splice(i, 1); this.targetHit = this.tick; continue }
      const e = s.t * s.t
      const x = this.core.x + (this.target.x - this.core.x) * e
      const y = this.core.y + (this.target.y - this.core.y) * e
      ctx.beginPath()
      ctx.moveTo(x, y)
      ctx.lineTo(this.core.x + (this.target.x - this.core.x) * (e - 0.06), this.core.y + (this.target.y - this.core.y) * (e - 0.06))
      ctx.strokeStyle = "rgba(255,56,92," + (0.7 - s.t * 0.4) + ")"
      ctx.lineWidth = 1.6
      ctx.stroke()
    }

    // 4) 행동 타겟: 신호 도달 시 Rausch 링이 퍼짐 ("행동 결정")
    const since = this.tick - (this.targetHit || -999)
    if (since < 40) {
      const tr = since / 40
      ctx.beginPath()
      ctx.arc(this.target.x, this.target.y, 4 + tr * 22, 0, Math.PI * 2)
      ctx.strokeStyle = "rgba(255,56,92," + (0.55 * (1 - tr)) + ")"
      ctx.lineWidth = 1.5
      ctx.stroke()
    }
    // 타겟 코어 점
    ctx.beginPath()
    ctx.arc(this.target.x, this.target.y, 3.2, 0, Math.PI * 2)
    ctx.fillStyle = "rgba(255,56,92,0.9)"
    ctx.fill()
  }

  spawnSignal() {
    this.signals.push({ t: 0 })
  }

  drawStaticFrame() {
    // reduced-motion: 한 프레임만 그려 정적 다이어그램처럼 보이게
    this.tick = 30
    this.step()
    this.stop()
  }
}
