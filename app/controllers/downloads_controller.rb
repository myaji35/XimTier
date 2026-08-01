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
      log_honeypot_submission(form: "download", email: params.dig(:download, :email))
      redirect_to investors_path(locale: I18n.locale), notice: I18n.t("investors.flash.success") and return
    end

    # 이름·이메일·회사·직책을 수집하므로 동의가 필요하다 (제22조). — ISS-001
    unless params.dig(:download, :consent) == "1"
      @download.errors.add(:base, I18n.t("contact.errors.consent_required"))
      render "pages/investors", status: :unprocessable_entity and return
    end

    @download.privacy_agreed_at = Time.current
    # 기존 레코드 재사용 시 토큰을 새로 발급한다 — 갱신하지 않으면
    # 지난번 발급 시각이 남아 메일을 받자마자 만료된 링크가 된다. — ISS-009
    @download.reissue_token! if @download.persisted?

    if @download.save
      DownloadMailer.link(@download).deliver_later
      # 데모 신청·문의는 관리자 알림이 있는데 IR 만 없었다. 자료는 자동으로 나가지만
      # 누가 받아갔는지 모르면 후속 연락 타이밍을 놓친다. — 2026-07-16
      DownloadMailer.admin_notification(@download).deliver_later
      redirect_to investors_path(locale: I18n.locale, sent: 1)
    else
      render "pages/investors", status: :unprocessable_entity
    end
  end

  def show
    if @download.nil?
      redirect_to investors_path(locale: I18n.locale), alert: I18n.t("investors.errors.invalid_token") and return
    end

    # 처리방침 3항: 발급 후 24시간. — ISS-009
    if @download.token_expired?
      redirect_to investors_path(locale: I18n.locale), alert: I18n.t("investors.errors.token_expired") and return
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
