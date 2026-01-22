class TimeEntry < ApplicationRecord
  belongs_to :project
  belongs_to :subproject, optional: true
  has_one :client, through: :project
  has_one :invoice_line_item, dependent: :nullify

  validates :date, presence: true
  validates :hours, presence: true, numericality: { greater_than: 0 }
  validate :subproject_belongs_to_project

  scope :uninvoiced, -> { where(invoiced: false) }
  scope :invoiced, -> { where(invoiced: true) }
  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, -> { order(date: :desc, created_at: :desc) }
  scope :today, -> { where(date: Date.current) }
  scope :this_week, -> { where(date: Date.current.beginning_of_week..Date.current.end_of_week) }

  def hourly_rate
    project.effective_hourly_rate
  end

  def amount_cents
    (hours * hourly_rate * 100).to_i
  end

  def amount
    amount_cents / 100.0
  end

  private

  def subproject_belongs_to_project
    return unless subproject.present?
    return if subproject.project_id == project_id

    errors.add(:subproject, "must belong to the selected project")
  end
end
