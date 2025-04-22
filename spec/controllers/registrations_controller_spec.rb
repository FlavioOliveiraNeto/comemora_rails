require 'rails_helper'

RSpec.describe RegistrationsController, type: :request do
  describe 'POST /users' do
    let(:atributos_validos) {
      {
        user: {
          name: 'Usuário Teste',
          email: 'teste@example.com',
          password: 'ValidP@ssword1',
          password_confirmation: 'ValidP@ssword1'
        }
      }
    }

    context 'tratamento de erros' do
      it 'retorna erro de validação quando o nome está em branco' do
        atributos = atributos_validos.deep_dup
        atributos[:user][:name] = ''

        post '/users', params: atributos

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors'].first).to include(I18n.t('activerecord.errors.models.user.attributes.name.blank'))
      end

      it 'retorna erro de validação quando o e-mail é inválido' do
        atributos = atributos_validos.deep_dup
        atributos[:user][:email] = 'email-invalido'

        post '/users', params: atributos

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors'].first).to include(I18n.t('activerecord.errors.models.user.attributes.email.invalid'))
      end

      it 'retorna erro quando a senha não atende aos critérios de complexidade' do
        atributos = atributos_validos.deep_dup
        atributos[:user][:password] = 'senha'
        atributos[:user][:password_confirmation] = 'senha'
      
        post '/users', params: atributos
      
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        
        # Coletar todas as mensagens de erro em um array
        error_messages = json_response['errors']
        
        # Verificar se pelo menos uma mensagem de cada tipo está presente
        expect(error_messages).to include(
          a_string_including(I18n.t('activerecord.errors.models.user.attributes.password.too_short', count: 6))
        ).or include(
          a_string_including(I18n.t('activerecord.errors.models.user.attributes.password.missing_uppercase'))
        ).or include(
          a_string_including(I18n.t('activerecord.errors.models.user.attributes.password.missing_special_char'))
        ).or include(
          a_string_including(I18n.t('activerecord.errors.models.user.attributes.password.missing_number'))
        )
      end               

      it 'retorna erro quando a confirmação de senha não corresponde' do
        atributos = atributos_validos.deep_dup
        atributos[:user][:password_confirmation] = 'OutraSenha@123'

        post '/users', params: atributos

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors'].first).to include(I18n.t('activerecord.errors.models.user.attributes.password.confirmation'))
      end

      it 'retorna erro quando o e-mail já está em uso' do
        create(:user, email: 'teste@example.com')

        post '/users', params: atributos_validos

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['errors'].first).to include(I18n.t('activerecord.errors.models.user.attributes.email.taken'))
      end

      it 'lida com erros inesperados de forma apropriada' do
        allow_any_instance_of(User).to receive(:save).and_raise(StandardError.new('Erro simulado'))

        post '/users', params: atributos_validos

        expect(response).to have_http_status(:internal_server_error)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq(I18n.t('devise.registrations.error'))
      end

      it 'retorna erro quando os parâmetros estão ausentes' do
        post '/users', params: {}

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq(I18n.t('devise.registrations.missing_params'))
      end
    end
  end
end
