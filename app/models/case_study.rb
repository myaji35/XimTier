class CaseStudy < ApplicationRecord
  RESERVED_SLUGS = %w[manufacturing hospital public smart-city finance retail logistics energy education telecom ga-branch].freeze

  has_many :case_media,    -> { order(:position) }, dependent: :destroy
  has_many :case_comments, dependent: :destroy
  has_many :case_likes,    dependent: :destroy
  has_one_attached :hero_image

  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9\-]+\z/, message: "소문자·숫자·하이픈만" }
  validates :slug, exclusion: { in: RESERVED_SLUGS, message: "예약된 경로와 충돌합니다" }
  validates :title_ko, presence: true

  before_validation :set_published_at

  scope :published, -> { where(published: true) }
  scope :recent,     -> { order(published_at: :desc, created_at: :desc) }
  scope :most_liked, -> { order(likes_count: :desc, published_at: :desc) }

  def to_param = slug

  # 로케일별 표시 헬퍼 — 해당 로케일 값이 비면 ko로 fallback
  def title(locale = I18n.locale)   = pick(:title, locale)
  def summary(locale = I18n.locale) = pick(:summary, locale)
  def body_html(locale = I18n.locale) = pick(:body_html, locale)

  # 카드 썸네일: hero_image 없으면 첫 유튜브 매체의 썸네일 URL
  def thumbnail_youtube_id
    case_media.detect(&:youtube?)&.youtube_id
  end

  # PDF 첫 페이지를 썸네일로 쓴다. previewable? 는 poppler(pdftoppm) 유무에 따라
  # 달라지므로 반드시 확인한다 — 없는 환경에서는 nil 을 돌려 다음 폴백으로 넘긴다.
  def thumbnail_pdf
    case_media.detect { |m| m.pdf.attached? && m.pdf.previewable? }&.pdf
  end

  # 이미지가 없는 html 매체용. 본문 앞부분을 그대로 카드에 얹는다.
  def thumbnail_excerpt
    html = case_media.detect { |m| m.embed_html.present? }&.embed_html
    return nil if html.blank?

    ActionController::Base.helpers.strip_tags(html).squish.truncate(90).presence
  end

  private

  def pick(attr, locale)
    en = self[:"#{attr}_en"]
    (locale.to_s == "en" && en.present?) ? en : self[:"#{attr}_ko"]
  end

  def set_published_at
    self.published_at ||= Time.current if published?
  end
end
