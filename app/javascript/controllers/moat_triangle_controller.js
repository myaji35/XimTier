import { Controller } from "@hotwired/stimulus"

// XIM-12 — 해자 삼각형 인터랙티브
// vertex/card 양방향 동기화, 스크롤 reveal 1회, 키보드 ←/→ 순환, reduce-motion 존중.
// 외부 의존 0, Stimulus 만 사용.
export default class extends Controller {
  static targets = ["vertex", "card", "line", "disc"]
  static values = {
    activeKey: { type: String,  default: "" },
    revealed:  { type: Boolean, default: false }
  }

  // line의 data-pair는 두 vertex key를 "-"로 연결: "sovereignty-reverse" 등
  // hover된 vertex와 연결된 line만 emphasis 처리할 때 사용.

  connect() {
    this.reduceMotion = window.matchMedia &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches

    this._setupReveal()
  }

  disconnect() {
    if (this._io) this._io.disconnect()
  }

  // ── Actions ─────────────────────────────────────────────────────────
  highlight(event) {
    const key = event.currentTarget.dataset.key
    if (!key) return
    this.activeKeyValue = key
    this._applyActive(key)
  }

  release(_event) {
    // hover/blur 해제 — focus가 다른 vertex/card로 옮겨가는 경우는
    // 다음 highlight가 곧장 덮어쓰므로, 단순 비우기만으로 충분
    this.activeKeyValue = ""
    this._applyActive("")
  }

  toggle(event) {
    event.preventDefault()
    const key = event.currentTarget.dataset.key
    if (!key) return
    if (this.activeKeyValue === key) {
      this.activeKeyValue = ""
      this._applyActive("")
    } else {
      this.activeKeyValue = key
      this._applyActive(key)
    }
  }

  navigate(event) {
    // ←/→ 키 — vertex 사이 순환 포커스
    const order = ["sovereignty", "reverse", "regulated"]
    const currentKey = event.currentTarget.dataset.key
    const idx = order.indexOf(currentKey)
    if (idx === -1) return

    let nextIdx
    if (event.key === "ArrowRight") nextIdx = (idx + 1) % order.length
    else if (event.key === "ArrowLeft") nextIdx = (idx - 1 + order.length) % order.length
    else return

    event.preventDefault()
    const nextKey = order[nextIdx]
    const nextVertex = this.vertexTargets.find(v => v.dataset.key === nextKey)
    if (nextVertex) nextVertex.focus()
  }

  // ── 내부 ────────────────────────────────────────────────────────────
  _applyActive(key) {
    // vertex: data-active 토글
    this.vertexTargets.forEach(v => {
      if (key && v.dataset.key === key) v.dataset.active = "true"
      else delete v.dataset.active
    })
    // card: 같은 인덱스 동기화
    this.cardTargets.forEach(c => {
      if (key && c.dataset.key === key) c.dataset.active = "true"
      else delete c.dataset.active
    })
    // line: 해당 vertex를 끝점으로 갖는 2개만 active, 나머지 1개는 muted
    this.lineTargets.forEach(l => {
      const pair = (l.dataset.pair || "").split("-")
      if (!key) {
        delete l.dataset.active
        delete l.dataset.muted
      } else if (pair.includes(key)) {
        l.dataset.active = "true"
        delete l.dataset.muted
      } else {
        l.dataset.muted = "true"
        delete l.dataset.active
      }
    })
  }

  _setupReveal() {
    if (this.revealedValue) return
    if (this.reduceMotion) {
      // 모션 없이 즉시 reveal 상태로 둔다 (CSS가 stroke-dashoffset 0 처리)
      this.revealedValue = true
      this.element.dataset.revealed = "true"
      return
    }
    this._io = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (e.isIntersecting && e.intersectionRatio >= 0.5) {
          this.revealedValue = true
          this.element.dataset.revealed = "true"
          this._io.disconnect()
        }
      })
    }, { threshold: [0, 0.5, 1] })
    this._io.observe(this.element)
  }
}
