Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  root 'pages#index'
  get    'render_form/', to: 'pages#render_form'

  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get    '/details', to: 'clusters#show'
  post   '/delete',  to: 'clusters#destroy'
  post   '/create',  to: 'clusters#create'

  post   '/new',     to: 'infrastructures#new'

  delete '/delete_assignment', to: 'assignments#destroy'
  post   '/create_assignment', to: 'assignments#create'

  get    '*unmatched_route', to: 'application#not_found'

  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
