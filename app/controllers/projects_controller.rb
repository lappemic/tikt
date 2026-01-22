class ProjectsController < ApplicationController
  before_action :set_client, only: %i[new create]
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.includes(:client).order("clients.name, projects.name")
  end

  def show
    @subprojects = @project.subprojects.order(:name)
    @time_entries = @project.time_entries.recent.limit(20)
  end

  def new
    @project = @client.projects.build
  end

  def edit
  end

  def create
    @project = @client.projects.build(project_params)

    if @project.save
      redirect_to @project.client, notice: "Project created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project.client, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    client = @project.client
    @project.destroy
    redirect_to client, notice: "Project deleted."
  end

  def subprojects
    @project = Project.find(params[:id])
    @subprojects = @project.subprojects.active.order(:name)

    render json: @subprojects.map { |sp| { id: sp.id, name: sp.name } }
  end

  private

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :hourly_rate, :budget, :status)
  end
end
