require "rails_helper"

# IR 신청자를 이메일 도메인으로 분류한다.
# 자료 발송을 막지는 않는다 — IR 은 널리 퍼지는 게 이득이고, 무료메일을 쓰는
# 진짜 심사역도 많다. 분류는 대표님이 "누구에게 먼저 연락할지" 판단하는 신호다.
RSpec.describe InvestorClassifier do
  describe "VC 확인" do
    # 실제 신청 이력에 있던 도메인. 이 판별이 통해야 자동화가 의미 있다.
    it "알려진 VC 도메인을 알아본다" do
      expect(described_class.call("sj.lee@theventures.co.kr").kind).to eq(:vc)
    end

    it "서브도메인이 붙어도 알아본다" do
      expect(described_class.call("partner@mail.theventures.co.kr").kind).to eq(:vc)
    end

    it "대소문자를 가리지 않는다" do
      expect(described_class.call("SJ.Lee@TheVentures.co.kr").kind).to eq(:vc)
    end
  end

  describe "법인" do
    it "회사 도메인은 법인으로 본다" do
      r = described_class.call("kim.exec@hyundai-sme.com")
      expect(r.kind).to eq(:company)
      expect(r.domain).to eq("hyundai-sme.com")
    end
  end

  describe "미판별" do
    # 무료메일은 신원을 알 수 없을 뿐, 투자자가 아니라는 뜻이 아니다.
    %w[gmail.com naver.com daum.net hanmail.net outlook.com icloud.com kakao.com].each do |d|
      it "#{d} 은 미판별로 둔다" do
        expect(described_class.call("someone@#{d}").kind).to eq(:unknown)
      end
    end

    it "테스트용 도메인도 미판별이다" do
      expect(described_class.call("test-ir@example.com").kind).to eq(:unknown)
    end

    it "이메일이 이상해도 터지지 않는다" do
      [ nil, "", "not-an-email", "@", "a@" ].each do |bad|
        expect { described_class.call(bad) }.not_to raise_error
        expect(described_class.call(bad).kind).to eq(:unknown)
      end
    end
  end

  describe "표시" do
    it "대표님이 알림에서 바로 알아볼 수 있는 라벨을 준다" do
      expect(described_class.call("sj.lee@theventures.co.kr").label).to include("VC")
      expect(described_class.call("kim.exec@hyundai-sme.com").label).to include("법인")
      expect(described_class.call("x@gmail.com").label).to include("미판별")
    end
  end

  # 실제 신청 이력으로 검증한다. 이 4건이 제대로 갈리지 않으면 분류가 무의미하다.
  describe "실제 신청 이력 재현" do
    {
      "sj.lee@theventures.co.kr"  => :vc,       # 더벤처스 Investment Partner
      "kim.exec@hyundai-sme.com"  => :company,  # 현대 정밀공업 상무 (고객 후보)
      "test-ir@example.com"       => :unknown   # 테스트 데이터
    }.each do |email, expected|
      it "#{email} → #{expected}" do
        expect(described_class.call(email).kind).to eq(expected)
      end
    end
  end
end
