class PasswordsController < Devise::PasswordsController
    respond_to :json
  
    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      
      if successfully_sent?(resource)
        render json: { message: 'Instruções para redefinir senha enviadas.' }, status: :ok
      else
        render json: { message: 'Instruções para redefinir senha não puderam ser enviadas.' }, status: :unprocessable_entity
      end
    end
  
    def update
      self.resource = resource_class.reset_password_by_token(resource_params)
      
      if resource.errors.empty?
        render json: { message: 'Senha atualizada com sucesso.' }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end
end