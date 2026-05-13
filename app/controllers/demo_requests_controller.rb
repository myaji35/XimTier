class DemoRequestsController < ApplicationController
  def new
    @demo_request = DemoRequest.new
    render "pages/demo"
  end

  def create
    # Honeypot
    if params[:website].present?
      redirect_to demo_path(locale: I18n.locale), notice: I18n.t("demo.flash.success") and return
    end

    unless params.dig(:demo_request, :consent) == "1"
      @demo_request = DemoRequest.new(demo_params_for_form)
      @demo_request.errors.add(:base, I18n.t("contact.errors.consent_required"))
      render "pages/demo", status: :unprocessable_entity and return
    end

    user_params = user_params_from_request
    user = User.find_by(email: user_params[:email])

    if user.nil?
      generated_password = SecureRandom.alphanumeric(16)
      user = User.create(
        email: user_params[:email],
        password: generated_password,
        password_confirmation: generated_password,
        name: user_params[:name],
        company: user_params[:company],
        role: user_params[:role],
        industry: user_params[:industry],
        locale: I18n.locale.to_s
      )
      unless user.persisted?
        @demo_request = DemoRequest.new(demo_params_for_form)
        user.errors.full_messages.each { |m| @demo_request.errors.add(:base, m) }
        render "pages/demo", status: :unprocessable_entity and return
      end
      DemoMailer.welcome(user, generated_password).deliver_later
    end

    @demo_request = user.demo_requests.build(
      data_description: params.dig(:demo_request, :data_description),
      preferred_at:     params.dig(:demo_request, :preferred_at).presence,
      locale:           I18n.locale.to_s,
      source:           request.referer.to_s.first(255)
    )

    if params.dig(:demo_request, :data_file).present?
      @demo_request.data_file.attach(params[:demo_request][:data_file])
    end

    if @demo_request.save
      DemoMailer.received(@demo_request).deliver_later
      DemoMailer.admin_notification(@demo_request).deliver_later
      sign_in(user) unless user_signed_in?
      redirect_to dashboard_path(locale: I18n.locale), notice: I18n.t("demo.flash.success")
    else
      render "pages/demo", status: :unprocessable_entity
    end
  end

  private

  def user_params_from_request
    {
      email:    params.dig(:demo_request, :email).to_s.downcase.strip,
      name:     params.dig(:demo_request, :name),
      company:  params.dig(:demo_request, :company),
      role:     params.dig(:demo_request, :role),
      industry: params.dig(:demo_request, :industry).presence || "other"
    }
  end

  def demo_params_for_form
    {
      data_description: params.dig(:demo_request, :data_description),
      preferred_at:     params.dig(:demo_request, :preferred_at)
    }
  end
end
