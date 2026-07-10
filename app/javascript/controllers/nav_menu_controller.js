import { Controller } from "@hotwired/stimulus"

// 모바일 헤더 햄버거 메뉴 토글
export default class extends Controller {
  static targets = ["panel"]

  toggle() {
    this.panelTarget.classList.toggle("hidden")
  }

  // 링크 클릭·Turbo 이동 시 패널 닫기
  connect() {
    this.close = () => this.panelTarget.classList.add("hidden")
    document.addEventListener("turbo:visit", this.close)
  }

  disconnect() {
    document.removeEventListener("turbo:visit", this.close)
  }
}
