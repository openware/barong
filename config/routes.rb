# frozen_string_literal: true

Rails.application.routes.draw do
  resources :documents
  resources :customers
  devise_for :accounts
  root to: 'web/index#index', as: :index

  scope module: :web do
    # Define public routes here.
  end

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :accounts
  end
end
