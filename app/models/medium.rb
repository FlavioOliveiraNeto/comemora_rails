class Medium < ApplicationRecord
  has_one_attached :file
  belongs_to :user
  has_many :event_media, dependent: :destroy
  has_many :events, through: :event_media

  validate :file_attached
  validates :file_data, inclusion: { in: %w[photo video], allow_nil: false }

  before_validation :set_file_data

  def file_url
    if file.attached?
      Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false)
    end
  rescue StandardError => e
    Rails.logger.error "Error generating URL for medium #{id}: #{e.message}"
    nil
  end

  private

  def file_attached
    errors.add(:file, "deve ser anexado") unless file.attached?
  end

  def set_file_data
    return unless file.attached?
  
    self.file_data = if file.content_type.start_with?('image/')
                      'photo'
                    else
                      'video'
                    end
  end  
end