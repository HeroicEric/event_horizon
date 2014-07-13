Rails.application.routes.draw do
  root "assignments#index"

  resources :assignments, only: [:index, :show], param: :slug do
    resources :submissions, only: [:index, :new, :create]
    resources :ratings, only: [:create, :update]
  end

  resources :submissions, only: [:show] do
    resources :comments, only: [:create]
  end

  resources :users, only: [:index, :show]

  resources :courses, only: [:new, :create, :show]

  resource :session, only: [:new, :create, :destroy] do
    get "failure", on: :member
  end

  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/failure", to: "sessions#failure"
end
