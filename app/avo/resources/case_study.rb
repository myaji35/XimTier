class Avo::Resources::CaseStudy < Avo::BaseResource
  self.includes = [ :case_media, :case_comments, { hero_image_attachment: :blob } ]
  self.title = :title_ko
  self.search = {
    query: -> { query.where("title_ko LIKE :q OR title_en LIKE :q OR slug LIKE :q", q: "%#{params[:q]}%") }
  }

  def fields
    field :id,          as: :id
    field :slug,        as: :text, help: "URL에 쓰입니다. 소문자·숫자·하이픈만. 예: incheon-smart-factory"
    field :title_ko,    as: :text, required: true
    field :title_en,    as: :text, hide_on: :index
    field :industry,    as: :text, help: "태그/필터용 (선택). 예: 제조, 병원"
    field :summary_ko,  as: :textarea, hide_on: :index
    field :summary_en,  as: :textarea, hide_on: :index
    field :hero_image,  as: :file, is_image: true, hide_on: :index,
          help: "카드 썸네일. 비우면 첫 유튜브 영상 썸네일을 사용합니다."
    field :body_html_ko, as: :textarea, hide_on: :index, help: "상세 본문 HTML (선택)"
    field :body_html_en, as: :textarea, hide_on: :index
    field :published,   as: :boolean
    field :published_at, as: :date_time, hide_on: :index
    field :likes_count, as: :number, readonly: true, only_on: %i[index show]
    field :position,    as: :number, help: "정렬 우선순위 (선택)"
    field :created_at,  as: :date_time, sortable: true, only_on: :index

    field :case_media,    as: :has_many
    field :case_comments, as: :has_many
  end
end
