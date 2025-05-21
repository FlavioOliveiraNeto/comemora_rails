class Media < ApplicationRecord
    belongs_to :user
    has_one_attached :file
  
    has_many :event_media
    has_many :events, through: :event_media
  
    validates :description, presence: true
end
  