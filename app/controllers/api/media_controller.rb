module Api
  class MediaController < ApplicationController
    before_action :authenticate_user!
    before_action :set_event
    before_action :authorize_event_media_access
    before_action :set_medium, only: [:destroy]
    before_action :authorize_medium, only: [:destroy]

    # GET /api/events/:event_id/media
    def index
      @media = @event.media.includes(:user).order(created_at: :asc)

      render json: @media.map { |m|
        {
          id: m.id,
          file_url: url_for(m.file),
          user_id: m.user_id,
          user_name: m.user.name,
          description: m.description,
          created_at: m.created_at,
          type: get_media_type(m.file.content_type)
        }
      }
    end

    # POST /api/events/:event_id/media
    def create
      return render json: { error: 'Não autorizado' }, status: :forbidden unless @event.can_add_media?(current_user)
      
      media_params = params.require(:media).permit(:file, :description)

      @medium = Medium.new(
        user: current_user,
        description: media_params[:description]
      )

      @medium.file.attach(media_params[:file])

      if @event.can_add_media?(current_user) && @medium.save
        @event.event_media.create!(medium: @medium)

        render json: {
          id: @medium.id,
          file_url: url_for(@medium.file),
          user_id: @medium.user_id,
          user_name: @medium.user.name,
          description: @medium.description,
          created_at: @medium.created_at,
          type: get_media_type(@medium.file.content_type)
        }, status: :created
      else
        render json: {
          error: 'Falha ao adicionar mídia',
          errors: @medium.errors.full_messages
        }, status: :unprocessable_entity
      end
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
      unless @event.admin?(current_user) || @medium.user == current_user
        render json: { error: 'Não autorizado' }, status: :forbidden
      end
    end

    def authorize_event_media_access
      unless @event.admin?(current_user) || @event.accepted_participant?(current_user)
        render json: { error: 'Você não tem acesso às mídias deste evento.' }, status: :forbidden
      end
    end

    # Helper para determinar o tipo da mídia (foto ou vídeo)
    def get_media_type(content_type)
      if content_type.starts_with?('image/')
        'photo'
      elsif content_type.starts_with?('video/')
        'video'
      else
        'unknown'
      end
    end
  end
end