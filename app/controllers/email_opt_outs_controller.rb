class EmailOptOutsController < ApplicationController
  before_action :set_email_from_token

  def show; end

  def create
    EmailOptOut.find_or_create_by!(email: EmailOptOut.normalize(@email)) do |opt_out|
      opt_out.reason = params[:reason].presence
      opt_out.source = "unsubscribe_link"
    end
  end

  private

  def set_email_from_token
    @token = params[:token].to_s
    @email = Rails.application.message_verifier(:email_optout).verified(@token)
    head :not_found unless @email.is_a?(String) && @email.match?(URI::MailTo::EMAIL_REGEXP)
  end
end
