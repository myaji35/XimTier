class CaseStudy < ApplicationRecord
  RESERVED_SLUGS = %w[manufacturing hospital public smart-city finance retail logistics energy education telecom].freeze

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

  private

  def pick(attr, locale)
    en = self[:"#{attr}_en"]
    (locale.to_s == "en" && en.present?) ? en : self[:"#{attr}_ko"]
  end

  def set_published_at
    self.published_at ||= Time.current if published?
  end
end
