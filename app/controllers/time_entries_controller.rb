class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: %i[show edit update destroy]

  def index
    @time_entries = TimeEntry.includes(project: :client).recent
    @projects = Project.active.includes(:client).order("clients.name, projects.name")
    @clients = Client.order(:name)

    respond_to do |format|
      format.html
      format.csv do
        send_data TimeEntriesCsv.new(filtered_time_entries).generate,
          filename: "time-entries-#{Date.current.iso8601}.csv",
          type: "text/csv"
      end
    end
  end

  def show
  end

  def new
    @time_entry = TimeEntry.new(date: Date.current)
  end

  def edit
  end

  def create
    @time_entry = TimeEntry.new(time_entry_params)

    respond_to do |format|
      if @time_entry.save
        format.turbo_stream
        format.html { redirect_to time_entries_path, notice: "Time entry logged." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_time_entry", partial: "form", locals: { time_entry: @time_entry }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @time_entry.update(time_entry_params)
        format.turbo_stream
        format.html { redirect_to time_entries_path, notice: "Time entry updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @time_entry.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to time_entries_path, notice: "Time entry deleted." }
    end
  end

  private

  def set_time_entry
    @time_entry = TimeEntry.find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:project_id, :subproject_id, :date, :hours, :description)
  end

  def filtered_time_entries
    scope = TimeEntry.includes(project: :client).recent
    if params[:project_id].present?
      scope = scope.where(project_id: params[:project_id])
    elsif params[:client_id].present?
      scope = scope.where(projects: { client_id: params[:client_id] })
    end
    scope.where(date: parse_date(params[:start_date])..parse_date(params[:end_date]))
  end

  def parse_date(value)
    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end
end
