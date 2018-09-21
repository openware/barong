# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper
  mount UserApi::Base, at: '/api'
  mount ManagementAPI::V1::Base, at: '/management_api'

  devise_for :accounts, controllers: { sessions: :sessions,
                                       confirmations: :confirmations }
  devise_scope :account do
    match 'accounts/sign_in/confirm', to: 'sessions#confirm', via: %i[get post]
  end

  root to: 'index#index', as: :index

  post 'phones/verification', to: 'phones#verify'

  get  'security',            to: 'security#enable'
  post 'security/confirm',    to: 'security#confirm'

  get 'health/alive', to: 'health#alive'
  get 'health/ready', to: 'health#ready'

  resources :phones,    only: %i[new create]
  resources :profiles,  only: %i[new create]
  resources :documents, only: %i[new create]

  namespace :admin do
    get '/', to: 'accounts#index', as: :accounts
    resources :accounts, except: %i[new create] do
      post :disable_2fa, on: :member

      resources :labels, except: %i[index show]
    end
    resources :websites
    resources :profiles, only: %i[edit update] do
      put :document_label, on: :member
    end
  end
end
