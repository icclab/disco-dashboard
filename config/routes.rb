Rails.application.routes.draw do
  root 'pages#dashboard'
  get '/login', to: 'pages#login' 

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
