class Avo::Resources::Download < Avo::BaseResource
  # Avo 는 번역 결과에 humanize 를 걸어 "IR 자료 신청" 을 "Ir 자료 신청" 으로 바꾼다
  # (avo/resources/base.rb:222). 약어를 살리려면 이름을 직접 정의해 우회해야 한다.
  def self.name = "IR 자료 신청"
  def self.plural_name = "IR 자료 신청"
  def self.navigation_label = plural_name

  # 투자자 우선 확인용. VC → 법인 → 미판별 순으로 보이게 한다.
  self.default_sort_column = :created_at
  self.default_sort_direction = :desc

  self.search = {
    query: -> {
      query.where("email LIKE :q OR name LIKE :q OR company LIKE :q", q: "%#{params[:q]}%")
    }
  }

  def fields
    field :id,       as: :id
    # 이메일 도메인 기반 분류. 발송을 막지는 않고 후속 연락 판단용 신호다.
    field :investor_kind, as: :text, name: "구분", sortable: true, readonly: true,
          format_using: -> { record.investor_label },
          help: "VC 목록·회사 도메인으로 자동 판별합니다. 무료메일이면 미판별."
    field :email,    as: :text
    field :name,     as: :text
    field :company,  as: :text
    field :role,     as: :text
    field :asset,    as: :select, options: Download.assets.keys.index_by(&:itself)
    field :downloaded_count, as: :number, name: "다운로드",
          help: "0이면 신청만 하고 열어보지 않은 것입니다."
    field :download_token, as: :text, hide_on: :index, readonly: true
    field :token_issued_at, as: :date_time, hide_on: :index, readonly: true,
          help: "발급 후 24시간이 지나면 링크가 무효가 됩니다."
    field :privacy_agreed_at, as: :date_time, hide_on: :index, readonly: true,
          name: "개인정보 동의"
    field :locale,   as: :text
    field :created_at, as: :date_time, sortable: true, only_on: :index
  end
end
