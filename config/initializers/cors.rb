Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'https://thunderous-seahorse-705db1.netlify.app', 'http://localhost:8080'
  
      resource '*',
        headers: :any,
        methods: [:get, :post, :put, :patch, :delete, :options, :head],
        expose: ['Authorization'],
        credentials: true
    end
end