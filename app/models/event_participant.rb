class EventParticipant < ApplicationRecord
  belongs_to :event
  belongs_to :user
  
  enum status: {
    invited: 'invited',
    accepted: 'accepted',
    declined: 'declined'
  }
  
  validates :status, inclusion: { in: statuses.keys }
end