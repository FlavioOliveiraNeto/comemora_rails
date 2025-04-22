require 'rails_helper'

RSpec.describe SessionsController, type: :request do
  let!(:confirmed_user) { create(:user, confirmed_at: Time.now, password: 'ValidP@ssword1', password_confirmation: 'ValidP@ssword1') }
  let!(:unconfirmed_user) { create(:user, confirmed_at: nil, password: 'ValidP@ssword1', password_confirmation: 'ValidP@ssword1') }

  describe 'POST /users/sign_in' do
    context 'com credenciais válidas' do
      let(:params_validos) { { user: { email: confirmed_user.email, password: 'ValidP@ssword1' } } }

      it 'retorna o token de autenticação' do
        post '/users/sign_in', params: params_validos

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['token']).to be_present
      end

      it 'retorna os dados do usuário' do
        post '/users/sign_in', params: params_validos

        json_response = JSON.parse(response.body)
        expect(json_response['user']).to include('id', 'email', 'name')
        expect(json_response['user']['email']).to eq(confirmed_user.email)
      end

      it 'define o header Authorization' do
        post '/users/sign_in', params: params_validos

        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end
    end

    context 'com credenciais inválidas' do
      it 'retorna erro para senha incorreta' do
        post '/users/sign_in', params: { user: { email: confirmed_user.email, password: 'SenhaErrada1!' } }

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(I18n.t('devise.failure.invalid'))
      end

      it 'retorna erro para usuário inexistente' do
        post '/users/sign_in', params: { user: { email: 'naoexiste@example.com', password: 'SenhaQualquer1!' } }

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq(I18n.t('devise.failure.not_found_in_database'))
      end

      it 'retorna erro para usuário não confirmado' do
        post '/users/sign_in', params: { user: { email: unconfirmed_user.email, password: 'ValidP@ssword1' } }

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include(I18n.t('devise.failure.unconfirmed'))
      end
    end

    context 'quando ocorre erro inesperado' do
      it 'retorna erro 500 com mensagem apropriada' do
        allow_any_instance_of(Warden::SessionSerializer).to receive(:fetch).and_raise(StandardError.new('Erro de teste'))
    
        post '/users/sign_in', params: { user: { email: confirmed_user.email, password: 'ValidP@ssword1' } }
    
        expect(response).to have_http_status(:internal_server_error)
    
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq(I18n.t('devise.failure.unknown'))
      end
    end
  end

  describe 'DELETE /users/sign_out' do
    let(:token) do
      post '/users/sign_in', params: { user: { email: confirmed_user.email, password: 'ValidP@ssword1' } }
      json_response = JSON.parse(response.body)
      json_response['token']  # Acessar o token do corpo da resposta corretamente
    end
  
    context 'quando autenticado' do
      it 'retorna mensagem de sucesso' do
        delete '/users/sign_out', headers: { 'Authorization' => "Bearer #{token}" }
  
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq(I18n.t('devise.sessions.signed_out'))
      end
    end
  
    context 'quando não autenticado' do
      it 'retorna erro de autorização' do
        delete '/users/sign_out'
  
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end  
end
