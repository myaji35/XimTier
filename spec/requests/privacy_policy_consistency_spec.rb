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

  # 방침 6항: "방문자 추적 쿠키, 광고 쿠키, 분석 도구 쿠키는 사용하지 않습니다"
  #
  # ahoy_matey 가 2년짜리 ahoy_visitor 쿠키를 심으면서 이 문구가 거짓이 된 적이 있다.
  # 데이터를 읽는 코드는 어디에도 없었는데도 수집만 하고 있었다 (ISS-011).
  # 분석 도구를 다시 넣으면 여기서 잡는다.
  describe "쿠키 — 방침이 허용한 것만 나간다" do
    # 방침 6항이 명시한 세 가지. 이 밖의 쿠키가 나가면 방침 위반이다.
    ALLOWED = %w[_xaisimtier_session remember_user_token xim_visitor].freeze

    it "홈에서 추적 쿠키가 나가지 않는다" do
      get "/ko"
      expect(cookie_names).to all(be_in(ALLOWED))
    end

    it "로그인 후에도 허용된 쿠키만 나간다" do
      sign_in create(:user)
      get "/ko"
      expect(cookie_names).to all(be_in(ALLOWED))
    end

    # 갤러리 상세는 좋아요 쿠키를 심는 유일한 경로다.
    # 처음 이 검사가 홈·대시보드만 봐서 20년짜리 xim_visitor 를 놓쳤다.
    it "갤러리 상세에서도 허용된 쿠키만 나간다" do
      CaseStudy.create!(slug: "cookie-guard", title_ko: "쿠키 가드", published: true)
      get "/ko/cases/cookie-guard/gallery"
      expect(cookie_names).to all(be_in(ALLOWED))
    end

    it "분석 도구 gem 이 설치되어 있지 않다" do
      gems = File.read(Rails.root.join("Gemfile"))
      expect(gems).not_to match(/ahoy|mixpanel|segment|google-analytics|amplitude/i)
    end

    # 배너 문구는 뷰에 하드코딩돼 있어 방침만 고치면 따로 논다.
    # 실제로 ahoy 제거 후에도 배너는 "cookieless 분석" 을 계속 주장하고 있었다.
    it "쿠키 배너가 방침과 어긋나지 않는다" do
      get "/ko"
      expect(response.body).not_to include("cookieless")
      expect(response.body).not_to match(/분석만 사용/)
    end

    def cookie_names
      response.headers["Set-Cookie"].to_s.lines.map { |l| l.split("=").first.strip }.reject(&:empty?)
    end
  end
end

RSpec.configure do |c|
  c.include Devise::Test::IntegrationHelpers, type: :request
end
