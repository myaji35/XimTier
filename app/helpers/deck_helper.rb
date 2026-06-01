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
    },
    "sol-meeting" => {
      title: "AI 스마트 Meeting 분석", chapter: "04 One-Stop 솔루션", slides: [61],
      lead: "공청회·업무 회의 등 자연어 회의록 로딩 시, 자연어 분석 기반의 패널별 핵심 이슈와 중요도를 자동 산출합니다.",
      sections: [
        { h: "AI 핵심이슈 최적화 분석", body: "패널–이슈별 찬반 감성 지식그래프 기반의 핵심 이슈 최적화 도출 (What-If·Reverse What-If)." },
        { h: "활용 효과", body: "사안별 최적화 방향 도출, 협의 시간 단축, 합의 실패율 감소, 최소 예산 기반 최적 해법, 정책 최적화 지원." }
      ]
    },
    "sol-survey" => {
      title: "AI 스마트 설문 분석", chapter: "04 One-Stop 솔루션", slides: [62],
      lead: "설문 원시 데이터 로딩 시 전처리를 자동 수행하고, 과제 간 상호 연계성과 중요도를 자동 선별하여 전략 우선 과제와 최적 타깃을 도출합니다.",
      sections: [
        { h: "전략 우선 과제 도출 + 타깃 선별", body: "AI 설문 통합 지식그래프, 문항별 분석, 과제 간 상호 연계성과 타깃 특성 분석." },
        { h: "활용 효과", body: "최대 효과성 높은 과제 집중 추진, 타깃 계층별 종합 분석·대책, 설문 자료 재활용 예산 효율(K-AI 스마트도시 선도)." }
      ]
    },
    "sol-sns" => {
      title: "AI 스마트 SNS 분석", chapter: "04 One-Stop 솔루션", slides: [63],
      lead: "SNS 원시 데이터 로딩 시 키워드 자동 추출과 카테고리별 감성 만족지수 산출을 지원합니다.",
      sections: [
        { h: "카테고리별 만족지수 + 종합 시사점", body: "경영·정책·전략 개선을 위한 AI 종합 시사점 도출." },
        { h: "활용 효과", body: "SNS 만족지수 기반 스마트시티 행정·정책 개선, 제품·서비스 개선 방향, 시민·고객 지향 경영/정책 수립." }
      ]
    },
    "sol-festival" => {
      title: "AI 축제/행사 YX 최적화 분석", chapter: "04 One-Stop 솔루션", slides: [64],
      lead: "축제 방문객수 등 Y 성과와 X 변수(인력·시설·프로모션·SNS 평판·날씨)를 로딩하여 현상 분석과 정책 시사점을 도출합니다.",
      sections: [
        { h: "Y 성과–X 변수 연관 분석", body: "SNS 만족지수와 전략 도출, AI 지식그래프와 시사점 도출." },
        { h: "What-If / Reverse What-If 최적화", body: "방문객수 증가를 위한 X 변수 최적화, 시설·서비스·광고비 최적 운영, AI 종합 최적화 보고서." }
      ]
    },
    "sol-market" => {
      title: "AI 전통시장/상권 YX 최적화 분석", chapter: "04 One-Stop 솔루션", slides: [65],
      lead: "전통시장/상권 방문객수 등 Y 성과와 X 변수를 로딩하여 현상 분석과 정책 시사점을 도출합니다.",
      sections: [
        { h: "Y 성과–X 변수 연관 분석", body: "SNS 만족지수와 전략 도출, AI 지식그래프와 시사점 도출." },
        { h: "최적화 도출", body: "방문객수 증가를 위한 Reverse What-If 최적화, 시설·서비스·광고비 최적 운영." }
      ]
    },
    "sol-smb" => {
      title: "AI 소상공인/매장 YX 최적화 분석", chapter: "04 One-Stop 솔루션", slides: [66],
      lead: "소상공인 매출액 등 Y 성과와 X 변수를 로딩하여 현상 분석과 운영 시사점을 도출합니다.",
      sections: [
        { h: "Y 성과–X 변수 연관 분석", body: "SNS 만족지수와 전략 도출, AI 지식그래프와 시사점 도출." },
        { h: "최적화 도출", body: "매출액 증가를 위한 Reverse What-If, 인력·시설·서비스·광고비 최적 운영." }
      ]
    },
    "sol-clinic" => {
      title: "AI 광고형 병의원 YX 최적화 분석", chapter: "04 One-Stop 솔루션", slides: [67],
      lead: "광고형 병의원 방문객 매출 등 Y 성과와 X 변수를 로딩하여 현상 분석과 정책 시사점을 도출합니다.",
      sections: [
        { h: "Y 성과–X 변수 연관 분석", body: "SNS 만족지수와 전략 도출, AI 지식그래프와 시사점 도출." },
        { h: "최적화 도출", body: "광고 방문객수 증가를 위한 X 변수 최적화, 시설·서비스·광고비 최적 운영." }
      ]
    },
    "sol-maintenance" => {
      title: "AI 설비고장/예지보전 YX 최적화 분석", chapter: "04 One-Stop 솔루션", slides: [68],
      lead: "제조 설비 고장/예지보전 등 Y 성과와 X 변수(설비 운영·정비활동·설비 상태품질/고장·외부 환경)를 로딩합니다.",
      sections: [
        { h: "IoT 센싱별 고장률 위치 분석", body: "Y 성과–X 변수 연관 분석, AI 지식그래프와 시사점 도출." },
        { h: "최적화 도출", body: "고장률 감소를 위한 Reverse What-If, 예지보전 대책·예산절감, 최적 운영 방안." }
      ]
    },
    "sol-sns-product" => {
      title: "AI SNS 기반 제품 기능 개발 YX 최적화", chapter: "04 One-Stop 솔루션", slides: [69],
      lead: "프로파일(성연령·직업·소득)별 매출 등 Y 성과와 SNS 데이터를 로딩하여 프로파일별 SNS 감성 만족지수를 산출합니다.",
      sections: [
        { h: "프로파일별 SNS 만족지수 + 타깃 도출", body: "Y 성과와 SNS 프로파일 분석, AI 지식그래프와 시사점 도출." },
        { h: "제품 기능 최적화", body: "매출 기여도 따른 기능 강화, 타깃 맞춤 최적 기능, 연구개발비·원가 최적화." }
      ]
    },
    "sol-survey-product" => {
      title: "AI 설문 기반 제품 기능 개발 YX 최적화", chapter: "04 One-Stop 솔루션", slides: [70],
      lead: "프로파일별 매출 등 Y 성과와 설문 데이터를 로딩하여 프로파일별 만족지수와 문항별 평점을 산출합니다.",
      sections: [
        { h: "설문 평점 + 타깃 도출", body: "Y 성과와 설문 프로파일 분석, AI 지식그래프와 시사점 도출." },
        { h: "제품 기능 최적화", body: "매출 기여도 따른 기능 강화, 타깃 맞춤 최적 기능, 연구개발비·원가 최적화." }
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
