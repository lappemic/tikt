module Portal
  class DashboardController < BaseController
    def show
      @projects = current_client.projects.includes(:subprojects, :time_entries).order(:name)
      @recent_entries = current_client.time_entries.includes(:project, :subproject).recent.limit(10)
      @recent_invoices = current_client.invoices.recent.limit(5)
      @total_hours = current_client.total_hours
    end
  end
end
