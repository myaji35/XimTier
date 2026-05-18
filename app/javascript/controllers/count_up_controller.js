import { Controller } from "@hotwired/stimulus"

// CountUp — FR-2 시장 지표 카운트업 애니메이션
// data-controller="count-up" data-count-up-target="value"
// 숫자만 추출해 0 → 목표값 ease-out 보간, 부호/단위(%, B, M, $)는 보존.
// IntersectionObserver로 viewport 진입 시 1회 실행.
// prefers-reduced-motion: reduce 시 모션 OFF — 최종값 즉시 표시.
export default class extends Controller {
  static targets = ["value"]
  static values = {
    duration: { type: Number, default: 1400 }
  }

  connect() {
    // NOTE: `this.targets`는 Stimulus base Controller의 getter-only 속성이므로 인스턴스 변수명을 분리한다.
    this.targetEls = this.valueTargets.length ? this.valueTargets : [this.element]
    this.original = this.targetEls.map(el => el.textContent.trim())
    this.played = false

    if (this.prefersReducedMotion()) return

    this.targetEls.forEach((el, i) => {
      const parsed = this.parse(this.original[i])
      if (parsed) el.textContent = this.format(0, parsed)
    })

    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.played) {
          this.played = true
          this.animateAll()
          this.observer.disconnect()
        }
      })
    }, { threshold: 0.35 })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  prefersReducedMotion() {
    return window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  // "+28.5%" → { sign:"+", number:28.5, suffix:"%", decimals:1 }
  // "$81B"  → { prefix:"$", number:81, suffix:"B", decimals:0 }
  // "85%"   → { number:85, suffix:"%", decimals:0 }
  parse(text) {
    const match = text.match(/^([^\d-]*)(-?)([\d,]+(?:\.\d+)?)(.*)$/)
    if (!match) return null
    const [, prefixRaw, sign, numRaw, suffix] = match
    const number = parseFloat(numRaw.replace(/,/g, ""))
    if (Number.isNaN(number)) return null
    const decimals = (numRaw.split(".")[1] || "").length
    return {
      prefix: prefixRaw.replace("+", ""),
      sign: sign || (prefixRaw.includes("+") ? "+" : ""),
      number,
      suffix,
      decimals
    }
  }

  format(current, p) {
    const fixed = current.toFixed(p.decimals)
    return `${p.prefix}${p.sign}${fixed}${p.suffix}`
  }

  animateAll() {
    const start = performance.now()
    const parsed = this.targetEls.map((el, i) => ({
      el,
      data: this.parse(this.original[i])
    }))

    const tick = now => {
      const elapsed = now - start
      const t = Math.min(1, elapsed / this.durationValue)
      const eased = 1 - Math.pow(1 - t, 3) // easeOutCubic

      parsed.forEach(({ el, data }) => {
        if (!data) return
        const current = data.number * eased
        el.textContent = this.format(current, data)
      })

      if (t < 1) {
        requestAnimationFrame(tick)
      } else {
        parsed.forEach(({ el, data }, i) => {
          el.textContent = this.original[i]
        })
      }
    }

    requestAnimationFrame(tick)
  }
}
