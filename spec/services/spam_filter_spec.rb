require "rails_helper"

RSpec.describe SpamFilter do
  def spam?(message: "정상 문의입니다", name: "홍길동", company: "XimTier", email: "hello@ximtier.com")
    described_class.spam?(message: message, name: name, company: company, email: email)
  end

  it "본문에 URL이 2개 이상이면 스팸으로 판정한다" do
    expect(spam?(message: "https://spam.test/a 와 http://spam.test/b")).to be(true)
  end

  it "URL이 하나인 정상 문의는 허용한다" do
    expect(spam?(message: "참고 자료는 https://example.com/document 입니다")).to be(false)
  end

  it "이름이나 본문의 영문 스팸 키워드를 대소문자와 무관하게 차단한다" do
    expect(spam?(name: "Casino Partner")).to be(true)
    expect(spam?(message: "We can help you RANK HIGHER")).to be(true)
  end

  it "이름에 URL이 들어가면 차단한다" do
    expect(spam?(name: "https://spam.test")).to be(true)
  end

  it "대기업명과 이메일 도메인이 일치하지 않으면 차단한다" do
    expect(spam?(company: "Google", email: "sales@gmail.com")).to be(true)
    expect(spam?(company: "Facebook", email: "person@meta.com")).to be(false)
    expect(spam?(company: "Amazon", email: "person@team.amazon.com")).to be(false)
  end

  it "일반 회사명에는 도메인 일치를 요구하지 않는다" do
    expect(spam?(company: "Acme", email: "person@gmail.com")).to be(false)
  end
end
