class ApplicationController < ActionController::API
    before_action :cors_preflight_check
    after_action :cors_set_access_control_headers
  
    protected
  
    def cors_set_access_control_headers
      headers['Access-Control-Allow-Origin'] = 'http://localhost:8080'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, X-Requested-With'
      headers['Access-Control-Max-Age'] = '1728000'
    end
  
    def cors_preflight_check
      if request.method == 'OPTIONS'
        headers['Access-Control-Allow-Origin'] = 'http://localhost:8080'
        headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, PATCH, DELETE, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        headers['Access-Control-Max-Age'] = '1728000'
        render plain: '', content_type: 'text/plain'
      end
    end
end