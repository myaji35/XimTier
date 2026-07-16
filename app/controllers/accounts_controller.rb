class AccountsController < ApplicationController
  before_action :authenticate_user!

  def close
  end

  def destroy
    result = AccountClosing.call(current_user, current_password: params[:current_password])

    unless result.ok?
      flash.now[:alert] = I18n.t("account.close.errors.#{result.error}")
      render :close, status: :unprocessable_entity and return
    end

    sign_out current_user
    redirect_to home_path(locale: I18n.locale), notice: I18n.t("account.close.flash.done")
  end
end
