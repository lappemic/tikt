class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show edit update destroy send_invoice mark_paid]

  def index
    @invoices = Invoice.includes(:client, :line_items).recent
    @status_filter = params[:status]
    @invoices = @invoices.where(status: @status_filter) if @status_filter.present?
  end

  def show
  end

  def new
    @client = Client.find(params[:client_id]) if params[:client_id]
    @clients = Client.with_uninvoiced_time.order(:name)

    if @client
      @uninvoiced_entries = @client.uninvoiced_time_entries.includes(:project).recent
    end
  end

  def create
    @client = Client.find(params[:client_id])
    time_entry_ids = params[:time_entry_ids] || []

    invoice = InvoiceGenerator.new(client: @client, time_entry_ids: time_entry_ids).call

    if invoice
      redirect_to edit_invoice_path(invoice), notice: "Invoice created. Review and finalize below."
    else
      redirect_to new_invoice_path(client_id: @client.id), alert: "Please select at least one time entry."
    end
  end

  def edit
    @line_items = @invoice.line_items.includes(:time_entry)
  end

  def update
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: "Invoice updated."
    else
      @line_items = @invoice.line_items.includes(:time_entry)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @invoice.line_items.each do |item|
      item.time_entry&.update!(invoiced: false)
    end
    @invoice.destroy
    redirect_to invoices_path, notice: "Invoice deleted."
  end

  def send_invoice
    SendInvoiceJob.perform_later(@invoice.id)
    @invoice.mark_as_sent!
    redirect_to @invoice, notice: "Invoice sent to #{@invoice.client.email}."
  end

  def mark_paid
    @invoice.mark_as_paid!
    redirect_to @invoice, notice: "Invoice marked as paid."
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:issued_at, :due_at, :notes)
  end
end
