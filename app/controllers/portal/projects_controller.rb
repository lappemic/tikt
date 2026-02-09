module Portal
  class ProjectsController < BaseController
    def index
      @projects = current_client.projects.includes(:subprojects, :time_entries).order(:name)
    end

    def show
      @project = current_client.projects.find(params[:id])
      @subprojects = @project.subprojects.includes(:time_entries).order(:name)
      @time_entries = @project.time_entries.includes(:subproject).recent
    end
  end
end
