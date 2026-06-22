require "test_helper"

class InvoiceTest < ActiveSupport::TestCase
  test "billed is a valid status" do
    assert_includes Invoice.statuses.keys, "billed"
  end

  test "mark_as_billed! transitions the invoice to billed" do
    invoice = invoices(:one)
    invoice.mark_as_billed!
    assert invoice.billed?
    assert_equal "billed", invoice.reload.status
  end

  test "issued? is true for sent and billed, false for draft and paid" do
    assert_not invoices(:one).issued?, "draft should not be issued"
    assert invoices(:two).issued?, "sent should be issued"

    invoices(:one).update!(status: :billed)
    assert invoices(:one).issued?, "billed should be issued"

    invoices(:two).update!(status: :paid)
    assert_not invoices(:two).issued?, "paid should not be issued"
  end

  test "updating a line item quantity via nested attributes recalculates the total" do
    invoice = invoices(:one)
    item = invoice.line_items.first # qty 10.0 * 15000c = 150000c

    invoice.update!(line_items_attributes: [ { id: item.id, quantity: 5 } ])

    assert_equal 75_000, invoice.reload.total_cents
  end

  test "updating a line item unit_price via nested attributes recalculates the total" do
    invoice = invoices(:one)
    item = invoice.line_items.first # qty 10.0

    invoice.update!(line_items_attributes: [ { id: item.id, unit_price: 200 } ])

    assert_equal 200_000, invoice.reload.total_cents # 10.0 * 20000c
  end

  test "removing a line item via nested attributes releases its time entry and zeroes the total" do
    invoice = invoices(:one)
    item = invoice.line_items.first
    entry = item.time_entry
    entry.update!(invoiced: true)

    invoice.update!(line_items_attributes: [ { id: item.id, _destroy: "1" } ])

    assert_equal 0, invoice.reload.line_items.count
    assert_equal 0, invoice.total_cents
    assert_not entry.reload.invoiced?
  end
end
