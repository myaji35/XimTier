import { Controller } from "@hotwired/stimulus"

// Reverse What-If — 제조 불량률 시나리오
// _design_ref/demo.jsx Stimulus 포팅
export default class extends Controller {
  static targets = [
    "slider", "targetValue", "improvement",
    "varName", "varFrom", "varArrow", "varTo", "varDelta", "varRow",
    "shapLabel", "shapFill", "shapNum", "shapRow",
    "tabReverse", "tabShap", "panelReverse", "panelShap",
    "accuracy"
  ]

  static values = {
    baselineDefect: { type: Number, default: 2.4 },
    targetDefect:   { type: Number, default: 1.2 }
  }

  // Manufacturing defect-rate scenario — 5 vars
  // coef: 회귀 계수 / weight: SHAP 비중
  VARS = [
    { id: 'temp',  name_ko: '공정 온도', name_en: 'Temperature', unit: '°C',    min: 180, max: 240, base: 215, coef: -0.018, weight: 0.32 },
    { id: 'press', name_ko: '주입 압력', name_en: 'Pressure',    unit: 'MPa',   min: 60,  max: 120, base: 88,  coef:  0.012, weight: 0.21 },
    { id: 'speed', name_ko: '라인 속도', name_en: 'Line speed',  unit: 'm/min', min: 8,   max: 22,  base: 14,  coef:  0.064, weight: 0.28 },
    { id: 'humid', name_ko: '습도',      name_en: 'Humidity',    unit: '%',     min: 35,  max: 75,  base: 52,  coef:  0.022, weight: 0.10 },
    { id: 'grade', name_ko: '원료 등급', name_en: 'Material',    unit: '',      min: 1,   max: 5,   base: 3,   coef: -0.15,  weight: 0.09 },
  ]

  connect() {
    this.update()
  }

  // Slider 변경 시
  changeTarget() {
    this.targetDefectValue = parseFloat(this.sliderTarget.value)
    this.update()
  }

  // 탭 전환
  showReverse() { this.activateTab("reverse") }
  showShap()    { this.activateTab("shap") }

  activateTab(name) {
    const isReverse = name === "reverse"
    this.tabReverseTarget.classList.toggle("active", isReverse)
    this.tabShapTarget.classList.toggle("active", !isReverse)
    this.panelReverseTarget.style.display = isReverse ? "block" : "none"
    this.panelShapTarget.style.display    = isReverse ? "none" : "block"
  }

  // 핵심 — solve + render
  update() {
    const target = this.targetDefectValue
    const baseline = this.baselineDefectValue
    const delta = baseline - target  // positive => want to reduce defects

    this.targetValueTarget.textContent = target.toFixed(2)
    const improvementPct = Math.round((1 - target / baseline) * 100)
    this.improvementTarget.textContent = `${improvementPct >= 0 ? '−' : '+'}${Math.abs(improvementPct)}%`

    // Solve
    const totalAbs = this.VARS.reduce((s, v) => s + Math.abs(v.coef) * v.weight, 0)
    const solved = this.VARS.map(v => {
      const dir = -Math.sign(v.coef) // direction to reduce defects
      const share = (Math.abs(v.coef) * v.weight) / totalAbs
      const range = v.max - v.min
      const move = dir * (delta / 4) * share * range * 4
      let next = v.base + move
      next = Math.max(v.min, Math.min(v.max, next))
      const shap = ((next - v.base) / range) * v.coef * 100
      return { ...v, next, shap }
    })

    // Render Reverse rows
    this.varRowTargets.forEach((row, i) => {
      const v = solved[i]
      const diff = v.next - v.base
      const up = diff > 0
      row.classList.toggle("is-up", up)
      row.classList.toggle("is-down", !up)
      this.varNameTargets[i].textContent = `${v.name_ko}`
      this.varFromTargets[i].textContent = this.fmt(v.base, v.unit)
      this.varToTargets[i].textContent   = this.fmt(v.next, v.unit)
      this.varDeltaTargets[i].textContent = `${up ? '+' : ''}${diff.toFixed(1)}${v.unit && v.unit !== '' ? v.unit : ''}`
    })

    // SHAP — sorted desc by |shap|
    const shapSorted = [...solved].sort((a, b) => Math.abs(b.shap) - Math.abs(a.shap))
    const maxShap = Math.max(...shapSorted.map(s => Math.abs(s.shap)), 0.001)

    this.shapRowTargets.forEach((row, i) => {
      const v = shapSorted[i]
      const pct = (Math.abs(v.shap) / maxShap) * 50
      const isNeg = v.shap < 0
      this.shapLabelTargets[i].textContent = v.name_ko
      this.shapNumTargets[i].textContent   = `${v.shap > 0 ? '+' : ''}${v.shap.toFixed(2)}`
      const fill = this.shapFillTargets[i]
      fill.style.width = `${pct}%`
      fill.style.left  = isNeg ? `${50 - pct}%` : '50%'
      fill.classList.toggle("is-neg", isNeg)
    })
  }

  fmt(v, unit) {
    if (unit === '') return v.toFixed(1)
    if (unit === '%' || unit === 'MPa' || unit === '°C') return v.toFixed(1) + unit
    return v.toFixed(1) + ' ' + unit
  }
}
