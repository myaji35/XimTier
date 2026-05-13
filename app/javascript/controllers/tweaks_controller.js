import { Controller } from "@hotwired/stimulus"

// Tweaks Panel — 우하단 floating UI
// design.md §7 — 4 옵션 토글 + localStorage 영속화
export default class extends Controller {
  static targets = ["panel", "trigger"]

  STORAGE_KEY = "ximtier.tweaks.v1"
  DEFAULTS = {
    accent:   "default",   // default | electric | mono
    chips:    "on",        // on | off
    spacing:  "default",   // default | compact
    section:  "default"    // default | all-light
  }

  connect() {
    this.state = this.load()
    this.apply()
  }

  load() {
    try {
      const raw = localStorage.getItem(this.STORAGE_KEY)
      if (raw) return { ...this.DEFAULTS, ...JSON.parse(raw) }
    } catch (_e) {}
    return { ...this.DEFAULTS }
  }

  save() {
    try { localStorage.setItem(this.STORAGE_KEY, JSON.stringify(this.state)) } catch (_e) {}
  }

  apply() {
    document.body.dataset.tweakAccent  = this.state.accent
    document.body.dataset.tweakChips   = this.state.chips
    document.body.dataset.tweakSpacing = this.state.spacing
    document.body.dataset.tweakSection = this.state.section
    this.syncRadios()
  }

  toggle() {
    this.panelTarget.classList.toggle("is-open")
  }

  change(event) {
    const { name, value } = event.target
    this.state[name] = value
    this.save()
    this.apply()
  }

  reset() {
    this.state = { ...this.DEFAULTS }
    this.save()
    this.apply()
  }

  syncRadios() {
    this.element.querySelectorAll("input[type=radio]").forEach(input => {
      input.checked = (this.state[input.name] === input.value)
    })
  }
}
