Rails.application.routes.draw do
  root 'application#index'
  get :callback, controller: 'application'
end
