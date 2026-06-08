import { Controller } from "@hotwired/stimulus"

// Converge — 히어로 6-step "데이터 → 행동 결정" 수렴 연출
// data-controller="converge" 컨테이너 + 자식 data-converge-target="step"
// 진입 시 step들이 좌→우 stagger 등장 → 마지막 step(실행 가이드)에 voltage 펄스 1회.
// 카피 "AI가 분석하고, XimTier는 행동을 결정합니다"의 시각화.
// prefers-reduced-motion: reduce 시 모션 OFF — 즉시 전체 표시.
export default class extends Controller {
  static targets = ["step"]
  static values = {
    stagger: { type: Number, default: 140 },
    baseDelay: { type: Number, default: 0 }
  }

  connect() {
    this.steps = this.stepTargets
    if (!this.steps.length) return

    if (this.prefersReducedMotion()) {
      this.steps.forEach(el => el.classList.add("is-in"))
      return
    }

    this.played = false
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.played) {
          this.played = true
          this.run()
          this.observer.disconnect()
        }
      })
    }, { threshold: 0.3 })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
    if (this.timer) clearTimeout(this.timer)
  }

  prefersReducedMotion() {
    return window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  run() {
    this.steps.forEach((el, i) => {
      el.style.transitionDelay = `${this.baseDelayValue + i * this.staggerValue}ms`
      el.classList.add("is-in")
    })

    // 모든 step 등장 후 마지막(행동 결정) step에 voltage 펄스
    const last = this.steps[this.steps.length - 1]
    const delay = this.baseDelayValue + this.steps.length * this.staggerValue + 300
    this.timer = setTimeout(() => last.classList.add("is-pulse"), delay)
  }
}
