module PortalAuthentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_client
  end

  private

  def current_client
    @current_client ||= Client.find_by(id: session[:client_id], portal_enabled: true)
  end
end
