require "rails_helper"

RSpec.describe "/how-it-works with Reverse What-If demo", type: :request do
  it "/ko/how-it-works — 데모 섹션 + Stimulus 컨트롤러 노출" do
    get "/ko/how-it-works"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("reverse-what-if-demo")
    expect(response.body).to include("data-controller=\"reverse-what-if\"")
    expect(response.body).to include("슬라이더 한 번에 5개 변수가 자동 역산됩니다")
    expect(response.body).to include("OPTIMAL INPUTS")
    expect(response.body).to include("FEATURE IMPACT (SHAP)")
    expect(response.body).to include("case_01 · semiconductor_defect_rate.csv")
  end

  it "/en/how-it-works — English demo section" do
    get "/en/how-it-works"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("One slider")
    expect(response.body).to match(/reverse-solved instantly/)
  end

  it "Stimulus 컨트롤러 파일 자산 200" do
    get "/ko/how-it-works"
    # Importmap의 컨트롤러 경로는 /assets/controllers/... 패턴 — 헤더의 JS 모듈 import 확인
    expect(response.body).to include("@hotwired/stimulus")
  end
end
