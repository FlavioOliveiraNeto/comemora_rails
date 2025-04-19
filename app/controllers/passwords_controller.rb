class PasswordsController < Devise::PasswordsController
  respond_to :json
  before_action :validate_password_params, only: [:create]
  before_action :validate_reset_params, only: [:update]

  def create
    self.resource = send_reset_instructions
    if successfully_sent?(resource)
      render_reset_instructions_sent
    else
      render_reset_instructions_error
    end
  rescue => e
    handle_reset_error(e)
  end

  def update
    self.resource = reset_password
    if resource.errors.empty?
      render_password_updated
    else
      render_password_update_error
    end
  rescue => e
    handle_reset_error(e)
  end

  private

  def send_reset_instructions
    resource_class.send_reset_password_instructions(resource_params)
  end

  def reset_password
    resource_class.reset_password_by_token(resource_params)
  end

  def render_reset_instructions_sent
    render json: {
      message: I18n.t('devise.passwords.send_instructions')
    }, status: :ok
  end

  def render_reset_instructions_error
    render json: {
      message: I18n.t('devise.passwords.send_instructions_error'),
      errors: resource.errors.full_messages
    }, status: :unprocessable_entity
  end

  def render_password_updated
    render json: {
      message: I18n.t('devise.passwords.updated')
    }, status: :ok
  end

  def render_password_update_error
    render json: {
      message: I18n.t('devise.passwords.update_error'),
      errors: resource.errors.full_messages,
      details: error_details(resource.errors)
    }, status: :unprocessable_entity
  end

  def handle_reset_error(exception)
    render json: {
      message: I18n.t('devise.passwords.error'),
      details: Rails.env.development? ? exception.message : nil
    }, status: :internal_server_error
  end

  def error_details(errors)
    errors.details.each_with_object({}) do |(attribute, details), hash|
      hash[attribute] = details.map { |d| d[:error] }
    end
  end

  def validate_password_params
    return if resource_params[:email].present?

    render json: {
      message: I18n.t('devise.passwords.no_email')
    }, status: :unprocessable_entity
  end

  def validate_reset_params
    return if resource_params[:reset_password_token].present? && 
              resource_params[:password].present? && 
              resource_params[:password_confirmation].present?

    render json: {
      message: I18n.t('devise.passwords.invalid_reset_params')
    }, status: :unprocessable_entity
  end

  def resource_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :reset_password_token
    )
  end
end