module Api
    class EventsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_event, only: [:show, :update, :destroy, :invite, :join, :decline, :upload_media, :leave]
      before_action :authorize_event, except: [:index, :create, :my_events, :participating]
  
      # GET /api/events
      def index
        @events = Event.upcoming
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
          render json: @event, status: :created
        else
          render json: @event.errors, status: :unprocessable_entity
        end
      end
  
      # GET /api/events/:id
      def show
        render json: @event, include: [:participants, :media]
      end
  
      # PUT/PATCH /api/events/:id
      def update
        if @event.update(event_params)
          render json: @event
        else
          render json: @event.errors, status: :unprocessable_entity
        end
      end
  
      # DELETE /api/events/:id
      def destroy
        @event.destroy
        head :no_content
      end
  
      # POST /api/events/:id/invite
      def invite
        user = User.find(params[:user_id])
        
        if @event.invite_user(user)
          render json: { message: 'Usuário convidado com sucesso' }
        else
          render json: { error: 'Não foi possível convidar o usuário' }, status: :unprocessable_entity
        end
      end
  
      # POST /api/events/:id/join
      def join
        if @event.accept_invitation(current_user)
          render json: { message: 'Você entrou no evento com sucesso' }
        else
          render json: { error: 'Não foi possível entrar no evento' }, status: :unprocessable_entity
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
  
      # POST /api/events/:id/upload_media
      def upload_media
        if @event.add_media(current_user, params[:file])
          render json: { message: 'Mídia adicionada com sucesso' }
        else
          render json: { error: 'Não foi possível adicionar a mídia' }, status: :unprocessable_entity
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
  
      private
  
      def set_event
        @event = Event.find(params[:id])
      end
  
      def authorize_event
        authorize @event
      end
  
      def event_params
        params.require(:event).permit(:title, :description, :start_date, :end_date, :location)
      end
    end
end