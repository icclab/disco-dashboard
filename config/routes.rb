Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  root 'pages#dashboard'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get    '/debug',   to: 'pages#debug'
  get    '/details', to: 'pages#details'
  post   '/delete',  to: 'pages#delete'
  resources :pages, only:[:create, :delete]
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
