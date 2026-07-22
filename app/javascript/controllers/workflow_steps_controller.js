import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "arrow"]
  static values = {
    activeKey: { type: String, default: "" },
    revealed: { type: Boolean, default: false },
    reduceMotion: { type: Boolean, default: false }
  }
  static classes = ["active", "muted", "revealed"]

  connect() {
    this.motionQuery = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.mobileQuery = window.matchMedia("(max-width: 979px)")
    this.reduceMotionValue = this.motionQuery.matches
    this.expandedKey = ""
    this._rememberStyles()
    this._applyActive("")
    this._prepareReveal()
    this._syncDescriptions()
    this._startCorePulse()

    this._motionChange = event => this._handleMotionChange(event)
    this._mobileChange = () => this._syncDescriptions()
    this.motionQuery.addEventListener?.("change", this._motionChange)
    this.mobileQuery.addEventListener?.("change", this._mobileChange)

    if (this.reduceMotionValue || !("IntersectionObserver" in window)) {
      this._reveal()
      return
    }

    this.observer = new IntersectionObserver(entries => {
      if (entries.some(entry => entry.isIntersecting && entry.intersectionRatio >= 0.4)) this._reveal()
    }, { threshold: 0.4 })
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
    this.motionQuery?.removeEventListener?.("change", this._motionChange)
    this.mobileQuery?.removeEventListener?.("change", this._mobileChange)
    this.coreAnimation?.cancel()
  }

  highlight(event) {
    if (event.type === "mouseenter" && this.mobileQuery.matches) return
    const key = event.currentTarget.dataset.key
    if (key) this._applyActive(key)
  }

  release() {
    if (this.mobileQuery.matches && this.expandedKey) return
    requestAnimationFrame(() => {
      const engaged = this.cardTargets.find(card => card.matches(":hover, :focus"))
      this._applyActive(engaged?.dataset.key || "")
    })
  }

  toggle(event) {
    if (event.type === "click" && !this.mobileQuery.matches) return
    event.preventDefault()
    const key = event.currentTarget.dataset.key
    if (!key) return

    const willOpen = this.activeKeyValue !== key || this.expandedKey !== key
    this.expandedKey = this.mobileQuery.matches && willOpen ? key : ""
    this._applyActive(willOpen ? key : "")
    this._syncDescriptions()
  }

  navigate(event) {
    const currentIndex = this.cardTargets.indexOf(event.currentTarget)
    if (currentIndex < 0) return

    let nextIndex
    if (event.key === "ArrowRight") nextIndex = (currentIndex + 1) % this.cardTargets.length
    else if (event.key === "ArrowLeft") nextIndex = (currentIndex - 1 + this.cardTargets.length) % this.cardTargets.length
    else if (event.key === "Home") nextIndex = 0
    else if (event.key === "End") nextIndex = this.cardTargets.length - 1
    else return

    event.preventDefault()
    this.cardTargets[nextIndex].focus()
  }

  _applyActive(key) {
    this.activeKeyValue = key || ""
    const activeIndex = this.cardTargets.findIndex(card => card.dataset.key === key)

    this.cardTargets.forEach((card, index) => {
      const active = activeIndex >= 0 && index === activeIndex
      const muted = activeIndex >= 0 && !active
      card.toggleAttribute("data-active", active)
      card.toggleAttribute("data-muted", muted)
      card.style.opacity = muted ? "0.6" : "1"
      card.style.transform = active ? "translateY(-4px)" : "translateY(0)"
      card.style.boxShadow = active
        ? "var(--shadow-airbnb-card-hover, 0 16px 40px -16px rgba(34,34,34,0.18))"
        : card.dataset.workflowBaseShadow

      const sub = card.querySelector("[data-workflow-sub]")
      if (sub) sub.style.color = active ? "var(--color-rausch, #ff385c)" : sub.dataset.workflowBaseColor
    })

    this.arrowTargets.forEach((arrow, index) => {
      const adjacent = activeIndex >= 0 && (index === activeIndex || index === activeIndex - 1)
      arrow.toggleAttribute("data-active", adjacent)
      arrow.style.color = adjacent ? "var(--color-rausch, #ff385c)" : arrow.dataset.workflowBaseColor
      arrow.style.transform = `translateY(-50%)${adjacent ? " translateX(4px)" : ""}`
    })

    if (this.coreAnimation) key ? this.coreAnimation.pause() : this.coreAnimation.play()
  }

  _reveal() {
    if (this.revealedValue) return
    this.revealedValue = true
    this.element.dataset.revealed = "true"
    this.observer?.disconnect()

    this.cardTargets.forEach((card, index) => {
      card.style.transitionDelay = this.reduceMotionValue ? "0ms" : `${index * 80}ms`
      card.style.opacity = "1"
      card.style.transform = "translateY(0)"
    })
  }

  _rememberStyles() {
    this.cardTargets.forEach(card => {
      card.dataset.workflowBaseShadow = card.style.boxShadow || ""
      const sub = card.querySelector("[data-workflow-sub]")
      if (sub) sub.dataset.workflowBaseColor = sub.style.color || ""
    })
    this.arrowTargets.forEach(arrow => { arrow.dataset.workflowBaseColor = arrow.style.color || "" })
  }

  _prepareReveal() {
    const duration = this.reduceMotionValue ? "0ms" : "220ms"
    this.cardTargets.forEach(card => {
      card.style.transition = `opacity 180ms ease-out, transform ${duration} ease-out, box-shadow ${duration} ease-out, border-color ${duration} ease-out`
      card.style.outline = "none"
      card.addEventListener("focus", this._focusOutline = this._focusOutline || (event => {
        if (event.currentTarget.matches(":focus-visible")) {
          event.currentTarget.style.outline = "2px solid #ff385c"
          event.currentTarget.style.outlineOffset = "3px"
        }
      }))
      card.addEventListener("blur", this._blurOutline = this._blurOutline || (event => { event.currentTarget.style.outline = "none" }))
      if (!this.reduceMotionValue) {
        card.style.opacity = "0"
        card.style.transform = "translateY(12px)"
      }
    })
    this.arrowTargets.forEach(arrow => { arrow.style.transition = `color 180ms ease-out, transform 180ms ease-out` })
  }

  _syncDescriptions() {
    this.cardTargets.forEach(card => {
      const desc = card.querySelector("[data-workflow-desc]")
      if (!desc) return
      const expanded = !this.mobileQuery.matches || card.dataset.key === this.expandedKey
      desc.hidden = !expanded
      card.setAttribute("aria-expanded", String(expanded))
    })
  }

  _startCorePulse() {
    const core = this.cardTargets.find(card => card.dataset.core === "true")
    if (!core || this.reduceMotionValue || !core.animate) return
    this.coreAnimation?.cancel()
    this.coreAnimation = core.animate([
      { boxShadow: "0 8px 32px -12px rgba(255,56,92,0.28)" },
      { boxShadow: "0 10px 36px -10px rgba(255,56,92,0.48)" },
      { boxShadow: "0 8px 32px -12px rgba(255,56,92,0.28)" }
    ], { duration: 2400, iterations: Infinity, easing: "ease-in-out" })
  }

  _handleMotionChange(event) {
    this.reduceMotionValue = event.matches
    this.coreAnimation?.cancel()
    this.cardTargets.forEach(card => { card.style.transitionDuration = event.matches ? "0ms" : "" })
    this.arrowTargets.forEach(arrow => { arrow.style.transitionDuration = event.matches ? "0ms" : "" })
    if (!event.matches) this._startCorePulse()
    if (event.matches) this._reveal()
  }
}
