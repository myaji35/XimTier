class DownloadsController < ApplicationController
  before_action :set_download_by_token, only: [:show]

  def new
    @download = Download.new
    render "pages/investors"
  end

  def create
    asset = params.dig(:download, :asset).presence || (I18n.locale == :en ? "ir_deck_en" : "ir_deck_ko")
    @download = Download.find_or_initialize_by(
      email: download_params[:email],
      asset: Download.assets[asset]
    )
    @download.assign_attributes(
      download_params.except(:asset).merge(locale: I18n.locale.to_s, asset: asset)
    )

    # Honeypot
    if params[:website].present?
      redirect_to investors_path(locale: I18n.locale), notice: I18n.t("investors.flash.success") and return
    end

    if @download.save
      DownloadMailer.link(@download).deliver_later
      redirect_to investors_path(locale: I18n.locale, sent: 1)
    else
      render "pages/investors", status: :unprocessable_entity
    end
  end

  def show
    if @download.nil?
      redirect_to investors_path(locale: I18n.locale), alert: I18n.t("investors.errors.invalid_token") and return
    end

    @download.increment_download!
    if File.exist?(@download.asset_path)
      send_file @download.asset_path, type: "application/pdf", disposition: "inline",
                                       filename: "XimTier_#{@download.asset}.pdf"
    else
      redirect_to investors_path(locale: I18n.locale), alert: I18n.t("investors.errors.file_missing")
    end
  end

  private

  def set_download_by_token
    @download = Download.find_by(download_token: params[:token])
  end

  def download_params
    params.require(:download).permit(:email, :name, :company, :role, :asset)
  end
end
