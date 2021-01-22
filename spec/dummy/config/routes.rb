Rails.application.routes.draw do
  root 'my_info#index'

  resources :my_info, only: [:index] do
    get :callback, on: :collection
  end
end
