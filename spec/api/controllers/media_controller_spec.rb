require 'rails_helper'

RSpec.describe Api::MediaController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event, admin: user) }
  let(:medium) { create(:medium, user: user) }

  before do
    sign_in user
    create(:event_medium, event: event, medium: medium)
  end

  describe 'GET #index' do
    it 'retorna lista de mídias do evento' do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'DELETE #destroy' do
    it 'remove a mídia do evento' do
      expect {
        delete :destroy, params: { event_id: event.id, id: medium.id }
      }.to change(Medium, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end