class SendInvoiceJob < ApplicationJob
  queue_as :default

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    return if invoice.paid?

    InvoiceMailer.send_invoice(invoice).deliver_now
  end
end
