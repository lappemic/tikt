class ClientsController < ApplicationController
  before_action :set_client, only: %i[show edit update destroy]

  def index
    @clients = Client.includes(:projects).order(:name)
  end

  def show
    @projects = @client.projects.includes(:time_entries).order(:name)
    @uninvoiced_entries = @client.uninvoiced_time_entries.includes(:project).recent
    @invoices = @client.invoices.recent.limit(5)
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to @client, notice: "Client created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Client updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: "Client deleted."
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :address, :hourly_rate)
  end
end
