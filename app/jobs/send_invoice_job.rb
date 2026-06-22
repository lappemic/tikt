class SendInvoiceJob < ApplicationJob
  queue_as :default

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    # Only a sent invoice should have a delivery running; billed/draft/paid
    # invoices must not be emailed (e.g. a duplicate or retried job).
    return unless invoice.sent?

    InvoiceMailer.send_invoice(invoice).deliver_now
  end
end
