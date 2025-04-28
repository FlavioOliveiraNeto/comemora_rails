module Api
  class HomeController < ApplicationController
    before_action :authenticate_user!

    def index
      user_data = {
        user: current_user.as_json(only: [:id, :name, :email, :role]),
        organized_events: current_user.organized_events.as_json(
          include: :participants,
          methods: [:banner_url]
        ),
        #participating_events: current_user.events.where(event_participants: { status: 'accepted' }).as_json(include: [:admin, :participants])
      }
      
      render json: user_data, status: :ok
    end
  end
end