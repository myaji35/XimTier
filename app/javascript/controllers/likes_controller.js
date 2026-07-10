import { Controller } from "@hotwired/stimulus"

// 익명 좋아요 토글 — 서버에 POST, 응답으로 카운트/상태 갱신
export default class extends Controller {
  static targets = ["button", "label", "count"]
  static values = { url: String, liked: Boolean }

  async toggle() {
    this.buttonTarget.disabled = true
    try {
      const res = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "",
          "Accept": "application/json"
        }
      })
      if (!res.ok) throw new Error("like failed")
      const data = await res.json()
      this.likedValue = data.liked
      this.countTargets.forEach((el) => (el.textContent = data.likes_count))
      this.#render()
    } catch (e) {
      console.error("[likes]", e)
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  #render() {
    const liked = this.likedValue
    this.labelTarget.textContent = liked ? "좋아요 취소" : "좋아요"
    if (liked) {
      this.buttonTarget.style.background = "var(--color-rausch)"
      this.buttonTarget.style.color = "#fff"
      this.buttonTarget.style.border = "1px solid var(--color-rausch)"
    } else {
      this.buttonTarget.style.background = "transparent"
      this.buttonTarget.style.color = "var(--color-rausch)"
      this.buttonTarget.style.border = "1px solid var(--color-rausch)"
    }
  }
}
