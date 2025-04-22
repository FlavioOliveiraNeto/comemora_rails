require 'rails_helper'

RSpec.describe ConfirmationsController, type: :request do
  let!(:user) { create(:user, confirmed_at: nil) }
  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  describe 'GET /users/confirmation' do
    context 'with valid token' do
      it 'confirms the user account' do
        get "/users/confirmation?confirmation_token=#{user.confirmation_token}"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.confirmations.confirmed'))

        user.reload
        expect(user.confirmed?).to be true
      end

      it 'returns user data after confirmation' do
        get "/users/confirmation?confirmation_token=#{user.confirmation_token}"

        json_response = JSON.parse(response.body)
        expect(json_response['user']).to include('id', 'email', 'name', 'confirmed_at')
        expect(json_response['user']['confirmed_at']).not_to be_nil
      end
    end

    context 'with invalid token' do
      it 'returns error for missing token' do
        get "/users/confirmation"

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.confirmations.no_token'))
      end

      it 'returns error for invalid token' do
        get "/users/confirmation?confirmation_token=invalid_token"
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.confirmations.failed'))
        expect(JSON.parse(response.body)['errors'].first).to include(I18n.t('activerecord.errors.models.user.attributes.confirmation_token.invalid'))
      end

      it 'returns error for already confirmed user' do
        confirmed_user = create(:user, confirmed_at: Time.now)
      
        get "/users/confirmation?confirmation_token=invalid_token_for_confirmed_user"
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.confirmations.failed'))
        expect(JSON.parse(response.body)['errors'].first).to include(I18n.t('activerecord.errors.models.user.attributes.confirmation_token.invalid'))
      end
    end

    it 'handles unexpected errors gracefully' do
      allow_any_instance_of(User).to receive(:confirm).and_raise(StandardError.new("Test error"))

      get "/users/confirmation?confirmation_token=#{user.confirmation_token}"

      expect(response).to have_http_status(:internal_server_error)
      expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.confirmations.error'))
    end
  end

  describe 'POST /users/confirmation' do
    it 'resends confirmation instructions' do
      expect {
        post '/users/confirmation',
             params: { user: { email: user.email } }.to_json,
             headers: headers
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.confirmations.send_instructions'))
    end

    it 'returns error for invalid email' do
      post '/users/confirmation',
           params: { user: { email: 'nonexistent@example.com' } }.to_json,
           headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.confirmations.failed'))
      expect(JSON.parse(response.body)['errors']).to include(I18n.t('devise.failure.not_found_in_database'))
    end

    it 'returns message for already confirmed user' do
      confirmed_user = create(:user, confirmed_at: Time.now)

      post '/users/confirmation',
           params: { user: { email: confirmed_user.email } }.to_json,
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']).to eq(I18n.t('devise.confirmations.failed'))
      expect(JSON.parse(response.body)['errors'].first).to include(I18n.t('errors.messages.already_confirmed'))
    end
  end
end
