source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'rails', '~> 7.0.0'
gem 'pg', '~> 1.0' # Mais recente e compatível com Rails 7
gem 'puma', '~> 5.0' # Ou '~> 6.0', compatível com Rails 7

# As gems abaixo são para o Asset Pipeline tradicional (Rails 5/6).
# No Rails 7, a abordagem padrão mudou para jsbundling-rails e cssbundling-rails.
# Se você tiver problemas, considere substituí-las ou migrar para a nova abordagem.
gem 'sass-rails', '~> 5.0' # Para SASS, Rails 7 prefere 'dart-sass' com 'cssbundling-rails'
gem 'uglifier', '>= 1.3.0' # Pode ser substituído por 'terser'
gem 'webpacker' # Substituído por 'jsbundling-rails' e 'cssbundling-rails'
# gem 'duktape' # Geralmente não necessário com Node.js para assets
# gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5' # Substituído por 'turbo-rails' (Hotwire)

gem 'jbuilder', '~> 2.5'
gem 'redis', '~> 4.0' # Descomente se usar Redis
gem 'bcrypt', '~> 3.1.7' # Descomente se usar has_secure_password
gem 'mini_magick', '~> 4.8' # Descomente se usar ActiveStorage variants

# gem 'capistrano-rails', group: :development # Descomente se usar Capistrano

gem 'bootsnap', '>= 1.18.6', require: false

gem 'logger'
gem 'concurrent-ruby', '1.3.4'
gem 'devise'
# gem 'devise-i18n', '~> 1.13.0'
gem 'rack-cors'
gem 'devise-jwt'
gem 'pundit'
gem 'kaminari'
gem 'whenever'
gem 'prawn'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'warden'
end

group :development do
  gem 'web-console', '~> 4.0'
  gem 'letter_opener'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]