class Medium < ApplicationRecord
  has_one_attached :file
  belongs_to :user
  has_many :event_media, dependent: :destroy
  has_many :events, through: :event_media

  validate :file_attached

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
end