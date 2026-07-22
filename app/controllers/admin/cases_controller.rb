class Admin::CasesController < ApplicationController
  layout "admin_cases"

  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_case_study, only: %i[show edit update destroy create_medium destroy_medium]

  def index
    @case_studies = CaseStudy.order(:position, created_at: :desc)
  end

  def show
    @case_medium = @case_study.case_media.build
  end

  def new
    @case_study = CaseStudy.new
  end

  def create
    @case_study = CaseStudy.new(case_study_params)

    if @case_study.save
      redirect_to admin_case_path(@case_study), notice: "사례 콘텐츠를 생성했습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @case_medium = @case_study.case_media.build
  end

  def update
    if @case_study.update(case_study_params)
      redirect_to admin_case_path(@case_study), notice: "사례 콘텐츠를 수정했습니다."
    else
      @case_medium = @case_study.case_media.build
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @case_study.destroy!
    redirect_to admin_cases_path, notice: "사례 콘텐츠를 삭제했습니다."
  end

  def create_medium
    @case_medium = @case_study.case_media.build(case_medium_params)

    if @case_medium.save
      redirect_to edit_admin_case_path(@case_study), notice: "매체를 추가했습니다."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy_medium
    medium = @case_study.case_media.find(params[:medium_id])
    medium.destroy!
    redirect_to edit_admin_case_path(@case_study), notice: "매체를 삭제했습니다."
  end

  private

  # 관리자 경로는 다국어 scope 밖에 있으므로 locale 쿼리 문자열을 붙이지 않는다.
  def default_url_options
    { locale: nil }
  end

  def require_admin!
    return if current_user&.admin?

    sign_out(current_user) if current_user
    redirect_to new_user_session_path(locale: nil), alert: "관리자 로그인이 필요합니다."
  end

  # CaseStudy#to_param 은 slug 이므로 관리 화면에서도 기본키 조회를 사용하지 않는다.
  def set_case_study
    @case_study = CaseStudy.find_by!(slug: params[:id])
  end

  def case_study_params
    params.require(:case_study).permit(
      :slug, :title_ko, :title_en, :industry,
      :summary_ko, :summary_en, :body_html_ko, :body_html_en,
      :hero_image, :published, :published_at, :position
    )
  end

  def case_medium_params
    params.require(:case_medium).permit(
      :kind, :title, :caption, :position, :youtube_url, :pdf, :embed_html
    )
  end
end
