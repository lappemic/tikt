Rails.application.routes.draw do
  root "dashboard#show"

  resources :clients do
    resources :projects, shallow: true do
      resources :subprojects, shallow: true
    end
  end

  resources :time_entries
  resources :projects, only: [] do
    get :subprojects, on: :member
  end
  resources :invoices do
    member do
      post :send_invoice
      post :mark_paid
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
