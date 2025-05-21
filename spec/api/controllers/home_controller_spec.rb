require 'rails_helper'

RSpec.describe Api::HomeController, type: :controller do
  let(:user) { create(:user, confirmed_at: Time.current) }
  let(:organized_event) { create(:event, admin: user) }
  let(:participating_event) { create(:event) }

  before do
    sign_in user
    create(:event_participant, event: participating_event, user: user, status: 'accepted')
  end

  describe 'GET #index' do
    it 'retorna dados do usuário e eventos' do
      get :index
      expect(response).to have_http_status(:ok)
      
      json_response = JSON.parse(response.body)
      expect(json_response['user']['id']).to eq(user.id)
      expect(json_response['organized_events']).to be_an(Array)
      expect(json_response['participating_events']).to be_an(Array)
    end
  end
end