# 히어로 뇌 네트워크 모션그래픽 (Three.js/WebGL)

날짜: 2026-06-17
대상: `app/views/pages/home.html.erb` 히어로 블럭 (`v3-hero`)
상태: 승인됨 (대표님 2026-06-17)

## 목적

히어로 배경의 기존 2D Canvas 모션그래픽(`hero_flow_controller.js`)을, 첨부 이미지의 "청록색 뇌 형태 파티클 네트워크" 비주얼을 가진 Three.js/WebGL 버전으로 교체한다. XimTier의 핵심 내러티브("데이터 → 분석 코어 → 행동 수렴")는 보존하고 비주얼만 업그레이드한다.

## 결정 사항 (브레인스토밍)

| 항목 | 결정 |
|---|---|
| 구현 기술 | Three.js / WebGL |
| 적용 페이지 | `home.html.erb` (메인 히어로, `v3-hero` 다크 네이비) |
| 의존성 도입 | `vendor/javascript`에 `three.module.js` 베닜링 + importmap pin (CDN 미사용) |
| 모션 컨셉 | 뇌 형태 파티클 네트워크 + 기존 수렴 내러티브 **융합** |

## 아키텍처

```
home.html.erb  (canvas + data-controller="hero-flow" 유지, 변경 최소)
  └─ hero_flow_controller.js  (Three.js 버전으로 재작성, 인터페이스 동일)
       └─ import * as THREE from "three"  (vendor 베닜링)
```

기존 컨트롤러 이름(`hero-flow`)·타깃(`canvas`)·라이프사이클(connect/disconnect/resize/start/stop)을 유지하므로 ERB 변경은 사실상 없다.

## 컴포넌트

### (a) 의존성
- `vendor/javascript/three.module.js` — Three.js 베닜링 (r150+ ESM 단일 파일)
- `config/importmap.rb` — `pin "three", to: "three.module.js"` 추가

### (b) hero_flow_controller.js (재작성)
분리된 단위:
- **씬 셋업**: Scene / 카메라 / `WebGLRenderer({ alpha: true, antialias: true })` — 다크 네이비 위 합성
- **뇌 노드**: 좌우 반구 뇌 실루엣을 따라 노드 좌표 ~400–600개 생성 → 단일 `THREE.Points`
- **엣지**: 인접 노드 쌍 연결 → 단일 `THREE.LineSegments`, teal→blue 그라데이션 색
- **수렴 내러티브**: 노드 일부가 주기적으로 '분석 코어'로 점화·수렴 → Rausch '행동' 펄스 발사 (기존 의미 보존)
- **라이프사이클**: `connect` / `disconnect` / `resize` / `start` / `stop` — 기존과 동일 시그니처

### (c) 안전장치 (기존 유지)
- `prefers-reduced-motion` → 정적 한 프레임만 렌더 후 정지
- `visibilitychange` → 탭 숨김 시 `requestAnimationFrame` 정지
- WebGL 미지원 시 → 정적 배경 폴백 (그라데이션 글로우만)

## 색 / 토큰 (brand-dna v3 히어로 토큰만)
- teal `#00c8c8`, blue `#2563eb`, light-blue `#78b4ff`
- 행동(Action) Rausch `#ff385c`
- 배경 navy `#0a1124`
- 그라데이션은 brand-dna 모션 예외(`hero_motion_exception`)로 히어로 한정 허용

## 성능
- 드로우콜 2–3개 (Points 1 + LineSegments 1 + 코어 글로우)
- DPR 캡 `min(devicePixelRatio, 2)`
- 화면 폭 기반 노드 수 자동 감축 (모바일)

## 검증 (캐릭터 저니 + UI 조작)
- Playwright로 `/` 로드 → 히어로 캔버스 렌더 스크린샷 (데스크탑 / 모바일)
- `prefers-reduced-motion` 모드 스크린샷
- 콘솔 에러 0 / WebGL 컨텍스트 정상 확인
- 기존 히어로 텍스트·CTA·6-step workflow가 캔버스 위에 정상 표시되는지 확인

## 비범위 (YAGNI)
- 순수 뇌 네트워크(내러티브 없는) 별도 버전은 만들지 않는다 (융합형 1개만)
- 다른 페이지(v3_overview 등) 히어로는 이번 범위 외
