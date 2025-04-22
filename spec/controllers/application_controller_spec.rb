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

  describe 'CORS headers' do
    it 'sets Access-Control-Allow-Origin header' do
      get :index
      expect(response.headers['Access-Control-Allow-Origin']).to eq('http://localhost:8080')
    end

    it 'sets Access-Control-Allow-Methods header' do
      get :index
      expect(response.headers['Access-Control-Allow-Methods']).to include('POST')
      expect(response.headers['Access-Control-Allow-Methods']).to include('GET')
      expect(response.headers['Access-Control-Allow-Methods']).to include('PUT')
      expect(response.headers['Access-Control-Allow-Methods']).to include('PATCH')
      expect(response.headers['Access-Control-Allow-Methods']).to include('DELETE')
      expect(response.headers['Access-Control-Allow-Methods']).to include('OPTIONS')
    end

    it 'sets Access-Control-Allow-Headers header' do
      get :index
      expect(response.headers['Access-Control-Allow-Headers']).to include('Authorization')
      expect(response.headers['Access-Control-Allow-Headers']).to include('Content-Type')
    end

    it 'sets Access-Control-Max-Age header' do
      get :index
      expect(response.headers['Access-Control-Max-Age']).to eq('1728000')
    end

    it 'handles preflight OPTIONS requests' do
      process :index, method: :options
      expect(response).to have_http_status(:no_content)
      expect(response.body).to eq('')
    end
  end
end
