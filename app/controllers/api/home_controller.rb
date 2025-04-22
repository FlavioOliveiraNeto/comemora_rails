module Api
  class HomeController < ApplicationController
    before_action :authenticate_user!

    def index
      render json: { message: 'Bem-vindo à home!' }, status: :ok
    end
  end
end