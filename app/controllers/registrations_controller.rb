class RegistrationsController < Devise::RegistrationsController
    respond_to :json
  
    def create
      build_resource(sign_up_params)
  
      resource.save
      if resource.persisted?
        render json: {
          message: 'Conta criada com sucesso.',
          user: resource
        }, status: :ok
      else
        render json: {
          message: 'Conta não pode ser criada.',
          errors: resource.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  
    private
  
    def sign_up_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end