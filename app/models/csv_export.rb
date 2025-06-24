class CsvExport < ApplicationRecord
  belongs_to :project

  enum :state, {
    queued: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }

  scope :recent, -> { order(created_at: :desc).limit(10) }

  before_validation :sanitize_filename

  validates :filename, presence: true, format: { with: /\A[\w.\-]+\z/, message: 'contains invalid characters' }

  def file_path
    Rails.root.join('storage', 'exports', "#{id}_#{filename}")
  end

  SAFE_STORAGE_PATH = Rails.root.join('storage', 'exports').to_s

  def full_file_path
    path = File.expand_path(file_path.to_s, SAFE_STORAGE_PATH)
    unless path.start_with?(SAFE_STORAGE_PATH)
      raise SecurityError, "Unsafe file path"
    end
    path
  end

  def file_path
    Rails.root.join('storage', 'exports', "#{id}_#{filename}")
  end

  def generate_filename!
    self.filename = "#{project.name.parameterize}_#{Time.now.to_i}-export.csv"
  end

  private

  def sanitize_filename
    if filename.present?
      self.filename = File.basename(filename.to_s).gsub(/[^0-9A-Za-z.\-]/, '_')
    end
  end
end
