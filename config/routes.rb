# frozen_string_literal: true

Rails.application.routes.draw do

  use_doorkeeper

  devise_for :accounts, controllers: { sessions: 'accounts/sessions' }

  root to: 'index#index', as: :index

  post  'phones/verification', to: 'phones#verify'

  resources :accounts, only: [:show] do
    collection do
      get 'edit'
      post 'enable_otp'
      post 'disable_otp'
      patch 'update'
    end
  end

  resources :phones
  resources :profiles
  resources :documents

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    resources :accounts
    resources :websites
    resources :profiles do
      put :change_state,    on: :member
    end
  end

  namespace :api do
    resources :account, to: 'accounts#show'
  end
end
