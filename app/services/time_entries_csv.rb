require "csv"

class TimeEntriesCsv
  HEADERS = %w[Date Client Project Subproject Hours Rate Amount Description Invoiced].freeze

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
      entry.project.client.name,
      entry.project.name,
      entry.subproject&.name,
      format("%.2f", entry.hours),
      format("%.2f", entry.hourly_rate),
      format("%.2f", entry.amount),
      entry.description,
      entry.invoiced? ? "Yes" : "No"
    ]
  end
end
