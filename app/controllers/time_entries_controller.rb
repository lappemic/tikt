class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: %i[show edit update destroy]

  def index
    @time_entries = TimeEntry.includes(project: :client).recent
    @projects = Project.active.includes(:client).order(:name)
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
end
