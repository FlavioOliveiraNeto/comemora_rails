Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'sessions',
    passwords: 'passwords',
    confirmations: 'confirmations'
  }

  devise_scope :user do
    get '/confirmation', to: 'confirmations#redirect_to_vue', as: :confirmation_redirect
  end
  
  namespace :api do
    resources :home, only: [:index]
    
    resources :events do
      member do
        post 'invite'           # Convidar usuário
        post 'join'             # Aceitar convite
        post 'decline'          # Recusar convite
        delete 'leave'          # Sair do evento
        get :event_details      # Informações detalhadas do evento
        get 'download_album_html', to: 'events#create_album', format: :html     # Criar álbum de fotos do evento
      end
      
      collection do
        get 'my_events'         # Eventos administrados pelo usuário
        get 'participating'     # Eventos que o usuário participa
      end

      resources :participants, only: [:index, :destroy]
      resources :media, only: [:index, :create, :destroy]
    end
  end
end