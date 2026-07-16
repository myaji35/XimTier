class AddTokenIssuedAtToDownloads < ActiveRecord::Migration[8.1]
  # 처리방침 3항이 "IR 다운로드 토큰: 발급 후 24시간" 을 공표했으나 만료 로직이 없었다. — ISS-009
  #
  # created_at 을 쓰지 않는 이유: DownloadsController#create 가
  # find_or_initialize_by(email:, asset:) 로 기존 레코드를 재사용하므로,
  # 재신청해도 created_at 이 그대로라 메일을 받자마자 만료된 링크가 된다.
  def change
    add_column :downloads, :token_issued_at, :datetime

    # 기존 토큰은 발급 시각을 알 수 없다. created_at 으로 채운다 —
    # 이 경우엔 소급이 사실에 부합한다(토큰은 생성 시점에 발급되므로).
    # 24시간이 지난 것들은 자연히 만료 상태가 되며, 이는 공표한 방침대로다.
    up_only do
      execute "UPDATE downloads SET token_issued_at = created_at WHERE token_issued_at IS NULL"
    end
  end
end
