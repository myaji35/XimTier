import { Controller } from "@hotwired/stimulus"

// Market scenario toggle — Bull / Base / Worst
export default class extends Controller {
  static targets = ["tab", "value", "formula", "body", "share"]
  static values = {
    bull:  Object,
    base:  Object,
    worst: Object
  }

  switch(event) {
    const which = event.currentTarget.dataset.scenario
    const data = this[`${which}Value`]
    if (!data || !data.value) return

    this.valueTarget.textContent   = data.value
    this.formulaTarget.textContent = data.formula
    this.bodyTarget.textContent    = data.body
    this.shareTarget.querySelector("span:last-child").textContent = data.share

    this.tabTargets.forEach(t => {
      t.classList.toggle("is-active", t.dataset.scenario === which)
    })
  }
}
