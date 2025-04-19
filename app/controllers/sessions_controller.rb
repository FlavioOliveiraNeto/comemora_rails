class SessionsController < Devise::SessionsController
  respond_to :json

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
      message: 'Logado(a) com sucesso.',
      user: resource.as_json(only: [:id, :email, :name]),
      token: token
    }, status: :ok
  end

  def respond_to_on_destroy
    head :no_content
  end

  def handle_authentication_error(exception)
    error_message = case exception
                    when Warden::Strategies::Base::Failure
                      if exception.message == "Invalid Email or password."
                        "Credenciais inválidas"
                      else
                        "Falha na autenticação"
                      end
                    when ActiveRecord::RecordNotFound
                      "Conta não encontrada para o email informado"
                    else
                      "Ocorreu um erro durante o login"
                    end

    render json: { 
      message: error_message,
      details: exception.message
    }, status: :unauthorized
  end
end