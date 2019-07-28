Rails.application.routes.draw do
  resources :races, only: [:index, :show]
end
