Rails.application.routes.draw do
  resources :races, only: [:index, :show]

  root 'races#index'
end
