# config/initializers/assets.rb

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )

# Adicione todos os arquivos CSS do seu template na pasta 'album/'
Rails.application.config.assets.precompile += %w(
  album/bootstrap.min.css
  album/font-awesome.min.css
  album/slicknav.min.css
  album/fresco.css
  album/slick.css
  album/style.css
)

# Adicione todos os arquivos JavaScript do seu template na pasta 'album/'
Rails.application.config.assets.precompile += %w(
  album/vendor/jquery-3.2.1.min.js
  album/fresco.min.js
  album/jquery.slicknav.min.js
  album/slick.min.js
  album/main.js
)

# Você pode adicionar também os diretórios inteiros se preferir,
# mas listar os arquivos explicitamente é mais seguro e explícito.
# Exemplo para diretórios (alternativa, não use junto com a lista acima):
# Rails.application.config.assets.precompile << Proc.new { |path|
#   File.basename(path).in?(%w( .js .css )) && File.dirname(path).start_with?('album/')
# }