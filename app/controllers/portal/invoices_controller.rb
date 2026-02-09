module Portal
  class InvoicesController < BaseController
    def index
      @invoices = current_client.invoices.recent
    end

    def show
      @invoice = current_client.invoices.find(params[:id])
    end
  end
end
