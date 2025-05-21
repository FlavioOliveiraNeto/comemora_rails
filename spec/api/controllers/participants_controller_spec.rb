require 'rails_helper'

RSpec.describe Api::ParticipantsController, type: :controller do
  let(:admin) { create(:user, confirmed_at: Time.current) }
  let(:event) { create(:event, admin: admin) }
  let(:participant) { create(:user, confirmed_at: Time.current) }

  before do
    sign_in admin
    create(:event_participant, event: event, user: participant, status: 'accepted')
    allow(controller).to receive(:authorize).and_return(true)
  end

  describe 'GET #index' do
    it 'retorna lista de participantes' do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'DELETE #destroy' do
    it 'remove um participante do evento' do
      expect {
        delete :destroy, params: { event_id: event.id, id: participant.id }
      }.to change(EventParticipant, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end
end