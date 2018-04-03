# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper
  mount API::Base, at: '/api'

  devise_for :accounts, controllers: { sessions: :sessions,
                                       confirmations: :confirmations }
  devise_scope :account do
    match 'accounts/sign_in/confirm', to: 'sessions#confirm', via: %i[get post]
  end

  root to: 'index#index', as: :index

  post 'phones/verification', to: 'phones#verify'
  get  'security',            to: 'security#enable'

  resources :phones,    only: [:new, :create]
  resources :profiles,  only: [:new, :create]
  resources :documents, only: [:new, :create]

  namespace :admin do
    get '/', to: 'accounts#index', as: :accounts
    resources :accounts
    resources :websites
    resources :profiles do
      put :change_state, on: :member
    end
  end
end
