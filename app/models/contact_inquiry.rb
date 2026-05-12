class ContactInquiry < ApplicationRecord
  enum :industry, {
    other:         0,
    manufacturing: 1,
    hospital:      2,
    public_sector: 3,
    finance:       4,
    smart_city:    5
  }

  validates :name,    presence: true, length: { maximum: 100 }
  validates :email,   presence: true, format: URI::MailTo::EMAIL_REGEXP
  validates :message, presence: true, length: { maximum: 5000 }
  validates :locale,  inclusion: { in: %w[ko en] }

  scope :recent,    -> { order(created_at: :desc) }
  scope :unhandled, -> { where(handled: false) }
end
