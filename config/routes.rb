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
  post 'security/confirm',    to: 'security#confirm'

  resources :phones,    only: %i[new create]
  resources :profiles,  only: %i[new create]
  resources :documents, only: %i[new create]

  namespace :admin do
    get '/', to: 'accounts#index', as: :accounts
    resources :accounts, except: %i[new create show]
    resources :websites
    resources :profiles, only: %i[index show] do
      put :change_state, on: :member
    end
  end
end
