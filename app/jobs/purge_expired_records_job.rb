# 처리방침 3항이 공표한 보유기간을 실제로 이행한다. — ISS-009
#
# 방침에 적어둔 기간이 지나도 파기하지 않으면, 그 자체가 공표한 방침의 위반이다
# (개인정보보호법 제30조 제3항: 방침과 실제가 다르면 정보주체에 유리한 쪽 적용).
#
# 방침 3항이 정한 기간:
#   - 데모 신청·문의: 미팅 종료 후 1년 또는 사용자 삭제 요청 시까지
#   - IR 자료 신청 기록: 1년 (다운로드 토큰 자체는 발급 후 24시간이면 무효)
#   - 웹서버 접속 로그: 14일 후 자동 삭제
#   - Google Analytics 데이터: 14개월 후 자동 삭제
#
# 별도 삭제 요청은 개인정보보호 연락처를 통해 처리한다.
class PurgeExpiredRecordsJob < ApplicationJob
  queue_as :default

  RETENTION = 1.year

  def perform
    demo = purge_finished_demo_requests
    inquiries = purge_old_inquiries
    downloads = purge_old_downloads

    Rails.logger.info(
      "[PurgeExpiredRecords] demo_requests=#{demo} contact_inquiries=#{inquiries} downloads=#{downloads}"
    )
  end

  private

  # 방침 기준은 "미팅 종료 후" 1년이다. 종료 시각을 따로 남기지 않으므로
  # completed/cancelled 로 전환된 시각(updated_at)을 종료 시각으로 본다.
  # 아직 진행 중(pending/scheduled)인 건은 종료 자체가 없었으므로 대상이 아니다.
  def purge_finished_demo_requests
    scope = DemoRequest.where(status: %w[completed cancelled])
                       .where(updated_at: ..RETENTION.ago)
    # dependent: :destroy 로 comments·data_file 까지 연쇄시키려면 destroy_all 이어야 한다.
    # delete_all 은 첨부파일을 남긴다.
    scope.destroy_all.size
  end

  # contact_inquiries 는 User 와 무관한 별도 테이블이라 회원탈퇴로 지워지지 않는다.
  # 미팅 개념이 없으므로 접수 시각 기준.
  def purge_old_inquiries
    ContactInquiry.where(created_at: ..RETENTION.ago).destroy_all.size
  end

  # 토큰은 발급 24시간 뒤 무효가 되지만(Download#token_expired?),
  # 신청 기록은 데모·문의와 같은 1년 기준으로 보유한다 — 방침 3항에 그렇게 명시했다.
  def purge_old_downloads
    Download.where(created_at: ..RETENTION.ago).destroy_all.size
  end
end
