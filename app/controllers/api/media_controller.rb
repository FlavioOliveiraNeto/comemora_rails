module Api
    class MediaController < ApplicationController
      before_action :authenticate_user!
      before_action :set_event
      before_action :set_medium, only: [:destroy]
      before_action :authorize_medium, only: [:destroy]
  
      # GET /api/events/:event_id/media
      def index
        @media = @event.media
        render json: @media
      end
  
      # DELETE /api/events/:event_id/media/:id
      def destroy
        if @medium.destroy
          render json: { message: 'Mídia removida com sucesso' }
        else
          render json: { error: 'Não foi possível remover a mídia' }, status: :unprocessable_entity
        end
      end
  
      private
  
      def set_event
        @event = Event.find(params[:event_id])
      end
  
      def set_medium
        @medium = Medium.find(params[:id])
      end
  
      def authorize_medium
        # Só o admin do evento ou o dono da mídia pode deletar
        unless @event.admin?(current_user) || @medium.user == current_user
          render json: { error: 'Não autorizado' }, status: :forbidden
        end
      end
    end
end