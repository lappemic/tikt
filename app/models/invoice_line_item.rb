class InvoiceLineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :time_entry, optional: true

  validates :description, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_cents, presence: true

  before_validation :calculate_total

  after_save :update_invoice_total
  after_destroy :update_invoice_total

  def unit_price
    unit_price_cents / 100.0
  end

  def unit_price=(value)
    self.unit_price_cents = (value.to_f * 100).to_i
  end

  def total
    total_cents / 100.0
  end

  private

  def calculate_total
    self.total_cents = (quantity.to_f * unit_price_cents.to_i).to_i
  end

  def update_invoice_total
    invoice.recalculate_total!
  end
end
