class Avo::Resources::CaseMedium < Avo::BaseResource
  self.includes = [ :case_study, { pdf_attachment: :blob } ]
  self.title = :title

  def fields
    field :id,          as: :id
    field :case_study,  as: :belongs_to
    field :kind,        as: :select, options: CaseMedium.kinds.keys.index_by(&:itself),
          display_with_value: true, help: "youtube / pdf / html 중 선택"
    field :title,       as: :text, help: "매체 제목 (선택)"
    field :youtube_url, as: :text, hide_on: :index, help: "kind가 youtube일 때. watch·youtu.be·shorts URL 모두 지원"
    field :pdf,         as: :file, hide_on: :index, help: "kind가 pdf일 때 파일 첨부"
    field :embed_html,  as: :textarea, hide_on: :index, help: "kind가 html일 때 본문 HTML"
    field :caption,     as: :textarea, hide_on: :index
    field :position,    as: :number, help: "상세 페이지 내 표시 순서"
    field :created_at,  as: :date_time, sortable: true, only_on: :index
  end
end
