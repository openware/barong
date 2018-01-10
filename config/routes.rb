# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :accounts
  root to: 'web/index#index', as: :index

  scope module: :web do
    # Define public routes here.
  end

  namespace :admin do
    resources :accounts
  end
end
