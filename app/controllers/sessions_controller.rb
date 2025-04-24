class SessionsController < Devise::SessionsController
  respond_to :json
  before_action :configure_sign_in_params, only: [:create]
  skip_before_action :verify_signed_out_user, only: :destroy

  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    render_sign_in_success(resource)
  rescue StandardError => e
    handle_auth_error(e)
  end

  def destroy
    if current_user
      if current_token = request.headers['Authorization']&.split('Bearer ')&.last
        Warden::JWTAuth::RevocationStrategy.new.call(current_token, :revocation)
      end
      
      sign_out(current_user)
      render json: { message: I18n.t('devise.sessions.signed_out') }, status: :ok
    else
      render json: { message: I18n.t('devise.failure.unauthenticated') }, status: :unauthorized
    end
  end

  protected

  def handle_auth_error(exception)
    Rails.logger.error "Erro ao autenticar usuário: #{exception.message}" if Rails.env.development?
    render json: {
      message: I18n.t('devise.failure.unknown'),
      details: Rails.env.development? ? exception.message : nil
    }, status: :internal_server_error
  end

  def respond_to_on_destroy
    render json: { message: I18n.t('devise.failure.unauthenticated') }, status: :unauthorized
  end

  def render_sign_in_success(user)
    token = request.env['warden-jwt_auth.token']
    response.headers['Authorization'] = "Bearer #{token}" if token

    render json: {
      message: I18n.t('devise.sessions.signed_in'),
      user: {
        id: user.id,
        email: user.email,
        name: user.name, 
        role: user.role
      },
      token: token
    }, status: :ok
  end

  def render_sign_out_success
    render json: { message: I18n.t('devise.sessions.signed_out') }, status: :ok
  end

  def user_json(user)
    user.as_json(
      only: [:id, :email, :name],
      methods: [:admin?]
    )
  end

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end
end
