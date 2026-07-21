require "rails_helper"

RSpec.describe "GET /version", type: :request do
  it "배포 SHA를 JSON으로 반환하고 캐시하지 않는다" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("KAMAL_VERSION").and_return("2b88c2d5fe51e1a50cdb1352ace6eefe7595b90b")

    get "/version"

    expect(response).to have_http_status(:ok)
    expect(response.cache_control[:no_store]).to be(true)
    # 공개 엔드포인트라 SHA 외의 값을 늘리지 않는다.
    expect(response.parsed_body).to eq("version" => "2b88c2d5fe51e1a50cdb1352ace6eefe7595b90b")
  end

  it "KAMAL_VERSION이 없어도 500 없이 폴백 버전을 반환한다" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("KAMAL_VERSION").and_return(nil)

    get "/version"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("version")).to be_a(String)
    expect(response.parsed_body.fetch("version")).not_to be_empty
  end
end
