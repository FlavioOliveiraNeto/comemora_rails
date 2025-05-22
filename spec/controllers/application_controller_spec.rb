require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render plain: 'Test Controller'
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end
end
