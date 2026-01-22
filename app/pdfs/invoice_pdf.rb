class InvoicePdf
  include Prawn::View

  def initialize(invoice)
    @invoice = invoice
    @client = invoice.client
  end

  def document
    @document ||= Prawn::Document.new(
      page_size: "A4",
      margin: [ 50, 50, 50, 50 ]
    )
  end

  def render_pdf
    header
    move_down 30
    invoice_details
    move_down 30
    client_info
    move_down 30
    line_items_table
    move_down 20
    totals
    if @invoice.notes.present?
      move_down 30
      notes
    end
    footer
    document.render
  end

  private

  def header
    text "INVOICE", size: 28, style: :bold
    move_down 5
    text @invoice.number, size: 14, color: "666666"
  end

  def invoice_details
    data = [
      [ "Issue Date:", @invoice.issued_at.strftime("%B %d, %Y") ],
      [ "Due Date:", @invoice.due_at.strftime("%B %d, %Y") ],
      [ "Status:", @invoice.status.upcase ]
    ]

    table(data, cell_style: { borders: [], padding: [ 2, 0 ] }) do
      column(0).font_style = :bold
      column(0).width = 100
    end
  end

  def client_info
    text "Bill To:", size: 10, style: :bold, color: "666666"
    move_down 5
    text @client.name, size: 14, style: :bold
    if @client.email.present?
      text @client.email, size: 10, color: "666666"
    end
    if @client.address.present?
      move_down 5
      text @client.address, size: 10
    end
  end

  def line_items_table
    data = [ [ "Description", "Hours", "Rate", "Amount" ] ]

    @invoice.line_items.each do |item|
      data << [
        item.description,
        format("%.2f", item.quantity),
        format_currency(item.unit_price),
        format_currency(item.total)
      ]
    end

    table(data, header: true, width: bounds.width) do
      row(0).font_style = :bold
      row(0).background_color = "f5f5f5"
      cells.padding = [ 8, 10 ]
      cells.borders = [ :bottom ]
      cells.border_color = "dddddd"
      column(1).align = :right
      column(2).align = :right
      column(3).align = :right
      column(0).width = 280
    end
  end

  def totals
    total_data = [
      [ "Total", format_currency(@invoice.total) ]
    ]

    table(total_data, position: :right, width: 200) do
      cells.borders = []
      cells.padding = [ 5, 10 ]
      row(0).font_style = :bold
      row(0).size = 14
      column(1).align = :right
    end
  end

  def notes
    text "Notes", size: 10, style: :bold, color: "666666"
    move_down 5
    text @invoice.notes, size: 10
  end

  def footer
    bounding_box([ 0, 30 ], width: bounds.width, height: 30) do
      stroke_horizontal_rule
      move_down 10
      text "Thank you for your business!", size: 10, align: :center, color: "666666"
    end
  end

  def format_currency(amount)
    "$#{'%.2f' % amount}"
  end
end
