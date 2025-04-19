class SessionsController < Devise::SessionsController
  respond_to :json
  before_action :configure_sign_in_params, only: [:create]

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    respond_with(resource)
  rescue => e
    handle_authentication_error(e)
  end

  private

  def respond_with(resource, _opts = {})
    token = request.env['warden-jwt_auth.token']
    response.headers['Authorization'] = "Bearer #{token}" if token
    
    render json: {
      message: I18n.t('devise.sessions.signed_in'),
      user: user_json(resource),
      token: token
    }, status: :ok
  end

  def respond_to_on_destroy
    render json: { message: I18n.t('devise.sessions.signed_out') }, status: :ok
  end

  def handle_authentication_error(exception)
    error_key, status = case exception
                        when Warden::Strategies::Base::Failure
                          if exception.message.include?('Invalid')
                            ['devise.failure.invalid', :unauthorized]
                          else
                            ['devise.failure.unauthenticated', :unauthorized]
                          end
                        when ActiveRecord::RecordNotFound
                          ['devise.failure.not_found_in_database', :not_found]
                        else
                          ['devise.failure.unknown', :internal_server_error]
                        end

    render json: { 
      message: I18n.t(error_key),
      details: Rails.env.development? ? exception.message : nil
    }, status: status
  end

  def user_json(user)
    user.as_json(
      only: [:id, :email, :name],
      methods: [:admin?]
    )
  end

  # Permite parâmetros adicionais no login
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:otp_attempt]) # Exemplo para 2FA
  end
end