module Portal
  class BaseController < ApplicationController
    layout "portal"
    before_action :authenticate_client!

    private

    def authenticate_client!
      unless current_client
        redirect_to portal_login_path, alert: "Please log in to continue."
      end
    end

    def current_client
      @current_client ||= Client.find_by(id: session[:client_id], portal_enabled: true)
    end
    helper_method :current_client
  end
end
