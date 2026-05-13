import { Controller } from "@hotwired/stimulus"

// Fixed left mini-nav scroll-spy
// data-controller="mini-nav"
// data-mini-nav-target="link" + data-section-id="<id>" on each link
export default class extends Controller {
  static targets = ["link"]

  connect() {
    this.onScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.handleScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
  }

  handleScroll() {
    const pos = window.scrollY + window.innerHeight * 0.35
    let active = null
    this.linkTargets.forEach(link => {
      const id = link.dataset.sectionId
      const sec = document.getElementById(id)
      if (sec && sec.offsetTop <= pos) active = link
    })
    this.linkTargets.forEach(l => l.classList.remove("active"))
    if (active) active.classList.add("active")
  }
}
