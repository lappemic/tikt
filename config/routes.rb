Rails.application.routes.draw do
  root "dashboard#show"

  resources :clients do
    resources :projects, shallow: true do
      # Exclude :index — SubprojectsController has no index action, and
      # GET /projects/:id/subprojects is owned by ProjectsController#subprojects
      # below (used by the time-entry form to populate subprojects via JSON).
      resources :subprojects, shallow: true, except: [ :index ]
      resources :billings, only: [:create, :destroy], shallow: true
    end
  end

  resources :time_entries
  resources :projects, only: [:index] do
    get :subprojects, on: :member
  end
  resources :invoices do
    member do
      post :send_invoice
      post :mark_paid
    end
  end

  # Portal login/logout
  scope :portal do
    get "login", to: "portal/sessions#new", as: :portal_login
    post "login", to: "portal/sessions#create"
    delete "logout", to: "portal/sessions#destroy", as: :portal_logout
  end

  namespace :portal do
    root "dashboard#show"
    resources :projects, only: [ :index, :show ]
    resources :invoices, only: [ :index, :show ]
    resources :time_entries, only: [ :index ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
