Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions: 'sessions',
    passwords: 'passwords',
    confirmations: 'confirmations'
  }
  
  namespace :api do
    resources :home, only: [:index]
    
    # Rotas para eventos
    resources :events do
      member do
        post 'invite'               # Convidar usuário
        post 'join'                 # Aceitar convite
        post 'decline'              # Recusar convite
        post 'upload_media'         # Upload de mídia
        delete 'leave'              # Sair do evento
        get :event_details
      end
      
      collection do
        get 'my_events'            # Eventos que o usuário administra
        get 'participating'         # Eventos que o usuário participa
      end
      
      resources :participants, only: [:index, :destroy]  # Gerenciar participantes
      resources :media, only: [:index, :destroy]         # Gerenciar mídias
    end
  end
end