Rails.application.routes.draw do
  get "dashboard/index"
  # Rotas para o sistema genérico de equipamentos
  resources :equipment_types do
    resources :equipment_features, except: [:show] do
      resources :equipment_feature_options, except: [:show]
    end
    member do
      get :equipment_features, defaults: { format: :json }
    end
  end
  
  # Rotas independentes para características
  resources :equipment_features, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  
  resources :equipments do
    collection do
      get :filter
      get :export_csv
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
