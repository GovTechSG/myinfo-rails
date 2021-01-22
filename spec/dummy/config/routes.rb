Rails.application.routes.draw do
  root 'application#index'
  get :callback, controller: 'application'
  get :token_callback, controller: 'application'
end
