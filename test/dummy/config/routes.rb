Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :posts, only: [:new, :create]

  namespace :admin do
    resources :posts, only: [:new]
  end
end
