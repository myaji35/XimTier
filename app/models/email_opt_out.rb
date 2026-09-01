class EmailOptOut < ApplicationRecord
  before_validation :normalize_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :source, presence: true

  def self.opted_out?(email)
    exists?(email: normalize(email))
  end

  def self.normalize(email)
    email.to_s.strip.downcase
  end

  private

  def normalize_email
    self.email = self.class.normalize(email)
  end
end
