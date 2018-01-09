Rails.application.routes.draw do
  devise_for :accounts
  root to: 'application#index'
end
