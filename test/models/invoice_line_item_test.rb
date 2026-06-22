require "test_helper"

class InvoiceLineItemTest < ActiveSupport::TestCase
  test "unit_price= converts dollars to cents" do
    item = InvoiceLineItem.new(unit_price: 150.50)
    assert_equal 15_050, item.unit_price_cents
  end

  test "unit_price= rounds to the nearest cent without float truncation" do
    item = InvoiceLineItem.new(unit_price: 200.10)
    assert_equal 20_010, item.unit_price_cents
  end

  test "calculate_total multiplies quantity by unit price" do
    item = invoice_line_items(:one)
    item.quantity = 3
    item.unit_price_cents = 10_000
    item.valid?
    assert_equal 30_000, item.total_cents
  end

  test "calculate_total rounds fractional cents instead of truncating" do
    item = invoice_line_items(:one)
    item.quantity = 0.29
    item.unit_price_cents = 100 # 0.29 * 100 = 28.9999.. -> 29, not 28
    item.valid?
    assert_equal 29, item.total_cents
  end

  test "destroying a line item marks its time entry as uninvoiced" do
    item = invoice_line_items(:one)
    entry = item.time_entry
    entry.update!(invoiced: true)

    item.destroy

    assert_not entry.reload.invoiced?
  end
end
