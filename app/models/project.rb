class Project < ApplicationRecord
  STATUSES = %w[offered accepted rejected finished].freeze

  belongs_to :client
  has_many :time_entries, dependent: :destroy
  has_many :subprojects, dependent: :destroy

  validates :name, presence: true
  validates :hourly_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :active, -> { where(status: "accepted") }
  scope :by_status, ->(status) { where(status: status) }

  def offered? = status == "offered"
  def accepted? = status == "accepted"
  def rejected? = status == "rejected"
  def finished? = status == "finished"
  def active? = accepted?
  def can_log_time? = accepted?

  def effective_hourly_rate
    hourly_rate.presence || client.hourly_rate
  end

  def total_hours
    time_entries.sum(:hours)
  end

  def uninvoiced_hours
    time_entries.uninvoiced.sum(:hours)
  end

  def billed_hours
    time_entries.invoiced.sum(:hours)
  end

  def total_cost_cents
    time_entries.sum { |entry| entry.amount_cents }
  end

  def total_cost
    total_cost_cents / 100.0
  end

  def budget
    budget_cents.present? ? budget_cents / 100.0 : nil
  end

  def budget=(value)
    self.budget_cents = value.present? ? (value.to_f * 100).to_i : nil
  end

  def budget_remaining_cents
    return nil unless budget_cents.present?
    budget_cents - total_cost_cents
  end

  def budget_remaining
    budget_remaining_cents.present? ? budget_remaining_cents / 100.0 : nil
  end

  def budget_percentage_used
    return nil unless budget_cents.present? && budget_cents > 0
    (total_cost_cents.to_f / budget_cents * 100).round(1)
  end
end
