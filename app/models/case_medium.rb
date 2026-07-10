class CaseMedium < ApplicationRecord
  belongs_to :case_study
  has_one_attached :pdf

  enum :kind, { youtube: 0, pdf: 1, html: 2 }

  validates :youtube_url, presence: true, if: :youtube?
  validate  :pdf_attached, if: :pdf?
  validates :embed_html,  presence: true, if: :html?

  # 유튜브 URL(watch·youtu.be·shorts·embed)에서 11자 videoId 추출
  def youtube_id
    return nil unless youtube? && youtube_url.present?
    youtube_url[%r{(?:v=|youtu\.be/|embed/|shorts/)([A-Za-z0-9_-]{11})}, 1]
  end

  def youtube_embed_url
    id = youtube_id
    id && "https://www.youtube-nocookie.com/embed/#{id}"
  end

  private

  def pdf_attached
    errors.add(:pdf, "PDF 파일을 첨부하세요") unless pdf.attached?
  end
end
