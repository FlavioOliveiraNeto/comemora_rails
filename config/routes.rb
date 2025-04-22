Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'sessions',
    passwords: 'passwords',
    confirmations: 'confirmations'
  }
  
  namespace :api do
    resources :home, only: [:index]
  end
end