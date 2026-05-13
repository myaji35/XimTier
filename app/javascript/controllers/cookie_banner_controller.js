import { Controller } from "@hotwired/stimulus"

// Cookie Banner — GDPR-safe minimal consent
// XimTier는 cookieless analytics(Plausible) + 필수 쿠키(Devise session)만 사용
// 따라서 "이해함" 버튼 한 번만 받아 dismiss.
export default class extends Controller {
  static targets = ["banner"]
  STORAGE_KEY = "ximtier.cookie.consent.v1"

  connect() {
    if (localStorage.getItem(this.STORAGE_KEY) === "ack") {
      this.bannerTarget.style.display = "none"
    } else {
      // 첫 방문 — 1초 뒤 슬라이드업 노출
      setTimeout(() => {
        this.bannerTarget.style.transform = "translateY(0)"
        this.bannerTarget.style.opacity = "1"
      }, 1000)
    }
  }

  accept() {
    try { localStorage.setItem(this.STORAGE_KEY, "ack") } catch (_e) {}
    this.bannerTarget.style.transform = "translateY(120%)"
    this.bannerTarget.style.opacity = "0"
    setTimeout(() => { this.bannerTarget.style.display = "none" }, 300)
  }
}
