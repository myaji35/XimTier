require "rails_helper"

RSpec.describe GoogleSheetExporter do
  around do |example|
    original_test_emails = ENV["SHEET_TEST_EMAILS"]
    example.run
  ensure
    ENV["SHEET_TEST_EMAILS"] = original_test_emails
  end

  describe ".export_contact" do
    it "'문의' 태그를 포함한 9개 열을 append_row에 넘긴다" do
      inquiry = ContactInquiry.new(
        name: "홍길동",
        email: "lead@example.com",
        company: "테스트 주식회사",
        industry: "manufacturing",
        locale: "ko",
        source: "website",
        message: "도입을 문의합니다."
      )

      expect(described_class).to receive(:append_row) do |row|
        expect(row.length).to eq(9)
        expect(row[1]).to eq("문의")
        expect(row[2..]).to eq([
          "홍길동",
          "lead@example.com",
          "테스트 주식회사",
          "manufacturing",
          "ko",
          "website",
          "도입을 문의합니다."
        ])
      end

      described_class.export_contact(inquiry)
    end

    it "내부 이메일이면 '테스트' 태그를 넘긴다" do
      inquiry = ContactInquiry.new(name: "내부 사용자", email: "smartician@naver.com")

      expect(described_class).to receive(:append_row) do |row|
        expect(row[1]).to eq("테스트")
      end

      described_class.export_contact(inquiry)
    end

    it "대문자와 공백이 있는 내부 이메일도 '테스트'로 분류한다" do
      expect(described_class.send(:tag_for, "SMARTICIAN@NAVER.COM", "문의")).to eq("테스트")
      expect(described_class.send(:tag_for, " myaji35@gmail.com ", "문의")).to eq("테스트")
    end
  end

  describe ".export_demo" do
    it "user 연관의 이름과 이메일 및 '데모' 태그를 포함한 9개 열을 넘긴다" do
      user = User.new(
        name: "김데모",
        email: "demo@example.com",
        company: "데모 주식회사",
        industry: "finance"
      )
      demo_request = DemoRequest.new(
        user: user,
        locale: "ko",
        source: "landing_page",
        data_description: "매출 데이터를 분석하고 싶습니다."
      )

      expect(described_class).to receive(:append_row) do |row|
        expect(row.length).to eq(9)
        expect(row[1]).to eq("데모")
        expect(row[2]).to eq("김데모")
        expect(row[3]).to eq("demo@example.com")
      end

      described_class.export_demo(demo_request)
    end
  end

  it "문의와 데모 export의 열 개수가 동일하다" do
    inquiry = ContactInquiry.new(name: "문의자", email: "contact@example.com")
    demo_request = DemoRequest.new(user: User.new(name: "신청자", email: "demo@example.com"))
    rows = []
    allow(described_class).to receive(:append_row) { |row| rows << row }

    described_class.export_contact(inquiry)
    described_class.export_demo(demo_request)

    expect(rows.map(&:length)).to eq([9, 9])
  end

  it "SHEET_TEST_EMAILS에 추가한 주소도 '테스트'로 분류한다" do
    ENV["SHEET_TEST_EMAILS"] = "another@example.com, added@example.com"

    expect(described_class.send(:tag_for, " ADDED@EXAMPLE.COM ", "문의")).to eq("테스트")
  end

  describe ".append_row" do
    it "enabled?가 false이면 false를 반환하고 HTTP 호출을 하지 않는다" do
      allow(described_class).to receive(:enabled?).and_return(false)
      expect(Net::HTTP).not_to receive(:new)

      expect(described_class.append_row(Array.new(9))).to be false
    end
  end
end
