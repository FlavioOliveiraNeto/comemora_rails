class ConfirmationsController < Devise::ConfirmationsController
  respond_to :json
  before_action :validate_confirmation_token, only: [:show]

  def show
    self.resource = confirm_resource
    if resource.errors.empty?
      render_confirmation_success
    else
      render_confirmation_error
    end
  rescue => e
    handle_confirmation_error(e)
  end

  private

  def confirm_resource
    resource_class.confirm_by_token(params[:confirmation_token])
  end

  def render_confirmation_success
    render json: {
      message: I18n.t('devise.confirmations.confirmed'),
      user: confirmed_user_json
    }, status: :ok
  end

  def render_confirmation_error
    render json: {
      message: I18n.t('devise.confirmations.failed'),
      errors: resource.errors.full_messages,
      details: error_details(resource.errors)
    }, status: :unprocessable_entity
  end

  def handle_confirmation_error(exception)
    render json: {
      message: I18n.t('devise.confirmations.error'),
      details: Rails.env.development? ? exception.message : nil
    }, status: :internal_server_error
  end

  def confirmed_user_json
    resource.as_json(
      only: [:id, :email, :name, :confirmed_at],
      methods: [:admin?]
    )
  end

  def error_details(errors)
    errors.details.each_with_object({}) do |(attribute, details), hash|
      hash[attribute] = details.map { |d| d[:error] }
    end
  end

  def validate_confirmation_token
    return if params[:confirmation_token].present?

    render json: {
      message: I18n.t('devise.confirmations.no_token')
    }, status: :unprocessable_entity
  end
end