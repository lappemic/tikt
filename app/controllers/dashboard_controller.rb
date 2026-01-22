class DashboardController < ApplicationController
  def show
    @today_entries = TimeEntry.today.includes(project: :client).recent
    @today_hours = @today_entries.sum(:hours)
    @projects = Project.active.includes(:client).order(:name)
  end
end
