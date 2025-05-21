require 'rails_helper'

RSpec.describe Api::MediaController, type: :controller do
  let(:user) { create(:user, confirmed_at: Time.current) }
  let(:other_user) { create(:user, confirmed_at: Time.current) }
  let(:event) { create(:event, admin: user) }
  let(:participant) { create(:user, confirmed_at: Time.current) }
  let(:medium) { create(:medium, user: user) }

  before do
    sign_in user
    create(:event_medium, event: event, medium: medium)
    create(:event_participant, event: event, user: participant, status: 'accepted')
  end

  describe 'GET #index' do
    it 'retorna lista de mídias do evento para admin' do
      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:ok)
      data = JSON.parse(response.body)
      expect(data).to be_an(Array)
      expect(data.first['id']).to eq(medium.id)
    end

    it 'não permite acesso se não for admin ou participante aceito' do
      sign_out user
      sign_in other_user

      get :index, params: { event_id: event.id }
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST #create' do
    let(:file) { fixture_file_upload('spec/fixtures/image.png', 'image/png') }

    context 'usuário admin' do
      it 'adiciona mídia ao evento' do
        post :create, params: { event_id: event.id, media: { file: file, type: 'photo' } }
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['file_url']).to be_present
        expect(event.media.pluck(:id)).to include(json['id'])
      end
    end

    context 'usuário participante aceito' do
      before do
        sign_out user
        sign_in participant
      end

      it 'adiciona mídia ao evento' do
        post :create, params: { event_id: event.id, media: { file: file, type: 'photo' } }
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['file_url']).to be_present
      end
    end

    context 'usuário não autorizado' do
      before do
        sign_out user
        sign_in other_user
      end

      it 'não permite adicionar mídia' do
        post :create, params: { event_id: event.id, media: { file: file, type: 'photo' } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'admin do evento' do
      it 'remove a mídia' do
        expect {
          delete :destroy, params: { event_id: event.id, id: medium.id }
        }.to change(Medium, :count).by(-1)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'dono da mídia' do
      before do
        sign_out user
        sign_in medium.user
      end

      it 'remove a mídia' do
        expect {
          delete :destroy, params: { event_id: event.id, id: medium.id }
        }.to change(Medium, :count).by(-1)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'usuário não autorizado' do
      before do
        sign_out user
        sign_in other_user
      end

      it 'não permite remover mídia' do
        delete :destroy, params: { event_id: event.id, id: medium.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
