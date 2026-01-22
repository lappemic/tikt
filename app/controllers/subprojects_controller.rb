class SubprojectsController < ApplicationController
  before_action :set_project, only: %i[new create]
  before_action :set_subproject, only: %i[show edit update destroy]

  def show
    @time_entries = @subproject.time_entries.recent.limit(20)
  end

  def new
    @subproject = @project.subprojects.build
  end

  def edit
  end

  def create
    @subproject = @project.subprojects.build(subproject_params)

    if @subproject.save
      redirect_to @project, notice: "Subproject created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @subproject.update(subproject_params)
      redirect_to @subproject.project, notice: "Subproject updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    project = @subproject.project
    @subproject.destroy
    redirect_to project, notice: "Subproject deleted."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_subproject
    @subproject = Subproject.find(params[:id])
  end

  def subproject_params
    params.require(:subproject).permit(:name, :description, :budget, :status)
  end
end
