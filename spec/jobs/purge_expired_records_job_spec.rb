require "rails_helper"

# ISS-009 — 처리방침 3항 "데모 신청·문의: 미팅 종료 후 1년" 을 코드가 이행하지 않았다.
# 공표한 보유기간이 지난 개인정보가 무기한 쌓이고 있었다.
RSpec.describe PurgeExpiredRecordsJob, type: :job do
  let(:user) { create(:user) }

  describe "데모 신청" do
    # 방침 문구가 "미팅 종료 후 1년" 이므로 기준 시각은 종료 시점이다.
    # 종료 시각을 따로 안 남기므로 completed/cancelled 로 바뀐 시각(updated_at)을 쓴다.
    it "종료 후 1년이 지나면 파기된다" do
      dr = user.demo_requests.create!(data_description: "오래된 신청", locale: "ko", status: :completed)
      dr.update_column(:updated_at, 13.months.ago)

      expect { described_class.perform_now }.to change(DemoRequest, :count).by(-1)
    end

    it "취소된 신청도 1년 후 파기된다" do
      dr = user.demo_requests.create!(data_description: "취소됨", locale: "ko", status: :cancelled)
      dr.update_column(:updated_at, 13.months.ago)

      expect { described_class.perform_now }.to change(DemoRequest, :count).by(-1)
    end

    it "종료 후 1년이 안 됐으면 남는다" do
      dr = user.demo_requests.create!(data_description: "최근 종료", locale: "ko", status: :completed)
      dr.update_column(:updated_at, 6.months.ago)

      expect { described_class.perform_now }.not_to change(DemoRequest, :count)
    end

    # 아직 진행 중인 건은 "미팅 종료" 자체가 없었으므로 파기 대상이 아니다.
    it "진행 중(pending/scheduled)인 신청은 오래돼도 남는다" do
      dr = user.demo_requests.create!(data_description: "진행 중", locale: "ko", status: :pending)
      dr.update_column(:updated_at, 2.years.ago)

      expect { described_class.perform_now }.not_to change(DemoRequest, :count)
    end

    it "파기 시 첨부파일과 코멘트도 함께 지워진다" do
      dr = user.demo_requests.create!(data_description: "첨부 있음", locale: "ko", status: :completed)
      dr.data_file.attach(io: StringIO.new("data"), filename: "x.csv", content_type: "text/csv")
      dr.comments.create!(body: "코멘트", user: user, by_admin: false)
      dr.update_column(:updated_at, 13.months.ago)

      expect { described_class.perform_now }
        .to change(Comment, :count).by(-1)
        .and change(ActiveStorage::Attachment, :count).by(-1)
    end
  end

  describe "문의" do
    # contact_inquiries 는 User 와 무관한 별도 테이블이라 회원탈퇴로도 지워지지 않는다.
    it "접수 후 1년이 지나면 파기된다" do
      ci = ContactInquiry.create!(name: "문의자", email: "old@test.com", message: "오래된 문의",
                                  locale: "ko", industry: "other")
      ci.update_column(:created_at, 13.months.ago)

      expect { described_class.perform_now }.to change(ContactInquiry, :count).by(-1)
    end

    it "1년이 안 됐으면 남는다" do
      ci = ContactInquiry.create!(name: "문의자", email: "recent@test.com", message: "최근 문의",
                                  locale: "ko", industry: "other")
      ci.update_column(:created_at, 6.months.ago)

      expect { described_class.perform_now }.not_to change(ContactInquiry, :count)
    end
  end

  describe "IR 자료 신청 기록" do
    # 토큰은 24시간 뒤 무효가 되지만(Download#token_expired?), 신청 기록은
    # 데모·문의와 같은 1년 기준으로 보유한다 — IR 리드 추적이 24시간 만에
    # 끊기지 않도록 방침 문구를 그렇게 정했다.
    it "접수 후 1년이 지나면 파기된다" do
      d = Download.create!(name: "투자자", email: "old-ir@test.com", asset: "ir_deck_ko",
                           locale: "ko", privacy_agreed_at: Time.current)
      d.update_column(:created_at, 13.months.ago)

      expect { described_class.perform_now }.to change(Download, :count).by(-1)
    end

    it "토큰이 만료됐어도 1년 안이면 신청 기록은 남는다 (리드 추적)" do
      d = Download.create!(name: "투자자", email: "recent-ir@test.com", asset: "ir_deck_ko",
                           locale: "ko", privacy_agreed_at: Time.current)
      d.update_column(:token_issued_at, 25.hours.ago)

      expect { described_class.perform_now }.not_to change(Download, :count)
      expect(d.reload.token_expired?).to be(true)
    end
  end

  # 배치는 조용히 멈춰도 티가 안 난다. 돌았다는 증거를 남겨야
  # 방침대로 파기되고 있는지 사후에 확인할 수 있다.
  it "파기 건수를 로그로 남긴다" do
    dr = user.demo_requests.create!(data_description: "파기 대상", locale: "ko", status: :completed)
    dr.update_column(:updated_at, 13.months.ago)

    logged = []
    allow(Rails.logger).to receive(:info) { |msg| logged << msg.to_s }
    described_class.perform_now

    expect(logged.join("\n")).to match(/\[PurgeExpiredRecords\].*demo_requests=1/)
  end
end
