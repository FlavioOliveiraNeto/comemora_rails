# home_controller.rb
module Api
  class HomeController < ApplicationController
    before_action :authenticate_user!

    def index
      user_data = {
        user: current_user.as_json(only: [:id, :name, :email, :role]),
        organized_events: serialized_organized_events,
        participating_events: serialized_participating_events
      }
      
      render json: user_data, status: :ok
    end

    private

    def serialized_organized_events
      current_user.organized_events.order(Arel.sql("CASE events.status WHEN #{Event.statuses[:active]} THEN 0 ELSE 1 END"), :start_date)
        .as_json(
          include: {
            participants: { only: [:id, :name, :email] }
          },
          methods: [:banner_url]
        )
    end

    def serialized_participating_events
      current_user.participating_events
        .where(event_participants: { status: 'accepted' })
        .order(Arel.sql("CASE events.status WHEN #{Event.statuses[:active]} THEN 0 ELSE 1 END"), :start_date)
        .as_json(
          include: {
            admin: { only: [:id, :name, :email] },
            participants: { only: [:id, :name, :email] }
          },
          methods: [:banner_url]
        )
    end
  end
end