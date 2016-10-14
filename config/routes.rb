Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  root 'pages#dashboard'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get    '/details', to: 'clusters#show'
  post   '/delete',  to: 'clusters#destroy'
  post   '/create',  to: 'clusters#create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
