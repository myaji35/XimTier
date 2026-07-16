# IR 신청자를 이메일 도메인으로 분류한다.
#
# 이 분류는 자료 발송을 막지 않는다. IR 자료는 널리 퍼지는 게 이득이고,
# 무료메일을 쓰는 진짜 심사역도 많다. 막으면 오고 싶은 사람만 막힌다.
# 분류의 목적은 대표님이 "누구에게 먼저 연락할지" 판단할 신호를 주는 것이다.
#
# 근거: 2026-07-16 기준 실제 신청 4건 중 진짜 VC 는 1건(더벤처스)이었고,
# 그 1건을 갈라낸 단서가 회사 이메일 도메인이었다.
class InvestorClassifier
  Result = Struct.new(:kind, :domain, :label, keyword_init: true)

  # 신원을 알 수 없는 도메인. 투자자가 아니라는 뜻이 아니라 "회사를 알 수 없다"는 뜻이다.
  FREE_MAIL = %w[
    gmail.com googlemail.com naver.com daum.net hanmail.net kakao.com
    outlook.com hotmail.com live.com msn.com icloud.com me.com
    yahoo.com yahoo.co.kr proton.me protonmail.com nate.com
    example.com example.org test.com
  ].freeze

  # 알려진 VC·액셀러레이터 도메인. 이 목록은 계속 추가해도 된다.
  # 여기 걸리면 대표님이 알림에서 바로 알아보고 우선 연락할 수 있다.
  VC_DOMAINS = %w[
    theventures.co.kr altos.vc kaistone.com capstonepe.com
    softbank.co.kr sbva.co.kr kbinvest.co.kr mirae-asset.com
    hanwha.co.kr smilegate.com bonangels.net primer.kr
    strong.vc kakaoventures.com naver-d2sf.com posco-ventures.com
    intervest.co.kr atinum.com stonebridge.co.kr korea-omega.com
    sparklabs.co.kr fastventures.co.kr yellowdog.kr bass.vc
    a16z.com sequoiacap.com accel.com greylock.com
  ].freeze

  def self.call(email)
    domain = extract_domain(email)
    return Result.new(kind: :unknown, domain: nil, label: "⚠️ 미판별") if domain.blank?

    if vc_domain?(domain)
      Result.new(kind: :vc, domain: domain, label: "✅ VC 확인")
    elsif FREE_MAIL.include?(domain)
      Result.new(kind: :unknown, domain: domain, label: "⚠️ 미판별 (무료메일)")
    else
      Result.new(kind: :company, domain: domain, label: "🏢 법인 (#{domain})")
    end
  end

  def self.extract_domain(email)
    d = email.to_s.downcase.strip.split("@").last
    return nil if d.blank? || d == email.to_s.downcase.strip || !d.include?(".")

    d
  end
  private_class_method :extract_domain

  # 서브도메인(mail.theventures.co.kr)도 잡는다.
  def self.vc_domain?(domain)
    VC_DOMAINS.any? { |vc| domain == vc || domain.end_with?(".#{vc}") }
  end
  private_class_method :vc_domain?
end
