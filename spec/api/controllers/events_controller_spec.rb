require 'rails_helper'

RSpec.describe Api::EventsController, type: :controller do
  let(:user) { create(:user, confirmed_at: Time.current) }
  let(:event) { create(:event, admin: user) }
  let(:other_user) { create(:user, confirmed_at: Time.current) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'retorna lista de eventos futuros' do
      create_list(:event, 3, admin: user)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        event: {
          title: 'Novo Evento',
          description: 'Descrição do evento',
          start_date: Time.current,
          end_date: 1.day.from_now,
          location: 'Local do evento'
        }
      }
    end

    it 'cria um novo evento' do
      expect {
        post :create, params: valid_params
      }.to change(Event, :count).by(1)
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PUT #update' do
    let(:update_params) do
      {
        id: event.id,
        event: {
          title: 'Título Atualizado'
        }
      }
    end

    it 'atualiza o evento' do
      put :update, params: update_params
      expect(response).to have_http_status(:ok)
      expect(event.reload.title).to eq('Título Atualizado')
    end
  end

  describe 'DELETE #destroy' do
    it 'remove o evento' do
      expect {
        delete :destroy, params: { id: event.id }
      }.to change(Event, :count).by(0)
      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'POST #invite' do
    it 'convida um usuário para o evento' do
      post :invite, params: { id: event.id, user_id: other_user.id }
      expect(response).to have_http_status(:created)
      expect(event.participants).to include(other_user)
    end
  end
end