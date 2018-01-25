# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :accounts
  root to: 'web/index#index', as: :index

  scope module: :web do
    resources :documents
    resources :customers
  end

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :accounts
  end
end
