require "rails_helper"

# ISS-009 — 처리방침은 법적 약속이다 (개인정보보호법 제30조 제3항:
# 방침과 실제가 다르면 정보주체에 유리한 쪽이 적용된다).
#
# 방침에 적어놓고 코드가 이행하지 않는 상태가 반복해서 발생했다:
#   - "삭제 요청 시까지" 라고 해놓고 탈퇴 경로가 없었음 (ISS-002에서 해소)
#   - "24시간 후 폐기" 라고 해놓고 토큰이 영구 유효했음 + 본문에 "v1.5 적용 예정" 자인
#   - "1년 보유" 라고 해놓고 파기 배치가 없었음
#
# 방침 문구와 코드가 어긋나면 여기서 잡는다.
RSpec.describe "처리방침 ↔ 코드 일치", type: :request do
  %w[ko en].each do |locale|
    describe "#{locale} 처리방침" do
      before { get "/#{locale}/privacy" }

      it "미구현 기능을 예정으로 적어두지 않는다" do
        expect(response.body).not_to match(/v1\.5|적용 예정|coming soon|planned/i)
      end
    end
  end

  describe "방침이 약속한 것이 실제로 존재한다" do
    it "탈퇴 경로 — 방침이 안내한 화면이 실제로 있다" do
      user = create(:user)
      sign_in user
      get "/ko/account/close"
      expect(response).to have_http_status(:ok)
    end

    it "토큰 만료 — 방침이 말한 24시간이 코드 상수와 일치한다" do
      expect(Download::TOKEN_TTL).to eq(24.hours)
      get "/ko/privacy"
      expect(response.body).to include("24시간")
    end

    it "보유기간 — 방침이 말한 1년이 파기 잡 상수와 일치한다" do
      expect(PurgeExpiredRecordsJob::RETENTION).to eq(1.year)
      get "/ko/privacy"
      expect(response.body).to include("1년")
    end

    # 잡이 있어도 스케줄에 등록되지 않으면 영원히 안 돈다.
    it "파기 잡이 프로덕션 스케줄에 등록되어 있다" do
      schedule = YAML.load_file(Rails.root.join("config/recurring.yml"))["production"]
      entry = schedule.values.find { |v| v["class"] == "PurgeExpiredRecordsJob" }

      expect(entry).to be_present, "recurring.yml production 에 PurgeExpiredRecordsJob 이 없다"
      expect(entry["schedule"]).to be_present
    end
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end
