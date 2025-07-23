Rails.application.routes.draw do
  root 'sessions#new'

  get    'login',  to: 'sessions#new'
  post   'login',  to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get  'signup', to: 'users#new'
  post 'signup', to: 'users#create'

  get 'dashboard', to: 'users#show'

  resources :clients
end
