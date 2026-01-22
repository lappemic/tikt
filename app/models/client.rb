class Client < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :time_entries, through: :projects

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }

  scope :with_uninvoiced_time, -> {
    joins(:time_entries).where(time_entries: { invoiced: false }).distinct
  }

  def uninvoiced_time_entries
    time_entries.uninvoiced
  end

  def uninvoiced_hours
    uninvoiced_time_entries.sum(:hours)
  end

  def total_billed
    invoices.paid.sum(:total_cents) / 100.0
  end

  def total_hours
    time_entries.sum(:hours)
  end

  def billed_hours
    time_entries.invoiced.sum(:hours)
  end
end
