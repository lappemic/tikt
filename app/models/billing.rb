class Billing < ApplicationRecord
  belongs_to :project

  validates :date, presence: true
  validates :hours, presence: true, numericality: { greater_than: 0 }
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :recent, -> { order(date: :desc, created_at: :desc) }
  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }

  def amount
    amount_cents / 100.0
  end

  def amount=(value)
    self.amount_cents = value.present? ? (value.to_f * 100).round : nil
  end
end
