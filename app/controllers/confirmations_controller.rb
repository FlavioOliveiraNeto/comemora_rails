class ConfirmationsController < Devise::ConfirmationsController
  respond_to :json

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    
    if resource.errors.empty?
      render json: { message: 'Conta confirmada com sucesso.' }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end
end