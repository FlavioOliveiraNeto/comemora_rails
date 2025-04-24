class EventMedium < ApplicationRecord
  belongs_to :event
  belongs_to :medium
end