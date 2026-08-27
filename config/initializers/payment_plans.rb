# 결제 플랜 정의. 금액은 ENV 주입 — 대표님 가격 확정 전까지 nil 이며,
# nil 이면 결제 진입이 비활성화된다(죽은 UI 방지).
PAYMENT_PLANS = {
  "light_saas_monthly" => {
    name_key: "pricing.tiers.light.name",
    amount: ENV["PLAN_LIGHT_SAAS_MONTHLY_AMOUNT"].presence&.to_i,
    interval: "monthly"
  }
}

def PAYMENT_PLANS.available?(code)
  self[code].present? && self[code][:amount].to_i > 0
end

PAYMENT_PLANS.freeze
