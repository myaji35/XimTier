import { Controller } from "@hotwired/stimulus"

// Reveal — 스크롤 인뷰 stagger 연출 (홈 섹션 공통)
// data-controller="reveal" 컨테이너 + 자식 data-reveal-target="item"
// viewport 진입 시 각 item에 .is-in 부여(index * stagger 지연) → fade-up.
// data-reveal-stagger-value(ms, 기본 80), data-reveal-once-value(기본 true).
// IntersectionObserver(threshold 0.2)로 1회 실행.
// prefers-reduced-motion: reduce 시 모션 OFF — 즉시 전체 표시.
export default class extends Controller {
  static targets = ["item"]
  static values = {
    stagger: { type: Number, default: 80 },
    baseDelay: { type: Number, default: 0 },
    once: { type: Boolean, default: true }
  }

  connect() {
    this.items = this.itemTargets.length ? this.itemTargets : [this.element]

    if (this.prefersReducedMotion()) {
      this.items.forEach(el => el.classList.add("is-in"))
      return
    }

    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.reveal()
          if (this.onceValue) this.observer.disconnect()
        }
      })
    }, { threshold: 0.2 })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  prefersReducedMotion() {
    return window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  reveal() {
    this.items.forEach((el, i) => {
      el.style.transitionDelay = `${this.baseDelayValue + i * this.staggerValue}ms`
      el.classList.add("is-in")
    })
  }
}
