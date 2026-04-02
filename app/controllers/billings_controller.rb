class BillingsController < ApplicationController
  before_action :set_project, only: [:create]
  before_action :set_billing, only: [:destroy]

  def create
    @billing = @project.billings.build(billing_params)

    respond_to do |format|
      if @billing.save
        format.turbo_stream
        format.html { redirect_to @project, notice: "Billing recorded." }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_billing",
            partial: "billings/form",
            locals: { project: @project, billing: @billing }
          )
        end
        format.html { redirect_to @project, alert: "Could not record billing." }
      end
    end
  end

  def destroy
    @billing.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @project, notice: "Billing deleted." }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_billing
    @billing = Billing.find(params[:id])
    @project = @billing.project
  end

  def billing_params
    params.require(:billing).permit(:date, :hours, :amount, :note)
  end
end
