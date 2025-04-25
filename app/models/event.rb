class Event < ApplicationRecord
  # Associations
  belongs_to :admin, class_name: 'User'
  
  has_many :event_participants, dependent: :destroy
  has_many :participants, through: :event_participants, source: :user
  
  has_many :event_media, dependent: :destroy
  has_many :media, through: :event_media
  
  # Active Storage para banner
  has_one_attached :banner

  # Validations
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :start_date, :end_date, presence: true
  validates :location, length: { maximum: 200 }
  validate :end_date_after_start_date
  validate :banner_validation

  # Scopes
  scope :upcoming, -> { where('start_date >= ?', Time.current).order(:start_date) }
  scope :past, -> { where('end_date < ?', Time.current).order(start_date: :desc) }
  scope :administered_by, ->(user) { where(admin: user) }

  # Role checking methods
  def admin?(user)
    admin == user
  end

  def participant?(user)
    participants.exists?(user.id)
  end

  def participant_status(user)
    event_participants.find_by(user: user)&.status
  end

  def accepted_participant?(user)
    participant_status(user) == 'accepted'
  end

  # Media management
  def add_media(user, media_file)
    return false unless can_add_media?(user)
    
    medium = user.media.create(file: media_file)
    event_media.create(medium: medium)
  end

  def can_add_media?(user)
    admin?(user) || accepted_participant?(user)
  end

  # Banner methods
  def banner_url
    return "default_banner_url" unless banner.attached?
    Rails.application.routes.url_helpers.url_for(banner)
  end

  # Invitation system
  def invite_user(user)
    return if admin?(user) || participant?(user)
    
    user = User.find_by(id: user.id)
    return false unless user

    event_participants.create(user: user, status: 'invited')
  end

  def accept_invitation(user)
    participant = event_participants.find_by(user: user)
    participant&.update(status: 'accepted')
  end

  def decline_invitation(user)
    participant = event_participants.find_by(user: user)
    participant&.update(status: 'declined')
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?
    
    if end_date < start_date
      errors.add(:end_date, "precisa ser depois da data de início")
    end
  end

  def banner_validation
    return unless banner.attached?
    
    if banner.blob.byte_size > 10.megabytes
      errors.add(:banner, "é muito grande (máximo 10MB)")
    elsif !banner.blob.content_type.starts_with?('image/')
      errors.add(:banner, "precisa ser uma imagem")
    end
  end
end
