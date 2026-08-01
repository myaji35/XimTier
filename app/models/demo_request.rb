class DemoRequest < ApplicationRecord
  DATA_FILE_CONTENT_TYPES = %w[
    text/csv
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    application/json
    text/plain
    application/pdf
  ].freeze

  # 배포 설정에 별도 요청 본문/업로드 상한이 없어 애플리케이션에서 10MB로 제한한다.
  DATA_FILE_MAX_SIZE = 10.megabytes

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_one_attached :data_file

  enum :status, {
    pending:   0,
    scheduled: 1,
    completed: 2,
    cancelled: 3
  }

  validates :data_description, presence: true, length: { maximum: 2000 }
  validates :locale, inclusion: { in: %w[ko en] }
  validate :data_file_is_valid

  scope :recent, -> { order(created_at: :desc) }
  scope :open,   -> { where(status: %w[pending scheduled]) }

  after_update_commit :send_scheduled_email, if: :newly_scheduled?

  private

  def newly_scheduled?
    saved_change_to_status? && status_before_last_save == "pending" && scheduled?
  end

  def send_scheduled_email
    DemoMailer.scheduled(self).deliver_later
  end

  def data_file_is_valid
    return unless data_file.attached?

    unless DATA_FILE_CONTENT_TYPES.include?(data_file.blob.content_type)
      errors.add(:data_file, :invalid_content_type)
    end

    errors.add(:data_file, :file_too_large) if data_file.blob.byte_size > DATA_FILE_MAX_SIZE
  end
end
