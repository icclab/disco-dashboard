Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root 'groups#index'
  get    '/faq',   to: 'pages#faq'
  get    '/debug', to: 'pages#debug'

  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  get    '/clusters',              to: 'clusters#index'
  get    '/clusters/new',          to: 'clusters#new'
  get    '/clusters/render_form/', to: 'clusters#render_form'
  get    '/clusters/:uuid',        to: 'clusters#show'
  get    '/clusters/:id/sshprivatekey', to: 'clusters#sshprivatekey'
  post   '/clusters/',             to: 'clusters#create'
  put    '/clusters/',             to: 'clusters#update'
  delete '/clusters/',             to: 'clusters#destroy'

  post   '/associate_cluster', to: 'groups#associate_cluster'
  delete '/associate_cluster', to: 'groups#deassociate_cluster'

  post   '/create_assignment', to: 'assignments#create'
  delete '/delete_assignment', to: 'assignments#destroy'

  patch  '/infrastructures/:id',   to: 'infrastructures#update'
  delete '/infrastructures',       to: 'infrastructures#destroy'

  resources :users
  resources :infrastructures
  resources :groups, only: [:index, :new, :create, :destroy]
  resources :tasks,  only: [:index, :new, :create, :destroy]

  get    '*unmatched_route', to: 'application#not_found'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
