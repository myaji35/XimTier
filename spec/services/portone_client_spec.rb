require "rails_helper"

RSpec.describe PortoneClient do
  let(:user) { create(:user) }
  let(:payment) do
    Payment.create!(
      user: user,
      payment_id: "xim_test_payment",
      portone_tx_id: "portone_tx_123",
      amount: 500_000,
      plan_code: "pro",
      status: "pending"
    )
  end

  describe ".verify!" do
    let(:api_result) do
      {
        "status" => "PAID",
        "paymentId" => payment.payment_id,
        "amount" => { "total" => payment.amount }
      }
    end

    it "정상 결제이면 성공 결과를 반환한다" do
      allow(described_class).to receive(:fetch_payment).and_return(api_result)

      expect(described_class.verify!(payment)).to eq([true, nil, api_result])
    end

    it "결제 금액이 다르면 실패한다" do
      api_result["amount"]["total"] = 1
      allow(described_class).to receive(:fetch_payment).and_return(api_result)

      ok, reason, result = described_class.verify!(payment)

      expect(ok).to be false
      expect(reason).to include("금액 불일치")
      expect(result).to eq(api_result)
    end

    it "주문번호가 다르면 실패한다" do
      api_result["paymentId"] = "forged_payment_id"
      allow(described_class).to receive(:fetch_payment).and_return(api_result)

      ok, reason, result = described_class.verify!(payment)

      expect(ok).to be false
      expect(reason).to include("주문번호 불일치")
      expect(result).to eq(api_result)
    end

    it "결제 상태가 PAID가 아니면 실패한다" do
      api_result["status"] = "READY"
      allow(described_class).to receive(:fetch_payment).and_return(api_result)

      ok, reason, result = described_class.verify!(payment)

      expect(ok).to be false
      expect(reason).to include("미결제 상태")
      expect(result).to eq(api_result)
    end

    it "API 조회에 실패하면 실패 결과를 반환한다" do
      allow(described_class).to receive(:fetch_payment).and_return(nil)

      ok, reason, result = described_class.verify!(payment)

      expect(ok).to be false
      expect(reason).to include("조회 실패")
      expect(result).to be_nil
    end

    it "portone_tx_id가 비어 있으면 실패한다" do
      payment.portone_tx_id = nil

      ok, reason, result = described_class.verify!(payment)

      expect(ok).to be false
      expect(reason).to include("tx_id 없음")
      expect(result).to be_nil
    end
  end

  describe ".verify_webhook_signature" do
    it "항상 false를 반환한다" do
      # 미구현 상태에서 true 가 되면 위조 웹훅이 통과한다
      expect(described_class.verify_webhook_signature("body", {})).to be false
    end
  end

  describe Payment do
    def payment_attributes(overrides = {})
      {
        user: user,
        payment_id: Payment.generate_payment_id,
        amount: 500_000,
        plan_code: "pro",
        status: "pending"
      }.merge(overrides)
    end

    it "amount가 0이면 invalid이다" do
      invalid_payment = Payment.new(payment_attributes(amount: 0))

      expect(invalid_payment).not_to be_valid
      expect(invalid_payment.errors[:amount]).to be_present
    end

    it "payment_id가 중복이면 invalid이다" do
      existing_payment = Payment.create!(payment_attributes(payment_id: "duplicate_payment_id"))
      duplicate_payment = Payment.new(payment_attributes(payment_id: existing_payment.payment_id))

      expect(duplicate_payment).not_to be_valid
      expect(duplicate_payment.errors[:payment_id]).to be_present
    end

    it ".generate_payment_id는 호출마다 다른 값을 반환한다" do
      first_payment_id = Payment.generate_payment_id
      second_payment_id = Payment.generate_payment_id

      expect(second_payment_id).not_to eq(first_payment_id)
    end
  end
end
