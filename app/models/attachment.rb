class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true
  belongs_to :uploader, class_name: 'User'

  validates :filename, presence: true
  validates :file_path, presence: true
  validates :uploader, presence: true

  # For Active Storage integration
  has_one_attached :file

  # Validations for file size, type, etc. can be added here
  validate :acceptable_file

  # Define file type helper methods
  def image?
    content_type.start_with?('image/')
  end

  def document?
    %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
       application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
       application/vnd.ms-powerpoint application/vnd.openxmlformats-officedocument.presentationml.presentation
       text/plain].include?(content_type)
  end

  def code?
    %w[text/x-ruby text/x-python text/x-java text/javascript text/x-c text/x-c++
       application/json text/html text/css].include?(content_type)
  end

  private

  def acceptable_file
    unless file.attached?
      errors.add(:file, "must be attached")
      return
    end

    unless file.byte_size <= 50.megabytes
      errors.add(:file, "is too large (max 50MB)")
    end
  end
end
