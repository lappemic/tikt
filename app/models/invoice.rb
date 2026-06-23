class Invoice < ApplicationRecord
  belongs_to :client
  has_many :line_items, class_name: "InvoiceLineItem", dependent: :destroy
  accepts_nested_attributes_for :line_items, allow_destroy: true

  enum :status, { draft: "draft", sent: "sent", billed: "billed", paid: "paid" }

  validates :number, presence: true, uniqueness: true
  validates :issued_at, presence: true
  validates :due_at, presence: true
  validates :status, presence: true

  before_validation :generate_number, on: :create
  before_validation :set_default_dates, on: :create

  scope :recent, -> { order(issued_at: :desc) }

  def recalculate_total!
    update!(total_cents: line_items.sum(:total_cents))
  end

  def total
    total_cents / 100.0
  end

  def overdue?
    !paid? && due_at < Date.current
  end

  def can_send?
    finalizable?
  end

  # Marking an invoice as already billed is, like sending, a finalization step
  # available only from draft.
  def can_bill?
    finalizable?
  end

  # True once the invoice has been issued to the client (emailed or billed
  # externally) and is awaiting payment. Used to gate the "Mark as Paid" flow.
  def issued?
    sent? || billed?
  end

  def mark_as_sent!
    update!(status: :sent)
  end

  def mark_as_billed!
    update!(status: :billed)
  end

  def mark_as_paid!
    update!(status: :paid)
  end

  private

  # A draft invoice with at least one line item can be finalized — either
  # emailed (sent) or recorded as billed externally.
  def finalizable?
    draft? && line_items.any?
  end

  def generate_number
    return if number.present?

    year = Date.current.year
    last_invoice = Invoice.where("number LIKE ?", "INV-#{year}-%").order(:number).last
    sequence = if last_invoice
      last_invoice.number.split("-").last.to_i + 1
    else
      1
    end
    self.number = "INV-#{year}-#{sequence.to_s.rjust(3, '0')}"
  end

  def set_default_dates
    self.issued_at ||= Date.current
    self.due_at ||= issued_at + 30.days
  end
end
