require 'rails_helper'

RSpec.describe PasswordsController, type: :request do
  let!(:user) { create(:user, confirmed_at: Time.now) }
  
  describe 'POST /users/password' do
    context 'with valid parameters' do
      it 'sends reset password instructions' do
        expect {
          post '/users/password', params: { user: { email: user.email } }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('message' => I18n.t('devise.passwords.send_instructions'))
      end
      
      it 'updates reset_password_token for the user' do
        expect {
          post '/users/password', params: { user: { email: user.email } }
          user.reload
        }.to change(user, :reset_password_token)
      end
    end
    
    context 'with invalid parameters' do
      it 'returns error for missing email' do
        post '/users/password', params: { user: { email: '' } }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.passwords.no_email'))
      end
      
      it 'returns error for non-existent email' do
        post '/users/password', params: { user: { email: 'nonexistent@example.com' } }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].first).to eq(I18n.t('devise.failure.not_found_in_database'))
      end
      
      it 'handles unexpected errors gracefully' do
        allow_any_instance_of(User).to receive(:send_reset_password_instructions).and_raise(StandardError.new("Test error"))
        
        post '/users/password', params: { user: { email: user.email } }
        
        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.passwords.error'))
      end
    end
  end
  
  describe 'PUT /users/password' do
    let(:user) { create(:user, confirmed_at: Time.current) }
    
    # Gera um token fresco para cada teste
    let(:valid_token) do
      raw, enc = Devise.token_generator.generate(User, :reset_password_token)
      user.update!(
        reset_password_token: enc,
        reset_password_sent_at: Time.now.utc
      )
      raw
    end
  
    context 'com parâmetros válidos' do
      it 'atualiza a senha do usuário' do
        put '/users/password', params: { 
          user: { 
            reset_password_token: valid_token,
            password: 'NewValidP@ssword1',
            password_confirmation: 'NewValidP@ssword1'
          } 
        }
  
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.passwords.updated'))
        
        # Verifica login com nova senha
        post '/users/sign_in', params: { user: { email: user.email, password: 'NewValidP@ssword1' } }
        expect(response).to have_http_status(:ok)
      end
    end
  
    context 'com parâmetros inválidos' do
      it 'retorna erro quando falta o token' do
        put '/users/password', params: { 
          user: { 
            password: 'NewValidP@ssword1',
            password_confirmation: 'NewValidP@ssword1'
          } 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.passwords.invalid_reset_params'))
      end
      
      it 'retorna erro para token inválido' do
        put '/users/password', params: { 
          user: { 
            reset_password_token: 'token_invalido_qualquer',
            password: 'NewValidP@ssword1',
            password_confirmation: 'NewValidP@ssword1'
          } 
        }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors'].first).to include(I18n.t('activerecord.errors.models.user.attributes.reset_password_token.invalid'))
      end
      
      it 'retorna erro para senha muito simples' do
        put '/users/password', params: { 
          user: { 
            reset_password_token: valid_token,
            password: 'senhafraca',
            password_confirmation: 'senhafraca'
          } 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors'][0]).to include(I18n.t('activerecord.errors.models.user.attributes.password.missing_uppercase'))
        expect(json_response['errors'][1]).to include(I18n.t('activerecord.errors.models.user.attributes.password.missing_special_char'))
        expect(json_response['errors'][2]).to include(I18n.t('activerecord.errors.models.user.attributes.password.missing_number'))       
      end
      
      it 'retorna erro quando a confirmação não corresponde com a senha.' do
        put '/users/password', params: { 
          user: { 
            reset_password_token: valid_token,
            password: 'NewValidP@ssword1',
            password_confirmation: 'DifferentP@ssword1'
          } 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].first).to include(I18n.t('activerecord.errors.models.user.attributes.password.confirmation'))
      end
      
      it 'retorna erro para token expirado' do
        # Cria um token expirado
        raw, enc = Devise.token_generator.generate(User, :reset_password_token)
        user.update!(
          reset_password_token: enc,
          reset_password_sent_at: 7.hours.ago # Supondo que expire em 6 horas
        )
        
        put '/users/password', params: { 
          user: { 
            reset_password_token: raw,
            password: 'NewValidP@ssword1',
            password_confirmation: 'NewValidP@ssword1'
          } 
        }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors'].first).to include(I18n.t('errors.messages.expired_token'))
      end
      
      it 'retorna erro quando a senha está em branco' do
        put '/users/password', params: { 
          user: { 
            reset_password_token: valid_token,
            password: '',
            password_confirmation: ''
          } 
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to include(I18n.t('activerecord.errors.models.user.attributes.password.blank'))
      end
    end
  end
end