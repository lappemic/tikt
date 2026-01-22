class InvoiceGenerator
  def initialize(client:, time_entry_ids:)
    @client = client
    @time_entries = client.time_entries.uninvoiced.where(id: time_entry_ids)
  end

  def call
    return nil if @time_entries.empty?

    ActiveRecord::Base.transaction do
      invoice = @client.invoices.create!

      @time_entries.each do |entry|
        invoice.line_items.create!(
          time_entry: entry,
          description: "#{entry.project.name}: #{entry.description.presence || entry.date.strftime('%b %d')}",
          quantity: entry.hours,
          unit_price_cents: (entry.hourly_rate * 100).to_i
        )
        entry.update!(invoiced: true)
      end

      invoice
    end
  end
end
