class ContactInquiriesController < ApplicationController
  def new
    @inquiry = ContactInquiry.new
    render "pages/contact"
  end

  def create
    @inquiry = ContactInquiry.new(inquiry_params.merge(
      locale: I18n.locale.to_s,
      source: request.referer.to_s.first(255)
    ))

    # Honeypot·제출 시간·내용 기반 스팸은 성공한 것처럼 응답해 봇의 우회를 막는다.
    spam_reason = if params[:website].present?
      "honeypot"
                  elsif invalid_form_submission_time?
      "form_timing"
                  elsif SpamFilter.spam?(message: @inquiry.message, name: @inquiry.name,
                           company: @inquiry.company, email: @inquiry.email)
      "content"
                  end
    if spam_reason
      log_honeypot_submission(form: "contact_inquiry", email: @inquiry.email, reason: spam_reason)
      redirect_to contact_path(locale: I18n.locale), notice: I18n.t("contact.flash.success") and return
    end

    unless params.dig(:contact_inquiry, :consent) == "1"
      @inquiry.errors.add(:base, I18n.t("contact.errors.consent_required"))
      render "pages/contact", status: :unprocessable_entity and return
    end

    @inquiry.privacy_agreed_at = Time.current

    # Cloudflare Turnstile (skipped automatically when env keys are absent)
    if TurnstileVerifier.enabled?
      token = params["cf-turnstile-response"].presence || params[:cf_turnstile_response]
      unless TurnstileVerifier.verify(token, remote_ip: request.remote_ip)
        @inquiry.errors.add(:base, I18n.t("contact.errors.turnstile_failed"))
        render "pages/contact", status: :unprocessable_entity and return
      end
    end

    if @inquiry.save
      ContactMailer.auto_reply(@inquiry).deliver_later
      ContactMailer.admin_notification(@inquiry).deliver_later
      SlackContactNotificationJob.perform_later(@inquiry.id)
      GoogleSheetExportJob.perform_later("contact", @inquiry.id)
      redirect_to contact_path(locale: I18n.locale), notice: I18n.t("contact.flash.success")
    else
      render "pages/contact", status: :unprocessable_entity
    end
  end

  private

  def inquiry_params
    params.require(:contact_inquiry).permit(:name, :email, :company, :industry, :message)
  end
end
