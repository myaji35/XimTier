import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"]
  static values = { share: String, done: String }

  async copy() {
    await navigator.clipboard.writeText(location.href)
    this.labelTarget.textContent = this.doneValue

    clearTimeout(this.resetTimer)
    this.resetTimer = setTimeout(() => {
      this.labelTarget.textContent = this.shareValue
    }, 2000)
  }

  disconnect() {
    clearTimeout(this.resetTimer)
  }
}
