class AddInvestorKindToDownloads < ActiveRecord::Migration[8.1]
  # IR 신청자 분류 결과를 기록한다 (vc / company / unknown).
  # 발송을 막는 용도가 아니라, 대표님이 누구에게 먼저 연락할지 판단할 신호다.
  #
  # 신청 시점에 계산해 저장한다. VC 목록이 나중에 바뀌어도 "그때 어떻게 판단했는지"가
  # 남아야 이력을 신뢰할 수 있다.
  def change
    add_column :downloads, :investor_kind, :string
    add_index  :downloads, :investor_kind

    # 기존 레코드도 같은 기준으로 채운다. 분류는 신청 당시의 이메일에서 계산하므로
    # 소급해도 사실과 어긋나지 않는다.
    up_only do
      Download.reset_column_information
      Download.find_each do |d|
        d.update_column(:investor_kind, InvestorClassifier.call(d.email).kind.to_s)
      end
    end
  end
end
