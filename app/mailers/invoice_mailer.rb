class InvoiceMailer < ApplicationMailer
  def send_invoice(invoice)
    @invoice = invoice
    @client = invoice.client

    pdf = InvoicePdf.new(invoice).render_pdf

    attachments["#{invoice.number}.pdf"] = {
      mime_type: "application/pdf",
      content: pdf
    }

    mail(
      to: @client.email,
      subject: "Invoice #{@invoice.number}"
    )
  end
end
