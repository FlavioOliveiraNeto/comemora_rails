class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  before_action :configure_sign_up_params, only: [:create]

  def create
    if params[:user].blank?
      render json: {
        message: I18n.t('devise.registrations.missing_params')
      }, status: :bad_request
      return
    end

    build_resource(sign_up_params)
    Rails.logger.debug "Tentando criar usuário com os parâmetros: #{sign_up_params.inspect}" if Rails.env.development?

    resource.save
    if resource.persisted?
      render_registration_success(resource)
    else
      render_registration_error(resource)
    end
  rescue => e
    handle_registration_error(e)
  end

  private

  def render_registration_success(user)
    render json: {
      message: I18n.t('devise.registrations.signed_up'),
      user: user_json(user)
    }, status: :created
  end

  def render_registration_error(user)
    render json: {
      message: I18n.t('devise.registrations.failed'),
      errors: user.errors.full_messages,
      details: error_details(user.errors)
    }, status: :unprocessable_entity
  end

  def handle_registration_error(exception)
    Rails.logger.error "Erro ao registrar usuário: #{exception.message}" if Rails.env.development?
    render json: {
      message: I18n.t('devise.registrations.error'),
      details: Rails.env.development? ? exception.message : nil
    }, status: :internal_server_error
  end

  def user_json(user)
    user.as_json(
      only: [:id, :email, :name, :created_at],
      methods: [:admin?]
    )
  end

  def error_details(errors)
    errors.details.each_with_object({}) do |(attribute, details), hash|
      hash[attribute] = details.map { |d| d[:error] }
    end
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email])
  end

  def sign_up_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end
end
