Rails.application.routes.draw do
  # Rotas para locações
  resources :rentals do
    member do
      patch :complete
    end
    resources :rental_equipments, only: [:index, :create, :destroy]
    resources :rental_billing_periods do
      member do
        get :receipt
        get :receipt_pdf
      end
    end
  end
  
  get "dashboard/index"
  # Rotas para o sistema genérico de equipamentos
  resources :equipment_types do
    resources :equipment_features, except: [:show] do
      resources :equipment_feature_options, except: [:show]
    end
    member do
      get :equipment_features, defaults: { format: :json }
      get :edit_modal, defaults: { format: :json }
      post :duplicate
      get :manage
      patch :update_manage
    end
  end
  
  # Rotas independentes para características (apenas para acesso direto)
  resources :equipment_features, only: [:show, :new, :create, :edit, :update, :destroy]
  
  resources :equipments do
    collection do
      get :filter
      get :export_csv
      get :select_type
    end
    member do
      get :photos, defaults: { format: :json }
    end
  end
  
  # Rotas para clientes (mantidas do sistema anterior)
  resources :clients do
    member do
      get :contacts
    end
  end

  # Rotas de autenticação
  root 'sessions#new'

  get    'login',  to: 'sessions#new'
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get  'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  get 'dashboard', to: 'dashboard#index'
end
