module Portal
  class SessionsController < ApplicationController
    include PortalAuthentication

    layout "portal"
    rate_limit to: 10, within: 1.minute, only: :create

    def new
      redirect_to portal_root_path if current_client
    end

    def create
      client = Client.find_by(email: params[:email])

      if client&.portal_access? && client.authenticate(params[:password])
        session[:client_id] = client.id
        redirect_to portal_root_path, notice: "Welcome back, #{client.name}."
      else
        flash.now[:alert] = "Invalid email or password."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      session.delete(:client_id)
      redirect_to portal_login_path, notice: "Logged out."
    end
  end
end
