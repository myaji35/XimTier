class AddConsentRecords < ActiveRecord::Migration[8.1]
  # 개인정보 수집·이용 동의를 화면 체크로만 확인하고 DB에 남기지 않아
  # 분쟁 시 입증이 불가능했다. 동의 시각을 기록한다. — ISS-001
  #
  # 기존 레코드는 NULL로 남긴다. 실제로 언제 동의했는지 기록이 없으므로
  # created_at 으로 소급 기입하면 사실과 다른 기록이 된다.
  def change
    add_column :users,              :privacy_agreed_at, :datetime
    add_column :contact_inquiries,  :privacy_agreed_at, :datetime
    add_column :downloads,          :privacy_agreed_at, :datetime
  end
end
