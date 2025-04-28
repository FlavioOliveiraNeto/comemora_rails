class Medium < ApplicationRecord
  has_one_attached :file
  belongs_to :user
  has_many :event_media
  has_many :events, through: :event_media
end