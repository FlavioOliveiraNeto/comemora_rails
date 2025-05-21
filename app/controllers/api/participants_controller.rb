module Api
    class ParticipantsController < ApplicationController
      include Pundit::Authorization
      
      before_action :authenticate_user!
      before_action :set_event
      before_action :authorize_event_admin, only: [:destroy]
  
      # GET /api/events/:event_id/participants
      def index
        @participants = @event.participants
        render json: @participants
      end
  
      # DELETE /api/events/:event_id/participants/:id
      def destroy
        participant = @event.event_participants.find_by(user_id: params[:id])
        
        if participant&.destroy
          render json: { message: 'Participante removido com sucesso' }
        else
          render json: { error: 'Não foi possível remover o participante' }, status: :unprocessable_entity
        end
      end
  
      private
  
      def set_event
        @event = Event.find(params[:event_id])
      end
  
      def authorize_event_admin
        authorize @event, :admin?
      end
    end
end