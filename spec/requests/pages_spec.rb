require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "Accept-Language: ko 일 때 /ko로 리디렉트한다" do
      get "/", headers: { "Accept-Language" => "ko-KR,ko;q=0.9" }
      expect(response).to redirect_to("/ko")
    end

    it "Accept-Language: en 일 때 /en로 리디렉트한다" do
      get "/", headers: { "Accept-Language" => "en-US,en;q=0.9" }
      expect(response).to redirect_to("/en")
    end
  end

  describe "GET /ko" do
    it "한국어 랜딩 200 + 한글 헤드라인 노출" do
      get "/ko"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("LLM이 못 푸는 수치를")
    end
  end

  describe "GET /en" do
    it "영문 랜딩 200 + 영문 헤드라인 노출" do
      get "/en"
      expect(response).to have_http_status(:ok)
      expect(response.body).to match(/We prove the numbers LLMs can.{1,6}t/)
    end
  end

  describe "GET /up (health)" do
    it "Kamal 헬스체크 200" do
      get "/up"
      expect(response).to have_http_status(:ok)
    end
  end
end
