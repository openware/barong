# frozen_string_literal: true

Rails.application.routes.draw do
  resources :keys
  use_doorkeeper
  mount API::Base, at: '/api'

  devise_for :accounts
  root to: 'index#index', as: :index

  post  'phones/verification',  to: 'phones#verify'
  get   'security',             to: 'security#enable'

  resources :phones,    only: %i[new create]
  resources :profiles,  only: %i[new create]
  resources :documents, only: %i[new create]

  namespace :admin do
    get '/', to: 'accounts#index', as: :accounts
    resources :accounts
    resources :websites
    resources :profiles do
      put :change_state,    on: :member
    end
  end

  namespace :security do
    resources :keys
  end
end
