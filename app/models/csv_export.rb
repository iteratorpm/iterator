class CsvExport < ApplicationRecord
  belongs_to :project

  enum :status, {
    queued: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }

  scope :recent, -> { order(created_at: :desc).limit(10) }

  def file_path
    Rails.root.join('storage', 'exports', "#{id}_#{filename}")
  end
end
