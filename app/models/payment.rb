class Payment < ApplicationRecord
  belongs_to :user

  STATUSES = %w[pending paid failed cancelled].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :amount, numericality: { greater_than: 0, only_integer: true }
  validates :payment_id, presence: true, uniqueness: true

  scope :paid, -> { where(status: "paid") }

  def self.generate_payment_id
    "xim_#{Time.current.strftime("%Y%m%d%H%M%S")}_#{SecureRandom.hex(4)}"
  end

  def paid?
    status == "paid"
  end

  def pending?
    status == "pending"
  end
end
