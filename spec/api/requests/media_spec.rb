require 'rails_helper'

RSpec.describe "API::Media", type: :request do
  let(:user) { create(:user, confirmed_at: Time.current) }
  let(:event) { create(:event, admin: user) }
  
  before do
    # Adiciona o user como participante aceito (caso não seja admin)
    create(:event_participant, event: event, user: user, status: 'accepted') unless event.admin?(user)
    
    # Login via Devise helpers ou autenticação via token, dependendo do setup
    sign_in user
  end

  describe "POST /api/events/:event_id/media" do
    it "permite que participante faça upload de mídia com legenda" do
      media_file = fixture_file_upload('spec/fixtures/image.png', 'image/png')

      post api_event_media_path(event), params: {
        media: {
          file: media_file,
          description: 'Minha foto legal'
        }
      }

      expect(response).to have_http_status(:created)
      
      json = JSON.parse(response.body)
      expect(json['file_url']).to be_present
      expect(json['description']).to eq('Minha foto legal')
      expect(json['user_id']).to eq(user.id)
    end
  end
end
