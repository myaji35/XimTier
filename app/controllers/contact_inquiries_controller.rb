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

    unless params.dig(:contact_inquiry, :consent) == "1"
      @inquiry.errors.add(:base, I18n.t("contact.errors.consent_required"))
      render "pages/contact", status: :unprocessable_entity and return
    end

    # Honeypot (bots fill this hidden field)
    if params[:website].present?
      redirect_to contact_path(locale: I18n.locale), notice: I18n.t("contact.flash.success") and return
    end

    if @inquiry.save
      ContactMailer.auto_reply(@inquiry).deliver_later
      ContactMailer.admin_notification(@inquiry).deliver_later
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
