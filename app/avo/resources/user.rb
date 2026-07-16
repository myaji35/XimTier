class Avo::Resources::User < Avo::BaseResource
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
    field :industry, as: :select, options: ::User.industries.keys.index_by(&:itself)
    # 권한 상승 방지 (ISS-008) — 열람만 허용. 부여/회수는 rails 콘솔 또는 감사 가능한 전용 경로로.
    field :admin,    as: :boolean, readonly: true
    field :locale,   as: :text
    field :demo_requests, as: :has_many
    field :created_at, as: :date_time, sortable: true, only_on: :index
  end
end
