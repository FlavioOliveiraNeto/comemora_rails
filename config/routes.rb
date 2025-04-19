Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'sessions',
    passwords: 'passwords',
    confirmations: 'confirmations'
  }
  
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show]
    end
  end
end