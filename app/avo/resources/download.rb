class Avo::Resources::Download < Avo::BaseResource
  # Avo 는 번역 결과에 humanize 를 걸어 "IR 자료 신청" 을 "Ir 자료 신청" 으로 바꾼다
  # (avo/resources/base.rb:222). 약어를 살리려면 이름을 직접 정의해 우회해야 한다.
  def self.name = "IR 자료 신청"
  def self.plural_name = "IR 자료 신청"
  def self.navigation_label = plural_name

  self.search = {
    query: -> {
      query.where("email LIKE :q OR name LIKE :q OR company LIKE :q", q: "%#{params[:q]}%")
    }
  }

  def fields
    field :id,       as: :id
    field :email,    as: :text
    field :name,     as: :text
    field :company,  as: :text
    field :role,     as: :text
    field :asset,    as: :select, options: Download.assets.keys.index_by(&:itself)
    field :downloaded_count, as: :number
    field :download_token, as: :text, hide_on: :index, readonly: true
    field :locale,   as: :text
    field :created_at, as: :date_time, sortable: true, only_on: :index
  end
end
