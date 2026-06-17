import { chromium } from "playwright"

const BASE = process.env.HERO_QA_URL || "http://localhost:3000"
const OUT = "tmp/hero-brain"

async function run() {
  const browser = await chromium.launch()
  const errors = []

  // 1) 데스크탑 정상 모션
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 } })
  page.on("console", m => { if (m.type() === "error") errors.push(m.text()) })
  page.on("pageerror", e => errors.push(String(e)))
  await page.goto(BASE, { waitUntil: "networkidle" })
  await page.waitForTimeout(1500)

  // WebGL 컨텍스트 살아있는지 확인
  const hasGL = await page.evaluate(() => {
    const c = document.querySelector(".v3-hero__canvas")
    if (!c) return false
    const gl = c.getContext("webgl2") || c.getContext("webgl")
    return !!gl
  })
  await page.screenshot({ path: `${OUT}-desktop.png` })

  // 2) 모바일
  const m = await browser.newPage({ viewport: { width: 390, height: 844 } })
  await m.goto(BASE, { waitUntil: "networkidle" })
  await m.waitForTimeout(1200)
  await m.screenshot({ path: `${OUT}-mobile.png` })

  // 3) reduced-motion
  const rm = await browser.newPage({ viewport: { width: 1280, height: 800 } })
  await rm.emulateMedia({ reducedMotion: "reduce" })
  await rm.goto(BASE, { waitUntil: "networkidle" })
  await rm.waitForTimeout(800)
  await rm.screenshot({ path: `${OUT}-reduced.png` })

  await browser.close()

  console.log("WebGL context:", hasGL)
  console.log("Console errors:", errors.length)
  errors.forEach(e => console.log("  -", e))
  if (!hasGL) { console.error("FAIL: WebGL 컨텍스트 없음"); process.exit(1) }
  if (errors.length) { console.error("FAIL: 콘솔/페이지 에러 존재"); process.exit(1) }
  console.log("PASS: 히어로 뇌 네트워크 렌더 + 무에러")
}

run()
