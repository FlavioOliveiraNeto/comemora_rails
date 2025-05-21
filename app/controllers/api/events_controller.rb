module Api
  class EventsController < ApplicationController
    include Pundit::Authorization
    
    before_action :authenticate_user!
    skip_before_action :authenticate_user!, only: [:event_details]
    before_action :set_event, only: [:show, :update, :destroy, :invite, :join, :decline, :add_media, :leave]
    before_action :authorize_event, except: [:index, :create, :my_events, :participating, :event_details]

    # GET /api/events
    def index
      @events = Event.upcoming.page(params[:page]).per(10) # Paginação usando 'kaminari' ou 'will_paginate'
      render json: @events
    end

    # GET /api/events/my_events
    def my_events
      @events = current_user.organized_events
      render json: @events
    end

    # GET /api/events/participating
    def participating
      @events = current_user.events.where(event_participants: { status: 'accepted' })
      render json: @events
    end

    # POST /api/events
    def create
      @event = current_user.organized_events.new(event_params)
      
      if @event.save
        # Adicione esta linha para processar o banner se existir
        @event.banner.attach(params[:event][:banner]) if params[:event][:banner]
        
        render json: { 
          evento: @event.as_json.merge(banner_url: @event.banner_url),
          message: 'Evento criado com sucesso.' 
        }, status: :created
      else
        render json: @event.errors, status: :unprocessable_entity
      end
    end

    # GET /api/events/:id
    def show
      event = Event.find(params[:id])

      unless event.admin?(current_user) || event.accepted_participant?(current_user)
        return render json: { error: 'Não autorizado' }, status: :forbidden
      end

      render json: event.as_json(
        include: {
          participants: { only: [:id, :name, :email] },
          media: {
            only: [:id, :user_id, :description, :created_at],
            methods: [:file_url]
          }
        },
        methods: [:banner_url]
      ), status: :ok
    end

    # PUT/PATCH /api/events/:id
    def update
      keep_banner = params[:event].delete(:keep_banner)
      @event.assign_attributes(event_params)
    
      # Lógica de controle do banner
      if keep_banner == 'false' && @event.banner.attached?
        @event.banner.purge_later
      end
    
      if @event.save
        @event.banner.attach(params[:event][:banner]) if params[:event][:banner]
        render json: { 
          evento: @event.as_json(methods: [:banner_url]),
          message: 'Evento atualizado com sucesso'
        }
      else
        render json: { 
          errors: @event.errors.full_messages,
          message: 'Falha na atualização'
        }, status: :unprocessable_entity
      end
    end

    # DELETE /api/events/:id
    def destroy
      @event.destroy
      head :no_content
    end

    # POST /api/events/:id/invite
    def invite
      user = User.find_by(id: params[:user_id])
      
      if user.nil?
        return render json: { error: 'Usuário não encontrado' }, status: :not_found
      end

      if @event.invite_user(user)
        render json: { message: 'Usuário convidado com sucesso' }, status: :created
      else
        render json: { error: 'Não foi possível convidar o usuário' }, status: :unprocessable_entity
      end
    end

    # POST /api/events/:id/join
    def join
      begin
        event = Event.find(params[:id])
        
        return invalid_token_response unless valid_token?(event)
    
        participant = event.event_participants.find_or_create_by(
          user_id: current_user.id,
          status: 'accepted' # Ou o status apropriado
        )
    
        participant.persisted? ? success_response(event) : error_response(participant)
    
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Evento não encontrado' }, status: :not_found
      end
    end

    # POST /api/events/:id/decline
    def decline
      if @event.decline_invitation(current_user)
        render json: { message: 'Convite recusado com sucesso' }
      else
        render json: { error: 'Não foi possível recusar o convite' }, status: :unprocessable_entity
      end
    end

    # DELETE /api/events/:id/leave
    def leave
      participant = @event.event_participants.find_by(user: current_user)
      
      if participant&.destroy
        render json: { message: 'Você saiu do evento com sucesso' }
      else
        render json: { error: 'Não foi possível sair do evento' }, status: :unprocessable_entity
      end
    end

    # GET /api/events/:id/event_details
    def event_details
      @event = Event.find_by(id: params[:id])
    
      if @event.nil?
        return render json: { error: 'Evento não encontrado' }, status: :not_found
      end
    
      authorized = false
    
      if user_signed_in?
        authorized = @event.admin?(current_user) || @event.participant?(current_user)
      end
    
      if !authorized && params[:token].present?
        authorized = Event.where(invite_token: params[:token]).present?
      end
    
      unless authorized
        return render json: { error: 'Você não tem permissão para ver este evento.' }, status: :forbidden
      end
    
      render json: @event.as_json(
        include: {
          participants: { only: [:id, :name, :email] }
        },
        methods: [:banner_url]
      ), status: :ok
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def authorize_event
      authorize @event
    end

    def valid_token?(event)
      event.invite_token == params[:token]
    end
    
    def invalid_token_response
      render json: { error: 'Convite inválido' }, status: :forbidden
    end

    def success_response(event)
      render json: { 
        event: event,
        message: 'Você entrou no evento com sucesso!'
      }, status: :ok
    end
    
    def error_response(participant)
      render json: { 
        error: 'Não foi possível entrar no evento',
        details: participant.errors.full_messages 
      }, status: :unprocessable_entity
    end

    def medium_json(medium)
      {
        id: medium.id,
        file_url: medium.file.attached? ? url_for(medium.file) : nil,
        user_id: medium.user_id,
        created_at: medium.created_at
      }
    end

    def event_params
      params.require(:event).permit(
        :title, 
        :description, 
        :start_date, 
        :end_date, 
        :location,
        :banner,
      )
    end
  end
end
