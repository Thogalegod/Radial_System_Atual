Rails.application.routes.draw do
  resources :medium_voltage_transformers
  resources :bt_options
  resources :locations
  resources :statuses
  root 'sessions#new'

  get    'login',  to: 'sessions#new'
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get  'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  get 'dashboard', to: 'users#show'

  resources :clients do
    member do
      get :contacts
    end
  end
end
