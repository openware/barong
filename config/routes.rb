# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper

  devise_for :accounts
  root to: 'web/index#index', as: :index

  scope module: :web do
    # Define public routes here.
  end

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :accounts
  end

  namespace :api do
    resources :accounts, to: 'accounts#show'
  end
end
