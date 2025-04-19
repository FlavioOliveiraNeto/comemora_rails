if Rails.env.development?
    require 'letter_opener'
    LetterOpener.configure do |config|
      # Para abrir em nova aba ao invés de popup
      config.message_template = :light
    end
end