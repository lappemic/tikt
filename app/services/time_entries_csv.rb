require "csv"

class TimeEntriesCsv
  HEADERS = %w[Date Client Project Subproject Hours Rate Amount Description Invoiced].freeze
  FORMULA_PREFIXES = %W[= + - @ \t \r].freeze

  def initialize(time_entries)
    @time_entries = time_entries
  end

  def generate
    CSV.generate do |csv|
      csv << HEADERS
      @time_entries.each { |entry| csv << row_for(entry) }
    end
  end

  private

  def row_for(entry)
    [
      entry.date.iso8601,
      escape(entry.project.client.name),
      escape(entry.project.name),
      escape(entry.subproject&.name),
      format("%.2f", entry.hours),
      format("%.2f", entry.hourly_rate),
      format("%.2f", entry.amount),
      escape(entry.description),
      entry.invoiced? ? "Yes" : "No"
    ]
  end

  # Prefix free-text cells starting with =, +, -, @, tab, or CR with a single
  # quote so spreadsheet apps render them as text instead of evaluating them
  # as formulas.
  def escape(value)
    return value if value.nil?

    str = value.to_s
    FORMULA_PREFIXES.any? { |p| str.start_with?(p) } ? "'#{str}" : str
  end
end
