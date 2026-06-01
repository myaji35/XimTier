module DeckHelper
  # slug => { title:, chapter:, lead:, slides: [n,...], sections: [{h:, body:}] }
  DECK_DETAILS = {
    "data-exploration" => {
      title: "데이터 탐색", chapter: "02 데이터 탐색", slides: [23],
      lead: "사용자 로딩 데이터의 주요 필드와 필드별 기초 통계, 기술 통계와 상관관계 히트맵을 지원합니다.",
      sections: [
        { h: "① 로딩 데이터 기본 정보", body: "로딩된 데이터의 주요 필드와 데이터 구조를 한눈에 파악합니다." },
        { h: "② 기술통계와 상관관계 분석", body: "필드별 기초·기술 통계와 필드 간 상관관계 히트맵으로 관계를 분석합니다. 원스톱 데이터 구조·관계 분석 지원." }
      ]
    },
    "whatdata-ai" => {
      title: "WhatDataAI 분석", chapter: "02 데이터 탐색", slides: [24],
      lead: "입력 데이터의 필드를 분석하여 활용 가능한 AI 알고리즘(회귀·판별·다중분류·시계열)과 Y·X 변수를 자동 추천합니다.",
      sections: [
        { h: "① AI 알고리즘별 활용 가능 데이터 진단", body: "우리 데이터로 무엇을 할 수 있는지, 어떤 데이터가 중요한지 자동 진단합니다." },
        { h: "② 활용 가능 알고리즘과 데이터 — AI 종합 분석", body: "신규 비즈니스 창출 기회 확보, 예산절감, 수익 창출로 연결합니다." }
      ]
    },
    "address-xy" => {
      title: "주소 XY 정제", chapter: "02 데이터 탐색", slides: [25],
      lead: "주소 필드를 기반으로 카카오 API + 내부 학습 주소 기반의 위경도 좌표 및 행정구역 표준 파싱을 지원합니다.",
      sections: [
        { h: "① 주소 필드 자동 인식 기반의 주소 정제", body: "주소 필드를 자동 인식하여 정제를 실시합니다." },
        { h: "② 주소정제 결과", body: "위경도 좌표와 표준 행정지역명 도출 자동화로 주제도·차트 분석 전처리 시간을 축소합니다." }
      ]
    },
    "explore-chart" => {
      title: "AI 탐색 차트", chapter: "02 데이터 탐색", slides: [26, 27],
      lead: "개별 차트(기본형·분포통계·관계분석·고급시각화·워드클라우드 약 24종)와 X·Y·Z축 자동 차트 22종을 지원합니다.",
      sections: [
        { h: "개별 차트 만들기", body: "차트 유형 선택 → 주요 차트 시각화. 데이터 기준 다양한 차트를 쉽게 시각화하여 보고서에 활용." },
        { h: "자동 차트 분석", body: "X·Y·Z축 변수 입력 시 기본·분포통계·관계분석·고급시각화 차트 22종 자동 생성. 차트 제작 시간 감소." }
      ]
    },
    "text-explore" => {
      title: "AI 텍스트 탐색 분석", chapter: "02 데이터 탐색", slides: [28],
      lead: "테이블 워드클라우드와 비정형 문서 워드클라우드 분석을 지원합니다.",
      sections: [
        { h: "① 로딩 테이블 데이터 기반 워드클라우드", body: "문서와 필드에 대한 이해도를 제고합니다." },
        { h: "② 비정형 문서 기반 워드클라우드", body: "텍스트 데이터 특성의 시각적 이해 + 분석 인사이트 도출." }
      ]
    },
    "thematic-map" => {
      title: "주제도 분석", chapter: "02 데이터 탐색", slides: [29],
      lead: "국내·전 세계 지도 자동 로딩과 지리적 데이터 분포 특성을 쉽게 파악할 수 있도록 지원합니다.",
      sections: [
        { h: "행정경계 5종 / 격자·헥사곤 7종", body: "시도·시군구·행정동·법정동·기초구역 5종, 100m~10km 격자/헥사곤 7종 전국 표준 경계 지원." },
        { h: "국내·해외 배경지도", body: "국내 VWorld(기본도·위성도·하이브리드), 해외 오픈스트리트맵 배경 지도." }
      ]
    },
    "insight-report" => {
      title: "AI 종합 인사이트 리포트", chapter: "02 데이터 탐색", slides: [30],
      lead: "지식그래프 기반에서 자연어를 질의하면 주제에 맞는 차트·주제도·시사점·정책 제언을 GPT가 추천하고 종합 리포트를 자동 출력합니다.",
      sections: [
        { h: "① Auto 지식그래프 생성", body: "데이터 기반 AI 행정 지원, LLM 기반 정책 의사결정 플랫폼." },
        { h: "② Auto GPT 보고서 출력", body: "차트·주제도·통계분석·What-If·Reverse What-If가 포함된 종합 리포트. 데이터 기반의 No 환각(Hallucination)." }
      ]
    },
    "target-yx" => {
      title: "AI Target YX 최적화", chapter: "02 데이터 탐색", slides: [31],
      lead: "Y 기준 최우수 알고리즘 자동 선정 + 개선 대상 Target 집단 선정. What-If와 Reverse What-If로 목표 Y 달성을 위한 최적 X 조합을 추천합니다.",
      sections: [
        { h: "What-If 분석 (X 변화 → Y 예측)", body: "X 변수 변화에 따른 Y 변화 값을 예측합니다." },
        { h: "Reverse What-If 분석 (Y 목표 → 최적 X 조합)", body: "약 60종 알고리즘 경쟁 기반 최우수 알고리즘 선정. 전체 평균·하위 20%·상위 20%·특정 레코드의 증감 방안 도출." }
      ]
    }
  }.freeze

  def deck_detail(slug)
    DECK_DETAILS[slug]
  end

  def deck_detail_slugs
    DECK_DETAILS.keys
  end
end
