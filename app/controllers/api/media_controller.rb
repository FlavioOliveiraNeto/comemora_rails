module Api
  class MediaController < ApplicationController
    before_action :authenticate_user!
    before_action :set_event
    before_action :authorize_event_media_access
    before_action :set_medium, only: [:destroy]
    before_action :authorize_medium, only: [:destroy]

    # GET /api/events/:event_id/media
    def index
      @media = @event.media.order(created_at: :desc)
      render json: @media.map { |m| { id: m.id, url: m.file_url, created_at: m.created_at } }
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

    def authorize_event_media_access
      unless @event.admin?(current_user) || @event.accepted_participant?(current_user)
        render json: { error: 'Você não tem acesso às mídias deste evento.' }, status: :forbidden
      end
    end
  end
end
