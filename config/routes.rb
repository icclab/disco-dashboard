Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  root 'pages#dashboard'
  get '/login', to: 'pages#login'
  get '/debug', to: 'pages#debug'
  get '/details', to: 'pages#details'
  post '/delete', to: 'pages#delete'
  resources :pages, only:[:create, :delete]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
