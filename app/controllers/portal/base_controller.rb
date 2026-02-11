module Portal
  class BaseController < ApplicationController
    include PortalAuthentication

    layout "portal"
    before_action :authenticate_client!

    private

    def authenticate_client!
      redirect_to portal_login_path, alert: "Please log in to continue." unless current_client
    end
  end
end
