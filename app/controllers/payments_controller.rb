class PaymentsController < ApplicationController
  before_action :authenticate_user!

  def new
    plan_code = params[:plan].to_s
    unless PAYMENT_PLANS.available?(plan_code)
      redirect_to pricing_path(locale: I18n.locale), alert: t("payments.unavailable")
      return
    end

    @plan = PAYMENT_PLANS.fetch(plan_code)
    @amount = @plan[:amount]
  end

  def create
    plan_code = params[:plan].to_s
    unless PAYMENT_PLANS.available?(plan_code)
      render json: { error: t("payments.unavailable") }, status: :unprocessable_entity
      return
    end

    payment = Payment.create!(
      user: current_user,
      payment_id: Payment.generate_payment_id,
      plan_code: plan_code,
      amount: PAYMENT_PLANS.fetch(plan_code)[:amount],
      status: "pending"
    )

    render json: {
      payment_id: payment.payment_id,
      amount: payment.amount,
      store_id: PortoneClient.store_id,
      channel_key: PortoneClient.channel_key
    }
  end

  def complete
    payment = Payment.find_by!(payment_id: params[:payment_id], user: current_user)
    payment.update!(portone_tx_id: params[:tx_id])

    ok, reason, raw_response = PortoneClient.verify!(payment)

    if ok
      raw_response ||= PortoneClient.fetch_payment(payment.portone_tx_id)
      payment.update!(status: "paid", paid_at: Time.current, raw_response: raw_response || {})
      notify_admin(payment)
      render json: { ok: true }
    else
      payment.update!(status: "failed", failed_at: Time.current, failure_reason: reason)
      render json: { ok: false, reason: reason }, status: :unprocessable_entity
    end
  end

  private

  def notify_admin(payment)
    if defined?(SlackNotifier) && SlackNotifier.respond_to?(:notify_payment)
      SlackNotifier.notify_payment(payment)
    else
      Rails.logger.info("[PaymentsController] payment completed: #{payment.payment_id}")
    end
  end
end
