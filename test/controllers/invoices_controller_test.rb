require "test_helper"

class InvoicesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "edit page renders editable line items and the mark-as-billed action" do
    invoice = invoices(:one)
    item = invoice.line_items.first

    get edit_invoice_url(invoice)

    assert_response :success
    # Editable line item fields are present
    assert_select "input[name=?]", "invoice[line_items_attributes][0][quantity]"
    assert_select "input[name=?]", "invoice[line_items_attributes][0][unit_price]"
    # The "Mark as Billed" button posts to the mark_billed route
    assert_select "form[action=?]", mark_billed_invoice_path(invoice)
  end

  test "mark_billed marks the invoice as billed without sending an email" do
    invoice = invoices(:one) # draft

    assert_no_enqueued_jobs(only: SendInvoiceJob) do
      post mark_billed_invoice_url(invoice)
    end

    assert_redirected_to invoice_url(invoice)
    assert invoice.reload.billed?
  end

  test "send_invoice enqueues the mailer job and marks the invoice as sent" do
    invoice = invoices(:one) # draft

    assert_enqueued_with(job: SendInvoiceJob) do
      post send_invoice_invoice_url(invoice)
    end

    assert invoice.reload.sent?
  end

  test "update adapts the invoiced value through line item attributes" do
    invoice = invoices(:one)
    item = invoice.line_items.first # qty 10.0 * 15000c = 150000c

    patch invoice_url(invoice), params: {
      invoice: {
        line_items_attributes: { "0" => { id: item.id, quantity: "8", unit_price: "200" } }
      }
    }

    assert_redirected_to invoice_url(invoice)
    assert_equal 160_000, invoice.reload.total_cents # 8 * 20000c
  end

  test "mark_billed is rejected for a non-draft invoice" do
    invoice = invoices(:two) # sent

    post mark_billed_invoice_url(invoice)

    assert_redirected_to invoice_url(invoice)
    assert invoice.reload.sent?, "status should be unchanged"
  end

  test "send_invoice is rejected for a non-draft invoice" do
    invoice = invoices(:two) # sent

    assert_no_enqueued_jobs(only: SendInvoiceJob) do
      post send_invoice_invoice_url(invoice)
    end

    assert invoice.reload.sent?
  end

  test "mark_paid is rejected for a draft invoice" do
    invoice = invoices(:one) # draft

    post mark_paid_invoice_url(invoice)

    assert_redirected_to invoice_url(invoice)
    assert invoice.reload.draft?, "status should be unchanged"
  end

  test "editing a non-draft invoice is blocked" do
    invoice = invoices(:two) # sent
    original_total = invoice.total_cents
    item = invoice.line_items.first

    patch invoice_url(invoice), params: {
      invoice: { line_items_attributes: { "0" => { id: item.id, quantity: "1" } } }
    }

    assert_redirected_to invoice_url(invoice)
    assert_equal original_total, invoice.reload.total_cents
  end

  test "destroying a non-draft invoice is blocked" do
    invoice = invoices(:two) # sent

    assert_no_difference -> { Invoice.count } do
      delete invoice_url(invoice)
    end

    assert_redirected_to invoice_url(invoice)
    assert Invoice.exists?(invoice.id)
  end

  test "update can remove a line item and release its time entry" do
    invoice = invoices(:one)
    item = invoice.line_items.first
    entry = item.time_entry
    entry.update!(invoiced: true)

    patch invoice_url(invoice), params: {
      invoice: {
        line_items_attributes: { "0" => { id: item.id, _destroy: "1" } }
      }
    }

    assert_equal 0, invoice.reload.line_items.count
    assert_not entry.reload.invoiced?
  end
end
