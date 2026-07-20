class Avo::Resources::CaseStudy < Avo::BaseResource
  self.includes = [ :case_media, :case_comments, { hero_image_attachment: :blob } ]
  self.title = :title_ko
  self.search = {
    query: -> { query.where("title_ko LIKE :q OR title_en LIKE :q OR slug LIKE :q", q: "%#{params[:q]}%") }
  }

  # CaseStudy#to_param 이 slug 를 돌려주므로 Avo 가 만드는 링크도 slug 를 담는다.
  # 그런데 Avo 기본 find_record 는 기본키로만 조회해서 id = NULL 이 되고
  # 상세·편집이 전부 404 였다. (ISS-027)
  # 공개 URL 이 slug 를 쓰므로 모델의 to_param 은 두고 조회 쪽을 맞춘다.
  # 숫자로 들어오면 id 로 찾는다 — Avo 내부가 기본키로 부르는 경로(일괄 액션 등)를 깨뜨리지 않기 위함.
  self.find_record_method = -> {
    column = ->(value) { value.to_s.match?(/\A\d+\z/) ? :id : :slug }

    if id.is_a?(Array)
      query.where(slug: id).or(query.where(id: id.grep(/\A\d+\z/)))
    else
      query.find_by!(column.call(id) => id)
    end
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
