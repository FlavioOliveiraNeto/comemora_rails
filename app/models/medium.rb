class Medium < ApplicationRecord
  belongs_to :user
  has_many :event_media
  has_many :events, through: :event_media
  
  # Use a gem como shrine ou active storage para upload de arquivos
  include ImageUploader::Attachment(:file)
end